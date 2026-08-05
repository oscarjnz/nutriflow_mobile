import 'dart:convert';

import 'app_database.dart';
import 'local_cache.dart';

class DriftLocalCache implements LocalCache {
  DriftLocalCache(this._db);

  final AppDatabase _db;

  @override
  Future<void> putCache(String key, Object? jsonEncodable) {
    return _db.into(_db.cacheEntries).insertOnConflictUpdate(
          CacheEntriesCompanion.insert(
            key: key,
            payload: jsonEncode(jsonEncodable),
            fetchedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<Object?> getCache(String key) async {
    final row = await (_db.select(_db.cacheEntries)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    return jsonDecode(row.payload);
  }

  /// Filters in Dart rather than with a SQL `LIKE 'prefix%'`: a Clerk user id
  /// (`user_2abc...`) contains an underscore, which `LIKE` reads as a
  /// single-character wildcard, so the pattern would also match keys that
  /// merely resemble the prefix. Escaping it is possible but easy to get
  /// subtly wrong, and this table holds a handful of rows - one per cached
  /// endpoint - so reading the keys back costs nothing.
  @override
  Future<void> clearExcept(String keyPrefix) async {
    final keys = await (_db.selectOnly(_db.cacheEntries)..addColumns([_db.cacheEntries.key]))
        .map((row) => row.read(_db.cacheEntries.key)!)
        .get();
    final stale = keys.where((key) => !key.startsWith(keyPrefix)).toList();
    if (stale.isEmpty) return;
    await (_db.delete(_db.cacheEntries)..where((t) => t.key.isIn(stale))).go();
  }
}
