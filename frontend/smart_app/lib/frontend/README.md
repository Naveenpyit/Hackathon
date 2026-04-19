# Frontend Architecture Guide

## Project Structure

```
lib/frontend/
├── config/                    # Configuration & Constants
│   ├── theme.dart            # Design system (colors, spacing, fonts)
│   └── strings.dart          # All UI text strings
│
├── core/                      # Core Utilities & Exceptions
│   ├── exceptions/
│   │   └── app_exceptions.dart
│   └── utils/
│       └── validation_utils.dart
│
├── presentation/              # UI Layer
│   └── screens/              # 6 Complete Screens
│       ├── welcome_screen.dart
│       ├── signin_screen.dart
│       ├── signup_screen.dart
│       ├── forgot_password_screen.dart
│       ├── email_verification_screen.dart
│       └── chats_screen.dart
│
├── data/                      # Future: Data Layer
└── domain/                    # Future: Domain Layer
```

## Getting Started

### Run the App
```bash
cd smart_app
flutter pub get
flutter run
```

### Build for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Best Practices

### 1. Use Theme Constants
```dart
// ✅ Correct
color: AppTheme.primaryColor
fontSize: AppTheme.fontSizeL

// ❌ Avoid
color: Color(0xFF0078D4)
fontSize: 16.0
```

### 2. Use String Constants
```dart
// ✅ Correct
Text(AppStrings.welcomeTitle)

// ❌ Avoid
Text('Welcome to Smart App')
```

### 3. Use Validation Utils
```dart
// ✅ Correct
validator: ValidationUtils.validateEmail

// ❌ Avoid
validator: (value) { /* inline validation */ }
```

## File Organization

- **config/**: Design tokens and text strings
- **core/**: Validation, exceptions, utilities
- **presentation/**: UI screens and widgets
- **data/**: API and database (future)
- **domain/**: Business logic (future)

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `welcome_screen.dart` |
| Classes | PascalCase | `WelcomeScreen` |
| Variables | camelCase | `_emailController` |
| Constants | UPPER_SNAKE_CASE | `AppTheme.primaryColor` |

---

For more information, check the project documentation files.
