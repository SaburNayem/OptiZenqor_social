# OptiZenqor Social - Full Project Documentation

## 1. App Architecture
## 1.1 Core- 
There will be constant Folder where use constant data like text and color.
There will be data folder there will be service and service model
There will be common widget section
there will be api end point 
there will be shared preference
## 1.2 Feature-
 There will be only feature not anything else 
 In feature folder like home will be a folder main folder where 3 or 4 folder according to its need common will be home model home screen and home controller and into all this folder will be file . 

## 1.3 Route- route only have routes 

## 1. Project Summary
OptiZenqor Social is a modular Flutter social platform prototype. It provides a complete app shell with feed, reels, chat, profile, and settings, plus a large set of route-based feature modules such as communities, premium, reporting, onboarding variants, privacy controls, localization, accessibility, and upload flow stubs.

The project is currently mock-first:
- primary data is provided from local mock datasets
- repositories simulate async network behavior with delays
- most actions are local-state interactions without backend persistence

This document reflects the current state of the main branch code.

## 2. Stack and Dependencies

### 2.1 Runtime Stack
- Flutter (Material 3 UI)
- Dart SDK constraint: ^3.10.8
- GetX package used for app routing and some controllers
- ChangeNotifier + AnimatedBuilder used in many feature modules
- shared_preferences included, but current storage mode is configured as in-memory fallback

### 2.2 pubspec Dependencies
Main:
- flutter
- cupertino_icons: ^1.0.8
- shared_preferences: ^2.5.3
- get: ^4.7.2

Dev:
- flutter_test
- flutter_lints: ^6.0.0

## 3. Application Bootstrap

### 3.1 Startup Sequence
1. main.dart initializes Flutter bindings and runs OptiZenqorApp.
2. app.dart builds GetMaterialApp.
3. App uses AppRoute.routes (GetX route table), AppRoute.unknownRoute, and AppRoute.initialRoute.
4. Initial route is splash (/).

### 3.2 Splash and Entry Flow
Current default UX flow:
1. Splash screen with animated brand hero.
2. After a 2-second bootstrap delay, navigate to onboarding.
3. Onboarding supports skip/continue.
4. Login route leads into main shell on successful mock login.



### 4.1 Directory Design
- lib/core: shared app-wide concerns
	- common_data: mock datasets
	- common_models: shared DTO/entity models
	- config: app configuration constants
	- constants: dimensions/assets/keys/strings
	- enums: app enums
	- helpers/utils/validators
	- services: storage/auth/upload/notification/api stubs
	- theme: global theming and colors
	- widgets: reusable presentational components
- lib/feature: domain modules, usually with controller/model/screen/repository
- lib/route: route name constants and route mappings

### 4.2 State Management Pattern
The project uses a hybrid approach:
- GetX controller pattern in core feed-shell surfaces
	- MainShellController extends GetxController
	- HomeFeedController extends GetxController
	- PostDetailController extends GetxController
- ChangeNotifier pattern in many other feature modules
	- controllers extend ChangeNotifier
	- screens bind via AnimatedBuilder

### 4.3 Navigation Pattern
- Primary navigation is via GetMaterialApp + named routes (Get.toNamed / Get.offNamed).
- Some flows still use direct MaterialPageRoute pushes (for example create post, post detail from feed, user profile from feed).

## 5. Routing

### 5.1 Route Source of Truth
- route/route_names.dart: all named route string constants
- route/app_route.dart: GetX page bindings
- route/app_routes.dart: public route whitelist set
- route/route_generator.dart: legacy MaterialPageRoute generator retained in codebase

### 5.2 Registered Routes
Entry/auth routes:
- /
- /onboarding
- /auth/login
- /auth/signup
- /auth/forgot-password
- /auth/reset-password
- /shell

Core product routes:
- /search-discovery
- /communities
- /marketplace
- /notifications
- /creator-dashboard
- /premium
- /settings

Settings sub-routes:
- /settings/account
- /settings/password-security
- /settings/devices-sessions
- /settings/blocked-users
- /settings/language-accessibility

Extended routes:
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

Unknown routes are handled by an explicit not-found scaffold.

## 6. Main Shell and Core User Journey

### 6.1 Main Shell Tabs
Bottom navigation provides:
- Home
- Reels
- Chat
- Profile
- Settings

### 6.2 App Bar Actions
- Home-only Create action (opens full create post screen)
- Search shortcut
- Notifications shortcut

