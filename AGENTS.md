# AGENTS.md — AI Agent Instructions for Versatile

## Session Startup

1. **Read MEMORY.md first** — always read `MEMORY.md` at the start of every session to understand the project without re-scanning the codebase.
2. **Activate relevant skills** — load skills that match the current task (flutter-*, ios-*, etc.) using the Skill tool. Scan the prompt for technology keywords and activate matching skills before writing code.

## Pending tasks lifecycle

The memory file `project_pending_tasks.md` (indexed in `MEMORY.md`) tracks postponed work. When the user confirms that a pending task is done ("ya quedó listo", "ya está", etc.), **delete that entry from `project_pending_tasks.md`** immediately. If the file ends up empty, remove the file itself and its line from `MEMORY.md`. Do not leave stale pendings — they must reflect only work that is still outstanding.

## DOCUMENTACION folder

The `DOCUMENTACION/` folder contains long-form feature docs (architecture, database, active workout, programs, etc.). **Do NOT read these files unless the user explicitly asks** ("revisa la documentación", "lee DOCUMENTACION/X", etc.). For day-to-day tasks, rely on `MEMORY.md` and reading the actual code — the docs are reference material for production-ready documentation work, not session context. Loading them eagerly wastes the context window.

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

## CodeGraph

CodeGraph builds a semantic knowledge graph of the codebase for faster exploration.

### If `.codegraph/` exists

**Never call `codegraph_explore` or `codegraph_context` directly in the main session.** These return large amounts of source code. ALWAYS spawn an Explore agent for exploration questions (e.g., "how does X work?", "explain the Y system", "where is Z implemented?").

When spawning Explore agents, include:

> This project has CodeGraph initialized (.codegraph/ exists). Use `codegraph_explore` as your PRIMARY tool — it returns full source code sections from all relevant files in one call.
>
> **Rules:**
> 1. Follow the explore call budget in the `codegraph_explore` tool description — it scales automatically based on project size.
> 2. Do NOT re-read files that codegraph_explore already returned source code for. The source sections are complete and authoritative.
> 3. Only fall back to grep/glob/read for files listed under "Additional relevant files" if you need more detail, or if codegraph returned no results.

The main session may only use these lightweight tools directly:

| Tool | Use For |
|------|---------|
| `codegraph_search` | Find symbols by name |
| `codegraph_callers` / `codegraph_callees` | Trace call flow |
| `codegraph_impact` | Check what's affected before editing |
| `codegraph_node` | Get a single symbol's details |

### If `.codegraph/` does NOT exist

At session start, ask the user if they'd like to run `codegraph init -i` to initialize it.
