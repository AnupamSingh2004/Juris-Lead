#!/bin/bash

# Security Verification Script for Flutter Google Auth
echo "🔒 Security Configuration Verification"
echo "======================================"

# Check if .env file exists
if [ -f ".env" ]; then
    echo "✅ .env file exists"
else
    echo "❌ .env file missing"
    exit 1
fi

# Check if .env is in .gitignore
if grep -q "^\.env$" .gitignore; then
    echo "✅ .env is in .gitignore"
else
    echo "❌ .env is NOT in .gitignore - SECURITY RISK!"
    exit 1
fi

# Check if .env.example exists
if [ -f ".env.example" ]; then
    echo "✅ .env.example exists for other developers"
else
    echo "⚠️  .env.example missing (recommended for team setup)"
fi

# Check if required environment variables are set in .env
required_vars=("GOOGLE_ANDROID_CLIENT_ID" "GOOGLE_WEB_CLIENT_ID")
for var in "${required_vars[@]}"; do
    if grep -q "^${var}=" .env; then
        echo "✅ $var is configured"
    else
        echo "❌ $var is missing from .env"
    fi
done

# Check if hardcoded credentials are removed from config file
if grep -q "static const String.*Client.*=" lib/config/google_auth_config.dart; then
    echo "❌ Hardcoded credentials still found in google_auth_config.dart"
else
    echo "✅ No hardcoded credentials in google_auth_config.dart"
fi

# Check if flutter_dotenv is in pubspec.yaml
if grep -q "flutter_dotenv:" pubspec.yaml; then
    echo "✅ flutter_dotenv dependency added"
else
    echo "❌ flutter_dotenv dependency missing"
fi

echo ""
echo "🎯 Security Status:"
if [ $? -eq 0 ]; then
    echo "✅ Your app is ready for GitHub! No credentials will be exposed."
else
    echo "❌ Please fix the issues above before pushing to GitHub."
fi

echo ""
echo "📋 Next Steps:"
echo "1. Test Google Sign-In functionality"
echo "2. Commit and push to GitHub"
echo "3. Share .env.example with team members"
