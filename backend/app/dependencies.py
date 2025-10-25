"""
Dependency injection for the FastAPI application
"""
import logging
import asyncio

logger = logging.getLogger(__name__)

async def get_tiktok_live_service():
    """
    Get the global TikTok Live service instance with lazy loading.
    If model tidak exist, akan di-load sekarang (lazy loading).
    """
    # Import the global instance from main.py
    import main
    
    if main.global_model_service is None:
        logger.info("🔥 Model belum di-load. Loading sekarang (lazy loading)...")
        logger.info("🔥 Loading AI model... Please wait 2-3 minutes...")
        
        try:
            # Import only when needed to avoid triggering model loading at import time
            from app.services.tiktok_live_service import TikTokLiveService
            
            main.global_model_service = TikTokLiveService()
            await main.global_model_service.initialize()
            
            # Verify model
            model_info = main.global_model_service.get_model_info()
            logger.info(f"✅ Model loaded successfully!")
            logger.info(f"📊 Model Info: {model_info}")
            
        except Exception as e:
            logger.error(f"❌ Failed to load model: {e}")
            main.global_model_service = None
            raise Exception(f"Failed to load model: {e}")
    
    if not main.global_model_service.is_initialized:
        logger.error("Model service exists but is not initialized")
        raise Exception("Model is not initialized yet. Please wait for model loading to complete.")
    
    logger.info("Returning initialized global model service")
    return main.global_model_service
