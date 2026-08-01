// lib/features/fasting/fasting_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/fasting_session.dart';
import '../../shared/date_labels.dart';
import '../../shared/widgets/hero_card.dart';
import 'fasting_protocols.dart';

/// Fasting timer (Fase 3). Direct-Supabase CRUD via
/// [FastingSessionsRepository] - see
/// docs/superpowers/specs/2026-07-31-fasting-timer-design.md.
/// Streaks are explicitly out of scope for v1.

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  String _protocolId = fastingProtocols.first.id;
  final _customHoursController = TextEditingController();
  final _notesController = TextEditingController();
  bool _starting = false;
  bool _ending = false;
  bool _canceling = false;
  String? _error;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _customHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Runs a 1s ticker only while an active fast is on screen, so the
  /// elapsed-time text advances live without re-querying the provider each
  /// second. Cancelled as soon as there's no active fast, and always in
  /// [dispose].
  void _ensureTicker(bool shouldRun) {
    if (shouldRun && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!shouldRun && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  Future<void> _startFast() async {
    final protocol = fastingProtocols.firstWhere((p) => p.id == _protocolId);
    int? targetHours = protocol.targetHours;
    if (targetHours == null) {
      targetHours = parseCustomTargetHours(_customHoursController.text);
      if (targetHours == null) {
        setState(() => _error = 'Ingresa horas validas para el ayuno personalizado (entre 1 y 72).');
        return;
      }
    }

    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      await ref.read(fastingSessionsRepositoryProvider).startFast(
            protocol: _protocolId,
            targetHours: targetHours,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );
      if (mounted) {
        _notesController.clear();
        _customHoursController.clear();
        ref.invalidate(activeFastingSessionProvider);
        ref.invalidate(recentFastingSessionsProvider);
      }
    } catch (e) {
      debugPrint('startFast failed: $e');
      if (mounted) {
        setState(() => _error = e is StateError ? e.message : 'No pudimos iniciar el ayuno. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _endFast(String id) async {
    setState(() {
      _ending = true;
      _error = null;
    });
    try {
      await ref.read(fastingSessionsRepositoryProvider).endFast(id);
      if (mounted) {
        ref.invalidate(activeFastingSessionProvider);
        ref.invalidate(recentFastingSessionsProvider);
      }
    } catch (e) {
      debugPrint('endFast failed: $e');
      if (mounted) {
        setState(() => _error = 'No pudimos terminar el ayuno. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _ending = false);
    }
  }

  Future<void> _cancelFast(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar ayuno'),
        content: const Text('Se eliminara este registro. Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancelar ayuno')),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!mounted) return;
    setState(() {
      _canceling = true;
      _error = null;
    });
    try {
      await ref.read(fastingSessionsRepositoryProvider).cancelFast(id);
      if (mounted) {
        ref.invalidate(activeFastingSessionProvider);
        ref.invalidate(recentFastingSessionsProvider);
      }
    } catch (e) {
      debugPrint('cancelFast failed: $e');
      if (mounted) {
        setState(() => _error = 'No pudimos cancelar el ayuno. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _canceling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final active = ref.watch(activeFastingSessionProvider);
    final history = ref.watch(recentFastingSessionsProvider);

    // `.value`, not `asData`: during a `ref.invalidate` refresh the state is
    // AsyncLoading with the previous value retained, so `asData` is null even
    // though `.when(data:)` still renders the active card. Keying the ticker
    // off `asData` would cancel and recreate it on every refresh.
    _ensureTicker(active.value?.value != null);

    final fromCache = (active.value?.fromCache ?? false) || (history.value?.fromCache ?? false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ayuno'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            active.when(
              data: (cached) => cached.value == null
                  ? _StartFastCard(
                      protocolId: _protocolId,
                      onProtocolChanged: (id) => setState(() => _protocolId = id),
                      customHoursController: _customHoursController,
                      notesController: _notesController,
                      starting: _starting,
                      error: _error,
                      onSubmit: _startFast,
                    )
                  : _ActiveFastCard(
                      session: cached.value!,
                      ending: _ending,
                      canceling: _canceling,
                      error: _error,
                      onEnd: () => _endFast(cached.value!.id),
                      onCancel: () => _cancelFast(cached.value!.id),
                    ),
              loading: () => const HeroCard(
                child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              ),
              error: (error, _) => HeroCard(
                child: Text(
                  'No se pudo cargar tu estado de ayuno.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                ),
              ),
            ),
            if (fromCache) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: semantics.muted, borderRadius: BorderRadius.circular(16)),
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
            const SizedBox(height: 24),
            Text('Historial reciente', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            history.when(
              data: (cached) => cached.value.isEmpty
                  ? Text(
                      'Todavia no completas ningun ayuno.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                    )
                  : Column(
                      children: [
                        for (final (index, session) in cached.value.indexed) ...[
                          if (index > 0) const SizedBox(height: 10),
                          _FastingHistoryRow(session: session),
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

class _StartFastCard extends StatelessWidget {
  const _StartFastCard({
    required this.protocolId,
    required this.onProtocolChanged,
    required this.customHoursController,
    required this.notesController,
    required this.starting,
    required this.error,
    required this.onSubmit,
  });

  final String protocolId;
  final ValueChanged<String> onProtocolChanged;
  final TextEditingController customHoursController;
  final TextEditingController notesController;
  final bool starting;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = protocolId == 'custom';

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Empezar ayuno', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final protocol in fastingProtocols)
                ChoiceChip(
                  label: Text(protocol.label),
                  selected: protocolId == protocol.id,
                  onSelected: (_) => onProtocolChanged(protocol.id),
                ),
            ],
          ),
          if (isCustom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: customHoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas objetivo (1-72)'),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
          const SizedBox(height: 16),
          if (error != null) ...[
            Text(error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: starting ? null : onSubmit,
            child: starting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Empezar ayuno'),
          ),
        ],
      ),
    );
  }
}

class _ActiveFastCard extends StatelessWidget {
  const _ActiveFastCard({
    required this.session,
    required this.ending,
    required this.canceling,
    required this.error,
    required this.onEnd,
    required this.onCancel,
  });

  final FastingSession session;
  final bool ending;
  final bool canceling;
  final String? error;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final elapsed = DateTime.now().difference(session.startAt);
    final targetSeconds = Duration(hours: session.targetHours).inSeconds;
    final progress = (elapsed.inSeconds / targetSeconds).clamp(0.0, 1.0);
    final protocolLabel = fastingProtocolLabel(session.protocol);

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ayuno en curso - $protocolLabel', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            formatFastingDuration(elapsed),
            // Tabular figures are mandatory here (CLAUDE.md section 5): this
            // is the one number on screen that changes every second, so
            // proportional digits would make it jitter continuously.
            style: theme.textTheme.displaySmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'de ${session.targetHours}h',
            style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 20),
          // Failures from "Terminar"/"Cancelar" have to be rendered here:
          // while a fast is active this card replaces _StartFastCard, which
          // is the only other place that shows the screen's error text.
          if (error != null) ...[
            Text(error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: (ending || canceling) ? null : onEnd,
                  child: ending
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Terminar ayuno'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: (ending || canceling) ? null : onCancel,
                  child: canceling
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FastingHistoryRow extends StatelessWidget {
  const _FastingHistoryRow({required this.session});

  final FastingSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    // fetchHistory() only returns rows where end_at is not null.
    final duration = session.endAt!.difference(session.startAt);
    final protocolLabel = fastingProtocolLabel(session.protocol);

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(protocolLabel, style: theme.textTheme.titleMedium),
              Text(
                shortDateLabel(session.startAt),
                style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
              ),
            ],
          ),
          Text(formatFastingDuration(duration), style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
