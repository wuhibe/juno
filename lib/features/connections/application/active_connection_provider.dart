import 'dart:async';

import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/db/adapter/adapter_registry.dart';
import 'package:juno/db/adapter/database_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_connection_provider.g.dart';

/// The connection lifecycle state: idle → connecting → connected | error.
sealed class ConnectionStatus {
  const ConnectionStatus();
}

/// No connection is open.
class ConnectionIdle extends ConnectionStatus {
  /// Creates the idle state.
  const ConnectionIdle();
}

/// A connection attempt is in flight for [connectionId].
class ConnectionConnecting extends ConnectionStatus {
  /// Creates the connecting state.
  const ConnectionConnecting(this.connectionId);

  /// The connection being opened.
  final String connectionId;
}

/// A live connection is open for [connectionId].
class ConnectionConnected extends ConnectionStatus {
  /// Creates the connected state.
  const ConnectionConnected(this.connectionId, this.adapter);

  /// The connected connection.
  final String connectionId;

  /// The live adapter (owned by the provider).
  final DatabaseAdapter adapter;
}

/// The last connection attempt for [connectionId] failed with [error].
class ConnectionFailed extends ConnectionStatus {
  /// Creates the error state.
  const ConnectionFailed(this.connectionId, this.error);

  /// The connection that failed to open.
  final String connectionId;

  /// The typed, user-safe failure.
  final AppException error;
}

/// Owns the single active database connection and its adapter.
///
/// Holds the adapter lifecycle so the rest of the app talks to a live
/// connection through [ConnectionConnected.adapter] without ever creating or
/// disposing adapters itself.
@Riverpod(keepAlive: true)
class ActiveConnection extends _$ActiveConnection {
  DatabaseAdapter? _adapter;

  @override
  ConnectionStatus build() {
    ref.onDispose(() {
      final adapter = _adapter;
      if (adapter != null) {
        unawaited(adapter.disconnect());
      }
    });
    return const ConnectionIdle();
  }

  /// Opens [connectionId]: loads its metadata + password, builds the adapter,
  /// connects (enforcing read-only server-side), and stamps it as used.
  Future<void> connect(String connectionId) async {
    state = ConnectionConnecting(connectionId);

    final connections = ref.read(connectionsRepositoryProvider);
    final credentials = ref.read(secureCredentialsRepositoryProvider);

    try {
      final saved = await connections.getById(connectionId);
      if (saved == null) {
        throw StateError('Connection "$connectionId" no longer exists.');
      }
      final password = await credentials.readPassword(connectionId) ?? '';
      final adapter = AdapterRegistry.create(saved.kind);
      await adapter.connect(saved.toConnectionConfig(password: password));

      // Replace any prior connection only after the new one is live.
      await _disconnectAdapter();
      _adapter = adapter;

      await connections.markUsed(connectionId);
      state = ConnectionConnected(connectionId, adapter);
    } on AppException catch (error) {
      state = ConnectionFailed(connectionId, error);
    } catch (error, stackTrace) {
      state = ConnectionFailed(
        connectionId,
        UnknownDatabaseException(
          'Could not open the connection.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Closes the active connection and returns to idle.
  Future<void> disconnect() async {
    await _disconnectAdapter();
    state = const ConnectionIdle();
  }

  Future<void> _disconnectAdapter() async {
    final adapter = _adapter;
    _adapter = null;
    if (adapter != null) {
      await adapter.disconnect();
    }
  }
}
