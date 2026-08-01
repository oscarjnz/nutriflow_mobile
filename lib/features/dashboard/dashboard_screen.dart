import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/providers.dart';
import '../../core/local_db/cached_fetch.dart';
import '../../core/supabase/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/day_macro_totals.dart';
import '../../models/macro_goal.dart';
import '../../shared/date_labels.dart';
import '../../shared/meal_type.dart';
import '../../shared/widgets/bento_metric_card.dart';
import '../../shared/widgets/floating_nav_bar.dart';
import '../../shared/widgets/hero_card.dart';
import '../../shared/widgets/horizontal_day_selector.dart';

/// Today's totals/entries are wired to real data: [todayMacroTotalsProvider]
/// and [todayMealEntriesProvider] (Supabase direct) for what's been logged,
/// [goalProvider] (Fase 1 REST) for the target. The week strip in
/// [HorizontalDaySelector] is still static scaffolding - there's no
/// per-day-of-week query yet, only "today" (see CLAUDE.md 2026-07-16 audit).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// Midnight of the day being shown. Defaults to today and is what every
  /// read on this screen is keyed by, so tapping the week strip actually
  /// re-queries instead of only moving a highlight.
  late DateTime _selectedDate = startOfDay(DateTime.now());
  int _navIndex = 0;

  /// The seven days of [_selectedDate]'s week, Monday first, computed fresh
  /// on every build. Nothing about the date is baked in at compile time: an
  /// app left open past midnight, or launched on any other day, shows the
  /// correct week (the old hardcoded strip always claimed today was Thursday).
  List<DateTime> get _week {
    final monday = startOfWeek(_selectedDate);
    return [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final today = startOfDay(DateTime.now());
    final isToday = isSameDay(_selectedDate, today);
    final week = _week;

    final goal = ref.watch(goalProvider);
    // Today keeps reading the long-lived providers so the cached-offline
    // behaviour and the post-logging invalidation both keep working; other
    // days go through the autoDispose family.
    final totals = isToday
        ? ref.watch(todayMacroTotalsProvider)
        : ref.watch(macroTotalsForDayProvider(_selectedDate));
    final entries = isToday
        ? ref.watch(todayMealEntriesProvider)
        : ref.watch(mealEntriesForDayProvider(_selectedDate));

    final user = ClerkAuth.userOf(context);
    final greetingName = user?.hasName == true ? user!.firstName ?? user.name : 'Bienvenido';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HOLA DE NUEVO', style: theme.textTheme.labelSmall),
                            const SizedBox(height: 2),
                            Text(
                              greetingName,
                              style: theme.textTheme.headlineLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const ClerkUserButton(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullDateLabel(today),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantics.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 20),
                  HorizontalDaySelector(
                    items: [
                      for (final day in week)
                        DaySelectorItem(
                          label: weekdayInitial(day),
                          value: '${day.day}',
                          status: isSameDay(day, today) ? 'Hoy' : shortDateLabel(day),
                        ),
                    ],
                    selectedIndex: week.indexWhere((d) => isSameDay(d, _selectedDate)),
                    onSelect: (i) => setState(() => _selectedDate = week[i]),
                  ),
                  const SizedBox(height: 20),
                  _DaySummaryCard(
                    goal: goal,
                    totals: totals,
                    date: _selectedDate,
                    isToday: isToday,
                    entriesFromCache: entries.asData?.value.fromCache ?? false,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isToday ? 'Comidas de hoy' : 'Comidas del ${shortDateLabel(_selectedDate)}',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  ...entries.when(
                    data: (cached) => cached.value.isEmpty
                        ? [
                            Text(
                              isToday
                                  ? 'Todavia no registras comidas hoy.'
                                  : 'No registraste comidas ese dia.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: semantics.mutedForeground,
                              ),
                            ),
                          ]
                        : [
                            for (final (index, entry) in cached.value.indexed) ...[
                              if (index > 0) const SizedBox(height: 10),
                              _MealRow(
                                icon: iconForMealType(entry.mealType),
                                title: labelForMealType(entry.mealType),
                                subtitle: '${entry.foodName} - ${entry.calories.round()} kcal',
                              ),
                            ],
                          ],
                    loading: () => [const Center(child: CircularProgressIndicator())],
                    error: (error, _) => [
                      Text(
                        'No se pudieron cargar las comidas de hoy.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FloatingNavBar(
              items: [
                LucideIcons.home,
                LucideIcons.calendarDays,
                LucideIcons.heartPulse,
                LucideIcons.user,
              ],
              currentIndex: _navIndex,
              onTap: (i) async {
                setState(() => _navIndex = i);
                final route = switch (i) {
                  1 => '/calendar',
                  2 => '/weight',
                  3 => '/profile',
                  _ => null,
                };
                if (route == null) return;
                await context.push(route);
                // The tab is a jump-off point, not a persistent section: once
                // the pushed screen pops we are back on the dashboard, so the
                // highlight has to come back with it.
                if (mounted) setState(() => _navIndex = 0);
              },
              fabIcon: LucideIcons.plus,
              onFabTap: () async {
                await context.push('/log');
                ref.invalidate(todayMealEntriesProvider);
                ref.invalidate(mealEntriesForDayProvider(_selectedDate));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  const _DaySummaryCard({
    required this.goal,
    required this.totals,
    required this.date,
    required this.isToday,
    required this.entriesFromCache,
  });

  final AsyncValue<CachedValue<MacroGoal>> goal;
  final AsyncValue<DayMacroTotals> totals;

  /// The day these totals belong to. The goal is the user's standing target,
  /// which is not stored per day, so past days are compared against today's
  /// goal - stated in the UI copy rather than silently implied.
  final DateTime date;
  final bool isToday;

  /// Whether [todayMealEntriesProvider] (which [totals] is derived from)
  /// fell back to the local cache - tracked separately from [goal] since
  /// each read can fail/fall back independently of the other.
  final bool entriesFromCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    if (goal.isLoading || totals.isLoading) {
      return const HeroCard(
        child: SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
      );
    }
    if (goal.hasError || totals.hasError) {
      debugPrint('Dashboard summary load failed: goal=${goal.error} totals=${totals.error}');
      return HeroCard(
        child: Text(
          'No se pudo cargar tu resumen.',
          style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
        ),
      );
    }

    final goalCached = goal.requireValue;
    final goalValue = goalCached.value;
    final totalsValue = totals.requireValue;
    final remaining = goalValue.calorieTarget - totalsValue.calories.round();

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text('🥗', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Resumen de hoy' : 'Resumen del ${shortDateLabel(date)}',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      '${totalsValue.calories.round()} / ${goalValue.calorieTarget} kcal',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: semantics.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: BentoMetricCard(
                  label: 'PROTEINA',
                  value: '${totalsValue.protein.round()} g',
                  icon: LucideIcons.beef,
                  accent: semantics.macroProtein,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BentoMetricCard(
                  label: 'CARBOS',
                  value: '${totalsValue.carbs.round()} g',
                  icon: LucideIcons.wheat,
                  accent: semantics.macroCarbs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BentoMetricCard(
            label: 'GRASA',
            value: '${totalsValue.fat.round()} g',
            icon: LucideIcons.droplet,
            accent: semantics.macroFat,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantics.muted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.sparkles, size: 16, color: semantics.mutedForeground),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    switch ((isToday, remaining > 0)) {
                      (true, true) => 'Te faltan $remaining kcal para tu meta de hoy.',
                      (true, false) => 'Superaste tu meta de hoy por ${-remaining} kcal.',
                      (false, true) => 'Ese dia quedaste $remaining kcal por debajo de tu meta actual.',
                      (false, false) => 'Ese dia superaste tu meta actual por ${-remaining} kcal.',
                    },
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (goalCached.fromCache || entriesFromCache) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: semantics.muted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.cloudOff, size: 16, color: semantics.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexion: mostrando los ultimos datos guardados.',
                      style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantics.macroProtein.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: semantics.macroProtein),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 18)),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Icon(LucideIcons.check, size: 18, color: semantics.mutedForeground),
          ),
        ],
      ),
    );
  }
}
