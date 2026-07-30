import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'drift_local_cache.dart';
import 'local_cache.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final localCacheProvider = Provider<LocalCache>((ref) {
  return DriftLocalCache(ref.watch(appDatabaseProvider));
});
