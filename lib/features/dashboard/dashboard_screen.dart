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
  int _selectedDay = 3;
  int _navIndex = 0;

  static const _days = [
    DaySelectorItem(label: 'L', value: '', status: ''),
    DaySelectorItem(label: 'M', value: '', status: ''),
    DaySelectorItem(label: 'M', value: '', status: ''),
    DaySelectorItem(label: 'J', value: '', status: 'Hoy'),
    DaySelectorItem(label: 'V', value: '', status: ''),
    DaySelectorItem(label: 'S', value: '', status: ''),
    DaySelectorItem(label: 'D', value: '', status: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final goal = ref.watch(goalProvider);
    final totals = ref.watch(todayMacroTotalsProvider);
    final entries = ref.watch(todayMealEntriesProvider);

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HOLA DE NUEVO', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 2),
                          Text('Oscar', style: theme.textTheme.headlineLarge),
                        ],
                      ),
                      const ClerkUserButton(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  HorizontalDaySelector(
                    items: _days,
                    selectedIndex: _selectedDay,
                    onSelect: (i) => setState(() => _selectedDay = i),
                  ),
                  const SizedBox(height: 20),
                  _TodaySummaryCard(goal: goal, totals: totals),
                  const SizedBox(height: 24),
                  Text('Comidas de hoy', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  ...entries.when(
                    data: (cached) => cached.value.isEmpty
                        ? [
                            Text(
                              'Todavia no registras comidas hoy.',
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
              onTap: (i) {
                setState(() => _navIndex = i);
                if (i == 2) {
                  context.push('/weight');
                }
              },
              fabIcon: LucideIcons.plus,
              onFabTap: () async {
                await context.push('/log');
                ref.invalidate(todayMealEntriesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({required this.goal, required this.totals});

  final AsyncValue<CachedValue<MacroGoal>> goal;
  final AsyncValue<DayMacroTotals> totals;

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
          'No se pudo cargar tu resumen de hoy.',
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
                    Text('Resumen de hoy', style: theme.textTheme.headlineMedium),
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
                    remaining > 0
                        ? 'Te faltan $remaining kcal para tu meta de hoy.'
                        : 'Superaste tu meta de hoy por ${-remaining} kcal.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (goalCached.fromCache) ...[
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
