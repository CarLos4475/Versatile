# AGENTS.md — AI Agent Instructions for Versatile

## Session Startup

1. **Read MEMORY.md first** — always read `MEMORY.md` at the start of every session to understand the project without re-scanning the codebase.
2. **Activate relevant skills** — load skills that match the current task (flutter-*, ios-*, etc.) using the Skill tool. Scan the prompt for technology keywords and activate matching skills before writing code.

## Architecture

- **State management**: Riverpod (`flutter_riverpod`). Providers in `core/providers/`, view models per feature in `features/*/view_models/`.
- **Data layer**: SQLite via `DatabaseHelper` singleton. Repositories in `data/repositories/`. Entities in `domain/entities/`.
- **Feature-first**: Each feature has `screens/`, `view_models/`, `widgets/`.
- **L10n**: `AppLocalizations` via gen-l10n. Strings added to `app_localizations_en.dart` and `app_localizations_es.dart`, abstract getters in `app_localizations.dart`.

## Conventions

- Use `context.colors` (extension from `AppColors`) for all colors — never hardcode them.
- Wrap interactive elements in `PressableScale` from `shared/widgets/motion.dart`.
- Use `GlassContainer` / `GlassButton` for glassmorphism surfaces.
- Access theme via `context.colors.accent`, `context.colors.bgApp`, etc.
- Confirm destructive actions with `AlertDialog` before executing.
- Follow existing widget naming: `_PrivateWidget` prefix for file-private widgets.
- Never add comments unless directly instructed.

## Skills

Available skills cover Flutter patterns (layout, routing, serialization, testing) and iOS frameworks. Activate skills when:
- Building UI → `flutter-add-widget-preview`, `flutter-build-responsive-layout`
- Writing tests → `flutter-add-widget-test`, `flutter-add-integration-test`
- Architecture → `flutter-apply-architecture-best-practices`
- Fixing layout → `flutter-fix-layout-issues`
- HTTP/API → `flutter-use-http-package`
- Routing → `flutter-setup-declarative-routing`
- Serialization → `flutter-implement-json-serialization`
- iOS native → any matching iOS skill
