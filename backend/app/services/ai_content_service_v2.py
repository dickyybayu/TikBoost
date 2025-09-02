import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.models import AIContent
from app.schemas.schemas import AIContentCreate, AIContentRequest
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
        self.max_length = settings.MAX_NEW_TOKENS
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

    def _format_prompt_for_finetuned_model(
        self, 
        product_name: str, 
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None
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

    def _generate_full_4lines(
        self, 
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate full 4-line response using your trained model"""
        
        if self.generator is None:
            return {"error": "AI model not available"}
        
        # Format prompt according to your training structure
        formatted_prompt = self._format_prompt_for_finetuned_model(
            product_name=product_name,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context
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

    def generate_finetuned_content(
        self,
        db: Session,
        *,
        user_id: int,
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate live commerce content using your fine-tuned 4-line model (Option 2)"""
        
        generation_result = self._generate_full_4lines(
            product_name=product_name,
            product_price=product_price,
            stock_count=stock_count,
            viewer_count=viewer_count,
            event_context=event_context
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

    def extract_specific_section_finetuned(
        self,
        product_name: str,
        section_type: str,  # "COPY", "HOST", "TIME", or "BUNDLE"
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        use_cache: bool = True
    ) -> str:
        """Extract only a specific section from your fine-tuned model (Option 2)"""
        
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
        
        # Generate full 4-line content
        generation_result = self._generate_full_4lines(
            product_name, product_price, stock_count, viewer_count, event_context
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
