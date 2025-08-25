#!/bin/bash

# Simplified Azure Deployment Script for IPC Justice Aid Backend
# This script deploys resources individually instead of using ARM templates

set -e

# Configuration
RESOURCE_GROUP_NAME="ipc-justice-aid-rg"
LOCATION="Central India"
APP_NAME="ipc-justice-aid"
SUBSCRIPTION_ID=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Login to Azure (skip if already logged in)
echo_info "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo_info "Logging into Azure..."
    az login
fi

# Set subscription if provided
if [ -n "$SUBSCRIPTION_ID" ]; then
    echo_info "Setting Azure subscription..."
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Get current subscription info
CURRENT_SUBSCRIPTION=$(az account show --query name --output tsv)
echo_info "Using subscription: $CURRENT_SUBSCRIPTION"

# Create resource group
echo_info "Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --output table

# Generate secure passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)

echo_info "Generated secure passwords (save these securely):"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Django Secret Key: $SECRET_KEY"

# Create Container Registry
echo_info "Creating Container Registry..."
REGISTRY_NAME="ipcjusticeaidacr$(date +%s | tail -c 5)"
az acr create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$REGISTRY_NAME" \
    --sku Basic \
    --admin-enabled true \
    --location "$LOCATION" \
    --output table

CONTAINER_REGISTRY="${REGISTRY_NAME}.azurecr.io"

# Create PostgreSQL server
echo_info "Creating PostgreSQL server..."
POSTGRES_SERVER_NAME="ipcjusticeaidpg$(date +%s | tail -c 5)"
az postgres flexible-server create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$POSTGRES_SERVER_NAME" \
    --location "$LOCATION" \
    --admin-user ipc_admin \
    --admin-password "$POSTGRES_PASSWORD" \
    --sku-name Standard_B1ms \
    --tier Burstable \
    --storage-size 32 \
    --version 14 \
    --output table

# Create database
echo_info "Creating database..."
az postgres flexible-server db create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --server-name "$POSTGRES_SERVER_NAME" \
    --database-name ipc_justice_aid

# Allow Azure services to access PostgreSQL
echo_info "Configuring PostgreSQL firewall..."
az postgres flexible-server firewall-rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$POSTGRES_SERVER_NAME" \
    --rule-name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Create Redis Cache
echo_info "Creating Redis Cache..."
REDIS_CACHE_NAME="ipcjusticeaidredis$(date +%s | tail -c 5)"
az redis create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$REDIS_CACHE_NAME" \
    --location "$LOCATION" \
    --sku Basic \
    --vm-size c0 \
    --output table

# Create Log Analytics workspace
echo_info "Creating Log Analytics workspace..."
LOG_ANALYTICS_NAME="ipcjusticeaidlogs$(date +%s | tail -c 5)"
az monitor log-analytics workspace create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --workspace-name "$LOG_ANALYTICS_NAME" \
    --location "$LOCATION" \
    --output table

# Create Container App Environment
echo_info "Creating Container App Environment..."
CONTAINER_APP_ENV="$APP_NAME-env"
az containerapp env create \
    --name "$CONTAINER_APP_ENV" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --logs-workspace-id "/subscriptions/$(az account show --query id --output tsv)/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.OperationalInsights/workspaces/$LOG_ANALYTICS_NAME" \
    --output table

# Get ACR credentials
echo_info "Getting container registry credentials..."
ACR_USERNAME=$(az acr credential show --name "$REGISTRY_NAME" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$REGISTRY_NAME" --query passwords[0].value --output tsv)

# Build and push Docker image
echo_info "Building and pushing Docker image..."
az acr build \
    --registry "$REGISTRY_NAME" \
    --image "$APP_NAME:latest" \
    .

# Get Redis connection details
echo_info "Getting Redis connection string..."
REDIS_KEY=$(az redis list-keys --name "$REDIS_CACHE_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query primaryKey --output tsv)
REDIS_URL="rediss://:$REDIS_KEY@$REDIS_CACHE_NAME.redis.cache.windows.net:6380/0?ssl_cert_reqs=none"

# Create Container App
echo_info "Creating Container App..."
az containerapp create \
    --name "$APP_NAME-app" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --environment "$CONTAINER_APP_ENV" \
    --image "$CONTAINER_REGISTRY/$APP_NAME:latest" \
    --target-port 8000 \
    --ingress external \
    --registry-server "$CONTAINER_REGISTRY" \
    --registry-username "$ACR_USERNAME" \
    --registry-password "$ACR_PASSWORD" \
    --secrets \
        secret-key="$SECRET_KEY" \
        database-password="$POSTGRES_PASSWORD" \
        redis-url="$REDIS_URL" \
    --env-vars \
        DEBUG=False \
        SECRET_KEY=secretref:secret-key \
        AZURE_APP_SERVICE=True \
        DATABASE_NAME=ipc_justice_aid \
        DATABASE_USER=ipc_admin \
        DATABASE_PASSWORD=secretref:database-password \
        DATABASE_HOST="$POSTGRES_SERVER_NAME.postgres.database.azure.com" \
        DATABASE_PORT=5432 \
        DATABASE_SSL_MODE=require \
        REDIS_URL=secretref:redis-url \
        CELERY_BROKER_URL=secretref:redis-url \
        CELERY_RESULT_BACKEND=secretref:redis-url \
    --cpu 1.0 \
    --memory 2Gi \
    --min-replicas 1 \
    --max-replicas 5 \
    --output table

# Get the app URL
echo_info "Getting application URL..."
APP_URL=$(az containerapp show --name "$APP_NAME-app" --resource-group "$RESOURCE_GROUP_NAME" --query properties.configuration.ingress.fqdn --output tsv)

echo_info "Deployment completed successfully!"
echo_info "Application URL: https://$APP_URL"
echo_info ""
echo_warning "IMPORTANT: Save these credentials securely:"
echo "PostgreSQL Server: $POSTGRES_SERVER_NAME.postgres.database.azure.com"
echo "PostgreSQL Username: ipc_admin"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Django Secret Key: $SECRET_KEY"
echo "Redis Cache: $REDIS_CACHE_NAME.redis.cache.windows.net"
echo "Redis URL: $REDIS_URL"
echo "Container Registry: $CONTAINER_REGISTRY"
echo "Registry Username: $ACR_USERNAME"
echo ""
echo_warning "Next steps:"
echo "1. Test your application at: https://$APP_URL"
echo "2. Configure custom domain if needed"
echo "3. Set up monitoring and alerts"
echo "4. Configure backup strategies"
echo ""
echo_info "To clean up resources (if needed):"
echo "az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait"
