import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/day_macro_totals.dart';
import '../../models/day_meal_entry.dart';
import 'meal_logs_repository.dart';

final mealLogsRepositoryProvider = Provider<MealLogsRepository>((ref) {
  return const MealLogsRepository();
});

final todayMealEntriesProvider = FutureProvider<List<DayMealEntry>>((ref) {
  return ref.watch(mealLogsRepositoryProvider).fetchTodayEntries();
});

/// Derived from [todayMealEntriesProvider] rather than a second query -
/// there's no Postgres view/RPC for daily totals yet (see CLAUDE.md
/// 2026-07-16 audit), so summing the same rows client-side avoids a
/// redundant round trip.
final todayMacroTotalsProvider = Provider<AsyncValue<DayMacroTotals>>((ref) {
  final entries = ref.watch(todayMealEntriesProvider);
  return entries.whenData((rows) {
    return rows.fold(DayMacroTotals.zero(), (totals, entry) => totals + entry);
  });
});
