# Sectioned Content Generation Guide

Your TikBoost backend now supports **sectioned content generation**, allowing you to generate specific parts of content separately and combine them as needed.

## 🎯 Why Sectioned Generation?

Since you've fine-tuned your model with specific prompts and outputs, sectioned generation allows you to:

- **Generate only what you need** - Create just a "call-to-action" or "product benefits"
- **Mix and match sections** - Combine different sections for various use cases
- **Regenerate specific parts** - Fix only the sections that need improvement
- **A/B test sections** - Try different versions of specific parts
- **Customize content structure** - Define your own section types

## 📋 Available Section Types

### Copywriting Sections
- **hook** - Attention-grabbing opening that stops scrolling
- **problem** - Pain point or problem identification
- **solution** - Product/service as the solution
- **benefits** - Key benefits and value propositions
- **social_proof** - Testimonials or credibility indicators
- **urgency** - Limited time offers or scarcity
- **call_to_action** - Clear directive for next steps
- **closing** - Memorable closing statement

### Live Script Sections
- **opening** - Welcoming viewers and introduction
- **product_intro** - Product introduction and presentation
- **demonstration** - Product demo or usage examples
- **features** - Key features and specifications
- **benefits** - How it solves problems/improves life
- **testimonials** - Customer reviews and feedback
- **pricing** - Price reveal and value justification
- **urgency** - Limited time offers or bonuses
- **q_and_a** - Addressing common questions
- **call_to_action** - How to purchase instructions
- **closing** - Thank you and final encouragement

### Product Description Sections
- **headline** - Product name and key selling point
- **overview** - Brief product summary
- **features** - Technical specifications and features
- **benefits** - Customer benefits and use cases
- **materials** - Materials, quality, and construction
- **dimensions** - Size, weight, and measurements
- **usage** - How to use and care instructions
- **warranty** - Guarantee and warranty information
- **reviews** - Customer feedback highlights

## 🚀 API Usage Examples

### 1. Get Available Sections
```bash
GET /api/v1/ai-content/sections/copywriting
```

Response:
```json
{
  "content_type": "copywriting",
  "available_sections": {
    "hook": "Attention-grabbing opening that stops scrolling",
    "benefits": "Key benefits and value propositions",
    "call_to_action": "Clear directive for next steps"
  },
  "total_sections": 8
}
```

### 2. Generate Specific Sections
```bash
POST /api/v1/ai-content/generate-sections
```

Request:
```json
{
  "content_type": "copywriting",
  "base_prompt": "wireless bluetooth headphones",
  "sections_wanted": ["hook", "benefits", "call_to_action"],
  "context": "Premium quality, 30-hour battery",
  "merge_sections": true
}
```

Response:
```json
{
  "content": {
    "id": 123,
    "content_type": "copywriting",
    "title": "Sectioned Copywriting - wireless bluetooth headphones...",
    "content": "🎵 Stop everything! Your ears deserve better...\n\n✅ 30-hour battery life means...\n\n👆 Click 'Buy Now' and transform your audio experience today!"
  },
  "sections": [
    {
      "section_name": "hook",
      "section_type": "hook",
      "content": "🎵 Stop everything! Your ears deserve better..."
    },
    {
      "section_name": "benefits", 
      "section_type": "benefits",
      "content": "✅ 30-hour battery life means..."
    },
    {
      "section_name": "call_to_action",
      "section_type": "call_to_action", 
      "content": "👆 Click 'Buy Now' and transform your audio experience today!"
    }
  ],
  "available_sections": ["hook", "problem", "solution", "benefits", "social_proof", "urgency", "call_to_action", "closing"],
  "generated_sections": ["hook", "benefits", "call_to_action"]
}
```

### 3. Regenerate Single Section
```bash
POST /api/v1/ai-content/regenerate-section?content_type=copywriting&section_name=call_to_action&base_prompt=fitness%20tracker&context=health%20conscious%20audience
```

Response:
```json
{
  "section_name": "call_to_action",
  "section_type": "call_to_action",
  "content": "🏃‍♀️ Ready to transform your fitness journey? Grab your tracker now and get FREE shipping plus a 30-day money-back guarantee!",
  "content_type": "copywriting",
  "base_prompt": "fitness tracker"
}
```

### 4. Custom Sections
```bash
POST /api/v1/ai-content/generate-custom-sections
```

