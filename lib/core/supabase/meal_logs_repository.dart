import 'package:flutter/foundation.dart';

import '../../models/day_meal_entry.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/local_cache.dart';
import 'postgrest_numeric.dart';
import 'supabase_bootstrap.dart';

/// Direct-Supabase reads for `meal_logs`/`meal_items` (CLAUDE.md section 6 -
/// CRUD reads bypass the Fase 1 REST API and rely on RLS/`app_user_id()`
/// for per-user filtering, so no `user_id` filter is added here), read
/// through the local cache (docs/superpowers/specs/2026-07-30-weight-logs-
/// local-cache-design.md) so today's meals still show if the network call
/// fails.
class MealLogsRepository {
  MealLogsRepository(this._cache);

  final LocalCache _cache;

  static const _cacheKey = 'today_meals';

  /// Today's logged meal items (local device day), newest first. Mirrors
  /// `getDayEntries` in `nutriflow/src/repositories/meal-logs.repo.ts`:
  /// same join (meal_items -> meal_logs -> foods), same
  /// `deleted_at is null` + `logged_at` day-range filters.
  Future<CachedValue<List<DayMealEntry>>> fetchTodayEntries() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return cachedFetch<List<DayMealEntry>>(
      cache: _cache,
      key: _cacheKey,
      fetchRaw: () => supabase
          .from('meal_items')
          .select('''
            id,
            meal_log_id,
            quantity_grams,
            calories_snapshot,
            protein_snapshot,
            carbs_snapshot,
            fat_snapshot,
            foods(name_es),
            meal_logs!inner(meal_type, logged_at)
          ''')
          .isFilter('deleted_at', null)
          .isFilter('meal_logs.deleted_at', null)
          .gte('meal_logs.logged_at', dayStart.toIso8601String())
          .lt('meal_logs.logged_at', dayEnd.toIso8601String())
          .order('logged_at', referencedTable: 'meal_logs', ascending: false),
      decode: (raw) => (raw as List).cast<Map<String, dynamic>>().map(_toEntry).toList(),
      onNetworkError: (error, stackTrace) =>
          debugPrint('fetchTodayEntries failed, falling back to cache: $error\n$stackTrace'),
      onCacheWriteError: (error, stackTrace) =>
          debugPrint('fetchTodayEntries could not update the cache: $error\n$stackTrace'),
    );
  }

  DayMealEntry _toEntry(Map<String, dynamic> row) {
    final mealLog = row['meal_logs'] as Map<String, dynamic>;
    final food = row['foods'] as Map<String, dynamic>?;
    return DayMealEntry(
      mealItemId: row['id'] as String,
      mealLogId: row['meal_log_id'] as String,
      foodName: food?['name_es'] as String? ?? 'Alimento',
      mealType: mealLog['meal_type'] as String,
      quantityGrams: numFromPostgrest(row['quantity_grams']),
      calories: numFromPostgrest(row['calories_snapshot']),
      protein: numFromPostgrest(row['protein_snapshot']),
      carbs: numFromPostgrest(row['carbs_snapshot']),
      fat: numFromPostgrest(row['fat_snapshot']),
      loggedAt: DateTime.parse(mealLog['logged_at'] as String),
    );
  }
}
