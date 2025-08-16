# Heroku Deployment Guide for IPC Justice Aid Backend

This guide explains how to deploy the IPC Justice Aid Backend to Heroku using Hugging Face models instead of Ollama.

## Prerequisites

1. **Heroku Account**: Create a free account at [heroku.com](https://heroku.com)
2. **Heroku CLI**: Install from [devcenter.heroku.com/articles/heroku-cli](https://devcenter.heroku.com/articles/heroku-cli)
3. **Hugging Face Account**: Create a free account at [huggingface.co](https://huggingface.co)
4. **Git**: Ensure your project is in a Git repository

## Step 1: Get Hugging Face API Token

1. Go to [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
2. Click "New token"
3. Give it a name like "IPC-Justice-Aid-Production"
4. Select "Read" role (sufficient for inference API)
5. Copy the token (you'll need it later)

## Step 2: Prepare Your Application

1. **Install Heroku CLI and login:**
   ```bash
   heroku login
   ```

2. **Create a Heroku app:**
   ```bash
   heroku create your-app-name-here
   ```

3. **Add Heroku Postgres (free tier):**
   ```bash
   heroku addons:create heroku-postgresql:essential-0
   ```

4. **Add Heroku Redis (free tier):**
   ```bash
   heroku addons:create heroku-redis:mini
   ```

## Step 3: Configure Environment Variables

Set the required environment variables in Heroku:

```bash
# Basic Django settings
heroku config:set SECRET_KEY="your-production-secret-key-here"
heroku config:set DEBUG=False
heroku config:set ALLOWED_HOSTS="your-app-name.herokuapp.com"

# NOTE: DATABASE_URL and REDIS_URL are automatically set by Heroku addons
# No need to set database variables manually!

# Analysis service configuration (use Hugging Face for production)
heroku config:set ANALYSIS_ENVIRONMENT=huggingface

# Hugging Face configuration (REQUIRED)
heroku config:set HUGGINGFACE_API_TOKEN="your-hf-token-here"
heroku config:set HUGGINGFACE_MODEL_ID="mistralai/Mistral-7B-Instruct-v0.1"
heroku config:set HUGGINGFACE_TIMEOUT=60
heroku config:set HUGGINGFACE_MAX_RETRIES=3

# Legal analysis settings
heroku config:set MAX_CASE_DESCRIPTION_LENGTH=5000
heroku config:set ANALYSIS_HISTORY_RETENTION_DAYS=365

# Google OAuth (if you're using it)
heroku config:set GOOGLE_OAUTH_CLIENT_ID="your-google-client-id"
heroku config:set GOOGLE_OAUTH_CLIENT_SECRET="your-google-client-secret"

# Email settings (if needed)
heroku config:set EMAIL_HOST="smtp.gmail.com"
heroku config:set EMAIL_PORT=587
heroku config:set EMAIL_USE_TLS=True
heroku config:set EMAIL_HOST_USER="your-email@gmail.com"
heroku config:set EMAIL_HOST_PASSWORD="your-app-password"

# Frontend URL (update with your frontend URL)
heroku config:set FRONTEND_URL="https://your-frontend-domain.com"

# CORS settings (update with your frontend domain)
heroku config:set CORS_ALLOWED_ORIGINS="https://your-frontend-domain.com,https://your-app-name.herokuapp.com"
```

## Step 4: Create Required Files

1. **Create `Procfile` in your project root:**
   ```
   web: gunicorn ipc_justice_aid_backend.wsgi:application --bind 0.0.0.0:$PORT
   worker: celery -A ipc_justice_aid_backend worker --loglevel=info
   beat: celery -A ipc_justice_aid_backend beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler
   ```

2. **Create `runtime.txt` (optional, to specify Python version):**
   ```
   python-3.11.5
   ```

## Step 5: Deploy to Heroku

1. **Add and commit your changes:**
   ```bash
   git add .
   git commit -m "Add Heroku deployment configuration"
   ```

2. **Push to Heroku:**
   ```bash
   git push heroku main
   ```

3. **Run database migrations:**
   ```bash
   heroku run python manage.py migrate
   ```

4. **Create a superuser (optional):**
   ```bash
   heroku run python manage.py createsuperuser
   ```

5. **Scale your dynos:**
   ```bash
   # Web dyno (included in free tier)
   heroku ps:scale web=1
   
   # Worker dyno (optional, for background tasks)
   heroku ps:scale worker=1
   
   # Beat dyno (optional, for scheduled tasks)
   heroku ps:scale beat=1
   ```

## Step 6: Test Your Deployment

1. **Check if your app is running:**
   ```bash
   heroku open
   ```

2. **Test the analysis service:**
   ```bash
   curl -X POST https://your-app-name.herokuapp.com/api/ipc-analysis/health-check/ \
        -H "Content-Type: application/json"
   ```

3. **View logs:**
   ```bash
   heroku logs --tail
   ```

## Step 7: Domain Configuration (Optional)

If you have a custom domain:

```bash
heroku domains:add your-domain.com
heroku config:set ALLOWED_HOSTS="your-domain.com,your-app-name.herokuapp.com"
```

## Troubleshooting

### Common Issues:

1. **Model Loading Timeout:**
   - Hugging Face models may take time to load initially
   - Increase `HUGGINGFACE_TIMEOUT` if needed
   - The first request might be slower (cold start)

2. **Memory Issues:**
   - Heroku free tier has 512MB RAM limit
   - Consider upgrading to a paid dyno if needed
   - Monitor memory usage: `heroku logs --dyno web`

3. **Database Connection:**
   - Ensure `DATABASE_URL` is set (automatic with Heroku Postgres)
   - Check database connection: `heroku pg:info`

4. **Redis Connection:**
   - Ensure `REDIS_URL` is set (automatic with Heroku Redis)
   - Check Redis connection: `heroku redis:info`

### Useful Commands:

```bash
# View environment variables
heroku config

# Access Django shell
heroku run python manage.py shell

# View database info
heroku pg:info

# View Redis info
heroku redis:info

# Restart the app
heroku restart

# View app information
heroku apps:info
```

## Alternative Models

If `mistralai/Mistral-7B-Instruct-v0.1` doesn't work well, try these alternatives:

1. **google/flan-t5-large** - Good for structured tasks
2. **microsoft/DialoGPT-medium** - Smaller, faster
3. **nlpaueb/legal-bert-base-uncased** - Legal domain specific

Update the model:
```bash
heroku config:set HUGGINGFACE_MODEL_ID="google/flan-t5-large"
```

## Cost Optimization

1. **Hugging Face API**: Free tier includes 30,000 requests/month
2. **Heroku Free Tier**: 550-1000 dyno hours/month
3. **Postgres**: 10,000 rows limit on free tier
4. **Redis**: 30MB limit on free tier

## Security Notes

1. Keep your Hugging Face API token secure
2. Use environment variables for all secrets
3. Enable SSL in production
4. Consider using Heroku's OAuth addon for authentication

## Success!

Your IPC Justice Aid backend should now be running on Heroku with Hugging Face models for legal analysis!

Visit your app at: `https://your-app-name.herokuapp.com`
