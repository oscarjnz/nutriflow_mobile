import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/local_db/cached_fetch.dart';

import 'support/fake_local_cache.dart';

void main() {
  group('cachedFetch', () {
    test('caches and returns the network value on success', () async {
      final cache = FakeLocalCache();

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
      final cache = FakeLocalCache();
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
      final cache = FakeLocalCache();

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
      final cache = FakeLocalCache();
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

    test('returns the fresh value when caching it fails, not stale data', () async {
      final cache = FakeLocalCache(putCacheError: Exception('disk full'));

      final result = await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => 99,
        decode: (raw) => raw as int,
      );

      expect(result.value, 99);
      expect(result.fromCache, isFalse);
    });

    test('calls onCacheWriteError, not onNetworkError, when only the cache write fails', () async {
      final cache = FakeLocalCache(putCacheError: Exception('disk full'));
      Object? networkError;
      Object? cacheWriteError;

      final result = await cachedFetch<int>(
        cache: cache,
        key: 'k',
        fetchRaw: () async => 7,
        decode: (raw) => raw as int,
        onNetworkError: (error, stackTrace) => networkError = error,
        onCacheWriteError: (error, stackTrace) => cacheWriteError = error,
      );

      expect(result.value, 7);
      expect(result.fromCache, isFalse);
      expect(networkError, isNull);
      expect(cacheWriteError, isNotNull);
    });

    test('rethrows the network error when the cached value no longer matches decode', () async {
      final cache = FakeLocalCache();
      await cache.putCache('k', {'unexpected': 'shape'});

      expect(
        () => cachedFetch<int>(
          cache: cache,
          key: 'k',
          fetchRaw: () async => throw Exception('network down'),
          decode: (raw) => raw as int, // throws TypeError on a Map
        ),
        throwsException,
      );
    });
  });
}
