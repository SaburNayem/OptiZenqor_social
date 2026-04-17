# OptiZenqor Socity Project Structure Documentation

This document defines the required folder flow for the Flutter codebase.
The goal is a clean, scalable, non-garbage architecture with strict separation of responsibility.

State management standard: `BLoC`

## 1. Main Architecture Flow

The app must follow this top-level structure inside `lib/`:

```text
lib/
  app.dart
  main.dart
  binding/
  app_route/
  core/
  feature/
```

## 2. Responsibility of Each Top-Level Folder

### `main.dart`

- Application entry point
- Calls `runApp(...)`
- Initializes the minimum required bootstrap
- Keeps no business logic

### `app.dart`

- Root app widget
- Holds `MaterialApp` or `MaterialApp.router`
- Applies theme, route setup, localization, and app-wide wrappers
- Stays separate from `main.dart`

### `binding/`

- Global dependency injection setup
- Registers shared services, repositories, BLoCs, storage, and socket dependencies
- Can be split like:

```text
lib/binding/
  app_binding.dart
  core_binding.dart
  feature_binding.dart
```

### `app_route/`

- All route names, route builders, route guards, and navigation mapping
- No business logic here
- Suggested structure:

```text
lib/app_route/
  app_route.dart
  route_names.dart
  route_generator.dart
  route_observer.dart
```

### `core/`

- All reusable app-wide code lives here
- If something is shared across multiple features, it belongs in `core`
- If something is only for one feature, it must stay inside that feature

### `feature/`

- Every product module lives here
- Each screen must have its own dedicated folder
- Never keep two different screens inside the same screen folder

## 3. Required Folder Structure

```text
lib/
  app.dart
  main.dart

  binding/
    app_binding.dart
    core_binding.dart
    feature_binding.dart

  app_route/
    app_route.dart
    route_names.dart
    route_generator.dart
    route_observer.dart

  core/
    constants/
    assets/
    common_widget/
    text_style/
    utils/
    functions/
    webrtc/
    data/
    service/
    socket/

  feature/
    auth/
    home/
    profile/
    settings/
    chat/
    reels/
    ...
```

## 4. Core Folder Flow

`core/` should be the strongest shared layer in the project.

Suggested structure:

```text
lib/core/
  constants/
    app_colors.dart
    app_strings.dart
    app_dimensions.dart
    app_keys.dart
    app_assets.dart

  assets/
    asset_paths.dart

  common_widget/
    app_button.dart
    app_text_field.dart
    app_loader.dart
    common_app_bar.dart
    common_empty_view.dart
    common_error_view.dart

  text_style/
    app_text_style.dart
    app_theme_text.dart

  utils/
    validators.dart
    debouncer.dart
    logger.dart
    extensions.dart

  functions/
    date_functions.dart
    media_functions.dart
    permission_functions.dart

  webrtc/
    webrtc_service.dart
    webrtc_models.dart
    call_helpers.dart

  data/
    model/
    shared_pref/

  service/
    http_service.dart
    api_service.dart
    connectivity_service.dart
    local_storage_service.dart

  socket/
    socket_service.dart
    socket_event.dart
    socket_property.dart
    socket_handler.dart
```

## 5. Core Rules

- `constants/` stores fixed app constants only
- `assets/` stores asset path management
- `common_widget/` stores reusable widgets used across features
- `text_style/` stores global text styles and typography helpers
- `functions/` stores common helper functions
- `webrtc/` stores all WebRTC-related shared implementation
- `data/model/` stores shared models used globally
- `data/shared_pref/` stores all shared preference keys and helpers
- `service/` stores app-wide services
- `service/http_service.dart` is the base network layer
- `socket/` stores all socket setup, socket events, and socket properties
- Never move feature-specific UI into `core`
- Never create duplicate helper files with similar responsibility

## 6. Feature Folder Flow

Each feature will contain sub-features or screen folders.
Every screen should have a dedicated folder.

Example:

```text
lib/feature/
  auth/
    login/
    signup/
    forgot_password/

  home/
    home_feed/
    create_post/
    notification_list/

  profile/
    profile_view/
    edit_profile/
    follower_list/
```

## 7. Screen-Level Folder Rule

Every screen folder must have `3` or `4` subfolders depending on need.

### If the screen does not need reusable widgets:

```text
lib/feature/auth/login/
  bloc/
  model/
  controller/
  screen/
```

### If the screen needs its own private widgets:

```text
lib/feature/auth/login/
  bloc/
  model/
  controller/
  screen/
  widget/
```

## 8. Screen Folder Responsibilities

### `bloc/`

