# Frontend Backend Mismatch Report

Updated: 2026-05-02

## Fixed In This Pass

- `marketplace_repository.dart`
  - create-order now throws on backend failure instead of returning a nullable fake-success result
  - create-listing now throws on backend failure instead of returning a nullable fake-success result
  - missing delivery options no longer default to a fabricated pickup-only state
- `calls_repository.dart`
  - session creation now sends the selected recipient id to the backend
- `live_stream_repository.dart`
  - preview label is now backend-driven when provided instead of hardcoded in the repository
- `flutter analyze` and `flutter test` both pass after the repository updates

## Current Frontend Status

The Flutter app now fails more honestly in key server-owned flows and validates cleanly. It still contains broader display-level fallback strings and partial derivation in several feature slices that need another cleanup pass.

## Remaining Frontend Mismatches

| Feature | Frontend file | Current issue | Needed next |
| --- | --- | --- | --- |
| Marketplace payload richness | `lib/feature/marketplace/repository/marketplace_repository.dart` | sellers, categories, draft visuals, and some order/chat/offer display fields still depend on partial payload interpretation | complete backend marketplace payloads and remove more derivation |
| Jobs placeholder labels | `lib/feature/jobs_networking/model/job_model.dart` | model constructors still fill some missing backend fields with display placeholders | finish backend payload completeness, then remove placeholders |
| Calls lifecycle | `lib/feature/calls/repository/calls_repository.dart` | lifecycle UI still relies on shallow history payloads rather than durable snapshots | expand server lifecycle snapshot contract |
| Support/help depth | `lib/feature/support_help/repository/support_help_repository.dart` | overview is good, but detail/reply/update UX remains thin | add richer support workflow coverage |
| Groups/pages/learning/events slices | multiple repositories/models | some user-visible placeholder labels and defensive fallback shaping still remain | continue no-placeholder cleanup across the requested modules |

## Validation

- `flutter pub get` -> passed
- `dart format .` -> passed
- `flutter analyze` -> passed
- `flutter test` -> passed

## Honest Status

- Flutter completion: 82%
