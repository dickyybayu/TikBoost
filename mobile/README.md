# TikBoost - AI-Powered Livestream Selling Assistant

## Overview
TikBoost is a modern mobile app concept designed for AI-powered livestream selling assistance. The app features a comprehensive suite of tools to help streamers optimize their content, manage products, and engage with their audience effectively.

## Features

### 🏠 Dashboard
- **Performance Metrics**: Real-time viewer count, engagement rates, and revenue tracking
- **AI Recommendations**: Intelligent suggestions for optimal streaming times and strategies
- **Settings Access**: Quick access to app settings and theme preferences

### 🤖 AI Content Generator
- **Smart Suggestions**: AI-powered content ideas based on trends and performance
- **Content Templates**: Pre-built templates for different product categories
- **Performance Analytics**: Track which content performs best

### 📅 Smart Planner
- **Session Scheduling**: Plan and organize upcoming livestream sessions
- **AI-Powered Timing**: Get suggestions for optimal streaming windows
- **Calendar Integration**: Visual calendar with highlighted recommended dates

### 🔔 Notifications Hub
- **Real-time Alerts**: Instant notifications for viewer milestones and engagement spikes
- **AI Insights**: Smart notifications about trending topics and opportunities
- **Customizable Preferences**: Control which notifications you receive

### 📦 Product Management
- **Inventory Tracking**: Manage your product catalog with stock levels
- **Performance Metrics**: Track which products sell best during streams
- **Quick Actions**: Easy product adding and editing features

### ⚙️ Settings & Customization
- **Dark/Light Theme**: Toggle between light and dark themes for optimal viewing
- **Notification Preferences**: Customize alert types and frequencies
- **Account Management**: Profile settings and preferences
- **Security Options**: Privacy and security controls

## Theme System

### Light Theme
- **Primary Colors**: Soft beige and warm peach tones
- **Accent Color**: Muted green for highlights and actions
- **Background**: Clean white with subtle card shadows

### Dark Theme
- **Primary Colors**: Dark grays and deep backgrounds
- **Accent Color**: Same muted green for consistency
- **Background**: Rich dark tones optimized for night viewing

### Switching Themes
1. Go to the **Dashboard** screen
2. Tap the **Settings** icon in the top-right corner
3. Find the **Dark Mode** toggle in the Appearance section
4. Toggle the switch to change between light and dark themes
5. The change applies immediately across the entire app

## Architecture

The app follows a modular architecture pattern:

```
lib/
├── screens/           # Individual app screens
├── widgets/           # Reusable UI components
├── models/            # Data structures and types
├── utils/             # App-wide utilities and theming
└── main.dart          # App entry point
```

### Key Components
- **ThemeNotifier**: Manages app-wide theme state using ChangeNotifier
- **AppColors**: Dynamic color system that adapts to light/dark themes
- **AppTheme**: Centralized theme definitions for Material Design components
- **Modular Widgets**: Reusable components like AppCard, AppButton, MetricCard

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart 3.0+
- Chrome browser (for web testing)

### Installation
1. Clone the repository
2. Navigate to the mobile directory: `cd mobile`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run -d chrome`

### Development
The app is designed with hot reload in mind. Make changes to any Dart file and see them reflected immediately during development.
