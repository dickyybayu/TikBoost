from fastapi import APIRouter
from typing import Dict, Any
from pydantic import BaseModel
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

class LiveProductInput(BaseModel):
    product_name: str
    discounted_price: int
    stock_remaining: int
    live_viewers: int
    event_type: str = "flash sale"

@router.post("/live/recommendations/mock")
async def generate_mock_recommendations(product_input: LiveProductInput):
    """Mock endpoint for testing without loading heavy model"""
    try:
        # Generate mock response based on input
        mock_copy = f"{product_input.product_name} cuma {product_input.discounted_price:,}! Stok tinggal {product_input.stock_remaining} pcs guys, buruan!"
        
        mock_time = "19:00-21:00 (prime time)" if product_input.live_viewers > 1000 else "20:00-22:00 (peak hours)"
        
        mock_bundle = f"Paket hemat 2+1 gratis khusus {product_input.event_type} hari ini!"
        
        return {
            "success": True,
            "recommendations": {
                "copy": mock_copy,
                "time": mock_time,
                "bundle": mock_bundle
            },
            "mock": True,
            "message": "This is a mock response for testing. Real AI model is loading."
        }
        
    except Exception as e:
        logger.error(f"Error in mock endpoint: {str(e)}")
        return {
            "success": False,
            "error": str(e),
            "recommendations": {
                "copy": "Error generating mock copy",
                "time": "Error generating mock time", 
                "bundle": "Error generating mock bundle"
            }
        }

@router.get("/health")
async def health_check():
    """Simple health check endpoint"""
    return {
        "status": "healthy",
        "message": "Mock TikTok Live API is running",
        "endpoints": [
            "/api/v1/mock/live/recommendations/mock",
            "/api/v1/mock/health"
        ]
    }
