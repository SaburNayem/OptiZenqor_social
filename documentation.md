# OptiZenqor Social - Project Documentation

## 1. Project Overview
OptiZenqor Social is a Flutter social-platform app scaffold with a feature-first folder structure, broad route coverage, and mock-backed product flows that now cover much more of a modern social-media surface. The app includes onboarding, authentication, a multi-tab main shell, feed and reels experiences, chat, notifications, settings, creator tooling, marketplace and subscription surfaces, and a large set of supporting modules for privacy, reporting, accessibility, events, learning, referral, moderation, and profile variations.

The project is still largely prototype-oriented:
- most screens are powered by local models, mock repositories, or in-memory controller state
- many repositories simulate network work with delayed `Future` responses
- several services and advanced tools are intentionally lightweight wrappers or placeholders for future integrations

## 2. Tech Stack

### 2.1 Runtime
- Flutter
- Dart SDK `^3.10.8`
- Material 3
- GetX for app-level routing and some screen controllers
- `ChangeNotifier` and `AnimatedBuilder` across many feature flows

### 2.2 Main dependencies
- `get: ^4.7.2`
- `shared_preferences: ^2.5.3`
- `image_picker: ^1.1.2`
- `video_player: ^2.9.2`
- `cupertino_icons: ^1.0.8`

### 2.3 Dev dependencies
- `flutter_test`
- `flutter_lints: ^6.0.0`

## 3. App Bootstrap

### 3.1 Startup flow
1. [`lib/main.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/main.dart) initializes Flutter bindings.
2. [`lib/main.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/main.dart) awaits `ThemeService.instance.init()`.
3. [`lib/app.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/app.dart) launches `OptiZenqorApp`.
4. [`lib/app.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/app.dart) builds a `GetMaterialApp` with `AppRoute.routes`, `AppRoute.unknownRoute`, and `AppRoute.initialRoute`.
5. The initial route is `/`, which renders the splash screen.

### 3.2 Splash and first navigation
- [`lib/feature/splash/screen/splash_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/splash/screen/splash_screen.dart) shows branded animated splash content.
- [`lib/feature/splash/controller/splash_controller.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/splash/controller/splash_controller.dart) waits 2 seconds, checks onboarding completion and auth session state, then uses `Navigator.pushReplacementNamed`.
- The route decision is:
  - onboarding not complete -> `/onboarding`
  - onboarding complete and session exists -> `/shell`
  - onboarding complete and no session -> `/auth/login`

