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

echo_info "Azure Web App Deployment using existing resources"

# Use existing resources
RESOURCE_GROUP="ipc-justice-aid-rg"
REGISTRY_NAME="ipcjusticeaidacr0127"
POSTGRES_SERVER="ipcjusticeaidpg0140"

# Generate unique app name
TIMESTAMP=$(date +%s | tail -c 5)
WEB_APP_NAME="ipc-justice-aid-app-$TIMESTAMP"

echo_info "Using existing resources:"
echo "Resource Group: $RESOURCE_GROUP"
echo "Container Registry: $REGISTRY_NAME"
echo "PostgreSQL Server: $POSTGRES_SERVER"
echo "Web App Name: $WEB_APP_NAME"

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $REGISTRY_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
echo_info "Container Registry URL: $ACR_LOGIN_SERVER"

# Get PostgreSQL connection info (we'll need to set password manually)
echo_warning "You'll need to provide the PostgreSQL password when prompted"
echo "PostgreSQL Server: $POSTGRES_SERVER.postgres.database.azure.com"

# Create App Service Plan
echo_info "Creating App Service Plan..."
az appservice plan create \
    --name ipc-justice-aid-plan \
    --resource-group $RESOURCE_GROUP \
    --location "Central India" \
    --is-linux \
    --sku B1 || echo_warning "App Service Plan might already exist"

# Create Web App
echo_info "Creating Web App: $WEB_APP_NAME"
az webapp create \
    --resource-group $RESOURCE_GROUP \
    --plan ipc-justice-aid-plan \
    --name $WEB_APP_NAME \
    --deployment-container-image-name nginx

# Build and push image to existing ACR
echo_info "Building and pushing Docker image to existing ACR..."
az acr build --registry $REGISTRY_NAME --image ipc-justice-aid:latest .

# Get ACR credentials
echo_info "Getting ACR credentials..."
ACR_USERNAME=$(az acr credential show --name $REGISTRY_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $REGISTRY_NAME --query passwords[0].value --output tsv)

# Configure Web App to use our image
echo_info "Configuring Web App container..."
az webapp config container set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --docker-custom-image-name "$ACR_LOGIN_SERVER/ipc-justice-aid:latest" \
    --docker-registry-server-url "https://$ACR_LOGIN_SERVER" \
    --docker-registry-server-user $ACR_USERNAME \
    --docker-registry-server-password $ACR_PASSWORD

# Generate Django secret key
SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)

echo_warning "Please enter the PostgreSQL password when prompted:"
read -s POSTGRES_PASSWORD

# Configure app settings
echo_info "Configuring Web App environment variables..."
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $WEB_APP_NAME \
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
        ALLOWED_HOSTS="$WEB_APP_NAME.azurewebsites.net,.azurewebsites.net" \
        WEBSITES_PORT=8000 \
        WEBSITES_CONTAINER_START_TIME_LIMIT=1800

echo_info "Deployment completed!"
echo_info "Application URL: https://$WEB_APP_NAME.azurewebsites.net"
echo_warning "Credentials generated:"
echo "Django Secret Key: $SECRET_KEY"
echo "Web App Name: $WEB_APP_NAME"
echo "Container Registry: $ACR_LOGIN_SERVER"

echo_info "To view logs, run:"
echo "az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
