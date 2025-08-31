from typing import Optional, List
from pydantic import BaseModel, EmailStr
from datetime import datetime

# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None
    tiktok_username: Optional[str] = None
    youtube_username: Optional[str] = None
    instagram_username: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None
    tiktok_username: Optional[str] = None
    youtube_username: Optional[str] = None
    instagram_username: Optional[str] = None

class UserInDBBase(UserBase):
    id: int
    is_active: bool
    is_premium: bool
    avatar_url: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

class User(UserInDBBase):
    pass

class UserInDB(UserInDBBase):
    hashed_password: str

# Authentication Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenPayload(BaseModel):
    sub: Optional[int] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

# Live Session Schemas
class LiveSessionBase(BaseModel):
    title: str
    description: Optional[str] = None
    scheduled_start: datetime
    scheduled_end: Optional[datetime] = None
    platform: str

class LiveSessionCreate(LiveSessionBase):
    pass

class LiveSessionUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    scheduled_start: Optional[datetime] = None
    scheduled_end: Optional[datetime] = None
    status: Optional[str] = None
    viewer_count: Optional[int] = None
    engagement_rate: Optional[float] = None

class LiveSession(LiveSessionBase):
    id: int
    status: str
    actual_start: Optional[datetime] = None
    actual_end: Optional[datetime] = None
    viewer_count: int
    peak_viewers: int
    engagement_rate: float
    revenue_generated: float
    owner_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

# Product Schemas
class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    currency: str = "IDR"
    image_url: Optional[str] = None
    category: Optional[str] = None
    stock_quantity: int = 0

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    currency: Optional[str] = None
    image_url: Optional[str] = None
    category: Optional[str] = None
    stock_quantity: Optional[int] = None
    is_active: Optional[bool] = None

class Product(ProductBase):
    id: int
    is_active: bool
    total_sold: int
    revenue_generated: float
    conversion_rate: float
    owner_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

# Product Bundle Schemas
class ProductBundleBase(BaseModel):
    name: str
    description: Optional[str] = None
    bundle_price: float
    discount_percentage: float = 0.0

class ProductBundleCreate(ProductBundleBase):
    product_ids: List[int]
    quantities: List[int]

class ProductBundle(ProductBundleBase):
    id: int
    is_active: bool
    owner_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

# Analytics Schemas
class AnalyticsBase(BaseModel):
    date: datetime
    metric_type: str
    metric_value: float
    platform: Optional[str] = None
    session_id: Optional[int] = None

class Analytics(AnalyticsBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        orm_mode = True

# AI Content Schemas
class AIContentBase(BaseModel):
    content_type: str
    title: str
    content: str
    prompt_used: Optional[str] = None

class AIContentCreate(AIContentBase):
    pass

class AIContent(AIContentBase):
    id: int
    is_favorite: bool
    usage_count: int
    user_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

class AIContentRequest(BaseModel):
    content_type: str  # "copywriting", "script", "description"
    prompt: str
    context: Optional[str] = None
    sections: Optional[List[str]] = None  # Specific sections to generate
    structured_output: bool = False  # Whether to return structured sections

class AIContentSection(BaseModel):
    """Individual section of generated content"""
    section_name: str
    section_type: str  # "opening", "product_highlight", "call_to_action", etc.
    content: str
    confidence_score: Optional[float] = None

class AIContentStructured(BaseModel):
    """Structured AI content with multiple sections"""
    id: int
    content_type: str
    title: str
    prompt_used: str
    sections: List[AIContentSection]
    full_content: str  # Combined content from all sections
    is_favorite: bool
    usage_count: int
    user_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

class SectionRequest(BaseModel):
    """Request for generating specific sections"""
    content_type: str
    base_prompt: str
    sections_wanted: List[str]  # ["opening", "product_benefits", "closing", etc.]
    context: Optional[str] = None
    merge_sections: bool = True  # Whether to combine sections into full content

# Notification Schemas
class NotificationBase(BaseModel):
    title: str
    message: str
    type: str
    action_url: Optional[str] = None
    action_text: Optional[str] = None

class NotificationCreate(NotificationBase):
    pass

class Notification(NotificationBase):
    id: int
    is_read: bool
    user_id: int
    created_at: datetime

    class Config:
        orm_mode = True

# Dashboard Response Schemas
class DashboardMetrics(BaseModel):
    viewers_today: int
    viewers_change: float
    engagement_rate: float
    engagement_change: float
    revenue_today: float
    revenue_change: float

class DashboardResponse(BaseModel):
    metrics: DashboardMetrics
    recent_sessions: List[LiveSession]
    top_products: List[Product]
    notifications: List[Notification]
