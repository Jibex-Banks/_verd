# VERD

VERD is a Flutter app for crop health scanning and guidance.
It supports cloud AI analysis when online, local TensorFlow Lite inference when offline, and sync-friendly scan history backed by Firebase.

## Highlights

- Hybrid AI routing:
  - Online: image upload + Gemini analysis
  - Offline: on-device TFLite model fallback
- Crop scan workflow with result details and recommendations
- Scan history and persisted local storage (Hive)
- Firebase Auth support (email + Google)
- Push notifications (FCM) with route-based deep navigation
- Localization-ready UI and theme mode support

## Tech Stack

- **Framework:** Flutter (Dart)
- **State management:** Riverpod
- **Routing:** GoRouter
- **Backend:** Firebase (Auth, Firestore, Storage, Messaging, Analytics, Crashlytics, App Check)
- **Local data:** Hive
- **AI/ML:** Google Gemini API + TensorFlow Lite (`tflite_flutter`)

## Project Structure

Main app code lives in `lib/`:

- `lib/core/` - app-wide constants, router, theme, localization, providers
- `lib/data/` - models, repositories, services (AI routing, Firebase, local ML, storage)
- `lib/features/` - screen-level UI grouped by feature
- `lib/providers/` - Riverpod providers for app services and state
- `lib/shared/` - reusable widgets and UI building blocks

## Prerequisites

Before running locally, ensure:

- Flutter SDK installed
- A configured Firebase project for Android/iOS (and platform config files present)
- A Gemini API key

## Environment Variables

Create a `.env` file in the project root:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

The app loads `.env` at startup from `main.dart`.

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Ensure Firebase is configured:
   - `lib/firebase_options.dart` exists
   - Platform Firebase config files are added (Android/iOS as needed)

3. Run the app:

```bash
flutter run
```

## Testing

Run all tests:

```bash
flutter test
```

## Notes on AI Routing

The scan flow uses an AI routing service:

- If internet is available:
  - Uploads scan image to Firebase Storage
  - Calls Gemini directly for analysis
  - Saves completed scan data to Firestore
- If offline or cloud analysis fails:
  - Falls back to local TFLite inference
  - Returns offline-compatible result payload

This design keeps scanning functional in low-connectivity conditions.

## Useful Commands

```bash
# Lint / static checks
flutter analyze

# Regenerate code (if needed for generators)
dart run build_runner build --delete-conflicting-outputs
```

## Contributing

1. Create a feature branch
2. Make focused changes with tests when possible
3. Run `flutter analyze` and `flutter test`
4. Open a pull request with a clear summary
