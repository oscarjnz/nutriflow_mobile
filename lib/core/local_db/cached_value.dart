/// Wraps a value fetched via [cachedFetch] with whether it came from the
/// network just now (`fromCache: false`) or from [LocalCache] because the
/// network call failed (`fromCache: true`). UI reads this to show a
/// non-blocking "offline, showing saved data" notice instead of a hard
/// error (see docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md).
class CachedValue<T> {
  const CachedValue(this.value, {required this.fromCache});

  final T value;
  final bool fromCache;
}
