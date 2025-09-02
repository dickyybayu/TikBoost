from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
import asyncio
import logging
from contextlib import asynccontextmanager
from app.core.config import settings
from app.api.api_v1.api import api_router
from app.core.database import engine
from app.models import models

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create database tables
models.Base.metadata.create_all(bind=engine)

# 🔥 GLOBAL MODEL INSTANCE - AKAN DI-LOAD SEKALI SAJA!
global_model_service = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    global global_model_service
    
    # Startup - NO MODEL LOADING! Model akan di-load lazy saat dibutuhkan
    logger.info("🚀 Starting TikBoost API...")
    logger.info("� Model akan di-load saat endpoint pertama kali dipanggil (lazy loading)")
    global_model_service = None
    
    yield
    
    # Shutdown
    logger.info("🛑 Shutting down TikBoost API...")

app = FastAPI(
    title="TikBoost API",
    description="AI-powered livestream selling assistant backend",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan
)

# Set CORS
if os.environ.get("CORS_ALLOW_ALL") == "1" or settings.DEBUG:
    # Dev-friendly: allow all origins. Use credentials=False to emit wildcard "*" header
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
elif settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {
        "message": "Welcome to TikBoost API",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)