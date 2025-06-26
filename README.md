# OcuScan Flutter

This is the Flutter port of the OcuScan app. It includes authentication, onboarding, patient management, and secure session storage. All screens and logic are migrated from the original React Native/Expo project.

## Features
- Sign In / Sign Up
- Onboarding
- Patient List
- Secure session storage
- Responsive UI

## Getting Started
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Run `flutter pub get`
3. Run `flutter run`

## Project Structure
- `lib/` - Main Dart code
  - `main.dart` - Entry point
  - `screens/` - All screens (SignIn, CreateAccount, Onboarding, Patients, About, NewPatient)
  - `widgets/` - Shared widgets
  - `services/` - Secure storage and auth logic

## Notes
- Uses `flutter_secure_storage` for storing sensitive data
- Uses `go_router` for navigation
- UI styled to match the original app

---

If you have any issues or want to request features, please open an issue.
