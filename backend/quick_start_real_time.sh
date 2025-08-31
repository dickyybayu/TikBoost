#!/bin/bash

# 🚀 QUICK START: Real-Time Data Integration
# Run this script to test your enhanced AI model with real-time data

echo "🚀 TikBoost AI Real-Time Data Integration - Quick Start"
echo "======================================================"

# Check if we're in the right directory
if [ ! -f "main.py" ]; then
    echo "❌ Please run this from the backend directory"
    exit 1
fi

echo "📋 Step 1: Installing any missing dependencies..."
# pip install -r requirements.txt

echo "✅ Step 2: Testing the demo..."
python test_real_time_demo.py

echo ""
echo "📊 Step 3: Start the server to test API endpoints..."
echo "Run: uvicorn main:app --reload"
echo ""
echo "🔧 Step 4: Test the enhanced APIs:"
echo "POST /api/v1/ai-content/generate-live-commerce"
echo "POST /api/v1/ai-content/generate-specific-section"
echo "GET  /api/v1/ai-content/real-time-context-status"
echo ""
echo "🎯 Your model now uses REAL-TIME data instead of just training data!"
echo "Check the generated content for trending keywords, viewer counts, and dynamic recommendations."
