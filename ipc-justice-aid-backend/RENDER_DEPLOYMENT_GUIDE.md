# 🚀 Render Deployment Guide for IPC Justice Aid Backend

This guide will help you deploy your IPC Justice Aid backend to Render using Hugging Face models for AI processing instead of Ollama.

## 📋 Prerequisites

1. **Render Account**: Sign up at [render.com](https://render.com)
2. **Hugging Face Account**: Sign up at [huggingface.co](https://huggingface.co)
3. **GitHub Repository**: Your code should be in a GitHub repository
4. **API Keys**: Gather all required API keys (see below)

## 🔑 Required API Keys

Before deployment, gather these API keys:

### 1. Hugging Face API Token (REQUIRED)
1. Go to [Hugging Face Settings](https://huggingface.co/settings/tokens)
2. Create a new token with "Read" access
3. Copy the token (starts with `hf_...`)

### 2. Optional API Keys
- **Google OAuth**: For Google login (optional)
- **Razorpay/Stripe**: For payment processing (optional)
- **Email SMTP**: For sending emails (optional)

## 🚀 Deployment Steps

### Step 1: Fork or Clone Repository
1. Fork this repository to your GitHub account
2. Clone it locally if you need to make changes

### Step 2: Update Frontend URL (if applicable)
1. In `.env.render`, update `FRONTEND_URL` with your frontend deployment URL
2. If deploying frontend separately, get that URL first

### Step 3: Deploy to Render

#### Option A: Using render.yaml (Recommended)
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New" → "Blueprint"
3. Connect your GitHub repository
4. Render will automatically detect the `render.yaml` file
5. Review the services that will be created:
   - Web Service (Backend API)
   - PostgreSQL Database
   - Redis Cache

#### Option B: Manual Deployment
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Create services manually (see manual setup section below)

### Step 4: Configure Environment Variables
In Render dashboard, set these environment variables:

#### Required Variables:
```bash
# Hugging Face Configuration (REQUIRED)
HUGGINGFACE_API_TOKEN=hf_your_token_here

# Analysis Configuration
ANALYSIS_ENVIRONMENT=huggingface

# Database and Redis (Auto-configured if using render.yaml)
DATABASE_URL=postgresql://...  # Auto-set by Render
REDIS_URL=redis://...         # Auto-set by Render
```

#### Optional Variables:
```bash
# Email Configuration
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Google OAuth
GOOGLE_OAUTH_CLIENT_ID=your-google-client-id
GOOGLE_OAUTH_CLIENT_SECRET=your-google-client-secret

# Payment Gateways
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-key-secret
STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key
STRIPE_SECRET_KEY=your-stripe-secret-key

# Frontend URL (Update with your actual frontend URL)
FRONTEND_URL=https://your-frontend-app.onrender.com
```

### Step 5: Deploy and Test
1. Click "Deploy" to start the deployment
2. Wait for build to complete (5-10 minutes)
3. Test the health endpoint: `https://your-app.onrender.com/legal/health/`
4. Test the analysis endpoint with a sample case

## 🔧 Manual Setup (Alternative to render.yaml)

If you prefer manual setup:

### 1. Create PostgreSQL Database
- Service Type: PostgreSQL
- Name: `ipc-justice-aid-db`
- Plan: Starter (Free)

### 2. Create Redis Instance
- Service Type: Redis
- Name: `ipc-justice-aid-redis`
- Plan: Starter (Free)

### 3. Create Web Service
- Service Type: Web Service
- Name: `ipc-justice-aid-backend`
- Runtime: Python 3
- Build Command: `./render-build.sh`
- Start Command: `gunicorn ipc_justice_aid_backend.wsgi:application --bind 0.0.0.0:$PORT --workers 4 --timeout 300`
- Plan: Starter (Free)

## 🔍 Health Check and Testing

### Health Check Endpoint
```
GET https://your-app.onrender.com/legal/health/
```

Expected response:
```json
{
  "status": "healthy",
  "service": "IPC Justice Aid Backend",
  "analysis_service": "huggingface",
  "database": "connected",
  "redis": "connected"
}
```

### Test Analysis Endpoint
```bash
curl -X POST https://your-app.onrender.com/leads/analyze-case/ \
  -H "Content-Type: application/json" \
  -d '{
    "case_description": "A person threatened to kill someone with a knife",
    "incident_date": "2024-01-15",
    "incident_location": "Mumbai, Maharashtra"
  }'
```

## 🌟 Key Differences from Local Development

### 1. AI Model Service
- **Local**: Uses Ollama with custom IPC-Helper model
- **Production**: Uses Hugging Face Inference API with Mistral model

### 2. Database
- **Local**: Local PostgreSQL
- **Production**: Render PostgreSQL (managed)

### 3. Cache
- **Local**: Local Redis
- **Production**: Render Redis (managed)

### 4. Static Files
- **Local**: Served by Django
- **Production**: Served by WhiteNoise middleware

## 🔧 Configuration Details

### Analysis Environment
The system automatically detects the environment:
- `ANALYSIS_ENVIRONMENT=auto`: Auto-detects (Ollama for dev, HuggingFace for prod)
- `ANALYSIS_ENVIRONMENT=huggingface`: Forces Hugging Face (recommended for production)
- `ANALYSIS_ENVIRONMENT=ollama`: Forces Ollama (local development only)

### Hugging Face Models
Default model: `mistralai/Mistral-7B-Instruct-v0.1`

Alternative models you can use:
- `microsoft/DialoGPT-medium`: Conversational AI
- `google/flan-t5-large`: Good for structured tasks
- `nlpaueb/legal-bert-base-uncased`: Legal domain specific

To change model, update `HUGGINGFACE_MODEL_ID` environment variable.

## 🐛 Troubleshooting

### Common Issues:

#### 1. Build Fails
- Check `render-build.sh` has execute permissions
- Verify all dependencies in `requirements.txt`
- Check Python version compatibility

#### 2. Health Check Fails
- Verify environment variables are set correctly
- Check database connection
- Verify Hugging Face API token

#### 3. Analysis Not Working
- Verify `HUGGINGFACE_API_TOKEN` is set and valid
- Check `ANALYSIS_ENVIRONMENT=huggingface`
- Test Hugging Face API directly

#### 4. Static Files Not Loading
- Ensure `python manage.py collectstatic` runs in build
- Check WhiteNoise configuration in settings

### Debug Commands
```bash
# Check environment
curl https://your-app.onrender.com/legal/health/

# Check logs in Render dashboard
# Go to your service → Logs tab

# Check database connection
python manage.py dbshell

# Test Hugging Face connection
python manage.py shell
>>> from ipc_analysis.huggingface_service import HuggingFaceService
>>> service = HuggingFaceService()
>>> service.health_check()
```

## 🔄 Updating Deployment

### Via Git Push
1. Push changes to your GitHub repository
2. Render will automatically redeploy

### Environment Variables
1. Go to Render Dashboard
2. Select your service
3. Go to Environment tab
4. Update variables and save

## 💰 Cost Considerations

### Render Costs (Free Tier)
- Web Service: Free for 750 hours/month
- PostgreSQL: Free for starter plan
- Redis: Free for starter plan

### Hugging Face Costs
- Inference API: Free tier available
- Rate limits apply to free tier
- Consider upgrading for production use

## 🔐 Security Best Practices

1. **Never commit API keys** to your repository
2. **Use strong SECRET_KEY** (auto-generated by Render)
3. **Enable HTTPS** (auto-enabled by Render)
4. **Regular token rotation** for API keys
5. **Monitor usage** for unusual activity

## 📊 Monitoring and Scaling

### Monitoring
- Use Render dashboard for basic metrics
- Check logs regularly for errors
- Monitor Hugging Face API usage

### Scaling
- Upgrade Render plan for more resources
- Increase worker count in start command
- Consider upgrading database plan

## 🎯 Next Steps

1. **Frontend Deployment**: Deploy your frontend (Flutter/Next.js) separately
2. **Custom Domain**: Configure custom domain in Render
3. **SSL Certificate**: Configure custom SSL if using custom domain
4. **Monitoring**: Set up monitoring and alerting
5. **Backup**: Configure database backups

## 🆘 Support

If you encounter issues:

1. Check Render documentation: [render.com/docs](https://render.com/docs)
2. Check Hugging Face documentation: [huggingface.co/docs](https://huggingface.co/docs)
3. Review application logs in Render dashboard
4. Check this repository's issues section

## 📝 Environment Variable Reference

Copy this template to set up your environment variables in Render:

```bash
# Required
SECRET_KEY=auto-generated-by-render
DEBUG=False
ALLOWED_HOSTS=*
ANALYSIS_ENVIRONMENT=huggingface
HUGGINGFACE_API_TOKEN=hf_your_token_here
DATABASE_URL=auto-set-by-render
REDIS_URL=auto-set-by-render

# Optional but recommended
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
FRONTEND_URL=https://your-frontend.onrender.com

# Optional - Authentication
GOOGLE_OAUTH_CLIENT_ID=your-client-id
GOOGLE_OAUTH_CLIENT_SECRET=your-client-secret

# Optional - Payments
RAZORPAY_KEY_ID=your-key-id
RAZORPAY_KEY_SECRET=your-secret
STRIPE_PUBLISHABLE_KEY=your-publishable-key
STRIPE_SECRET_KEY=your-secret-key
```

---

## ✅ Deployment Checklist

- [ ] Hugging Face account created and API token obtained
- [ ] GitHub repository prepared with latest code
- [ ] render.yaml file configured
- [ ] Environment variables prepared
- [ ] Render account set up
- [ ] Services deployed via Blueprint
- [ ] Environment variables configured in Render
- [ ] Health check endpoint tested
- [ ] Analysis endpoint tested
- [ ] Frontend URL updated (if applicable)
- [ ] Custom domain configured (if needed)

Happy deploying! 🚀
