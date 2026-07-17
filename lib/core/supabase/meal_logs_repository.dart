import '../../models/day_meal_entry.dart';
import 'supabase_bootstrap.dart';

/// Direct-Supabase reads for `meal_logs`/`meal_items` (CLAUDE.md section 6 -
/// CRUD reads bypass the Fase 1 REST API and rely on RLS/`app_user_id()`
/// for per-user filtering, so no `user_id` filter is added here).
class MealLogsRepository {
  const MealLogsRepository();

  /// Today's logged meal items (local device day), newest first. Mirrors
  /// `getDayEntries` in `nutriflow/src/repositories/meal-logs.repo.ts`:
  /// same join (meal_items -> meal_logs -> foods), same
  /// `deleted_at is null` + `logged_at` day-range filters.
  Future<List<DayMealEntry>> fetchTodayEntries() async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final rows = await supabase
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
        .order('logged_at', referencedTable: 'meal_logs', ascending: false);

    return rows.map((row) {
      final mealLog = row['meal_logs'] as Map<String, dynamic>;
      final food = row['foods'] as Map<String, dynamic>?;
      return DayMealEntry(
        mealItemId: row['id'] as String,
        mealLogId: row['meal_log_id'] as String,
        foodName: food?['name_es'] as String? ?? 'Alimento',
        mealType: mealLog['meal_type'] as String,
        quantityGrams: row['quantity_grams'] as num,
        calories: row['calories_snapshot'] as num,
        protein: row['protein_snapshot'] as num,
        carbs: row['carbs_snapshot'] as num,
        fat: row['fat_snapshot'] as num,
        loggedAt: DateTime.parse(mealLog['logged_at'] as String),
      );
    }).toList();
  }
}
