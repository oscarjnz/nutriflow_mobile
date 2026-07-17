import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_meal_entry.freezed.dart';

/// Mirrors `DayEntry` in `nutriflow/src/repositories/meal-logs.repo.ts`:
/// one row per `meal_items` entry, joined to its parent `meal_logs` and
/// `foods` row. Built directly from a Supabase query (see
/// `core/supabase/meal_logs_repository.dart`), not from the REST API -
/// this is CRUD, so it goes through the direct-Supabase path (CLAUDE.md
/// section 6), not a Fase 1 endpoint.
@freezed
abstract class DayMealEntry with _$DayMealEntry {
  const factory DayMealEntry({
    required String mealItemId,
    required String mealLogId,
    required String foodName,
    required String mealType,
    required num quantityGrams,
    required num calories,
    required num protein,
    required num carbs,
    required num fat,
    required DateTime loggedAt,
  }) = _DayMealEntry;
}
