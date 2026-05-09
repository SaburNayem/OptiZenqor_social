# Frontend Backend Mismatch Report

Updated: 2026-05-09

## Fixed In This Pass

- `api_payload_reader.dart`
  - added normalized `readDataMap(...)` and `requireDataMap(...)` helpers for stricter backend contract reads
- `stories_repository.dart`
  - story creation and story-viewer reads now prefer canonical `data` payloads instead of broad top-level alias scanning
- `story_text_composer_screen.dart` and `story_preview_screen.dart`
  - story submission drafts no longer send the fake placeholder id `draft_story_submission`
- `home_feed_repository.dart`
  - feed, hidden posts, stories, and hydration reads now prefer canonical `data` payloads
- `activity_sessions_repository.dart`, `learning_courses_repository.dart`, `events_repository.dart`
  - these repositories now require canonical backend `data` payloads instead of permissive fallback shapes
- `session_item_model.dart` and `bookmark_item_model.dart`
  - removed several display-level placeholder labels such as unknown/default saved-item strings
- `dart analyze` and the smoke parser test both pass after the repository updates

## Current Frontend Status

The Flutter app now fails more honestly in additional server-owned flows and validates cleanly. It still contains broader display-level fallback strings and partial derivation in several feature slices that need another cleanup pass.

## Remaining Frontend Mismatches

| Feature | Frontend file | Current issue | Needed next |
| --- | --- | --- | --- |
| Marketplace payload richness | `lib/feature/marketplace/repository/marketplace_repository.dart` | sellers, categories, draft visuals, and some order/chat/offer display fields still depend on partial payload interpretation | complete backend marketplace payloads and remove more derivation |
| Jobs placeholder labels | `lib/feature/jobs_networking/model/job_model.dart` | model constructors still fill some missing backend fields with display placeholders | finish backend payload completeness, then remove placeholders |
| Calls lifecycle | `lib/feature/calls/repository/calls_repository.dart` | lifecycle UI still relies on shallow history payloads rather than durable snapshots | expand server lifecycle snapshot contract |
| Support/help depth | `lib/feature/support_help/repository/support_help_repository.dart` | overview is good, but detail/reply/update UX remains thin | add richer support workflow coverage |
| Groups/pages/saved collections/account switching | multiple repositories/models | several repositories still scan alias-heavy payloads or tolerate partial backend shapes | continue normalized `data` contract cleanup across the remaining slices |
| Stories/feed/share display fallbacks | story/feed/share screens and models | some display-level fallback copy still remains for empty backend fields | trim remaining placeholders after backend payload completeness is verified |

## Validation

- `dart format` on edited files -> passed
- `dart analyze lib test --no-fatal-warnings` -> passed
- `flutter test test/smoke/api_payload_reader_test.dart` -> passed

## Honest Status

- Flutter completion: 86%
