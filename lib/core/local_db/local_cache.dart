/// Read-through JSON cache keyed by a caller-chosen string (e.g.
/// 'today_meals', 'goal', 'weight_logs_recent'). Kept as an interface,
/// separate from [DriftLocalCache], so repository/provider logic can be
/// unit-tested against a fake without a real SQLite database - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
///
/// Implementations store data unattributed: it is [ScopedLocalCache], not
/// this interface, that keeps one account's data out of another's reach.
/// Repositories should always be handed the scoped wrapper.
abstract class LocalCache {
  Future<void> putCache(String key, Object? jsonEncodable);

  /// Returns the last value stored under [key] (JSON-decoded), or null if
  /// nothing has been cached for it yet.
  Future<Object?> getCache(String key);

  /// Deletes every entry whose key does not start with [keyPrefix].
  ///
  /// Exists so [ScopedLocalCache] can drop data belonging to accounts other
  /// than the one currently signed in. Row-level security guards the network,
  /// not this file on disk, so nothing else would ever remove it.
  Future<void> clearExcept(String keyPrefix);
}
