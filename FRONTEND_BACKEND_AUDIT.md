# Frontend Backend Audit

Last updated: 2026-05-09

## Files Changed In This Pass

- `lib/core/data/api/api_payload_reader.dart`
- `lib/feature/stories/repository/stories_repository.dart`
- `lib/feature/stories/screen/story_text_composer_screen.dart`
- `lib/feature/stories/screen/story_preview_screen.dart`
- `lib/feature/home_feed/repository/home_feed_repository.dart`
- `lib/feature/activity_sessions/repository/activity_sessions_repository.dart`
- `lib/feature/activity_sessions/model/session_item_model.dart`
- `lib/feature/learning_courses/repository/learning_courses_repository.dart`
- `lib/feature/events/repository/events_repository.dart`
- `lib/feature/bookmarks/model/bookmark_item_model.dart`
- `test/smoke/api_payload_reader_test.dart`

## What Was Tightened

- added normalized `data` helpers in `ApiPayloadReader` for stricter backend-contract reads
- story creation screens no longer submit a fake production-style placeholder story id
- stories repository now prefers normalized `data` payloads and viewer lists
- home feed repository now prefers normalized `data` payloads for feed, hidden posts, stories, and hydrated entity reads
- activity sessions, learning courses, and events repositories now require canonical backend `data` payloads instead of scanning broad fallback shapes
- activity session and bookmark parsing no longer inject several user-facing placeholder labels

## Validation

- `dart format` on edited files -> passed
- `dart analyze lib test --no-fatal-warnings` -> passed
- `flutter test test/smoke/api_payload_reader_test.dart` -> passed

## Remaining Frontend Gaps

- support/help still needs backend-backed ticket detail, replies, updates, and richer retry/error/loading/empty states
- groups, group chat, pages, account switching, blocked/muted accounts, saved collections, and several profile/detail repositories still need the same strict normalized-contract audit standard applied end to end
- calls/live should move further toward explicit durable backend lifecycle contracts once those server routes are finalized
- remaining production fallback labels and alias-heavy readers outside the edited files should be removed in follow-up feature passes

## Honest Status

The Flutter app is materially closer to a backend-first production contract after this pass, especially in core payload parsing and story/feed flows. It is still not fully complete across every feature slice in the app.
