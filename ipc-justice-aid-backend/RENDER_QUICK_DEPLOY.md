# 🚀 Quick Deployment Guide: IPC Justice Aid Backend on Render

## 📦 What's Been Prepared

I've set up your backend for production deployment on Render with Google Gemini integration. Here's what's been configured:

### ✅ Files Created/Modified:

1. **`render.yaml`** - Blueprint for automatic deployment
2. **`render-build.sh`** - Optimized build script for Render
3. **`requirements.render.txt`** - Production-optimized dependencies
4. **`.env.render`** - Template for environment variables
5. **`RENDER_ENVIRONMENT_GUIDE.md`** - Comprehensive environment variable guide
6. **`health_check_render.py`** - Health check script
7. **`test_gemini_integration.py`** - Gemini integration test
8. **Updated `settings.py`** - Added Render-specific configurations

## 🎯 Key Configuration Changes

### 1. Analysis Service
- **Local Development**: Uses Ollama with your custom IPC-Helper model
- **Production (Render)**: Uses Google Gemini API
- **Auto-Detection**: System automatically chooses the right service based on environment

### 2. Environment Detection
The system automatically detects Render environment and:
- Forces `ANALYSIS_ENVIRONMENT=auto` (detects Gemini for production)
- Configures proper SSL settings
- Sets up CORS for your frontend at `https://juris-lead.vercel.app`

### 3. Dependencies
Created optimized `requirements.render.txt` that excludes:
- Ollama-specific packages
- Heavy local development tools
- Unnecessary dependencies for production

## 🚀 Deployment Steps

### 1. Get Google Gemini API Key (REQUIRED)
```bash
# Go to: https://aistudio.google.com/app/apikey
# Create a new API key
# Copy the API key (starts with "AIzaSy...")
```

### 2. Deploy to Render
```bash
# Option A: Use render.yaml (Recommended)
# 1. Go to https://dashboard.render.com
# 2. Click "New" → "Blueprint"
# 3. Connect your GitHub repository
# 4. Render will detect render.yaml and create all services

# Option B: Manual deployment (see full guide)
```

### 3. Set Environment Variables in Render
```bash
# Required
GEMINI_API_KEY=[Copy from your .env file: RENDER_GEMINI_API_KEY]

# Optional (configure as needed)
EMAIL_HOST_USER=[Copy from your .env file: RENDER_EMAIL_HOST_USER]
EMAIL_HOST_PASSWORD=[Copy from your .env file: RENDER_EMAIL_HOST_PASSWORD]
GOOGLE_OAUTH_CLIENT_ID=[Copy from your .env file: RENDER_GOOGLE_OAUTH_CLIENT_ID]
GOOGLE_OAUTH_CLIENT_SECRET=[Copy from your .env file: RENDER_GOOGLE_OAUTH_CLIENT_SECRET]
```

**💡 Tip: All actual values are in your `.env` file with `RENDER_` prefix for easy copying!**

## 🧪 Testing Your Deployment

### 1. Health Check
```bash
curl https://your-app.onrender.com/legal/health/
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

### 2. Test Analysis
```bash
curl -X POST https://your-app.onrender.com/leads/analyze-case/ \
  -H "Content-Type: application/json" \
  -d '{
    "case_description": "A person threatened to kill someone with a knife",
    "incident_date": "2024-01-15",
    "incident_location": "Mumbai, Maharashtra"
  }'
```

### 3. Run Health Check Script (locally)
```bash
cd ipc-justice-aid-backend
python health_check_render.py https://your-app.onrender.com
```

## 🔧 Local Testing with Hugging Face

Before deploying, test Hugging Face integration locally:

```bash
# 1. Set environment variables
export HUGGINGFACE_API_TOKEN=hf_your_token_here
export ANALYSIS_ENVIRONMENT=huggingface

# 2. Run test script
cd ipc-justice-aid-backend
python test_huggingface.py
```

## 💡 Key Benefits of This Setup

### ✅ Cost Effective
- **Render**: Free tier for 750 hours/month
- **Hugging Face**: Free tier with rate limits
- **No Ollama hosting costs**

### ✅ Production Ready
- **Auto-scaling**: Render handles traffic spikes
- **SSL/HTTPS**: Automatic SSL certificates
- **Database**: Managed PostgreSQL
- **Cache**: Managed Redis

### ✅ Easy Maintenance
- **Git-based deployment**: Push to deploy
- **Environment variables**: Easy configuration updates
- **Health monitoring**: Built-in health checks
- **Logs**: Centralized logging in Render dashboard

## 🔄 Development vs Production

| Feature | Local Development | Production (Render) |
|---------|-------------------|-------------------|
| AI Service | Ollama (Custom Model) | Hugging Face API |
| Database | Local PostgreSQL | Render PostgreSQL |
| Cache | Local Redis | Render Redis |
| Static Files | Django Dev Server | WhiteNoise |
| HTTPS | HTTP (localhost) | HTTPS (automatic) |
| Scaling | Single instance | Auto-scaling |

## 🎯 Next Steps

1. **Deploy Backend**: Follow the steps above
2. **Update Frontend**: Update frontend API URLs to point to your Render deployment
3. **Custom Domain**: Configure custom domain in Render (optional)
4. **Monitoring**: Set up monitoring and alerts
5. **Performance**: Monitor response times and optimize as needed

## 🆘 Troubleshooting Quick Fixes

### Build Fails
```bash
# Check build logs in Render dashboard
# Common issues:
# - Missing dependencies
# - Environment variables not set
# - Build script permissions
```

### Analysis Not Working
```bash
# Check these in order:
# 1. HUGGINGFACE_API_TOKEN is set and valid
# 2. ANALYSIS_ENVIRONMENT=huggingface
# 3. Model is accessible (check health endpoint)
```

### Database Connection Issues
```bash
# Usually auto-resolved by Render
# Check DATABASE_URL is set correctly
# Verify PostgreSQL service is running
```

## 📊 Expected Performance

### Response Times (Hugging Face)
- **Health Check**: ~100ms
- **Case Analysis**: ~5-15 seconds (depending on model loading)
- **Model Loading**: Initial requests may take 20-30 seconds

### Rate Limits (Free Tier)
- **Hugging Face**: ~1000 requests/month (free tier)
- **Render**: 750 hours/month (free tier)

## 🔐 Security Notes

- ✅ All API keys stored as environment variables
- ✅ HTTPS enforced in production
- ✅ CORS properly configured
- ✅ Debug mode disabled in production
- ✅ Database credentials managed by Render

## 📞 Support

- **Render Docs**: https://render.com/docs
- **Hugging Face Docs**: https://huggingface.co/docs
- **Django Deployment**: https://docs.djangoproject.com/en/4.2/howto/deployment/

---

## ✅ Deployment Checklist

- [ ] Hugging Face API token obtained
- [ ] render.yaml reviewed and customized
- [ ] Environment variables prepared
- [ ] GitHub repository updated with latest changes
- [ ] Render Blueprint deployed
- [ ] Environment variables set in Render dashboard
- [ ] Health check endpoint tested
- [ ] Analysis endpoint tested
- [ ] Frontend API URLs updated

**Ready to deploy! 🚀**

The configuration prioritizes:
1. **Simplicity**: Easy one-click deployment
2. **Reliability**: Production-ready setup
3. **Cost-effectiveness**: Uses free tiers effectively
4. **Maintainability**: Git-based workflow

Your backend will automatically use Hugging Face in production while keeping Ollama for local development.
