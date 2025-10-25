# Deploy TikBoost Backend to Render

## Step 1: Create GitHub Repository
1. Create a new repository on GitHub
2. Push your code to GitHub:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

## Step 2: Create Render Account
1. Go to https://render.com
2. Sign up with your GitHub account
3. Connect your GitHub repository

## Step 3: Create PostgreSQL Database
1. In Render dashboard, click "New +"
2. Select "PostgreSQL"
3. Fill in details:
   - Name: `tikboost-db`
   - Database: `tikboost`
   - User: `tikboost_user`
   - Region: Choose closest to your users
4. Click "Create Database"
5. **Save the database connection details** (you'll need them for web service)

## Step 4: Create Web Service
1. In Render dashboard, click "New +"
2. Select "Web Service"
3. Connect your GitHub repository
4. Fill in details:
   - Name: `tikboost-backend`
   - Environment: `Python 3`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - Plan: Free (or paid for better performance)

## Step 5: Set Environment Variables
In your web service settings, add these environment variables:

### Required Variables:
```
DATABASE_URL=<from your PostgreSQL database>
SECRET_KEY=your-super-secret-key-here-minimum-32-characters
ACCESS_TOKEN_EXPIRE_MINUTES=30
RUNPOD_API_KEY=your-runpod-api-key
RUNPOD_ENDPOINT_ID=your-runpod-endpoint-id
```

### Optional Variables:
```
ENVIRONMENT=production
DEBUG=false
ALLOWED_ORIGINS=["https://your-frontend-domain.com"]
```

## Step 6: Deploy
1. Click "Create Web Service"
2. Wait for deployment to complete (5-10 minutes)
3. Your backend will be available at: `https://tikboost-backend.onrender.com`

## Step 7: Test Deployment
Test your endpoints:
- Health check: `GET https://tikboost-backend.onrender.com/health`
- API docs: `https://tikboost-backend.onrender.com/docs`

## Step 8: Update Mobile App
Update the mobile app configuration to use the production backend URL:

1. Edit `mobile/lib/config/environment.dart`
2. Change `baseUrl` to your Render URL
3. Build and deploy your mobile app

## Troubleshooting

### Common Issues:
1. **Build Failed**: Check `requirements.txt` for incompatible packages
2. **Database Connection**: Verify DATABASE_URL format
3. **502 Error**: Check start command and port configuration
4. **Memory Issues**: Upgrade to paid plan for better resources

### Logs:
- Check deployment logs in Render dashboard
- Use `print()` statements for debugging

## Cost Optimization
- Free tier includes 750 hours/month
- Database sleeps after 90 days of inactivity
- Consider upgrading for production use

## Security Notes
- Use strong SECRET_KEY (32+ characters)
- Keep API keys secure
- Enable CORS only for your domains
- Use HTTPS for all communications
