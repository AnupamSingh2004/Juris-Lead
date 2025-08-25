#!/bin/bash

# Azure Web App for Containers Deployment Script
# Alternative deployment method using Azure Web App for Containers

set -e

# Configuration
RESOURCE_GROUP_NAME="ipc-justice-aid-webapp-rg"
LOCATION="Central India"
APP_NAME="ipc-justice-aid-webapp"
PLAN_NAME="ipc-justice-aid-plan"

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

# Login to Azure
echo_info "Logging into Azure..."
az login

# Create resource group
echo_info "Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION"

# Create App Service Plan (Linux)
echo_info "Creating App Service Plan..."
az appservice plan create \
    --name "$PLAN_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --is-linux \
    --sku B1

# Create Azure Database for PostgreSQL
echo_info "Creating PostgreSQL server..."
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
POSTGRES_SERVER_NAME="$APP_NAME-postgres-$(date +%s)"

az postgres flexible-server create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$POSTGRES_SERVER_NAME" \
    --location "$LOCATION" \
    --admin-user ipc_admin \
    --admin-password "$POSTGRES_PASSWORD" \
    --sku-name Standard_B1ms \
    --tier Burstable \
    --storage-size 32 \
    --version 14

# Create database
az postgres flexible-server db create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --server-name "$POSTGRES_SERVER_NAME" \
    --database-name ipc_justice_aid

# Allow Azure services to access PostgreSQL
az postgres flexible-server firewall-rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$POSTGRES_SERVER_NAME" \
    --rule-name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Create Redis Cache
echo_info "Creating Redis Cache..."
REDIS_CACHE_NAME="$APP_NAME-redis-$(date +%s)"
az redis create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$REDIS_CACHE_NAME" \
    --location "$LOCATION" \
    --sku Basic \
    --vm-size c0

# Create Container Registry
echo_info "Creating Container Registry..."
REGISTRY_NAME="${APP_NAME}acr$(date +%s)"
az acr create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$REGISTRY_NAME" \
    --sku Basic \
    --admin-enabled true

# Get ACR login server
REGISTRY_LOGIN_SERVER=$(az acr show --name "$REGISTRY_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query loginServer --output tsv)

# Build and push image to ACR
echo_info "Building and pushing Docker image..."
az acr build \
    --registry "$REGISTRY_NAME" \
    --image ipc-justice-aid:latest \
    .

# Create Web App
echo_info "Creating Web App..."
az webapp create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --plan "$PLAN_NAME" \
    --name "$APP_NAME" \
    --deployment-container-image-name "$REGISTRY_LOGIN_SERVER/ipc-justice-aid:latest"

# Configure Web App to use ACR
ACR_USERNAME=$(az acr credential show --name "$REGISTRY_NAME" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$REGISTRY_NAME" --query passwords[0].value --output tsv)

az webapp config container set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --docker-custom-image-name "$REGISTRY_LOGIN_SERVER/ipc-justice-aid:latest" \
    --docker-registry-server-url "https://$REGISTRY_LOGIN_SERVER" \
    --docker-registry-server-user "$ACR_USERNAME" \
    --docker-registry-server-password "$ACR_PASSWORD"

# Get Redis connection details
REDIS_HOST=$(az redis show --name "$REDIS_CACHE_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query hostName --output tsv)
REDIS_KEY=$(az redis list-keys --name "$REDIS_CACHE_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query primaryKey --output tsv)
REDIS_URL="rediss://:$REDIS_KEY@$REDIS_HOST:6380/0?ssl_cert_reqs=none"

# Generate secret key
SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)

# Configure Web App settings
echo_info "Configuring Web App settings..."
az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$APP_NAME" \
    --settings \
        DEBUG=False \
        SECRET_KEY="$SECRET_KEY" \
        AZURE_APP_SERVICE=True \
        DATABASE_NAME=ipc_justice_aid \
        DATABASE_USER=ipc_admin \
        DATABASE_PASSWORD="$POSTGRES_PASSWORD" \
        DATABASE_HOST="$POSTGRES_SERVER_NAME.postgres.database.azure.com" \
        DATABASE_PORT=5432 \
        DATABASE_SSL_MODE=require \
        REDIS_URL="$REDIS_URL" \
        CELERY_BROKER_URL="$REDIS_URL" \
        CELERY_RESULT_BACKEND="$REDIS_URL" \
        ALLOWED_HOSTS="$APP_NAME.azurewebsites.net,.azurewebsites.net" \
        WEBSITES_PORT=8000 \
        WEBSITES_CONTAINER_START_TIME_LIMIT=1800

# Enable continuous deployment
az webapp deployment container config \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --enable-cd true

# Get deployment details
APP_URL="https://$APP_NAME.azurewebsites.net"
WEBHOOK_URL=$(az webapp deployment container show-cd-url --name "$APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query CI_CD_URL --output tsv)

echo_info "Deployment completed successfully!"
echo_info "Application URL: $APP_URL"
echo_info "Webhook URL for CI/CD: $WEBHOOK_URL"
echo ""
echo_warning "Deployment credentials (save securely):"
echo "PostgreSQL Server: $POSTGRES_SERVER_NAME.postgres.database.azure.com"
echo "PostgreSQL Username: ipc_admin"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Redis Cache: $REDIS_HOST"
echo "Redis Key: $REDIS_KEY"
echo "Django Secret Key: $SECRET_KEY"
echo "Container Registry: $REGISTRY_LOGIN_SERVER"
echo "Registry Username: $ACR_USERNAME"
echo "Registry Password: $ACR_PASSWORD"
echo ""
echo_warning "Next steps:"
echo "1. Access your application at: $APP_URL"
echo "2. Configure custom domain and SSL certificate"
echo "3. Set up monitoring and logging"
echo "4. Configure backup strategies"
echo "5. Set up CI/CD pipeline using the webhook URL"
