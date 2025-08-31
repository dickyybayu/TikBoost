#!/bin/bash

echo "🚀 Starting TikBoost Backend Setup..."

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Setup environment variables
echo "🔧 Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
    echo "⚠️  Please update the .env file with your actual values"
fi

# Initialize database (you'll need to set up PostgreSQL first)
echo "🗄️  Database setup..."
echo "Please make sure PostgreSQL is running and update DATABASE_URL in .env"

# Run migrations (when Alembic is set up)
# alembic upgrade head

echo "✅ Setup complete!"
echo ""
echo "🚀 To start the server:"
echo "   uvicorn main:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "📚 API Documentation will be available at:"
echo "   http://localhost:8000/docs"
