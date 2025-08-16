# Railway Production Deployment Checklist

## ✅ Pre-Deployment Verification

### 1. Code & Configuration
- [x] `railway_settings.py` configured with all production settings
- [x] `railway.json` deployment configuration created
- [x] `nixpacks.toml` build configuration created
- [x] `railway-startup.sh` startup script created
- [x] All Django checks passing (`python manage.py check`)

### 2. Environment Variables Ready
- [x] `RAILWAY_ENV_COMPLETE.txt` contains all required variables
- [x] Secret key is production-ready (50+ characters)
- [x] Database URL is correct
- [x] Google OAuth credentials are valid

## 🚀 Deployment Steps

### Step 1: Railway Project Setup
1. Create new Railway project
2. Connect your GitHub repository
3. Add PostgreSQL service to your project
4. Note the PostgreSQL connection URL

### Step 2: Environment Variables Configuration
Copy all variables from `RAILWAY_ENV_COMPLETE.txt` and set them in Railway:

#### Critical Variables (MUST UPDATE):
```bash
SECRET_KEY=<generate-new-50-char-secret>
DATABASE_URL=<your-railway-postgresql-url>
CORS_ALLOWED_ORIGINS=<your-frontend-urls>
CSRF_TRUSTED_ORIGINS=<your-frontend-urls>
FRONTEND_URL=<your-frontend-url>
```

#### Auto-Provided by Railway:
```bash
RAILWAY_PUBLIC_DOMAIN=<auto-provided>
```

### Step 3: Deploy
1. Push your code to GitHub
2. Railway will automatically detect and deploy
3. Monitor build logs for any issues

### Step 4: Post-Deployment Verification
1. Check health endpoint: `https://your-app.railway.app/api/v1/health/`
2. Test Google OAuth login
3. Test legal analysis functionality
4. Verify static files are serving correctly

## 🔧 Troubleshooting

### Build Issues
- Check nixpacks.toml for package compatibility
- Review Railway build logs
- Ensure all Python dependencies are in requirements.txt

### Runtime Issues
- Check environment variables are set correctly
- Verify database connection string
- Review application logs in Railway dashboard

### Authentication Issues
- Verify Google OAuth redirect URLs include Railway domain
- Check CORS and CSRF settings
- Ensure HTTPS is properly configured

## 🛡️ Security Verification

### Production Security Checklist
- [x] DEBUG=False
- [x] SECRET_KEY is production-ready
- [x] SECURE_SSL_REDIRECT=True
- [x] Session and CSRF cookies are secure
- [x] CORS origins are restrictive
- [x] Database uses secure connection

## 📊 Monitoring

### Health Check Endpoints
- `/api/v1/health/` - Application health
- `/admin/` - Django admin (for superuser)
- `/api/v1/analysis/health/` - Analysis service health

### Key Metrics to Monitor
- Response times
- Error rates
- Database connection health
- Memory usage
- CPU usage

## 🔄 Maintenance

### Regular Tasks
- Monitor logs for errors
- Update dependencies regularly
- Backup database regularly
- Review security settings

### Environment Updates
When updating environment variables:
1. Update in Railway dashboard
2. Restart application if needed
3. Verify changes with health check

## 📞 Support Resources

### Railway Documentation
- Railway Docs: https://docs.railway.app/
- Railway Discord: https://discord.gg/railway

### Application Logs
Access logs through Railway dashboard or CLI:
```bash
railway logs
```

### Database Access
Connect to PostgreSQL through Railway dashboard or CLI:
```bash
railway shell
```

---

## 🎯 Success Criteria

✅ **Deployment is successful when:**
1. Health endpoint returns 200 OK
2. Google OAuth login works
3. Legal analysis API responds correctly
4. Static files serve without errors
5. No critical errors in logs

**Your IPC Justice Aid backend is now production-ready! 🚀**
