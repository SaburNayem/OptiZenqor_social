# Frontend Backend Mismatch Report

Updated: 2026-05-01

## Latest Pass Update

- Jobs networking mutations are now backend-driven for:
  - saved jobs
  - application withdrawal
  - company follow
  - alert create/update
  - recruiter job deletion
- Jobs profile/employer slices no longer fall back to placeholder display strings; nullable backend data now flows through to the UI state.
- Advanced privacy, accessibility support, and legal compliance now load live backend state and persist updates through backend settings state instead of using placeholder production entries.
- `course_model.dart` placeholder default text was removed.
- `flutter analyze` passes after this pass.

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
| Jobs list and profile empty/error UX | `lib/feature/jobs_networking/controller/jobs_networking_controller.dart` and screen widgets | core mutations are wired, but empty/error presentation is still basic | routes exist | add richer empty/error/loading affordances throughout the jobs screens |
| Advanced privacy edit coverage | `lib/feature/advanced_privacy_controls/controller/advanced_privacy_controls_controller.dart` | main toggles are backend-backed, but not every conceptual privacy option has a backend state key yet | partial backend settings data exists | expand backend-backed controls or hide unsupported options |
| Accessibility edit coverage | `lib/feature/accessibility_support/controller/accessibility_support_controller.dart` | backend-backed options now load, but unsupported placeholder options were removed rather than fully replaced | backend route exists | extend backend state if more accessibility controls are required |
| Legal compliance adjacent actions | `lib/feature/legal_compliance/*` | consent state is backend-backed, but account deletion/data export flows still need dedicated UX wiring | partial backend/legal routes exist | wire the rest of the legal actions to backend screens |

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
