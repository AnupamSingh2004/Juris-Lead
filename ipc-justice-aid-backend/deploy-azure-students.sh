#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo_info "Azure for Students Deployment Script"
echo_warning "This script is optimized for Azure for Students subscriptions"

# Generate unique names
TIMESTAMP=$(date +%s | tail -c 5)
REGISTRY_NAME="ipcjusticeaidacr$TIMESTAMP"
POSTGRES_SERVER="ipcjusticeaidpg$TIMESTAMP"
REDIS_NAME="ipcjusticeaidredis$TIMESTAMP"

# Generate secure passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)

echo_info "Generated credentials (save these!):"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Django Secret Key: $SECRET_KEY"

# Use existing resource group or create new one
echo_info "Ensuring resource group exists..."
az group create --name ipc-justice-aid-rg --location "Central India" || echo_warning "Resource group already exists"

# Create ACR
echo_info "Creating Container Registry..."
az acr create \
    --resource-group ipc-justice-aid-rg \
    --name $REGISTRY_NAME \
    --sku Basic \
    --admin-enabled true \
    --location "Central India"

ACR_LOGIN_SERVER=$(az acr show --name $REGISTRY_NAME --query loginServer --output tsv)

# Create PostgreSQL
echo_info "Creating PostgreSQL server..."
az postgres flexible-server create \
    --resource-group ipc-justice-aid-rg \
    --name $POSTGRES_SERVER \
    --location "Central India" \
    --admin-user ipc_admin \
    --admin-password "$POSTGRES_PASSWORD" \
    --sku-name Standard_B1ms \
    --tier Burstable \
    --storage-size 32 \
    --version 14 \
    --public-access 0.0.0.0

az postgres flexible-server db create \
    --resource-group ipc-justice-aid-rg \
    --server-name $POSTGRES_SERVER \
    --database-name ipc_justice_aid

# Create App Service Plan
echo_info "Creating App Service Plan..."
az appservice plan create \
    --name ipc-justice-aid-plan \
    --resource-group ipc-justice-aid-rg \
    --location "Central India" \
    --is-linux \
    --sku B1

# Create Web App
echo_info "Creating Web App..."
az webapp create \
    --resource-group ipc-justice-aid-rg \
    --plan ipc-justice-aid-plan \
    --name ipc-justice-aid-app \
    --deployment-container-image-name nginx

# Build and push image
echo_info "Building and pushing Docker image..."
az acr build --registry $REGISTRY_NAME --image ipc-justice-aid:latest .

# Configure Web App
echo_info "Configuring Web App..."
ACR_USERNAME=$(az acr credential show --name $REGISTRY_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $REGISTRY_NAME --query passwords[0].value --output tsv)

az webapp config container set \
    --name ipc-justice-aid-app \
    --resource-group ipc-justice-aid-rg \
    --docker-custom-image-name "$ACR_LOGIN_SERVER/ipc-justice-aid:latest" \
    --docker-registry-server-url "https://$ACR_LOGIN_SERVER" \
    --docker-registry-server-user $ACR_USERNAME \
    --docker-registry-server-password $ACR_PASSWORD

az webapp config appsettings set \
    --resource-group ipc-justice-aid-rg \
    --name ipc-justice-aid-app \
    --settings \
        DEBUG=False \
        SECRET_KEY="$SECRET_KEY" \
        AZURE_APP_SERVICE=True \
        DATABASE_NAME=ipc_justice_aid \
        DATABASE_USER=ipc_admin \
        DATABASE_PASSWORD="$POSTGRES_PASSWORD" \
        DATABASE_HOST="$POSTGRES_SERVER.postgres.database.azure.com" \
        DATABASE_PORT=5432 \
        DATABASE_SSL_MODE=require \
        ALLOWED_HOSTS="ipc-justice-aid-app.azurewebsites.net,.azurewebsites.net" \
        WEBSITES_PORT=8000 \
        WEBSITES_CONTAINER_START_TIME_LIMIT=1800

echo_info "Deployment completed!"
echo_info "Application URL: https://ipc-justice-aid-app.azurewebsites.net"
echo_warning "Save these credentials:"
echo "PostgreSQL: $POSTGRES_SERVER.postgres.database.azure.com"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Django Secret: $SECRET_KEY"
echo "Container Registry: $ACR_LOGIN_SERVER"
