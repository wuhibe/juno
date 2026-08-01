# Juno

A mobile-first PostgreSQL client for iOS and Android. Browse schemas, filter and page through
tables, and run SQL with highlighting and schema-aware autocomplete — from a phone, with an
enforced read-only mode so a stray tap can't write to production.

Built with Flutter. Dark theme, SQL-token colour palette, one connection at a time.

---

## Features

**Connections**
- Saved connections with per-connection colour tag and environment label (dev / staging / prod)
- Passwords stored only in the OS keychain/keystore, never in the local database or logs
- Test-connection ping with latency before saving
- **Read-only mode**, enforced server-side (`default_transaction_read_only`), so writes hidden
  inside CTEs are rejected by the engine — not by a regex

**Browsing**
- Schema → tables / views / materialized views / partitioned tables → columns, with type,
  nullability, primary key, and foreign-key target
- Table browser with server-side filtering (`=`, `≠`, `<`, `>`, contains, starts with, is one of,
  is null), sorting by column, and 200-row pages
- Enum columns offer their allowed labels as filter chips

**Querying**
- SQL editor with syntax highlighting and autocomplete (keywords → tables → columns)
- Composable snippet toolbar above the keyboard: tap chips instead of typing
- Auto-pagination for bare `SELECT`s, cancel mid-query, elapsed time and row counts
- Results grid with horizontal scroll, NULL rendered distinctly, tap-and-hold a cell for the full
  value (with JSON pretty-printing)
- Local query history (SQL text only) with re-run and copy

**Reliability**
- Mobile OSes kill idle sockets: every resume pings and silently reconnects
- Driver errors are mapped to typed, human-readable messages — never raw driver strings

---

## Install

Grab the latest `Juno-v*.apk` from [Releases](https://github.com/wuhibe/juno/releases) and install
it. The app checks for newer releases on launch and offers the download.

> **One-time note:** releases before signing was set up were signed with a debug key. If you have
> such a build installed, Android will refuse the upgrade — uninstall it once, then install the new
> APK. Upgrades after that are seamless.

iOS is not distributed yet; run it from source.

---

## Development

The Flutter SDK is pinned per-project with [FVM](https://fvm.app) — the version lives in `.fvmrc`.
Always prefix commands with `fvm` so you use the pinned SDK.

```bash
fvm flutter pub get      # dependencies
npm install              # once, to install the husky git hooks
fvm flutter run          # run on a device or simulator
```

| Task | Command |
|---|---|
| Codegen (Riverpod / drift) | `fvm dart run build_runner build --delete-conflicting-outputs` |
| Watch codegen | `fvm dart run build_runner watch --delete-conflicting-outputs` |
| Format | `fvm dart format lib test` |
| Analyze | `fvm flutter analyze` |
| Test | `fvm flutter test` |

Node is used only for commit linting and git hooks, never for app code.

### Testing

```bash
fvm flutter test
```

Adapter integration tests need a real server and are skipped unless you opt in:

```bash
docker run --rm -p 5432:5432 -e POSTGRES_PASSWORD=dev postgres:16
```

```bash
fvm flutter test --dart-define=JUNO_PG_IT=true test/db/postgres_adapter_integration_test.dart
```

---

## Architecture

Every database call goes through an abstract adapter, so adding MySQL or SQLite later means a new
adapter and a field descriptor — not a UI rewrite.

```
features/ ─▶ data/ ─▶ db/adapter (contract) ◀─ db/postgres (impl)
   │                      ▲
   └──────▶ core/ ◀───────┘
```

`package:postgres` is imported in exactly one directory (`lib/db/postgres/`). The UI and state
layers only ever see driver-agnostic models, and all SQL the app itself generates — previews,
pagination, filters, introspection — is written inside the adapter.

See [`CLAUDE.md`](CLAUDE.md) for the full conventions: layering rules, theme tokens, security
requirements, and commit format. Planned work lives in [`ROADMAP.md`](ROADMAP.md).

---

## Releasing

Releases are cut from a version tag:

```bash
git tag v1.1.0 && git push origin v1.1.0
```

The workflow builds a signed APK — the tag sets the build name, the CI run number sets the build
number — and publishes it as `Juno-v1.1.0.apk` with generated release notes. It requires the
`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD` repository secrets; see
[`.github/workflows/release.yml`](.github/workflows/release.yml).
