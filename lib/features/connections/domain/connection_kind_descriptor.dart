import 'package:flutter/material.dart';

import 'package:juno/db/adapter/models/connection_config.dart';

/// Per-engine UI metadata for the connection editor.
///
/// Keeping field defaults and capabilities behind a descriptor is what lets a
/// future MySQL/SQLite adapter slot in with a new descriptor and zero changes
/// to the editor form (plan §3).
class ConnectionKindDescriptor {
  /// Creates a descriptor for [kind].
  const ConnectionKindDescriptor({
    required this.kind,
    required this.label,
    required this.icon,
    required this.defaultPort,
    required this.sslModes,
  });

  /// The engine.
  final DatabaseKind kind;

  /// Human-readable engine name.
  final String label;

  /// Icon shown on the connection card and editor.
  final IconData icon;

  /// Default TCP port pre-filled in the editor.
  final int defaultPort;

  /// SSL modes this engine supports, in display order.
  final List<DbSslMode> sslModes;

  static const Map<DatabaseKind, ConnectionKindDescriptor> _byKind =
      <DatabaseKind, ConnectionKindDescriptor>{
        DatabaseKind.postgres: ConnectionKindDescriptor(
          kind: DatabaseKind.postgres,
          label: 'PostgreSQL',
          icon: Icons.storage_rounded,
          defaultPort: 5432,
          sslModes: DbSslMode.values,
        ),
      };

  /// The descriptor for [kind].
  static ConnectionKindDescriptor of(DatabaseKind kind) => _byKind[kind]!;
}

/// Display helpers for [DbSslMode].
extension DbSslModeLabel on DbSslMode {
  /// A short, human-readable label.
  String get label => switch (this) {
    DbSslMode.disable => 'Disable',
    DbSslMode.require => 'Require',
    DbSslMode.verifyFull => 'Verify full',
  };
}
