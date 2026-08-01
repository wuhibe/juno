# Roadmap

What Juno does today is described in [`README.md`](README.md); this file is only what it does
*not* do yet. No dates, no phases — pull items off as they become worth doing.

## Engines

- **MySQL / MariaDB adapter.** The adapter contract and the per-kind connection-form descriptor
  already exist; this is a new `DatabaseAdapter` plus a descriptor. Read-only mode maps to
  `SET SESSION TRANSACTION READ ONLY`. Evaluate maintained drivers at build time — the classic
  `mysql_client` is stale.
- **SQLite adapter** for local database files.
- **SSH tunnelling** (`dartssh2`) so databases behind a bastion are reachable.

## Connections

- **Connection from URL:** paste `postgresql://user:pass@host:5432/db` into the editor form and
  pre-fill every field. The password still goes to secure storage only.
- Test-connection button styling: tighten the corner radius to match the rest of the form.

## Browsing & querying

- **Relative date filters** ("last 7 days", "this month") on timestamp columns, compiling to
  `>= now() - interval '…'`, so filtering by time needs no manual timestamp typing.
- **OR groups in filters.** Conditions are AND-only today.
- **Stable paging under a non-unique sort.** `ORDER BY` on a column with ties lets rows shuffle
  between pages; a primary-key tiebreaker would fix it.
- **Export** results to CSV/JSON.
- **Saved query library**, and multiple simultaneous connections / tabs.
- **Inline cell editing** with generated UPDATEs (write connections only).

## Platform

- **iOS distribution.** No channel exists yet, so the in-app update check is Android-only.
- **Persisted update dismissal.** "Skip this version" currently lasts the session; persisting it
  needs a settings row in the drift database.
- **Code push (e.g. Shorebird)** if patching Dart code without a full release ever becomes worth
  the extra build pipeline.

## Quality

- **On-device QA matrix**, not yet run: small and large Android phones, iPhone SE-class and
  Pro-class, SSL and non-SSL servers, read-only violation paths, airplane mode mid-query.
- **Safe-area audit (unverified).** Bottom-edge controls may fall under the home indicator on some
  devices — check the connection editor's Test/Connect buttons and the lower grid rows. The snippet
  toolbar and the table browser footer already wrap in `SafeArea`.
- **Huge cells.** A multi-megabyte `jsonb` value is truncated for display, but the truncation
  threshold has not been tuned against real data.
