from fastapi import APIRouter
from app.api.api_v1.endpoints import auth, tiktok_live, mock_tiktok, hf_inference

api_router = APIRouter()

# Authentication routes
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])

# TikTok Live AI routes (real model - local download)
api_router.include_router(tiktok_live.router, prefix="/tiktok", tags=["tiktok-live-ai"])

# Mock TikTok routes (for testing without heavy model)
api_router.include_router(mock_tiktok.router, prefix="/mock", tags=["mock-testing"])

# Hugging Face Inference API (cloud API - no download needed!)
api_router.include_router(hf_inference.router, prefix="/hf", tags=["huggingface-inference-api"])
