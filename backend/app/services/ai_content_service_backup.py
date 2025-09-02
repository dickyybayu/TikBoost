import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.models import AIContent
from app.schemas.schemas import AIContentCreate, AIContentRequest, AIContentSection, SectionRequest
import json
import re
import logging

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
        
        # Map our content types to your model's capabilities
        self.content_mapping = {
            "copywriting": "COPY",
            "script": "HOST", 
            "description": "COPY",
            "timing": "TIME",
            "bundle": "BUNDLE"
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
            # Fallback to a smaller model if the custom model fails
            self._initialize_fallback_model()

    def _initialize_fallback_model(self):
        """Initialize a fallback model if the custom model fails to load"""
        try:
            logger.info("Loading fallback model: microsoft/DialoGPT-medium")
            
            self.tokenizer = AutoTokenizer.from_pretrained("microsoft/DialoGPT-medium")
            self.model = AutoModelForCausalLM.from_pretrained("microsoft/DialoGPT-medium")
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            self.generator = pipeline(
                "text-generation",
                model=self.model,
                tokenizer=self.tokenizer,
                device=0 if torch.cuda.is_available() else -1
            )
            
            logger.info("Fallback model loaded successfully!")
            
        except Exception as e:
            logger.error(f"Error loading fallback model: {str(e)}")
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
        
        ⚠️  CRITICAL: This must match your training format EXACTLY
        Please replace this with your actual PROMPT_TEMPLATE and wrap_inst()
        """
        
        # 🚨 PLACEHOLDER - REPLACE WITH YOUR EXACT PROMPT_TEMPLATE
        # Your PROMPT_TEMPLATE should look something like this (in Indonesian):
        prompt_template = """[YOUR EXACT INDONESIAN PROMPT_TEMPLATE HERE]
        
Informasi Produk:
- Nama Produk: {product_name}
- Harga: {price}
- Stok Tersisa: {stock}  
- Jumlah Viewer: {viewers}
- Konteks Acara: {event}

[REST OF YOUR EXACT TEMPLATE]
"""
        
        # Fill in the template with actual values
        filled_template = prompt_template.format(
            product_name=product_name,
            price=product_price or "Belum ditentukan",
            stock=stock_count or "Tersedia",
            viewers=viewer_count or "100+",
            event=event_context or "Live streaming reguler"
        )
        
        # 🚨 PLACEHOLDER - REPLACE WITH YOUR EXACT wrap_inst() FUNCTION
        return self._wrap_inst(filled_template)
    
    def _wrap_inst(self, prompt: str) -> str:
        """
        Your exact wrap_inst() function for Mistral-style format
        
        ⚠️  CRITICAL: This must match your training wrap_inst() EXACTLY
        """
        # 🚨 PLACEHOLDER - REPLACE WITH YOUR EXACT wrap_inst() IMPLEMENTATION
        # This is just a guess - you need to provide the real one
        wrapped_prompt = f"""<s>[INST] {prompt}

Berikan jawaban dalam format yang tepat dengan 4 baris:
COPY: [konten copywriting]
HOST: [script untuk host]
TIME: [saran timing]
BUNDLE: [saran bundle produk]
[/INST]"""
        
        return wrapped_prompt

    def generate_finetuned_content(
        self,
        db: Session,
        *,
        user_id: int,
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        cache_result: bool = True
    ) -> Dict[str, Any]:
        """
        Generate live commerce content using your fine-tuned 4-line model
        
        This is optimized for Option 2: Parse output from your current model
        """
        
        if self.generator is None:
            return {"error": "AI model not available"}
        
        # Use the optimized full 4-line generation
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
        raw_output = generation_result["raw_output"]
        
        # Create formatted full content
        full_content = f"""COPY: {parsed_sections.get('COPY', '')}
HOST: {parsed_sections.get('HOST', '')}
TIME: {parsed_sections.get('TIME', '')}
BUNDLE: {parsed_sections.get('BUNDLE', '')}"""
        
        # Save to database if requested
        if cache_result:
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
                "raw_output": raw_output,
                "format": "4-line_parsed",
                "generation_strategy": "option_2_parsing"
            }
        else:
            # Return without saving (useful for quick extractions)
            return {
                "parsed_sections": parsed_sections,
                "raw_output": raw_output,
                "format": "4-line_parsed",
                "generation_strategy": "option_2_parsing_no_cache"
            }

    def _parse_finetuned_output(self, output: str) -> Dict[str, str]:
        """
        Enhanced parsing for your 4-line output format
        
        Handles various output formats your model might produce:
        - COPY: content
        - COPY content (without colon)
        - Multi-line sections
        - Mixed formatting
        """
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
                # Try multiple patterns:
                # 1. "COPY: content"
                # 2. "COPY content" 
                # 3. "COPY:" (content on next line)
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
        
        # Fallback parsing for non-standard formats
        if not any(parsed.values()):
            parsed = self._fallback_parse(output)
        
        # Clean up parsed content
        for section in parsed:
            parsed[section] = self._clean_section_content(parsed[section])
        
        return parsed
    
    def _fallback_parse(self, output: str) -> Dict[str, str]:
        """
        Fallback parser for when standard parsing fails
        """
        parsed = {"COPY": "", "HOST": "", "TIME": "", "BUNDLE": ""}
        
        # Try to extract any content that looks like the sections
        import re
        
        # Look for COPY-like content (marketing text)
        copy_patterns = [
            r'(?i)(jangan\s+lewatkan|diskon|promo|limited|eksklusif|spesial)',
            r'(?i)(🔥|⚡|💥|🎉|✨)',
            r'(?i)(buruan|segera|terbatas)'
        ]
        
        lines = output.split('\n')
        for i, line in enumerate(lines):
            line = line.strip()
            if not line:
                continue
                
            # Heuristic assignment based on content
            if any(re.search(pattern, line) for pattern in copy_patterns):
                if not parsed["COPY"]:
                    parsed["COPY"] = line
            elif any(word in line.lower() for word in ['halo', 'selamat', 'malam', 'siang']):
                if not parsed["HOST"]:
                    parsed["HOST"] = line
            elif any(word in line.lower() for word in ['menit', 'jam', 'waktu', 'durasi']):
                if not parsed["TIME"]:
                    parsed["TIME"] = line
            elif any(word in line.lower() for word in ['paket', 'bundle', 'bonus', 'gratis']):
                if not parsed["BUNDLE"]:
                    parsed["BUNDLE"] = line
        
        return parsed
    
    def _clean_section_content(self, content: str) -> str:
        """Clean and format section content"""
        if not content:
            return ""
        
        # Remove extra whitespace
        content = " ".join(content.split())
        
        # Remove common artifacts
        content = content.replace("**", "").replace("***", "")
        
        # Ensure proper sentence ending
        if content and not content.endswith(('.', '!', '?', ':', '...')):
            content += "."
        
        return content

    def extract_specific_section_finetuned(
        self,
        product_name: str,
        section_type: str,  # "COPY", "HOST", "TIME", or "BUNDLE"
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None,
        use_cached: bool = True  # Option to cache full generation
    ) -> str:
        """
        Extract only a specific section from your fine-tuned model
        
        Options:
        1. use_cached=True: Generate all 4 lines, return only requested section (efficient for multiple sections)
        2. use_cached=False: Always generate fresh (better for single section requests)
        """
        
        if use_cached:
            # Strategy: Generate all 4 lines once, extract what's needed
            # More efficient when user might want multiple sections
            full_result = self._generate_full_4lines(
                product_name, product_price, stock_count, viewer_count, event_context
            )
            if "error" in full_result:
                return full_result["error"]
            
            parsed_content = full_result.get("parsed_sections", {})
            return parsed_content.get(section_type, f"Could not extract {section_type} section")
        
        else:
            # Strategy: Direct generation (future enhancement for section-specific models)
            # For now, still generates all 4 but indicates this is a single-section request
            return self._generate_single_section_optimized(
                product_name, section_type, product_price, stock_count, viewer_count, event_context
            )

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
                "generation_strategy": "full_4lines"
            }
            
        except Exception as e:
            logger.error(f"Error with full 4-line generation: {str(e)}")
            return {"error": f"Generation failed: {str(e)}"}

    def _generate_single_section_optimized(
        self,
        product_name: str,
        section_type: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None
    ) -> str:
        """
        Optimized single section generation
        
        Current: Still uses your 4-line model but optimizes for single section
        Future: Could use section-specific models when available
        """
        
        # For now, use the full generation approach
        # In the future, you could train section-specific models and use them here
        full_result = self._generate_full_4lines(
            product_name, product_price, stock_count, viewer_count, event_context
        )
        
        if "error" in full_result:
            return full_result["error"]
        
        parsed_content = full_result.get("parsed_sections", {})
        extracted_section = parsed_content.get(section_type, f"Could not extract {section_type}")
        
        # Add metadata to indicate this was a single-section request
        logger.info(f"Single section '{section_type}' extracted for product: {product_name}")
        
        return extracted_section

    def _generate_cache_key(
        self,
        product_name: str,
        product_price: Optional[str] = None,
        stock_count: Optional[int] = None,
        viewer_count: Optional[int] = None,
        event_context: Optional[str] = None
    ) -> str:
        """Generate cache key for generation requests"""
        import hashlib
        
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
    
    def clear_generation_cache(self):
        """Clear the generation cache"""
        self._generation_cache.clear()
        logger.info("Generation cache cleared")
        """Get statistics about section generation usage (for deciding on specialized models)"""
        # This would track which sections are requested most
        # Useful for deciding which sections need specialized models
        return {
            "total_generations": "tracked_in_future",
            "section_requests": {
                "COPY": "most_requested_section_count", 
                "HOST": "host_requests_count",
                "TIME": "time_requests_count",
                "BUNDLE": "bundle_requests_count"
            },
            "recommendation": "Consider specialized models for sections with >50% single-section requests"
        }
        self, 
        db: Session, 
        *, 
        user_id: int, 
        request: SectionRequest
    ) -> Dict[str, Any]:
        """Generate content with specific sections"""
        
        # Get available sections for the content type
        available_sections = self.section_definitions.get(request.content_type, {})
        
        # Generate each requested section
        sections = []
        for section_name in request.sections_wanted:
            if section_name in available_sections:
                section_content = self._generate_section(
                    request.content_type,
                    section_name,
                    available_sections[section_name],
                    request.base_prompt,
                    request.context
                )
                
                sections.append(AIContentSection(
                    section_name=section_name,
                    section_type=section_name,
                    content=section_content,
                    confidence_score=0.85  # You could implement actual confidence scoring
                ))
        
        # Combine sections if requested
        full_content = ""
        if request.merge_sections:
            full_content = self._merge_sections(sections, request.content_type)
        else:
            full_content = "\n\n".join([f"**{s.section_name.title()}:**\n{s.content}" for s in sections])
        
        # Save to database
        ai_content_data = AIContentCreate(
            content_type=request.content_type,
            title=f"Sectioned {request.content_type.title()} - {request.base_prompt[:50]}...",
            content=full_content,
            prompt_used=f"Sections: {', '.join(request.sections_wanted)} | Prompt: {request.base_prompt}"
        )
        
        db_content = self._save_content(db, user_id=user_id, obj_in=ai_content_data)
        
        return {
            "content": db_content,
            "sections": [s.dict() for s in sections],
            "available_sections": list(available_sections.keys()),
            "generated_sections": request.sections_wanted
        }

    def _generate_section(
        self, 
        content_type: str, 
        section_name: str, 
        section_description: str,
        base_prompt: str, 
        context: Optional[str] = None
    ) -> str:
        """Generate content for a specific section"""
        
        system_instruction = f"""You are an expert {content_type} writer. Generate ONLY the {section_name} section.

Section Purpose: {section_description}

Rules:
- Write only for this specific section
- Keep it focused and concise
- Match the tone for {content_type}
- Don't include other sections or repeat content
- Be natural and engaging"""

        formatted_prompt = f"""<|system|>
{system_instruction}

<|user|>
Create {section_name} section for: {base_prompt}"""
        
        if context:
            formatted_prompt += f"\nContext: {context}"
        
        formatted_prompt += f"\n\nSection needed: {section_name} ({section_description})\n\n<|assistant|>\n"
        
        return self._generate_with_model(formatted_prompt)

    def _merge_sections(self, sections: List[AIContentSection], content_type: str) -> str:
        """Intelligently merge sections into flowing content"""
        
        if content_type == "script":
            # For scripts, add natural transitions
            merged = ""
            for i, section in enumerate(sections):
                if i > 0:
                    merged += "\n\n"
                merged += section.content
            return merged
            
        elif content_type == "copywriting":
            # For copywriting, ensure smooth flow
            return "\n\n".join([section.content for section in sections])
            
        elif content_type == "description":
            # For descriptions, organize logically
            ordered_content = []
            for section in sections:
                if section.section_name in ["headline", "overview"]:
                    ordered_content.insert(0, section.content)
                else:
                    ordered_content.append(section.content)
            return "\n\n".join(ordered_content)
        
        # Default merge
        return "\n\n".join([section.content for section in sections])

    def get_available_sections(self, content_type: str) -> Dict[str, str]:
        """Get available sections for a content type"""
        return self.section_definitions.get(content_type, {})

    def generate_custom_sections(
        self,
        db: Session,
        *,
        user_id: int,
        content_type: str,
        base_prompt: str,
        custom_sections: Dict[str, str],  # {section_name: section_description}
        context: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate content with custom-defined sections"""
        
        sections = []
        for section_name, section_description in custom_sections.items():
            section_content = self._generate_section(
                content_type,
                section_name,
                section_description,
                base_prompt,
                context
            )
            
            sections.append(AIContentSection(
                section_name=section_name,
                section_type="custom",
                content=section_content
            ))
        
        # Combine all sections
        full_content = "\n\n".join([f"**{s.section_name.title()}:**\n{s.content}" for s in sections])
        
        # Save to database
        ai_content_data = AIContentCreate(
            content_type=content_type,
            title=f"Custom {content_type.title()} - {base_prompt[:50]}...",
            content=full_content,
            prompt_used=f"Custom sections: {', '.join(custom_sections.keys())} | Prompt: {base_prompt}"
        )
        
        db_content = self._save_content(db, user_id=user_id, obj_in=ai_content_data)
        
        return {
            "content": db_content,
            "sections": [s.dict() for s in sections],
            "custom_sections": list(custom_sections.keys())
        }

    def generate_content(
        self, 
        db: Session, 
        *, 
        user_id: int, 
        request: AIContentRequest
    ) -> AIContent:
        """Generate AI content based on user request"""
        
        # Check if structured output is requested
        if request.structured_output and request.sections:
            # Use sectioned generation
            section_request = SectionRequest(
                content_type=request.content_type,
                base_prompt=request.prompt,
                sections_wanted=request.sections,
                context=request.context,
                merge_sections=True
            )
            result = self.generate_sectioned_content(db, user_id=user_id, request=section_request)
            return result["content"]
        
        # Generate content based on type (original method)
        if request.content_type == "copywriting":
            content = self._generate_copywriting(request.prompt, request.context)
        elif request.content_type == "script":
            content = self._generate_script(request.prompt, request.context)
        elif request.content_type == "description":
            content = self._generate_description(request.prompt, request.context)
        else:
            content = self._generate_general_content(request.prompt, request.context)

        # Save to database
        ai_content_data = AIContentCreate(
            content_type=request.content_type,
            title=f"{request.content_type.title()} - {request.prompt[:50]}...",
            content=content,
            prompt_used=request.prompt
        )
        
        return self._save_content(db, user_id=user_id, obj_in=ai_content_data)

    def _generate_copywriting(self, prompt: str, context: Optional[str] = None) -> str:
        """Generate engaging copywriting for products or sessions"""
        system_instruction = """You are an expert copywriter specializing in live commerce and social media marketing. 
Create compelling, engaging copy that drives sales and viewer engagement. 
Focus on benefits, urgency, and emotional appeal. Keep it concise and action-oriented."""
        
        formatted_prompt = self._format_prompt(system_instruction, prompt, context, "copywriting")
        return self._generate_with_model(formatted_prompt)

    def _generate_script(self, prompt: str, context: Optional[str] = None) -> str:
        """Generate live session scripts"""
        system_instruction = """You are a live streaming expert. Create engaging, natural-sounding scripts for live commerce sessions.
Include product introductions, engagement tactics, call-to-actions, and viewer interaction prompts.
Structure the script with clear segments: opening, product showcase, engagement, and closing."""
        
        formatted_prompt = self._format_prompt(system_instruction, prompt, context, "live session script")
        return self._generate_with_model(formatted_prompt)

    def _generate_description(self, prompt: str, context: Optional[str] = None) -> str:
        """Generate product descriptions"""
        system_instruction = """You are a product description specialist for e-commerce and live commerce.
Create detailed, persuasive product descriptions that highlight features, benefits, and value propositions.
Use SEO-friendly language and include relevant keywords naturally."""
        
        formatted_prompt = self._format_prompt(system_instruction, prompt, context, "product description")
        return self._generate_with_model(formatted_prompt)

    def _generate_general_content(self, prompt: str, context: Optional[str] = None) -> str:
        """Generate general content"""
        system_instruction = """You are a content creation expert for live commerce and social media.
Create engaging, relevant content that helps with live streaming, product marketing, and audience engagement."""
        
        formatted_prompt = self._format_prompt(system_instruction, prompt, context, "content")
        return self._generate_with_model(formatted_prompt)

    def _format_prompt(self, system_instruction: str, user_prompt: str, context: Optional[str], content_type: str) -> str:
        """Format the prompt for the fine-tuned model"""
        formatted_prompt = f"""<|system|>
{system_instruction}

<|user|>
Task: Create {content_type} for: {user_prompt}"""
        
        if context:
            formatted_prompt += f"\nAdditional context: {context}"
        
        formatted_prompt += "\n\n<|assistant|>\n"
        
        return formatted_prompt

    def _generate_with_model(self, prompt: str) -> str:
        """Generate content using the Hugging Face model"""
        if self.generator is None:
            return "Error: AI model not available. Please check model configuration."
        
        try:
            # Generate text using the pipeline
            outputs = self.generator(
                prompt,
                max_new_tokens=self.max_length,
                temperature=self.temperature,
                top_p=self.top_p,
                top_k=self.top_k,
                do_sample=True,
                pad_token_id=self.tokenizer.pad_token_id,
                eos_token_id=self.tokenizer.eos_token_id,
                return_full_text=False,  # Only return the generated part
                clean_up_tokenization_spaces=True
            )
            
            generated_text = outputs[0]['generated_text'].strip()
            
            # Clean up the generated text
            generated_text = self._clean_generated_text(generated_text)
            
            return generated_text
            
        except Exception as e:
            logger.error(f"Error generating content: {str(e)}")
            return f"Error generating content: {str(e)}"

    def _clean_generated_text(self, text: str) -> str:
        """Clean and format the generated text"""
        # Remove any remaining special tokens
        text = text.replace("<|system|>", "").replace("<|user|>", "").replace("<|assistant|>", "")
        
        # Remove extra whitespace
        text = " ".join(text.split())
        
        # Ensure the text doesn't repeat the prompt
        lines = text.split('\n')
        cleaned_lines = []
        
        for line in lines:
            line = line.strip()
            if line and not line.startswith("Task:") and not line.startswith("Create"):
                cleaned_lines.append(line)
        
        return '\n'.join(cleaned_lines) if cleaned_lines else text

    def get_model_status(self) -> Dict[str, Any]:
        """Get the status of the AI model"""
        return {
            "model_name": self.model_name,
            "model_loaded": self.generator is not None,
            "using_local_model": self.use_local,
            "device": "cuda" if torch.cuda.is_available() and self.generator else "cpu",
            "max_length": self.max_length,
            "temperature": self.temperature
        }

    def reload_model(self):
        """Reload the model (useful for switching models or updating configuration)"""
        logger.info("Reloading AI model...")
        self.tokenizer = None
        self.model = None
        self.generator = None
        self._initialize_model()

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

    def get_user_content(
        self, 
        db: Session, 
        user_id: int, 
        content_type: Optional[str] = None,
        skip: int = 0,
        limit: int = 20
    ) -> List[AIContent]:
        """Get user's AI generated content"""
        query = db.query(AIContent).filter(AIContent.user_id == user_id)
        
        if content_type:
            query = query.filter(AIContent.content_type == content_type)
        
        return (
            query.order_by(AIContent.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

    def toggle_favorite(
        self, db: Session, *, content_id: int, user_id: int
    ) -> Optional[AIContent]:
        """Toggle favorite status of AI content"""
        content = (
            db.query(AIContent)
            .filter(
                AIContent.id == content_id,
                AIContent.user_id == user_id
            )
            .first()
        )
        
        if content:
            content.is_favorite = not content.is_favorite
            db.add(content)
            db.commit()
            db.refresh(content)
        
        return content

    def increment_usage(
        self, db: Session, *, content_id: int, user_id: int
    ) -> Optional[AIContent]:
        """Increment usage count when content is used"""
        content = (
            db.query(AIContent)
            .filter(
                AIContent.id == content_id,
                AIContent.user_id == user_id
            )
            .first()
        )
        
        if content:
            content.usage_count += 1
            db.add(content)
            db.commit()
            db.refresh(content)
        
        return content

    # Content suggestions based on user data
    def suggest_content_ideas(
        self, db: Session, user_id: int, content_type: str
    ) -> List[str]:
        """Generate content ideas based on user's previous content and performance"""
        # This would analyze user's past content and suggest new ideas
        # For now, return some general suggestions
        suggestions = {
            "copywriting": [
                "Limited time flash sale announcement",
                "Customer testimonial highlights",
                "Behind-the-scenes product story",
                "Seasonal product recommendations",
                "Bundle deal promotions"
            ],
            "script": [
                "Product unboxing and first impressions",
                "Comparison between similar products",
                "Q&A session with viewers",
                "Tutorial or how-to demonstration",
                "Customer success stories"
            ],
            "description": [
                "Eco-friendly product benefits",
                "Premium quality materials focus",
                "Versatility and multiple uses",
                "Problem-solving capabilities",
                "Value for money proposition"
            ]
        }
        
        return suggestions.get(content_type, [])

ai_content_service = AIContentService()
