# Architecture Guide

Target structure for feature work:

```text
lib/
  core/
    architecture/
    bloc/
  features/
    feature_name/
      data/
        datasources/
        repositories/
      domain/
        repositories/
        usecases/
      presentation/
        cubit/
        screens/
        widgets/
```

Rules:

- Use `Cubit` or `Bloc` for presentation state.
- Keep screens and widgets dumb where possible.
- Put data access in repositories and data sources.
- Keep files focused and under 500 lines.
- Keep `lib/feature/...` as compatibility wrappers during migration.
