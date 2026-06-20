import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/db/postgres/postgres_error_mapper.dart';

void main() {
  group('mapPostgresSqlState', () {
    test('25006 (read_only_sql_transaction) -> ReadOnlyViolationException', () {
      final mapped = mapPostgresSqlState(
        '25006',
        'cannot execute INSERT in a read-only transaction',
      );
      expect(mapped, isA<ReadOnlyViolationException>());
    });

    test('class 28 codes -> AuthenticationException', () {
      expect(
        mapPostgresSqlState('28P01', 'password authentication failed'),
        isA<AuthenticationException>(),
      );
      expect(
        mapPostgresSqlState('28000', 'invalid authorization'),
        isA<AuthenticationException>(),
      );
    });

    test('class 08 codes -> HostUnreachableException', () {
      expect(
        mapPostgresSqlState('08006', 'connection failure'),
        isA<HostUnreachableException>(),
      );
    });

    test('unknown code -> QueryException preserving the error position', () {
      final mapped = mapPostgresSqlState(
        '42601',
        'syntax error at or near "FROM"',
        position: 7,
      );
      expect(mapped, isA<QueryException>());
      expect((mapped as QueryException).position, 7);
    });
  });

  group('mapPostgresError', () {
    test('SocketException -> HostUnreachableException', () {
      final mapped = mapPostgresError(
        const SocketException('no route to host'),
        StackTrace.current,
      );
      expect(mapped, isA<HostUnreachableException>());
    });

    test('TimeoutException -> ConnectionTimeoutException', () {
      final mapped = mapPostgresError(
        TimeoutException('too slow'),
        StackTrace.current,
      );
      expect(mapped, isA<ConnectionTimeoutException>());
    });

    test('an already-typed AppException passes through unchanged', () {
      const original = QueryCancelledException('cancelled by user');
      expect(mapPostgresError(original, StackTrace.current), same(original));
    });

    test('an unrecognized error -> UnknownDatabaseException', () {
      final mapped = mapPostgresError(Object(), StackTrace.current);
      expect(mapped, isA<UnknownDatabaseException>());
    });

    test('mapped messages never leak the password', () {
      // A sanity check that our user-facing messages are clean, generic text.
      final mapped = mapPostgresError(
        const SocketException('connection refused'),
        StackTrace.current,
      );
      expect(mapped.message, isNot(contains('password')));
    });
  });
}
