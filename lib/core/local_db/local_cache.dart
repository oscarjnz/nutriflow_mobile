/// Read-through JSON cache keyed by a caller-chosen string (e.g.
/// 'today_meals', 'goal', 'weight_logs_recent'). Kept as an interface,
/// separate from [DriftLocalCache], so repository/provider logic can be
/// unit-tested against a fake without a real SQLite database - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
abstract class LocalCache {
  Future<void> putCache(String key, Object? jsonEncodable);

  /// Returns the last value stored under [key] (JSON-decoded), or null if
  /// nothing has been cached for it yet.
  Future<Object?> getCache(String key);
}
