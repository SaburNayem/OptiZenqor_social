# Frontend Backend Mismatch Report

Updated: 2026-05-02

## Latest Pass Update

- jobs networking repository no longer hides failed aggregate/list requests behind empty production lists
- jobs networking screen now renders explicit loading, retry, error, and empty states for discover, profile, applications, applicants, saved jobs, and alerts tabs
- blocked/muted account loading still fails closed from the earlier pass instead of pretending backend errors are real empty state
- accessibility, localization, personalization onboarding, and legal compliance controllers from the earlier pass still reject malformed or empty backend payloads
- `flutter analyze` passes after these changes

## Current Frontend Status

The Flutter app is more honest about backend failures than it was before. It is still not fully free of client-side business derivation, especially in marketplace and some jobs/calls model layers.

## Fixed In This Implementation Cycle

- marketplace compare list persists through backend compare routes
- marketplace sold/pause/repost actions persist through backend listing-status routes
- marketplace saved-item toggles persist through backend bookmarks
- blocked/muted unmute no longer uses local-only success behavior
- jobs saved-job, application withdrawal, company follow, recruiter job deletion, applicant status, and alert mutations are backend-driven
- jobs list-style endpoints no longer silently degrade to empty success when the backend fails

## Remaining Frontend Mismatches

| Feature | Frontend file | Current issue | Backend route status | Needed next |
| --- | --- | --- | --- | --- |
| Marketplace contracts | `lib/feature/marketplace/repository/marketplace_repository.dart` | still derives sellers, categories, draft imagery, labels, timestamps, and order/chat/offer fields from partial payloads | partial routes exist | stabilize backend marketplace payloads and remove client-side derivation |
| Jobs model placeholder labels | `lib/feature/jobs_networking/model/job_model.dart` | some model constructors still provide placeholder display labels when backend fields are absent | partial routes exist | tighten backend payload completeness and then remove placeholder strings |
| Calls lifecycle | `lib/feature/calls/repository/calls_repository.dart` | backend-backed flows still infer lifecycle details instead of reading durable server snapshots | incomplete lifecycle backend | add persisted lifecycle state and stricter contracts |
| Support/help depth | `lib/feature/support_help/repository/support_help_repository.dart` | overview is backend-backed, but deeper support workflow coverage is still thin | partial routes exist | add ticket detail/reply/update UX with explicit retry/error states |
| Accessibility/legal/localization catalogs | corresponding controller files | controllers now fail correctly, but backend config is still operational-setting driven rather than fully normalized catalog tables | partial backend persistence exists | normalize catalog models and tighten contracts further |

## Validation

- `flutter pub get`: pass
- `dart format` on changed files: pass
- `flutter analyze`: pass
- `flutter test`: no runnable suite because there are no `*_test.dart` files under `test`

## Next Recommended Frontend Pass

1. Remove runtime business derivation from `marketplace_repository.dart`.
2. Tighten jobs model constructors once backend payload completeness is guaranteed.
3. Expand backend-driven support and call lifecycle coverage so the UI can stop inferring state.
