# OptiZenqor Socity

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Backend for debug builds

By default, debug builds use the deployed backend at
`https://opti-zenqor-social-backend.vercel.app`.

If that deployment is behind your local backend code, point Flutter at the
local API instead:

```bash
adb reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

That setup is intended for a USB-connected Android device while the NestJS
backend is running locally on port `3000`.