- All BLoC files for that screen
- Example:

```text
bloc/
  login_bloc.dart
  login_event.dart
  login_state.dart
```

### `model/`

- Screen-specific request, response, UI, and entity models
- Models that are only used by this screen stay here

### `controller/`

- Only for screen flow helpers, form controllers, text editing controllers, tab controllers, or local coordinators if needed
- Keep business state inside BLoC, not inside controller
- If a controller is not needed, do not create one

### `screen/`

- Main screen UI file
- One screen folder must contain one main screen only
- Never put two unrelated screens inside the same folder

### `widget/`

- Private widgets used only by that screen
- If widgets are reused in many features, move them to `core/common_widget/`

## 9. Best Practice for Feature Structure

Recommended example:

```text
lib/feature/auth/login/
  bloc/
    login_bloc.dart
    login_event.dart
    login_state.dart
  model/
    login_request_model.dart
    login_response_model.dart
  controller/
    login_form_controller.dart
  screen/
    login_screen.dart
  widget/
    login_header.dart
    login_form.dart
    login_footer.dart
```

Another example:

```text
lib/feature/profile/edit_profile/
  bloc/
    edit_profile_bloc.dart
    edit_profile_event.dart
    edit_profile_state.dart
  model/
    edit_profile_model.dart
  controller/
    edit_profile_form_controller.dart
  screen/
    edit_profile_screen.dart
  widget/
    profile_image_picker.dart
    profile_form_section.dart
```

## 10. BLoC State Management Standard

The project must use `flutter_bloc`.

Rules:

- Use BLoC for screen state and business logic
- Use events for all user actions
- Use states for all UI updates
- Never place main business logic directly in screen widgets
- Never use random mutable variables across screens
- Avoid mixed state management patterns in the same feature

Recommended BLoC file set:

```text
feature_name_bloc.dart
feature_name_event.dart
feature_name_state.dart
```

Recommended flow:

1. User action from screen
2. Event sent to BLoC
3. BLoC processes logic
4. Service or repository is called
5. New state is emitted
6. UI rebuilds from state

## 11. Clean Code Rules

- Never create garbage codebase
- Never create duplicate widgets with different names but same UI
- Never create duplicate models without clear reason
- Never keep unused files
- Never keep commented dead code
- Never put API code directly inside screen files
- Never put socket code directly inside UI files
- Never mix shared and feature-specific files carelessly
- Always keep naming predictable and consistent
- Always separate reusable code from screen-specific code

## 12. Naming Rules

- Folder names: `snake_case`
- File names: `snake_case`
- Class names: `PascalCase`
- BLoC names: `LoginBloc`, `ProfileBloc`
- Event names: `LoginSubmitted`, `ProfileLoaded`
- State names: `LoginInitial`, `LoginLoading`, `LoginSuccess`, `LoginFailure`

## 13. Final Recommended Example

```text
lib/
  main.dart
  app.dart

  binding/
    app_binding.dart
    core_binding.dart
    feature_binding.dart

  app_route/
    app_route.dart
    route_names.dart
    route_generator.dart
    route_observer.dart

  core/
    constants/
      app_assets.dart
      app_colors.dart
      app_dimensions.dart
      app_strings.dart
    assets/
      asset_paths.dart
    common_widget/
      app_button.dart
      app_loader.dart
      app_text_field.dart
    text_style/
      app_text_style.dart
    utils/
      validators.dart
      logger.dart
    functions/
      app_functions.dart
    webrtc/
      webrtc_service.dart
    data/
      model/
        common_api_response_model.dart
      shared_pref/
        app_shared_pref.dart
    service/
      http_service.dart
      api_service.dart
      local_storage_service.dart
    socket/
      socket_service.dart
      socket_property.dart

  feature/
    auth/
      login/
        bloc/
          login_bloc.dart
          login_event.dart
          login_state.dart
        model/
          login_model.dart
        controller/
          login_form_controller.dart
        screen/
          login_screen.dart
        widget/
          login_form_section.dart
      signup/
        bloc/
        model/
        controller/
        screen/
        widget/

    home/
      home_feed/
        bloc/
        model/
        controller/
        screen/
        widget/

    profile/
      profile_view/
        bloc/
        model/
        controller/
        screen/
        widget/
```

## 14. Final Decision

This project should move forward with:

- separate `main.dart` and `app.dart`
- `binding/` for dependency injection
- `app_route/` for all navigation setup
- `core/` for all shared code
- `feature/` for all feature modules
- one screen per dedicated folder
- `bloc/` as the primary state management layer
- clean, reusable, non-duplicated code only

This is the required standard for all new development and future refactoring.
