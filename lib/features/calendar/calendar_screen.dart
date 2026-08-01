import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/providers.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/radii.dart';
import '../../models/day_meal_entry.dart';
import '../../shared/date_labels.dart';
import '../../shared/meal_type.dart';

/// Month view over the meal history. Picking a day loads that day's real
/// entries and macro totals through [mealEntriesForDayProvider], the same
/// path the dashboard's week strip uses.
///
/// The grid itself is laid out by hand rather than with a calendar package:
/// a month is a fixed 7-column grid with a computed leading offset, and a
/// dependency would cost more in theming work (CLAUDE.md section 5 forbids
/// reinterpreting the design tokens) than it saves.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// Recomputed on every read, never cached in a field: frozen at
  /// construction, an app left open past midnight would keep `_visibleMonth`
  /// on the old month, disable the forward chevron (`_today` still being in
  /// that month) and mark every cell of the new day as future, leaving the
  /// user unable to reach today at all until they leave and re-enter.
  DateTime get _today => startOfDay(DateTime.now());

  late DateTime _selected = _today;

  /// First of the month currently on screen. Kept separate from [_selected]
  /// so paging through months does not move the selection.
  late DateTime _visibleMonth = DateTime(_today.year, _today.month);

  void _stepMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  /// Grid cells for [_visibleMonth]: leading nulls pad the row so the 1st
  /// lands under its real weekday, Monday first.
  List<DateTime?> get _cells {
    final firstDay = _visibleMonth;
    final daysInMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;
    return [
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(firstDay.year, firstDay.month, day),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final entries = ref.watch(mealEntriesForDayProvider(_selected));
    final totals = ref.watch(macroTotalsForDayProvider(_selected));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Volver',
        ),
        title: const Text('Calendario'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _MonthHeader(
              month: _visibleMonth,
              onPrevious: () => _stepMonth(-1),
              // Never page past the current month: there is nothing logged in
              // the future, so an empty grid would just look broken.
              onNext: _visibleMonth.isBefore(DateTime(_today.year, _today.month))
                  ? () => _stepMonth(1)
                  : null,
            ),
            const SizedBox(height: 16),
            const _WeekdayHeader(),
            const SizedBox(height: 8),
            _MonthGrid(
              cells: _cells,
              selected: _selected,
              today: _today,
              onSelect: (day) => setState(() => _selected = day),
            ),
            const SizedBox(height: 24),
            Text(
              isSameDay(_selected, _today) ? 'Hoy' : fullDateLabel(_selected),
              style: theme.textTheme.headlineMedium,
            ),
            // Without this the calendar is the one screen that presents stale
            // cached numbers as current: `CacheEntries` has no TTL, so a day
            // browsed once stays cached indefinitely. The dashboard, profile
            // and fasting screens all surface the same banner.
            if (entries.value?.fromCache ?? false) ...[
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: semantics.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            totals.when(
              data: (value) => _DayTotalsRow(
                calories: value.calories.round(),
                protein: value.protein.round(),
                carbs: value.carbs.round(),
                fat: value.fat.round(),
              ),
              loading: () => const _TotalsPlaceholder(),
              error: (error, _) {
                debugPrint('[calendar] totals failed for ${dayKey(_selected)}: $error');
                return Text(
                  'No se pudieron cargar los totales de ese dia.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: semantics.mutedForeground,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ...entries.when(
              data: (cached) => cached.value.isEmpty
                  ? [
                      _EmptyDay(
                        isFuture: _selected.isAfter(_today),
                      ),
                    ]
                  : [
                      for (final (index, entry) in cached.value.indexed) ...[
                        if (index > 0) const SizedBox(height: 10),
                        _CalendarMealRow(entry: entry),
                      ],
                    ],
              loading: () => [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) {
                debugPrint('[calendar] entries failed for ${dayKey(_selected)}: $error');
                return [
                  Text(
                    'No se pudieron cargar las comidas de ese dia.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: semantics.mutedForeground,
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;

  /// Null disables the control, which is how "you are already on the current
  /// month" is expressed.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: onPrevious,
          tooltip: 'Mes anterior',
        ),
        Expanded(
          child: Text(
            monthYearLabel(month),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.chevronRight),
          onPressed: onNext,
          tooltip: 'Mes siguiente',
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _initials = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    return Row(
      children: [
        for (final initial in _initials)
          Expanded(
            child: Text(
              initial,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: semantics.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.cells,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final List<DateTime?> cells;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) {
        final day = cells[index];
        if (day == null) return const SizedBox.shrink();
        return _DayCell(
          day: day,
          isSelected: isSameDay(day, selected),
          isToday: isSameDay(day, today),
          // Future days hold nothing and are not selectable.
          isEnabled: !day.isAfter(today),
          onTap: () => onSelect(day),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isEnabled,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    final Color background;
    final Color foreground;
    if (isSelected) {
      background = semantics.invertedSurface;
      foreground = semantics.onInvertedSurface;
    } else if (isEnabled) {
      background = semantics.card;
      foreground = semantics.cardForeground;
    } else {
      background = Colors.transparent;
      foreground = semantics.mutedForeground.withValues(alpha: 0.5);
    }

    return Semantics(
      button: isEnabled,
      selected: isSelected,
      label: fullDateLabel(day),
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: NutriFlowMotion.fast,
          curve: NutriFlowMotion.curve,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(NutriFlowRadii.tile),
            border: isSelected
                ? null
                : Border.all(
                    color: isToday
                        ? semantics.highlight
                        : theme.colorScheme.outline.withValues(alpha: isEnabled ? 0.3 : 0.12),
                    width: isToday ? 1.5 : 1,
                  ),
          ),
          child: Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayTotalsRow extends StatelessWidget {
  const _DayTotalsRow({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(NutriFlowRadii.card),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$calories kcal', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              _MacroChip(label: 'P', value: protein, color: semantics.macroProtein),
              const SizedBox(width: 8),
              _MacroChip(label: 'C', value: carbs, color: semantics.macroCarbs),
              const SizedBox(width: 8),
              _MacroChip(label: 'G', value: fat, color: semantics.macroFat),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(NutriFlowRadii.tile),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label $value g',
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsPlaceholder extends StatelessWidget {
  const _TotalsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<NutriFlowSemanticColors>()!;
    return Container(
      height: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: semantics.muted,
        borderRadius: BorderRadius.circular(NutriFlowRadii.card),
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.isFuture});

  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: semantics.muted,
        borderRadius: BorderRadius.circular(NutriFlowRadii.card),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.utensils, size: 28, color: semantics.mutedForeground),
          const SizedBox(height: 10),
          Text(
            isFuture ? 'Ese dia todavia no llega.' : 'No hay comidas registradas ese dia.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _CalendarMealRow extends StatelessWidget {
  const _CalendarMealRow({required this.entry});

  final DayMealEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(NutriFlowRadii.card),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantics.macroProtein.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(NutriFlowRadii.tile),
            ),
            child: Icon(iconForMealType(entry.mealType), color: semantics.macroProtein),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.foodName, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16)),
                Text(
                  '${labelForMealType(entry.mealType)} - ${entry.quantityGrams.round()} g',
                  style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
                ),
              ],
            ),
          ),
          Text('${entry.calories.round()} kcal', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
