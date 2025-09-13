from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from datetime import datetime

from app.core.database import get_db
from app.models.models import User
from app.models.ai_recommendations import AIRecommendation, UserProduct
from app.services.user_service import user_service
from app import schemas

router = APIRouter()

# Pydantic models for request/response
class ProductRequest(BaseModel):
    external_id: Optional[str] = None
    name: str
    price: float
    sales_count: int
    category: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None

class UserProductsRequest(BaseModel):
    products: List[ProductRequest]

class RecommendationsRequest(BaseModel):
    copywriting1: str
    copywriting2: str
    copywriting3: str
    optimal_time: str
    bundle_recommendation: str
    products_data: Optional[Dict[str, Any]] = None
    quality_score: Optional[float] = None

class RecommendationsResponse(BaseModel):
    id: int
    copywriting1: str
    copywriting2: str
    copywriting3: str
    optimal_time: str
    bundle_recommendation: str
    created_at: datetime
    quality_score: Optional[float] = None

# User Products Endpoints (Database-based)
@router.post("/user/products")
async def save_user_products(
    request: UserProductsRequest, 
    db: Session = Depends(get_db),
    current_user: User = Depends(user_service.get_current_user)
):
    """Save user's top products to database"""
    try:
        # Delete existing top products for this user
        db.query(UserProduct).filter(
            UserProduct.user_id == current_user.id,
            UserProduct.is_top_product == True
        ).delete()
        
        # Save new top products
        for product_data in request.products:
            user_product = UserProduct(
                user_id=current_user.id,
                external_id=product_data.external_id,
                name=product_data.name,
                price=product_data.price,
                sales_count=product_data.sales_count,
                category=product_data.category,
                description=product_data.description,
                image_url=product_data.image_url,
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

@router.get("/user/products")
async def load_user_products(
    db: Session = Depends(get_db),
    current_user: User = Depends(user_service.get_current_user)
):
    """Load user's top products from database"""
    try:
        products = db.query(UserProduct).filter(
            UserProduct.user_id == current_user.id,
            UserProduct.is_top_product == True,
            UserProduct.is_active == True
        ).order_by(UserProduct.sales_count.desc()).all()
        
        return {
            "username": current_user.username,
            "products": [
                {
                    "id": f"user_product_{product.id}",
                    "external_id": product.external_id,
                    "name": product.name,
                    "price": product.price,
                    "salesCount": product.sales_count,
                    "category": product.category,
                    "description": product.description,
                    "image_url": product.image_url,
                    "created_at": product.created_at.isoformat()
                }
                for product in products
            ]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading products: {str(e)}")

# AI Recommendations Endpoints (Database-based)
@router.post("/recommendations/save")
async def save_recommendations(
    request: RecommendationsRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(user_service.get_current_user)
):
    """Save AI recommendations to database"""
    try:
        # Create new recommendation
        recommendation = AIRecommendation(
            user_id=current_user.id,
            copywriting1=request.copywriting1,
            copywriting2=request.copywriting2,
            copywriting3=request.copywriting3,
            optimal_time=request.optimal_time,
            bundle_recommendation=request.bundle_recommendation,
            products_data=request.products_data,
            quality_score=request.quality_score
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
async def load_recommendations(
    db: Session = Depends(get_db),
    current_user: User = Depends(user_service.get_current_user)
):
    """Load latest AI recommendations from database"""
    try:
        # Get latest recommendation for user
        recommendation = db.query(AIRecommendation).filter(
            AIRecommendation.user_id == current_user.id
        ).order_by(AIRecommendation.created_at.desc()).first()
        
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
                "timestamp": int(recommendation.created_at.timestamp() * 1000),
                "quality_score": recommendation.quality_score
            }
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading recommendations: {str(e)}")

@router.get("/recommendations/history")
async def get_recommendations_history(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(user_service.get_current_user)
):
    """Get recommendations history for user"""
    try:
        recommendations = db.query(AIRecommendation).filter(
            AIRecommendation.user_id == current_user.id
        ).order_by(AIRecommendation.created_at.desc()).limit(limit).all()
        
        return {
            "status": "success",
            "data": [
                {
                    "id": rec.id,
                    "copywriting1": rec.copywriting1,
                    "copywriting2": rec.copywriting2,
                    "copywriting3": rec.copywriting3,
                    "optimal_time": rec.optimal_time,
                    "bundle_recommendation": rec.bundle_recommendation,
                    "created_at": rec.created_at.isoformat(),
                    "quality_score": rec.quality_score
                }
                for rec in recommendations
            ]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading recommendations history: {str(e)}")

@router.delete("/recommendations/{recommendation_id}")
async def delete_recommendation(
    recommendation_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(user_service.get_current_user)
):
    """Delete a specific recommendation"""
    try:
        recommendation = db.query(AIRecommendation).filter(
            AIRecommendation.id == recommendation_id,
            AIRecommendation.user_id == current_user.id
        ).first()
        
        if not recommendation:
            raise HTTPException(status_code=404, detail="Recommendation not found")
        
        db.delete(recommendation)
        db.commit()
        
        return {"status": "success", "message": "Recommendation deleted successfully"}
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting recommendation: {str(e)}")
