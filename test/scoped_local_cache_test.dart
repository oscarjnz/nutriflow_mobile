import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/local_db/cached_fetch.dart';
import 'package:nutriflow_mobile/core/local_db/scoped_local_cache.dart';

import 'support/fake_local_cache.dart';

void main() {
  group('ScopedLocalCache', () {
    test('keeps one account from reading another under the same key', () async {
      final disk = FakeLocalCache();
      await ScopedLocalCache(disk, 'user_a').putCache('goal', {'calories': 2840});

      final asUserB = ScopedLocalCache(disk, 'user_b');

      expect(await asUserB.getCache('goal'), isNull);
    });

    test('each account reads back its own value', () async {
      final disk = FakeLocalCache();
      final asUserA = ScopedLocalCache(disk, 'user_a');
      await asUserA.putCache('goal', 2840);

      // Nobody else has written yet, so A's own value must survive its own
      // purge pass and still be there on a later read.
      expect(await asUserA.getCache('goal'), 2840);

      final asUserB = ScopedLocalCache(disk, 'user_b');
      await asUserB.putCache('goal', 1900);

      expect(await asUserB.getCache('goal'), 1900);
    });

    test('drops the previous account/s entries from disk once another signs in', () async {
      final disk = FakeLocalCache();
      final asUserA = ScopedLocalCache(disk, 'user_a');
      await asUserA.putCache('goal', 2840);
      await asUserA.putCache('fasting_history', ['a note']);
      expect(disk.store, isNotEmpty);

      // The first operation of the next account is what purges, so that a
      // signed-out device keeps its cache but a switched one does not.
      await ScopedLocalCache(disk, 'user_b').getCache('goal');

      expect(disk.store, isEmpty);
    });

    test('purges once per instance, not on every operation', () async {
      final disk = _CountingCache();
      final cache = ScopedLocalCache(disk, 'user_a');

      await cache.putCache('goal', 1);
      await cache.getCache('goal');
      await cache.getCache('today_meals');

      expect(disk.clearExceptCalls, 1);
    });

    test('reads and writes nothing at all while signed out', () async {
      final disk = FakeLocalCache();
      await disk.putCache('goal', 'written by an earlier build');

      final signedOut = ScopedLocalCache(disk, null);
      await signedOut.putCache('goal', 'must not be stored');

      expect(await signedOut.getCache('goal'), isNull);
      // Untouched: a signed-out session neither reads unattributed data nor
      // adds any, and it must not wipe the signed-in user's cache either.
      expect(disk.store['goal'], 'written by an earlier build');
    });

    test('cachedFetch offline fallback does not cross accounts', () async {
      final disk = FakeLocalCache();

      Future<CachedValue<int>> fetchGoal(ScopedLocalCache cache, {required bool online}) {
        return cachedFetch<int>(
          cache: cache,
          key: 'goal',
          fetchRaw: () async => online ? 2840 : throw Exception('offline'),
          decode: (raw) => raw as int,
        );
      }

      await fetchGoal(ScopedLocalCache(disk, 'user_a'), online: true);

      // The regression this whole class exists for: user B, offline, must get
      // an error rather than user A's cached goal.
      await expectLater(
        fetchGoal(ScopedLocalCache(disk, 'user_b'), online: false),
        throwsException,
      );
    });
  });
}

class _CountingCache extends FakeLocalCache {
  int clearExceptCalls = 0;

  @override
  Future<void> clearExcept(String keyPrefix) {
    clearExceptCalls++;
    return super.clearExcept(keyPrefix);
  }
}
