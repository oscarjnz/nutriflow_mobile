import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/supabase/pg_timestamp.dart';

void main() {
  group('pgTimestamp', () {
    test('serializes a local DateTime with an explicit UTC offset', () {
      // The regression this exists for: `toIso8601String()` on a non-UTC
      // DateTime emits a bare wall-clock literal with no offset, which
      // Supabase (session TimeZone = UTC) then reads as if it were UTC.
      final local = DateTime(2026, 8, 1, 20);
      expect(local.isUtc, isFalse);
      expect(local.toIso8601String(), isNot(endsWith('Z')));

      expect(pgTimestamp(local), endsWith('Z'));
    });

    test('preserves the actual instant rather than the wall-clock reading', () {
      final local = DateTime(2026, 8, 1, 20);
      expect(DateTime.parse(pgTimestamp(local)).isAtSameMomentAs(local), isTrue);
    });

    test('passes an already-UTC DateTime through unchanged', () {
      final utc = DateTime.utc(2026, 8, 1, 20);
      expect(pgTimestamp(utc), utc.toIso8601String());
      expect(pgTimestamp(utc), endsWith('Z'));
    });

    test('round-trips to the same instant regardless of the source offset', () {
      final instant = DateTime.utc(2026, 8, 1, 20);
      expect(
        DateTime.parse(pgTimestamp(instant.toLocal())).isAtSameMomentAs(instant),
        isTrue,
      );
    });
  });
}
