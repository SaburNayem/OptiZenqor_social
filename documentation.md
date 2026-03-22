# OptiZenqor Social - Complete Project Documentation

## 1. Project Overview
OptiZenqor Social is a Flutter social platform prototype built with a modular architecture and mock-first data strategy. The app includes a full shell experience (Home, Reels, Chat, Profile, Settings), route-driven feature modules, and local interactive behavior intended to simulate a production social app without backend APIs.

This document is the single source of truth for the current branch and includes:
- architecture and folder design
- navigation and route map
- feature-by-feature implementation status
- data and runtime behavior
- known limits and next implementation priorities

## 2. Technology Stack
- Flutter (Material 3)
- Dart (null safety, SDK ^3.10.8)
- State management: ChangeNotifier + AnimatedBuilder
- Local storage package: shared_preferences (currently configured to run in in-memory mode)

### 2.1 Dependencies in pubspec.yaml
Core dependencies:
- flutter
- cupertino_icons
- shared_preferences

Dev dependencies:
- flutter_test
- flutter_lints

## 3. High-Level Architecture

### 3.1 App Bootstrap
Startup sequence:
1. main.dart initializes bindings and runs OptiZenqorApp.
2. app.dart creates MaterialApp with light/dark themes.
3. route_generator.dart handles all named route resolution.
4. initial route starts at splash.

### 3.2 Layered Structure
- lib/core: shared models, services, constants, reusable widgets, helpers
- lib/route: centralized route names and route generator
- lib/feature: domain modules, each with screen/controller/model/repository where needed

### 3.3 State and Data Flow Pattern
Standard feature flow:
1. UI screen creates controller instance.
2. Controller fetches data from repository or mock source.
3. UI listens to controller via AnimatedBuilder.
4. User actions call controller methods.
5. Controller mutates local state and triggers notifyListeners.

This is currently local-state-first and backend-independent.

## 4. Runtime and Storage Behavior

### 4.1 Storage Mode
Current storage behavior is session-only in practice:
- LocalStorageService has a _persistDataOnDevice flag set to false.
- Data read/write operations use in-memory fallback map.
- App interactions work normally, but data is not persisted across restarts.

### 4.2 Data Sources
Primary runtime data comes from MockData in core/common_data:
- users
- posts
- reels
- stories
- messages
- notifications
- groups
- products

Controllers may append local runtime state (likes, hidden posts, created local posts, chat state toggles).

## 5. Navigation and Shell

### 5.1 Primary App Flow
1. Splash
2. Onboarding
3. Login
4. Main shell

### 5.2 Main Shell Tabs
- Home
- Reels
- Chat
- Profile
- Settings

### 5.3 App Bar Actions
- Home-only Create button (opens full Create Post screen)
- Search
- Notifications

### 5.4 Drawer Shortcuts
- Communities
- Marketplace
- Creator Dashboard
- Premium Plans
- Drafts and Scheduling
- Upload Manager

## 6. Route Catalog

### 6.1 Entry Routes
- / (splash)
- /onboarding
- /auth/login
- /auth/signup
- /auth/forgot-password
- /auth/reset-password
- /shell

### 6.2 Core Product Routes
- /search-discovery
- /communities
- /marketplace
- /notifications
- /creator-dashboard
- /premium
- /settings
- /settings/account
- /settings/password-security
- /settings/devices-sessions
- /settings/blocked-users
- /settings/language-accessibility

### 6.3 Extended Routes
- /drafts-scheduling
- /upload-manager
- /offline-sync
- /verification-request
- /personalization-onboarding
- /advanced-privacy-controls
- /share-repost-system
- /media-viewer
- /post-detail
- /account-switching
- /push-notification-preferences
- /report-center
- /activity-sessions
- /deep-link-handler
- /app-update-flow
- /localization-support
- /accessibility-support
- /explore-recommendation
- /blocked-muted-accounts
- /maintenance-mode
- /invite-referral
- /legal-compliance

Note: Create Post currently uses MaterialPageRoute directly from Home and shell app bar, not a named route.

## 7. Detailed Feature Status

### 7.1 Authentication
Implemented:
- login validation (email + password required)
- role selection integration
- navigation to shell on success

Current limitations:
- mock auth only (no server credential validation)
- analytics event naming still partially generic

### 7.2 Home Feed
Implemented:
- initial load
- pull-to-refresh
- pagination trigger near list end
- feed tabs (For You, Following, Trending)
- stories section
- post detail open
- author profile open
- optimistic like toggle and visible like count updates
- not interested hide behavior
- top composer row with reels icon (left), share prompt, photo/video icons (right)
- full-screen create post flow

