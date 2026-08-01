import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/supabase/fasting_sessions_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('curatedFastingError', () {
    test('curates the unique-violation on fasting_active_per_user', () {
      const error = PostgrestException(message: 'duplicate key value', code: '23505');
      expect(curatedFastingError(error), 'Ya tienes un ayuno en curso.');
    });

    test('returns null for other Postgrest errors', () {
      const error = PostgrestException(message: 'server error', code: '500');
      expect(curatedFastingError(error), isNull);
    });

    test('returns null for non-Postgrest errors', () {
      expect(curatedFastingError(Exception('boom')), isNull);
    });
  });

  group('fastingSessionFromRow', () {
    test('maps a finished session row', () {
      final session = fastingSessionFromRow({
        'id': 'session-1',
        'start_at': '2026-07-30T20:00:00.000Z',
        'end_at': '2026-07-31T12:00:00.000Z',
        'target_hours': 16,
        'protocol': '16:8',
        'notes': 'sin cafe',
      });

      expect(session.id, 'session-1');
      expect(session.startAt.isAtSameMomentAs(DateTime.parse('2026-07-30T20:00:00.000Z')), isTrue);
      expect(session.endAt!.isAtSameMomentAs(DateTime.parse('2026-07-31T12:00:00.000Z')), isTrue);
      expect(session.targetHours, 16);
      expect(session.protocol, '16:8');
      expect(session.notes, 'sin cafe');
    });

    test('returns local DateTimes so the UI dates entries by the local day', () {
      // The regression this exists for: `DateTime.parse` of an offset-bearing
      // string yields a UTC value, whose `.day`/`.hour` are UTC components.
      // A history row would then be dated by UTC's calendar, not the user's.
      final session = fastingSessionFromRow({
        'id': 'session-3',
        'start_at': '2026-07-30T20:00:00.000Z',
        'end_at': '2026-07-31T12:00:00.000Z',
        'target_hours': 16,
        'protocol': '16:8',
        'notes': null,
      });

      expect(session.startAt.isUtc, isFalse);
      expect(session.endAt!.isUtc, isFalse);
    });

    test('parses the offset format PostgREST actually sends, not just "Z"', () {
      final session = fastingSessionFromRow({
        'id': 'session-4',
        'start_at': '2026-07-30T20:00:00+00:00',
        'end_at': null,
        'target_hours': 16,
        'protocol': '16:8',
        'notes': null,
      });

      expect(session.startAt.isAtSameMomentAs(DateTime.parse('2026-07-30T20:00:00.000Z')), isTrue);
    });

    test('maps an in-progress session row (end_at and notes null)', () {
      final session = fastingSessionFromRow({
        'id': 'session-2',
        'start_at': '2026-07-31T08:00:00.000Z',
        'end_at': null,
        'target_hours': 12,
        'protocol': '12:12',
        'notes': null,
      });

      expect(session.endAt, isNull);
      expect(session.notes, isNull);
    });
  });
}
