# TikBoost Backend API

AI-powered livestream selling assistant backend ## 🚦 Getting Started

### Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Hugging Face Token

> 📖 **Detailed Setup Guide**: See [HUGGINGFACE_SETUP.md](./HUGGINGFACE_SETUP.md) for complete instructions on configuring your custom model.th FastAPI.

## 🚀 Features

3. **Configure Environment**
   ```bash4. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Hugging Face model and API keys
   ``` Edit .env file with your settings
   HUGGINGFACE_API_TOKEN=your-huggingface-token
   HUGGINGFACE_MODEL_NAME=your-username/your-model-name
   SECRET_KEY=your-super-secret-key
   ```thentication & User Management** - JWT-based authentication with user profiles
- **Live Session Management** - Schedule, track, and analyze live streaming sessions
- **AI Content Generation** - Custom fine-tuned model via Hugging Face
- **Product Management** - Product catalog with bundling and performance analytics
- **Real-time Analytics** - Track viewers, engagement, and revenue metrics
- **Smart Notifications** - Automated alerts and recommendations
- **Background Tasks** - Celery-powered async processing

## 🏗️ Tech Stack

- **Framework**: FastAPI (Python 3.11+)
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Cache**: Redis
- **AI**: Custom Hugging Face Model
- **Background Tasks**: Celery
- **Authentication**: JWT with OAuth2
- **API Documentation**: Swagger/OpenAPI
- **Containerization**: Docker & Docker Compose

## 📁 Project Structure

```
backend/
├── app/
│   ├── api/
│   │   └── api_v1/
│   │       ├── endpoints/          # API endpoints
│   │       │   ├── auth.py
│   │       │   ├── users.py
│   │       │   ├── dashboard.py
│   │       │   ├── live_sessions.py
│   │       │   ├── products.py
│   │       │   ├── ai_content.py
│   │       │   └── notifications.py
│   │       └── api.py             # API router
│   ├── core/
│   │   ├── config.py              # App configuration
│   │   ├── database.py            # Database connection
│   │   └── security.py            # Security utilities
│   ├── models/
│   │   └── models.py              # SQLAlchemy models
│   ├── schemas/
│   │   └── schemas.py             # Pydantic models
│   ├── services/
│   │   ├── user_service.py        # User business logic
│   │   ├── analytics.py           # Analytics service
│   │   ├── live_session_service.py
│   │   ├── product_service.py
│   │   ├── ai_content_service.py
│   │   └── notification_service.py
│   └── utils/                     # Utility functions
├── migrations/                    # Database migrations
├── main.py                        # FastAPI app entry point
├── requirements.txt               # Python dependencies
├── docker-compose.yml             # Multi-service setup
├── Dockerfile                     # Container image
└── .env.example                   # Environment template
```

## 🚦 Getting Started

### Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- - **Hugging Face Token**

### Method 1: Quick Setup with Your Hugging Face Model

1. **Clone and Setup**
   ```bash
   git clone <repository>
   cd TikBoost/backend
   cp .env.example .env
   ```

2. **Configure Your Model**
   ```bash
   # Edit .env file with your Hugging Face model details
   HUGGINGFACE_API_TOKEN=your-huggingface-token
   HUGGINGFACE_MODEL_NAME=your-username/your-model-name
   SECRET_KEY=your-super-secret-key
   ```

3. **Test Your Model**
   ```bash
   python test_model.py
   ```

4. **Start All Services**
   ```bash
   docker-compose up -d
   ```

5. **Access the API**
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs
   - Model Status: http://localhost:8000/api/v1/ai-content/model-status

### Method 2: Docker Compose (Recommended)

1. **Clone and Setup**
   ```bash
   git clone <repository>
   cd TikBoost/backend
   cp .env.example .env
   ```

2. **Configure Environment**
   ```bash
   # Edit .env file with your settings
   OPENAI_API_KEY=your-openai-api-key
   SECRET_KEY=your-super-secret-key
   ```

3. **Start All Services**
   ```bash
   docker-compose up -d
   ```

4. **Access the API**
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs
   - Flower (Celery): http://localhost:5555

### Method 3: Local Development

1. **Setup Python Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\\Scripts\\activate
   pip install -r requirements.txt
   ```

