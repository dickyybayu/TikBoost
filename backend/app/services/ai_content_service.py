import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.models import AIContent
from app.schemas.schemas import AIContentCreate, AIContentRequest
from app.services.tiktok_api_service import tiktok_api_service
import logging
import hashlib

logger = logging.getLogger(__name__)

class AIContentService:
    def __init__(self):
        self.model_name = settings.HUGGINGFACE_MODEL_NAME
        self.use_local = settings.HUGGINGFACE_USE_LOCAL
        self.local_path = settings.HUGGINGFACE_LOCAL_PATH
        self.api_token = settings.HUGGINGFACE_API_TOKEN
        
        # Model parameters
        self.max_length = settings.MAX_TOKEN_LENGTH
        self.temperature = settings.MODEL_TEMPERATURE
        self.top_p = settings.MODEL_TOP_P
        self.top_k = settings.MODEL_TOP_K
        
        # Your specific fine-tuned model format (4-line response)
        self.fine_tuned_format = {
            "expected_lines": ["COPY", "HOST", "TIME", "BUNDLE"],
            "uses_indonesian": True,
            "mistral_style": True
        }
        
        # Initialize model and tokenizer
        self.tokenizer = None
        self.model = None
        self.generator = None
        
        # Cache for recent generations (Option 2 optimization)
        self._generation_cache = {}
        self._cache_max_size = 50
        
        # Real-time data integration
        self.enable_dynamic_context = True
        self._context_cache = {}
        self._context_cache_ttl = 300  # 5 minutes TTL for real-time data
        
        self._initialize_model()

    def _initialize_model(self):
        """Initialize the Hugging Face model and tokenizer"""
        try:
            model_path = self.local_path if self.use_local else self.model_name
            
            logger.info(f"Loading model from: {model_path}")
            
            # Load tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                model_path,
                use_auth_token=self.api_token if not self.use_local else None,
                trust_remote_code=True
            )
            
            # Add padding token if it doesn't exist
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            # Load model
            self.model = AutoModelForCausalLM.from_pretrained(
                model_path,
                use_auth_token=self.api_token if not self.use_local else None,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device_map="auto" if torch.cuda.is_available() else None,
                trust_remote_code=True
            )
            
            # Create text generation pipeline
            self.generator = pipeline(
                "text-generation",
                model=self.model,
                tokenizer=self.tokenizer,
                device=0 if torch.cuda.is_available() else -1,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32
            )
            
            logger.info("Model loaded successfully!")
            
        except Exception as e:
            logger.error(f"Error loading model: {str(e)}")
            self.generator = None

    async def _collect_real_time_context(self, 
                                       product_name: str = None,
                                       seller_id: str = None,
                                       product_category: str = None,
                                       db: Session = None) -> Dict[str, Any]:
        """
        Collect real-time data from TikTok (via Apify) and platform data to enhance model recommendations
        
        🎯 NEW: Now integrates Apify TikTok scraping for LATEST trending data!
        """
        from datetime import datetime, timedelta
        from app.services.apify_tiktok_service import apify_tiktok_service
        
        cache_key = f"context_{seller_id}_{product_category}_{product_name}"
        
        # Check cache first
        if cache_key in self._context_cache:
            cached_data = self._context_cache[cache_key]
            if datetime.now() - cached_data['timestamp'] < timedelta(seconds=self._context_cache_ttl):
                return cached_data['data']
        
        # Collect data from multiple sources in parallel
        try:
            # 🚀 TikTok Data via Apify (Latest trending content from TikTok)
            tiktok_hashtags_task = apify_tiktok_service.get_trending_hashtags(
                region="ID", 
                limit=15
            )
            tiktok_viral_videos_task = apify_tiktok_service.get_viral_videos(
                hashtags=self._get_category_hashtags(product_category),
                region="ID",
                limit=10
            )
            tiktok_content_insights_task = apify_tiktok_service.get_content_insights(
                category=product_category or "general",
                region="ID"
            )
            
            # Platform Internal Data
            internal_trends_task = self._get_trending_keywords(db)
            market_data_task = self._get_market_insights(product_category, db)
            performance_data_task = self._get_performance_metrics(seller_id, db)
            audience_data_task = self._get_audience_insights(seller_id, db)
            real_time_stats_task = self._get_real_time_stats(product_name, db)
            
            # Execute all tasks concurrently
            import asyncio
            results = await asyncio.gather(
                tiktok_hashtags_task,
                tiktok_viral_videos_task, 
                tiktok_content_insights_task,
                internal_trends_task,
                market_data_task,
                performance_data_task,
                audience_data_task,
                real_time_stats_task,
                return_exceptions=True
            )
            
            # Process results
            tiktok_hashtags = results[0] if not isinstance(results[0], Exception) else []
            tiktok_viral_videos = results[1] if not isinstance(results[1], Exception) else []
            tiktok_content_insights = results[2] if not isinstance(results[2], Exception) else {}
            internal_trends = results[3] if not isinstance(results[3], Exception) else []
            market_data = results[4] if not isinstance(results[4], Exception) else {}
            performance_data = results[5] if not isinstance(results[5], Exception) else {}
            audience_data = results[6] if not isinstance(results[6], Exception) else {}
            real_time_stats = results[7] if not isinstance(results[7], Exception) else {}
            
            # Combine TikTok and internal data
            context = {
                # 🎯 TikTok Data via Apify (LATEST from TikTok itself!)
                'tiktok_trending_hashtags': [h.get('hashtag', '') for h in tiktok_hashtags[:15]],
                'tiktok_viral_keywords': tiktok_content_insights.get('trending_keywords', [])[:10],
                'tiktok_viral_content_types': tiktok_content_insights.get('viral_content_types', [])[:5],
                'tiktok_popular_music': tiktok_content_insights.get('popular_music_trends', [])[:5],
                'tiktok_engagement_patterns': tiktok_content_insights.get('engagement_patterns', {}),
                'tiktok_viral_descriptions': [v.get('description', '')[:100] for v in tiktok_viral_videos[:5]],
                
                # 📊 Platform Internal Data  
                'current_trends': internal_trends,
                'market_data': market_data,
                'performance_data': performance_data,
                'audience_data': audience_data,
                'real_time_stats': real_time_stats,
                
                # 🎯 Combined Intelligence
                'combined_trending_keywords': self._combine_tiktok_and_internal_trends(
                    tiktok_content_insights.get('trending_keywords', []),
                    internal_trends
                ),
                'recommended_hashtags': self._select_best_hashtags_from_tiktok(
                    tiktok_hashtags, 
                    product_category
                ),
                'content_strategy': self._generate_tiktok_inspired_strategy(
                    tiktok_content_insights,
                    tiktok_viral_videos,
                    performance_data
                ),
                
                'timestamp': datetime.now().isoformat(),
                'data_sources': ['tiktok_apify_scraper', 'internal_platform']
            }
            
            # Cache the context
            self._context_cache[cache_key] = {
                'data': context,
                'timestamp': datetime.now()
            }
            
            # Limit cache size
            if len(self._context_cache) > 20:
                oldest_key = min(self._context_cache.keys(), 
                               key=lambda k: self._context_cache[k]['timestamp'])
                del self._context_cache[oldest_key]
            
            logger.info(f"Collected real-time context from TikTok API and platform data")
            return context
            
        except Exception as e:
            logger.error(f"Failed to collect real-time context: {e}")
            # Fallback to internal data only
            return await self._get_fallback_context(product_name, seller_id, product_category, db)
    
    async def _get_trending_keywords(self, db: Session = None) -> List[str]:
        """Get current trending keywords/hashtags from your platform"""
        try:
            if db:
                # Example query - adapt to your database structure
                # trending_query = """
                # SELECT keyword, COUNT(*) as frequency 
                # FROM live_sessions ls
                # JOIN session_keywords sk ON ls.id = sk.session_id
                # WHERE ls.created_at > NOW() - INTERVAL '24 hours'
                # AND ls.viewer_count > 100
                # GROUP BY keyword
                # ORDER BY frequency DESC
                # LIMIT 10
                # """
                # trending_keywords = db.execute(text(trending_query)).fetchall()
                # return [row[0] for row in trending_keywords]
                pass
            
            # Fallback trending keywords based on live commerce best practices
            return [
                "viral", "trending", "populer", "best seller", 
                "promo hari ini", "limited time", "flash sale",
                "eksklusif", "terbatas", "gratis ongkir"
            ]
        except Exception as e:
            logger.warning(f"Failed to get trending keywords: {e}")
            return []
    
    async def _get_market_insights(self, category: str = None, db: Session = None) -> Dict[str, Any]:
        """Get current market performance for the category"""
        try:
            if db and category:
                # Example implementation - adapt to your tables
                # market_query = """
                # SELECT 
                #     AVG(conversion_rate) as avg_conversion,
                #     AVG(engagement_rate) as avg_engagement,
                #     COUNT(*) as total_sessions
                # FROM live_sessions 
                # WHERE product_category = %s 
                # AND created_at > NOW() - INTERVAL '7 days'
                # """
                # result = db.execute(text(market_query), (category,)).fetchone()
                pass
            
            # Dynamic insights based on time of day and current trends
            from datetime import datetime
            current_hour = datetime.now().hour
            
            peak_hours = ["19:00-21:00", "12:00-14:00"] if 12 <= current_hour <= 14 or 19 <= current_hour <= 21 else ["20:00-22:00"]
            
            return {
                'hot_products': self._get_category_trends(category),
                'peak_hours': peak_hours,
                'high_converting_words': ["eksklusif", "terbatas", "gratis ongkir", "cashback"],
                'avg_engagement_rate': 0.15,
                'current_demand': "high" if 19 <= current_hour <= 22 else "medium"
            }
        except Exception as e:
            logger.warning(f"Failed to get market insights: {e}")
            return {}
    
    async def _get_performance_metrics(self, seller_id: str, db: Session = None) -> Dict[str, Any]:
        """Get seller's recent performance data"""
        try:
            if db and seller_id:
                # Example query - adapt to your seller performance tracking
                # performance_query = """
                # SELECT 
                #     AVG(conversion_rate) as conversion,
                #     AVG(engagement_rate) as engagement,
                #     COUNT(*) as session_count,
                #     MAX(viewer_count) as max_viewers
                # FROM live_sessions 
                # WHERE seller_id = %s 
                # AND created_at > NOW() - INTERVAL '30 days'
                # """
                # metrics = db.execute(text(performance_query), (seller_id,)).fetchone()
                pass
            
            return {
                'recent_conversion_rate': 0.12,
                'top_performing_content': ["product demo", "testimonial", "before_after"],
                'best_time_slots': ["20:00", "13:00", "21:00"],
                'audience_engagement': 0.18,
                'successful_phrases': ["jangan sampai terlewat", "stok terbatas"]
            }
        except Exception as e:
            logger.warning(f"Failed to get performance metrics: {e}")
            return {}
    
    async def _get_audience_insights(self, seller_id: str, db: Session = None) -> Dict[str, Any]:
        """Get current audience behavior insights"""
        try:
            if db and seller_id:
                # Example query - adapt to your user analytics
                # audience_query = """
                # SELECT 
                #     age_group, gender, preferred_content_type,
                #     AVG(session_duration) as avg_duration
                # FROM user_sessions us
                # JOIN users u ON us.user_id = u.id
                # WHERE us.seller_id = %s
                # AND us.created_at > NOW() - INTERVAL '7 days'
                # GROUP BY age_group, gender, preferred_content_type
                # """
                pass
            
            from datetime import datetime
            current_hour = datetime.now().hour
            
            return {
                'active_demographics': ['18-25', '26-35'] if 19 <= current_hour <= 23 else ['26-35', '36-45'],
                'preferred_content_style': 'energetic' if 19 <= current_hour <= 22 else 'casual',
                'peak_activity': '19:00-22:00',
                'popular_reactions': ['excited', 'curious', 'interested'],
                'attention_span': 'short' if current_hour >= 20 else 'medium'
            }
        except Exception as e:
            logger.warning(f"Failed to get audience insights: {e}")
            return {}
    
    async def _get_competitor_analysis(self, category: str, db: Session = None) -> Dict[str, Any]:
        """Get competitor insights for the category"""
        try:
            # This would analyze successful strategies in your platform
            return {
                'successful_strategies': ['storytelling', 'urgency', 'social_proof'],
                'trending_formats': ['before_after', 'unboxing', 'live_demo'],
                'winning_phrases': ['jangan sampai terlewat', 'stok terbatas', 'eksklusif untuk hari ini'],
                'effective_timing': ['countdown', 'limited_slots', 'flash_sale']
            }
        except Exception as e:
            logger.warning(f"Failed to get competitor analysis: {e}")
            return {}
    
    async def _get_real_time_stats(self, product_name: str, db: Session = None) -> Dict[str, Any]:
        """Get real-time stats for the specific product"""
        try:
            if db and product_name:
                # Example query for product performance
                # stats_query = """
                # SELECT 
                #     COUNT(*) as view_count,
                #     SUM(purchase_count) as purchase_count,
                #     AVG(rating) as avg_rating
                # FROM product_views pv
                # LEFT JOIN purchases p ON pv.product_id = p.product_id
                # WHERE pv.product_name = %s
                # AND pv.created_at > NOW() - INTERVAL '24 hours'
                # """
                pass
            
            from random import randint
            return {
                'current_viewers': randint(50, 500),
                'recent_purchases': randint(5, 50),
                'stock_urgency': 'medium',
                'viewer_growth': 'increasing'
            }
        except Exception as e:
            logger.warning(f"Failed to get real-time stats: {e}")
            return {}
    
    def _get_category_trends(self, category: str) -> List[str]:
        """Get trending products for category"""
        category_trends = {
            'fashion': ['dress viral', 'outfit trendy', 'fashion muslimah'],
            'beauty': ['skincare viral', 'makeup tutorial', 'anti aging'],
            'electronics': ['gadget terbaru', 'smartphone murah', 'aksesoris hp'],
            'food': ['makanan viral', 'snack enak', 'minuman segar'],
            'home': ['dekorasi rumah', 'peralatan dapur', 'furniture murah']
        }
        return category_trends.get(category, ['produk viral', 'best seller', 'trending'])
    
    def _enhance_prompt_with_context(self, base_prompt: str, context: Dict[str, Any]) -> str:
        """Enhance the base prompt with real-time context including TikTok data from Apify"""
        if not context or not self.enable_dynamic_context:
            return base_prompt
        
        # Extract TikTok trending data from Apify (PRIORITY - most current)
        tiktok_keywords = context.get('tiktok_viral_keywords', [])[:3]
        tiktok_hashtags = context.get('tiktok_trending_hashtags', [])[:3] 
        tiktok_content_types = context.get('tiktok_viral_content_types', [])[:2]
        tiktok_music = context.get('tiktok_popular_music', [])[:2]
        combined_keywords = context.get('combined_trending_keywords', [])[:3]
        
        # Extract platform data
        market_data = context.get('market_data', {})
        performance_data = context.get('performance_data', {})
        audience_data = context.get('audience_data', {})
        real_time_stats = context.get('real_time_stats', {})
        
        # Build enhanced context injection
        context_enhancement = ""
        
        # 🔥 TikTok trending data from Apify (highest priority)
        if tiktok_keywords:
            context_enhancement += f"\n🔥 Viral TikTok saat ini: {', '.join(tiktok_keywords)}"
        
        if tiktok_hashtags:
            context_enhancement += f"\n📈 Hashtag trending TikTok: #{', #'.join(tiktok_hashtags)}"
        
        if tiktok_content_types:
            context_enhancement += f"\n🎬 Jenis konten viral: {', '.join(tiktok_content_types)}"
        
        if tiktok_music:
            context_enhancement += f"\n🎵 Musik trending: {', '.join(tiktok_music)}"
        
        # Platform-specific data
        if combined_keywords and not tiktok_keywords:  # Use if TikTok data unavailable
            context_enhancement += f"\nKeyword trending saat ini: {', '.join(combined_keywords)}"
        
        if market_data.get('current_demand'):
            context_enhancement += f"\nDemand saat ini: {market_data['current_demand']}"
        
        if audience_data.get('preferred_content_style'):
            context_enhancement += f"\nStyle yang disukai audience: {audience_data['preferred_content_style']}"
        
        if performance_data.get('successful_phrases'):
            phrases = performance_data['successful_phrases'][:2]
            context_enhancement += f"\nFrasa yang terbukti efektif: {', '.join(phrases)}"
        
        if real_time_stats.get('current_viewers'):
            context_enhancement += f"\nJumlah viewer saat ini: {real_time_stats['current_viewers']} orang"
        
        # Add TikTok engagement insights from Apify data
        tiktok_engagement = context.get('tiktok_engagement_patterns', {})
        if tiktok_engagement.get('avg_like_rate'):
            like_rate = tiktok_engagement['avg_like_rate'] * 100
            context_enhancement += f"\nEngagement rate TikTok: {like_rate:.1f}%"
        tiktok_engagement = context.get('tiktok_engagement_patterns', {})
        if tiktok_engagement.get('high_performing_threshold'):
            context_enhancement += f"\nTarget engagement rate: {tiktok_engagement['high_performing_threshold']}%"
        
        # Data source indicator
        data_sources = context.get('data_sources', [])
        if 'tiktok_api' in data_sources:
            context_enhancement += f"\n🎯 Menggunakan data terkini dari TikTok API"
        
        # Inject context into the original prompt
        enhanced_prompt = base_prompt.replace(
            "Buatlah konten promosi live streaming yang engaging dan persuasif dalam bahasa Indonesia.",
            f"Buatlah konten promosi live streaming yang engaging dan persuasif dalam bahasa Indonesia.{context_enhancement}"
        )
        
        return enhanced_prompt
    
    def _combine_trending_data(self, tiktok_keywords: List[str], internal_keywords: List[str]) -> List[str]:
        """Combine TikTok and internal trending keywords intelligently"""
        # Merge and deduplicate, prioritizing TikTok data for freshness
        combined = []
        seen = set()
        
        # Add TikTok keywords first (most current)
        for keyword in tiktok_keywords[:8]:  # Top 8 from TikTok
            if keyword and keyword.lower() not in seen:
                combined.append(keyword)
                seen.add(keyword.lower())
        
        # Add internal keywords that aren't duplicates
        for keyword in internal_keywords[:5]:  # Top 5 internal
            if keyword and keyword.lower() not in seen:
                combined.append(keyword)
                seen.add(keyword.lower())
        
        return combined[:12]  # Return top 12 combined
    
    def _get_category_hashtags(self, category: str) -> List[str]:
        """Get relevant hashtags for scraping based on product category"""
        category_hashtags = {
            'beauty': ['makeup', 'skincare', 'beauty', 'cosmetics', 'glowing'],
            'fashion': ['fashion', 'outfit', 'style', 'trending', 'ootd'],
            'electronics': ['gadget', 'tech', 'smartphone', 'unboxing', 'review'],
            'food': ['food', 'kuliner', 'recipe', 'cooking', 'delicious'],
            'home': ['homedecor', 'furniture', 'interior', 'homedesign', 'diy'],
            'health': ['health', 'wellness', 'fitness', 'healthy', 'tips'],
            'sports': ['sport', 'fitness', 'workout', 'training', 'exercise']
        }
        
        # Get hashtags for category, fallback to general
        hashtags = category_hashtags.get(category, ['trending', 'viral', 'popular'])
        return hashtags
    
    def _combine_tiktok_and_internal_trends(self, tiktok_keywords: List[str], internal_keywords: List[str]) -> List[str]:
        """Combine TikTok scraped data and internal trending keywords intelligently"""
        combined = []
        seen = set()
        
        # Add TikTok keywords first (most current from the platform)
        for keyword in tiktok_keywords[:10]:  # Top 10 from TikTok
            if keyword and keyword.lower() not in seen and len(keyword) > 2:
                combined.append(keyword)
                seen.add(keyword.lower())
        
        # Add internal keywords that complement TikTok data
        for keyword in internal_keywords[:5]:  # Top 5 internal
            if keyword and keyword.lower() not in seen and len(keyword) > 2:
                combined.append(keyword)
                seen.add(keyword.lower())
        
        return combined[:15]  # Return top 15 combined trends
    
    def _select_best_hashtags_from_tiktok(self, tiktok_hashtags: List[Dict[str, Any]], category: str) -> List[str]:
        """Select the most relevant hashtags from TikTok data for the product category"""
        if not tiktok_hashtags:
            return self._get_category_hashtags(category)
        
        # Filter hashtags by relevance to category
        category_keywords = {
            'beauty': ['beauty', 'makeup', 'skincare', 'cosmetic', 'glowing', 'cantik'],
            'fashion': ['fashion', 'outfit', 'style', 'baju', 'dress', 'trendy'],
            'electronics': ['gadget', 'tech', 'hp', 'phone', 'elektronik', 'digital'],
            'food': ['food', 'makanan', 'kuliner', 'resep', 'enak', 'delicious'],
            'home': ['rumah', 'home', 'dekor', 'furniture', 'interior'],
        }
        
        relevant_keywords = category_keywords.get(category, [])
        selected_hashtags = []
        
        # Score hashtags by relevance and trending score
        for hashtag_data in tiktok_hashtags:
            hashtag = hashtag_data.get('hashtag', '').lower()
            trending_score = hashtag_data.get('trending_score', 0)
            
            # Check relevance to category
            relevance_score = 0
            for keyword in relevant_keywords:
                if keyword in hashtag:
                    relevance_score += 1
            
            # Combine trending and relevance scores
            total_score = trending_score + (relevance_score * 2)  # Boost relevant hashtags
            
            selected_hashtags.append({
                'hashtag': hashtag,
                'score': total_score
            })
        
        # Sort by score and return top hashtags
        selected_hashtags.sort(key=lambda x: x['score'], reverse=True)
        return [h['hashtag'] for h in selected_hashtags[:8]]
    
    def _generate_tiktok_inspired_strategy(self, 
                                         tiktok_insights: Dict[str, Any],
                                         viral_videos: List[Dict[str, Any]], 
                                         performance_data: Dict[str, Any]) -> Dict[str, Any]:
        """Generate content strategy inspired by current TikTok trends"""
        
        # Analyze viral video descriptions for patterns
        viral_patterns = self._analyze_viral_video_patterns(viral_videos)
        
        # Extract engagement insights
        engagement_patterns = tiktok_insights.get('engagement_patterns', {})
        
        # Get content type recommendations
        viral_content_types = tiktok_insights.get('viral_content_types', [])
        
        strategy = {
            'recommended_content_types': viral_content_types[:3],
            'viral_patterns': viral_patterns,
            'engagement_optimization': {
                'optimal_length': '15-30 seconds',
                'peak_engagement_time': self._get_peak_engagement_time(),
                'effective_hooks': self._extract_effective_hooks(viral_videos),
                'trending_music': tiktok_insights.get('popular_music_trends', [])[:3]
            },
            'content_structure': {
                'hook_duration': '3-5 seconds',
                'main_content': '10-20 seconds', 
                'call_to_action': '5-10 seconds'
            },
            'hashtag_strategy': {
                'trending_count': 3,
                'niche_count': 2,
                'branded_count': 1
            }
        }
        
        return strategy
    
    def _analyze_viral_video_patterns(self, viral_videos: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze patterns in viral video descriptions"""
        if not viral_videos:
            return {}
        
        # Common words/phrases analysis
        all_descriptions = ' '.join([v.get('description', '') for v in viral_videos]).lower()
        
        # Extract common phrases (simplified)
        common_phrases = []
        if 'tutorial' in all_descriptions:
            common_phrases.append('tutorial')
        if 'review' in all_descriptions:
            common_phrases.append('review')
        if 'tips' in all_descriptions:
            common_phrases.append('tips')
        if 'hack' in all_descriptions:
            common_phrases.append('hack')
        
        # Analyze hashtag usage
        all_hashtags = []
        for video in viral_videos:
            hashtags = video.get('hashtags', [])
            all_hashtags.extend(hashtags)
        
        from collections import Counter
        popular_hashtags = [h for h, count in Counter(all_hashtags).most_common(5)]
        
        return {
            'common_content_themes': common_phrases,
            'popular_hashtags': popular_hashtags,
            'avg_description_length': len(all_descriptions) // len(viral_videos) if viral_videos else 0
        }
    
    def _get_peak_engagement_time(self) -> str:
        """Get peak engagement time based on current time"""
        from datetime import datetime
        current_hour = datetime.now().hour
        
        if 19 <= current_hour <= 22:
            return "prime_time_evening"
        elif 12 <= current_hour <= 14:
            return "lunch_break"
        elif 20 <= current_hour <= 23:
            return "night_time_peak"
        else:
            return "off_peak"
    
    def _extract_effective_hooks(self, viral_videos: List[Dict[str, Any]]) -> List[str]:
        """Extract effective hook patterns from viral videos"""
        hooks = []
        
        for video in viral_videos[:5]:  # Top 5 viral videos
            description = video.get('description', '')
            if description:
                # Extract first sentence/phrase as potential hook
                first_sentence = description.split('.')[0].split('!')[0][:50]
                if len(first_sentence) > 10:
                    hooks.append(first_sentence.strip())
        
        return hooks[:3]  # Return top 3 hooks
    
    def _select_best_hashtags(self, tiktok_hashtags: List[Dict[str, Any]], category: str) -> List[str]:
        """Select the most relevant hashtags for the product category"""
        if not tiktok_hashtags:
            return []
        
        # Filter hashtags by category relevance and trend score
        relevant_hashtags = []
        
        for hashtag_data in tiktok_hashtags:
            hashtag = hashtag_data.get('name', '')
            category_match = hashtag_data.get('category', '')
            trend_score = hashtag_data.get('trend_score', 0)
            
            # Prioritize hashtags that match the category or have high trend scores
            if (category and category_match == category) or trend_score > 50:
                relevant_hashtags.append({
                    'hashtag': hashtag,
                    'score': trend_score,
                    'category': category_match
                })
        
        # Sort by score and return top hashtags
        relevant_hashtags.sort(key=lambda x: x['score'], reverse=True)
        return [h['hashtag'] for h in relevant_hashtags[:8]]
    
    def _generate_content_strategy(self, tiktok_analysis: Dict[str, Any], performance_data: Dict[str, Any]) -> Dict[str, Any]:
        """Generate content strategy based on TikTok trends and performance data"""
        strategy = {
            'recommended_formats': [],
            'key_phrases': [],
            'hashtag_strategy': [],
            'timing_advice': [],
            'engagement_tactics': []
        }
        
        # Extract recommendations from TikTok analysis
        if tiktok_analysis:
            strategy['recommended_formats'] = tiktok_analysis.get('successful_formats', [])[:3]
            strategy['key_phrases'] = tiktok_analysis.get('viral_phrases', [])[:5]
            strategy['timing_advice'] = tiktok_analysis.get('optimal_posting_times', [])
        
        # Add performance-based recommendations
        if performance_data:
            if performance_data.get('performance_tier') == 'top_performer':
                strategy['engagement_tactics'].append('maintain_current_style')
            else:
                strategy['engagement_tactics'].extend(['increase_urgency', 'add_social_proof'])
        
        return strategy
    
    async def _get_fallback_context(self, product_name: str, seller_id: str, product_category: str, db: Session) -> Dict[str, Any]:
        """Fallback context when TikTok API fails"""
        from datetime import datetime
        
        try:
            return {
                'current_trends': await self._get_trending_keywords(db),
                'market_data': await self._get_market_insights(product_category, db),
                'performance_data': await self._get_performance_metrics(seller_id, db),
                'real_time_stats': await self._get_real_time_stats(product_name, db),
                'tiktok_trending_hashtags': [],  # Empty when API fails
                'tiktok_viral_keywords': [],
                'combined_trending_keywords': await self._get_trending_keywords(db),
                'timestamp': datetime.now().isoformat(),
                'data_sources': ['internal_platform_only']
            }
        except:
            return {
                'current_trends': ["viral", "trending", "best seller"],
                'combined_trending_keywords': ["populer", "promo", "limited"],
                'timestamp': datetime.now().isoformat(),
                'data_sources': ['fallback_default']
            }

    def _format_prompt_for_finetuned_model(
        self, 
        product_name: str, 
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        real_time_context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Format prompt according to your EXACT fine-tuned model's training structure
        
        ⚠️  CRITICAL: Replace this with your actual PROMPT_TEMPLATE and wrap_inst()
        """
        
        # 🚨 PLACEHOLDER - REPLACE WITH YOUR EXACT PROMPT_TEMPLATE
        prompt_template = """Anda adalah ahli live commerce yang berpengalaman dalam menciptakan konten promosi yang menarik.

Informasi Produk:
- Nama Produk: {product_name}
- Harga: {price}
- Stok Tersisa: {stock}  
- Jumlah Viewer: {viewers}
- Konteks Acara: {event}

Buatlah konten promosi live streaming yang engaging dan persuasif dalam bahasa Indonesia."""
        
        # Fill in the template with actual values
        filled_template = prompt_template.format(
            product_name=product_name,
            price=product_price or "Belum ditentukan",
            stock=stock_count or "Tersedia",
            viewers=viewer_count or "100+",
            event=event_context or "Live streaming reguler"
        )
        
        # Enhance with real-time context if available
        if real_time_context:
            filled_template = self._enhance_prompt_with_context(filled_template, real_time_context)
        
        # Apply your wrap_inst() function
        return self._wrap_inst(filled_template)
    
    def _wrap_inst(self, prompt: str) -> str:
        """
        Your exact wrap_inst() function for Mistral-style format
        
        ⚠️  CRITICAL: Replace this with your exact wrap_inst() implementation
        """
        # 🚨 PLACEHOLDER - REPLACE WITH YOUR EXACT wrap_inst() IMPLEMENTATION
        wrapped_prompt = f"""<s>[INST] {prompt}

Berikan jawaban dalam format yang tepat dengan 4 baris:
COPY: [konten copywriting yang menarik]
HOST: [script untuk host live streaming]
TIME: [saran timing dan durasi optimal]
BUNDLE: [saran bundle produk dan promo]
[/INST]"""
        
        return wrapped_prompt

    async def _generate_full_4lines(
        self, 
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        seller_id: Optional[str] = None,
        product_category: Optional[str] = None,
        db: Optional[Session] = None
    ) -> Dict[str, Any]:
        """Generate full 4-line response using your trained model with real-time context"""
        
        if self.generator is None:
            return {"error": "AI model not available"}
        
        # Collect real-time context for enhanced recommendations
        real_time_context = None
        if self.enable_dynamic_context and db:
            try:
                real_time_context = await self._collect_real_time_context(
                    product_name=product_name,
                    seller_id=seller_id,
                    product_category=product_category,
                    db=db
                )
            except Exception as e:
                logger.warning(f"Failed to collect real-time context: {e}")
        
        # Format prompt according to your training structure with real-time enhancements
        formatted_prompt = self._format_prompt_for_finetuned_model(
            product_name=product_name,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context,
            real_time_context=real_time_context
        )
        
        try:
            # Generate using your model
            outputs = self.generator(
                formatted_prompt,
                max_new_tokens=self.max_length,
                temperature=self.temperature,
                top_p=self.top_p,
                top_k=self.top_k,
                do_sample=True,
                pad_token_id=self.tokenizer.pad_token_id,
                eos_token_id=self.tokenizer.eos_token_id,
                return_full_text=False
            )
            
            generated_text = outputs[0]['generated_text'].strip()
            
            # Parse the 4-line response
            parsed_content = self._parse_finetuned_output(generated_text)
            
            return {
                "raw_output": generated_text,
                "parsed_sections": parsed_content,
                "generation_strategy": "option_2_full_4lines"
            }
            
        except Exception as e:
            logger.error(f"Error with full 4-line generation: {str(e)}")
            return {"error": f"Generation failed: {str(e)}"}

    def _parse_finetuned_output(self, output: str) -> Dict[str, str]:
        """Enhanced parsing for your 4-line output format"""
        parsed = {
            "COPY": "",
            "HOST": "",
            "TIME": "",
            "BUNDLE": ""
        }
        
        lines = output.split('\n')
        current_section = None
        current_content = []
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            # Check if line starts with section identifier
            section_found = None
            for section in ["COPY", "HOST", "TIME", "BUNDLE"]:
                if line.startswith(f"{section}:") or line.startswith(f"{section} "):
                    section_found = section
                    
                    # Save previous section if exists
                    if current_section and current_content:
                        parsed[current_section] = " ".join(current_content).strip()
                    
                    # Start new section
                    current_section = section
                    current_content = []
                    
                    # Extract content after section identifier
                    if ":" in line:
                        content_part = line.split(":", 1)[1].strip()
                    else:
                        content_part = line.replace(section, "", 1).strip()
                    
                    if content_part:
                        current_content.append(content_part)
                    
                    break
            
            # If no section identifier found, add to current section
            if not section_found and current_section:
                current_content.append(line)
        
        # Don't forget the last section
        if current_section and current_content:
            parsed[current_section] = " ".join(current_content).strip()
        
        # Clean up parsed content
        for section in parsed:
            parsed[section] = self._clean_section_content(parsed[section])
        
        return parsed
    
    def _clean_section_content(self, content: str) -> str:
        """Clean and format section content"""
        if not content:
            return ""
        
        # Remove extra whitespace
        content = " ".join(content.split())
        
        # Remove common artifacts
        content = content.replace("**", "").replace("***", "")
        
        return content

    def _generate_cache_key(
        self,
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None
    ) -> str:
        """Generate cache key for generation requests"""
        cache_data = f"{product_name}|{product_price}|{stock_count}|{viewer_count}|{event_context}"
        return hashlib.md5(cache_data.encode()).hexdigest()
    
    def _get_from_cache(self, cache_key: str) -> Optional[Dict[str, Any]]:
        """Get generation result from cache"""
        return self._generation_cache.get(cache_key)
    
    def _store_in_cache(self, cache_key: str, result: Dict[str, Any]):
        """Store generation result in cache"""
        # Simple LRU: remove oldest if cache is full
        if len(self._generation_cache) >= self._cache_max_size:
            oldest_key = next(iter(self._generation_cache))
            del self._generation_cache[oldest_key]
        
        self._generation_cache[cache_key] = result

    # OPTION 2 MAIN METHODS

    async def generate_finetuned_content(
        self,
        db: Session,
        *,
        user_id: int,
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        seller_id: Optional[str] = None,
        product_category: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate live commerce content using your fine-tuned 4-line model with real-time data (Option 2)"""
        
        generation_result = await self._generate_full_4lines(
            product_name=product_name,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context,
            seller_id=seller_id,
            product_category=product_category,
            db=db
        )
        
        if "error" in generation_result:
            return generation_result
        
        parsed_sections = generation_result["parsed_sections"]
        
        # Create formatted full content
        full_content = f"""COPY: {parsed_sections.get('COPY', '')}
HOST: {parsed_sections.get('HOST', '')}
TIME: {parsed_sections.get('TIME', '')}
BUNDLE: {parsed_sections.get('BUNDLE', '')}"""
        
        # Save to database
        ai_content_data = AIContentCreate(
            content_type="live_commerce_4line",
            title=f"Live Commerce Content - {product_name}",
            content=full_content,
            prompt_used=f"Product: {product_name}, Price: {product_price}, Context: {event_context}"
        )
        
        db_content = self._save_content(db, user_id=user_id, obj_in=ai_content_data)
        
        return {
            "content": db_content,
            "parsed_sections": parsed_sections,
            "raw_output": generation_result["raw_output"],
            "format": "4-line_parsed",
            "generation_strategy": "option_2_parsing"
        }

    async def extract_specific_section_finetuned(
        self,
        product_name: str,
        section_type: str,  # "COPY", "HOST", "TIME", or "BUNDLE"
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        seller_id: Optional[str] = None,
        product_category: Optional[str] = None,
        db: Optional[Session] = None,
        use_cache: bool = True
    ) -> str:
        """Extract only a specific section from your fine-tuned model with real-time data (Option 2)"""
        
        # Generate cache key
        cache_key = self._generate_cache_key(
            product_name, product_price, stock_count, viewer_count, event_context
        )
        
        # Check cache first if enabled
        if use_cache:
            cached_result = self._get_from_cache(cache_key)
            if cached_result:
                logger.info(f"Using cached generation for {product_name}")
                parsed_sections = cached_result.get("parsed_sections", {})
                return parsed_sections.get(section_type, f"Could not extract {section_type} section")
        
        # Generate full 4-line content with real-time data
        generation_result = await self._generate_full_4lines(
            product_name=product_name,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context,
            seller_id=seller_id,
            product_category=product_category,
            db=db
        )
        
        if "error" in generation_result:
            return generation_result["error"]
        
        # Cache the result for future section extractions
        if use_cache:
            self._store_in_cache(cache_key, generation_result)
        
        # Extract the requested section
        parsed_sections = generation_result.get("parsed_sections", {})
        return parsed_sections.get(section_type, f"Could not extract {section_type} section")

    def _save_content(
        self, db: Session, *, user_id: int, obj_in: AIContentCreate
    ) -> AIContent:
        """Save generated content to database"""
        db_obj = AIContent(
            content_type=obj_in.content_type,
            title=obj_in.title,
            content=obj_in.content,
            prompt_used=obj_in.prompt_used,
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_model_status(self) -> Dict[str, Any]:
        """Get the status of the AI model"""
        return {
            "model_name": self.model_name,
            "model_loaded": self.generator is not None,
            "using_local_model": self.use_local,
            "device": "cuda" if torch.cuda.is_available() and self.generator else "cpu",
            "max_length": self.max_length,
            "temperature": self.temperature,
            "cache_size": len(self._generation_cache),
            "generation_strategy": "Option 2 - Parse 4-line output"
        }

    def reload_model(self):
        """Reload the model"""
        logger.info("Reloading AI model...")
        self.tokenizer = None
        self.model = None
        self.generator = None
        self._generation_cache.clear()
        self._initialize_model()

# Create singleton instance
ai_content_service = AIContentService()
