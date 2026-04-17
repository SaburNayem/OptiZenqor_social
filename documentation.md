# OptiZenqor Socity Implementation Documentation

This document converts the requested product feature list into a concrete Flutter implementation plan for the existing OptiZenqor Socity codebase.

It is written for the current project structure:

- `lib/core`
- `lib/feature`
- `lib/route`
- Flutter + Material 3
- GetX for routing and feature state standardization

This is a product-and-engineering contract, not a redesign request.
All screens should remain static-first, mock-driven, and fully clickable.
Every visible button, tile, icon action, card action, chip, tab, bottom sheet item, popup menu item, and long-press action must do something predictable even before backend integration.

## 1. Delivery Rules

### 1.1 Architecture Rule

Every medium or large feature should follow:

```text
lib/feature/<feature_name>/
  controller/
  model/
  repository/
  screen/
  widget/        optional
  common/        optional
```

Small features may use only:

```text
lib/feature/<feature_name>/
  controller/
  screen/
```

### 1.2 GetX Rule

Use GetX as the standard for:

- named navigation
- dependency injection
- feature controllers
- transient state for mock flows
- bottom sheets, dialogs, snackbars

Do not leave buttons without behavior.
If a backend action does not exist yet, use one of these static actions:

- `Get.toNamed(...)`
- `Get.bottomSheet(...)`
- `Get.dialog(...)`
- toggle local `RxBool`, `RxInt`, `RxList`, `RxString`
- show `Get.snackbar(...)`
- update mock model in repository
- show confirmation state inside the same screen

### 1.3 Static-Complete Rule

Every screen must support:

- loading state
- empty state
- success state
- error or blocked state where appropriate

Every form must support:

- text validation
- primary button action
- secondary button action
- back navigation
- submit loading
- submit success feedback

## 2. Screen Contract

Each screen should define:

- screen purpose
- entry route
- controller owner
- model inputs
- static UI states
- button actions

Minimum screen scaffold contract:

1. App bar title and back behavior
2. Main content body
3. Primary CTA
4. Secondary CTA or contextual action
5. Empty and error view when relevant
6. Mock repository data binding

## 3. Controller Contract

Each feature controller should own:

- screen state
- selected tab/index/filter
- form field values or text controllers
- validation flags
- loading/submitting flags
- local mock mutations
- route transitions

Prefer this shape:

```dart
class ExampleController extends GetxController {
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final items = <ExampleModel>[].obs;
  final selectedTab = 0.obs;

  final ExampleRepository repository;

  ExampleController({ExampleRepository? repository})
      : repository = repository ?? ExampleRepository();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {}
  void onPrimaryAction() {}
  void onSecondaryAction() {}
}
```

## 4. Repository Contract

Each repository should be mock-first and backend-ready.

Repository responsibilities:

- return mock lists
- return mock detail objects
- simulate latency
- update in-memory state
- support create/edit/delete/toggle flows
- isolate data from UI

Good repository methods:

- `fetchFeed()`
- `fetchStories()`
- `loginWithEmail()`
- `sendOtp()`
- `verifyOtp()`
- `createPost()`
- `toggleBookmark()`
- `followUser()`
- `muteUser()`
- `fetchSettingsSections()`

## 5. Route Standard

All flows should use named GetX routes.

Route naming rules:

- feature root: `/<feature>`
- nested flow: `/<feature>/<sub-flow>`
- detail: `/<feature>/detail`
- create: `/<feature>/create`
- edit: `/<feature>/edit`
- settings child: `/settings/<section>`

Example:

```dart
static const login = '/auth/login';
static const signupStepOne = '/auth/signup/step-1';
static const createStory = '/stories/create';
static const eventDetail = '/events/detail';
static const marketplaceCreate = '/marketplace/create';
```

## 6. Global App Flows

### 6.1 Splash Flow

Feature:
- `lib/feature/splash`

Screens:
- `SplashScreen`

Controller:
- decide first route based on mock app state

Static actions:
- logo tap: show version snackbar
- retry button on error: reload bootstrap
- continue button: go to onboarding or login

