import 'cached_value.dart';
import 'local_cache.dart';

export 'cached_value.dart';

/// Fetches [key] over the network via [fetchRaw], caches the raw JSON-safe
/// result in [cache], and decodes it with [decode] - reusing the exact same
/// decode step whether the data just came from the network or, on failure,
/// from [cache]. Rethrows if the network call fails AND nothing has been
/// cached for [key] yet.
Future<CachedValue<T>> cachedFetch<T>({
  required LocalCache cache,
  required String key,
  required Future<Object?> Function() fetchRaw,
  required T Function(Object? raw) decode,
  void Function(Object error, StackTrace stackTrace)? onNetworkError,
}) async {
  try {
    final raw = await fetchRaw();
    await cache.putCache(key, raw);
    return CachedValue(decode(raw), fromCache: false);
  } catch (error, stackTrace) {
    onNetworkError?.call(error, stackTrace);
    final cached = await cache.getCache(key);
    if (cached != null) {
      return CachedValue(decode(cached), fromCache: true);
    }
    rethrow;
  }
}
