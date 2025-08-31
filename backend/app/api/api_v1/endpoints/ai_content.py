from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime

from app import schemas
from app.core.database import get_db
from app.core.config import settings
from app.services.user_service import user_service
from app.services.ai_content_service import ai_content_service

router = APIRouter()

@router.get("/model-status")
def get_model_status(
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get AI model status and configuration
    """
    return ai_content_service.get_model_status()

@router.post("/reload-model")
def reload_model(
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Reload the AI model (admin only)
    """
    ai_content_service.reload_model()
    return {"message": "Model reloaded successfully", "status": ai_content_service.get_model_status()}

@router.post("/generate", response_model=schemas.AIContent)
def generate_ai_content(
    *,
    db: Session = Depends(get_db),
    content_request: schemas.AIContentRequest,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate AI content based on user request
    """
    content = ai_content_service.generate_content(
        db, user_id=current_user.id, request=content_request
    )
    return content

@router.get("/", response_model=List[schemas.AIContent])
def read_ai_content(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 20,
    content_type: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Retrieve user's AI generated content
    """
    content = ai_content_service.get_user_content(
        db, 
        user_id=current_user.id, 
        content_type=content_type,
        skip=skip, 
        limit=limit
    )
    return content

@router.get("/suggestions/{content_type}")
def get_content_suggestions(
    *,
    db: Session = Depends(get_db),
    content_type: str,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get content suggestions for specific content type
    """
    if content_type not in ["copywriting", "script", "description"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid content type"
        )
    
    suggestions = ai_content_service.suggest_content_ideas(
        db, user_id=current_user.id, content_type=content_type
    )
    return {"suggestions": suggestions}

@router.post("/{content_id}/favorite", response_model=schemas.AIContent)
def toggle_favorite_content(
    *,
    db: Session = Depends(get_db),
    content_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Toggle favorite status of AI content
    """
    content = ai_content_service.toggle_favorite(
        db, content_id=content_id, user_id=current_user.id
    )
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI content not found"
        )
    return content

@router.post("/{content_id}/use", response_model=schemas.AIContent)
def use_ai_content(
    *,
    db: Session = Depends(get_db),
    content_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Mark AI content as used (increment usage count)
    """
    content = ai_content_service.increment_usage(
        db, content_id=content_id, user_id=current_user.id
    )
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI content not found"
        )
    return content

# Specific content generation endpoints
@router.post("/copywriting", response_model=schemas.AIContent)
def generate_copywriting(
    *,
    db: Session = Depends(get_db),
    prompt: str,
    context: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate copywriting content
    """
    request = schemas.AIContentRequest(
        content_type="copywriting",
        prompt=prompt,
        context=context
    )
    content = ai_content_service.generate_content(
        db, user_id=current_user.id, request=request
    )
    return content

@router.post("/script", response_model=schemas.AIContent)
def generate_script(
    *,
    db: Session = Depends(get_db),
    prompt: str,
    context: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate live session script
    """
    request = schemas.AIContentRequest(
        content_type="script",
        prompt=prompt,
        context=context
    )
    content = ai_content_service.generate_content(
        db, user_id=current_user.id, request=request
    )
    return content

@router.post("/description", response_model=schemas.AIContent)
def generate_description(
    *,
    db: Session = Depends(get_db),
    prompt: str,
    context: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate product description
    """
    request = schemas.AIContentRequest(
        content_type="description",
        prompt=prompt,
        context=context
    )
    content = ai_content_service.generate_content(
        db, user_id=current_user.id, request=request
    )
    return content

@router.post("/generate-live-commerce")
async def generate_live_commerce_content(
    *,
    db: Session = Depends(get_db),
    product_name: str,
    product_price: str = None,
    stock_count: int = None,
    viewer_count: int = None,
    event_context: str = None,
    seller_id: str = None,
    product_category: str = None,
    enable_real_time_data: bool = True,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate live commerce content using your fine-tuned model with REAL-TIME DATA (Option 2: 4-line format)
    
    🆕 NEW: Now includes real-time data integration:
    - Current trending keywords and hashtags
    - Market performance insights 
    - Seller performance metrics
    - Audience behavior data
    - Competitor analysis
    - Live stats (viewers, purchases, etc.)
    
    Returns all 4 sections: COPY, HOST, TIME, BUNDLE with dynamic recommendations
    """
    try:
        # Pass seller info for real-time data collection
        result = await ai_content_service.generate_finetuned_content(
            db,
            user_id=current_user.id,
            product_name=product_name,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context,
            seller_id=seller_id or str(current_user.id),  # Use current user as seller if not provided
            product_category=product_category
        )
        
        # Add real-time context info to response
        result["real_time_enhanced"] = enable_real_time_data
        result["data_sources"] = [
            "trending_keywords", "market_insights", "performance_metrics",
            "audience_data", "competitor_analysis", "real_time_stats"
        ]
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate content with real-time data: {str(e)}"
        )

@router.post("/generate-specific-section")
async def generate_specific_section(
    *,
    db: Session = Depends(get_db),
    product_name: str,
    section_type: str,  # "COPY", "HOST", "TIME", or "BUNDLE"
    product_price: str = None,
    stock_count: int = None,
    viewer_count: int = None,
    event_context: str = None,
    seller_id: str = None,
    product_category: str = None,
    use_cache: bool = True,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Extract only a specific section from your fine-tuned model with REAL-TIME DATA (Option 2 approach)
    
    🆕 NEW: Now includes real-time data for dynamic recommendations:
    - Uses current market trends and user behavior
    - Adapts content based on live performance metrics
    - Incorporates competitor insights and trending phrases
    
    This generates all 4 lines but returns only the requested section
    Uses caching for efficiency when multiple sections are needed
    """
    if section_type not in ["COPY", "HOST", "TIME", "BUNDLE"]:
        raise HTTPException(
            status_code=400,
            detail="section_type must be one of: COPY, HOST, TIME, BUNDLE"
        )
    
    try:
        content = await ai_content_service.extract_specific_section_finetuned(
            product_name=product_name,
            section_type=section_type,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context,
            seller_id=seller_id or str(current_user.id),
            product_category=product_category,
            db=db,
            use_cache=use_cache
        )
        
        return {
            "section_type": section_type,
            "product_name": product_name,
            "content": content,
            "used_cache": use_cache,
            "real_time_enhanced": True,
            "generation_strategy": "option_2_parsing_with_real_time_data"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate section with real-time data: {str(e)}"
        )

@router.get("/available-sections")
def get_available_sections_finetuned(
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get available sections for your fine-tuned model
    """
    return {
        "available_sections": {
            "COPY": "Copywriting content - engaging sales text and promotional content",
            "HOST": "Host script - what the live streamer should say during the session", 
            "TIME": "Timing suggestions - optimal duration and timing for the live session",
            "BUNDLE": "Bundle recommendations - product bundles and promotional packages"
        },
        "total_sections": 4,
        "model_format": "4-line Indonesian live commerce",
        "generation_strategy": "option_2_parsing"
    }

@router.post("/test-finetuned-format")
async def test_finetuned_format(
    *,
    db: Session = Depends(get_db),
    product_name: str = "Test Product",
    test_real_time_data: bool = True,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Test your fine-tuned model with a sample product to verify format compatibility
    🆕 NEW: Now includes real-time data testing
    """
    # Test the prompt formatting
    formatted_prompt = ai_content_service._format_prompt_for_finetuned_model(
        product_name=product_name,
        product_price="Rp 299.000",
        stock_count=50,
        viewer_count=250,
        event_context="Flash Sale Special"
    )
    
    result = {
        "test_product": product_name,
        "formatted_prompt": formatted_prompt,
        "expected_format": "4 lines: COPY, HOST, TIME, BUNDLE",
        "model_status": ai_content_service.get_model_status()
    }
    
    # Test real-time data collection if requested
    if test_real_time_data:
        try:
            real_time_context = await ai_content_service._collect_real_time_context(
                product_name=product_name,
                seller_id=str(current_user.id),
                product_category="test_category",
                db=db
            )
            result["real_time_data_test"] = {
                "status": "success",
                "data_collected": list(real_time_context.keys()),
                "trending_keywords": real_time_context.get("current_trends", [])[:3],
                "market_demand": real_time_context.get("market_data", {}).get("current_demand"),
                "cache_ttl": ai_content_service._context_cache_ttl
            }
        except Exception as e:
            result["real_time_data_test"] = {
                "status": "error",
                "error": str(e)
            }
    
    return result

@router.get("/real-time-context-status")
async def get_real_time_context_status(
    *,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get the status and configuration of the real-time data system including TikTok API integration
    """
    return {
        "real_time_enabled": ai_content_service.enable_dynamic_context,
        "context_cache_size": len(ai_content_service._context_cache),
        "context_cache_ttl_seconds": ai_content_service._context_cache_ttl,
        "data_sources": [
            "tiktok_api_trending_hashtags",
            "tiktok_api_viral_content_analysis", 
            "tiktok_api_audience_insights",
            "internal_trending_keywords",
            "internal_market_insights",
            "internal_performance_metrics", 
            "internal_audience_insights",
            "internal_real_time_stats"
        ],
        "tiktok_api_configured": {
            "research_api": hasattr(settings, 'TIKTOK_RESEARCH_API_TOKEN') and settings.TIKTOK_RESEARCH_API_TOKEN is not None,
            "creator_api": hasattr(settings, 'TIKTOK_CREATOR_API_TOKEN') and settings.TIKTOK_CREATOR_API_TOKEN is not None,
            "ads_api": hasattr(settings, 'TIKTOK_ADS_API_TOKEN') and settings.TIKTOK_ADS_API_TOKEN is not None,
            "default_region": getattr(settings, 'TIKTOK_DEFAULT_REGION', 'ID')
        },
        "cache_keys": list(ai_content_service._context_cache.keys()),
        "status": "active_with_tiktok_api" if ai_content_service.enable_dynamic_context else "disabled"
    }

@router.get("/tiktok-trending-data")
async def get_tiktok_trending_data(
    *,
    region_code: str = "ID",
    limit: int = 20,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    🔥 NEW: Get current trending data directly from TikTok API
    
    This endpoint fetches the latest trending hashtags and content from TikTok
    to show what's viral RIGHT NOW on the platform.
    """
    from app.services.tiktok_api_service import tiktok_api_service
    
    try:
        # Get trending hashtags from TikTok API
        trending_hashtags = await tiktok_api_service.get_trending_hashtags(
            region_code=region_code,
            limit=limit
        )
        
        # Get viral content analysis
        viral_analysis = await tiktok_api_service.get_viral_content_analysis(
            category="commerce"
        )
        
        return {
            "region": region_code,
            "trending_hashtags": trending_hashtags,
            "viral_analysis": {
                "viral_keywords": viral_analysis.get('viral_keywords', [])[:10],
                "successful_formats": viral_analysis.get('successful_formats', []),
                "viral_phrases": viral_analysis.get('viral_phrases', [])[:8],
                "engagement_patterns": viral_analysis.get('engagement_patterns', {}),
                "content_themes": viral_analysis.get('content_themes', [])
            },
            "data_freshness": "live_from_tiktok_api",
            "timestamp": datetime.now().isoformat(),
            "total_hashtags": len(trending_hashtags),
            "api_status": "success"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch TikTok trending data: {str(e)}"
        )

@router.post("/generate-with-tiktok-trends")  
async def generate_content_with_tiktok_trends(
    *,
    db: Session = Depends(get_db),
    product_name: str,
    product_price: str = None,
    product_category: str = None,
    region_code: str = "ID",
    include_tiktok_hashtags: bool = True,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    🚀 ADVANCED: Generate content using LIVE TikTok trending data
    
    This endpoint combines your fine-tuned model with real-time TikTok API data
    to create content that's aligned with what's viral RIGHT NOW on TikTok!
    
    Features:
    - Live trending hashtags from TikTok
    - Viral keywords and phrases currently popular
    - Content formats that are performing well
    - Real-time audience insights
    """
    from app.services.tiktok_api_service import tiktok_api_service
    
    try:
        # Generate content with TikTok data integration
        result = await ai_content_service.generate_finetuned_content(
            db,
            user_id=current_user.id,
            product_name=product_name,
            product_price=product_price,
            seller_id=str(current_user.id),
            product_category=product_category
        )
        
        # Add TikTok trending data to the response for transparency
        if include_tiktok_hashtags:
            tiktok_hashtags = await tiktok_api_service.get_trending_hashtags(
                region_code=region_code,
                limit=15
            )
            
            result["tiktok_enhancement"] = {
                "trending_hashtags": [h.get('name', '') for h in tiktok_hashtags[:8]],
                "recommended_hashtags": f"#{', #'.join([h.get('name', '') for h in tiktok_hashtags[:5]])}",
                "region": region_code,
                "data_source": "live_tiktok_api"
            }
        
        result["generation_method"] = "fine_tuned_model_with_tiktok_api_data"
        result["content_freshness"] = "enhanced_with_live_tiktok_trends"
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate content with TikTok trends: {str(e)}"
        )

@router.get("/sections/{content_type}")
def get_available_sections(
    content_type: str,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get available sections for a content type
    """
    sections = ai_content_service.get_available_sections(content_type)
    if not sections:
        raise HTTPException(
            status_code=404,
            detail=f"No sections available for content type: {content_type}"
        )
    return {
        "content_type": content_type,
        "available_sections": sections,
        "total_sections": len(sections)
    }

@router.post("/generate-sections")
def generate_sectioned_content(
    *,
    db: Session = Depends(get_db),
    section_request: schemas.SectionRequest,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate content with specific sections
    """
    result = ai_content_service.generate_sectioned_content(
        db, user_id=current_user.id, request=section_request
    )
    return result

@router.post("/generate-custom-sections")
def generate_custom_sections(
    *,
    db: Session = Depends(get_db),
    content_type: str,
    base_prompt: str,
    custom_sections: dict,  # {section_name: section_description}
    context: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Generate content with custom-defined sections
    """
    result = ai_content_service.generate_custom_sections(
        db,
        user_id=current_user.id,
        content_type=content_type,
        base_prompt=base_prompt,
        custom_sections=custom_sections,
        context=context
    )
    return result

@router.post("/regenerate-section")
def regenerate_specific_section(
    *,
    db: Session = Depends(get_db),
    content_type: str,
    section_name: str,
    base_prompt: str,
    context: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Regenerate a specific section only
    """
    # Get section description
    available_sections = ai_content_service.get_available_sections(content_type)
    if section_name not in available_sections:
        raise HTTPException(
            status_code=400,
            detail=f"Section '{section_name}' not available for {content_type}"
        )
    
    section_content = ai_content_service._generate_section(
        content_type=content_type,
        section_name=section_name,
        section_description=available_sections[section_name],
        base_prompt=base_prompt,
        context=context
    )
    
    return {
        "section_name": section_name,
        "section_type": section_name,
        "content": section_content,
        "content_type": content_type,
        "base_prompt": base_prompt
    }

# ===============================================================================
# 🚀 NEW APIFY TIKTOK INTEGRATION ENDPOINTS
# ===============================================================================

@router.get("/apify-status")
async def get_apify_status(
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get the status of Apify TikTok integration
    """
    from app.services.apify_tiktok_service import apify_tiktok_service
    
    return {
        "apify_integration": {
            "enabled": apify_tiktok_service.client is not None,
            "api_token_configured": apify_tiktok_service.api_token is not None,
            "scraper_actor": apify_tiktok_service.tiktok_scraper_actor,
            "hashtag_actor": apify_tiktok_service.hashtag_scraper_actor,
            "max_results": apify_tiktok_service.max_results,
            "timeout": apify_tiktok_service.timeout,
            "cache_enabled": apify_tiktok_service.enable_cache,
            "cache_ttl": apify_tiktok_service.cache_ttl,
            "cache_size": len(apify_tiktok_service._cache)
        },
        "real_time_data": {
            "enabled": ai_content_service.enable_dynamic_context,
            "context_cache_size": len(ai_content_service._context_cache),
            "context_cache_ttl": ai_content_service._context_cache_ttl
        }
    }

@router.get("/tiktok-trending")
async def get_tiktok_trending_data(
    *,
    category: str = "general",
    region: str = "ID", 
    limit: int = 10,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    🔥 Get current TikTok trending data via Apify scraping
    
    This endpoint provides real-time TikTok data including:
    - Trending hashtags
    - Viral videos for the category
    - Content insights and patterns
    """
    from app.services.apify_tiktok_service import apify_tiktok_service
    
    try:
        # Get trending hashtags
        hashtags = await apify_tiktok_service.get_trending_hashtags(
            region=region, 
            limit=limit
        )
        
        # Get viral videos for the category
        category_hashtags = ai_content_service._get_category_hashtags(category)
        viral_videos = await apify_tiktok_service.get_viral_videos(
            hashtags=category_hashtags,
            region=region,
            limit=limit//2
        )
        
        # Get content insights
        content_insights = await apify_tiktok_service.get_content_insights(
            category=category,
            region=region
        )
        
        return {
            "trending_hashtags": hashtags,
            "viral_videos": viral_videos,
            "content_insights": content_insights,
            "category": category,
            "region": region,
            "scraped_at": content_insights.get("generated_at"),
            "data_source": "apify_tiktok_scraper",
            "recommendations": {
                "top_hashtags": [h.get("hashtag") for h in hashtags[:5]],
                "trending_keywords": content_insights.get("trending_keywords", [])[:5],
                "viral_content_types": content_insights.get("viral_content_types", [])
            }
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch TikTok trending data: {str(e)}"
        )

@router.post("/test-apify-enhanced-generation")
async def test_apify_enhanced_generation(
    *,
    db: Session = Depends(get_db),
    product_name: str = "Serum Anti Aging Premium",
    product_category: str = "beauty",
    compare_with_static: bool = True,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    🧪 Test content generation with Apify TikTok data vs static content
    
    This shows the difference between:
    1. Static content (based only on training data)
    2. Enhanced content (with real-time TikTok trends from Apify)
    """
    try:
        results = {
            "test_product": product_name,
            "test_category": product_category,
            "timestamp": datetime.now().isoformat()
        }
        
        # Generate enhanced content with Apify TikTok data
        enhanced_content = await ai_content_service.generate_finetuned_content(
            db=db,
            user_id=current_user.id,
            product_name=product_name,
            product_category=product_category,
            seller_id=str(current_user.id)
        )
        
        results["enhanced_content"] = {
            "copy": enhanced_content.get("parsed_sections", {}).get("COPY", ""),
            "host": enhanced_content.get("parsed_sections", {}).get("HOST", ""),
            "time": enhanced_content.get("parsed_sections", {}).get("TIME", ""),
            "bundle": enhanced_content.get("parsed_sections", {}).get("BUNDLE", ""),
            "data_sources": enhanced_content.get("data_sources", []),
            "real_time_enhanced": enhanced_content.get("real_time_enhanced", False)
        }
        
        # Show what TikTok data was used
        from app.services.apify_tiktok_service import apify_tiktok_service
        tiktok_data = {
            "trending_hashtags": [],
            "viral_keywords": [],
            "content_types": []
        }
        
        try:
            hashtags = await apify_tiktok_service.get_trending_hashtags(limit=5)
            tiktok_data["trending_hashtags"] = [h.get("hashtag") for h in hashtags]
            
            insights = await apify_tiktok_service.get_content_insights(category=product_category)
            tiktok_data["viral_keywords"] = insights.get("trending_keywords", [])[:5]
            tiktok_data["content_types"] = insights.get("viral_content_types", [])
        except Exception as e:
            tiktok_data["error"] = str(e)
        
        results["tiktok_data_used"] = tiktok_data
        
        # Compare with static content if requested
        if compare_with_static:
            # Temporarily disable real-time context
            original_setting = ai_content_service.enable_dynamic_context
            ai_content_service.enable_dynamic_context = False
            
            try:
                static_content = await ai_content_service.generate_finetuned_content(
                    db=db,
                    user_id=current_user.id,
                    product_name=product_name,
                    product_category=product_category,
                    seller_id=str(current_user.id)
                )
                
                results["static_content"] = {
                    "copy": static_content.get("parsed_sections", {}).get("COPY", ""),
                    "host": static_content.get("parsed_sections", {}).get("HOST", ""), 
                    "time": static_content.get("parsed_sections", {}).get("TIME", ""),
                    "bundle": static_content.get("parsed_sections", {}).get("BUNDLE", ""),
                    "data_sources": ["training_data_only"]
                }
                
                # Analyze improvements
                results["improvements"] = _analyze_content_improvements(
                    static_content.get("parsed_sections", {}),
                    enhanced_content.get("parsed_sections", {}),
                    tiktok_data
                )
                
            finally:
                # Restore original setting
                ai_content_service.enable_dynamic_context = original_setting
        
        return results
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Test failed: {str(e)}"
        )

def _analyze_content_improvements(static_sections: Dict, enhanced_sections: Dict, tiktok_data: Dict) -> Dict[str, Any]:
    """Analyze improvements in enhanced content vs static content"""
    improvements = {
        "tiktok_keywords_added": [],
        "trending_hashtags_included": [],
        "viral_patterns_detected": [],
        "content_length_changes": {},
        "overall_assessment": ""
    }
    
    # Check for TikTok keywords in enhanced content
    tiktok_keywords = tiktok_data.get("viral_keywords", [])
    for section_name, enhanced_text in enhanced_sections.items():
        static_text = static_sections.get(section_name, "")
        
        # Check for new keywords
        for keyword in tiktok_keywords:
            if keyword.lower() in enhanced_text.lower() and keyword.lower() not in static_text.lower():
                improvements["tiktok_keywords_added"].append(f"{keyword} in {section_name}")
        
        # Check length changes
        improvements["content_length_changes"][section_name] = {
            "static_length": len(static_text),
            "enhanced_length": len(enhanced_text),
            "change": len(enhanced_text) - len(static_text)
        }
    
    # Check for hashtag inclusion
    trending_hashtags = tiktok_data.get("trending_hashtags", [])
    enhanced_full_text = " ".join(enhanced_sections.values()).lower()
    for hashtag in trending_hashtags:
        if hashtag.lower() in enhanced_full_text:
            improvements["trending_hashtags_included"].append(hashtag)
    
    # Overall assessment
    total_improvements = (
        len(improvements["tiktok_keywords_added"]) + 
        len(improvements["trending_hashtags_included"])
    )
    
    if total_improvements > 3:
        improvements["overall_assessment"] = "Significant enhancement with current TikTok trends"
    elif total_improvements > 1:
        improvements["overall_assessment"] = "Moderate enhancement with trending data"
    else:
        improvements["overall_assessment"] = "Minimal enhancement - check Apify data availability"
    
    return improvements