### 3.3 Theme setup
- [`lib/core/services/theme_service.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/services/theme_service.dart) stores the active `ThemeMode` in a `ValueNotifier`.
- [`lib/app.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/app.dart) rebuilds with `ValueListenableBuilder<ThemeMode>`.
- [`lib/core/theme/app_theme.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/theme/app_theme.dart) defines light and dark themes.
- Material 3 is enabled in both modes.

## 4. Architecture

### 4.1 Top-level structure
- `lib/core`: shared models, mock data, services, constants, widgets, helpers, enums, and validators
- `lib/feature`: domain-oriented feature modules
- `lib/route`: route constants, GetX route registry, whitelist helpers, and a legacy route generator
- `test`: minimal widget coverage
- `android`, `ios`, `web`: platform runners

### 4.2 Core layer
`lib/core` currently includes:
- `common_data`: shared mock seed data
- `common_models`: app-wide entities like users, posts, reels, stories, messages, groups, products, notifications, and offline actions
- `services`: theme, local storage, auth, analytics, upload, notifications, connectivity, deep links, media picker, and API client utilities
- `theme`: shared colors and `ThemeData`
- `widgets`: reusable avatars, loaders, post cards, text fields, empty/error states, and media helpers

Shared models now carry richer social-product metadata, including:
- user verification status, badge styles, public profile metadata, notes, and supporter-badge state
- post audience, location, tagged users, mentions, alt text, edit history, sponsored labels, view/share counts, and repost-history placeholders
- reel cover selection, text overlays, subtitle flags, trim metadata, remix flags, and draft markers
- message delivery, reply-thread, starred-message, and message-kind placeholders

### 4.3 Feature module pattern
Most features use some combination of:
- `model`
- `controller`
- `repository`
- `screen`

Not every module uses every layer, but responsibilities are generally grouped within the feature directory.

### 4.4 State management
The app uses a mixed approach rather than one single state pattern:
- GetX for named routing and some controllers such as `MainShellController` and `HomeFeedController`
- `GetBuilder` for shell and feed rebuilds
- `ChangeNotifier` plus `AnimatedBuilder` for many feature controllers
- plain Dart controller classes for simple orchestration flows like splash

### 4.5 Navigation style
Navigation is also mixed:
- named GetX routes are the main public app routing mechanism
- several internal flows still use `Navigator.push` and `MaterialPageRoute`

Examples:
- splash bootstrap uses `Navigator.pushReplacementNamed`
- create-post, post-detail, chat-detail, and profile drill-down flows use direct `Navigator` pushes

## 5. Routing

### 5.1 Route sources
- [`lib/route/route_names.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/route_names.dart): route string constants
- [`lib/route/app_route.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_route.dart): main `GetPage` registry
- [`lib/route/app_routes.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_routes.dart): public-route helper list
- [`lib/route/route_generator.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/route_generator.dart): legacy `MaterialPageRoute` mapper for selected routes

### 5.2 Registered GetX routes
[`lib/route/app_route.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_route.dart) currently contains 61 `GetPage` entries, including the unknown-route fallback.

Main named routes:
- `/`
- `/onboarding`
- `/auth/login`
- `/auth/signup`
- `/auth/forgot-password`
- `/auth/reset-password`
- `/shell`
- `/search-discovery`
- `/communities`
- `/marketplace`
- `/notifications`
- `/creator-dashboard`
- `/premium`
- `/settings`
- `/settings/account`
- `/settings/password-security`
- `/settings/devices-sessions`
- `/settings/blocked-users`
- `/settings/language-accessibility`
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

Unknown routes fall back to a simple not-found scaffold in [`lib/route/app_route.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/route/app_route.dart).

### 5.3 Routed vs internal-only modules
There are currently 59 top-level feature directories under `lib/feature`.

Feature directories present in the codebase but not exposed as standalone named GetX routes include:
- `follow_unfollow`
- `home_feed`
- `posts`
- `reels_short_video`
- `stories`
- `recruiter_profile`
- `seller_profile`
- `auth` subfeatures beyond the public auth routes

These modules are still used by the app, but they are reached through tabs, nested flows, or internal composition rather than direct route entry points.

## 6. Main User Experience

### 6.1 Entry and auth flow
- The app starts on splash.
- Onboarding is a separate screen and completion state is stored through `OnboardingRepository`.
- Login writes a session payload through `AuthRepository` and `LocalStorageService`.
- Signup, forgot password, and reset password have dedicated screens and controllers.

### 6.2 Main shell
[`lib/feature/home_feed/screen/main_shell_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/home_feed/screen/main_shell_screen.dart) is the primary post-login container. It includes:
- an app bar with contextual tab title
- a drawer-based feature hub
- an offline banner area
- a bottom `NavigationBar`

Bottom tabs:
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
- Drafts & Scheduling
- Upload Manager

App bar actions:
- create button on the home tab only
- search
- notifications

### 6.3 Home feed
[`lib/feature/home_feed/screen/home_feed_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/home_feed/screen/home_feed_screen.dart) includes:
- pull-to-refresh feed loading
- an inline quick composer
- stories
- feed tab switching
- infinite-scroll style pagination trigger
- post cards with like, comment, bookmark, share, report, and not-interested interactions
- recommendation feedback controls such as show-less-like-this, hide creator, hide topic, and why-am-I-seeing-this placeholders
- post-detail and profile drill-down via `Navigator`

### 6.4 Content creation depth
[`lib/feature/home_feed/screen/create_post_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/home_feed/screen/create_post_screen.dart) now supports richer local post composition metadata:
- audience selection
- location tagging
- people tagging
- co-author placeholders
- alt-text placeholder input
- local draft saving
- draft version-history and edit-history placeholders

