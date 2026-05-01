# Frontend Backend Mismatch Report

Updated: 2026-05-01

## Current Frontend Status

The Flutter app is locally connected to a broad live backend surface. The app is not fully mock-free yet, but the most problematic production-local marketplace and blocked-muted flows were removed in this pass.

## Fixed In This Pass

- `AuthService` no longer actively calls demo-account endpoints.
- Marketplace compare list now persists through:
  - `GET /marketplace/compare`
  - `PATCH /marketplace/compare`
- Marketplace sold/pause/repost listing actions now persist through:
  - `PATCH /marketplace/products/:id/status`
- Marketplace saved-item toggles now persist through backend bookmarks:
  - `POST /bookmarks`
  - `DELETE /bookmarks/:id`
- Blocked-muted account unmute now persists through:
  - `PATCH /blocked-muted-accounts/:targetId/unmute`

## Remaining Frontend Mismatches

| Feature | Frontend file | Current issue | Backend route status | Needed next |
| --- | --- | --- | --- | --- |
| Jobs profile/employer slices | `lib/feature/jobs_networking/repository/jobs_networking_repository.dart` | still falls back to default empty models for some thin responses | routes exist | switch to explicit error/empty-state handling |
| Advanced privacy | `lib/feature/advanced_privacy_controls/controller/advanced_privacy_controls_controller.dart` | placeholder controller entries remain | partial backend settings data exists | replace controller placeholders with backend-backed state |
| Accessibility support | `lib/feature/accessibility_support/controller/accessibility_support_controller.dart` | placeholder support rows remain | backend route exists | bind full state to backend response |
| Legal compliance UI | `lib/feature/legal_compliance/screen/legal_compliance_screen.dart` | placeholder copy remains | backend route exists | convert to real backend-driven copy/state |
| Learning courses defaults | `lib/feature/learning_courses/model/course_model.dart` | placeholder default text remains in model defaults | backend route exists | reduce placeholder defaults and rely on API payloads |
| Jobs mutations/UI state | `lib/feature/jobs_networking/controller/jobs_networking_controller.dart` | still performs local optimistic mutations without full backend refresh | partial backend support exists | add backend-backed alert/save/withdraw/status mutations |

## Production-Local State Removed

- marketplace compare list
- marketplace listing sold/pause/repost state
- marketplace saved items
- blocked-muted unmute behavior
- active demo auth endpoint usage

## Validation

- `flutter pub get`: pass
- `dart format .`: pass
- `flutter analyze`: pass
- `flutter test`: still expected to fail or no-op if the repo has no real test suite configured

## Next Recommended Frontend Pass

1. Remove default-model fallback behavior from jobs/profile/business modules.
2. Replace advanced-privacy/accessibility/legal-compliance placeholder controller content with backend-backed reads.
3. Expand backend mutation coverage for jobs alerts/saved jobs/company follow if those screens are meant to be fully durable.
