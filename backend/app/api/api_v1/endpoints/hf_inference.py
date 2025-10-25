from fastapi import APIRouter, HTTPException
from typing import Dict, Any
from pydantic import BaseModel
from app.services.hf_inference_service import hf_inference_service
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

class LiveProductInput(BaseModel):
    product_name: str
    discounted_price: int
    stock_remaining: int
    live_viewers: int
    event_type: str = "flash sale"

@router.post("/api/recommendations")
async def generate_recommendations_via_api(product_input: LiveProductInput):
    """Generate TikTok Live recommendations using HF Inference API (no local model needed!)"""
    try:
        product_data = {
            "product_name": product_input.product_name,
            "discounted_price": product_input.discounted_price,
            "stock_remaining": product_input.stock_remaining,
            "live_viewers": product_input.live_viewers,
            "event_type": product_input.event_type
        }
        
        result = await hf_inference_service.generate_live_recommendations(product_data)
        
        return {
            "status": "success",
            "data": result,
            "method": "huggingface_inference_api",
            "note": "This uses HF cloud API - no local model download needed!"
        }
        
    except Exception as e:
        logger.error(f"Error in HF API endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to generate recommendations: {str(e)}")

@router.post("/api/test")
async def test_hf_api():
    """Test connection to Hugging Face Inference API"""
    try:
        result = await hf_inference_service.test_connection()
        
        return {
            "status": "success" if result["success"] else "error",
            "connection_test": result,
            "message": "This endpoint tests HF cloud API connection"
        }
        
    except Exception as e:
        logger.error(f"Error testing HF API: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Test failed: {str(e)}")

@router.get("/api/info")
async def get_api_info():
    """Get information about the HF Inference API service"""
    return {
        "service": "Hugging Face Inference API",
        "model": "Venturaa/mistral-recommender-merged-bf16", 
        "method": "Cloud API calls",
        "advantages": [
            "No local model download",
            "Fast inference with GPU",
            "Auto-scaling",
            "Pay per use"
        ],
        "endpoints": [
            "POST /api/v1/hf/api/recommendations - Generate recommendations",
            "POST /api/v1/hf/api/test - Test API connection",
            "GET /api/v1/hf/api/info - This info"
        ]
    }