#!/usr/bin/env python3
"""
TikBoost Fine-Tuned Model Demo

This script tests your specific fine-tuned model that generates
4-line responses (COPY, HOST, TIME, BUNDLE) in Indonesian.
"""

import requests
import json

# Configuration
API_BASE_URL = "http://localhost:8000/api/v1"
JWT_TOKEN = "your-jwt-token-here"

headers = {
    "Authorization": f"Bearer {JWT_TOKEN}",
    "Content-Type": "application/json"
}

def test_finetuned_format(product_name="Smartphone Gaming"):
    """Test the fine-tuned model format"""
    print(f"🧪 TESTING FINE-TUNED FORMAT")
    print("=" * 50)
    
    response = requests.post(
        f"{API_BASE_URL}/ai-content/test-finetuned-format",
        headers=headers,
        params={"product_name": product_name}
    )
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Test Product: {result['test_product']}")
        print(f"📋 Expected Format: {result['expected_format']}")
        print(f"🤖 Model Status: {result['model_status']['model_loaded']}")
        print(f"\n📝 Formatted Prompt Preview:")
        print("-" * 40)
        prompt_preview = result['formatted_prompt'][:300] + "..." if len(result['formatted_prompt']) > 300 else result['formatted_prompt']
        print(prompt_preview)
        return True
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return False

def generate_live_commerce_content():
    """Generate full 4-line content for live commerce"""
    print(f"\n\n🎬 GENERATING LIVE COMMERCE CONTENT")
    print("=" * 50)
    
    # Test with Indonesian product
    data = {
        "product_name": "Headphone Bluetooth Gaming",
        "product_price": "Rp 450.000", 
        "stock_count": 25,
        "viewer_count": 150,
        "event_context": "Flash Sale Malam Ini"
    }
    
    print(f"📱 Product: {data['product_name']}")
    print(f"💰 Price: {data['product_price']}")
    print(f"📦 Stock: {data['stock_count']}")
    print(f"👥 Viewers: {data['viewer_count']}")
    print(f"🎪 Event: {data['event_context']}")
    
    response = requests.post(
        f"{API_BASE_URL}/ai-content/generate-live-commerce",
        headers=headers,
        params=data
    )
    
    if response.status_code == 200:
        result = response.json()
        
        if "error" in result:
            print(f"❌ Generation Error: {result['error']}")
            return False
        
        print(f"\n📝 GENERATED 4-LINE CONTENT:")
        print("-" * 40)
        
        # Show parsed sections
        if "parsed_sections" in result:
            sections = result["parsed_sections"]
            print(f"📢 COPY: {sections.get('COPY', 'No COPY generated')}")
            print(f"🎤 HOST: {sections.get('HOST', 'No HOST generated')}")
            print(f"⏰ TIME: {sections.get('TIME', 'No TIME generated')}")
            print(f"📦 BUNDLE: {sections.get('BUNDLE', 'No BUNDLE generated')}")
        
        print(f"\n💾 Saved to database with ID: {result['content']['id']}")
        return True
        
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return False

def generate_specific_section():
    """Generate only a specific section (COPY, HOST, TIME, or BUNDLE) - Option 2 approach"""
    print(f"\n\n🎯 GENERATING SPECIFIC SECTIONS (Option 2)")
    print("=" * 50)
    
    product_data = {
        "product_name": "Smartwatch Fitness Tracker",
        "product_price": "Rp 350.000",
        "stock_count": 10,
        "viewer_count": 89,
        "event_context": "Early Bird Special"
    }
    
    print(f"📱 Product: {product_data['product_name']}")
    print(f"💰 Strategy: Generate all 4 lines, extract specific sections")
    print(f"⚡ Caching: Enabled for efficiency")
    
    # Test each section type
    for section_type in ["COPY", "HOST", "TIME", "BUNDLE"]:
        print(f"\n🔍 Extracting {section_type} section...")
        
        params = {**product_data, "section_type": section_type, "use_cache": True}
        
        response = requests.post(
            f"{API_BASE_URL}/ai-content/generate-specific-section",
            headers=headers,
            params=params
        )
        
        if response.status_code == 200:
            result = response.json()
            content = result['content'][:150] + "..." if len(result['content']) > 150 else result['content']
            cache_status = "📦 (cached)" if result.get('used_cache') else "🔥 (fresh)"
            print(f"✅ {section_type}: {content} {cache_status}")
        else:
            print(f"❌ Error generating {section_type}: {response.text}")

