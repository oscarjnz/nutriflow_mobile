/// PostgREST serializes Postgres `numeric`/`decimal` columns as JSON
/// strings (not numbers) to avoid float precision loss, so any column of
/// that Postgres type read via direct Supabase access must accept either
/// shape (see CLAUDE.md's 2026-07-17 bitacora entry for the incident this
/// fixed).
num numFromPostgrest(Object? value) => value is String ? num.parse(value) : value as num;
