# Frontend/Backend Audit

This audit summarizes the current frontend data access status after the latest
auth-owned API integration work.

## Fully or Mostly API-backed

- `lib/feature/auth/repository/auth_repository.dart`
- `lib/feature/home_feed/repository/home_feed_repository.dart`
- `lib/feature/stories/repository/stories_repository.dart`
- `lib/feature/post_detail/repository/post_detail_repository.dart`
- `lib/feature/chat/repository/chat_repository.dart`
- `lib/feature/notifications/repository/notifications_repository.dart`
- `lib/feature/bookmarks/repository/bookmarks_repository.dart`
- `lib/feature/user_profile/repository/user_profile_repository.dart`
- `lib/feature/stories/repository/buddy_repository.dart`
- `lib/feature/wallet_payments/repository/wallet_payments_repository.dart`
- `lib/feature/safety_privacy/repository/safety_privacy_repository.dart`

These areas already use the central API client for their live backend flows.
Some still keep local cache for UX or optimistic state.

## Hybrid: API plus Local Cache / Offline / Preference Storage

- `lib/feature/home_feed/repository/home_feed_repository.dart`
  Uses API for feed/posts/stories but still has cache/local-created-post support.
- `lib/feature/bookmarks/repository/bookmarks_repository.dart`
  Uses API and mirrors results into local storage.
- `lib/feature/user_profile/repository/user_profile_repository.dart`
  Uses API but still stores some cached/export request state locally.
- `lib/feature/drafts_and_scheduling/repository/drafts_and_scheduling_repository.dart`
  Still local-first for draft persistence.
- `lib/feature/posts/repository/posts_repository.dart`
  Local-only draft storage.
- `lib/feature/settings/repository/settings_preferences_repository.dart`
  Local settings state.

These are not necessarily wrong. They should stay local only if the product
intends offline or device-local preferences. Otherwise they need backend-backed
equivalents.

## Local-only / Mock-heavy Repositories Still Needing Backend Work

- `lib/feature/group_chat/repository/group_chat_repository.dart`
- `lib/feature/groups/repository/groups_repository.dart`
- `lib/feature/events/repository/events_repository.dart`
- `lib/feature/trending/repository/trending_repository.dart`
- `lib/feature/polls_surveys/repository/polls_surveys_repository.dart`
- `lib/feature/support_help/repository/support_help_repository.dart`
- `lib/feature/learning_courses/repository/learning_courses_repository.dart`
- `lib/feature/business_profile/repository/business_profile_repository.dart`
- `lib/feature/jobs_networking/repository/jobs_networking_repository.dart`
- `lib/feature/marketplace/repository/marketplace_repository.dart`
- `lib/feature/live_stream/repository/live_stream_repository.dart`
- `lib/feature/pages/repository/pages_repository.dart`
- `lib/feature/calls/repository/calls_repository.dart`
- `lib/feature/subscriptions/repository/subscriptions_repository.dart`
- `lib/feature/hashtags/repository/hashtags_repository.dart`
- `lib/feature/account_switching/repository/account_switching_repository.dart`
- `lib/feature/activity_sessions/repository/activity_sessions_repository.dart`
- `lib/feature/blocked_muted_accounts/repository/blocked_muted_accounts_repository.dart`
- `lib/feature/verification_request/repository/verification_request_repository.dart`
- `lib/feature/saved_collections/repository/saved_collections_repository.dart`

These should be moved to:

1. Typed response models
2. API service / repository calls through `ApiClientService`
3. Real loading / empty / error states based on backend responses
4. Local cache only after the backend flow is confirmed

## Mock / Seeded UI Usage Still Visible

- `lib/feature/events/screen/events_screen.dart`
- `lib/feature/share_repost_system/screen/share_post_screen.dart`
- `lib/feature/wallet_payments/screen/wallet_payments_screen.dart`

These should be removed or isolated behind explicit dev-only flags after each
matching backend route is production-backed.

## Core Foundation Status

- Central auth header injection: implemented in `ApiClientService`
- Refresh-token handling: implemented in `ApiClientService`
- Session clear on unrecoverable 401/refresh failure: implemented
- Platform-aware base URL defaults: implemented in `AppConfig`
- Uploads through central API client: implemented

## Recommended Next Migration Order

1. Marketplace
2. Jobs
3. Events
4. Communities / Groups / Pages
5. Group chat / live stream / hidden/archive flows
6. Drafts / saved collections / verification / settings state sync
