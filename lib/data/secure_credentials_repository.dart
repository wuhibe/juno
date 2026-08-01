import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores and retrieves connection passwords.
///
/// This is the **only** place a password is read or written. Passwords never
/// touch drift, logs, analytics, or any persisted state object. Kept
/// as an interface so it can be faked in tests without platform channels.
abstract interface class SecureCredentialsRepository {
  /// Stores (or replaces) the password for [connectionId].
  Future<void> savePassword(String connectionId, String password);

  /// Reads the password for [connectionId], or null if none is stored.
  Future<String?> readPassword(String connectionId);

  /// Deletes the stored password for [connectionId] (no-op if absent).
  Future<void> deletePassword(String connectionId);
}

/// Keychain (iOS) / Keystore-backed (Android) implementation over
/// `flutter_secure_storage`. Keys are namespaced `conn_password_<uuid>`.
class FlutterSecureCredentialsRepository
    implements SecureCredentialsRepository {
  /// Creates the repository, optionally with a custom [storage] (tests).
  FlutterSecureCredentialsRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String _keyFor(String connectionId) => 'conn_password_$connectionId';

  @override
  Future<void> savePassword(String connectionId, String password) =>
      _storage.write(key: _keyFor(connectionId), value: password);

  @override
  Future<String?> readPassword(String connectionId) =>
      _storage.read(key: _keyFor(connectionId));

  @override
  Future<void> deletePassword(String connectionId) =>
      _storage.delete(key: _keyFor(connectionId));
}