Suggested route:
- `/`

### 6.2 Onboarding Flow

Feature:
- `lib/feature/onboarding`

Screens:
- `OnboardingScreen`

Required behavior:
- 3 onboarding pages
- skip
- next
- previous when applicable
- continue to login/signup

Buttons:
- `Skip` -> `RouteNames.login`
- `Next` -> next page
- `Get Started` -> auth choice screen or login

Suggested models:
- `OnboardingSlideModel`

### 6.3 Auth Flow

Feature:
- `lib/feature/auth`

Sub-features:
- `login`
- `signup`
- `forgot_password`
- `reset_password`

#### Login

Screens:
- login option screen
- email or phone login screen

Buttons:
- `Continue with Google` -> mock Google success bottom sheet, then shell
- `Continue with Email` -> email login form
- `Continue with Phone` -> phone login form
- `Forgot Password` -> forgot password email screen
- `Sign Up` -> signup step 1

Suggested routes:
- `/auth/login`
- `/auth/login/email`
- `/auth/login/phone`

Models:
- `LoginModel`

Controller responsibilities:
- mode switch: email or phone
- validation
- mock login
- remember me
- role preview if needed

#### Signup

Required 3 screens:

1. account credentials
2. user basic data
3. profile type and image data

Buttons:
- `Next` -> validate and move next
- `Back` -> previous step
- `Select Profile Type` -> bottom sheet
- `Upload Image` -> mock picker action
- `Create Account` -> success dialog then onboarding completion or shell

Suggested routes:
- `/auth/signup`
- `/auth/signup/step-1`
- `/auth/signup/step-2`
- `/auth/signup/step-3`

Suggested models:
- `SignupModel`
- `ProfileTypeModel`

#### Forgot Password

Required screens:

1. enter email
2. enter otp
3. new password

Buttons:
- `Send Code` -> snackbar + move to otp
- `Resend Code` -> countdown reset
- `Verify Code` -> move to reset password
- `Save Password` -> success dialog + login route

Suggested routes:
- `/auth/forgot-password`
- `/auth/otp-verification`
- `/auth/reset-password`

## 7. Main Shell and Drawer

Feature:
- `lib/feature/home_feed`

Tabs:
- Home
- Reels
- Create
- Chat
- Profile

Drawer sections:
- create and manage
- discover
- professional
- settings and support

Static behavior:
- tapping tab switches page
- tapping create opens create post hub or create tab
- drawer item always navigates to a valid screen
- logout opens confirm dialog

Required controller:
- `MainShellController extends GetxController`

Required mock state:
- selected tab index
- current user
- role-aware drawer items

## 8. Home Flow

Feature:
- `lib/feature/home_feed`

Screens:
- feed screen
- create post screen

Feed content blocks:
- story ring row
- composer
- suggested users
- text posts
- image posts
- reels preview cards
- trending tags section

Feed buttons:
- story avatar -> story viewer
- create post input -> create post flow
- like -> toggle liked state
- comment -> post detail
- share -> share sheet
- bookmark -> toggle saved
- menu -> bottom sheet with hide, report, unfollow, copy link
- follow button -> toggle follow state

Required models:
- `FeedPostModel`
- `FeedTabModel`

Required repository methods:
- `fetchHomeFeed()`
- `toggleLike(postId)`
- `toggleBookmark(postId)`
- `hidePost(postId)`

## 9. Story Flow

Feature:
- `lib/feature/stories`

Screens:
- story list inside home
- create story
- story viewer

Create story types:
- text story
- image story

Viewer behaviors:
- progress bar
- next/previous
- reaction picker
- quick comment field
- viewer list static for own story

Buttons:
- `Add Story` -> create story
- `Text` -> open text story editor
- `Photo` -> open image picker placeholder
- `Post Story` -> save mock story and return
- `React` -> add local reaction
- `Send Comment` -> append mock comment
- long press story -> pause

Suggested routes:
- `/stories/create`
- `/stories/view`

Suggested models:
- `StoryDraftModel`
- `StoryReactionModel`
- `StoryCommentModel`

