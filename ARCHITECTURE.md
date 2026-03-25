# OptiZenqor Social Architecture

This project follows a feature-first Flutter architecture with a small shared `core` layer and a route-only `route` layer.

## Top Level

```text
lib/
  app.dart
  main.dart
  core/
  feature/
  route/
```

## Core

`core` contains only shared app-wide code.

```text
lib/core/
  constant/
    app_colors.dart
    app_dimensions.dart
    app_strings.dart
    storage_keys.dart

  common_widget/
    common_widgets.dart
    ...shared widgets

  data/
    api/
      api_end_points.dart
    service/
      api_client_service.dart
      local_storage_service.dart
      ...other shared services
    service_model/
      service_response_model.dart
      ...other service models
    shared_preference/
      app_shared_preferences.dart
```

### Core Rules

- `constant/` is for shared constant values like text, color, spacing, and storage keys.
- `common_widget/` is for reusable widgets used across multiple features.
- `data/api/` stores API endpoint definitions.
- `data/service/` stores shared services.
- `data/service_model/` stores shared service response/request models.
- `data/shared_preference/` stores typed shared-preference access.
- Feature-specific widgets, services, or models should stay inside the feature unless they are reused widely.

## Feature

`feature` contains only feature modules.

Each feature owns its own files and should use only the folders it actually needs.

```text
lib/feature/
  home_feed/
    common/
    controller/
    model/
    repository/
    screen/
```

### Feature Rules

- Every product area lives inside `lib/feature/`.
- A feature can contain:
  - `common/`
  - `controller/`
  - `model/`
  - `repository/`
  - `screen/`
- Do not add unnecessary layers for very small features.
- Keep feature logic inside the feature folder.
- Shared code should move to `core` only when it is truly reused across multiple features.

### Example Feature Shapes

Small feature:

```text
lib/feature/splash/
  controller/
  screen/
```

Medium feature:

```text
lib/feature/subscriptions/
  controller/
  model/
  repository/
  screen/
```

Larger feature:

```text
lib/feature/home_feed/
  common/
  controller/
  model/
  repository/
  screen/
```

## Route

`route` contains route-only files.

```text
lib/route/
  app_pages.dart
  app_route.dart
  app_routes.dart
  route_generator.dart
  route_names.dart
  routes.dart
```

### Route Rules

- `route_names.dart` stores route path constants.
- `app_pages.dart` stores route page builders.
- `app_route.dart` exposes route aliases and shared access.
- `app_routes.dart` can group route sets like public/private routes.
- `route_generator.dart` handles material route generation fallback.
- `routes.dart` is the single barrel export for route imports.
- No business logic should live inside `route/`.

## Current Direction

The target architecture for ongoing refactoring is:

1. Keep `core`, `feature`, and `route` as the only main layers in `lib`.
2. Move shared constants toward `core/constant`.
3. Move shared reusable widgets toward `core/common_widget`.
4. Move shared persistence and services toward `core/data`.
5. Keep all product-specific behavior inside `feature`.
6. Keep route definitions and route helpers inside `route` only.

## Migration Guidance

- Do not rewrite the app from scratch.
- Migrate gradually feature by feature.
- Prefer compatibility exports during transition if needed.
- Preserve existing route coverage and working screens.
- Standardize new work on this structure first, then backfill older modules.
