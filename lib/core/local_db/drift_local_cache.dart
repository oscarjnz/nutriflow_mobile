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
}
