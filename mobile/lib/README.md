# TikBoost - AI-Powered Livestream Selling Assistant

A modern Flutter mobile app that serves as an AI-powered assistant for livestream selling on TikTok and other platforms.

## Features

TikBoost includes five main screens:

1. **Dashboard Screen** - Performance metrics and AI recommendations
2. **AI Content Screen** - Smart suggestions for content optimization
3. **Planner Screen** - Calendar and session management
4. **Notifications Screen** - Real-time alerts and actionable notifications
5. **Products Screen** - Product management and bundle creation

## Architecture

The app follows a modular architecture with clear separation of concerns:

### Directory Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models
│   ├── dashboard_models.dart # Dashboard-related models
│   ├── content_models.dart   # Content and session models
│   └── product_models.dart   # Product and notification models
├── screens/                  # Main app screens
│   ├── dashboard_screen.dart
│   ├── ai_content_screen.dart
│   ├── planner_screen.dart
│   ├── notifications_screen.dart
│   └── products_screen.dart
├── widgets/                  # Reusable UI components
│   ├── common_widgets.dart   # Generic widgets (AppCard, AppButton, etc.)
│   ├── dashboard_widgets.dart
│   ├── content_widgets.dart
│   └── product_widgets.dart
└── utils/                    # App utilities and constants
    ├── app_colors.dart       # Color palette definitions
    ├── app_theme.dart        # App theme configuration
    └── app_constants.dart    # App-wide constants
```

## Design System

### Color Palette
- **Background**: Dark theme with card overlays
- **Accent Colors**: Beige, soft peach, light gray, muted green
- **System Colors**: Success, warning, error states
- **Brand Colors**: Orange accent (#FF6B35)

### UI Components
- **AppCard**: Reusable container with consistent styling
- **AppButton**: Customizable button component
- **IconContainer**: Consistent icon display
- **MetricCard**: Performance metrics display
- **NotificationCard**: Actionable notification items

## Key Features

### Modular Design
- **Separation of Concerns**: Each screen, widget, and utility has a specific responsibility
- **Reusable Components**: Common UI elements are abstracted into reusable widgets
- **Consistent Styling**: Centralized theme and color management
- **Type Safety**: Strong typing with custom models for all data structures

### Scalability
- **Easy Extension**: New screens can be added by following the established patterns
- **Component Library**: Rich set of pre-built components for rapid development
- **Theme Consistency**: All visual elements follow the design system
- **Data Models**: Structured data handling with proper type definitions

### Best Practices
- **Clean Architecture**: Clear separation between UI, business logic, and data
- **Consistent Naming**: Following Flutter/Dart naming conventions
- **Error Handling**: Proper error states and loading indicators
- **Performance**: Efficient widget structure and minimal rebuilds

## Usage

Each screen demonstrates different aspects of the app:

1. **Dashboard**: Real-time metrics with AI-powered recommendations
2. **AI Content**: Content optimization suggestions with actionable insights
3. **Planner**: Calendar integration with session scheduling
4. **Notifications**: Priority-based notification system
5. **Products**: E-commerce features with bundle management

## Getting Started

1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Customization

The modular structure makes it easy to:
- Add new screens by creating them in `screens/` and adding to navigation
- Create new widgets by following patterns in `widgets/`
- Modify colors and theme in `utils/app_colors.dart` and `utils/app_theme.dart`
- Add new data models in `models/` directory
- Extend functionality by following established patterns

## Dependencies

- Flutter SDK
- Material Design Components
- Standard Flutter widgets and icons

The app uses only core Flutter dependencies to maintain simplicity and performance.
