import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'app_database.dart';
import 'drift_local_cache.dart';
import 'local_cache.dart';
import 'scoped_local_cache.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The cache every repository and cached provider must read through.
///
/// Watching [currentUserIdProvider] is what keeps cached data from crossing
/// accounts, on two fronts at once. On disk, the returned [ScopedLocalCache]
/// namespaces its keys by user. In memory, the watch makes this provider - and
/// therefore the whole graph built on it, repositories and cached
/// `FutureProvider`s alike - rebuild when the signed-in user changes, so no
/// already-loaded value survives into another account's session. Nothing here
/// needs to know which providers those are, which is the point.
final localCacheProvider = Provider<LocalCache>((ref) {
  final delegate = DriftLocalCache(ref.watch(appDatabaseProvider));
  return ScopedLocalCache(delegate, ref.watch(currentUserIdProvider));
});