Related creation surfaces now also expose placeholders for:
- story stickers, polls, question stickers, emoji sliders, mentions, locations, music, and links
- reel audio attach, text overlays, captions, trim/crop, cover selection, remix/duet, and draft-save flows

### 6.5 Chat and profile flows
- [`lib/feature/chat/screen/chat_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/chat/screen/chat_screen.dart) renders inbox conversations with pinned, archived, unread, retry, notes/status UI, and message-request placeholders.
- [`lib/feature/chat/screen/chat_detail_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/chat/screen/chat_detail_screen.dart) adds in-conversation search, media/docs/links tabs, unread-marker jump UI, voice-note placeholder, disappearing-message placeholder, and star/reply-thread placeholders.
- [`lib/feature/user_profile/screen/user_profile_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/user_profile/screen/user_profile_screen.dart) now supports verification state, role-based badges, public profile sharing, QR/profile-preview placeholders, notes, pinned and featured content, tagged-content history, suggested contacts, and account-center export/deactivation placeholders.

### 6.6 Discovery, pages, communities, and engagement
- [`lib/feature/search_discovery/screen/search_discovery_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/search_discovery/screen/search_discovery_screen.dart) now includes advanced entity filters, suggestion groups, trending search terms, hashtag-detail placeholders, recommendation-feedback sections, and richer explore sections.
- [`lib/feature/post_detail/screen/post_detail_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/post_detail/screen/post_detail_screen.dart) includes comment mentions, comment reactions, and post-level view/share context.
- [`lib/feature/communities/screen/communities_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/communities/screen/communities_screen.dart) includes owner/admin moderation placeholders such as pin announcement, join approval, member removal, role assignment, mute-member, and rule-management actions.
- [`lib/feature/pages/screen/pages_screen.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/pages/screen/pages_screen.dart) now exposes page categories, configurable action-button labeling, review placeholders, visitor-post placeholders, and follower-insight placeholders.

### 6.7 Connectivity simulation
- [`lib/core/services/connectivity_service.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/services/connectivity_service.dart) is a local `ChangeNotifier`.
- It exposes `isOnline`, `lastFailedAction`, and retry helpers.
- The current implementation is app-side simulation, not a real device/network monitoring integration.

## 7. Data, Storage, and Services

### 7.1 Mock data
[`lib/core/common_data/mock_data.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/common_data/mock_data.dart) seeds app content for:
- users
- posts
- reels
- stories
- messages
- notifications
- groups
- products

The sample users already cover multiple roles such as creator, business, regular user, seller, and recruiter.

### 7.2 Repository layer
Repositories are mostly mock adapters. In practice they often:
- return `Future` values
- simulate latency
- transform local model data for UI consumption
- avoid true backend integration

Notable repository additions and deepened local flows include:
- [`lib/feature/drafts_and_scheduling/repository/drafts_and_scheduling_repository.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/feature/drafts_and_scheduling/repository/drafts_and_scheduling_repository.dart) for durable local draft storage
- expanded feed preference persistence for recommendation controls
- expanded profile export caching and data-export request logging

