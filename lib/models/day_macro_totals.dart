import 'day_meal_entry.dart';

/// Mirrors `DayMacroTotals` in `nutriflow/src/repositories/meal-logs.repo.ts`.
/// Computed client-side from [DayMealEntry] rows rather than a Postgres
/// view/RPC, since none exists yet (see 2026-07-16 audit in CLAUDE.md).
///
/// Hand-written rather than `@freezed` for now - see the doc comment on
/// `models/macro_goal.dart` for why (build_runner is broken on this SDK).
class DayMacroTotals {
  const DayMacroTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory DayMacroTotals.zero() =>
      const DayMacroTotals(calories: 0, protein: 0, carbs: 0, fat: 0);

  final num calories;
  final num protein;
  final num carbs;
  final num fat;

  DayMacroTotals operator +(DayMealEntry entry) => DayMacroTotals(
        calories: calories + entry.calories,
        protein: protein + entry.protein,
        carbs: carbs + entry.carbs,
        fat: fat + entry.fat,
      );
}
