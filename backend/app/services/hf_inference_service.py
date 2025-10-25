import requests
import logging
from typing import Optional, Dict, Any
from app.core.config import settings

logger = logging.getLogger(__name__)

class HuggingFaceInferenceService:
    def __init__(self):
        self.api_url = f"https://api-inference.huggingface.co/models/{settings.HUGGINGFACE_MODEL_NAME}"
        self.headers = {"Authorization": f"Bearer {settings.HUGGINGFACE_API_TOKEN}"}
        
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
    
    async def generate_live_recommendations(self, product_data: Dict[str, Any]) -> Dict[str, Any]:
        """Generate TikTok Live selling recommendations using HF Inference API"""
        try:
            # Create prompt
            prompt = self._create_prompt(product_data)
            
            # Call Hugging Face Inference API
            payload = {
                "inputs": prompt,
                "parameters": {
                    "max_new_tokens": settings.MAX_NEW_TOKENS,
                    "temperature": settings.MODEL_TEMPERATURE,
                    "top_p": settings.MODEL_TOP_P,
                    "do_sample": settings.MODEL_DO_SAMPLE,
                    "return_full_text": False
                }
            }
            
            response = requests.post(
                self.api_url,
                headers=self.headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                
                # Extract generated text
                if isinstance(result, list) and len(result) > 0:
                    generated_text = result[0].get('generated_text', '')
                else:
                    generated_text = str(result)
                
                # Parse the structured output
                parsed_response = self._parse_response(generated_text)
                
                logger.info("Successfully generated live recommendations via HF API")
                return {
                    "success": True,
                    "recommendations": parsed_response,
                    "raw_response": generated_text,
                    "prompt_used": prompt,
                    "method": "huggingface_inference_api"
                }
            
            elif response.status_code == 503:
                # Model loading on HF servers
                return {
                    "success": False,
                    "error": "Model is loading on Hugging Face servers. Please try again in 20-30 seconds.",
                    "recommendations": {
                        "copy": "Model sedang loading, coba lagi sebentar...",
                        "time": "Model sedang loading, coba lagi sebentar...",
                        "bundle": "Model sedang loading, coba lagi sebentar..."
                    }
                }
            
            else:
                error_msg = f"HF API Error {response.status_code}: {response.text}"
                logger.error(error_msg)
                return {
                    "success": False,
                    "error": error_msg,
                    "recommendations": {
                        "copy": "Error connecting to AI model",
                        "time": "Error connecting to AI model",
                        "bundle": "Error connecting to AI model"
                    }
                }
                
        except Exception as e:
            logger.error(f"Failed to call HF Inference API: {str(e)}")
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
        
        # Fallback if parsing fails
        if not any(result.values()):
            result["copy"] = response[:100] + "..." if len(response) > 100 else response
            result["time"] = "19:00-21:00 (default)"
            result["bundle"] = "Paket bundling tersedia"
        
        return result
    
    async def test_connection(self) -> Dict[str, Any]:
        """Test connection to HF Inference API"""
        try:
            # Simple test with minimal input
            test_payload = {
                "inputs": "Test connection",
                "parameters": {"max_new_tokens": 10}
            }
            
            response = requests.post(
                self.api_url,
                headers=self.headers,
                json=test_payload,
                timeout=30
            )
            
            return {
                "success": response.status_code == 200,
                "status_code": response.status_code,
                "message": "Connection successful" if response.status_code == 200 else f"Error: {response.text}",
                "model_url": self.api_url
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "model_url": self.api_url
            }

# Global instance
hf_inference_service = HuggingFaceInferenceService()