### 6.3 Drawer Feature Hub
Quick access links:
- Communities
- Marketplace
- Creator Dashboard
- Premium Plans
- Drafts and Scheduling
- Upload Manager

## 7. Data Layer and Storage

### 7.1 Mock Data
core/common_data/mock_data.dart provides local datasets for:
- users
- posts
- reels
- stories
- messages
- notifications (with typed route payloads)
- groups
- products

### 7.2 Repository Pattern
Repositories return async Futures and are generally stub/mock backed:
- HomeFeedRepository fetches feed + stories, writes feed cache
- AuthRepository wraps AuthService + LocalStorageService
- ChatRepository simulates inbox and send
- NotificationsRepository supports full fetch and category filtering
- MarketplaceRepository supports basic query filtering
- PostsRepository stores/retrieves/deletes draft payloads

### 7.3 Local Storage Behavior
LocalStorageService has persistence disabled by default:
- _persistDataOnDevice is false
- shared_preferences path is bypassed
- values are stored in an in-memory map fallback

Result: app state may feel persistent during runtime but is not durable across app restarts.

## 8. Services Overview

Current core services are intentionally scaffolded/lightweight:
- api_client_service.dart: async get/post stubs returning status maps
- analytics_service.dart: no-op logging placeholders
- auth_service.dart: mock login/logout and role state
- connectivity_service.dart: local online/offline notifier
- deep_link_service.dart: incoming/open route placeholders
- media_picker_service.dart: pick image/video stubs returning null
- notification_service.dart: initialize/subscribe stubs
- upload_service.dart: simulated upload returning remote:// path
- local_storage_service.dart: in-memory storage abstraction with optional plugin mode

## 9. Feature Module Inventory

All current feature directories in lib/feature contain Dart implementation files:
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

## 10. Feature Behavior Snapshot

### 10.1 Auth and Onboarding
- Onboarding has 3 slides, skip and continue/get started actions.
- Login form validates email/password and supports role selection.
- Login success currently navigates to shell directly.

### 10.2 Home Feed
- Initial load and pull-to-refresh supported.
- Pagination is triggered near the list end.
- Tabs: For You, Following, Trending.
- Stories strip displayed before feed posts.
- Post actions include like toggle, post detail open, author profile open, report/share/not interested actions.

### 10.3 Create Post
- Dedicated create screen supports caption + optional media URL.
- User can switch photo/video intent via chips.
- On submit, result is returned and inserted at top of feed as local post.

### 10.4 Reels
- Vertical reels display with basic interaction affordances.
- Current behavior is local and mock-data driven.

### 10.5 Chat
- Inbox + chat detail flow exists.
- Local compose/send behaviors are implemented.
- Chat settings are present with local runtime toggles.

### 10.6 Notifications
- Notification list loading and category filtering.
- Notification payload model includes route and entity hints.

### 10.7 Additional Modules
The broader module set (privacy, legal, accessibility, localization, update flow, deep links, report center, verification, etc.) is present and navigable. Many are currently UI and local-state oriented, with backend integration pending.

## 11. UI and Theming
- Theme mode follows system (light/dark available).
- AppTheme is centralized in core/theme.
- Material 3 is enabled.
- Reusable widgets include app_button, app_text_field, app_avatar, app_loader, post_card, empty_state_view, error_state_view, and section_header.

## 12. Models and Shared Contracts

Core shared models include:
- Form and UI state: form_state_model, load_state_model, pagination_state_model
- Social entities: user_model, post_model, reel_model, story_model, message_model, notification_model
- Other entities: group_model, product_model, offline_action_model

Important enums:
- user_role
- view_state

## 13. Testing and Static Analysis
- analysis_options.yaml includes flutter_lints defaults.
- Current test coverage is minimal.
- Existing widget test checks app bootstrap and splash-brand text visibility.

Useful commands:
1. flutter pub get
2. flutter analyze
3. flutter test

## 14. Known Limitations
- No production backend integration for core social flows.
- Storage is not durable across app restarts in current config.
- Media picking and upload are placeholder implementations.
- Notification/deep-link/call systems are not production wired.
- Some modules are primarily scaffold/UI-first and need deeper business logic.

## 15. Recommended Next Implementation Steps
1. Add real API/data-source adapters behind repository interfaces.
2. Enable persistent local data layer (SQLite/Hive/Isar) and sync strategy.
3. Integrate real media picker and upload pipeline.
4. Complete notification and deep-link lifecycle handling.
5. Expand automated test coverage across auth, feed, create post, and routing paths.
