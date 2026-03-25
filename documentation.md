APPROVED APP ARCHITECTURE

- `lib/core`
  - `constant/`
  - `common_widget/`
  - `data/api/`
  - `data/service/`
  - `data/service_model/`
  - `data/shared_preference/`
- `lib/feature`
  - only feature folders
  - each feature uses only what it needs: `common/`, `model/`, `controller/`, `repository/`, `screen/`
- `lib/route`
  - route-only files

See `ARCHITECTURE.md` for the detailed structure and migration rules.

I already have an existing Flutter project named "OptiZenqor Social".
Do NOT rebuild the app from scratch.
Do NOT replace the architecture blindly.
Do NOT generate a new unrelated project.
Your task is to UPGRADE, REFACTOR, STANDARDIZE, and COMPLETE my CURRENT existing project while preserving its working structure and current feature coverage.

You must work as a senior Flutter architect and product-minded engineer.
Treat the current codebase as an existing social media platform scaffold that already includes many screens, routes, mock repositories, and placeholder flows.

==================================================
1. CURRENT PROJECT CONTEXT YOU MUST RESPECT
==================================================

This existing project already has:
- Flutter + Dart
- Material 3
- GetX routing and some controllers
- mixed state management using GetX + ChangeNotifier + AnimatedBuilder + some plain controller flows
- feature-first folder structure
- route coverage for many modules
- splash, onboarding, login, signup, reset password
- main shell with bottom navigation and drawer
- home feed, reels, chat, profile, settings
- search/discovery, communities, groups, pages, marketplace
- creator dashboard, subscriptions, premium, wallet, events, live stream
- report center, safety/privacy, legal/compliance, accessibility, localization
- bookmarks, saved collections, drafts/scheduling, upload manager
- user profile, business profile, recruiter profile, seller profile
- mock repositories and local/in-memory or shared_preferences-backed flows
- many advanced feature placeholders already added

The current codebase is broad but prototype-oriented:
- many repositories are still mock-based
- architecture is mixed and not fully standardized
- navigation is mixed between GetX named routes and Navigator pushes
- some services are scaffold-level only
- many advanced modules are UI placeholders awaiting deeper logic
- current structure already runs and should be preserved, improved, and completed

Your job is to transform this existing project into a cleaner, more scalable, more production-ready app foundation WITHOUT destroying the current product breadth.

==================================================
2. PRIMARY GOAL
==================================================

Upgrade the current OptiZenqor Social codebase into a high-quality, scalable, production-style Flutter social media app foundation.

You must:
- keep the existing project identity
- preserve existing feature modules unless there is a very strong architectural reason to merge/refactor
- improve consistency
- reduce duplication
- standardize patterns
- deepen incomplete modules
- replace weak placeholders with stronger local/mock logic
- make the codebase easier for future API integration
- keep the app runnable

This task is a REFACTOR + EXPANSION task, not a blank greenfield generation.

==================================================
3. ARCHITECTURE RULES
==================================================

Keep the existing feature-first structure, but improve it consistently.

Current top-level intent should remain similar to:
- lib/core
- lib/feature
- lib/route
- lib/app.dart
- lib/main.dart

Inside features, standardize toward a consistent structure where appropriate, such as:
- model/
- controller/
- screen/
- widget/   if needed

Do not force every feature into unnecessary layers if the feature is very small, but for medium and large features use consistent organization.

Standardize the app around:
- clear models/entities
- repository abstraction
- mock/local repository implementation
- controller/viewmodel logic separation
- reusable widgets
- app-wide result/error/loading handling
- route consistency
- dependency injection consistency
- theme consistency
- local persistence consistency

==================================================
4. STATE MANAGEMENT STANDARDIZATION
==================================================

The current project uses mixed patterns.
Do not do a dangerous full rewrite of every feature at once.

Instead:
- keep GetX for routing and dependency injection
- keep GetX for high-level shell / app state where it is already used
- gradually standardize feature state into one predictable pattern
- prefer GetX controllers for medium/large interactive features
- reduce unnecessary ChangeNotifier usage where it adds inconsistency
- keep simple local state local when appropriate
- remove architectural confusion, not just code lines

The final result should feel consistent, even if migration is incremental.

==================================================
5. ROUTING STANDARDIZATION
==================================================

The current project already has many named GetX routes plus some direct Navigator pushes.
Refactor navigation carefully.

Your task:
- preserve all working existing route entry points
- reduce unnecessary mixed navigation
- move more flows toward a consistent named-route or GetX-navigation approach where helpful
- keep internal local navigation only where it is cleaner and justified
- ensure deep screen flows still work properly
- keep unknown route handling
- make route definitions cleaner and easier to extend

