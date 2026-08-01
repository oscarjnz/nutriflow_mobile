import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/weight_log.dart';
import '../../shared/widgets/hero_card.dart';

/// Body weight tracking (Fase 3). Direct-Supabase CRUD via
/// [WeightLogsRepository] - see
/// docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md.
/// v1 is kg-only (no kg/lb toggle) and has no edit/delete, by design.
class WeightLogScreen extends ConsumerStatefulWidget {
  const WeightLogScreen({super.key});

  @override
  ConsumerState<WeightLogScreen> createState() => _WeightLogScreenState();
}

class _WeightLogScreenState extends ConsumerState<WeightLogScreen> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  final _neckController = TextEditingController();
  final _hipsController = TextEditingController();
  bool _advancedOpen = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  double? _parsePositive(String text, {double max = double.infinity}) {
    if (text.trim().isEmpty) return null;
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0 || value >= max) return null;
    return value;
  }

  Future<void> _submit() async {
    final weightKg = _parsePositive(_weightController.text, max: 500);
    if (weightKg == null) {
      setState(() => _error = 'Ingresa un peso valido en kg (entre 0 y 500).');
      return;
    }
    final bodyFatPct = _parsePositive(_bodyFatController.text, max: 100);
    final waistCm = _parsePositive(_waistController.text);
    final neckCm = _parsePositive(_neckController.text);
    final hipsCm = _parsePositive(_hipsController.text);

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(weightLogsRepositoryProvider).logWeight(
            weightKg: weightKg,
            bodyFatPct: bodyFatPct,
            waistCm: waistCm,
            neckCm: neckCm,
            hipsCm: hipsCm,
          );
      _weightController.clear();
      _bodyFatController.clear();
      _waistController.clear();
      _neckController.clear();
      _hipsController.clear();
      ref.invalidate(recentWeightLogsProvider);
    } catch (e) {
      debugPrint('logWeight failed: $e');
      setState(() => _error = 'No pudimos guardar el registro. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final recent = ref.watch(recentWeightLogsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Peso corporal'),
        actions: [
          IconButton(
            tooltip: 'Ayuno',
            icon: const Icon(LucideIcons.timer),
            onPressed: () => context.push('/fasting'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            recent.when(
              data: (cached) => _LatestWeightCard(entries: cached.value, fromCache: cached.fromCache),
              loading: () => const HeroCard(
                child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              ),
              error: (error, _) => HeroCard(
                child: Text(
                  'No se pudo cargar tu historial de peso.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Registrar peso', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _advancedOpen = !_advancedOpen),
              icon: Icon(_advancedOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown),
              label: const Text('Composicion corporal (opcional)'),
            ),
            if (_advancedOpen) ...[
              TextField(
                controller: _bodyFatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Grasa corporal (%)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _waistController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cintura (cm)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _neckController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cuello (cm)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hipsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cadera (cm)'),
              ),
            ],
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
            const SizedBox(height: 24),
            Text('Historial reciente', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            recent.when(
              data: (cached) => cached.value.isEmpty
                  ? Text(
                      'Todavia no registras tu peso.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                    )
                  : Column(
                      children: [
                        for (final (index, entry) in cached.value.indexed) ...[
                          if (index > 0) const SizedBox(height: 10),
                          _WeightHistoryRow(entry: entry),
                        ],
                      ],
                    ),
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestWeightCard extends StatelessWidget {
  const _LatestWeightCard({required this.entries, required this.fromCache});

  final List<WeightLog> entries;
  final bool fromCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    if (entries.isEmpty) {
      return HeroCard(
        child: Text(
          'Registra tu primer peso para empezar a ver tu progreso.',
          style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
        ),
      );
    }

    final latest = entries.first;
    final previous = entries.length > 1 ? entries[1] : null;
    final delta = previous == null ? null : latest.weightKg - previous.weightKg;

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ultimo registro', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${latest.weightKg.toStringAsFixed(1)} kg', style: theme.textTheme.displaySmall),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              delta == 0
                  ? 'Sin cambio desde el registro anterior.'
                  : '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg desde el registro anterior.',
              style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
            ),
          ],
          if (fromCache) ...[
            const SizedBox(height: 12),
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

class _WeightHistoryRow extends StatelessWidget {
  const _WeightHistoryRow({required this.entry});

  final WeightLog entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final date = entry.loggedAt;
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(formatted, style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground)),
          Text('${entry.weightKg.toStringAsFixed(1)} kg', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
