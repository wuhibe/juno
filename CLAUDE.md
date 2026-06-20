# Juno — Mobile Database Client

A mobile-first (iOS + Android) database client built with Flutter. V1 targets **PostgreSQL**:
browse schemas/tables, run queries with highlighting + autocomplete, manage saved connections,
with an enforced per-connection **read-only mode**. See [`mobile-db-client-plan.md`](mobile-db-client-plan.md)
for the full product spec and phased roadmap — that document is the source of truth for *what* to build;
this file is the source of truth for *how* the code is organized and the conventions we hold to.

---

## Toolchain

- **Flutter SDK is pinned per-project with [FVM](https://fvm.app).** The version lives in `.fvmrc`.
- **Always prefix Dart/Flutter commands with `fvm`** so you use the pinned SDK, never a global one:

  | Task | Command |
  |---|---|
  | Get packages | `fvm flutter pub get` |
  | Run codegen (Riverpod/drift) | `fvm dart run build_runner build --delete-conflicting-outputs` |
  | Watch codegen | `fvm dart run build_runner watch --delete-conflicting-outputs` |
  | Format | `fvm dart format lib test` |
  | Analyze | `fvm flutter analyze` |
  | Test | `fvm flutter test` |
  | Run app | `fvm flutter run` |

- Node is used **only** for repo tooling (commit linting + git hooks), never for app code. See `package.json`.

---

## Architecture — the one rule that matters most

All database access goes through an **abstract adapter interface**. The app never imports
`package:postgres` (or any other driver) outside its adapter. This is what keeps the door open for
MySQL/SQLite later (plan §3).

- UI, state, and repositories consume **only driver-agnostic models** (`lib/db/adapter/models/`).
- All SQL the *app itself* generates (previews, pagination, introspection) lives **inside the adapter**.
- `ConnectionConfig.kind` is persisted from day one even though only `postgres` exists.

### Layering (dependencies point downward only)

```
features/ ─▶ data/ ─▶ db/adapter (contract) ◀─ db/postgres (impl)
   │                      ▲
   └──────▶ core/ ◀───────┘   (theme, router, errors — no feature imports)
```

- `features/**` may depend on `data/**`, `db/adapter/**`, and `core/**`.
- `data/**` may depend on `db/adapter/**` and `core/**`. It must not import a concrete driver.
- `db/postgres/**` is the **only** place `package:postgres` may be imported.
- `core/**` depends on nothing in the app. No `core` file imports a `feature`.

### Folder map (`lib/`)

```
core/
  theme/      design tokens (AppColors, AppTypography, AppRadii, AppSpacing) + ThemeData
  router/     go_router config
  errors/     AppException hierarchy + driver→app error mapping
db/
  adapter/    database_adapter.dart (contract), adapter_registry.dart, models/
  postgres/   postgres_adapter.dart, postgres_introspection.dart
data/         secure_credentials_repository, connections_repository, query_history_repository
features/
  connections/  list, editor form, test-connection
  browser/      schema tree, table preview
  editor/       SQL editor, autocomplete, snippet toolbar
  results/      grid, pagination, cell viewer
main.dart
```

---

## Theme — tokens are the only source of color/spacing

The design system is **dark-base with colorful semantic accents** (the SQL-token palette). It is
mirrored from the Figma/Claude design export (`Juno Design System.html`).

- **Never hardcode a `Color(0x…)`, font size, radius, or spacing value in a widget.** Reference the
  tokens in `lib/core/theme/`:
  - `AppColors`   — surfaces, text, semantic accents (`keyword`, `operator`, `value`, `schema`, `danger`, `success`).
  - `AppTypography` — Geist (UI) + JetBrains Mono (code/SQL) text styles.
  - `AppRadii` / `AppSpacing` — the radius and 4px-based spacing scales.
- Think of `lib/core/theme/` as this project's `tailwind.config` — extend it there, then consume the named token.
- The editor's syntax-highlight colors **must** match the snippet-chip colors (same hues) so code and
  chips read as one system. Verify every text/chip pair at ≥ 4.5:1 contrast.

---

## State & navigation

- **Riverpod** (`flutter_riverpod` + `riverpod_annotation`/codegen). Prefer `@riverpod` generated
  providers over hand-written ones. Run codegen after touching any annotated provider.
- **go_router** for navigation; routes are declared in `core/router/`.
- Keep widgets thin: no DB calls or business logic in `build()`. Side effects live in providers/repositories.

---

## Errors & security (non-negotiable)

- Driver errors are mapped to typed `AppException` subtypes (timeout / auth / unreachable / SSL /
  read-only-violation) with human-readable messages — surface those, never raw driver strings.
- **Secrets** (passwords) live **only** in `flutter_secure_storage` under `conn_password_<uuid>`.
  Never store a password in drift, logs, error reports, analytics, or any persisted state object.
- **Never log SQL with inlined credentials or full result data.** Query history stores SQL text only.
- Read-only mode is enforced **server-side** in the adapter's `connect()` (Postgres
  `default_transaction_read_only = on`); the client-side classifier is UX only, not the guarantee (plan §4).

---

## Conventions

- **Files/dirs:** `lower_snake_case.dart`. **Types:** `UpperCamelCase`. **Members/vars:** `lowerCamelCase`.
- One public class per file where practical; name the file after it (`postgres_adapter.dart`).
- Prefer `final`/`const`; immutable models. Avoid `dynamic`; type everything (the analyzer enforces this).
- Lints are configured in `analysis_options.yaml` (`flutter_lints` + `riverpod_lint` + custom strictness).
  **A clean `fvm flutter analyze` is required to commit** (enforced by the pre-commit hook).

## Commits

Conventional Commits, enforced by commitlint via the husky `commit-msg` hook.

```
<type>(<scope>): <subject>
```

- **types:** `feat fix refactor perf docs test build ci chore revert style`
- **scopes:** `core theme router db adapter postgres data connections browser editor results history deps ci tooling release`
- Subject in imperative mood, lower-case, no trailing period. Example:
  `feat(connections): add test-connection ping with latency`

The **pre-commit** hook runs `dart format --set-exit-if-changed` + `flutter analyze`; the
**commit-msg** hook runs commitlint. After a fresh clone, run `npm install` once so husky installs the hooks.

## Testing

- Unit-test the adapter against a Docker Postgres: `docker run -p 5432:5432 -e POSTGRES_PASSWORD=dev postgres:16`.
- Test driver-agnostic models and repositories without a real DB where possible.
- Every bug fix gets a regression test.
