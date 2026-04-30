# Frontend/Backend Mismatch Report

Updated: 2026-04-29

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

## Remaining backend contract gaps

- `group-chat`
  - Read and member-management routes now exist.
  - Role update and rename/delete routes exist on backend but are not yet surfaced in the current Flutter screen.
- `subscriptions`
  - Read routes exist.
  - Plan-change mutation now exists and is used by the Flutter repository.
  - Cancel/renew mutation routes now exist but are not yet surfaced in the current Flutter UI.
- `marketplace drafts`
  - Product create exists.
  - No draft-specific backend route exists for marketplace listings, so save-draft remains device-local.
- `live-stream lifecycle`
  - Setup/read routes exist.
  - Full persisted start/end/live moderation lifecycle is still not exposed as a durable frontend CRUD flow.

## Endpoint notes

- `ApiEndPoints.premiumPlans` is now part of the active subscriptions fetch flow.
- `ApiEndPoints.marketplaceCheckout` is now used for order creation instead of local-only order insertion.
- `ApiEndPoints.marketplaceProducts` is now used for listing creation instead of local-only listing insertion.

## Validation note

- `flutter pub get`, `flutter analyze`, and `flutter test` could not be completed in this workspace because the `flutter` command did not return within long timeouts.
