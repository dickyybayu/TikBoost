from sqlalchemy import Column, Integer, String, DateTime, Text, Float, ForeignKey, JSON, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.models.models import Base

class AIRecommendation(Base):
    __tablename__ = "ai_recommendations"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # AI Generated Content
    copywriting1 = Column(Text, nullable=False)
    copywriting2 = Column(Text, nullable=False)  
    copywriting3 = Column(Text, nullable=False)
    optimal_time = Column(String, nullable=False)
    bundle_recommendation = Column(Text, nullable=False)
    
    # Metadata
    products_data = Column(JSON, nullable=True)  # Store the products used for generation
    model_version = Column(String, nullable=True)
    quality_score = Column(Float, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="ai_recommendations")

class UserProduct(Base):
    __tablename__ = "user_products"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Product data
    external_id = Column(String, nullable=True)  # For syncing with external systems
    name = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    sales_count = Column(Integer, default=0)
    
    # Product metadata
    category = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)
    
    # Performance tracking
    last_sale_date = Column(DateTime(timezone=True), nullable=True)
    conversion_rate = Column(Float, default=0.0)
    
    # Status
    is_active = Column(Boolean, default=True)
    is_top_product = Column(Boolean, default=False)  # Mark as user's top 3
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="user_products")
