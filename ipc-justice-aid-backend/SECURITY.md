# 🔐 SECURITY NOTICE

**IMPORTANT: This repository does NOT contain any real secrets or credentials.**

## What's Safe to Commit

✅ **Template files with placeholder values:**
- `.env.production` - Contains placeholder values like "your-secret-key-here"
- `deploy-to-azure-india.sh` - Prompts user for secrets, doesn't contain them
- `azure-config.txt` - Template with placeholder values
- Documentation files with example configurations

## What's Protected by .gitignore

🚫 **Files that should NEVER be committed:**
- `.env` - Real environment variables
- `.env.local` - Local development secrets
- `secrets.json` - Any secrets file
- `azure-credentials.json` - Azure deployment credentials
- `production-config.sh` - Real production configuration
- Any file with actual passwords, API keys, or tokens

## Best Practices for Deployment

### 1. Never hardcode secrets
```bash
# ❌ BAD - Don't do this
SECRET_KEY="actual-secret-key-value"

# ✅ GOOD - Use placeholders in committed files
SECRET_KEY="your-super-secret-production-key-here"
```

### 2. Use Azure App Service Application Settings
- Set all sensitive values in Azure Portal > App Service > Configuration
- Use the deployment script which prompts for values securely
- Never paste real secrets in terminal commands that might be logged

### 3. Use environment variables locally
```bash
# Create a local .env file (not committed)
cp .env.production .env
# Edit .env with real values for local development
```

### 4. Azure CLI Security
```bash
# The deployment script securely prompts for sensitive values
./deploy-to-azure-india.sh
# Enter database admin password: [hidden input]
# Enter a strong secret key: [hidden input]
```

## Verifying Security Before Commit

Run this command to check for accidentally committed secrets:
```bash
# Check for potential secrets in staged files
git diff --cached | grep -i -E "(password|secret|key|token)" | grep -v "your-.*-here"
```

## If You Accidentally Commit Secrets

1. **Immediately rotate/change** all exposed credentials
2. **Remove from git history:**
   ```bash
   git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch path/to/secret/file' --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push** to update remote repository
4. **Notify team members** to re-clone the repository

## Deployment Security Checklist

- [ ] All template files use placeholder values
- [ ] `.gitignore` includes all secret file patterns
- [ ] Real secrets are only in Azure App Service settings
- [ ] Database passwords are complex and unique
- [ ] Storage keys are not exposed in code
- [ ] Google OAuth secrets are configured in Azure only
- [ ] Local `.env` files are in `.gitignore`

## Contact

If you find any security issues or accidentally committed secrets, please:
1. Immediately create an issue in this repository
2. Follow the secret rotation process above
3. Contact the development team

---
**Remember: Security is everyone's responsibility! 🛡️**
