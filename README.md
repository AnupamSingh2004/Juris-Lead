### 🎯 Mission

IPC Justice Aid democratizes access to justice by:

- **Empowering Citizens**: Free AI-powered analysis of legal incidents under the Indian Penal Code
- **Connecting Legal Professionals**: Streamlined lead generation with pre-screened, structured case summaries
- **Bridging the Gap**: Eliminating confusion and inefficiencies in the legal consultation process

## 🏗️ Architecture

This project consists of three main components:

```
├── backend/           # Django REST API + AI Integration (Docker)
├── web-frontend/      # Next.js Web Application
└── frontend/          # Flutter Mobile Application
```

### 📱 Two-Sided Platform

#### **Citizen Platform** (Free)
- Anonymous incident analysis
- Structured legal reports
- Lawyer connection portal
- Downloadable PDF summaries

#### **Professional Dashboard** (Subscription-based)
- Real-time case leads
- Advanced filtering by IPC sections
- Secure contact system
- Lead management tools

## 🚀 Quick Start

### Prerequisites

- **Backend**: Docker & Docker Compose
- **Web Frontend**: Node.js 18+, Next.js 14+
- **Mobile App**: Flutter 3.0+, Dart SDK
- **AI Services**: OpenAI API key or Claude API key

### 🔧 Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/your-username/ipc-justice-aid.git
cd ipc-justice-aid
```

#### 2. Backend Setup (Django with Docker)

```bash
cd backend

# Environment setup
cp .env.example .env
# Edit .env with your configuration

# Build and run with Docker Compose
docker-compose up --build

# Run migrations (in a new terminal)
docker-compose exec web python manage.py makemigrations
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser

# Backend will be available at http://localhost:8000
```

#### 3. Web Frontend Setup (Next.js)

```bash
cd web-frontend

# Install dependencies
npm install

# Environment setup
cp .env.local.example .env.local
# Edit .env.local with your configuration

# Run development server
npm run dev
```

#### 4. Mobile App Setup (Flutter)

```bash
cd frontend

# Get dependencies
flutter pub get

# Environment setup
cp lib/config/env.example.dart lib/config/env.dart
# Edit env.dart with your configuration

# Run on device/emulator
flutter run
```

## 📁 Project Structure

### Backend (Django - Dockerized)

```
backend/
├── core/                 # Core Django settings
├── apps/
│   ├── authentication/   # User management & JWT
│   ├── ai_analysis/      # AI incident analysis
│   ├── case_management/  # Case leads & matching
│   ├── lawyer_dashboard/ # Professional features
│   └── notifications/    # Email & messaging
├── utils/               # Shared utilities
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── manage.py
```

### Web Frontend (Next.js)

```
web-frontend/
├── src/
│   ├── app/             # App Router pages
│   ├── components/      # Reusable UI components
│   ├── lib/            # Utilities & API calls
│   ├── hooks/          # Custom React hooks
│   └── types/          # TypeScript definitions
├── public/             # Static assets
└── package.json
```

### Mobile App (Flutter)

```
frontend/
├── lib/
│   ├── core/           # Core utilities & constants
│   ├── features/       # Feature-based modules
│   │   ├── analysis/   # Incident analysis
│   │   ├── auth/       # Authentication
│   │   └── dashboard/  # Lawyer dashboard
│   ├── shared/         # Shared widgets & services
│   └── main.dart
└── pubspec.yaml
```

## 🔗 API Endpoints

### Public Endpoints

- `POST /api/analyze/` - Analyze legal incident
- `POST /api/lawyer-connect/` - Submit lawyer connection request
- `GET /api/download-pdf/{case_id}/` - Download case summary PDF

### Protected Endpoints (Lawyers)

- `GET /api/dashboard/leads/` - Get case leads
- `POST /api/dashboard/express-interest/` - Express interest in case
- `GET /api/dashboard/analytics/` - Get dashboard analytics

## 🧪 Testing

### Backend Tests

```bash
cd backend
# Run tests inside Docker container
docker-compose exec web python manage.py test

# Or run specific test modules
docker-compose exec web python manage.py test apps.ai_analysis.tests
```

### Frontend Tests

```bash
cd web-frontend
npm run test
```

### Mobile Tests

```bash
cd frontend
flutter test
```

## 🚀 Deployment

### Backend (Django with Docker)

```bash
# Production deployment
docker-compose -f docker-compose.prod.yml up --build -d

# Or build and push to registry
docker build -t ipc-justice-aid-backend .
docker tag ipc-justice-aid-backend your-registry/ipc-justice-aid-backend:latest
docker push your-registry/ipc-justice-aid-backend:latest
```

### Web Frontend (Next.js)

```bash
# Build for production
npm run build
npm start

# Or deploy to Vercel
vercel deploy
```

### Mobile App (Flutter)

```bash
cd frontend

# Build APK for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 🔐 Environment Variables

### Backend (.env)

```env
# Django Configuration
SECRET_KEY=your-django-secret-key
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

# Database (handled by docker-compose)
DATABASE_URL=postgresql://postgres:password@db:5432/ipc_justice_aid

# AI Services
OPENAI_API_KEY=your-openai-api-key
CLAUDE_API_KEY=your-claude-api-key

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Payment Gateway
STRIPE_PUBLIC_KEY=your-stripe-public-key
STRIPE_SECRET_KEY=your-stripe-secret-key

# Redis (for caching and celery)
REDIS_URL=redis://redis:6379/0
```

### Web Frontend (.env.local)

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=your-stripe-public-key
```

### Mobile App (lib/config/env.dart)

```dart
class Environment {
  static const String apiUrl = 'http://localhost:8000/api';
  static const String stripePublishableKey = 'your-stripe-public-key';
}
```

## 📋 Development Roadmap

### Phase 1: Core Platform (Current)
- [x] AI incident analysis
- [x] Basic lawyer dashboard
- [x] PDF report generation
- [ ] Payment integration
- [ ] Email notifications

### Phase 2: Enhanced Features
- [ ] Document upload analysis
- [ ] Advanced filtering
- [ ] Analytics dashboard
- [ ] Mobile app optimization

### Phase 3: Expansion
- [ ] Multi-language support
- [ ] Integration with legal databases
- [ ] API for third-party integrations
- [ ] International expansion

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/your-username/ipc-justice-aid/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-username/ipc-justice-aid/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/ipc-justice-aid/discussions)

## 👥 Team

- **Project Lead**: [Your Name](https://github.com/your-username)
- **Backend Developer**: [Name](https://github.com/username)
- **Frontend Developer**: [Name](https://github.com/username)
- **Mobile Developer**: [Name](https://github.com/username)

## 🙏 Acknowledgments

- Indian Penal Code legal framework
- OpenAI/Anthropic for AI capabilities
- Open source community
- Legal professionals who provided guidance

---

**⚖️ Making Justice Accessible for Everyone**# IPC Justice Aid 🏛️⚖️

**Democratizing Access to Justice through AI-Powered Legal Analysis**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black.svg)](https://nextjs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Django](https://img.shields.io/badge/Django-4.2+-green.svg)](https://www.djangoproject.com/)

## 📖 Overview

IPC Justice Aid is a legal-tech SaaS platform that bridges the gap between citizens facing legal challenges and legal professionals. Our AI-powered system analyzes incidents under the Indian Penal Code (IPC) and connects users with qualified lawyers through structured case summaries and lead generation.

### 🎯 Mission

IPC Justice Aid democratizes access to justice by: