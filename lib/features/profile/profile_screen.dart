import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/providers.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/radii.dart';
import '../../models/macro_goal.dart';

/// Account and targets. Identity comes from Clerk (the session already in
/// memory, no extra call); the macro targets come from `GET /api/goals`
/// through [goalProvider], which is the same server-computed goal the
/// dashboard compares against - never recomputed here (CLAUDE.md section 2).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final user = ClerkAuth.userOf(context);
    final goal = ref.watch(goalProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Volver',
        ),
        title: const Text('Perfil'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _IdentityCard(
              name: user?.hasName == true ? user!.name : 'Tu cuenta',
              email: user?.email,
              imageUrl: user?.imageUrl,
            ),
            const SizedBox(height: 24),
            Text('Tus metas diarias', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            goal.when(
              data: (cached) => _GoalGrid(goal: cached.value, fromCache: cached.fromCache),
              loading: () => const _GoalPlaceholder(),
              error: (error, stackTrace) {
                debugPrint('[profile] goal failed: $error\n$stackTrace');
                return _InfoTile(
                  icon: LucideIcons.cloudOff,
                  title: 'No pudimos cargar tus metas',
                  subtitle: 'Revisa tu conexion con el servidor de NutriFlow.',
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Seguimiento', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            _ActionTile(
              icon: LucideIcons.scale,
              title: 'Registro de peso',
              subtitle: 'Anota tu peso y composicion corporal',
              onTap: () => context.push('/weight'),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: LucideIcons.calendarDays,
              title: 'Historial por dia',
              subtitle: 'Revisa lo que comiste en cualquier fecha',
              onTap: () => context.push('/calendar'),
            ),
            const SizedBox(height: 24),
            Text('Cuenta', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: semantics.card,
                borderRadius: BorderRadius.circular(NutriFlowRadii.card),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Para cerrar sesion o cambiar tu cuenta, usa el menu de tu '
                    'avatar. Lo maneja Clerk directamente, asi la sesion se '
                    'cierra tambien del lado del servidor.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantics.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: ClerkUserButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.email, required this.imageUrl});

  final String name;
  final String? email;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantics.invertedSurface,
        borderRadius: BorderRadius.circular(NutriFlowRadii.hero),
      ),
      child: Row(
        children: [
          _Avatar(imageUrl: imageUrl, name: name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: semantics.onInvertedSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (email case final email?) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantics.onInvertedSurfaceMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();

    final fallback = Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: semantics.highlight, shape: BoxShape.circle),
      child: Text(
        initial,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: semantics.highlightForeground,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        // A broken avatar must never take the screen down with it.
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[profile] avatar failed to load: $error');
          return fallback;
        },
      ),
    );
  }
}

class _GoalGrid extends StatelessWidget {
  const _GoalGrid({required this.goal, required this.fromCache});

  final MacroGoal goal;
  final bool fromCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GoalTile(
                label: 'CALORIAS',
                value: '${goal.calorieTarget}',
                unit: 'kcal',
                icon: LucideIcons.flame,
                accent: semantics.highlight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GoalTile(
                label: 'PROTEINA',
                value: '${goal.proteinTarget}',
                unit: 'g',
                icon: LucideIcons.beef,
                accent: semantics.macroProtein,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _GoalTile(
                label: 'CARBOS',
                value: '${goal.carbsTarget}',
                unit: 'g',
                icon: LucideIcons.wheat,
                accent: semantics.macroCarbs,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GoalTile(
                label: 'GRASA',
                value: '${goal.fatTarget}',
                unit: 'g',
                icon: LucideIcons.droplet,
                accent: semantics.macroFat,
              ),
            ),
          ],
        ),
        if (fromCache) ...[
          const SizedBox(height: 10),
          _InfoTile(
            icon: LucideIcons.cloudOff,
            title: 'Sin conexion',
            subtitle: 'Estas viendo las ultimas metas guardadas.',
          ),
        ],
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(NutriFlowRadii.nested),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 10),
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: theme.textTheme.headlineMedium),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalPlaceholder extends StatelessWidget {
  const _GoalPlaceholder();

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<NutriFlowSemanticColors>()!;
    return Container(
      height: 180,
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NutriFlowRadii.card),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: semantics.card,
            borderRadius: BorderRadius.circular(NutriFlowRadii.card),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: semantics.muted,
                  borderRadius: BorderRadius.circular(NutriFlowRadii.tile),
                ),
                child: Icon(icon, size: 20, color: semantics.cardForeground),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16)),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: semantics.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: semantics.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});

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
        color: semantics.muted,
        borderRadius: BorderRadius.circular(NutriFlowRadii.nested),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: semantics.mutedForeground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: semantics.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
