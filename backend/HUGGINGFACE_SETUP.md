# TikBoost - Hugging Face Model Setup Guide

This guide will help you configure TikBoost backend to use your fine-tuned Hugging Face model.

## 🎯 Prerequisites

1. **Hugging Face Account** with your fine-tuned model uploaded
2. **API Token** from Hugging Face Hub
3. **Python 3.11+** installed locally
4. **Git** installed (for Hugging Face Hub access)

## 🔧 Configuration Steps

### Step 1: Get Your Hugging Face API Token

1. Visit [Hugging Face Settings](https://huggingface.co/settings/tokens)
2. Create a new token with **READ** access
3. Copy the token for later use

### Step 2: Configure Environment Variables

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file with your model details:**
   ```bash
   # Hugging Face Configuration
   HUGGINGFACE_API_TOKEN=hf_your_token_here
   HUGGINGFACE_MODEL_NAME=your-username/your-model-name
   HUGGINGFACE_USE_LOCAL=false
   HUGGINGFACE_LOCAL_PATH=
   
   # Model Parameters (adjust based on your model's optimal settings)
   MAX_TOKEN_LENGTH=1000
   MODEL_TEMPERATURE=0.7
   MODEL_TOP_P=0.9
   MODEL_TOP_K=50
   
   # Database and other settings
   DATABASE_URL=postgresql://username:password@localhost/tikboost_db
   REDIS_URL=redis://localhost:6379
   SECRET_KEY=your-secret-key-here
   ```

### Step 3: Install Dependencies

```bash
# Install Python dependencies
pip install -r requirements.txt

# Login to Hugging Face Hub
huggingface-cli login
```

### Step 4: Test Your Model

Run the model test script to ensure everything is working:

```bash
python test_model.py
```

This script will:
- ✅ Check GPU availability
- ✅ Login to Hugging Face Hub
- ✅ Load your model and tokenizer
- ✅ Test text generation
- ✅ Verify the model works with TikBoost prompts

### Step 5: Start the Backend

```bash
# Start with development server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Or use Docker Compose
docker-compose up -d
```

## 📊 Model Integration Details

### Prompt Format

Your fine-tuned model will receive prompts in this format:

```
<|system|>
[System instruction for the task type]

<|user|>
Task: Create [content_type] for: [user_prompt]
Additional context: [optional_context]

<|assistant|>
```

### Content Types Supported

1. **Copywriting** - Sales copy and marketing content
2. **Scripts** - Live streaming session scripts
3. **Descriptions** - Product descriptions
4. **General** - Other content types

### API Endpoints

- **POST** `/api/v1/ai-content/generate` - Generate content
- **GET** `/api/v1/ai-content/model-status` - Check model status
- **POST** `/api/v1/ai-content/reload-model` - Reload model

## 🚀 Performance Optimization

### GPU Usage

If you have a CUDA-compatible GPU:
- The model will automatically use GPU acceleration
- Faster generation times
- Better performance for larger models

### Memory Management

For large models, consider:
- Using `torch.float16` precision (automatically enabled)
- Adjusting `MAX_TOKEN_LENGTH` based on your needs
- Setting appropriate batch sizes

### Local Model Usage

To use a locally downloaded model:

1. **Download your model:**
   ```bash
   git lfs clone https://huggingface.co/your-username/your-model-name
   ```

2. **Update environment variables:**
   ```bash
   HUGGINGFACE_USE_LOCAL=true
   HUGGINGFACE_LOCAL_PATH=/path/to/your/local/model
   ```

## 🔍 Troubleshooting

### Common Issues

**Issue: "Model not found"**
- ✅ Check model name spelling
- ✅ Verify your HF token has access to the model
- ✅ Ensure model is public or you have access

**Issue: "CUDA out of memory"**
- ✅ Reduce `MAX_TOKEN_LENGTH`
- ✅ Use CPU instead: set GPU unavailable
- ✅ Use model quantization

**Issue: "Token authentication failed"**
- ✅ Verify your HF API token
- ✅ Re-run `huggingface-cli login`
- ✅ Check token permissions

### Logging and Monitoring

The AI service includes comprehensive logging:
- Model loading status
- Generation performance
- Error tracking
- Usage metrics

Check logs at: `/api/v1/ai-content/model-status`

## 📈 Production Deployment

### Docker Deployment

The Docker configuration includes:
- Optimized Hugging Face cache
- GPU support (if available)
- Proper environment variable handling
- Health checks

### Environment Variables for Production

```bash
# Production settings
ENVIRONMENT=production
DEBUG=false

# Model caching
HF_HOME=/app/.cache/huggingface
TRANSFORMERS_CACHE=/app/.cache/huggingface

# Resource limits
MAX_TOKEN_LENGTH=500  # Adjust based on needs
```

### Scaling Considerations

- **Multiple Workers**: Use multiple Uvicorn workers
- **Load Balancing**: Distribute requests across instances
- **Model Caching**: Cache loaded models in memory
- **Queue System**: Use Celery for heavy generation tasks

## 🧪 Testing Your Integration

### Test Generation Endpoints

```bash
# Test copywriting generation
curl -X POST "http://localhost:8000/api/v1/ai-content/generate" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content_type": "copywriting",
    "prompt": "wireless bluetooth headphones sale",
    "context": "Premium quality, 30-hour battery life"
  }'

# Check model status
curl -X GET "http://localhost:8000/api/v1/ai-content/model-status" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Performance Benchmarking

Monitor:
- Generation time per request
- Memory usage
- GPU utilization
- Token/second throughput

## 💡 Best Practices

1. **Fine-tune for TikBoost**: Train your model on live commerce and social media content
2. **Optimize Prompts**: Use consistent prompt formats for better results
3. **Monitor Performance**: Track generation quality and user satisfaction
4. **Update Regularly**: Keep your model updated with new training data
5. **Cache Results**: Store frequently used generated content

## 🆘 Support

If you encounter issues:

1. Check the model test output: `python test_model.py`
2. Review API logs for detailed error messages
3. Verify your Hugging Face model is accessible
4. Ensure all environment variables are set correctly

---

Your TikBoost backend is now ready to use your custom fine-tuned model! 🚀
