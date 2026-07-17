/// Mirrors `DayEntry` in `nutriflow/src/repositories/meal-logs.repo.ts`:
/// one row per `meal_items` entry, joined to its parent `meal_logs` and
/// `foods` row. Built directly from a Supabase query (see
/// `core/supabase/meal_logs_repository.dart`), not from the REST API -
/// this is CRUD, so it goes through the direct-Supabase path (CLAUDE.md
/// section 6), not a Fase 1 endpoint.
///
/// Hand-written rather than `@freezed` for now - see the doc comment on
/// `models/macro_goal.dart` for why (build_runner is broken on this SDK).
class DayMealEntry {
  const DayMealEntry({
    required this.mealItemId,
    required this.mealLogId,
    required this.foodName,
    required this.mealType,
    required this.quantityGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  final String mealItemId;
  final String mealLogId;
  final String foodName;
  final String mealType;
  final num quantityGrams;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;
  final DateTime loggedAt;
}
