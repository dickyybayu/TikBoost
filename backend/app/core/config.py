from typing import Any, Dict, List, Optional, Union
from pydantic import AnyHttpUrl, EmailStr, field_validator
from pydantic_settings import BaseSettings
import secrets
from app.core.config import settings

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = secrets.token_urlsafe(32)
    # 60 minutes * 24 hours * 8 days = 8 days
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8
    SERVER_NAME: str = "TikBoost API"
    SERVER_HOST: AnyHttpUrl = "http://localhost"
    
    # CORS origins - simplified
    BACKEND_CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8080,http://localhost:4200"

    PROJECT_NAME: str = "TikBoost"
    
    # Database
    DATABASE_URL: str = "postgresql://username:password@localhost/tikboost_db"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379"
    
    HUGGINGFACE_API_TOKEN: Optional[str] = {settings.HUGGINGFACE_API_TOKEN}
    HUGGINGFACE_MODEL_NAME: str = "Venturaa/mistral-recommender-merged-bf16"
    HUGGINGFACE_USE_LOCAL: bool = False  # Set to True if model is downloaded locally
    HUGGINGFACE_LOCAL_PATH: Optional[str] = None  # Path to local model if HUGGINGFACE_USE_LOCAL is True
    
    # Model Parameters
    MAX_NEW_TOKENS: int = 40  # Changed from MAX_TOKEN_LENGTH to match your example
    MODEL_TEMPERATURE: float = 0.7
    MODEL_TOP_P: float = 0.9
    MODEL_TOP_K: int = 50
    MODEL_DO_SAMPLE: bool = True
    
    # External APIs
    TIKTOK_API_KEY: Optional[str] = None
    YOUTUBE_API_KEY: Optional[str] = None
    
    # Apify Configuration for TikTok Scraping (Replaces TikTok API)
    APIFY_API_TOKEN: Optional[str] = None  # Your Apify API token
    APIFY_TIKTOK_SCRAPER_ACTOR: str = "clockworks/free-tiktok-scraper"  # Popular TikTok scraper
    APIFY_HASHTAG_SCRAPER_ACTOR: str = "drobnikj/tiktok-scraper"  # Alternative scraper
    APIFY_MAX_RESULTS: int = 20  # Max results per scraping request
    APIFY_TIMEOUT_SECONDS: int = 120  # Timeout for scraping tasks
    APIFY_ENABLE_CACHE: bool = True  # Enable caching of scraped data
    APIFY_CACHE_TTL: int = 1800  # Cache TTL in seconds (30 minutes)
    
    # TikTok API Integration (DEPRECATED - Use Apify instead)
    TIKTOK_RESEARCH_API_TOKEN: Optional[str] = None  # For TikTok Research API
    TIKTOK_CREATOR_API_TOKEN: Optional[str] = None   # For TikTok Creator API  
    TIKTOK_ADS_API_TOKEN: Optional[str] = None       # For TikTok Ads Manager API
    TIKTOK_ADVERTISER_ID: Optional[str] = None       # Your TikTok Ads Account ID
    TIKTOK_DEFAULT_REGION: str = "ID"                # Default region code (Indonesia)
    
    # Email
    SMTP_TLS: bool = True
    SMTP_PORT: Optional[int] = None
    SMTP_HOST: Optional[str] = None
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    EMAILS_FROM_EMAIL: Optional[EmailStr] = None
    EMAILS_FROM_NAME: Optional[str] = None
    
    # AWS
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_BUCKET_NAME: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    
    # Celery
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"
    
    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # OAuth Providers
    GOOGLE_OAUTH_CLIENT_ID: Optional[str] = None
    TIKTOK_CLIENT_KEY: Optional[str] = None
    TIKTOK_CLIENT_SECRET: Optional[str] = None
    TIKTOK_REDIRECT_URI: Optional[str] = None  # e.g. https://your.api.com/api/v1/auth/tiktok/callback
    APP_SCHEME: str = "tikboost"  # mobile custom URL scheme for OAuth callback
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 100
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Convert CORS origins string to list"""
        return [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",")]
    
    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
