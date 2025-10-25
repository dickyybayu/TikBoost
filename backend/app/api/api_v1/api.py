from fastapi import APIRouter
from app.api.api_v1.endpoints import auth, mock_tiktok, hf_inference, user_products_simple, user_sessions
# from app.api.api_v1.endpoints import ai_content  # COMMENTED OUT TO AVOID MODEL AUTO-LOADING
# from app.api.api_v1.endpoints import tiktok_live  # COMMENTED OUT TO AVOID MODEL AUTO-LOADING

api_router = APIRouter()

# Authentication routes
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])

# User data routes (DATABASE-BASED - NO AUTH REQUIRED FOR TESTING!)
api_router.include_router(user_products_simple.router, tags=["user-data"])
api_router.include_router(user_sessions.router, tags=["user-sessions"])

# AI Content routes (for persistent AI recommendations) - COMMENTED OUT TO AVOID MODEL AUTO-LOADING
# api_router.include_router(ai_content.router, prefix="/ai_content", tags=["ai-content"])

# TikTok Live AI routes (real model - local download) - COMMENTED OUT TO AVOID MODEL AUTO-LOADING
# api_router.include_router(tiktok_live.router, prefix="/tiktok", tags=["tiktok-live-ai"])

# Mock TikTok routes (for testing without heavy model)
api_router.include_router(mock_tiktok.router, prefix="/mock", tags=["mock-testing"])

# Hugging Face Inference API (cloud API - no download needed!)
api_router.include_router(hf_inference.router, prefix="/hf", tags=["huggingface-inference-api"])