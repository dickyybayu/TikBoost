import os
import logging
from typing import Optional, Dict, Any
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
from app.core.config import settings

logger = logging.getLogger(__name__)

class TikTokLiveService:
    def __init__(self):
        self.tokenizer = None
        self.model = None
        self.is_initialized = False
        
    async def initialize(self):
        """Initialize the fine-tuned Mistral model"""
        try:
            logger.info(f"Loading model: {settings.HUGGINGFACE_MODEL_NAME}")
            
            # Load tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                settings.HUGGINGFACE_MODEL_NAME,
                token=settings.HUGGINGFACE_API_TOKEN,
                trust_remote_code=True
            )
            
            # Load model
            self.model = AutoModelForCausalLM.from_pretrained(
                settings.HUGGINGFACE_MODEL_NAME,
                token=settings.HUGGINGFACE_API_TOKEN,
                torch_dtype=torch.bfloat16,
                device_map="auto",
                trust_remote_code=True
            )
            
            self.is_initialized = True
            logger.info("TikTok Live model initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize model: {str(e)}")
            raise e
    
    def _create_prompt(self, product_data: Dict[str, Any]) -> str:
        """Create prompt based on your fine-tuning format"""
        prompt = f"""### Instruction:
Kamu adalah host live TikTok Shop yang berbahasa santai. Berdasarkan detail produk di bawah, buat rekomendasi promosi dalam format COPY:, TIME:, BUNDLE:.

### Input:
Nama Produk   : {product_data.get('product_name', '')}
Harga (diskon): Rp{product_data.get('discounted_price', 0):,}
Stok Tersisa  : {product_data.get('stock_remaining', 0)}
Penonton Live : {product_data.get('live_viewers', 0)}
Event         : {product_data.get('event_type', '')}

### Response:
"""
        return prompt
    
    async def generate_live_recommendations(self, product_data: Dict[str, Any]) -> Dict[str, str]:
        """Generate TikTok Live selling recommendations"""
        if not self.is_initialized:
            await self.initialize()
        
        try:
            # Create prompt
            prompt = self._create_prompt(product_data)
            
            # Prepare messages for chat template
            messages = [
                {"role": "user", "content": prompt}
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
                max_new_tokens=settings.MAX_NEW_TOKENS,
                temperature=settings.MODEL_TEMPERATURE,
                top_p=settings.MODEL_TOP_P,
                top_k=settings.MODEL_TOP_K,
                do_sample=settings.MODEL_DO_SAMPLE,
                pad_token_id=self.tokenizer.eos_token_id
            )
            
            # Decode response
            response = self.tokenizer.decode(
                outputs[0][inputs["input_ids"].shape[-1]:],
                skip_special_tokens=True
            ).strip()
            
            # Parse the structured output
            parsed_response = self._parse_response(response)
            
            logger.info("Successfully generated live recommendations")
            return {
                "success": True,
                "recommendations": parsed_response,
                "raw_response": response,
                "prompt_used": prompt
            }
            
        except Exception as e:
            logger.error(f"Failed to generate recommendations: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "recommendations": {
                    "copy": "Error generating copy",
                    "time": "Error generating time",
                    "bundle": "Error generating bundle"
                }
            }
    
    def _parse_response(self, response: str) -> Dict[str, str]:
        """Parse the model response into structured format"""
        result = {
            "copy": "",
            "time": "",
            "bundle": ""
        }
        
        lines = response.split('\n')
        
        for line in lines:
            line = line.strip()
            if line.startswith("COPY:"):
                result["copy"] = line.replace("COPY:", "").strip()
            elif line.startswith("TIME:"):
                result["time"] = line.replace("TIME:", "").strip()
            elif line.startswith("BUNDLE:"):
                result["bundle"] = line.replace("BUNDLE:", "").strip()
        
        return result
    
    async def test_model(self) -> Dict[str, Any]:
        """Test the model with sample data"""
        sample_data = {
            "product_name": "Glowing Rok",
            "discounted_price": 199536,
            "stock_remaining": 463,
            "live_viewers": 1669,
            "event_type": "bonus ongkir"
        }
        
        return await self.generate_live_recommendations(sample_data)
    
    def get_model_info(self) -> Dict[str, Any]:
        """Get information about the loaded model"""
        return {
            "model_name": settings.HUGGINGFACE_MODEL_NAME,
            "is_initialized": self.is_initialized,
            "device": str(self.model.device) if self.model else "not loaded",
            "model_type": "Fine-tuned Mistral for TikTok Live Selling",
            "supported_format": "COPY, TIME, BUNDLE recommendations"
        }

# Global instance
tiktok_live_service = TikTokLiveService()
