import 'package:freezed_annotation/freezed_annotation.dart';

import 'day_meal_entry.dart';

part 'day_macro_totals.freezed.dart';

/// Mirrors `DayMacroTotals` in `nutriflow/src/repositories/meal-logs.repo.ts`.
/// Computed client-side from [DayMealEntry] rows rather than a Postgres
/// view/RPC, since none exists yet (see 2026-07-16 audit in CLAUDE.md).
@freezed
abstract class DayMacroTotals with _$DayMacroTotals {
  const DayMacroTotals._();

  const factory DayMacroTotals({
    required num calories,
    required num protein,
    required num carbs,
    required num fat,
  }) = _DayMacroTotals;

  factory DayMacroTotals.zero() =>
      const DayMacroTotals(calories: 0, protein: 0, carbs: 0, fat: 0);

  DayMacroTotals operator +(DayMealEntry entry) => DayMacroTotals(
        calories: calories + entry.calories,
        protein: protein + entry.protein,
        carbs: carbs + entry.carbs,
        fat: fat + entry.fat,
      );
}
