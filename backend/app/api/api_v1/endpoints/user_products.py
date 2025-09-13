from fastapi import APIRouter, HTTPException, Depends
from typing import List, Dict, Any
from pydantic import BaseModel
import json
import os

router = APIRouter()

# Pydantic models for request/response
class ProductData(BaseModel):
    id: str
    name: str
    price: float
    salesCount: int

class UserProductsRequest(BaseModel):
    username: str
    products: List[Dict[str, Any]]

class UserProductsResponse(BaseModel):
    username: str
    products: List[Dict[str, Any]]

# Simple file-based storage (untuk development)
# Nanti bisa diganti dengan database
STORAGE_DIR = "user_data"
os.makedirs(STORAGE_DIR, exist_ok=True)

@router.post("/user/products")
async def save_user_products(request: UserProductsRequest):
    """Save user's top products"""
    try:
        file_path = os.path.join(STORAGE_DIR, f"{request.username}_products.json")
        
        data = {
            "username": request.username,
            "products": request.products
        }
        
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        
        return {"message": "Products saved successfully", "count": len(request.products)}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saving products: {str(e)}")

@router.get("/user/products/{username}")
async def load_user_products(username: str):
    """Load user's top products"""
    try:
        file_path = os.path.join(STORAGE_DIR, f"{username}_products.json")
        
        if not os.path.exists(file_path):
            return {"username": username, "products": []}
        
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        return data
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading products: {str(e)}")

@router.delete("/user/products/{username}")
async def delete_user_products(username: str):
    """Delete user's products"""
    try:
        file_path = os.path.join(STORAGE_DIR, f"{username}_products.json")
        
        if os.path.exists(file_path):
            os.remove(file_path)
            return {"message": "Products deleted successfully"}
        else:
            return {"message": "No products found to delete"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting products: {str(e)}")

# AI Recommendations endpoints (simple file-based storage for now)
class RecommendationsData(BaseModel):
    copywriting1: str = ""
    copywriting2: str = ""
    copywriting3: str = ""
    optimalTime: str = ""
    bundleRecommendation: str = ""
    timestamp: int

@router.post("/recommendations/save")
async def save_recommendations(recommendations: RecommendationsData):
    """Save AI recommendations to file storage"""
    try:
        file_path = "data/recommendations.json"
        os.makedirs("data", exist_ok=True)
        
        with open(file_path, 'w') as f:
            json.dump(recommendations.dict(), f, indent=2)
        
        return {"status": "success", "message": "Recommendations saved successfully"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saving recommendations: {str(e)}")

@router.get("/recommendations/load")
async def load_recommendations():
    """Load AI recommendations from file storage"""
    try:
        file_path = "data/recommendations.json"
        
        if os.path.exists(file_path):
            with open(file_path, 'r') as f:
                data = json.load(f)
            return {"status": "success", "data": data}
        else:
            return {"status": "not_found", "message": "No recommendations found"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading recommendations: {str(e)}")
