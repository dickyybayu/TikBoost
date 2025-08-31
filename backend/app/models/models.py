from sqlalchemy import Boolean, Column, Integer, String, DateTime, Text, Float, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=True)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_premium = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Profile information
    avatar_url = Column(String, nullable=True)
    bio = Column(Text, nullable=True)
    phone = Column(String, nullable=True)
    
    # Social media links
    tiktok_username = Column(String, nullable=True)
    youtube_username = Column(String, nullable=True)
    instagram_username = Column(String, nullable=True)
    
    # Relationships
    live_sessions = relationship("LiveSession", back_populates="owner")
    products = relationship("Product", back_populates="owner")
    notifications = relationship("Notification", back_populates="user")
    analytics = relationship("Analytics", back_populates="user")

class LiveSession(Base):
    __tablename__ = "live_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    scheduled_start = Column(DateTime(timezone=True), nullable=False)
    scheduled_end = Column(DateTime(timezone=True), nullable=True)
    actual_start = Column(DateTime(timezone=True), nullable=True)
    actual_end = Column(DateTime(timezone=True), nullable=True)
    status = Column(String, default="scheduled")  # scheduled, live, completed, cancelled
    platform = Column(String, nullable=False)  # tiktok, youtube, instagram, etc.
    stream_url = Column(String, nullable=True)
    viewer_count = Column(Integer, default=0)
    peak_viewers = Column(Integer, default=0)
    engagement_rate = Column(Float, default=0.0)
    revenue_generated = Column(Float, default=0.0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Foreign Keys
    owner_id = Column(Integer, ForeignKey("users.id"))
    
    # Relationships
    owner = relationship("User", back_populates="live_sessions")
    session_products = relationship("SessionProduct", back_populates="session")

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    currency = Column(String, default="IDR")
    image_url = Column(String, nullable=True)
    category = Column(String, nullable=True)
    stock_quantity = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Performance metrics
    total_sold = Column(Integer, default=0)
    revenue_generated = Column(Float, default=0.0)
    conversion_rate = Column(Float, default=0.0)
    
    # Foreign Keys
    owner_id = Column(Integer, ForeignKey("users.id"))
    
    # Relationships
    owner = relationship("User", back_populates="products")
    session_products = relationship("SessionProduct", back_populates="product")
    bundle_products = relationship("BundleProduct", back_populates="product")

class ProductBundle(Base):
    __tablename__ = "product_bundles"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    bundle_price = Column(Float, nullable=False)
    discount_percentage = Column(Float, default=0.0)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Foreign Keys
    owner_id = Column(Integer, ForeignKey("users.id"))
    
    # Relationships
    bundle_products = relationship("BundleProduct", back_populates="bundle")

class BundleProduct(Base):
    __tablename__ = "bundle_products"
    
    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer, default=1)
    
    # Foreign Keys
    bundle_id = Column(Integer, ForeignKey("product_bundles.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    
    # Relationships
    bundle = relationship("ProductBundle", back_populates="bundle_products")
    product = relationship("Product", back_populates="bundle_products")

class SessionProduct(Base):
    __tablename__ = "session_products"
    
    id = Column(Integer, primary_key=True, index=True)
    quantity_sold = Column(Integer, default=0)
    revenue = Column(Float, default=0.0)
    conversion_rate = Column(Float, default=0.0)
    
    # Foreign Keys
    session_id = Column(Integer, ForeignKey("live_sessions.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    
    # Relationships
    session = relationship("LiveSession", back_populates="session_products")
    product = relationship("Product", back_populates="session_products")

class Analytics(Base):
    __tablename__ = "analytics"
    
    id = Column(Integer, primary_key=True, index=True)
    date = Column(DateTime(timezone=True), nullable=False)
    metric_type = Column(String, nullable=False)  # viewers, engagement, revenue, etc.
    metric_value = Column(Float, nullable=False)
    platform = Column(String, nullable=True)
    session_id = Column(Integer, ForeignKey("live_sessions.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Foreign Keys
    user_id = Column(Integer, ForeignKey("users.id"))
    
    # Relationships
    user = relationship("User", back_populates="analytics")

class AIContent(Base):
    __tablename__ = "ai_content"
    
    id = Column(Integer, primary_key=True, index=True)
    content_type = Column(String, nullable=False)  # copywriting, script, description
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    prompt_used = Column(Text, nullable=True)
    is_favorite = Column(Boolean, default=False)
    usage_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Foreign Keys
    user_id = Column(Integer, ForeignKey("users.id"))

class Notification(Base):
    __tablename__ = "notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String, nullable=False)  # info, warning, success, promotion
    is_read = Column(Boolean, default=False)
    action_url = Column(String, nullable=True)
    action_text = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Foreign Keys
    user_id = Column(Integer, ForeignKey("users.id"))
    
    # Relationships
    user = relationship("User", back_populates="notifications")
