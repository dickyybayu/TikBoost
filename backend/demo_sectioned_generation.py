#!/usr/bin/env python3
"""
TikBoost Sectioned AI Content Generation Demo

This script demonstrates how to use the sectioned content generation
with your fine-tuned Hugging Face model.
"""

import requests
import json
from typing import List, Dict

# Configuration
API_BASE_URL = "http://localhost:8000/api/v1"
# You'll need to get this token by logging in first
JWT_TOKEN = "your-jwt-token-here"

headers = {
    "Authorization": f"Bearer {JWT_TOKEN}",
    "Content-Type": "application/json"
}

def get_available_sections(content_type: str) -> Dict:
    """Get available sections for a content type"""
    response = requests.get(
        f"{API_BASE_URL}/ai-content/sections/{content_type}",
        headers=headers
    )
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return {}

def generate_sectioned_content(content_type: str, prompt: str, sections: List[str], context: str = None):
    """Generate content with specific sections"""
    
    data = {
        "content_type": content_type,
        "base_prompt": prompt,
        "sections_wanted": sections,
        "context": context,
        "merge_sections": True
    }
    
    response = requests.post(
        f"{API_BASE_URL}/ai-content/generate-sections",
        headers=headers,
        json=data
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return None

def generate_single_section(content_type: str, section_name: str, prompt: str, context: str = None):
    """Generate only a specific section"""
    
    response = requests.post(
        f"{API_BASE_URL}/ai-content/regenerate-section",
        headers=headers,
        params={
            "content_type": content_type,
            "section_name": section_name,
            "base_prompt": prompt,
            "context": context
        }
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return None

def demo_copywriting_sections():
    """Demo sectioned copywriting generation"""
    print("🎯 COPYWRITING SECTIONS DEMO")
    print("=" * 50)
    
    # Get available sections
    sections_info = get_available_sections("copywriting")
    print(f"Available sections: {list(sections_info.get('available_sections', {}).keys())}")
    
    # Generate specific sections
    prompt = "wireless bluetooth headphones with noise cancellation"
    context = "Premium quality, 30-hour battery, comfortable fit"
    sections_wanted = ["hook", "benefits", "social_proof", "call_to_action"]
    
    print(f"\nGenerating sections: {sections_wanted}")
    print(f"Product: {prompt}")
    print(f"Context: {context}")
    
    result = generate_sectioned_content("copywriting", prompt, sections_wanted, context)
    
    if result:
        print("\n📝 GENERATED CONTENT:")
        print("-" * 30)
        print(result["content"]["content"])
        
        print("\n🔍 INDIVIDUAL SECTIONS:")
        for section in result["sections"]:
            print(f"\n**{section['section_name'].upper()}:**")
            print(section['content'])

def demo_script_sections():
    """Demo sectioned script generation"""
    print("\n\n🎬 LIVE SCRIPT SECTIONS DEMO")
    print("=" * 50)
    
    # Get available sections
    sections_info = get_available_sections("script")
    print(f"Available sections: {list(sections_info.get('available_sections', {}).keys())}")
    
    # Generate specific sections for live session
    prompt = "smartphone with amazing camera features"
    context = "Live session at 8 PM, expecting 500+ viewers"
    sections_wanted = ["opening", "product_intro", "demonstration", "pricing", "call_to_action"]
    
    print(f"\nGenerating sections: {sections_wanted}")
    print(f"Product: {prompt}")
    print(f"Context: {context}")
    
    result = generate_sectioned_content("script", prompt, sections_wanted, context)
    
    if result:
        print("\n📝 GENERATED SCRIPT:")
        print("-" * 30)
        print(result["content"]["content"])

def demo_single_section_regeneration():
    """Demo regenerating a single section"""
    print("\n\n🔄 SINGLE SECTION REGENERATION DEMO")
    print("=" * 50)
    
    # Regenerate just the "call_to_action" section
    prompt = "fitness tracker smartwatch"
    section_name = "call_to_action"
    
    print(f"Regenerating '{section_name}' section for: {prompt}")
    
    result = generate_single_section("copywriting", section_name, prompt)
    
    if result:
        print(f"\n📝 REGENERATED {section_name.upper()}:")
        print("-" * 30)
        print(result["content"])

def demo_custom_sections():
    """Demo custom section definitions"""
    print("\n\n🎨 CUSTOM SECTIONS DEMO")
    print("=" * 50)
    
    # Define custom sections
    custom_sections = {
        "intro_joke": "Start with a light, engaging joke related to the product",
        "problem_story": "Tell a relatable story about the problem this product solves",
        "transformation": "Describe the transformation after using the product",
        "limited_bonus": "Mention exclusive bonuses for live viewers only"
    }
    
    print(f"Custom sections: {list(custom_sections.keys())}")
    
    data = {
        "content_type": "copywriting",
        "base_prompt": "eco-friendly water bottle",
        "custom_sections": custom_sections,
        "context": "Environmental consciousness, health benefits"
    }
    
    response = requests.post(
        f"{API_BASE_URL}/ai-content/generate-custom-sections",
        headers=headers,
        json=data
    )
    
    if response.status_code == 200:
        result = response.json()
        print("\n📝 GENERATED CUSTOM CONTENT:")
        print("-" * 30)
        print(result["content"]["content"])
    else:
        print(f"Error: {response.status_code} - {response.text}")

def main():
    """Main demo function"""
    print("🤖 TikBoost Sectioned AI Content Generation Demo")
    print("=" * 60)
    
    # Check if API is accessible
    try:
        response = requests.get(f"{API_BASE_URL}/ai-content/model-status", headers=headers)
        if response.status_code == 200:
            status = response.json()
            print(f"✅ Model Status: {'Loaded' if status.get('model_loaded') else 'Not Loaded'}")
            print(f"📋 Model: {status.get('model_name')}")
            print(f"💻 Device: {status.get('device')}")
        else:
            print("❌ Could not connect to API. Please check:")
            print("1. Backend server is running (port 8000)")
            print("2. JWT_TOKEN is valid")
            print("3. You're authenticated")
            return
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection failed. Please start the backend server first.")
        return
    
    # Run demos
    demo_copywriting_sections()
    demo_script_sections()
    demo_single_section_regeneration()
    demo_custom_sections()
    
    print("\n\n🎉 Demo completed! Your fine-tuned model can now generate:")
    print("✅ Specific sections only (hook, benefits, call-to-action, etc.)")
    print("✅ Custom-defined sections")
    print("✅ Regenerate individual sections")
    print("✅ Merge sections into complete content")
    
    print("\n💡 Pro Tips:")
    print("- Use specific sections when you only need part of the content")
    print("- Regenerate sections that don't meet your standards")
    print("- Define custom sections for unique content needs")
    print("- Combine different sections for A/B testing")

if __name__ == "__main__":
    main()
