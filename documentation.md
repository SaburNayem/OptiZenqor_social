# OptiZenqor Social - Project Documentation

## 1. Project Summary
OptiZenqor Social is a modular Flutter social-platform prototype built around a route-driven feature architecture. The app includes onboarding, authentication, a tabbed main shell, social feed flows, chat, marketplace, profile, settings, and a broad collection of extension modules such as accessibility, privacy, reporting, subscriptions, saved collections, wallet payments, events, learning, and support surfaces.

The project is currently mock-first:
- most feature data comes from local models and mock repositories
- repositories simulate async behavior instead of calling production APIs
- several services are placeholders intended for future backend or platform integration

## 2. Stack and Dependencies

### 2.1 Runtime Stack
- Flutter with Material 3
- Dart SDK constraint: `^3.10.8`
- GetX for named routing and selected controllers
- `ChangeNotifier` + `AnimatedBuilder` in many feature modules
- `shared_preferences` wired through a storage service, but persistence is intentionally disabled
- `image_picker` and `video_player` included for media-related screens

### 2.2 Main Dependencies
- `get: ^4.7.2`
- `shared_preferences: ^2.5.3`
- `image_picker: ^1.1.2`
- `video_player: ^2.9.2`

### 2.3 Dev Dependencies
- `flutter_test`
- `flutter_lints: ^6.0.0`

## 3. Application Bootstrap

### 3.1 Startup Flow
1. [`lib/main.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/main.dart) initializes Flutter bindings.
2. [`lib/main.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/main.dart) awaits `ThemeService.instance.init()`.
3. [`lib/app.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/app.dart) builds `OptiZenqorApp`.
4. `OptiZenqorApp` renders `GetMaterialApp` with `AppRoute.routes`, `AppRoute.unknownRoute`, and `AppRoute.initialRoute`.
5. The initial route is `/`, which maps to the splash screen.

### 3.2 Theme Setup
- Theme mode is managed through `ThemeService`.
- [`lib/app.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/app.dart) rebuilds through `ValueListenableBuilder<ThemeMode>`.
- Light and dark themes are centralized in `lib/core/theme`.

## 4. Architecture

### 4.1 Folder Structure
- `lib/core`: shared app-wide building blocks
- `lib/feature`: feature modules grouped by domain
- `lib/route`: route name constants, route registry, and legacy generator
- `test`: minimal widget-level coverage
- `android`, `ios`, `web`: platform runners

### 4.2 Core Layer
`lib/core` currently contains:
- `common_data`: mock datasets
- `common_models`: shared entities such as users, posts, reels, stories, groups, messages, and products
- `config`, `constants`, `enums`
- `helpers`, `utils`, `validators`
- `services`: auth, analytics, upload, local storage, notifications, connectivity, deep links, media picker, API client, theme
- `theme`: global styling
- `widgets`: reusable UI building blocks

### 4.3 Feature Pattern
Most feature folders follow a lightweight module pattern with some combination of:
- `model`
- `controller`
- `repository`
- `screen`

Not every feature uses every layer, but the project generally keeps presentation, state, and data concerns grouped inside the feature directory.

### 4.4 State Management
The codebase uses a hybrid pattern:
- GetX for app-level routing and several shell/feed flows
- `ChangeNotifier` in many feature controllers
- `AnimatedBuilder` or framework widgets for screen updates

Examples:
- `MainShellController` uses `GetxController`
- `HomeFeedController` uses `GetxController`
- many secondary features expose `ChangeNotifier` controllers

## 5. Routing

### 5.1 Source of Truth
- [`lib/route/route_names.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/route_names.dart): string constants
- [`lib/route/app_route.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_route.dart): registered `GetPage` routes
- [`lib/route/app_routes.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_routes.dart): route whitelist
- [`lib/route/route_generator.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/route_generator.dart): legacy `MaterialPageRoute` helper

### 5.2 Registered Routes
Entry and auth:
- `/`
- `/onboarding`
- `/auth/login`
- `/auth/signup`
- `/auth/forgot-password`
- `/auth/reset-password`
- `/shell`

Core routes:
- `/search-discovery`
- `/communities`
- `/marketplace`
- `/notifications`
- `/creator-dashboard`
- `/premium`
- `/settings`

Settings sub-routes:
- `/settings/account`
- `/settings/password-security`
- `/settings/devices-sessions`
- `/settings/blocked-users`
- `/settings/language-accessibility`

Extended routes:
- `/drafts-scheduling`
- `/upload-manager`
- `/offline-sync`
- `/verification-request`
- `/personalization-onboarding`
- `/advanced-privacy-controls`
- `/share-repost-system`
- `/media-viewer`
- `/post-detail`
- `/account-switching`
- `/push-notification-preferences`
- `/report-center`
- `/activity-sessions`
- `/deep-link-handler`
- `/app-update-flow`
- `/localization-support`
- `/accessibility-support`
- `/explore-recommendation`
- `/blocked-muted-accounts`
- `/maintenance-mode`
- `/invite-referral`
- `/legal-compliance`
- `/group-chat`
- `/calls`
- `/groups`
- `/pages`
- `/hashtags`
- `/trending`
- `/jobs-networking`
- `/business-profile`
- `/bookmarks`
- `/saved-collections`
- `/wallet-payments`
- `/subscriptions`
- `/events`
- `/live-stream`
- `/safety-privacy`
- `/learning-courses`
- `/polls-surveys`
- `/support-help`
- `/user-profile`
- `/chat`