Current behavior notes:
- suggestions strip after tabs has been removed
- share/report actions currently feedback-based

### 7.3 Create Post Flow
Implemented in dedicated screen:
- text input
- media type selection (Photo or Video)
- optional media URL
- Post action returns result to Home
- Home controller creates local post and inserts at top of feed

Current limitations:
- no real file picker or camera integration
- video rendering in list/detail is URL-pattern based placeholder behavior

### 7.4 Post Card
Implemented:
- author row
- caption rendering
- image rendering for first media item
- like/comment chips
- bookmark action callback

### 7.5 Post Detail
Implemented:
- author block
- caption rendering
- media rendering support from post detail model
- simple video preview placeholder for media URLs ending in video extensions
- like toggle
- comment list
- reply mode on comment tap
- add comment locally
- related posts list

### 7.6 Story Viewer
Implemented:
- open from story ring
- swipe behavior
- progress indicator visuals
- zoom support

Limitations:
- no auto-advance timer
- no persisted seen-state updates

### 7.7 Reels
Implemented:
- vertical pager rendering
- like, comment, share actions
- local count adjustments in controller

Limitations:
- no backend persistence
- no native media upload/record flow

### 7.8 Chat
Implemented:
- inbox list
- chat detail open
- local send/compose
- long-press actions (pin/archive/failure simulation)
- retry clearing
- attachments sheet (feedback-oriented)
- chat settings screen with runtime toggles

Limitations:
- no real-time transport, no read-sync backend
- call actions are UI feedback only

### 7.9 Notifications
Implemented:
- load + filter categories
- unread count
- typed payload-driven route mapping

Limitations:
- no server push integration
- no remote deep-link parser layer

### 7.10 User Profile
Implemented:
- role-aware profile rendering
- own vs other profile behavior
- message action visible for other profiles
- three-dot action menu

### 7.11 Settings
Implemented:
- settings hub navigation entries wired
- account/security/blocked/language/device routes available

Limitations:
- many destination screens are still scaffold/informational

### 7.12 Marketplace
Implemented:
- list load
- search filtering
- loading/error state handling

Limitations:
- no item detail/purchase checkout flow

### 7.13 Communities and Premium
Implemented:
- communities join/leave toggle + feedback
- premium plan selection feedback

## 8. Feature Module Inventory

### 8.1 Feature Folders With Dart Implementation
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
- posts
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

### 8.2 Feature Folders Present But Without Dart Files
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

## 9. Core Services Summary
- auth_service.dart: mock login/logout state
- local_storage_service.dart: in-memory runtime storage mode with optional shared_preferences pathway
- analytics_service.dart: event logging stubs
- deep_link_service.dart: placeholders for deep link handling
- connectivity_service.dart: baseline connectivity behavior stub

## 10. Shared UI Components
Reusable widgets in core/widgets include:
- app_button
- app_text_field
- app_avatar
- app_loader
- empty_state_view
- error_state_view
- section_header
- post_card

## 11. Testing and Quality
- analyzer workflow available via flutter analyze
- current automated tests are minimal
- widget_test.dart validates app bootstrap rendering baseline
- integration coverage is not yet implemented for core user journeys

## 12. Current Functional Limitations
- no backend integration for auth/feed/chat/reels/notifications
- no durable persistence across app restarts in current configuration
- no real media upload pipeline (camera/gallery/file service)
- no production call stack (VoIP/WebRTC)
- many advanced modules remain scaffold-level UI

## 13. Recommended Next Steps
1. Implement backend adapter layer behind existing repositories.
2. Add local database cache and sync strategy for offline durability.
3. Replace URL-based media placeholders with real picker/upload flow.
4. Expand Create Post to include mentions, audience, and scheduling.
5. Add integration tests for auth, feed interactions, create flow, chat, and notifications.

## 14. Run and Verification Commands
1. flutter pub get
2. flutter analyze
3. flutter test
4. flutter run

## 15. Recent Implementation Highlights
- Home composer now opens a dedicated full-screen create screen.
- Local post creation now inserts runtime posts into feed instantly.
- Post media rendering restored in feed cards.
- Post detail now renders media and supports comment/reply interactions.
- Storage intentionally configured for in-memory runtime behavior.

---
Documentation maintained for branch: main
Last updated: 2026-03-22
