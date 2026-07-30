import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../models/weight_log.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/local_cache.dart';
import 'postgrest_numeric.dart';
import 'supabase_bootstrap.dart';

/// Direct-Supabase CRUD for `weight_logs` (CLAUDE.md section 6 - simple
/// CRUD bypasses the Fase 1 REST API, RLS/`app_user_id()` scopes every
/// query, no explicit `user_id` filter needed on reads). Reads go through
/// the local cache, same as `MealLogsRepository` - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
class WeightLogsRepository {
  WeightLogsRepository(this._cache);

  final LocalCache _cache;
  final _uuid = const Uuid();

  static const _cacheKey = 'weight_logs_recent';

  Future<CachedValue<List<WeightLog>>> fetchRecent({int limit = 30}) {
    return cachedFetch<List<WeightLog>>(
      cache: _cache,
      key: _cacheKey,
      fetchRaw: () => supabase
          .from('weight_logs')
          .select()
          .isFilter('deleted_at', null)
          .order('logged_at', ascending: false)
          .limit(limit),
      decode: (raw) => (raw as List).cast<Map<String, dynamic>>().map(_toWeightLog).toList(),
      onNetworkError: (error, stackTrace) =>
          debugPrint('fetchRecent (weight_logs) failed, falling back to cache: $error\n$stackTrace'),
      onCacheWriteError: (error, stackTrace) =>
          debugPrint('fetchRecent (weight_logs) could not update the cache: $error\n$stackTrace'),
    );
  }

  /// Inserts a new entry. `weight_logs.id`/`user_id` have no server default
  /// (unlike tables written through the Fase 1 REST API), so both are
  /// resolved here: `id` client-side (uuid v4), `user_id` via the
  /// `app_user_id()` RPC - the same function the RLS policies use
  /// internally, called instead of duplicating clerk_id -> internal uuid
  /// resolution in Dart.
  Future<void> logWeight({
    required double weightKg,
    double? bodyFatPct,
    double? waistCm,
    double? neckCm,
    double? hipsCm,
    DateTime? loggedAt,
  }) async {
    final userId = await supabase.rpc('app_user_id') as String;
    await supabase.from('weight_logs').insert({
      'id': _uuid.v4(),
      'user_id': userId,
      'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (waistCm != null) 'waist_cm': waistCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      'logged_at': (loggedAt ?? DateTime.now()).toIso8601String(),
    });
  }

  WeightLog _toWeightLog(Map<String, dynamic> row) {
    return WeightLog(
      id: row['id'] as String,
      weightKg: numFromPostgrest(row['weight_kg']).toDouble(),
      bodyFatPct: row['body_fat_pct'] == null ? null : numFromPostgrest(row['body_fat_pct']).toDouble(),
      waistCm: row['waist_cm'] == null ? null : numFromPostgrest(row['waist_cm']).toDouble(),
      neckCm: row['neck_cm'] == null ? null : numFromPostgrest(row['neck_cm']).toDouble(),
      hipsCm: row['hips_cm'] == null ? null : numFromPostgrest(row['hips_cm']).toDouble(),
      loggedAt: DateTime.parse(row['logged_at'] as String),
    );
  }
}
