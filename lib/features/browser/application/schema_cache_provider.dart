import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'schema_cache_provider.g.dart';

/// Whether engine-internal schemas (`pg_catalog`, `information_schema`, `pg_*`)
/// are shown in the browser.
@Riverpod(keepAlive: true)
class ShowSystemSchemas extends _$ShowSystemSchemas {
  @override
  bool build() => false;

  /// Flips the toggle.
  void toggle() => state = !state;
}

/// Cached schema list for the active connection. Recomputed when the connection
/// changes or the system-schemas toggle flips.
@Riverpod(keepAlive: true)
Future<List<DbSchema>> schemaList(Ref ref) {
  final adapter = ref.watch(activeAdapterProvider);
  final includeSystem = ref.watch(showSystemSchemasProvider);
  return adapter.listSchemas(includeSystem: includeSystem);
}

/// Cached table list for [schema] (lazy: only loaded once a schema is expanded).
@Riverpod(keepAlive: true)
Future<List<DbTable>> tableList(Ref ref, String schema) {
  final adapter = ref.watch(activeAdapterProvider);
  return adapter.listTables(schema);
}

/// Cached column list for [schema].[table] (lazy: loaded on table expand).
/// Shared with the schema browser and (later) the autocomplete engine.
@Riverpod(keepAlive: true)
Future<List<DbColumn>> columnList(Ref ref, String schema, String table) {
  final adapter = ref.watch(activeAdapterProvider);
  return adapter.listColumns(schema, table);
}
