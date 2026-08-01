/// Serializes a [DateTime] for a Postgres `timestamptz` column.
///
/// **Always use this instead of calling `toIso8601String()` directly on a
/// value that is going into the database.**
///
/// Dart only appends the `Z` suffix when the [DateTime] is already UTC. A
/// local `DateTime` serializes to a bare wall-clock literal with no offset at
/// all (`2026-08-01T20:00:00.000`), and Supabase's session `TimeZone` is
/// `UTC`, so Postgres reads that literal as if it were already UTC. For a user
/// in Santo Domingo (UTC-4) that silently stores an instant four hours in the
/// past, and the error is invisible in the row itself - it only shows up when
/// something computes a duration against `now()`.
///
/// Converting to UTC first makes the offset explicit, so the stored instant is
/// the real one regardless of the device's timezone.
String pgTimestamp(DateTime value) => value.toUtc().toIso8601String();
