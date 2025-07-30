#!/bin/bash

# AarogyaRekha Azure India Deployment Script
# This script creates all necessary Azure resources for India deployment

set -e  # Exit on any error

# Configuration
RESOURCE_GROUP="aarogyarekha-rg"
LOCATION="Central India"
APP_NAME="aarogyarekha-api-india"
DB_SERVER_NAME="aarogyarekha-db-server"
REDIS_NAME="aarogyarekha-redis"
STORAGE_NAME="aarogyarekhasto"
PLAN_NAME="aarogyarekha-plan"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🇮🇳 AarogyaRekha Azure India Deployment Script${NC}"
echo "========================================"

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI authenticated${NC}"

# Register required providers
echo -e "${BLUE}🔧 Registering Azure providers...${NC}"
az provider register --namespace Microsoft.Storage
echo -e "${GREEN}✅ Providers registered${NC}"

# Prompt for required values
read -p "Enter database admin password: " -s DB_PASSWORD
echo
read -p "Enter a strong secret key: " -s SECRET_KEY
echo

if [ -z "$DB_PASSWORD" ] || [ -z "$SECRET_KEY" ]; then
    echo -e "${RED}❌ Password and secret key are required${NC}"
    exit 1
fi

echo -e "${YELLOW}🚀 Starting deployment to Central India...${NC}"

# Create Resource Group
echo -e "${BLUE}📁 Creating resource group...${NC}"
az group create --name $RESOURCE_GROUP --location "$LOCATION" --output table

# Create PostgreSQL Flexible Server (Modern version)
echo -e "${BLUE}🗄️ Creating PostgreSQL Flexible server...${NC}"
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --location "$LOCATION" \
  --admin-user aarogyarekha_admin \
  --admin-password "$DB_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 13 \
  --storage-size 32 \
  --public-access 0.0.0.0 \
  --output table

# Create Database
echo -e "${BLUE}📊 Creating database...${NC}"
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER_NAME \
  --database-name aarogyarekha_db \
  --output table

# Configure Database Firewall for Flexible Server
echo -e "${BLUE}🔥 Configuring database firewall...${NC}"
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --rule-name AllowAllAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

# Add India IP ranges for Flexible Server
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --rule-name AllowIndianMobileNetworks \
  --start-ip-address 49.0.0.0 \
  --end-ip-address 49.255.255.255 \
  --output table

# Create Redis Cache
echo -e "${BLUE}⚡ Creating Redis cache...${NC}"
az redis create \
  --resource-group $RESOURCE_GROUP \
  --name $REDIS_NAME \
  --location "$LOCATION" \
  --sku Basic \
  --vm-size c0 \
  --output table

# Create Storage Account
echo -e "${BLUE}💾 Creating storage account...${NC}"
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_NAME \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --output table

# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_NAME --query '[0].value' -o tsv)

# Create storage containers
echo -e "${BLUE}📦 Creating storage containers...${NC}"
az storage container create --name static --account-name $STORAGE_NAME --account-key "$STORAGE_KEY" --public-access blob
az storage container create --name media --account-name $STORAGE_NAME --account-key "$STORAGE_KEY" --public-access blob

# Create App Service Plan
echo -e "${BLUE}🏗️ Creating App Service Plan...${NC}"
az appservice plan create \
  --resource-group $RESOURCE_GROUP \
  --name $PLAN_NAME \
  --location "$LOCATION" \
  --sku B1 \
  --is-linux \
  --output table

# Create Web App
echo -e "${BLUE}🌐 Creating Web App...${NC}"
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $PLAN_NAME \
  --name $APP_NAME \
  --runtime "PYTHON|3.11" \
  --deployment-local-git \
  --output table

# Configure startup command
echo -e "${BLUE}⚙️ Configuring startup command...${NC}"
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --startup-file "startup.sh" \
  --output table

# Get Redis connection details
REDIS_HOST=$(az redis show --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query "hostName" -o tsv)
REDIS_KEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query "primaryKey" -o tsv)

# Configure application settings
echo -e "${BLUE}🔧 Configuring application settings...${NC}"
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --settings \
    DEBUG=False \
    SECRET_KEY="$SECRET_KEY" \
    AZURE_APP_SERVICE=True \
    AZURE_DOMAIN="$APP_NAME" \
    ALLOWED_HOSTS="$APP_NAME.azurewebsites.net" \
    DATABASE_NAME="aarogyarekha_db" \
    DATABASE_USER="aarogyarekha_admin" \
    DATABASE_PASSWORD="$DB_PASSWORD" \
    DATABASE_HOST="$DB_SERVER_NAME.postgres.database.azure.com" \
    DATABASE_PORT="5432" \
    DATABASE_SSL_MODE="require" \
    USE_AZURE_STORAGE=True \
    AZURE_ACCOUNT_NAME="$STORAGE_NAME" \
    AZURE_ACCOUNT_KEY="$STORAGE_KEY" \
    AZURE_CONTAINER="media" \
    AZURE_STATIC_CONTAINER="static" \
    REDIS_HOST="$REDIS_HOST" \
    REDIS_PORT="6380" \
    REDIS_PASSWORD="$REDIS_KEY" \
    TIME_ZONE="Asia/Kolkata" \
    LANGUAGE_CODE="en-in" \
    CORS_ALLOWED_ORIGINS="https://$APP_NAME.azurewebsites.net" \
    CSRF_TRUSTED_ORIGINS="https://$APP_NAME.azurewebsites.net" \
  --output table

# Get deployment URL
DEPLOYMENT_URL=$(az webapp deployment source config-local-git --resource-group $RESOURCE_GROUP --name $APP_NAME --query url -o tsv)

echo
echo -e "${GREEN}🎉 Deployment setup completed successfully!${NC}"
echo "========================================"
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Add git remote: git remote add azure $DEPLOYMENT_URL"
echo "2. Deploy code: git push azure main"
echo "3. Access your app: https://$APP_NAME.azurewebsites.net"
echo "4. Configure your custom domain and SSL certificate"
echo "5. Set up Google OAuth credentials"
echo
echo -e "${BLUE}Important URLs:${NC}"
echo "App URL: https://$APP_NAME.azurewebsites.net"
echo "Admin URL: https://$APP_NAME.azurewebsites.net/admin"
echo "API URL: https://$APP_NAME.azurewebsites.net/api"
echo
echo -e "${YELLOW}⚠️ Don't forget to:${NC}"
echo "- Update your frontend app to use the new API URL"
echo "- Configure Google OAuth for your domain"
echo "- Set up monitoring and alerts"
echo "- Review the security checklist"
echo
echo -e "${GREEN}🇮🇳 Your AarogyaRekha backend is ready for India!${NC}"
