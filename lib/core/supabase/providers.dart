import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/day_macro_totals.dart';
import '../../models/day_meal_entry.dart';
import '../../models/fasting_session.dart';
import '../../models/weight_log.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/providers.dart';
import 'fasting_sessions_repository.dart';
import 'meal_logs_repository.dart';
import 'weight_logs_repository.dart';

final mealLogsRepositoryProvider = Provider<MealLogsRepository>((ref) {
  return MealLogsRepository(ref.watch(localCacheProvider));
});

final todayMealEntriesProvider = FutureProvider<CachedValue<List<DayMealEntry>>>((ref) {
  return ref.watch(mealLogsRepositoryProvider).fetchTodayEntries();
});

/// Derived from [todayMealEntriesProvider] rather than a second query -
/// there's no Postgres view/RPC for daily totals yet (see CLAUDE.md
/// 2026-07-16 audit), so summing the same rows client-side avoids a
/// redundant round trip.
final todayMacroTotalsProvider = Provider<AsyncValue<DayMacroTotals>>((ref) {
  final entries = ref.watch(todayMealEntriesProvider);
  return entries.whenData((cached) {
    return cached.value.fold(DayMacroTotals.zero(), (totals, entry) => totals + entry);
  });
});

final weightLogsRepositoryProvider = Provider<WeightLogsRepository>((ref) {
  return WeightLogsRepository(ref.watch(localCacheProvider));
});

final recentWeightLogsProvider = FutureProvider.autoDispose<CachedValue<List<WeightLog>>>((ref) {
  return ref.watch(weightLogsRepositoryProvider).fetchRecent();
});

final fastingSessionsRepositoryProvider = Provider<FastingSessionsRepository>((ref) {
  return FastingSessionsRepository(ref.watch(localCacheProvider));
});

final activeFastingSessionProvider = FutureProvider.autoDispose<CachedValue<FastingSession?>>((ref) {
  return ref.watch(fastingSessionsRepositoryProvider).fetchActive();
});

final recentFastingSessionsProvider = FutureProvider.autoDispose<CachedValue<List<FastingSession>>>((ref) {
  return ref.watch(fastingSessionsRepositoryProvider).fetchHistory();
});
