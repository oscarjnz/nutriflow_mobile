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

    test('clamps negative durations to zero', () {
      // Reachable from clock skew or a timezone change mid-fast.
      // `inMinutes.remainder(60)` keeps the sign, so without the guard this
      // would render as "-2h -30m".
      expect(formatFastingDuration(const Duration(hours: -2, minutes: -30)), '0h 0m');
    });
  });

  group('fastingProtocolLabel', () {
    test('resolves an id to its Spanish label', () {
      expect(fastingProtocolLabel('custom'), 'Personalizado');
      expect(fastingProtocolLabel('16:8'), '16:8');
    });

    test('falls back to the raw id when the protocol is unknown', () {
      expect(fastingProtocolLabel('omad'), 'omad');
    });

    test('covers every protocol offered by the picker', () {
      for (final protocol in fastingProtocols) {
        expect(fastingProtocolLabel(protocol.id), protocol.label);
      }
    });
  });
}
