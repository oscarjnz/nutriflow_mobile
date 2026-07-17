import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/colors.dart';
import '../../shared/widgets/bento_metric_card.dart';
import '../../shared/widgets/floating_nav_bar.dart';
import '../../shared/widgets/hero_card.dart';
import '../../shared/widgets/horizontal_day_selector.dart';

/// First real assembly of the "Sophisticated Playful" visual language.
/// Data below is static scaffolding, NOT wired to Supabase/the REST API yet
/// (core/api and core/supabase clients come next in Fase 2) - this screen
/// exists to validate the theme/component system end to end before wiring
/// real repositories on top of it.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedDay = 3;
  int _navIndex = 0;

  static const _days = [
    DaySelectorItem(label: 'L', value: '', status: ''),
    DaySelectorItem(label: 'M', value: '', status: ''),
    DaySelectorItem(label: 'M', value: '', status: ''),
    DaySelectorItem(label: 'J', value: '1840', status: 'En meta'),
    DaySelectorItem(label: 'V', value: '', status: ''),
    DaySelectorItem(label: 'S', value: '', status: ''),
    DaySelectorItem(label: 'D', value: '', status: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

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
                  HeroCard(
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
                                    '1,840 / 2,200 kcal',
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
                                value: '112 g',
                                icon: LucideIcons.beef,
                                accent: semantics.macroProtein,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: BentoMetricCard(
                                label: 'CARBOS',
                                value: '180 g',
                                icon: LucideIcons.wheat,
                                accent: semantics.macroCarbs,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        BentoMetricCard(
                          label: 'GRASA',
                          value: '58 g',
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
                                  'Te faltan 360 kcal para tu meta de hoy.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Comidas de hoy', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _MealRow(icon: LucideIcons.coffee, title: 'Desayuno', subtitle: 'Avena con fruta'),
                  const SizedBox(height: 10),
                  _MealRow(icon: LucideIcons.utensils, title: 'Almuerzo', subtitle: 'Pollo con arroz'),
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
              onTap: (i) => setState(() => _navIndex = i),
              fabIcon: LucideIcons.plus,
              onFabTap: () {},
            ),
          ],
        ),
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
