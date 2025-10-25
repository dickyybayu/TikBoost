from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any, Optional
from pydantic import BaseModel
import logging
from app.dependencies import get_tiktok_live_service

logger = logging.getLogger(__name__)

router = APIRouter()

# Pydantic models for request/response
class LiveProductInput(BaseModel):
    product_name: str
    discounted_price: int
    stock_remaining: int
    live_viewers: int
    event_type: str = "flash sale"

class LiveRecommendationsResponse(BaseModel):
    success: bool
    recommendations: Dict[str, str]
    raw_response: Optional[str] = None
    prompt_used: Optional[str] = None
    error: Optional[str] = None

@router.get("/model/info")
async def get_model_info(service = Depends(get_tiktok_live_service)):
    """Get information about the TikTok Live model"""
    try:
        model_info = service.get_model_info()
        return {
            "status": "success",
            "data": model_info
        }
    except Exception as e:
        logger.error(f"Error getting model info: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/model/initialize")
async def initialize_model(service = Depends(get_tiktok_live_service)):
    """Initialize the TikTok Live model"""
    try:
        await service.initialize()
        return {
            "status": "success",
            "message": "TikTok Live model initialized successfully",
            "model_info": service.get_model_info()
        }
    except Exception as e:
        logger.error(f"Error initializing model: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to initialize model: {str(e)}")

@router.post("/live/recommendations", response_model=LiveRecommendationsResponse)
async def generate_live_recommendations(product_input: LiveProductInput, service = Depends(get_tiktok_live_service)):
    """Generate TikTok Live selling recommendations (COPY, TIME, BUNDLE)"""
    try:
        product_data = {
            "product_name": product_input.product_name,
            "discounted_price": product_input.discounted_price,
            "stock_remaining": product_input.stock_remaining,
            "live_viewers": product_input.live_viewers,
            "event_type": product_input.event_type
        }
        
        result = await service.generate_live_recommendations(product_data)
        
        return LiveRecommendationsResponse(
            success=result["success"],
            recommendations=result["recommendations"],
            raw_response=result.get("raw_response"),
            prompt_used=result.get("prompt_used"),
            error=result.get("error")
        )
        
    except Exception as e:
        logger.error(f"Error generating live recommendations: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to generate recommendations: {str(e)}")

@router.post("/test/model")
async def test_model(service = Depends(get_tiktok_live_service)):
    """Test the model with sample TikTok Live data"""
    try:
        # Check if model is initialized
        model_info = service.get_model_info()
        
        if not model_info["is_initialized"]:
            return {
                "status": "warning",
                "message": "Model is not initialized yet. Please wait for model loading to complete or call /tiktok/model/initialize",
                "model_status": {
                    "is_initialized": model_info["is_initialized"],
                    "is_loading": model_info.get("is_loading", False)
                },
                "sample_input": {
                    "product_name": "Glowing Rok",
                    "discounted_price": 199536,
                    "stock_remaining": 463,
                    "live_viewers": 1669,
                    "event_type": "bonus ongkir"
                }
            }
        
        result = await service.test_model()
        
        return {
            "status": "success",
            "message": "Model test completed",
            "test_result": result,
            "sample_input": {
                "product_name": "Glowing Rok",
                "discounted_price": 199536,
                "stock_remaining": 463,
                "live_viewers": 1669,
                "event_type": "bonus ongkir"
            }
        }
        
    except Exception as e:
        logger.error(f"Error testing model: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Model test failed: {str(e)}")

@router.get("/live/sample-data")
async def get_sample_data():
    """Get sample data format for testing"""
    return {
        "status": "success",
        "sample_input": {
            "product_name": "Tas Wanita Trendy",
            "discounted_price": 150000,
            "stock_remaining": 25,
            "live_viewers": 850,
            "event_type": "flash sale"
        },
        "expected_output_format": {
            "copy": "Copywriting yang menarik dan persuasif",
            "time": "Rekomendasi waktu live yang optimal",
            "bundle": "Saran paket bundling produk"
        },
        "supported_event_types": [
            "flash sale",
            "bonus ongkir",
            "buy 1 get 1",
            "diskon besar",
            "pre order"
        ]
    }
