#!/bin/bash

# Azure Deployment Script for IPC Justice Aid Backend
# This script deploys the application to Azure Container Apps

set -e

# Configuration
RESOURCE_GROUP_NAME="ipc-justice-aid-rg"
LOCATION="Central India"
APP_NAME="ipc-justice-aid"
SUBSCRIPTION_ID="" # Set your Azure subscription ID

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
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Login to Azure
echo_info "Logging into Azure..."
az login

# Set subscription
if [ -n "$SUBSCRIPTION_ID" ]; then
    echo_info "Setting Azure subscription..."
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Create resource group
echo_info "Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION"

# Generate secure passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)

echo_info "Generated secure passwords (save these securely):"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Django Secret Key: $SECRET_KEY"

# Deploy infrastructure
echo_info "Deploying Azure infrastructure..."
az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file azure-infrastructure.json \
    --parameters \
        appName="$APP_NAME" \
        location="$LOCATION" \
        postgresAdminPassword="$POSTGRES_PASSWORD"

# Wait for deployment to complete
echo_info "Waiting for deployment to complete..."
sleep 10

# Get deployment outputs
echo_info "Retrieving deployment outputs..."
CONTAINER_REGISTRY=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name azure-infrastructure \
    --query 'properties.outputs.containerRegistryLoginServer.value' \
    --output tsv)

POSTGRES_SERVER=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name azure-infrastructure \
    --query 'properties.outputs.postgresServerName.value' \
    --output tsv)

REDIS_CACHE=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name azure-infrastructure \
    --query 'properties.outputs.redisCacheName.value' \
    --output tsv)

STORAGE_ACCOUNT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name azure-infrastructure \
    --query 'properties.outputs.storageAccountName.value' \
    --output tsv)

CONTAINER_APP_ENV=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name azure-infrastructure \
    --query 'properties.outputs.containerAppEnvironmentName.value' \
    --output tsv)

# Check if all outputs were retrieved successfully
if [ -z "$CONTAINER_REGISTRY" ] || [ -z "$POSTGRES_SERVER" ] || [ -z "$REDIS_CACHE" ] || [ -z "$STORAGE_ACCOUNT" ] || [ -z "$CONTAINER_APP_ENV" ]; then
    echo_error "Failed to retrieve deployment outputs. Please check the deployment status."
    echo "Debugging deployment..."
    az deployment group show --resource-group "$RESOURCE_GROUP_NAME" --name azure-infrastructure
    exit 1
fi

echo_info "Infrastructure deployed successfully!"
echo "Container Registry: $CONTAINER_REGISTRY"
echo "PostgreSQL Server: $POSTGRES_SERVER"
echo "Redis Cache: $REDIS_CACHE"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container App Environment: $CONTAINER_APP_ENV"

# Get ACR credentials
echo_info "Getting container registry credentials..."
REGISTRY_NAME=$(echo "$CONTAINER_REGISTRY" | cut -d'.' -f1)
ACR_USERNAME=$(az acr credential show --name "$REGISTRY_NAME" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$REGISTRY_NAME" --query passwords[0].value --output tsv)

if [ -z "$ACR_USERNAME" ] || [ -z "$ACR_PASSWORD" ]; then
    echo_error "Failed to get ACR credentials"
    exit 1
fi

# Build and push Docker image
echo_info "Building and pushing Docker image..."
docker build -t "$CONTAINER_REGISTRY/ipc-justice-aid:latest" .
docker login "$CONTAINER_REGISTRY" -u "$ACR_USERNAME" -p "$ACR_PASSWORD"
docker push "$CONTAINER_REGISTRY/ipc-justice-aid:latest"

# Get Redis connection string
echo_info "Getting Redis connection string..."
REDIS_KEY=$(az redis list-keys --name "$REDIS_CACHE" --resource-group "$RESOURCE_GROUP_NAME" --query primaryKey --output tsv)
REDIS_URL="rediss://:$REDIS_KEY@$REDIS_CACHE.redis.cache.windows.net:6380/0?ssl_cert_reqs=none"

# Get storage account key
echo_info "Getting storage account key..."
STORAGE_KEY=$(az storage account keys list --account-name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP_NAME" --query '[0].value' --output tsv)

# Create Container App
echo_info "Creating Container App..."
az containerapp create \
    --name "$APP_NAME-app" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --environment "$CONTAINER_APP_ENV" \
    --image "$CONTAINER_REGISTRY/ipc-justice-aid:latest" \
    --target-port 8000 \
    --ingress external \
    --registry-server "$CONTAINER_REGISTRY" \
    --registry-username "$ACR_USERNAME" \
    --registry-password "$ACR_PASSWORD" \
    --secrets \
        secret-key="$SECRET_KEY" \
        database-password="$POSTGRES_PASSWORD" \
        redis-url="$REDIS_URL" \
        storage-key="$STORAGE_KEY" \
    --env-vars \
        DEBUG=False \
        SECRET_KEY=secretref:secret-key \
        AZURE_APP_SERVICE=True \
        DATABASE_NAME=ipc_justice_aid \
        DATABASE_USER=ipc_admin \
        DATABASE_PASSWORD=secretref:database-password \
        DATABASE_HOST="$POSTGRES_SERVER.postgres.database.azure.com" \
        DATABASE_PORT=5432 \
        DATABASE_SSL_MODE=require \
        REDIS_URL=secretref:redis-url \
        CELERY_BROKER_URL=secretref:redis-url \
        CELERY_RESULT_BACKEND=secretref:redis-url \
        USE_AZURE_STORAGE=True \
        AZURE_ACCOUNT_NAME="$STORAGE_ACCOUNT" \
        AZURE_ACCOUNT_KEY=secretref:storage-key \
        AZURE_CONTAINER=media \
        AZURE_STATIC_CONTAINER=static \
    --cpu 1.0 \
    --memory 2Gi \
    --min-replicas 1 \
    --max-replicas 5

# Get the app URL
APP_URL=$(az containerapp show --name "$APP_NAME-app" --resource-group "$RESOURCE_GROUP_NAME" --query properties.configuration.ingress.fqdn --output tsv)

echo_info "Deployment completed successfully!"
echo_info "Application URL: https://$APP_URL"
echo_info ""
echo_warning "Next steps:"
echo "1. Update your DNS settings to point to: $APP_URL"
echo "2. Configure environment variables in Azure Portal if needed"
echo "3. Set up custom domain and SSL certificate"
echo "4. Configure monitoring and alerts"
echo ""
echo_warning "Save these credentials securely:"
echo "PostgreSQL Server: $POSTGRES_SERVER.postgres.database.azure.com"
echo "PostgreSQL Username: ipc_admin"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Django Secret Key: $SECRET_KEY"
echo "Redis URL: $REDIS_URL"
