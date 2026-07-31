import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/features/fasting/fasting_protocols.dart';

void main() {
  group('parseCustomTargetHours', () {
    test('accepts a value within 1-72', () {
      expect(parseCustomTargetHours('24'), 24);
    });

    test('rejects zero', () {
      expect(parseCustomTargetHours('0'), isNull);
    });

    test('rejects values above 72', () {
      expect(parseCustomTargetHours('73'), isNull);
    });

    test('rejects non-numeric input', () {
      expect(parseCustomTargetHours('abc'), isNull);
    });
  });

  group('formatFastingDuration', () {
    test('formats hours and minutes', () {
      expect(formatFastingDuration(const Duration(hours: 14, minutes: 32)), '14h 32m');
    });

    test('formats durations under an hour', () {
      expect(formatFastingDuration(const Duration(minutes: 45)), '0h 45m');
    });
  });
}