2. **Setup Database**
   ```bash
   # Install and start PostgreSQL
   createdb tikboost_db
   
   # Install and start Redis
   redis-server
   ```

3. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your database and API keys
   ```

4. **Run the Application**
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

## 🔑 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/test-token` - Validate token

### Dashboard
- `GET /api/v1/dashboard/` - Get dashboard data with metrics

### Users
- `GET /api/v1/users/me` - Get current user
- `PUT /api/v1/users/me` - Update current user

### Live Sessions
- `POST /api/v1/live-sessions/` - Create live session
- `GET /api/v1/live-sessions/` - Get user's live sessions
- `GET /api/v1/live-sessions/upcoming` - Get upcoming sessions
- `POST /api/v1/live-sessions/{id}/start` - Start session
- `POST /api/v1/live-sessions/{id}/end` - End session

### Products
- `POST /api/v1/products/` - Create product
- `GET /api/v1/products/` - Get user's products
- `GET /api/v1/products/top` - Get top performing products
- `POST /api/v1/products/bundles` - Create product bundle

### AI Content
- `POST /api/v1/ai-content/generate` - Generate AI content
- `POST /api/v1/ai-content/copywriting` - Generate copywriting
- `POST /api/v1/ai-content/script` - Generate live session script
- `POST /api/v1/ai-content/description` - Generate product description

### Notifications
- `GET /api/v1/notifications/` - Get notifications
- `GET /api/v1/notifications/unread` - Get unread notifications
- `POST /api/v1/notifications/{id}/read` - Mark as read

## 🤖 AI Features

### Custom Fine-Tuned Model
Your personalized AI model via Hugging Face supports:
- **Copywriting**: Sales copy, product descriptions, promotional content
- **Scripts**: Live session scripts with engagement tactics
- **Descriptions**: Detailed product descriptions
- **Custom Content**: Tailored to your fine-tuning data

### Model Configuration
- **GPU Acceleration**: Automatic CUDA support when available
- **Flexible Deployment**: Local or Hugging Face Hub models
- **Performance Tuning**: Adjustable parameters for optimal results
- **Caching**: Intelligent model and result caching

### Smart Recommendations
- Optimal live streaming times
- Product bundling suggestions
- Performance improvement tips
- Audience engagement strategies

## 📊 Analytics & Metrics

Track comprehensive metrics:
- **Viewer Analytics**: Real-time and historical viewer data
- **Engagement Metrics**: Interaction rates, peak times
- **Revenue Tracking**: Sales performance, conversion rates
- **Product Performance**: Best sellers, stock levels

## 🔐 Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Input validation with Pydantic
- SQL injection prevention
- CORS protection
- Rate limiting ready

## 🛠️ Development

### Running Tests
```bash
pytest
```

### Code Formatting
```bash
black .
isort .
```

### Database Migrations
```bash
# Generate migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head
```

### Adding New Dependencies
```bash
pip install <package>
pip freeze > requirements.txt
```

## 🚀 Production Deployment

### Environment Variables
Set these in production:
```bash
DATABASE_URL=postgresql://user:password@host:5432/db
REDIS_URL=redis://host:6379
SECRET_KEY=your-production-secret-key
HUGGINGFACE_API_TOKEN=your-huggingface-token
HUGGINGFACE_MODEL_NAME=your-username/your-model-name
ENVIRONMENT=production
DEBUG=False
```

### Docker Production
```bash
docker build -t tikboost-api .
docker run -d -p 8000:8000 --env-file .env tikboost-api
```

## 📝 API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support, email support@tikboost.com or create an issue on GitHub.

---

**TikBoost Backend** - Empowering live commerce with AI 🚀