Unknown routes are handled by a dedicated not-found scaffold in [`lib/route/app_route.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_route.dart).

## 6. Main User Flow

### 6.1 Splash and Onboarding
- The app starts on the splash route.
- From splash, users are moved into onboarding and then authentication.
- Login, signup, forgot-password, and reset-password flows are present as separate routes.

### 6.2 Main Shell
[`lib/feature/home_feed/screen/main_shell_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/home_feed/screen/main_shell_screen.dart) provides the main app shell with:
- top app bar
- drawer-based feature hub
- offline banner driven by `ConnectivityService`
- bottom navigation

Bottom navigation tabs:
- Home
- Reels
- Chat
- Profile
- Settings

Drawer shortcuts:
- Communities
- Marketplace
- Creator Dashboard
- Premium Plans
- Drafts and Scheduling
- Upload Manager

### 6.3 Main Shell Actions
- home-only create-post action
- search shortcut
- notifications shortcut

The create-post flow still uses a direct `MaterialPageRoute` push rather than a named GetX route.

## 7. Data and Services

### 7.1 Mock Data
[`lib/core/common_data/mock_data.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/common_data/mock_data.dart) seeds local data for:
- users
- posts
- reels
- stories
- messages
- notifications
- groups
- products

### 7.2 Repository Layer
Repositories are mostly asynchronous mock adapters. Across the codebase they generally:
- return `Future` results
- simulate delay
- shape data for the UI
- avoid real backend persistence

### 7.3 Local Storage
[`lib/core/services/local_storage_service.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/services/local_storage_service.dart) is set up with persistence intentionally disabled:
- `_persistDataOnDevice` is `false`
- when persistence is off, values are stored in an in-memory map
- `shared_preferences` is only used if persistence is enabled and the plugin is available

Practical result:
- app data can survive during the current runtime session
- app data does not persist reliably across app restarts

### 7.4 Core Services
Current core services include:
- `analytics_service.dart`
- `api_client_service.dart`
- `auth_service.dart`
- `connectivity_service.dart`
- `deep_link_service.dart`
- `local_storage_service.dart`
- `media_picker_service.dart`
- `notification_service.dart`
- `theme_service.dart`
- `upload_service.dart`

Most of these are scaffolds or lightweight wrappers rather than production-ready integrations.

## 8. Feature Inventory
Current top-level feature directories under `lib/feature`:
- accessibility_support
- account_switching
- activity_sessions
- advanced_privacy_controls
- app_update_flow
- auth
- blocked_muted_accounts
- bookmarks
- business_profile
- calls
- chat
- communities
- creator_tools
- deep_link_handler
- drafts_and_scheduling
- events
- explore_recommendation
- follow_unfollow
- group_chat
- groups
- hashtags
- home_feed
- invite_referral
- jobs_networking
- learning_courses
- legal_compliance
- live_stream
- localization_support
- maintenance_mode
- marketplace
- media_viewer
- notifications
- offline_sync
- onboarding
- pages
- personalization_onboarding
- polls_surveys
- post_detail
- posts
- premium_membership
- push_notification_preferences
- recruiter_profile
- reels_short_video
- report_center
- safety_privacy
- saved_collections
- search_discovery
- seller_profile
- settings
- share_repost_system
- splash
- stories
- subscriptions
- support_help
- trending
- upload_manager
- user_profile
- verification_request
- wallet_payments

## 9. Feature Snapshot

### 9.1 Auth
- login, signup, forgot-password, and reset-password screens are present
- auth is mock-oriented and not backed by a production identity provider

### 9.2 Feed and Content
- home feed, reels, post detail, stories, hashtags, trending, and bookmarks are represented
- content creation exists through the create-post flow
- multiple supporting modules exist for saved collections, drafts, and uploads

### 9.3 Social and Community
- chat and group chat flows are present
- communities, groups, pages, follow/unfollow, and calls modules exist
- user, seller, recruiter, and business profile variants are included

### 9.4 Platform and Growth Features
- premium, subscriptions, wallet payments, events, jobs networking, learning courses, and creator tools are available as separate modules
- support, reporting, legal, privacy, accessibility, and localization surfaces are also present

## 10. UI and Theming
- Material 3 is enabled
- theme configuration lives in `lib/core/theme`
- app theme mode is controlled at runtime through `ThemeService`
- shared widgets include buttons, text fields, avatars, loaders, empty/error states, section headers, post cards, and an inline video player

## 11. Testing and Analysis
- [`analysis_options.yaml`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/analysis_options.yaml) uses Flutter lint defaults
- automated test coverage is currently minimal
- [`test/widget_test.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/test/widget_test.dart) verifies that the app bootstraps and renders the splash branding

Useful commands:
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`

## 12. Current Limitations
- backend integration is largely incomplete
- most repositories are still mock implementations
- local storage is non-persistent by design in the current setup
- media, notifications, deep links, and upload flows are not fully production wired
- feature breadth is high, but several modules are still UI-first scaffolds

## 13. Recommended Next Steps
1. Connect repositories to real API or local database adapters.
2. Decide whether `LocalStorageService` should remain session-only or move to true device persistence.
3. Standardize state management where feature complexity is growing.
4. Expand automated testing beyond the single bootstrap widget test.
5. Audit feature modules for route coverage, dependency wiring, and production-readiness.
