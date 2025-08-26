# 🚀 DEPLOYMENT INSTRUCTIONS

## 🎯 EXACT ENVIRONMENT VARIABLES FOR RENDER

**Copy these EXACT values to your Render Dashboard → Environment tab:**

### 1. Required - Database Connection
```
Key: DATABASE_URL


### 2. Required - AI Service  
```
Key: GEMINI_API_KEY


## 📝 Steps:
1. Go to Render Dashboard
2. Click your service → Environment tab
3. Click "Add Environment Variable"
4. Copy-paste the Key and Value exactly as shown above
5. Click "Save Changes"
6. Wait for automatic redeploy

## 🔍 Why the special encoding?
The password `Anupam1/2#3` contains special characters:
- `/` (forward slash) → `%2F` 
- `#` (hash) → `%23`

This prevents URL parsing errors in the database connection.

## ✅ Test after deployment:
```bash
curl https://your-app-name.onrender.com/health/
```

Should return: `{"status": "ok", "message": "IPC Justice Aid API is running"}`
