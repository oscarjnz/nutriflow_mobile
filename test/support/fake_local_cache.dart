import 'package:nutriflow_mobile/core/local_db/local_cache.dart';

/// In-memory [LocalCache] for tests, so cache-dependent logic can be
/// exercised without a real SQLite database - the reason [LocalCache] is an
/// interface at all (docs/superpowers/specs/2026-07-30-weight-logs-local-
/// cache-design.md).
///
/// [store] is exposed so tests can assert on the exact keys written, which is
/// what [ScopedLocalCache]'s guarantees are made of.
class FakeLocalCache implements LocalCache {
  FakeLocalCache({this.putCacheError});

  final Map<String, Object?> store = {};

  /// When set, every [putCache] throws it - used to check that a failed cache
  /// write never costs the caller a freshly fetched value.
  final Object? putCacheError;

  @override
  Future<void> putCache(String key, Object? jsonEncodable) async {
    if (putCacheError != null) throw putCacheError!;
    store[key] = jsonEncodable;
  }

  @override
  Future<Object?> getCache(String key) async => store[key];

  @override
  Future<void> clearExcept(String keyPrefix) async {
    store.removeWhere((key, _) => !key.startsWith(keyPrefix));
  }
}