## 10. Post Creation Flow

Feature:
- create under `home_feed` or extract `create_post`

Required create variants:
- text post with filter
- image post with filter and songs
- photo or video post
- camera capture
- tag people
- multiple people search and add
- location
- feelings
- draft
- schedule

Required screens:
- create hub
- text post editor
- media post editor
- tag people selector
- location selector
- feelings selector
- draft review
- schedule picker
- upload manager

Buttons:
- `Text Post` -> text editor
- `Photo/Video Post` -> media editor
- `Open Camera` -> camera mock preview
- `Add Music` -> song bottom sheet
- `Add Filter` -> filter carousel
- `Tag People` -> search people selector
- `Add Location` -> location selector
- `Feeling` -> feeling bottom sheet
- `Save Draft` -> store locally
- `Schedule` -> schedule sheet
- `Publish` -> success snackbar and back to home

Suggested routes:
- `/create`
- `/create/text`
- `/create/media`
- `/create/tag-people`
- `/create/location`
- `/create/feeling`
- `/drafts`
- `/scheduling`
- `/upload-manager`

Suggested models:
- `PostDraftModel`
- `PostAudienceModel`
- `TaggedUserModel`
- `PostLocationModel`
- `FeelingModel`
- `SongModel`

## 11. Profile Flow

Primary feature:
- `lib/feature/user_profile`

Additional role features:
- `business_profile`
- `seller_profile`
- `recruiter_profile`

Required profile modules:
- profile overview
- posts tab
- followers/following
- edit profile
- professional tools entry
- monetization
- subscriptions

Buttons:
- `Edit Profile` -> edit profile screen
- `Follow` -> toggle follow state
- `Message` -> open chat
- `Invite Friend` -> invite flow
- `Wallet Add Money` -> wallet add money
- `Subscription` -> subscriptions
- `View Followers` -> follower list
- `View Following` -> following list
- profile picture tap -> media viewer
- three dot -> block, report, share profile, copy link

Suggested routes:
- `/user-profile`
- `/user-profile/edit`
- `/user-profile/followers`
- `/user-profile/following`
- `/business-profile`
- `/seller-profile`
- `/recruiter-profile`

Suggested models:
- `UserProfileModel`
- `ProfileStatsModel`
- `FollowerModel`
- `ProfileLinkModel`

## 12. Inbox and Chat Flow

Feature:
- `lib/feature/chat`
- `lib/feature/group_chat`

Required screens:
- inbox
- chat detail
- chat settings
- group chat

Required interactions:
- 3-dot menu in inbox
- chat actions
- long press on message
- emoji reaction
- reply
- copy
- delete for me
- mute conversation

Inbox buttons:
- search -> filter local chats
- archive -> move item to archive state
- unread -> toggle unread badge
- 3-dot -> menu sheet

Chat buttons:
- send -> append local message
- attachment -> bottom sheet
- camera -> open capture placeholder
- mic -> hold to record mock state
- call -> call screen or snackbar
- video call -> video call snackbar
- long press message -> reaction and action sheet

Suggested routes:
- `/chat`
- `/chat/detail`
- `/chat/settings`
- `/group-chat`
- `/calls`

Suggested models:
- `ChatThreadModel`
- `MessageModel`
- `MessageActionModel`
- `ChatAttachmentModel`

## 13. Reels Flow

Feature:
- `lib/feature/reels_short_video`

Required interactions:
- vertical feed
- follow person
- comment
- like on double tap
- many reactions on long press
- share
- save

Buttons:
- single tap video -> pause or play
- double tap -> like animation
- long press like -> reaction picker
- comment -> open comments sheet
- follow -> toggle follow state
- share -> share bottom sheet
- audio title tap -> song detail placeholder

Suggested routes:
- `/reels`
- `/reels/comments`

Suggested models:
- `ReelModel`
- `ReelCommentModel`
- `ReelReactionModel`

## 14. Drawer and Utility Flows

Feature groups:
- pages
- jobs networking
- marketplace
- bookmarks
- saved collections
- creator tools
- wallet payments
- subscriptions
- premium membership
- events
- communities
- invite referral
- support help

