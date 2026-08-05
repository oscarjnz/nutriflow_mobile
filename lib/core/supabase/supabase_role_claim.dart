import 'dart:convert';

/// Whether [jwt] names the `authenticated` Postgres role.
///
/// Supabase's Third-Party Auth bridge dispatches on the token's `role` claim:
/// PostgREST runs each request as the role the token names, and falls back to
/// `anon` when the claim is missing. Every RLS policy in this project is
/// granted `TO authenticated`, so a Clerk token without
/// `"role": "authenticated"` does not fail - it reads as an anonymous
/// visitor, and every query comes back empty with HTTP 200.
///
/// That silence is what hid the 2026-08-05 bug: meals were written fine
/// through the REST backend (which reaches Postgres directly and never sees
/// RLS) while the dashboard read zero rows and reported no error at all. The
/// claim comes from Clerk's per-instance session token customization, so the
/// client cannot add it - all it can do is refuse to pass the token off as
/// authenticated. See [bootstrapSupabase].
///
/// Returns false for anything unparseable: a token this code cannot read is
/// a token it cannot vouch for.
bool jwtCarriesAuthenticatedRole(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return false;
  try {
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final claims = json.decode(payload);
    return claims is Map<String, dynamic> && claims['role'] == 'authenticated';
  } on FormatException {
    return false;
  }
}