Do not break current module access patterns.

==================================================
6. FEATURE MODULES YOU MUST PRESERVE AND IMPROVE
==================================================

The project already includes many feature areas. Keep them and improve them.

Preserve and deepen:
- splash
- onboarding
- auth
- main shell
- home feed
- posts
- create post
- reels / short video
- stories
- chat
- group chat
- notifications
- search / discovery
- hashtags
- trending
- communities
- groups
- pages
- user profile
- business profile
- recruiter profile
- seller profile
- creator tools
- subscriptions
- premium membership
- wallet / payments
- marketplace
- events
- live stream
- bookmarks
- saved collections
- drafts and scheduling
- upload manager
- personalization onboarding
- safety/privacy
- report center
- settings
- accessibility
- localization
- legal compliance
- invite/referral
- support/help
- offline sync
- verification request
- account switching
- blocked/muted accounts
- activity sessions
- deep link handler
- app update flow

If new shared abstractions are needed, add them cleanly without damaging current screens.

==================================================
7. SETTINGS MODULE: MAKE IT STRONG AND COMPLETE
==================================================

The settings area must become one of the strongest parts of the app.

Preserve and improve the existing settings module and make it fully structured with detailed sub-screens for:

- Account
- Privacy
- Security
- Notifications
- Messages & Calls
- Feed & Content Preferences
- Creator / Professional Tools
- Monetization & Payments
- Communities & Groups
- Data & Privacy Center
- Accessibility
- Language & Region
- Connected Apps
- Help & Safety
- About

Deepen current settings with better local logic and cleaner UX for:
- profile editing
- username/display name/bio/pronouns/links
- account type switching
- verification request entry
- deactivate/delete/download data
- privacy visibility controls
- blocked / muted / restricted users
- tagging / mention / repost / comment permissions
- activity status / last seen / read receipts
- hidden words / sensitive content
- discoverability and search indexing toggles
- security checkup
- active sessions / trusted devices
- password / 2FA / biometric lock
- notification category toggles
- chat/media/download/call preferences
- feed mode / autoplay / data saver / hidden topics / recommendation reset
- ad personalization and activity preferences
- data summary / history / cache clearing / permissions
- accessibility options
- support, safety, appeals, account status, strikes, violations

Make settings clean, scalable, and role-aware.

==================================================
8. DRAWER AND MAIN SHELL IMPROVEMENT
==================================================

The current app already has a shell, bottom navigation, and drawer.
Refine them instead of replacing them.

Requirements:
- improve drawer hierarchy
- group drawer items better
- make drawer role-aware
- keep creator/business/admin-only sections conditional
- improve shell state persistence across tabs
- improve app bar logic by active tab
- make navigation feel more professional and less prototype-like
- preserve existing major entry points like communities, marketplace, creator dashboard, premium, drafts, scheduling, saved posts, archived posts, events, live stream, upload manager

Bottom navigation should remain strong and stable.
Only adjust if a clearly better scalable structure is needed.

==================================================
9. HOME FEED AND CONTENT SYSTEM
==================================================

The current feed already includes quick composer, stories, tabs, pagination, post cards, recommendation feedback, and drill-down flows.
Deepen and standardize it.

Improve:
- feed tab architecture
- pagination logic
- refresh behavior
- post card reuse
- recommendation feedback system
- loading, empty, retry, and offline states
- action handling consistency
- local post state mutation consistency
- bookmarking / save state consistency
- like/comment/share/report/not interested flow consistency

Preserve support for:
- text posts
- image posts
- carousel posts
- video/reel preview
- poll/event/product placeholders where already present
- mentions, hashtags, location, alt text, audience, sponsored labels, view/share counts, edit history placeholders

Make the content model cleaner and more scalable.

==================================================
10. CREATE POST / DRAFTS / SCHEDULING
==================================================

The current project already supports rich create-post metadata, drafts, scheduling split, and placeholders.
Upgrade this flow into a stronger local-first content composer.

Requirements:
- preserve existing create-post flow
- improve form organization
- modularize media, audience, tagging, alt text, location, hashtag, co-author, and scheduling sections
- strengthen local validation
- improve local draft persistence
- support draft versioning in a cleaner way
- make scheduled items clearly separate from drafts
- make upload manager, drafts, and scheduling feel like one connected ecosystem

Do not just scaffold. Make these modules practically usable with mock/local persistence.

==================================================
11. CHAT AND INBOX
==================================================

The current chat module already includes inbox, detail, search, pinned, archived, unread, requests, tabs, media/docs/links tabs, disappearing placeholders, reply/thread placeholders, and more.