### 7.3 Local storage
[`lib/core/services/local_storage_service.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/services/local_storage_service.dart) supports `SharedPreferences` storage with an in-memory fallback.

Current behavior:
- `_persistDataOnDevice` is set to `true`
- the service tries to initialize `SharedPreferences`
- if the plugin is unavailable, it gracefully falls back to an in-memory map

Practical effect:
- theme mode, onboarding completion, and auth session state are intended to persist on device
- persistence may fall back to current-session memory in environments where the plugin is unavailable

The persisted local surface now also includes:
- durable post/reel drafts
- bookmarks and saved collections
- blocked and muted states
- recommendation preferences and related safety/control settings
- account-export request records

### 7.4 Core services
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

Most of these remain lightweight wrappers or scaffolds rather than production integrations.

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

## 9. Functional Snapshot

### 9.1 Social content
- feed, reels, post detail, stories, hashtags, trending, and bookmarks are represented
- content creation now includes richer audience, tagging, location, alt-text, draft, and history metadata
- saved collections, drafts, and upload management support creator workflows
- profile surfaces support pinned content, featured content, tagged-content history, and note/status UI

### 9.2 Messaging and community
- one-to-one chat and group chat are present
- direct messaging now includes notes/status, message requests, search, media/docs/links tabs, unread markers, and multiple placeholder depth features for replies, starred messages, voice notes, disappearing messages, and themes
- communities, groups, pages, and calls modules are available
- multiple profile variants exist for user, business, seller, and recruiter contexts

### 9.3 Growth, commerce, and creator surfaces
- marketplace, wallet payments, subscriptions, premium membership, and events are implemented as separate modules
- creator dashboard, jobs networking, learning courses, and live stream extend the app beyond the core feed
- live, events, and learning screens now include richer moderation, host-tools, saved-item, instructor-profile, certificate, quiz, and audio-room placeholders
- referral and growth-retention surfaces now expose referral-status, invite-reward, streak, milestone, and achievement placeholders

### 9.4 Platform support modules
- privacy, safety, reporting, legal compliance, accessibility, localization, deep-link handling, offline sync, and app update flows all have dedicated surfaces
- safety and privacy now also include hidden-word, sensitive-content, anti-spam, child/teen safety, parental-control, copyright, impersonation, harassment, self-harm, and appeal placeholders
- support/help now includes report-bug, changelog, remote-config, feature-flag, and crash-reporting placeholders

## 10. UI and Theme Notes
- the app uses Material 3
- theme configuration is centralized in [`lib/core/theme/app_theme.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/theme/app_theme.dart)
- theme switching is handled by [`lib/core/services/theme_service.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/lib/core/services/theme_service.dart)
- reusable widgets live under `lib/core/widgets`
- several feature screens now use `Chip`, `ChoiceChip`, `ActionChip`, and card-based placeholder panels to stage future backend-connected product depth without changing the current structure

## 11. Testing and Analysis
- [`analysis_options.yaml`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/analysis_options.yaml) uses Flutter lint defaults
- automated coverage is still minimal
- [`test/widget_test.dart`](/Users/bdcalling/Desktop/nayamProjects/OptiZenqor_social/test/widget_test.dart) contains a bootstrap widget test that now pumps through the splash timer before settling
- `flutter analyze` passes with no issues as of March 24, 2026
- `flutter test` passes as of March 24, 2026

Useful commands:
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`

## 12. Current Limitations
- backend integration is still largely incomplete
- most repositories remain mock implementations
- state management is intentionally mixed and not yet fully standardized
- navigation is split between GetX named routes and direct `Navigator` pushes
- connectivity, upload, deep links, analytics, notifications, and API services are mostly scaffolds
- many new social-media-grade features are present as durable local flows or UI placeholders awaiting real backend policy, search, messaging, recommendation, moderation, and media-processing services

## 13. Suggested Next Steps
1. Connect high-value repositories to real API or local database implementations.
2. Replace placeholder-only product depth with real backend-connected flows, especially in messaging, moderation, verification, discovery, and creator monetization.
3. Decide which flows should stay on `Navigator` and which should be consolidated into named GetX routes.
4. Standardize state-management patterns where feature complexity is growing.
5. Expand automated tests beyond bootstrap coverage and add targeted tests for drafts, recommendation preferences, and richer profile/chat interactions.
