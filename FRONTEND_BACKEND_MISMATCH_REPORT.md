# Frontend/Backend Mismatch Report

Updated: 2026-04-30

## Fixed in this frontend pass

- `subscriptions` now reads live plan/catalog data from:
  - `/premium-plans`
  - `/monetization/plans`
  - `/monetization/overview`
  - `/subscriptions`
- `subscriptions` now writes active plan changes to:
  - `POST /subscriptions/change-plan`
- `groups` now reads backend data from `/groups` instead of static local arrays.
- `group_chat` now reads backend data from `/group-chat` instead of static local arrays.
- `group_chat` now writes create/member-management actions to:
  - `POST /group-chat`
  - `POST /group-chat/:id/members`
  - `DELETE /group-chat/:id/members/:userId`
- `live_stream` setup now reads backend data from `/live-stream/setup` instead of hardcoded presenter/comment data.
- `marketplace` checkout now posts real orders to `/marketplace/checkout`.
- `marketplace` listing publish now posts real listings to `/marketplace/products`.
- `support_help` now reads `/support-help` instead of shipping hardcoded FAQ data.
- `trending` now reads `/trending` instead of shipping hardcoded trending cards.
- `hashtags` now reads `/hashtags` instead of shipping hardcoded hashtag counts.
- `group_chat` now exposes backend-backed rename/delete/member-role actions.
- `subscriptions` now exposes backend-backed cancel and renew actions.
- `verification_request` no longer fabricates a local `notRequested` state when the backend call fails.
- `archive` screens now surface backend errors instead of silently rendering fake-empty states.
- `wallet_payments` now reads backend wallet balance and ledger instead of shipping fake transaction data.
- `safety_privacy` now reads and writes backend privacy/settings state instead of storing local-only production settings.

## Remaining backend contract gaps

- `group-chat`
  - Read and member-management routes now exist.
  - Rename/delete/role update routes are now surfaced in the current Flutter screen.
- `subscriptions`
  - Read routes exist.
  - Plan-change mutation now exists and is used by the Flutter repository.
  - Cancel/renew mutation routes are now surfaced in the current Flutter UI.
- `marketplace drafts`
  - Product create exists.
  - No draft-specific backend route exists for marketplace listings, so save-draft remains device-local.
- `marketplace seller follows / offers / chat`
  - Flutter still keeps these states locally after initial backend load.
  - Dedicated durable backend mutation routes are still needed for a full migration.
- `live-stream lifecycle`
  - Setup/read/comment/reaction routes now exist and are durable.
  - Full persisted start/end/live moderation lifecycle is still not exposed as a durable frontend CRUD flow.
- `hidden/archive UI`
  - Archive list screens now read backend routes and show real error states.
  - Hidden posts screen still depends on local `HomeFeedController` state instead of the backend hidden-post routes.

## Endpoint notes

- `ApiEndPoints.premiumPlans` is now part of the active subscriptions fetch flow.
- `ApiEndPoints.marketplaceCheckout` is now used for order creation instead of local-only order insertion.
- `ApiEndPoints.marketplaceProducts` is now used for listing creation instead of local-only listing insertion.

## Validation note

- `flutter pub get`: pass
- `dart format` on the updated support/trending/marketplace files: pass
- `flutter analyze`: pass with pre-existing non-fatal warnings/info only in `socket_transport_web.dart`, `home_feed_screen.dart`, and story screen unused helpers.
- `flutter test`: fails because the repo currently has no `test/` directory or `_test.dart` files.