Request:
```json
{
  "content_type": "copywriting",
  "base_prompt": "eco-friendly water bottle",
  "custom_sections": {
    "environmental_impact": "Explain how this product helps the environment",
    "health_benefits": "Focus on health advantages",
    "lifestyle_upgrade": "Show how it improves daily life"
  },
  "context": "Sustainability-focused audience"
}
```

## 🛠️ Integration with Your Fine-Tuned Model

### Prompt Format for Sections

Your fine-tuned model receives section-specific prompts in this format:

```
<|system|>
You are an expert copywriting writer. Generate ONLY the hook section.

Section Purpose: Attention-grabbing opening that stops scrolling

Rules:
- Write only for this specific section
- Keep it focused and concise
- Match the tone for copywriting
- Don't include other sections or repeat content
- Be natural and engaging

<|user|>
Create hook section for: wireless bluetooth headphones
Context: Premium quality, 30-hour battery

Section needed: hook (Attention-grabbing opening that stops scrolling)

<|assistant|>
```

### Training Data Structure

If you want to further optimize your model for sectioned generation, consider training data like:

```
Input: <|system|>You are an expert copywriting writer. Generate ONLY the benefits section...<|user|>Create benefits section for: smartphone camera<|assistant|>
Output: ✅ Professional-quality photos in any lighting\n✅ AI-powered portrait mode for stunning selfies\n✅ 4K video recording for memories that last forever
```

## 💡 Use Cases & Best Practices

### 1. **Rapid Content Creation**
```python
# Generate just what you need quickly
sections = ["hook", "call_to_action"]
result = generate_sections("copywriting", "new product launch", sections)
```

### 2. **A/B Testing Different Sections**
```python
# Test different hooks for the same product
hook_v1 = regenerate_section("copywriting", "hook", "fitness app")
hook_v2 = regenerate_section("copywriting", "hook", "fitness app") 
# Compare performance
```

### 3. **Content Templates**
```python
# Create reusable section combinations
email_template = ["hook", "problem", "solution", "call_to_action"]
social_template = ["hook", "benefits", "urgency"] 
landing_page = ["hook", "benefits", "social_proof", "call_to_action"]
```

### 4. **Iterative Improvement**
```python
# Generate full content first
full_content = generate_content("copywriting", "product")

# Then improve specific sections
better_cta = regenerate_section("copywriting", "call_to_action", "product")
# Replace the CTA in full_content with better_cta
```

### 5. **Dynamic Content Assembly**
```python
# Mix sections based on audience
young_audience = ["hook", "benefits", "social_proof", "urgency"]
business_audience = ["problem", "solution", "features", "call_to_action"]
```

## 🎨 Custom Section Examples

### E-commerce Specific
```python
custom_sections = {
    "unboxing_excitement": "Create anticipation about the unboxing experience",
    "comparison_killer": "Compare favorably to competitors without naming them", 
    "guarantee_confidence": "Emphasize guarantees and return policies",
    "limited_stock_urgency": "Create urgency with stock limitations"
}
```

### Live Commerce Specific
```python
live_sections = {
    "viewer_interaction": "Encourage comments and engagement",
    "flash_deal_announcement": "Announce time-limited deals",
    "behind_scenes": "Share behind-the-scenes product insights",
    "viewer_testimonial": "Read and respond to live viewer feedback"
}
```

## 🔧 Advanced Configuration

### Model Parameters per Section
You can fine-tune generation parameters for different sections:

```python
# In your .env file
MAX_TOKEN_LENGTH=1000
MODEL_TEMPERATURE=0.7    # Default
HOOK_TEMPERATURE=0.9     # More creative for hooks
CTA_TEMPERATURE=0.5      # More focused for CTAs
```

### Section Dependencies
Some sections work better together:

```python
# Recommended combinations
persuasive_flow = ["hook", "problem", "solution", "benefits", "call_to_action"]
social_proof_flow = ["hook", "benefits", "testimonials", "urgency", "call_to_action"]
educational_flow = ["problem", "solution", "features", "benefits", "usage"]
```

## 📊 Performance Monitoring

Track section performance:
- Which sections get regenerated most?
- What section combinations perform best?
- Which custom sections are most effective?

## 🚀 Getting Started

1. **Test the demo script:**
   ```bash
   python demo_sectioned_generation.py
   ```

2. **Start with standard sections:**
   Use the predefined sections for your content type

3. **Experiment with combinations:**
   Try different section combinations for different use cases

4. **Create custom sections:**
   Define sections specific to your business needs

5. **Monitor and optimize:**
   Track which sections work best for your audience

Your fine-tuned model now gives you **granular control** over content generation, allowing you to create exactly what you need, when you need it! 🎯
