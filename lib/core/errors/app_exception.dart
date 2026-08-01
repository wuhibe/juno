/// Base of Juno's driver-agnostic exception hierarchy.
///
/// Database adapters must translate raw driver errors into one of these typed
/// exceptions so the UI can render a clean, human-readable [message] and branch
/// on the type — never on a driver string.
///
/// The original error is kept in [cause] for logging, but must never be shown
/// raw to the user, and must never contain credentials.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  /// Human-readable, user-safe description.
  final String message;

  /// The underlying error, for logs only. Never surfaced to the user.
  final Object? cause;

  /// Stack trace captured at the original failure site, for logs only.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// The connection attempt timed out.
final class ConnectionTimeoutException extends AppException {
  const ConnectionTimeoutException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// Authentication failed (bad username/password or role).
final class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.cause, super.stackTrace});
}

/// The host is unreachable (DNS failure, refused, network down).
final class HostUnreachableException extends AppException {
  const HostUnreachableException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// An SSL/TLS negotiation or verification problem.
final class SslException extends AppException {
  const SslException(super.message, {super.cause, super.stackTrace});
}

/// A write was attempted on a read-only connection and rejected server-side.
final class ReadOnlyViolationException extends AppException {
  const ReadOnlyViolationException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// A query failed to execute (syntax error, constraint, etc.).
final class QueryException extends AppException {
  const QueryException(
    super.message, {
    super.cause,
    super.stackTrace,
    this.position,
  });

  /// 1-based character position of the error within the SQL, when the engine
  /// reports it (Postgres `position`). Null when unavailable.
  final int? position;
}

/// The running query was cancelled by the user.
final class QueryCancelledException extends AppException {
  const QueryCancelledException(super.message, {super.cause, super.stackTrace});
}

/// A catch-all for unexpected failures that don't map to a specific type.
final class UnknownDatabaseException extends AppException {
  const UnknownDatabaseException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}
