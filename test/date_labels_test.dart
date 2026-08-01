import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/shared/date_labels.dart';

void main() {
  group('UTC inputs are normalized to the local day', () {
    // These are timezone-independent: they compare a UTC instant against the
    // same instant expressed locally, so they hold on any machine while still
    // failing if the normalization is removed (under any non-zero offset).
    final lateEvening = DateTime(2026, 7, 31, 23, 30);

    test('dayKey agrees whether given a UTC or a local DateTime', () {
      expect(dayKey(lateEvening.toUtc()), dayKey(lateEvening));
    });

    test('isSameDay agrees whether given a UTC or a local DateTime', () {
      expect(isSameDay(lateEvening.toUtc(), lateEvening), isTrue);
    });

    test('startOfDay agrees whether given a UTC or a local DateTime', () {
      expect(startOfDay(lateEvening.toUtc()), startOfDay(lateEvening));
    });

    test('labels agree whether given a UTC or a local DateTime', () {
      expect(fullDateLabel(lateEvening.toUtc()), fullDateLabel(lateEvening));
      expect(shortDateLabel(lateEvening.toUtc()), shortDateLabel(lateEvening));
      expect(monthYearLabel(lateEvening.toUtc()), monthYearLabel(lateEvening));
      expect(weekdayName(lateEvening.toUtc()), weekdayName(lateEvening));
    });
  });

  group('startOfWeek', () {
    test('returns the same day when given a Monday', () {
      // 2026-07-27 is a Monday.
      final monday = DateTime(2026, 7, 27, 15, 42);
      expect(startOfWeek(monday), DateTime(2026, 7, 27));
    });

    test('returns the preceding Monday when given a Sunday', () {
      // Sunday is weekday 7, the far end of the week - the case an
      // off-by-one in the Monday-first shift would break.
      final sunday = DateTime(2026, 8, 2, 23, 59);
      expect(startOfWeek(sunday), DateTime(2026, 7, 27));
    });

    test('crosses a month boundary', () {
      final wednesday = DateTime(2026, 8, 5);
      expect(startOfWeek(wednesday), DateTime(2026, 8, 3));
    });
  });

  group('weekday and month names', () {
    test('maps DateTime.weekday onto Monday-first tables', () {
      expect(weekdayName(DateTime(2026, 7, 27)), 'lunes');
      expect(weekdayName(DateTime(2026, 7, 31)), 'viernes');
      expect(weekdayName(DateTime(2026, 8, 2)), 'domingo');
    });

    test('initials line up with the same days', () {
      expect(weekdayInitial(DateTime(2026, 7, 27)), 'L');
      expect(weekdayInitial(DateTime(2026, 8, 2)), 'D');
    });

    test('months are 1-based', () {
      expect(monthName(DateTime(2026, 1, 1)), 'enero');
      expect(monthName(DateTime(2026, 12, 31)), 'diciembre');
    });
  });

  group('labels', () {
    test('fullDateLabel reads as a Spanish sentence', () {
      expect(
        fullDateLabel(DateTime(2026, 7, 31)),
        'viernes, 31 de julio de 2026',
      );
    });

    test('monthYearLabel drops the day', () {
      expect(monthYearLabel(DateTime(2026, 7, 31)), 'julio de 2026');
    });
  });

  group('isSameDay', () {
    test('ignores the time of day', () {
      expect(
        isSameDay(DateTime(2026, 7, 31, 0, 0), DateTime(2026, 7, 31, 23, 59)),
        isTrue,
      );
    });

    test('separates the same day number in different months', () {
      expect(isSameDay(DateTime(2026, 7, 31), DateTime(2026, 8, 31)), isFalse);
    });
  });

  group('dayKey', () {
    test('zero-pads so keys sort lexicographically', () {
      expect(dayKey(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('uses the local day, not a UTC-shifted one', () {
      // Late-evening local time is already the next day in UTC for negative
      // offsets; the cache key must still say "today".
      final lateEvening = DateTime(2026, 7, 31, 23, 30);
      expect(dayKey(lateEvening), '2026-07-31');
    });
  });
}
