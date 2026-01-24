# FORGE

**Your Ultimate Workout Companion for Strength Training**

Forge is a powerful mobile app built with Flutter for tracking workout progress, analyzing strength gains, and optimizing training programs. Designed specifically for powerlifters, street lifters, and armwrestlers.

## Documentation

**[Visit our documentation site](https://vdoro.github.io/Dyplom/)** for:
- Detailed analytics formulas
- Technical documentation
- Contributing guidelines
- User guides and tutorials

## Features

- **Advanced Analytics** - Track progress with strength coefficient, volume, frequency, and consistency metrics
- **Specialized Programs** - Pre-built programs for Powerlifting, Street Lifting, and Armwrestling
- **Smart Calendar** - Visual workout tracking with streaks and history
- **Body Weight Tracking** - Monitor weight changes over time with complete history
- **Personal Records** - Track 1RM and compare with world records
- **Customizable UI** - Personalize with custom avatars, themes, and colors
- **Cross-Platform** - Works on Android and iOS

## Quick Start

### Prerequisites

- Flutter SDK 3.6.2 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase project (optional, for authentication features)

### Installation

```bash
# Clone the repository
git clone https://github.com/Andezion/Forge
cd Forge

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Tech Stack

- **Framework**: Flutter 3.6.2+
- **Language**: Dart
- **State Management**: Provider 6.0.5
- **Backend**: Firebase (Auth, Firestore)
- **Local Storage**: SharedPreferences
- **Charts**: FL Chart 0.69.2
- **Calendar**: Table Calendar 3.0.9

## Analytics Formulas

Forge uses scientifically-backed formulas to calculate your progress:

### Strength Coefficient
```
Coefficient = (Σ(max_weight / first_weight) / exercise_count) × 100
```
- 100 = Baseline
- 150 = 50% stronger overall
- 200 = Doubled your strength

[See all formulas →](https://andezion.github.io/Forge/formulas.html)

## Architecture

```
lib/
├── constants/       # App-wide constants (colors, strings, styles)
├── models/          # Data models (Exercise, Workout, WorkoutHistory)
├── screens/         # UI screens
├── services/        # Business logic (DataManager, Analytics, Auth)
└── main.dart        # App entry point
```

[Full technical docs →](https://vdoro.github.io/Dyplom/technical.html)

## Contributing

We welcome contributions! Please read our [Contributing Guide](https://andezion.github.io/Forge/contributing.html) to get started.

### Quick Contribution Guide

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m "feat: your feature description"`
4. Push to branch: `git push origin feature/your-feature`
5. Open a Pull Request

### Code Standards

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter format .` before committing
- Run `flutter analyze` to check for issues
- Write tests for new features

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Screenshots

*(Add screenshots here once available)*

## Roadmap

- [ ] Cloud sync across devices
- [ ] AI-powered form check
- [ ] Social features (friends, shared workouts)
- [ ] Global leaderboards
- [ ] Wear OS / Apple Watch support
- [ ] Advanced analytics (predicted 1RM, deload recommendations)
- [ ] Exercise video library

## License

This project is licensed under the [MIT License](LICENSE)

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and supporters

## Contact

- **GitHub**: [@vdoro](https://github.com/vdoro)
- **Project**: [Forge](https://github.com/vdoro/Dyplom)
- **Documentation**: [https://vdoro.github.io/Dyplom/](https://vdoro.github.io/Dyplom/)

---

Built with 🔥 using Flutter & Firebase