Refine it into a cleaner messaging architecture:
- improve inbox state handling
- standardize conversation model usage
- standardize message model usage
- improve message action logic
- keep local/mock-ready real-time structure
- keep future websocket integration easy
- improve starred, reply, request, archive, mute, block, search, and unread marker behavior
- make chat detail UI more consistent and scalable
- preserve direct chat and group chat separation where helpful

==================================================
12. PROFILE SURFACES
==================================================

The project already supports user profile and role-based profile variations.
Preserve and refine:
- user profile
- business profile
- recruiter profile
- seller profile

Unify shared profile foundations while allowing role-based specialization.

Improve:
- profile header consistency
- tab structure
- relation states
- verification/badge rendering
- pinned and featured content
- notes/status areas
- profile share and QR logic placeholders
- export/deactivate placeholders
- tagged content history
- suggested people or related entity sections

==================================================
13. DISCOVERY / COMMUNITIES / PAGES / MARKETPLACE / EVENTS
==================================================

These modules already exist. Do not remove them.

Improve them by:
- reducing repetitive placeholder code
- standardizing section cards and list patterns
- making filters/tabs/search patterns more reusable
- improving local mock flows
- preserving moderation/admin/owner action placeholders
- making list/detail page relationships clearer
- improving empty/loading states
- preparing API contract boundaries clearly

==================================================
14. SERVICES AND INFRASTRUCTURE
==================================================

The project already has services such as:
- theme
- local storage
- auth
- analytics
- upload
- notifications
- connectivity
- deep links
- media picker
- API client

Improve these carefully:
- do not overengineer fake production integrations
- make interfaces and responsibilities clearer
- keep them as strong scaffolds for future real integration
- improve local storage keys and typed access patterns
- improve mock upload and background-task simulation
- improve connectivity/offline action structure
- improve analytics event abstraction
- improve API client abstraction even if still mock-based

==================================================
15. DESIGN SYSTEM AND UI CONSISTENCY
==================================================

The app already uses Material 3 and shared theme files.
Refine the visual system across the app.

Requirements:
- unify spacing
- unify cards, chips, pills, avatars, badges, section headers
- unify empty states, loading states, and error states
- unify bottom sheet patterns
- unify action menus
- improve list/detail consistency
- improve role badges and verification visuals
- improve creator/business visual differentiation
- keep light and dark themes both polished
- preserve the current project feel but make it more premium and coherent

Do not create a random completely new design language.
Evolve the existing app into a better product system.

==================================================
16. TESTING AND CODE HEALTH
==================================================

The project already passes analyze and test according to documentation.
Do not break that.

Improve code health by:
- keeping flutter analyze clean
- keeping flutter test passing
- reducing duplication
- improving naming
- removing dead or confusing code when safe
- adding targeted tests for critical local flows where valuable
- keeping files reasonably sized
- extracting reusable widgets when repeated
- using comments only where useful

==================================================
17. DELIVERABLE FORMAT
==================================================

You must produce real code changes, not just explanations.

Work in this order:

Step 1:
Audit the current project structure and identify the highest-value refactor targets without deleting breadth.

Step 2:
Standardize shared foundations:
- route organization
- dependency setup
- reusable widgets
- result/loading/error patterns
- shared models where obvious duplication exists

Step 3:
Refine the main app shell, drawer, and settings architecture.

Step 4:
Refine core social flows:
- home feed
- create post
- drafts/scheduling/upload manager
- chat/inbox
- profile system

Step 5:
Refine supporting feature modules without breaking current route coverage.

Step 6:
Ensure the app still runs cleanly with mock/local data.

==================================================
18. IMPORTANT CONSTRAINTS
==================================================

- Do not rebuild from scratch
- Do not delete large feature surfaces just because backend is missing
- Do not replace everything with generic placeholders
- Do not collapse the project into a tiny MVP
- Do not destroy existing routes
- Do not create a new architecture that ignores the current project
- Do not give only advice; make real implementation improvements
- Do not reduce feature breadth

Instead:
- preserve breadth
- improve depth
- improve consistency
- improve scalability
- improve maintainability
- improve local/mock realism
- prepare for future backend integration

==================================================
19. FINAL EXPECTATION
==================================================

The result should feel like:
- the same OptiZenqor Social project
- but cleaner
- more organized
- more consistent
- more polished
- more professional
- more scalable
- more complete

Do not output only a plan.
Do actual repository-quality implementation.
If the task is too large for one pass, start by making the highest-value architectural and feature improvements first, while keeping the app runnable and preserving the existing product surface.
