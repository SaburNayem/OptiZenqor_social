# OptiZenqor Social - Full App Documentation

## 1. Purpose and Scope
OptiZenqor Social is a Flutter mobile social platform prototype with modular feature folders, route-driven navigation, reusable UI components, and mock-data-first flows.

This document is a full status document for the current branch and includes:
- what is implemented
- what is partially implemented
- what is intentionally placeholder
- what folders exist but are not yet implemented

## 2. Tech Stack and Runtime
- Flutter (Material 3)
- Dart (null safety)
- State management: ChangeNotifier + AnimatedBuilder
- Persistence: shared_preferences + in-memory fallback path in storage service
- Data source: mock data from `lib/core/common_data/mock_data.dart`

Dependency summary from `pubspec.yaml`:
- flutter
- cupertino_icons
- shared_preferences

## 3. App Architecture

### 3.1 Layering
- `lib/core`: shared models, services, constants, validators, widgets, helpers
- `lib/route`: central route names and route generator
- `lib/feature`: feature modules (screen/controller/model/repository where used)

### 3.2 State Pattern
- Controllers own feature state.
- Screens listen through AnimatedBuilder.
- New shared state models exist for load/form/pagination in `lib/core/common_models`.

### 3.3 Data Strategy
- Current read/write operations are mock-based or local fallback-based.
- Repository scaffolding exists for major domains: auth, feed, chat, notifications, profile, marketplace, posts.

## 4. Roles
User roles defined in `lib/core/enums/user_role.dart`:
- guest
- user
- creator
- business
- seller
- recruiter

## 5. Lifecycle and Navigation

### 5.1 Boot Flow
1. Splash
2. Onboarding
3. Login
4. Shell

### 5.2 Shell Layout
Main shell tabs:
- Home
- Reels
- Chat
- Profile
- Settings

Top actions:
- Create (Home tab only)
- Search
- Notifications

Drawer quick links:
- Communities
- Marketplace
- Creator Dashboard
- Premium Plans
- Drafts & Scheduling
- Upload Manager

## 6. Route Catalog and Status

### 6.1 Auth and Entry
- `/` splash: implemented
- `/onboarding`: implemented
- `/auth/login`: implemented
- `/auth/signup`: scaffold screen
- `/auth/forgot-password`: scaffold screen
- `/auth/reset-password`: scaffold screen
- `/shell`: implemented shell wrapper

### 6.2 Main Product Routes
- `/search-discovery`: implemented
- `/communities`: implemented with join/leave interaction state
- `/marketplace`: implemented with search + grid
- `/notifications`: implemented with filters and payload-based route mapping
- `/creator-dashboard`: scaffold implementation
- `/premium`: scaffold implementation
- `/settings`: implemented settings hub (all listed rows route-enabled)

### 6.3 Advanced Routes
- `/drafts-scheduling`: scaffold implementation
- `/upload-manager`: scaffold implementation
- `/offline-sync`: scaffold implementation
- `/verification-request`: scaffold implementation
- `/personalization-onboarding`: scaffold implementation
- `/advanced-privacy-controls`: scaffold implementation
- `/share-repost-system`: scaffold implementation
- `/media-viewer`: scaffold implementation
- `/post-detail`: implemented detail screen with local comments/replies
- `/account-switching`: scaffold implementation
- `/push-notification-preferences`: scaffold implementation
- `/report-center`: scaffold implementation
- `/activity-sessions`: scaffold implementation
- `/deep-link-handler`: scaffold implementation
- `/app-update-flow`: scaffold implementation
- `/localization-support`: scaffold implementation
- `/accessibility-support`: scaffold implementation
- `/explore-recommendation`: scaffold implementation
- `/blocked-muted-accounts`: scaffold implementation
- `/maintenance-mode`: scaffold implementation
- `/invite-referral`: scaffold implementation
- `/legal-compliance`: scaffold implementation

## 7. Feature-by-Feature Functional Status

### 7.1 Authentication
Working:
- Login form validation for email + non-empty password
- Role selection
- Login transition to shell

Working with fallback:
- Session persistence write uses shared_preferences if available, otherwise in-memory fallback

Known limitations:
- No real credential backend; login is mock success flow
- Analytics event currently logs signup event from login path (naming mismatch)

### 7.2 Home Feed
Working:
- Initial load
- Pull to refresh
- Infinite load trigger on scroll
- Feed tabs (For You/Following/Trending)
- Stories row
- Story tap opens story viewer
- Post tap opens post detail
- Author tap opens other profile
- Like optimistic toggle
- Not interested hides post
- Home composer card present in feed

Behavior update:
- Create entry is exposed in Home top app bar only (not as cross-tab FAB)

Partially working / placeholder:
- Share/report from post menu only show feedback
- Create action currently shows feedback for upcoming composer flow

### 7.3 Story Viewer
Working:
- Story open from ring list
- Swipe through stories
- Progress indicators
- Zoom support via InteractiveViewer

Limitations:
- No auto-advance timer
- No seen-state mutation persisted

