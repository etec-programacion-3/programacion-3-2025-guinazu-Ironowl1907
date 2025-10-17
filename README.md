# Workout Tracker

A Flutter-based mobile application designed for serious lifters who want complete control over their workout tracking. Built entirely offline with local SQLite storage, this app gives you the freedom to create custom workouts, exercises, and muscle groups tailored to your training style.

## Features

- **Custom Workouts**: Create and manage personalized workout sessions
- **Custom Muscle Groups**: Define your own muscle group categorizations
- **Custom Exercises**: Build an exercise library that fits your training methodology
- **Routine Management**: Design and save workout routines for easy reuse
- **Advanced Analytics**: Track your progress with comprehensive analytics and insights
- **Completely Offline**: All data stored locally with SQLite - no internet connection required
- **Material Design**: Clean, intuitive interface following Google's Material Design guidelines

This app is built for lifters who know what they're doing and want full control over their training data without unnecessary hand-holding.

## Tech Stack

- **Framework**: Flutter 3.38
- **Language**: Dart
- **Database**: SQLite with sqflite ORM
- **Design**: Material Design

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK 3.38](https://docs.flutter.dev/get-started/install)
- [Android SDK](https://developer.android.com/studio) (for Android builds)
- Dart (included with Flutter)

### Platform-Specific Requirements

**For Android:**
- Android SDK
- Android Studio (recommended) or Android command-line tools

**For Linux Testing:**
- Linux development libraries (run `flutter doctor` for specific requirements)

## Installation

1. **Clone the repository**
```bash
git clone https://github.com/etec-programacion-3/programacion-3-2025-guinazu-Ironowl1907.git
cd programacion-3-2025-guinazu-Ironowl1907
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Verify your setup**
```bash
flutter doctor
```

## Running the App

### Development Mode (Linux)
```bash
flutter run -d linux
```

### Development Mode (Android)
Connect your Android device or start an emulator, then:
```bash
flutter run
```

### Build for Production

**Android APK (Release)**
```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Project Status

🚀 **Current Status**: MVP (Minimum Viable Product)

The app is functional and includes all core features. Contributions and feedback are welcome!

## Contributing

We welcome contributions of all types! Whether you're fixing bugs, adding features, improving documentation, or suggesting enhancements, your help is appreciated.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Important Notes

- The `main` branch is commit-blocked, so **all changes must go through Pull Requests**
- Please ensure your code follows the existing code style
- Test your changes thoroughly before submitting a PR
- Provide a clear description of what your PR does and why

## Database

The app uses SQLite for local data storage via the sqflite package. The database initializes empty on first launch - you populate it with your own workouts, exercises, and routines as you use the app.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*For lifters, by lifters. Track your gains your way.*
