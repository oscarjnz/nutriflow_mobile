import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/supabase/supabase_role_claim.dart';

String _jwtWith(Map<String, dynamic> claims) {
  String segment(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
  return '${segment({'alg': 'RS256'})}.${segment(claims)}.signature';
}

void main() {
  group('jwtCarriesAuthenticatedRole', () {
    test('accepts a token whose role claim is authenticated', () {
      expect(
        jwtCarriesAuthenticatedRole(
          _jwtWith({'sub': 'user_123', 'role': 'authenticated'}),
        ),
        isTrue,
      );
    });

    test('rejects the shape Clerk emits by default: no role claim at all', () {
      // Verbatim claim set from the production instance on 2026-08-05, minus
      // the signature. PostgREST read this as `anon`, so every RLS-protected
      // query returned zero rows with HTTP 200 and no error surfaced.
      expect(
        jwtCarriesAuthenticatedRole(
          _jwtWith({
            'exp': 1785956741,
            'iat': 1785956681,
            'iss': 'https://clerk.nutriflow.dpdns.org',
            'sid': 'sess_3HTnwzJxcUCrXHyOdjcZPTUgpIz',
            'sts': 'active',
            'sub': 'user_3HTnwyTv7fP25d9QULaXmOhiMZD',
            'v': 2,
          }),
        ),
        isFalse,
      );
    });

    test('rejects a role that is not authenticated', () {
      expect(jwtCarriesAuthenticatedRole(_jwtWith({'role': 'anon'})), isFalse);
    });

    test('rejects tokens it cannot parse', () {
      expect(jwtCarriesAuthenticatedRole(''), isFalse);
      expect(jwtCarriesAuthenticatedRole('not.a.jwt'), isFalse);
      expect(jwtCarriesAuthenticatedRole('only.two'), isFalse);
    });
  });
}
