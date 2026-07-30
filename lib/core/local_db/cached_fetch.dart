import 'cached_value.dart';
import 'local_cache.dart';

export 'cached_value.dart';

/// Fetches [key] over the network via [fetchRaw], caches the raw JSON-safe
/// result in [cache], and decodes it with [decode] - reusing the exact same
/// decode step whether the data just came from the network or, on failure,
/// from [cache]. Rethrows if the network call fails AND nothing usable has
/// been cached for [key] yet.
///
/// A fresh, successfully fetched value is never discarded because of a
/// problem writing it to [cache]: that write failure is reported via
/// [onCacheWriteError] and otherwise ignored, since it is not a reason to
/// treat the caller as offline. Likewise, cached JSON that no longer matches
/// [decode]'s expected shape (e.g. after a model change) is treated as if
/// nothing had been cached, rather than surfacing a decode crash in place of
/// the original network error.
Future<CachedValue<T>> cachedFetch<T>({
  required LocalCache cache,
  required String key,
  required Future<Object?> Function() fetchRaw,
  required T Function(Object? raw) decode,
  void Function(Object error, StackTrace stackTrace)? onNetworkError,
  void Function(Object error, StackTrace stackTrace)? onCacheWriteError,
}) async {
  final Object? raw;
  try {
    raw = await fetchRaw();
  } catch (error, stackTrace) {
    onNetworkError?.call(error, stackTrace);
    final cached = await cache.getCache(key);
    if (cached != null) {
      try {
        return CachedValue(decode(cached), fromCache: true);
      } catch (_) {
        // Cached payload no longer matches decode's expected shape; fall
        // through to rethrow the original network error below.
      }
    }
    rethrow;
  }

  final value = decode(raw);
  try {
    await cache.putCache(key, raw);
  } catch (error, stackTrace) {
    onCacheWriteError?.call(error, stackTrace);
  }
  return CachedValue(value, fromCache: false);
}
