import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'autocomplete_index_provider.g.dart';

/// Flattened table list across all visible (non-system) schemas, eagerly loaded
/// so the editor can offer table suggestions the moment the connection is live
/// — before the user has expanded anything in the schema browser.
///
/// Reuses the keep-alive [tableListProvider] caches, so the browser and the
/// autocomplete engine share one source of truth and a single round of
/// introspection. Columns stay lazy (warmed per referenced table in the editor)
/// to avoid introspecting every table on connect.
@Riverpod(keepAlive: true)
Future<List<DbTable>> autocompleteTables(Ref ref) async {
  final schemas = await ref.watch(schemaListProvider.future);
  final tables = <DbTable>[];
  for (final schema in schemas) {
    if (schema.isSystem) {
      continue;
    }
    tables.addAll(await ref.watch(tableListProvider(schema.name).future));
  }
  return tables;
}