### 7.4 Reels
Working:
- Vertical pager and visual rendering
- Like, comment, and share actions wired to controller-managed local counters and feedback

### 7.5 Chat
Working:
- Inbox list
- Open chat detail
- Compose/send local message
- Long-press chat actions (pin/archive/simulate failure)
- Retry marker clearing
- Header audio and video call buttons
- Plus attachment sheet opens
- Chat settings screen opens from chat detail app bar

Partially working / placeholder:
- Call buttons show feedback only; no RTC flow
- Attachment options show feedback only; no picker integration
- No backend send/read receipt sync

### 7.6 Notifications
Working:
- Loading state handling
- Category filters
- Unread count
- Notification taps route to mapped screens through typed payload fields

Limitations:
- Payload routes are local app route mappings (no server-issued deep-link parser yet)

### 7.7 User Profile
Working:
- Profile load and render
- Role-aware section labels
- Profile tab in shell opens correctly
- Own vs other profile action separation
- Message action shown only for other profiles
- Three-dot action menu for profile-level actions

Recent change:
- Settings button removed from profile header

### 7.8 Settings
Working:
- Route-linked entries navigate, including:
  - Account settings
  - Password and security
  - Blocked users
  - Language and accessibility
  - Devices and sessions

Limitations:
- Several settings destinations are functional scaffold screens with informational UI only

### 7.9 Marketplace
Working:
- Product list load
- Search updates results
- Error/loading states

Limitations:
- No item detail route
- No cart/checkout

### 7.10 Communities and Premium
Working:
- Screen render and list content
- Communities join/leave button toggles state and shows feedback
- Premium plan selection shows immediate feedback

### 7.11 Advanced Module Buttons with Empty Handlers
Status:
- Previously empty callbacks were replaced with interaction handlers and user feedback flows.
- Remaining gaps are mostly feature-depth gaps (backend/data integration), not blank UI callbacks.

## 8. Implemented Feature Modules (with Dart files)
- accessibility_support
- account_switching
- activity_sessions
- advanced_privacy_controls
- app_update_flow
- auth
- blocked_muted_accounts
- chat
- communities
- creator_tools
- deep_link_handler
- drafts_and_scheduling
- explore_recommendation
- home_feed
- invite_referral
- legal_compliance
- localization_support
- main_shell
- maintenance_mode
- marketplace
- media_viewer
- notifications
- offline_sync
- onboarding
- personalization_onboarding
- post_detail
- posts (repository scaffold only)
- premium_membership
- push_notification_preferences
- recruiter_profile
- reels_short_video
- report_center
- search_discovery
- seller_profile
- settings
- share_repost_system
- splash
- stories
- upload_manager
- user_profile
- verification_request

## 9. Feature Folders Present but Not Implemented (No Dart files)
- analytics
- bookmarks
- business_profile
- calls
- comments
- creator_profile
- events
- follow_unfollow
- group_chat
- groups
- hashtags
- jobs_networking
- learning_courses
- likes_reactions
- live_stream
- pages
- polls_surveys
- safety_privacy
- saved_collections
- subscriptions
- support_help
- trending
- wallet_payments

## 10. Core Services Summary
- `auth_service.dart`: mock login/logout role state
- `local_storage_service.dart`: shared_preferences + memory fallback
- `analytics_service.dart`: event logging stubs
- `deep_link_service.dart`: incoming/open placeholders
- `connectivity_service.dart`: basic connectivity stub behavior

## 11. UI Component Library
Reusable widgets in `lib/core/widgets` include:
- app_button
- app_text_field
- app_avatar
- app_loader
- empty_state_view
- error_state_view
- section_header
- post_card

## 12. Data and Mock Content
Mock datasets currently include:
- users
- posts
- reels
- stories
- messages
- notifications
- groups
- products

Used for immediate UI behavior and demo flows.

## 13. Quality and Testing
- Current analyzer state: expected clean after recent fixes
- Existing test coverage:
  - `test/widget_test.dart`: verifies app bootstraps to splash brand text
- No integration tests yet for auth/feed/chat/notifications interactions

## 14. Known Functional Gaps
- No backend integration for auth/feed/chat/notifications
- No real media upload
- No real call stack (VoIP/WebRTC)
- No durable offline queue sync engine
- Many advanced modules remain scaffold-level and feedback-driven

## 15. Recommended Implementation Order
1. Replace feedback-only create/share/report flows with full feature screens and repository operations.
2. Add real data sources behind existing repositories (remote API + local cache).
3. Expand settings sub-screens from scaffold UI into editable account/security/session workflows.
4. Add integration tests for critical paths:
   - login success and route transition
   - home tab feed interactions
   - story open/swipe
   - chat compose and attachment sheet
   - notification deep-link route mapping
5. Introduce backend adapter layer behind existing repositories.

## 16. Run and Verify
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter run`

If login fails with shared_preferences plugin error on hot reload, do a full app restart. Storage now has memory fallback for plugin-unavailable sessions.

---
Documentation maintained for branch: main
Last updated: 2026-03-22
