# Google Authentication Setup Guide for Juris-Lead

## Current Issue
The app package name has changed from `com.aarogyarekha.app` to `com.jurislead.app`, but the Google OAuth configuration still uses the old credentials.

## Required Steps

### 1. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or use existing project
3. Enable Google Sign-In API
4. Go to "APIs & Services" > "Credentials"

### 2. Create Android OAuth Client

1. Click "Create Credentials" > "OAuth 2.0 Client ID"
2. Select "Android" as application type
3. Enter the following details:
   - **Package name**: `com.jurislead.app`
   - **SHA-1 certificate fingerprint**: `03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49`

### 3. Create Web OAuth Client (for backend integration)

1. Click "Create Credentials" > "OAuth 2.0 Client ID"
2. Select "Web application" as application type
3. Add authorized origins:
   - `http://localhost:8001`
   - `http://localhost:3000`
4. Add authorized redirect URIs:
   - `http://localhost:8001/auth/callback`

### 4. Update Environment Variables

After creating the credentials, update the `.env` file with the new client IDs:

```env
GOOGLE_ANDROID_CLIENT_ID=your_new_android_client_id.apps.googleusercontent.com
GOOGLE_WEB_CLIENT_ID=your_new_web_client_id.apps.googleusercontent.com
```

## Current Configuration

- **Package Name**: `com.jurislead.app`
- **App Name**: Juris-Lead
- **SHA-1 Fingerprint**: `03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49`

## Testing

After updating the credentials:

1. Clean and rebuild the Flutter app
2. Test Google Sign-In functionality
3. Check debug logs for any configuration errors

## Troubleshooting

If you encounter "DEVELOPER_ERROR (Code 10)":
- Verify package name matches exactly: `com.jurislead.app`
- Verify SHA-1 fingerprint matches exactly
- Ensure Android OAuth client is properly configured in Google Cloud Console
- Wait a few minutes for changes to propagate
