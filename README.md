# 🏋️‍♂️ MGA Members App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com/)
[![Architecture](https://img.shields.io/badge/Architecture-Layered%20Clean-blue)](https://flutter.dev)

The member-facing companion to the MGA Admin & Trainer app — workout logging, branch browsing, grievance reporting, an AI trainer chatbot, and video-based posture analysis, for gym members on Android.

## Features

- Guided 3-step workout logging wizard (muscle group → exercise → sets, with per-exercise history pulled in on the final step)
- Branch directory with per-branch equipment inventory
- Grievance reporting and history (active/resolved)
- AI trainer chatbot with selectable tone and optional workout-log sharing for context-aware responses
- Posture analysis: record or upload a workout video, get rep count and joint-angle feedback back from the analysis service
- Inactive-account tile gating on the home screen — a member with a lapsed membership can still log workouts and raise grievances, but other features show a clear "renew or contact admin" prompt instead of silently failing
- Session auto-expiry (30-minute token TTL) with proactive logout

## Tech Stack

- Flutter (Android)
- `http` for networking
- `shared_preferences` for session storage
- `image_picker` for posture-analysis video capture/selection

## Project Structure

lib/
├── core/
│   ├── config/       # constants, colors, shared dark theme, routes
│   ├── network/      # ApiClient
│   └── utils/        # form validators
├── models/           # workout, branch, chat, grievance, trainer models
├── controllers/      # form-input controllers for the workout wizard
├── services/         # auth cache, resource/chat/people API services
└── screens/
    ├── auth/          # login, signup
    ├── common/        # splash, home
    ├── branches/      # branch directory
    ├── grievances/    # grievance list + report-issue flow
    ├── trainer/       # assigned-trainer profile
    ├── chat/          # AI trainer bot
    └── workout/       # 3-step logging wizard

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- An Android device or emulator

### Install & Run
flutter pub get
flutter run

### Configuration
The backend base URL lives in `lib/core/config/app_constants.dart`.

## Testing

flutter test

Unit tests cover form validators, all typed models (including edge cases like a missing `isInWorkingCondition` field, which previously crashed the app — see Architecture Notes), the `ApiClient` network layer, and the token-TTL logic. A widget test covers the inactive-account tile-gating behavior end to end: which tiles stay tappable, which show the dialog, and the fail-open behavior when membership status hasn't loaded yet.

## Architecture Notes

One real defect was fixed during the restructuring, not just relocated: `EquipmentItem.fromJson` previously defaulted a missing `isInWorkingCondition` field to an empty string on a `bool`-typed field — a guaranteed runtime crash the moment that key was absent from a response, not a style issue. It's now a proper `false` default, with a test pinning that behavior down so it can't silently regress.

A shared `AppTheme`/`AppColors` pair replaced seven screens' worth of identically copy-pasted `ThemeData.dark().copyWith(...)` blocks — one actual duplication problem, not an abstraction added for its own sake (compare the face-login app's README, where the same reasoning led to *not* adding a shared theme, since there was nothing duplicated to fix).

```