# AarogyaRekha Mobile App 📱

<div align="center">
  <img src="../screenshots/mobile-app/dashboard.png" alt="AarogyaRekha Dashboard" width="300"/>
</div>

**AarogyaRekha** - Your AI-powered health companion that predicts and prevents disease outbreaks before they happen.

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](../LICENSE)

## 🌟 Features

### 🤖 AI-Powered Health Assistant
- **Multilingual AI Chatbot** powered by Google Gemini
- **Personalized health recommendations** based on location and symptoms
- **24/7 health query support** in multiple Indian languages

### 📊 Disease Prediction & Alerts
- **Real-time risk assessment** for malaria, dengue, diarrhea, and malnutrition
- **Location-based alerts** with village-level granularity
- **Smart notifications** with color-coded risk zones (Green/Yellow/Red)

### 🗺️ Interactive Health Maps
- **Live risk visualization** with interactive maps
- **Geofenced alerts** for your specific location
- **Satellite data integration** for environmental health monitoring

### 👥 Multi-User Support
- **Rural Households** - Simple alerts and prevention tips
- **ASHA/Health Workers** - Field work interface and community monitoring
- **Tourists** - Travel health advisories and local risk warnings

### 📱 Core App Features
- **Google OAuth Authentication** - Secure and seamless login
- **Profile Management** - User preferences and health history
- **Prescription Management** - Upload and track prescriptions
- **Health Check** - Symptom assessment and recommendations
- **Notification Center** - Customizable alert preferences
- **Offline Support** - Core features work without internet

## 🛠️ Technology Stack

### Framework & Language
- **Flutter** 3.8.1 - Cross-platform mobile development
- **Dart** 3.8.1 - Programming language

### State Management & Architecture
- **Provider** 6.1.1 - State management
- **MVVM Architecture** - Clean separation of concerns
- **Service Layer** - API and business logic abstraction

### Key Dependencies
- **Google Sign-In** 6.1.5 - Authentication
- **Google Generative AI** 0.4.7 - AI chatbot integration
- **HTTP** 1.1.0 - API communication
- **Geolocator** 14.0.2 - Location services
- **Flutter Map** 8.1.1 - Interactive maps
- **Image Picker** 1.0.4 - Camera and gallery access
- **Flutter Secure Storage** 10.0.0 - Secure data storage

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / Xcode (for device testing)
- Google Maps API key
- Google OAuth credentials

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/aarogyarekha.git
   cd aarogyarekha/frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your configuration:
   ```env
   API_BASE_URL=http://localhost:8000/api/
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   GOOGLE_OAUTH_CLIENT_ID=your_google_oauth_client_id
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/                   # Configuration files
├── models/                   # Data models
│   ├── user_model.dart
│   ├── health_data_model.dart
│   └── alert_model.dart
├── screens/                  # UI Screens
│   ├── auth/                 # Authentication screens
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── dashboard_screen.dart # Main dashboard
│   ├── profile_screen.dart   # User profile
│   ├── chatbot_screen.dart   # AI chatbot
│   ├── risk_map_screen.dart  # Interactive maps
│   ├── alerts_screen.dart    # Alert center
│   ├── health_check_screen.dart
│   ├── notifications_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic & API
│   ├── api_service.dart      # Main API service
│   ├── auth_state.dart       # Authentication state
│   ├── location_service.dart # Location services
│   ├── gemini_service.dart   # AI chatbot service
│   ├── health_prediction_service.dart
│   └── alerts_service.dart
├── widgets/                  # Reusable UI components
│   ├── custom_app_bar.dart
│   ├── health_card.dart
│   ├── risk_indicator.dart
│   └── chat_bubble.dart
└── demo/                     # Demo and test files
```

## 🔧 Configuration

### API Configuration
Update the API base URL in your `.env` file:
```env
API_BASE_URL=https://your-backend-domain.com/api/
```

