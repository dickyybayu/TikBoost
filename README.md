# TikBoost - AI-Powered E-commerce Tool

Platform AI untuk mengoptimalkan penjualan online dengan rekomendasi copywriting dan strategi pemasaran yang dipersonalisasi.

## 🚀 Quick Start

### Mobile App (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

### Backend API (Python)
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

## 📱 Features

- **AI Copywriting**: 3 variasi copywriting untuk setiap produk
- **Bundle Recommendations**: Saran paket produk yang optimal
- **Sales Analytics**: Analisis performa dan timing penjualan
- **User Management**: Sistem login dan profil pengguna

## 🔧 Configuration

### RunPod API Setup
1. Daftar di [RunPod.ai](https://runpod.ai) dan dapatkan API key
2. Copy file config: `cp mobile/lib/config/runpod_config.example.dart mobile/lib/config/runpod_config.dart`
3. Edit file tersebut dengan credentials Anda

### Backend Environment
Create `backend/.env` file:
```
SECRET_KEY=your_secret_key_here
DATABASE_URL=sqlite:///./tikboost.db
RUNPOD_API_KEY=your_runpod_api_key
RUNPOD_ENDPOINT_ID=your_runpod_endpoint_id
```

## 🌐 Production Deployment

### Backend (Render.com)
1. Push code ke GitHub
2. Connect repository ke Render
3. Set root directory ke `backend`
4. Add environment variables

### Mobile App
Update `mobile/lib/config/environment.dart` dengan production URL backend.

## 📋 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: FastAPI (Python)
- **AI**: RunPod API
- **Database**: SQLite/PostgreSQL
- **Storage**: SharedPreferences + Backend persistence

## 🔗 API Endpoints

- `POST /api/v1/auth/login` - User authentication
- `POST /api/v1/auth/register` - User registration  
- `POST /api/v1/recommendations/save` - Save AI recommendations
- `GET /api/v1/recommendations/load` - Load saved recommendations

## 📄 License

MIT License - see LICENSE file for details.