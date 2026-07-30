import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/local_db/cached_fetch.dart';
import 'package:nutriflow_mobile/core/local_db/local_cache.dart';

class _FakeLocalCache implements LocalCache {
  final Map<String, Object?> _store = {};

  @override
  Future<void> putCache(String key, Object? jsonEncodable) async {
    _store[key] = jsonEncodable;
  }

  @override
  Future<Object?> getCache(String key) async => _store[key];
}

void main() {
  group('cachedFetch', () {
    test('caches and returns the network value on success', () async {
      final cache = _FakeLocalCache();

      final result = await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => 41,
        decode: (raw) => (raw as int) + 1,
      );

      expect(result.value, 42);
      expect(result.fromCache, isFalse);
      expect(await cache.getCache('k'), 41);
    });

    test('falls back to the cached value when the network call throws', () async {
      final cache = _FakeLocalCache();
      await cache.putCache('k', 41);

      final result = await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => throw Exception('network down'),
        decode: (raw) => (raw as int) + 1,
      );

      expect(result.value, 42);
      expect(result.fromCache, isTrue);
    });

    test('rethrows when the network call throws and nothing is cached', () async {
      final cache = _FakeLocalCache();

      expect(
        () => cachedFetch<int>(
          cache: cache,
          key: 'missing',
          fetchRaw: () async => throw Exception('network down'),
          decode: (raw) => raw as int,
        ),
        throwsException,
      );
    });

    test('calls onNetworkError with the original error before falling back', () async {
      final cache = _FakeLocalCache();
      await cache.putCache('k', 1);
      Object? seenError;

      await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => throw StateError('boom'),
        decode: (raw) => raw as int,
        onNetworkError: (error, stackTrace) => seenError = error,
      );

      expect(seenError, isA<StateError>());
    });
  });
}