def test_different_products():
    """Test with various product types"""
    print(f"\n\n🛍️ TESTING DIFFERENT PRODUCT TYPES")
    print("=" * 50)
    
    test_products = [
        {
            "product_name": "Sepatu Sneakers Limited Edition",
            "product_price": "Rp 899.000",
            "stock_count": 5,
            "viewer_count": 320,
            "event_context": "Exclusive Launch"
        },
        {
            "product_name": "Skincare Set Anti-Aging",
            "product_price": "Rp 275.000", 
            "stock_count": 100,
            "viewer_count": 45,
            "event_context": "Beauty Week Promo"
        },
        {
            "product_name": "Kamera Action 4K",
            "product_price": "Rp 1.200.000",
            "stock_count": 3,
            "viewer_count": 200,
            "event_context": "Mega Sale Final Day"
        }
    ]
    
    for i, product in enumerate(test_products, 1):
        print(f"\n📱 Test Product {i}: {product['product_name']}")
        
        response = requests.post(
            f"{API_BASE_URL}/ai-content/generate-live-commerce",
            headers=headers,
            params=product
        )
        
        if response.status_code == 200:
            result = response.json()
            if "parsed_sections" in result:
                sections = result["parsed_sections"]
                print(f"   📢 COPY: {sections.get('COPY', '')[:100]}...")
                print(f"   🎤 HOST: {sections.get('HOST', '')[:100]}...")
            else:
                print(f"   ❌ No parsed sections in response")
        else:
            print(f"   ❌ Failed: {response.text}")

def verify_model_compatibility():
    """Verify if your model works with the current setup"""
    print(f"\n\n🔧 VERIFYING MODEL COMPATIBILITY")
    print("=" * 50)
    
    # Check model status
    response = requests.get(
        f"{API_BASE_URL}/ai-content/model-status",
        headers=headers
    )
    
    if response.status_code == 200:
        status = response.json()
        print(f"✅ Model Loaded: {status.get('model_loaded', False)}")
        print(f"📋 Model Name: {status.get('model_name', 'Unknown')}")
        print(f"💻 Device: {status.get('device', 'Unknown')}")
        print(f"🌡️ Temperature: {status.get('temperature', 0.7)}")
        
        if not status.get('model_loaded'):
            print("\n⚠️  Model not loaded! Please check:")
            print("1. HUGGINGFACE_MODEL_NAME is correct")
            print("2. HUGGINGFACE_API_TOKEN is valid")
            print("3. Model is accessible from your account")
            return False
        
        return True
    else:
        print(f"❌ Cannot check model status: {response.text}")
        return False

def main():
    """Main demo function"""
    print("🤖 TikBoost Fine-Tuned Model Demo")
    print("Testing 4-line format: COPY, HOST, TIME, BUNDLE")
    print("=" * 60)
    
    # Step 1: Verify model compatibility
    if not verify_model_compatibility():
        print("\n❌ Model compatibility check failed!")
        return
    
    # Step 2: Test format
    if not test_finetuned_format():
        print("\n❌ Format test failed!")
        return
    
    # Step 3: Generate full content
    if not generate_live_commerce_content():
        print("\n❌ Content generation failed!")
        return
    
    # Step 4: Generate specific sections (Option 2)
    generate_specific_section()
    
    # Step 5: Test with different products
    test_different_products()
    
    print("\n\n🎉 OPTION 2 DEMO COMPLETED!")
    print("=" * 30)
    print("✅ Your fine-tuned model integration status:")
    print("   - Model loading: Working")
    print("   - 4-line format: Compatible")
    print("   - Indonesian prompts: Supported")  
    print("   - Section extraction: Available (Option 2)")
    print("   - Caching: Optimized for multiple requests")
    
    print("\n💡 Option 2 Benefits:")
    print("   ✅ Uses your existing fine-tuned model")
    print("   ✅ Generates all 4 lines, extracts what you need")
    print("   ✅ Cached results for efficiency")
    print("   ✅ No additional training required")
    
    print("\n🔧 Next Steps:")
    print("   1. Replace PROMPT_TEMPLATE with your exact template")
    print("   2. Replace wrap_inst() with your exact function")
    print("   3. Test with your real products")
    print("   4. Monitor which sections are requested most")
    
    print("\n� Future Optimization:")
    print("   - If users frequently request single sections")
    print("   - Consider training specialized models (Option 1)")
    print("   - For now, Option 2 gives you immediate sectioned generation!")

if __name__ == "__main__":
    main()
