import 'dart:async';
import 'dart:io';

import 'package:juno/core/errors/app_exception.dart';
import 'package:postgres/postgres.dart' as pg;

/// Translates a raw error thrown by `package:postgres` into a typed,
/// user-safe [AppException].
///
/// The UI must only ever see these — never a raw driver string, which can leak
/// internals or be unreadable. The original error is attached as `cause` for
/// logging only.
AppException mapPostgresError(
  Object error,
  StackTrace stackTrace, {
  String? sql,
}) {
  // Already mapped (e.g. rethrown) — pass through unchanged.
  if (error is AppException) {
    return error;
  }

  if (error is TimeoutException) {
    return ConnectionTimeoutException(
      'The database did not respond in time.',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is pg.BadCertificateException) {
    return SslException(
      'The server SSL certificate could not be verified.',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is SocketException) {
    return HostUnreachableException(
      'Could not reach the database host. Check the host, port, and network.',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is pg.ServerException) {
    return mapPostgresSqlState(
      error.code,
      error.message,
      position: error.position,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is pg.PgException) {
    final message = error.message.toLowerCase();
    if (message.contains('ssl') ||
        message.contains('certificate') ||
        message.contains('tls')) {
      return SslException(
        'A secure connection to the database could not be established.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (message.contains('timed out') || message.contains('timeout')) {
      return ConnectionTimeoutException(
        'The operation timed out.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return QueryException(error.message, cause: error, stackTrace: stackTrace);
  }

  return UnknownDatabaseException(
    'An unexpected database error occurred.',
    cause: error,
    stackTrace: stackTrace,
  );
}

/// Maps a Postgres SQLSTATE [code] to a typed [AppException].
///
/// Extracted as a pure function (no driver objects) so the security-critical
/// mappings — especially the read-only violation — are directly unit-testable.
/// See https://www.postgresql.org/docs/current/errcodes-appendix.html.
AppException mapPostgresSqlState(
  String? code,
  String message, {
  int? position,
  Object? cause,
  StackTrace? stackTrace,
}) {
  switch (code) {
    // 57014 — query_canceled: a user-requested cancellation landed server-side.
    case '57014':
      return QueryCancelledException(
        'Query cancelled.',
        cause: cause,
        stackTrace: stackTrace,
      );
    // Class 25 — read_only_sql_transaction: the read-only guarantee firing.
    case '25006':
      return ReadOnlyViolationException(
        'This connection is read-only — writes '
        '(INSERT/UPDATE/DELETE/DDL) are blocked.',
        cause: cause,
        stackTrace: stackTrace,
      );
    // Class 28 — invalid authorization / bad password.
    case '28000':
    case '28P01':
      return AuthenticationException(
        'Authentication failed. Check the username and password.',
        cause: cause,
        stackTrace: stackTrace,
      );
    // 3D000 — invalid_catalog_name: the database does not exist.
    case '3D000':
      return QueryException(
        'The specified database does not exist.',
        cause: cause,
        stackTrace: stackTrace,
        position: position,
      );
    // Class 08 — connection exceptions.
    case '08001':
    case '08006':
    case '08004':
      return HostUnreachableException(
        'The connection to the database failed.',
        cause: cause,
        stackTrace: stackTrace,
      );
    default:
      return QueryException(
        message,
        cause: cause,
        stackTrace: stackTrace,
        position: position,
      );
  }
}