Every drawer destination must open a working static screen with:

- list content
- item detail or modal
- create CTA if applicable
- empty state

## 15. Pages Flow

Feature:
- `lib/feature/pages`

Required modules:
- my pages
- followed pages
- page posts

Buttons:
- `Create Page` -> page create form
- `Follow Page` -> toggle follow
- `View Posts` -> page feed
- `Invite` -> invite members sheet

Suggested routes:
- `/pages`
- `/pages/my`
- `/pages/followed`
- `/pages/detail`
- `/pages/create`

## 16. Jobs Flow

Feature:
- `lib/feature/jobs_networking`

Required modules:
- add job post
- view job post
- search job post
- apply job post

Buttons:
- `Post Job` -> create job form
- `Search` -> filter result list
- `Apply` -> apply bottom sheet
- `Save Job` -> bookmark state
- `Share Job` -> share sheet

Suggested routes:
- `/jobs`
- `/jobs/create`
- `/jobs/detail`
- `/jobs/search`
- `/jobs/apply`

Suggested models:
- `JobModel`
- `JobApplicationModel`
- `JobFilterModel`

## 17. Marketplace Flow

Feature:
- `lib/feature/marketplace`

Required modules:
- add sell post
- view product
- search product
- buy product

Buttons:
- `Sell Item` -> create listing
- `Search Product` -> search screen
- `Filter` -> filter sheet
- `Buy Now` -> purchase summary dialog
- `Chat Seller` -> seller chat
- `Save` -> bookmark listing

Suggested routes:
- `/marketplace`
- `/marketplace/create`
- `/marketplace/detail`
- `/marketplace/search`
- `/marketplace/checkout`

Suggested models:
- `MarketplaceItemModel`
- `MarketplaceFilterModel`
- `PurchaseSummaryModel`

## 18. Drafts, Scheduling, Upload Manager

Feature:
- `lib/feature/drafts_and_scheduling`
- `lib/feature/upload_manager`

Required screens:
- all drafts
- schedule queue
- upload manager
- upload detail

Buttons:
- `Edit Draft` -> open create editor with prefilled data
- `Delete Draft` -> confirmation dialog
- `Reschedule` -> date picker
- `Retry Upload` -> set uploading then success
- `Cancel Upload` -> set canceled state
- `View Upload` -> upload detail screen

Suggested models:
- `DraftItemModel`
- `ScheduledPostModel`
- `UploadTaskModel`

## 19. Bookmark and Saved Posts

Features:
- `bookmarks`
- `saved_collections`

Required modules:
- all saved posts
- collection view
- view saved post detail

Buttons:
- `Save` -> add or remove bookmark
- `Move to Collection` -> collection picker
- `Open Post` -> post detail
- `Remove` -> unsave

Suggested routes:
- `/bookmarks`
- `/saved-collections`
- `/saved-collections/detail`

## 20. Professional, Monetization, Wallet, Subscription, Premium

Features:
- `creator_tools`
- `wallet_payments`
- `subscriptions`
- `premium_membership`

Required modules:
- creator dashboard
- creator and professional tools
- monetization and payment
- wallet and payment
- subscription management
- premium membership plan list

Buttons:
- `Add Money` -> amount sheet + success state
- `Withdraw` -> mock withdrawal request
- `View Earnings` -> earnings summary
- `Create Subscription Plan` -> plan form
- `Upgrade Premium` -> mock checkout
- `View Insights` -> chart detail placeholder

Suggested routes:
- `/creator-dashboard`
- `/creator-tools`
- `/wallet-payments`
- `/wallet-payments/add-money`
- `/subscriptions`
- `/subscriptions/create`
- `/premium`

Suggested models:
- `WalletTransactionModel`
- `WalletBalanceModel`
- `SubscriptionPlanModel`
- `CreatorMetricModel`
- `PremiumPlanModel`

## 21. Event Flow

Feature:
- `lib/feature/events`

Required modules:
- view event
- search event
- filter event
- add event

