import 'package:flutter/material.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';

/// One selectable row in a [SnippetPickSheet].
class SnippetPickItem<T> {
  /// Creates an item carrying [value], shown as [label] with optional [detail].
  const SnippetPickItem({
    required this.value,
    required this.label,
    this.detail,
  });

  /// The value returned when chosen.
  final T value;

  /// The primary label (table/column name).
  final String label;

  /// Optional trailing detail (schema, type).
  final String? detail;
}

/// A searchable bottom-sheet quick-pick used by the snippet toolbar's smart
/// chips — tap `FROM` to pick a table, or pick a column (plan §8 "smart chips").
class SnippetPickSheet<T> extends StatefulWidget {
  /// Creates the sheet titled [title] over [items].
  const SnippetPickSheet({required this.title, required this.items, super.key});

  /// The sheet header (e.g. "Tables").
  final String title;

  /// The selectable items.
  final List<SnippetPickItem<T>> items;

  /// Shows the sheet and resolves to the chosen value, or null if dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<SnippetPickItem<T>> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).juno.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (context) => SnippetPickSheet<T>(title: title, items: items),
    );
  }

  @override
  State<SnippetPickSheet<T>> createState() => _SnippetPickSheetState<T>();
}

class _SnippetPickSheetState<T> extends State<SnippetPickSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.items
        : widget.items
              .where((item) => item.label.toLowerCase().contains(query))
              .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                style: AppTypography.mono(14, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search…',
                  prefixIcon: Icon(Icons.search, color: colors.textMuted),
                  filled: true,
                  fillColor: colors.surfaceAlt,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.mdAll,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        item.label,
                        style: AppTypography.mono(
                          14,
                          color: colors.textPrimary,
                        ),
                      ),
                      trailing: item.detail == null
                          ? null
                          : Text(
                              item.detail!,
                              style: AppTypography.mono(
                                11,
                                color: colors.textFaint,
                              ),
                            ),
                      onTap: () => Navigator.of(context).pop(item.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
