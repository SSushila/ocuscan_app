# OcuScan Flutter

**OcuScan** is a cross-platform mobile application designed for AI-assisted retinal disease screening and patient management. This is the **Flutter port** of the original OcuScan app, migrated from React Native/Expo.

It includes user authentication, onboarding flows, patient management features, and integration with a backend prediction API. All screens and logic have been redesigned for a responsive and consistent Flutter experience.

---

## ✨ Features

- 🔐 Sign In / Sign Up  
- 👋 Onboarding for first-time users  
- 🧑‍⚕️ Patient list with records  
- 🔒 Secure session storage using `flutter_secure_storage`  
- 📱 Responsive UI supporting both Android and iOS  
- 🧠 Backend integration with a FastAPI + PyTorch inference model  

---

## 🚀 Getting Started

### 1. 📲 Set Up the Flutter App

> ⚠️ Note: This repository excludes the Android build folder and the backend model file (`best_vit_model.pth`) to reduce size. Please follow the steps below to reinitialize both components locally.

#### Prerequisites

- Flutter SDK: [Install Flutter](https://docs.flutter.dev/get-started/install)
- Android Studio or Xcode (for emulator or device testing)
- Python 3.8+ with `pip`

#### Frontend Setup

```bash
git clone https://github.com/Ssushila/ocuscan_flutter.git
cd ocuscan_flutter
flutter clean
flutter pub get
flutter run
````

> The app uses `go_router` for navigation and `flutter_secure_storage` for safely managing user sessions.

---

### 2. Set Up the Backend Prediction Server

This app interacts with a machine learning model via a FastAPI backend.

#### Backend Setup Steps

```bash
cd backend
pip install -r requirements.txt
# Re-download the model if not present
# Place 'best_vit_model.pth' inside the 'Model/' folder

uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

* Visit [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) to verify the API is live.
* The Flutter app will send retina scan images to `http://10.0.2.2:8000/predict` (Android emulator default for localhost).

---

## Project Structure

```
lib/
├── main.dart           # App entry point
├── screens/            # All major screens (SignIn, CreateAccount, Onboarding, Patients, About, NewPatient)
├── widgets/            # Shared reusable widgets
└── services/           # Auth, secure storage, and Supabase API logic
```

---

##  Notes

* The backend model (`best_vit_model.pth`) is not included in this repo for size and licensing reasons.
* The Android `/build` folder and iOS derived data are also excluded.
* You’ll need to re-train or download the pretrained model to run predictions.
* The backend folder includes a working FastAPI app that loads the model and performs inference.

---

## Contributions & Support

If you find bugs or want to request new features, please open an [issue](https://github.com/Ssushila/ocuscan_flutter/issues) or submit a pull request.

For questions or collaboration inquiries, feel free to reach out.