Buttons:
- `Create Event` -> event create form
- `Join` -> toggle joined
- `Interested` -> toggle interested
- `Search` -> search result list
- `Filter` -> event filter bottom sheet
- `Share` -> share sheet

Suggested routes:
- `/events`
- `/events/create`
- `/events/detail`
- `/events/search`

Suggested models:
- `EventModel`
- `EventFilterModel`
- `EventAttendeeModel`

## 22. Hide, Block, Report

These actions should be available across posts, profiles, chats, reels, and pages.

Required static actions:

- `Hide Post` -> remove from current feed and show undo snackbar
- `Remove Hide` -> restore hidden post from hidden list
- `Block` -> move user to blocked list
- `Mute` -> set muted status
- `Report` -> open category sheet and success confirmation

Suggested shared model:
- `ModerationActionModel`

Suggested shared repository:
- `SafetyRepository`

## 23. Help and Support

Feature:
- `lib/feature/support_help`

Required modules:
- faq
- support chat
- support mail
- report issue

Buttons:
- `Open FAQ` -> faq detail
- `Start Chat` -> support chat thread
- `Send Mail` -> mock mail compose success
- `Submit Issue` -> confirmation screen

Suggested routes:
- `/support-help`
- `/support-help/faq`
- `/support-help/chat`
- `/support-help/mail`

## 24. Communities and Discovery

Features:
- `communities`
- `groups`
- `search_discovery`
- `hashtags`
- `trending`
- `explore_recommendation`

Required modules:
- communities list
- group list and detail
- joined groups
- discovery search
- hashtag feed
- trending feed

Buttons:
- `Join Community` -> toggle joined
- `Create Group` -> create group form
- `Search` -> filter mock content
- `Open Hashtag` -> hashtag detail
- `Follow Topic` -> toggle follow

Suggested routes:
- `/communities`
- `/groups`
- `/groups/detail`
- `/search-discovery`
- `/hashtags`
- `/trending`
- `/explore-recommendation`

## 25. Connected App, Deep Link, Invite, About, Update, Legal, Maintenance, Logout

Features:
- `connected_apps`
- `deep_link_handler`
- `invite_referral`
- `about_settings`
- `app_update_flow`
- `legal_compliance`
- `maintenance_mode`

Buttons:
- `Connect App` -> local connected state
- `Disconnect` -> confirmation dialog
- `Test Deep Link` -> navigate to selected route preview
- `Copy Invite Code` -> snackbar
- `Share Invite` -> share sheet
- `Check for Updates` -> update available state
- `View Terms` -> legal detail
- `Preview Maintenance` -> maintenance screen
- `Logout` -> confirmation then auth route

## 26. Settings Flow

Feature:
- `lib/feature/settings`

Settings root must be one of the strongest modules in the app.

Required sections:

1. Account
2. Password and security
3. Device and sessions
4. Verification request
5. Account switching
6. Archive center
7. Privacy
8. Advance privacy control
9. Block and mute user
10. Safety and privacy
11. Report center
12. Help and safety
13. Notification
14. Notification categories
15. Msg and call
16. Activity session
17. Feed and content preference
18. Explore recommendations
19. Theme
20. Language and accessibility
21. Language and region
22. Accessibility
23. Localization support
24. Accessibility support
25. Data and privacy center
26. Offline sync
27. Connected apps
28. Creator and professional tools
29. Monetization & payment
30. Wallet and payment
31. Subscription
32. Premium membership
33. Communities and group
34. Support and help
35. About
36. App update flow
37. Legal and compliance
38. Maintenance mode preview
39. Logout

### 26.1 Account Settings

Must include:

- name
- username
- bio
- pronouns
- website
- email
- phone
- profile type
- profile image

Buttons:
- `Edit` -> open editable mode
- `Save` -> persist mock profile
- `Change Username` -> validation + success snackbar
- `Switch Account Type` -> modal selector
- `Deactivate Account` -> confirm dialog
- `Delete Account` -> danger confirm dialog

### 26.2 Password and Security

Must include:

