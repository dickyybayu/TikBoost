from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from datetime import datetime

from app.core.database import get_db
from app.models.models import User
from app.models.ai_recommendations import AIRecommendation, UserProduct

router = APIRouter()

# Pydantic models for request/response (Same as old endpoints for compatibility)
class ProductData(BaseModel):
    id: str
    name: str
    price: float
    salesCount: int

class UserProductsRequest(BaseModel):
    username: str
    products: List[Dict[str, Any]]

class RecommendationsData(BaseModel):
    copywriting1: str = ""
    copywriting2: str = ""
    copywriting3: str = ""
    optimalTime: str = ""
    bundleRecommendation: str = ""
    timestamp: int

# Helper function to get or create user
def get_or_create_user(db: Session, username: str) -> User:
    """Get existing user or create a new one"""
    user = db.query(User).filter(User.username == username).first()
    if not user:
        # Create a minimal user for testing
        user = User(
            username=username,
            email=f"{username}@test.com",
            hashed_password="dummy",  # For testing only
            full_name=username,
            is_active=True
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    return user

# User Products Endpoints (Database-based, no auth required)
@router.post("/user/products")
async def save_user_products(request: UserProductsRequest, db: Session = Depends(get_db)):
    """Save user's top products to database"""
    try:
        # Get or create user
        user = get_or_create_user(db, request.username)
        
        # Delete existing top products for this user
        db.query(UserProduct).filter(
            UserProduct.user_id == user.id,
            UserProduct.is_top_product == True
        ).delete()
        
        # Save new top products
        for product_data in request.products:
            user_product = UserProduct(
                user_id=user.id,
                external_id=product_data.get('id', ''),
                name=product_data.get('name', ''),
                price=float(product_data.get('price', 0)),
                sales_count=int(product_data.get('salesCount', 0)),
                is_top_product=True,
                is_active=True
            )
            db.add(user_product)
        
        db.commit()
        
        return {
            "message": "Products saved successfully", 
            "count": len(request.products)
        }
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error saving products: {str(e)}")

@router.get("/user/products/{username}")
async def load_user_products(username: str, db: Session = Depends(get_db)):
    """Load user's top products from database"""
    try:
        # Get user
        user = db.query(User).filter(User.username == username).first()
        if not user:
            return {"username": username, "products": []}
        
        # Get products
        products = db.query(UserProduct).filter(
            UserProduct.user_id == user.id,
            UserProduct.is_top_product == True,
            UserProduct.is_active == True
        ).order_by(UserProduct.sales_count.desc()).all()
        
        return {
            "username": username,
            "products": [
                {
                    "id": f"user_product_{product.id}",
                    "name": product.name,
                    "price": product.price,
                    "salesCount": product.sales_count,
                }
                for product in products
            ]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading products: {str(e)}")

# AI Recommendations Endpoints (Database-based, no auth required)
@router.post("/recommendations/save")
async def save_recommendations(recommendations: RecommendationsData, db: Session = Depends(get_db)):
    """Save AI recommendations to database (no auth required for testing)"""
    try:
        # For now, save to a default user "anonymous" or the last active user
        # In production, this should use proper authentication
        default_username = "anonymous"
        user = get_or_create_user(db, default_username)
        
        # Create new recommendation
        recommendation = AIRecommendation(
            user_id=user.id,
            copywriting1=recommendations.copywriting1,
            copywriting2=recommendations.copywriting2,
            copywriting3=recommendations.copywriting3,
            optimal_time=recommendations.optimalTime,
            bundle_recommendation=recommendations.bundleRecommendation,
            products_data={"timestamp": recommendations.timestamp}
        )
        
        db.add(recommendation)
        db.commit()
        db.refresh(recommendation)
        
        return {
            "status": "success", 
            "message": "Recommendations saved successfully",
            "id": recommendation.id
        }
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error saving recommendations: {str(e)}")

@router.get("/recommendations/load")
async def load_recommendations(db: Session = Depends(get_db)):
    """Load latest AI recommendations from database (no auth required for testing)"""
    try:
        # Get latest recommendation from any user (for testing)
        recommendation = db.query(AIRecommendation).order_by(
            AIRecommendation.created_at.desc()
        ).first()
        
        if not recommendation:
            return {
                "status": "not_found", 
                "message": "No recommendations found"
            }
        
        return {
            "status": "success",
            "data": {
                "copywriting1": recommendation.copywriting1,
                "copywriting2": recommendation.copywriting2,
                "copywriting3": recommendation.copywriting3,
                "optimalTime": recommendation.optimal_time,
                "bundleRecommendation": recommendation.bundle_recommendation,
                "timestamp": int(recommendation.created_at.timestamp() * 1000)
            }
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading recommendations: {str(e)}")

@router.delete("/user/products/{username}")
async def delete_user_products(username: str, db: Session = Depends(get_db)):
    """Delete user's products from database"""
    try:
        user = db.query(User).filter(User.username == username).first()
        if not user:
            return {"message": "User not found"}
        
        deleted_count = db.query(UserProduct).filter(
            UserProduct.user_id == user.id
        ).delete()
        
        db.commit()
        
        return {
            "message": f"Deleted {deleted_count} products successfully"
        }
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting products: {str(e)}")
