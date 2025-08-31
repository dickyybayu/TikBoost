#!/usr/bin/env python3
"""
Hugging Face Model Setup and Testing Utility
"""
import os
import sys
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from huggingface_hub import login, HfFolder

def check_gpu():
    """Check GPU availability"""
    if torch.cuda.is_available():
        print(f"✅ GPU available: {torch.cuda.get_device_name(0)}")
        print(f"   Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
        return True
    else:
        print("⚠️  No GPU available, will use CPU")
        return False

def login_to_huggingface():
    """Login to Hugging Face Hub"""
    token = os.getenv("HUGGINGFACE_API_TOKEN")
    if not token:
        print("❌ HUGGINGFACE_API_TOKEN not found in environment")
        token = input("Please enter your Hugging Face API token: ")
    
    try:
        login(token=token, add_to_git_credential=True)
        print("✅ Successfully logged in to Hugging Face Hub")
        return True
    except Exception as e:
        print(f"❌ Error logging in: {e}")
        return False

def test_model(model_name: str, use_gpu: bool = False):
    """Test loading and running the model"""
    print(f"\n🚀 Testing model: {model_name}")
    
    try:
        # Load tokenizer
        print("Loading tokenizer...")
        tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            trust_remote_code=True
        )
        
        if tokenizer.pad_token is None:
            tokenizer.pad_token = tokenizer.eos_token
        
        print("✅ Tokenizer loaded successfully")
        
        # Load model
        print("Loading model...")
        model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16 if use_gpu else torch.float32,
            device_map="auto" if use_gpu else None,
            trust_remote_code=True
        )
        
        print("✅ Model loaded successfully")
        
        # Create pipeline
        print("Creating text generation pipeline...")
        generator = pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,
            device=0 if use_gpu else -1,
            torch_dtype=torch.float16 if use_gpu else torch.float32
        )
        
        print("✅ Pipeline created successfully")
        
        # Test generation
        print("\n🧪 Testing text generation...")
        test_prompt = """<|system|>
You are an expert copywriter specializing in live commerce and social media marketing.

<|user|>
Task: Create copywriting for: wireless bluetooth headphones sale

<|assistant|>
"""
        
        outputs = generator(
            test_prompt,
            max_new_tokens=100,
            temperature=0.7,
            top_p=0.9,
            top_k=50,
            do_sample=True,
            pad_token_id=tokenizer.pad_token_id,
            eos_token_id=tokenizer.eos_token_id,
            return_full_text=False
        )
        
        generated_text = outputs[0]['generated_text'].strip()
        print(f"\n📝 Generated content:")
        print("-" * 50)
        print(generated_text)
        print("-" * 50)
        
        print("\n✅ Model test completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Error testing model: {e}")
        return False

def main():
    """Main function"""
    print("🤖 TikBoost AI Model Setup and Testing")
    print("=" * 50)
    
    # Check GPU
    has_gpu = check_gpu()
    
    # Login to Hugging Face
    if not login_to_huggingface():
        print("Failed to login to Hugging Face Hub")
        return 1
    
    # Get model name
    model_name = os.getenv("HUGGINGFACE_MODEL_NAME")
    if not model_name:
        model_name = input("Please enter your Hugging Face model name (e.g., username/model-name): ")
    
    if not model_name:
        print("❌ Model name is required")
        return 1
    
    # Test model
    success = test_model(model_name, has_gpu)
    
    if success:
        print("\n🎉 Your model is ready to use with TikBoost!")
        print(f"\nTo use this model in your backend:")
        print(f"1. Set HUGGINGFACE_MODEL_NAME={model_name} in your .env file")
        print(f"2. Set HUGGINGFACE_API_TOKEN=your_token in your .env file")
        print(f"3. Restart your FastAPI server")
        return 0
    else:
        print("\n❌ Model test failed. Please check your configuration.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
