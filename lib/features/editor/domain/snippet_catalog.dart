import 'package:juno/features/editor/domain/snippet_chip.dart';

/// The static snippet catalog — the colour-coded chips, grouped by
/// category, with their long-press variants. Smart (schema) chips are generated
/// at runtime from the schema cache and are not listed here.
abstract final class SnippetCatalog {
  /// Statement-structure chips (violet). Write chips are flagged so read-only
  /// connections can hide them.
  static const List<SnippetChip> structure = <SnippetChip>[
    SnippetChip(
      label: 'SELECT',
      insertText: 'SELECT',
      category: SnippetCategory.structure,
    ),
    SnippetChip(
      label: 'FROM',
      insertText: 'FROM',
      category: SnippetCategory.structure,
    ),
    SnippetChip(
      label: 'WHERE',
      insertText: 'WHERE',
      category: SnippetCategory.structure,
    ),
    SnippetChip(
      label: 'JOIN',
      insertText: 'JOIN',
      category: SnippetCategory.structure,
      variants: <SnippetChip>[
        SnippetChip(
          label: 'JOIN',
          insertText: 'JOIN',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'LEFT JOIN',
          insertText: 'LEFT JOIN',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'RIGHT JOIN',
          insertText: 'RIGHT JOIN',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'INNER JOIN',
          insertText: 'INNER JOIN',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'FULL JOIN',
          insertText: 'FULL JOIN',
          category: SnippetCategory.structure,
        ),
      ],
    ),
    SnippetChip(
      label: 'GROUP BY',
      insertText: 'GROUP BY',
      category: SnippetCategory.structure,
    ),
    SnippetChip(
      label: 'ORDER BY',
      insertText: 'ORDER BY',
      category: SnippetCategory.structure,
    ),
    SnippetChip(
      label: 'HAVING',
      insertText: 'HAVING',
      category: SnippetCategory.structure,
    ),
    SnippetChip(
      label: 'LIMIT',
      insertText: 'LIMIT',
      category: SnippetCategory.structure,
      variants: <SnippetChip>[
        SnippetChip(
          label: 'LIMIT',
          insertText: 'LIMIT',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'LIMIT 10',
          insertText: 'LIMIT 10',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'LIMIT 100',
          insertText: 'LIMIT 100',
          category: SnippetCategory.structure,
        ),
        SnippetChip(
          label: 'LIMIT 1000',
          insertText: 'LIMIT 1000',
          category: SnippetCategory.structure,
        ),
      ],
    ),
    SnippetChip(
      label: 'INSERT',
      insertText: 'INSERT INTO',
      category: SnippetCategory.structure,
      isWrite: true,
    ),
    SnippetChip(
      label: 'UPDATE',
      insertText: 'UPDATE',
      category: SnippetCategory.structure,
      isWrite: true,
    ),
    SnippetChip(
      label: 'DELETE',
      insertText: 'DELETE FROM',
      category: SnippetCategory.structure,
      isWrite: true,
    ),
  ];

  /// Operator chips (amber).
  static const List<SnippetChip> operators = <SnippetChip>[
    SnippetChip(
      label: '=',
      insertText: '=',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: '!=',
      insertText: '!=',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: '<',
      insertText: '<',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: '>',
      insertText: '>',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: '>=',
      insertText: '>=',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: '<=',
      insertText: '<=',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'LIKE',
      insertText: 'LIKE',
      category: SnippetCategory.operators,
      variants: <SnippetChip>[
        SnippetChip(
          label: 'LIKE',
          insertText: 'LIKE',
          category: SnippetCategory.operators,
        ),
        SnippetChip(
          label: "LIKE '%…%'",
          insertText: "LIKE '%%'",
          category: SnippetCategory.operators,
          cursorBack: 2,
        ),
      ],
    ),
    SnippetChip(
      label: 'ILIKE',
      insertText: 'ILIKE',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'IN ()',
      insertText: 'IN ()',
      category: SnippetCategory.operators,
      cursorBack: 1,
    ),
    SnippetChip(
      label: 'BETWEEN',
      insertText: 'BETWEEN',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'AND',
      insertText: 'AND',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'OR',
      insertText: 'OR',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'NOT',
      insertText: 'NOT',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'IS NULL',
      insertText: 'IS NULL',
      category: SnippetCategory.operators,
    ),
    SnippetChip(
      label: 'IS NOT NULL',
      insertText: 'IS NOT NULL',
      category: SnippetCategory.operators,
    ),
  ];

  /// Value & punctuation chips (teal).
  static const List<SnippetChip> values = <SnippetChip>[
    SnippetChip(
      label: "''",
      insertText: "''",
      category: SnippetCategory.value,
      cursorBack: 1,
    ),
    SnippetChip(
      label: '()',
      insertText: '()',
      category: SnippetCategory.value,
      cursorBack: 1,
    ),
    SnippetChip(label: '*', insertText: '*', category: SnippetCategory.value),
    SnippetChip(label: ',', insertText: ',', category: SnippetCategory.value),
    SnippetChip(label: ';', insertText: ';', category: SnippetCategory.value),
    SnippetChip(
      label: 'NULL',
      insertText: 'NULL',
      category: SnippetCategory.value,
    ),
    SnippetChip(
      label: 'TRUE',
      insertText: 'TRUE',
      category: SnippetCategory.value,
    ),
    SnippetChip(
      label: 'FALSE',
      insertText: 'FALSE',
      category: SnippetCategory.value,
    ),
    SnippetChip(
      label: 'NOW()',
      insertText: 'NOW()',
      category: SnippetCategory.value,
    ),
    SnippetChip(
      label: 'COUNT(*)',
      insertText: 'COUNT(*)',
      category: SnippetCategory.value,
    ),
  ];

  /// Every static chip across all categories.
  static List<SnippetChip> get all => <SnippetChip>[
    ...structure,
    ...operators,
    ...values,
  ];

  /// Looks up a chip by its [label], or null if none matches.
  static SnippetChip? byLabel(String label) {
    for (final chip in all) {
      if (chip.label == label) {
        return chip;
      }
    }
    return null;
  }
}
