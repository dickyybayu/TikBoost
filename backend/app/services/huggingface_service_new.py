import os
import logging
from typing import Optional, Dict, Any, List
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
from app.core.config import settings

logger = logging.getLogger(__name__)

class HuggingFaceService:
    def __init__(self):
        self.tokenizer = None
        self.model = None
        self.is_initialized = False
        
    async def initialize(self):
        """Initialize the Hugging Face model and tokenizer"""
        try:
            logger.info(f"Loading model: {settings.HUGGINGFACE_MODEL_NAME}")
            
            # Load tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(settings.HUGGINGFACE_MODEL_NAME)
            logger.info("Tokenizer loaded successfully")
            
            # Load model
            self.model = AutoModelForCausalLM.from_pretrained(settings.HUGGINGFACE_MODEL_NAME)
            logger.info("Model loaded successfully")
            
            # Determine device
            device = "cuda" if torch.cuda.is_available() else "cpu"
            self.model = self.model.to(device)
            logger.info(f"Model moved to device: {device}")
            
            self.is_initialized = True
            logger.info("Hugging Face model initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize Hugging Face model: {str(e)}")
            raise e
    
    async def generate_response(
        self,
        user_message: str,
        max_new_tokens: Optional[int] = None
    ) -> str:
        """Generate response using the chat template format"""
        if not self.is_initialized:
            await self.initialize()
        
        try:
            # Use settings defaults if not provided
            max_new_tokens = max_new_tokens or settings.MAX_NEW_TOKENS
            
            # Prepare messages in chat format
            messages = [
                {"role": "user", "content": user_message},
            ]
            
            # Apply chat template
            inputs = self.tokenizer.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt",
            ).to(self.model.device)
            
            # Generate response
            outputs = self.model.generate(
                **inputs, 
                max_new_tokens=max_new_tokens,
                do_sample=settings.MODEL_DO_SAMPLE,
                temperature=settings.MODEL_TEMPERATURE,
                top_p=settings.MODEL_TOP_P,
                top_k=settings.MODEL_TOP_K,
                pad_token_id=self.tokenizer.eos_token_id
            )
            
            # Decode only the new tokens (response)
            response = self.tokenizer.decode(
                outputs[0][inputs["input_ids"].shape[-1]:], 
                skip_special_tokens=True
            )
            
            logger.info(f"Successfully generated response for message: {user_message[:50]}...")
            return response.strip()
            
        except Exception as e:
            logger.error(f"Failed to generate response: {str(e)}")
            raise e
    
    async def generate_recommendation(
        self,
        product_data: Dict[str, Any],
        sales_data: Dict[str, Any] = None
    ) -> Dict[str, str]:
        """Generate product recommendation based on manual input data"""
        try:
            # Extract product information
            product_name = product_data.get('product_name', 'produk')
            product_price = product_data.get('product_price', '')
            product_category = product_data.get('product_category', '')
            product_description = product_data.get('product_description', '')
            
            # Extract sales statistics (manual input)
            if sales_data:
                viewer_count = sales_data.get('viewer_count', 0)
                engagement_rate = sales_data.get('engagement_rate', 0)
                previous_sales = sales_data.get('previous_sales', 0)
                target_audience = sales_data.get('target_audience', 'umum')
            else:
                viewer_count = 0
                engagement_rate = 0
                previous_sales = 0
                target_audience = 'umum'
            
            # Create structured prompt for recommendation
            prompt = f"""Berdasarkan data berikut, berikan rekomendasi strategi live selling:

Produk: {product_name}
Kategori: {product_category}
Harga: {product_price}
Deskripsi: {product_description}

Statistik Live:
- Jumlah penonton: {viewer_count}
- Tingkat engagement: {engagement_rate}%
- Penjualan sebelumnya: {previous_sales}
- Target audience: {target_audience}

Berikan rekomendasi strategi penjualan yang efektif untuk produk ini."""
            
            # Generate recommendation
            recommendation = await self.generate_response(prompt)
            
            return {
                "recommendation": recommendation,
                "product_name": product_name,
                "prompt_used": prompt,
                "success": True
            }
            
        except Exception as e:
            logger.error(f"Failed to generate recommendation: {str(e)}")
            return {
                "recommendation": "Maaf, terjadi kesalahan dalam membuat rekomendasi.",
                "error": str(e),
                "success": False
            }
    
    async def generate_content_script(
        self,
        content_type: str,
        context: Dict[str, Any]
    ) -> Dict[str, str]:
        """Generate content script for different scenarios"""
        try:
            if content_type == "opening":
                prompt = f"""Buatkan opening script yang menarik untuk live selling produk {context.get('product_name', 'produk')} dengan target audience {context.get('target_audience', 'umum')}. Script harus energik dan menarik perhatian."""
            
            elif content_type == "product_demo":
                prompt = f"""Buatkan script untuk demonstrasi produk {context.get('product_name', 'produk')} yang menjelaskan keunggulan dan cara penggunaan dengan menarik."""
            
            elif content_type == "closing":
                prompt = f"""Buatkan closing script yang persuasif untuk mendorong pembelian produk {context.get('product_name', 'produk')} dengan harga {context.get('product_price', '')}. Sertakan call-to-action yang kuat."""
            
            else:
                prompt = f"Buatkan script {content_type} untuk live selling yang menarik dan efektif."
            
            # Generate script
            script = await self.generate_response(prompt)
            
            return {
                "script": script,
                "content_type": content_type,
                "success": True
            }
            
        except Exception as e:
            logger.error(f"Failed to generate content script: {str(e)}")
            return {
                "script": "Gagal membuat script konten.",
                "error": str(e),
                "success": False
            }
    
    def get_model_info(self) -> Dict[str, Any]:
        """Get information about the loaded model"""
        return {
            "model_name": settings.HUGGINGFACE_MODEL_NAME,
            "is_initialized": self.is_initialized,
            "device": "cuda" if torch.cuda.is_available() else "cpu",
            "cuda_available": torch.cuda.is_available(),
            "max_new_tokens": settings.MAX_NEW_TOKENS,
            "temperature": settings.MODEL_TEMPERATURE,
            "top_p": settings.MODEL_TOP_P,
            "top_k": settings.MODEL_TOP_K
        }

# Global instance
huggingface_service = HuggingFaceService()
