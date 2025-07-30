# AarogyaRekha Django Backend - Azure Deployment Guide (India)

This guide will help you deploy the AarogyaRekha Django backend to Microsoft Azure App Service with India-specific configurations for optimal performance and data residency compliance.

## Prerequisites

1. **Azure Account**: You need an active Azure subscription
2. **Azure CLI**: Install the Azure CLI on your local machine
3. **Git**: For deployment from repository
4. **Note**: This deployment uses Azure India regions for data residency and better performance for Indian users

## Step 1: Create Azure Resources

### 1.1 Create Resource Group

```bash
# Using Central India region for better performance and data residency
az group create --name aarogyarekha-rg --location "Central India"
```

### 1.2 Create PostgreSQL Database

```bash
# Create PostgreSQL server in Central India
az postgres server create \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-db-server \
  --location "Central India" \
  --admin-user aarogyarekha_admin \
  --admin-password YOUR_SECURE_PASSWORD \
  --sku-name GP_Gen5_2 \
  --version 13 \
  --storage-size 102400 \
  --backup-retention-days 7

# Create database
az postgres db create \
  --resource-group aarogyarekha-rg \
  --server-name aarogyarekha-db-server \
  --name aarogyarekha_db

# Configure firewall (allow Azure services)
az postgres server firewall-rule create \
  --resource-group aarogyarekha-rg \
  --server aarogyarekha-db-server \
  --name AllowAllAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Add India-specific IP ranges for mobile networks (Optional)
az postgres server firewall-rule create \
  --resource-group aarogyarekha-rg \
  --server aarogyarekha-db-server \
  --name AllowIndianMobileNetworks \
  --start-ip-address 49.0.0.0 \
  --end-ip-address 49.255.255.255
```

### 1.3 Create Redis Cache (Optional but recommended)

```bash
# Create Redis cache in Central India
az redis create \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-redis \
  --location "Central India" \
  --sku Basic \
  --vm-size c0
```

### 1.4 Create Storage Account (Optional for static/media files)

```bash
# Create storage account in Central India
az storage account create \
  --resource-group aarogyarekha-rg \
  --name aarogyarekhasto \
  --location "Central India" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot

# Create containers for static and media files
az storage container create --name static --account-name aarogyarekhasto --public-access blob
az storage container create --name media --account-name aarogyarekhasto --public-access blob
```

### 1.5 Create App Service Plan

```bash
# Create App Service Plan in Central India
az appservice plan create \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-plan \
  --location "Central India" \
  --sku B1 \
  --is-linux
```

### 1.6 Create Web App

```bash
# Create Web App with India-friendly naming
az webapp create \
  --resource-group aarogyarekha-rg \
  --plan aarogyarekha-plan \
  --name aarogyarekha-api-india \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```

## Step 2: Configure Application Settings

Set the following environment variables in Azure Portal or using CLI:

```bash
# Core Django Settings for India deployment
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    DEBUG=False \
    SECRET_KEY="your-super-secret-production-key-here" \
    AZURE_APP_SERVICE=True \
    AZURE_DOMAIN="aarogyarekha-api-india" \
    ALLOWED_HOSTS="aarogyarekha-api-india.azurewebsites.net,yourdomain.com,yourdomain.in"

# Database Settings for India region
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    DATABASE_NAME="aarogyarekha_db" \
    DATABASE_USER="aarogyarekha_admin" \
    DATABASE_PASSWORD="YOUR_SECURE_PASSWORD" \
    DATABASE_HOST="aarogyarekha-db-server.postgres.database.azure.com" \
    DATABASE_PORT="5432" \
    DATABASE_SSL_MODE="require"

# CORS and CSRF Settings for Indian domains
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    CORS_ALLOWED_ORIGINS="https://yourdomain.com,https://yourdomain.in,https://aarogyarekha-api-india.azurewebsites.net" \
    CSRF_TRUSTED_ORIGINS="https://yourdomain.com,https://yourdomain.in,https://aarogyarekha-api-india.azurewebsites.net"

# Redis Settings for India region
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    REDIS_URL="rediss://aarogyarekha-redis.redis.cache.windows.net:6380/0"

# Azure Storage Settings for India region
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    USE_AZURE_STORAGE=True \
    AZURE_ACCOUNT_NAME="aarogyarekhasto" \
    AZURE_ACCOUNT_KEY="your-storage-account-key" \
    AZURE_CONTAINER="media" \
    AZURE_STATIC_CONTAINER="static"

# Google OAuth Settings for India
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    GOOGLE_OAUTH2_CLIENT_ID="your-google-client-id" \
    GOOGLE_OAUTH2_CLIENT_SECRET="your-google-client-secret"

# India-specific settings
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings \
    TIME_ZONE="Asia/Kolkata" \
    LANGUAGE_CODE="en-in" \
    USE_I18N=True \
    USE_TZ=True
```