### Maps Configuration
Add your Google Maps API key:
```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### Authentication Setup
Configure Google OAuth:
```env
GOOGLE_OAUTH_CLIENT_ID=your_google_oauth_client_id
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing
```bash
# Run on Android emulator
flutter run

# Run on iOS simulator
flutter run -d ios

# Run on physical device
flutter run -d [device_id]
```

## 🏗️ Build & Deployment

### Android Build
```bash
# Debug build
flutter build apk

# Release build
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### iOS Build
```bash
# Debug build
flutter build ios

# Release build
flutter build ios --release
```

### Web Build (if supported)
```bash
flutter build web
```

## 🎨 UI/UX Guidelines

### Color Scheme
- **Primary**: `#2E7D8A` (Teal)
- **Secondary**: `#4CAF50` (Green)
- **Accent**: `#FF9800` (Orange)
- **Background**: `#F5F5F5` (Light Grey)
- **Text**: `#333333` (Dark Grey)

### Typography
- **Headers**: Poppins, Bold
- **Body**: Roboto, Regular
- **Captions**: Roboto, Light

### Design Principles
- **Accessibility First** - Support for screen readers and high contrast
- **Responsive Design** - Works on all screen sizes
- **Intuitive Navigation** - Clear information hierarchy
- **Consistent Branding** - Cohesive visual identity

## 📱 App Screens Overview

### 🏠 Dashboard
- Health status overview
- Risk indicators for your area
- Quick actions (Health Check, Chatbot, Alerts)
- Weather and environmental data

### 🤖 AI Chatbot
- Natural language health queries
- Multilingual support (Hindi, English, regional languages)
- Personalized health recommendations
- Symptom assessment

### 🗺️ Risk Map
- Interactive map with risk zones
- Real-time outbreak predictions
- Location-based alerts
- Historical trend analysis

### 👤 Profile
- User information and preferences
- Health history and records
- Notification settings
- Privacy and security options

### 📋 Health Check
- Symptom assessment questionnaire
- Risk evaluation based on location
- Personalized prevention tips
- Historical health data

### 🔔 Notifications
- Disease outbreak alerts
- Preventive health tips
- Weather-related health warnings
- Community health updates

## 🌍 Localization

### Supported Languages
- **English** (Primary)
- **Hindi** (हिंदी)
- **Bengali** (বাংলা)
- **Telugu** (తెలుగు)
- **Tamil** (தமிழ்)
- **Marathi** (मराठी)

### Adding New Languages
1. Create language files in `lib/l10n/`
2. Update `pubspec.yaml` with new locale
3. Run `flutter pub get`
4. Update UI strings to use localization

## 🔐 Security & Privacy

### Data Protection
- **Encrypted Storage** - Sensitive data stored securely
- **HTTPS Only** - All API communications encrypted
- **Token Management** - Secure authentication tokens
- **Privacy Controls** - User data preferences

### Permissions
- **Location** - For area-specific health alerts
- **Camera** - For prescription uploads
- **Storage** - For offline data caching
- **Notifications** - For health alerts

## 🐛 Troubleshooting

### Common Issues

**Build Errors**
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

**Location Issues**
```bash
# Check permissions in device settings
# Ensure location services are enabled
```

**API Connection Problems**
```bash
# Verify backend is running
# Check .env configuration
# Ensure network connectivity
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the code style guidelines
4. Write tests for new features
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style
- Follow [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Use `flutter analyze` to check for issues
- Run `flutter format .` before committing

## 📚 Resources

### Flutter Documentation
- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### Project-Specific Resources
- [API Documentation](../docs/api.md)
- [Contributing Guidelines](../CONTRIBUTING.md)
- [Backend Setup](../aarogyarekha-backend/README.md)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/aarogyarekha/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/aarogyarekha/discussions)
- **Email**: developers@aarogyarekha.in

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

<div align="center">
  <p><strong>AarogyaRekha</strong> - Drawing the Digital Line Between Health and Disease</p>
  <p>Made with ❤️ for India's Healthcare Future</p>
</div>
