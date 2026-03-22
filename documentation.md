# OptiZenqor Social - Technical Documentation

## 1. Project Overview
OptiZenqor Social is a Flutter mobile social platform scaffold built with modular feature folders, centralized navigation, reusable core components, and mock-data-first flows.

This codebase is designed to:
- ship quickly with polished UI flows
- scale safely with feature isolation
- support backend integration without rewriting UI
- support role-based experiences on app-side only

## 2. Tech Stack
- Flutter (Material 3)
- Dart (null safety)
- ChangeNotifier-based feature controllers
- Mock local data for early product flows

## 3. App-Side Roles
Defined in lib/core/enums/user_role.dart:
- guest
- user
- creator
- business
- seller
- recruiter

## 4. Repository Structure

### Root
- lib/
- android/
- ios/
- web/
- test/
- pubspec.yaml
- analysis_options.yaml

### Core Layer (lib/core)
- constants/: app strings, dimensions, assets
- theme/: colors and theme configuration
- utils/: logger, debouncer
- widgets/: reusable UI components
- services/: backend-ready service stubs
- helpers/: formatting helpers
- validators/: input validation rules
- common_models/: shared app models
- common_data/: mock data source
- enums/: role and view state enums
- config/: app-level config placeholders

### Routing Layer (lib/route)
- route_names.dart: route constants
- route_generator.dart: centralized route creation
- app_routes.dart: public route grouping

### Feature Layer (lib/feature)
Features are modular and mostly follow:
- model/
- controller/
- screen/
- widget/ (used where needed)

Implemented feature groups include:
- splash, onboarding, auth
- main_shell
- home_feed, reels_short_video, stories
- chat, notifications, user_profile, settings
- search_discovery, communities, marketplace
- creator_tools, premium_membership
- advanced product modules (drafting/upload/offline/privacy/report/etc.)

## 5. App Bootstrap and Lifecycle

### main.dart
- Initializes Flutter binding
- Runs OptiZenqorApp

### app.dart
- Configures MaterialApp
- Applies light and dark theme
- Hooks route generator
- Starts from splash route

## 6. Navigation Architecture

### Top-level flow
1. Splash
2. Onboarding
3. Auth (login/signup/forgot/reset)
4. Main Shell

### Main Shell
Located at:
- lib/feature/main_shell/screen/main_shell_screen.dart (feature-level wrapper)
- lib/feature/home_feed/screen/main_shell_screen.dart (implementation)

Layout:
- Top AppBar:
  - Search action
  - Notifications action
- Drawer:
  - Feature shortcuts (communities, marketplace, creator dashboard, premium, drafts, upload manager)
- Bottom navigation tabs:
  - Home
  - Reels
  - Chat
  - Profile
  - Settings

Tab rendering uses explicit index mapping to avoid icon/content mismatch.

## 7. State Management Pattern
Each feature controller handles:
- loading data
- state transitions
- user action methods

Screens use AnimatedBuilder to react to controller updates.

Shared view states (idle/loading/success/empty/error) are defined in:
- lib/core/enums/view_state.dart

## 8. Data Strategy

### Current
- Data comes from mock source:
  - lib/core/common_data/mock_data.dart

### Future backend migration
- Keep UI and controller API stable
- Replace mock fetch/write logic inside controllers with repository/service calls
- Use service stubs in lib/core/services as integration points

## 9. Key Implemented User Flows

### Auth
- Login with role selection
- Signup placeholders
- Forgot password + reset password placeholders

### Home Feed
- Story ring strip
- Feed cards
- Pull to refresh
- Post interactions (tap, menu, like/comment/save)

### Post Actions
- Tap post -> post detail screen
- Three-dot menu -> action bottom sheet

### Reels
- Vertical swipe feed
- Engagement action UI

### Chat
- Inbox list
- Tap row opens chat detail screen
- Conversation UI with input placeholder

### Notifications
- Dedicated notifications page
- Access from top app bar icon

### Settings
- Settings hub with route-driven items
- Links to advanced modules

## 10. Advanced Feature Modules
The app includes production-oriented placeholder modules for future deep implementation:

- drafts_and_scheduling
  - draft save/schedule placeholders
- upload_manager
  - progress/retry/failed states
- offline_sync
  - offline queue + sync trigger
- verification_request
  - request/status workflow UI
- personalization_onboarding
  - interest selection UI
- advanced_privacy_controls
  - privacy toggles (mentions/comments/private account)
- share_repost_system
  - share/repost options
- media_viewer
  - fullscreen zoomable media viewer
- post_detail
  - detailed post screen + comment thread placeholder
- account_switching
  - identity switch UI
- push_notification_preferences
  - category-level push toggles
- report_center
  - reason selection + report history
- activity_sessions
  - activity log and session placeholders
- deep_link_handler
  - deep-link handling placeholder
- app_update_flow
  - optional/forced update UI placeholder
- localization_support
  - locale selection with RTL-ready option
- accessibility_support
  - reduced motion, larger targets, high contrast toggles
- explore_recommendation
  - recommendation surfaces for people, communities, and reels
- blocked_muted_accounts
  - blocked/muted/restricted account management UI
- maintenance_mode
  - maintenance downtime and retry screen
- invite_referral
  - invite link and referral code placeholders
- legal_compliance
  - terms/privacy/guidelines acceptance placeholders

## 11. Reusable UI Components
Located in lib/core/widgets:
- app_button.dart
- app_text_field.dart
- app_avatar.dart
- app_loader.dart
- empty_state_view.dart
- error_state_view.dart
- section_header.dart
- post_card.dart

These support consistency and avoid duplicated UI code across features.

## 12. Theming and UX Standards
- Material 3 setup
- Light and dark theme support
- Consistent spacing and radius constants
- Shared color system
- Feedback patterns via snackbars and sheets

## 13. Validation and Quality
- Static analysis command: flutter analyze
- Current status: no analyzer issues

## 14. How to Add a New Feature
1. Create feature folder under lib/feature
2. Add model/controller/screen (and widget if needed)
3. Implement controller logic and state updates
4. Build screen UI using reusable core widgets
5. Add route name in route_names.dart
6. Add route mapping in route_generator.dart
7. Link entry point from shell, drawer, or settings
8. Run flutter analyze

## 15. Known Placeholder Areas (Expected in Scaffold Stage)
- API integration in services/controllers
- Persistent storage and cache strategy
- Real media upload lifecycle (foreground/background workers)
- Real-time chat transport (socket/websocket)
- Full moderation, legal, and compliance backend workflows

## 16. Recommended Next Steps
1. Introduce repository interfaces per feature and connect to API client
2. Add persistent local cache for feed/chat/offline queue
3. Add widget and integration tests for key flows
4. Add localization arb files and Flutter localization delegates
5. Add deep-link package integration and notification click routing

## 17. Run Instructions
1. Install dependencies:
   - flutter pub get
2. Analyze code:
   - flutter analyze
3. Run app:
   - flutter run

---
Documentation maintained for current branch: main