- change password
- two factor auth toggle
- biometric lock toggle
- login alerts toggle
- trusted device list

Buttons:
- `Change Password` -> change password form
- `Enable 2FA` -> toggle and show success
- `Enable Biometrics` -> toggle
- `Run Security Checkup` -> progress then result screen

### 26.3 Device and Sessions

Must include:

- current device
- recent login sessions
- revoke session

Buttons:
- `Log Out This Device` -> confirm
- `Log Out Other Devices` -> confirm
- `View Device` -> device detail bottom sheet

### 26.4 Privacy and Safety

Must include:

- profile visibility
- last seen
- read receipts
- tag permissions
- mention permissions
- comment permissions
- repost permissions
- hidden words
- sensitive content
- discoverability

Buttons:
- each toggle updates local repository immediately
- `Manage Hidden Words` -> editor screen
- `Reset Privacy Defaults` -> confirm dialog

### 26.5 Notifications, Messages, Calls

Must include:

- push toggles
- email toggles
- in-app toggles
- category toggles
- chat preview toggle
- media auto-download
- call permissions

Buttons:
- toggle updates instantly
- `Preview Notification` -> show sample snackbar
- `Reset Categories` -> restore defaults

### 26.6 Feed, Theme, Language, Accessibility, Data

Must include:

- theme selector
- autoplay toggle
- data saver
- recommendation reset
- language picker
- region picker
- text scale
- reduced motion
- captions
- export data
- clear cache
- storage usage
- offline sync queue

Buttons:
- `Theme` -> bottom sheet
- `Reset Recommendations` -> confirm
- `Export Data` -> fake export progress and success
- `Clear Cache` -> success snackbar
- `Retry Sync` -> replay pending actions

## 27. Feature-to-Route Planning Map

Use the current route set where already available.
Add missing routes using this naming plan:

```text
/auth/login/email
/auth/login/phone
/auth/signup/step-1
/auth/signup/step-2
/auth/signup/step-3
/stories/create
/stories/view
/create
/create/text
/create/media
/create/tag-people
/create/location
/create/feeling
/user-profile/edit
/user-profile/followers
/user-profile/following
/chat/detail
/chat/settings
/reels
/pages/create
/pages/detail
/jobs/create
/jobs/detail
/jobs/apply
/marketplace/create
/marketplace/detail
/marketplace/checkout
/events/create
/events/detail
/support-help/faq
/support-help/chat
/support-help/mail
```

## 28. Shared Static Action Patterns

When backend is not ready, use these default outcomes:

- create action -> add new item to top of list
- edit action -> update local item and show snackbar
- delete action -> remove item and show undo snackbar
- like/follow/save -> optimistic local toggle
- report/block/hide -> remove current item and log to repository
- payment action -> fake success after delay
- upload action -> `queued -> uploading -> completed`
- otp flow -> accept `123456`
- login flow -> accept any valid-looking input

## 29. Required Mock Data Coverage

Mock data should exist for:

- users
- stories
- posts
- comments
- reels
- chats
- pages
- jobs
- marketplace products
- events
- wallets
- subscriptions
- settings values
- notifications
- reports
- blocked users
- drafts
- uploads

## 30. Recommended Implementation Order

1. standardize routes and route names
2. standardize GetX controllers for auth, shell, home, settings
3. complete static button behavior on every existing screen
4. complete missing auth and onboarding screens
5. complete create post, stories, reels, chat interactions
6. complete profile, marketplace, jobs, events
7. complete settings sub-screens and local persistence
8. complete support, legal, maintenance, invite, connected apps

## 31. Definition of Done

A feature is done only when:

- screen exists
- route exists
- controller exists
- mock data exists
- button actions exist
- loading and empty states exist
- navigation is connected
- no dead UI element remains

## 32. Final Engineering Direction

Build every requested feature as a static-complete mock product first.
Do not leave placeholder buttons.
Do not block progress waiting for APIs.
Use GetX consistently for routes, controllers, dialogs, snackbars, and local feature state.
Follow the existing feature-first structure.
Keep each feature implementation ready for future repository replacement with real backend services.
