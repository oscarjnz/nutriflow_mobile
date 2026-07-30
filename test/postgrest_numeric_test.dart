import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/supabase/postgrest_numeric.dart';

void main() {
  group('numFromPostgrest', () {
    test('parses a JSON string as returned for numeric/decimal columns', () {
      expect(numFromPostgrest('12.50'), 12.5);
    });

    test('passes a JSON number through unchanged', () {
      expect(numFromPostgrest(7), 7);
    });

    test('throws on null (callers must handle optional columns before calling this)', () {
      expect(() => numFromPostgrest(null), throwsA(isA<TypeError>()));
    });
  });
}
