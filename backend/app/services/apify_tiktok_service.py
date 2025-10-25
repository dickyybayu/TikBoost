"""
🚀 APIFY TIKTOK SCRAPING SERVICE

This service uses Apify to scrape TikTok data since the official TikTok API 
has restrictions and requires approval.

Apify provides reliable scrapers for:
- Trending hashtags
- Viral videos  
- User profiles
- Comments and engagement data
"""

import asyncio
import logging
import json
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta
from apify_client import ApifyClient
from app.core.config import settings

logger = logging.getLogger(__name__)

class ApifyTikTokService:
    """
    Service for scraping TikTok data using Apify platform
    """
    
    def __init__(self):
        self.api_token = settings.APIFY_API_TOKEN
        self.tiktok_scraper_actor = settings.APIFY_TIKTOK_SCRAPER_ACTOR
        self.hashtag_scraper_actor = settings.APIFY_HASHTAG_SCRAPER_ACTOR
        self.max_results = settings.APIFY_MAX_RESULTS
        self.timeout = settings.APIFY_TIMEOUT_SECONDS
        self.enable_cache = settings.APIFY_ENABLE_CACHE
        self.cache_ttl = settings.APIFY_CACHE_TTL
        
        # Initialize Apify client
        self.client = None
        if self.api_token:
            self.client = ApifyClient(self.api_token)
        
        # Cache for scraped data
        self._cache = {}
        self._cache_timestamps = {}
        
        logger.info(f"ApifyTikTokService initialized with actor: {self.tiktok_scraper_actor}")
    
    async def get_trending_hashtags(self, 
                                  region: str = "ID", 
                                  limit: int = 10) -> List[Dict[str, Any]]:
        """
        Get trending hashtags from TikTok using Apify scraper
        
        Args:
            region: Region code (e.g., 'ID' for Indonesia)
            limit: Maximum number of hashtags to return
            
        Returns:
            List of trending hashtag data
        """
        cache_key = f"trending_hashtags_{region}_{limit}"
        
        # Check cache first
        if self._is_cache_valid(cache_key):
            logger.info(f"Using cached trending hashtags for region {region}")
            return self._cache[cache_key]
        
        try:
            if not self.client:
                logger.warning("Apify client not initialized - using fallback data")
                return self._get_fallback_hashtags()
            
            # Run TikTok hashtag scraper
            run_input = {
                "searchQueries": ["trending", "viral", "popular"],
                "resultsPerQuery": limit,
                "searchTypes": ["hashtag"],
                "region": region,
                "maxResults": limit
            }
            
            logger.info(f"Running Apify scraper for trending hashtags in {region}")
            
            # Run the actor
            run = self.client.actor(self.hashtag_scraper_actor).call(
                run_input=run_input,
                timeout_secs=self.timeout
            )
            
            # Get results
            dataset_items = self.client.dataset(run["defaultDatasetId"]).list_items().items
            
            # Process and format results
            trending_hashtags = []
            for item in dataset_items[:limit]:
                hashtag_data = {
                    "hashtag": item.get("hashtag", "").replace("#", ""),
                    "view_count": item.get("viewCount", 0),
                    "video_count": item.get("videoCount", 0),
                    "description": item.get("desc", ""),
                    "trending_score": self._calculate_trending_score(item),
                    "scraped_at": datetime.now().isoformat()
                }
                trending_hashtags.append(hashtag_data)
            
            # Sort by trending score
            trending_hashtags.sort(key=lambda x: x["trending_score"], reverse=True)
            
            # Cache the results
            self._cache_data(cache_key, trending_hashtags)
            
            logger.info(f"Successfully scraped {len(trending_hashtags)} trending hashtags")
            return trending_hashtags
            
        except Exception as e:
            logger.error(f"Error scraping trending hashtags: {str(e)}")
            return self._get_fallback_hashtags()
    
    async def get_viral_videos(self, 
                             hashtags: List[str] = None,
                             region: str = "ID",
                             limit: int = 10) -> List[Dict[str, Any]]:
        """
        Get viral videos from TikTok using Apify scraper
        
        Args:
            hashtags: List of hashtags to search for
            region: Region code
            limit: Maximum number of videos to return
            
        Returns:
            List of viral video data
        """
        cache_key = f"viral_videos_{region}_{'-'.join(hashtags or ['trending'])}_{limit}"
        
        # Check cache first
        if self._is_cache_valid(cache_key):
            logger.info(f"Using cached viral videos")
            return self._cache[cache_key]
        
        try:
            if not self.client:
                logger.warning("Apify client not initialized - using fallback data")
                return self._get_fallback_videos()
            
            # Prepare search queries
            search_queries = hashtags or ["trending", "viral", "populer"]
            
            run_input = {
                "searchQueries": search_queries,
                "resultsPerQuery": limit // len(search_queries) + 1,
                "searchTypes": ["video"],
                "region": region,
                "maxResults": limit
            }
            
            logger.info(f"Running Apify scraper for viral videos with hashtags: {search_queries}")
            
            # Run the actor
            run = self.client.actor(self.tiktok_scraper_actor).call(
                run_input=run_input,
                timeout_secs=self.timeout
            )
            
            # Get results
            dataset_items = self.client.dataset(run["defaultDatasetId"]).list_items().items
            
            # Process and format results
            viral_videos = []
            for item in dataset_items[:limit]:
                video_data = {
                    "video_id": item.get("id", ""),
                    "description": item.get("text", ""),
                    "author": item.get("authorMeta", {}).get("name", ""),
                    "view_count": item.get("statsV2", {}).get("playCount", 0),
                    "like_count": item.get("statsV2", {}).get("diggCount", 0),
                    "comment_count": item.get("statsV2", {}).get("commentCount", 0),
                    "share_count": item.get("statsV2", {}).get("shareCount", 0),
                    "hashtags": item.get("hashtags", []),
                    "music": item.get("musicMeta", {}).get("musicName", ""),
                    "viral_score": self._calculate_viral_score(item),
                    "scraped_at": datetime.now().isoformat()
                }
                viral_videos.append(video_data)
            
            # Sort by viral score
            viral_videos.sort(key=lambda x: x["viral_score"], reverse=True)
            
            # Cache the results
            self._cache_data(cache_key, viral_videos)
            
            logger.info(f"Successfully scraped {len(viral_videos)} viral videos")
            return viral_videos
            
        except Exception as e:
            logger.error(f"Error scraping viral videos: {str(e)}")
            return self._get_fallback_videos()
    
    async def get_trending_sounds(self, 
                                region: str = "ID",
                                limit: int = 10) -> List[Dict[str, Any]]:
        """
        Get trending sounds/music from TikTok
        """
        cache_key = f"trending_sounds_{region}_{limit}"
        
        if self._is_cache_valid(cache_key):
            return self._cache[cache_key]
        
        try:
            if not self.client:
                return self._get_fallback_sounds()
            
            # Use music-focused search
            run_input = {
                "searchQueries": ["trending music", "viral sound", "popular audio"],
                "resultsPerQuery": limit,
                "searchTypes": ["music"],
                "region": region,
                "maxResults": limit
            }
            
            run = self.client.actor(self.tiktok_scraper_actor).call(
                run_input=run_input,
                timeout_secs=self.timeout
            )
            
            dataset_items = self.client.dataset(run["defaultDatasetId"]).list_items().items
            
            trending_sounds = []
            for item in dataset_items[:limit]:
                sound_data = {
                    "sound_id": item.get("musicMeta", {}).get("musicId", ""),
                    "title": item.get("musicMeta", {}).get("musicName", ""),
                    "author": item.get("musicMeta", {}).get("musicAuthor", ""),
                    "usage_count": item.get("musicMeta", {}).get("playCount", 0),
                    "duration": item.get("musicMeta", {}).get("duration", 0),
                    "trending_score": self._calculate_sound_trending_score(item),
                    "scraped_at": datetime.now().isoformat()
                }
                trending_sounds.append(sound_data)
            
            trending_sounds.sort(key=lambda x: x["trending_score"], reverse=True)
            self._cache_data(cache_key, trending_sounds)
            
            return trending_sounds
            
        except Exception as e:
            logger.error(f"Error scraping trending sounds: {str(e)}")
            return self._get_fallback_sounds()
    
    async def get_content_insights(self, 
                                 category: str = "general",
                                 region: str = "ID") -> Dict[str, Any]:
        """
        Get comprehensive content insights by analyzing trending videos
        """
        cache_key = f"content_insights_{category}_{region}"
        
        if self._is_cache_valid(cache_key):
            return self._cache[cache_key]
        
        try:
            # Get trending hashtags and videos
            hashtags = await self.get_trending_hashtags(region=region, limit=5)
            videos = await self.get_viral_videos(region=region, limit=20)
            
            # Analyze content patterns
            insights = {
                "trending_keywords": [tag["hashtag"] for tag in hashtags[:5]],
                "viral_content_types": self._analyze_content_types(videos),
                "popular_music_trends": self._analyze_music_trends(videos),
                "engagement_patterns": self._analyze_engagement_patterns(videos),
                "optimal_posting_times": self._analyze_posting_times(videos),
                "content_length_trends": self._analyze_video_lengths(videos),
                "hashtag_performance": self._analyze_hashtag_performance(videos),
                "region": region,
                "category": category,
                "generated_at": datetime.now().isoformat()
            }
            
            self._cache_data(cache_key, insights)
            return insights
            
        except Exception as e:
            logger.error(f"Error generating content insights: {str(e)}")
            return self._get_fallback_insights()
    
    # Helper methods for data processing
    def _calculate_trending_score(self, item: Dict) -> float:
        """Calculate trending score for hashtags"""
        view_count = item.get("viewCount", 0)
        video_count = item.get("videoCount", 0)
        
        # Simple scoring algorithm
        score = (view_count * 0.7) + (video_count * 0.3)
        return score / 1000000  # Normalize
    
    def _calculate_viral_score(self, item: Dict) -> float:
        """Calculate viral score for videos"""
        stats = item.get("statsV2", {})
        play_count = stats.get("playCount", 0)
        like_count = stats.get("diggCount", 0)
        comment_count = stats.get("commentCount", 0)
        share_count = stats.get("shareCount", 0)
        
        # Weighted viral score
        score = (play_count * 0.4) + (like_count * 0.3) + (comment_count * 0.2) + (share_count * 0.1)
        return score / 1000000  # Normalize
    
    def _calculate_sound_trending_score(self, item: Dict) -> float:
        """Calculate trending score for sounds"""
        music_meta = item.get("musicMeta", {})
        play_count = music_meta.get("playCount", 0)
        return play_count / 1000000
    
    def _analyze_content_types(self, videos: List[Dict]) -> List[str]:
        """Analyze popular content types from video descriptions"""
        content_types = []
        for video in videos:
            desc = video.get("description", "").lower()
            if "tutorial" in desc or "cara" in desc:
                content_types.append("tutorial")
            elif "review" in desc or "unboxing" in desc:
                content_types.append("review")
            elif "dance" in desc or "tari" in desc:
                content_types.append("dance")
            elif "comedy" in desc or "lucu" in desc:
                content_types.append("comedy")
            else:
                content_types.append("lifestyle")
        
        # Return most common types
        from collections import Counter
        return [item[0] for item in Counter(content_types).most_common(5)]
    
    def _analyze_music_trends(self, videos: List[Dict]) -> List[str]:
        """Analyze trending music from videos"""
        music_names = []
        for video in videos:
            music = video.get("music", "")
            if music and music != "":
                music_names.append(music)
        
        from collections import Counter
        return [item[0] for item in Counter(music_names).most_common(5)]
    
    def _analyze_engagement_patterns(self, videos: List[Dict]) -> Dict[str, float]:
        """Analyze engagement patterns"""
        if not videos:
            return {"avg_like_rate": 0, "avg_comment_rate": 0, "avg_share_rate": 0}
        
        total_views = sum(video.get("view_count", 0) for video in videos)
        total_likes = sum(video.get("like_count", 0) for video in videos)
        total_comments = sum(video.get("comment_count", 0) for video in videos)
        total_shares = sum(video.get("share_count", 0) for video in videos)
        
        return {
            "avg_like_rate": (total_likes / total_views) if total_views > 0 else 0,
            "avg_comment_rate": (total_comments / total_views) if total_views > 0 else 0,
            "avg_share_rate": (total_shares / total_views) if total_views > 0 else 0
        }
    
    def _analyze_posting_times(self, videos: List[Dict]) -> List[str]:
        """Analyze optimal posting times (placeholder)"""
        return ["19:00-21:00", "12:00-14:00", "20:00-22:00"]
    
    def _analyze_video_lengths(self, videos: List[Dict]) -> Dict[str, Any]:
        """Analyze trending video lengths (placeholder)"""
        return {
            "optimal_length": "15-30 seconds",
            "trending_range": "10-60 seconds",
            "max_engagement_length": "20 seconds"
        }
    
    def _analyze_hashtag_performance(self, videos: List[Dict]) -> List[Dict[str, Any]]:
        """Analyze hashtag performance"""
        hashtag_stats = {}
        
        for video in videos:
            hashtags = video.get("hashtags", [])
            view_count = video.get("view_count", 0)
            
            for hashtag in hashtags:
                if hashtag not in hashtag_stats:
                    hashtag_stats[hashtag] = {"count": 0, "total_views": 0}
                
                hashtag_stats[hashtag]["count"] += 1
                hashtag_stats[hashtag]["total_views"] += view_count
        
        # Calculate average views per hashtag
        performance = []
        for hashtag, stats in hashtag_stats.items():
            avg_views = stats["total_views"] / stats["count"] if stats["count"] > 0 else 0
            performance.append({
                "hashtag": hashtag,
                "usage_count": stats["count"],
                "avg_views": avg_views,
                "performance_score": avg_views * stats["count"]
            })
        
        return sorted(performance, key=lambda x: x["performance_score"], reverse=True)[:10]
    
    # Cache management methods
    def _is_cache_valid(self, cache_key: str) -> bool:
        """Check if cached data is still valid"""
        if not self.enable_cache:
            return False
        
        if cache_key not in self._cache:
            return False
        
        timestamp = self._cache_timestamps.get(cache_key)
        if not timestamp:
            return False
        
        return (datetime.now() - timestamp).total_seconds() < self.cache_ttl
    
    def _cache_data(self, cache_key: str, data: Any):
        """Cache data with timestamp"""
        if self.enable_cache:
            self._cache[cache_key] = data
            self._cache_timestamps[cache_key] = datetime.now()
    
    # Fallback methods when Apify is not available
    def _get_fallback_hashtags(self) -> List[Dict[str, Any]]:
        """Fallback trending hashtags"""
        return [
            {"hashtag": "viral", "view_count": 1000000, "trending_score": 5.0},
            {"hashtag": "trending", "view_count": 800000, "trending_score": 4.5},
            {"hashtag": "fyp", "view_count": 1200000, "trending_score": 4.8},
            {"hashtag": "indonesiaviral", "view_count": 600000, "trending_score": 4.2},
            {"hashtag": "tiktokindo", "view_count": 700000, "trending_score": 4.3}
        ]
    
    def _get_fallback_videos(self) -> List[Dict[str, Any]]:
        """Fallback viral videos"""
        return [
            {
                "video_id": "fallback1",
                "description": "Tutorial makeup natural untuk pemula",
                "view_count": 500000,
                "like_count": 50000,
                "hashtags": ["makeup", "tutorial", "beauty"],
                "viral_score": 4.5
            }
        ]
    
    def _get_fallback_sounds(self) -> List[Dict[str, Any]]:
        """Fallback trending sounds"""
        return [
            {"sound_id": "sound1", "title": "Trending Sound 1", "usage_count": 100000},
            {"sound_id": "sound2", "title": "Viral Audio", "usage_count": 80000}
        ]
    
    def _get_fallback_insights(self) -> Dict[str, Any]:
        """Fallback content insights"""
        return {
            "trending_keywords": ["viral", "trending", "populer"],
            "viral_content_types": ["tutorial", "comedy", "lifestyle"],
            "engagement_patterns": {"avg_like_rate": 0.05, "avg_comment_rate": 0.01}
        }

# Create singleton instance
apify_tiktok_service = ApifyTikTokService()
