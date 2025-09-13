# TikBoost Backend Deployment Guide - Render

## 1. Push Code ke GitHub

Pastikan code sudah di push ke GitHub repository.

## 2. Setup Render Service

1. **Login ke Render.com**
   - Buat account di https://render.com
   - Connect dengan GitHub account

2. **Create New Web Service**
   - Dashboard → New → Web Service
   - Connect GitHub repository: `TikBoost`
   - Branch: `krisna`
   - Root Directory: `backend`

## 3. Configure Service Settings

### Basic Settings:
- **Name**: `tikboost-backend`
- **Region**: `Singapore` (terdekat dengan Indonesia)
- **Branch**: `krisna`
- **Root Directory**: `backend`
- **Runtime**: `Python 3`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Environment Variables:
Add these in Render Environment Variables section:

```
SECRET_KEY=your_super_secret_key_here_32_characters
DATABASE_URL=<will_be_provided_by_render_postgresql>
ENVIRONMENT=production
DEBUG=false
BACKEND_CORS_ORIGINS=https://your-frontend-domain.com
HUGGINGFACE_API_TOKEN=your_hf_token_here
RUNPOD_API_KEY=your_runpod_key_here
RUNPOD_ENDPOINT_ID=your_runpod_endpoint_here
```

## 4. Add PostgreSQL Database

1. **Create PostgreSQL Database**
   - Dashboard → New → PostgreSQL
   - Name: `tikboost-db`
   - Region: Same as web service

2. **Connect Database**
   - Copy the `Internal Database URL`
   - Add as `DATABASE_URL` environment variable in web service

## 5. Deploy

1. Click **Create Web Service**
2. Wait for deployment (5-10 minutes first time)
3. Check logs for any errors

## 6. Test Deployment

Your backend will be available at:
```
https://tikboost-backend.onrender.com
```

Test endpoints:
- `GET /` - Health check
- `GET /docs` - API documentation
- `GET /api/v1/health` - Backend health

## 7. Update Mobile App

Update mobile app to use production backend URL:

In `mobile/lib/services/api_service.dart`:
```dart
static String get baseUrl {
  if (kIsWeb) return 'https://tikboost-backend.onrender.com';
  // For mobile apps, use production URL
  return 'https://tikboost-backend.onrender.com';
}
```

## 8. Monitoring

- Monitor logs in Render dashboard
- Check metrics and performance
- Set up alerts for downtime

## Notes:

- **Free Tier**: Render free tier sleeps after 15 minutes of inactivity
- **Cold Starts**: First request after sleep takes 30-60 seconds
- **Upgrade**: Consider paid plan for production use (no sleep)
- **SSL**: HTTPS automatically provided by Render
- **Database**: Free PostgreSQL has 1GB limit
