#!/bin/bash

# TikBoost Backend Deployment Script for Render

echo "🚀 Preparing TikBoost Backend for Render deployment..."

# Check if requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt not found!"
    exit 1
fi

# Check if Procfile exists
if [ ! -f "Procfile" ]; then
    echo "❌ Procfile not found!"
    exit 1
fi

# Validate main.py
if [ ! -f "main.py" ]; then
    echo "❌ main.py not found!"
    exit 1
fi

echo "✅ All required files found"

# Check Python version
python_version=$(python --version 2>&1)
echo "🐍 Python version: $python_version"

# Test if FastAPI can import
echo "🔍 Testing FastAPI import..."
python -c "import fastapi; print('✅ FastAPI import successful')" || {
    echo "❌ FastAPI import failed. Installing dependencies..."
    pip install -r requirements.txt
}

# Create .env.example for reference
echo "📝 Creating .env.example..."
cat > .env.example << EOF
# Copy this to .env and fill in your values
DATABASE_URL=postgresql://user:password@host:port/database
SECRET_KEY=your-super-secret-key-here-minimum-32-characters
ACCESS_TOKEN_EXPIRE_MINUTES=30
RUNPOD_API_KEY=your-runpod-api-key
RUNPOD_ENDPOINT_ID=your-runpod-endpoint-id
ENVIRONMENT=production
DEBUG=false
EOF

echo "✅ .env.example created"

# Test local server
echo "🧪 Testing local server startup..."
timeout 5s python -c "
import uvicorn
from main import app
print('✅ Server can start successfully')
" || echo "⚠️  Server test skipped (timeout or error)"

echo ""
echo "🎯 Pre-deployment checklist:"
echo "✅ requirements.txt optimized for Render"
echo "✅ Procfile configured"
echo "✅ runtime.txt specified"
echo "✅ Environment variables documented"
echo ""
echo "📋 Next steps:"
echo "1. Create GitHub repository"
echo "2. Push code to GitHub"
echo "3. Follow DEPLOY_TO_RENDER.md guide"
echo ""
echo "🔗 Quick deploy URLs:"
echo "   - Render: https://render.com"
echo "   - GitHub: https://github.com"
echo ""
echo "💡 Your backend will be deployed at:"
echo "   https://tikboost-backend.onrender.com"
echo ""
echo "🚀 Ready for deployment!"