## Step 3: Configure Deployment

### 3.1 Set startup command
```bash
az webapp config set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --startup-file "startup.sh"
```

### 3.2 Configure Git deployment

```bash
# Get deployment URL for India deployment
az webapp deployment source config-local-git \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india
```

## Step 4: Deploy Your Code

### 4.1 Add Azure remote

```bash
# From your local repository
git remote add azure https://username@aarogyarekha-api-india.scm.azurewebsites.net/aarogyarekha-api-india.git
```

### 4.2 Deploy

```bash
# Make sure you're in the backend directory
cd aarogyarekha-backend

# Deploy to Azure India
git add .
git commit -m "Deploy to Azure India"
git push azure main
```

## Step 5: Post-Deployment Setup

### 5.1 Run Database Migrations
The startup script should handle this automatically, but you can also run them manually:

```bash
# SSH into the App Service (if needed)
az webapp ssh --resource-group aarogyarekha-rg --name aarogyarekha-api-india

# Inside the container
python manage.py migrate
python manage.py collectstatic --noinput
```

### 5.2 Create Superuser (Optional)

If you set `DJANGO_SUPERUSER_EMAIL` and `DJANGO_SUPERUSER_PASSWORD` in application settings, a superuser will be created automatically.

## Step 6: Testing

1. **Test API Endpoints**: Visit `https://aarogyarekha-api-india.azurewebsites.net/api/`
2. **Test Admin**: Visit `https://aarogyarekha-api-india.azurewebsites.net/admin/`
3. **Check Logs**: Use Azure Portal or CLI to check application logs

```bash
az webapp log tail --resource-group aarogyarekha-rg --name aarogyarekha-api-india
```

## Step 7: Custom Domain (Optional)

### 7.1 Add Custom Domain

```bash
# Add your .in domain for India-specific branding
az webapp config hostname add \
  --resource-group aarogyarekha-rg \
  --webapp-name aarogyarekha-api-india \
  --hostname api.yourdomain.in
```

### 7.2 Configure SSL

```bash
az webapp config ssl bind \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --certificate-thumbprint YOUR_CERT_THUMBPRINT \
  --ssl-type SNI
```

## Monitoring and Logging

### Application Insights

```bash
# Create Application Insights in Central India
az monitor app-insights component create \
  --resource-group aarogyarekha-rg \
  --app aarogyarekha-insights \
  --location "Central India" \
  --application-type web

# Link to Web App
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api-india \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY="your-instrumentation-key"
```

## Scaling

### Scale up (Vertical)
```bash
az appservice plan update \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-plan \
  --sku S1
```

### Scale out (Horizontal)
```bash
az webapp config appsettings set \
  --resource-group aarogyarekha-rg \
  --name aarogyarekha-api \
  --settings WEBSITES_CONTAINER_START_TIME_LIMIT=1800

az monitor autoscale create \
  --resource-group aarogyarekha-rg \
  --resource aarogyarekha-api \
  --resource-type Microsoft.Web/sites \
  --name aarogyarekha-autoscale \
  --min-count 1 \
  --max-count 5 \
  --count 2
```

## Troubleshooting

1. **Check Logs**: Use `az webapp log tail` or Azure Portal
2. **Verify Environment Variables**: Check in Azure Portal > App Service > Configuration
3. **Database Connection**: Ensure firewall rules allow Azure services
4. **Static Files**: Verify STATIC_ROOT and WhiteNoise configuration
5. **SSL Issues**: Check certificate configuration and HTTPS redirects

## Security Checklist

- [ ] Set strong SECRET_KEY
- [ ] Enable HTTPS-only traffic
- [ ] Configure proper CORS origins
- [ ] Set up database firewall rules
- [ ] Enable Application Insights monitoring
- [ ] Configure backup policies
- [ ] Set up alerts for errors and performance

## Cost Optimization

1. **Use appropriate pricing tiers** for your traffic
2. **Enable auto-scaling** to handle traffic spikes
3. **Monitor usage** with Azure Cost Management
4. **Use Azure Redis** instead of premium cache
5. **Optimize database** size based on usage

Your Django backend should now be successfully deployed to Azure App Service!

## Next Steps

1. Update your Flutter app to use the new Azure API endpoint
2. Set up CI/CD pipeline with GitHub Actions or Azure DevOps
3. Configure monitoring and alerting
4. Set up backup and disaster recovery
5. Implement proper logging and error tracking
