# 🔒 SECURE RENDER DEPLOYMENT GUIDE

## Environment Variables to Set in Render Dashboard

**⚠️ CRITICAL: Never commit database credentials to GitHub!**

### 🎯 Required Variables (Set these manually in Render dashboard):

```
DATABASE_URL = [Copy from .env file - RENDER_DATABASE_URL value]
GEMINI_API_KEY = [Copy from .env file - RENDER_GEMINI_API_KEY value]
```

### 📋 Optional Variables (if you want email/payments):

```
EMAIL_HOST_USER = [Copy from .env file - RENDER_EMAIL_HOST_USER value]
EMAIL_HOST_PASSWORD = [Copy from .env file - RENDER_EMAIL_HOST_PASSWORD value]
GOOGLE_OAUTH_CLIENT_ID = [Copy from .env file - RENDER_GOOGLE_OAUTH_CLIENT_ID value]
GOOGLE_OAUTH_CLIENT_SECRET = [Copy from .env file - RENDER_GOOGLE_OAUTH_CLIENT_SECRET value]
RAZORPAY_KEY_ID = [Your Razorpay key if using payments]
RAZORPAY_KEY_SECRET = [Your Razorpay secret if using payments]
STRIPE_PUBLISHABLE_KEY = [Your Stripe key if using payments]
STRIPE_SECRET_KEY = [Your Stripe secret if using payments]
```

## 🛡️ Security Best Practices:

1. **Never commit credentials to Git**
2. **Use environment variables for all secrets**
3. **Rotate API keys regularly**
4. **Use different credentials for dev/staging/production**

## 📝 Steps to Deploy:

1. Push code to GitHub (credentials are NOT in render.yaml)
2. Create new web service in Render
3. Connect to your GitHub repo
4. Set environment variables manually in dashboard
5. Deploy!

## 🔗 Render Dashboard Steps:

1. Go to your service → Environment tab
2. Add each variable one by one
3. Copy values from your local .env file
4. Click "Deploy Latest Commit"
