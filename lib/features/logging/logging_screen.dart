import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/nutriflow_api.dart';
import '../../core/api/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/parse_food_result.dart';
import '../../models/parsed_item.dart';
import '../../shared/meal_type.dart';

/// Manual logging by typed food description. Flow: type free text ("2 huevos
/// con pan") -> POST /api/nlp/parse extracts food mentions and ranks catalog
/// candidates per mention -> user picks the right candidate + confirms grams
/// per item -> POST /api/logging/log-meal per confirmed item (source: 'nlp').
///
/// Grams stay user-entered rather than derived from the extracted
/// quantity/unit: converting "2 unidades" -> grams is
/// `nutriflow/src/lib/nutrition/units.ts` server-side logic, and there's no
/// endpoint exposing it yet (CLAUDE.md §2 - never reimplement that math here).
class LoggingScreen extends ConsumerStatefulWidget {
  const LoggingScreen({super.key});

  @override
  ConsumerState<LoggingScreen> createState() => _LoggingScreenState();
}

class _ItemSelection {
  String? foodId;
  num grams = 100;
}

class _LoggingScreenState extends ConsumerState<LoggingScreen> {
  final _textController = TextEditingController();
  String _mealType = defaultMealTypeForNow();
  ParseFoodResult? _result;
  final Map<int, _ItemSelection> _selections = {};
  bool _parsing = false;
  bool _logging = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _parsing = true;
      _error = null;
      _result = null;
      _selections.clear();
    });
    try {
      final api = ref.read(nutriFlowApiProvider);
      final result = await api.parseFoodText(text);
      setState(() {
        _result = result;
        for (var i = 0; i < result.items.length; i++) {
          _selections[i] = _ItemSelection();
        }
      });
    } on ApiFailure catch (e) {
      setState(() => _error = 'No pudimos interpretar el texto (${e.error}).');
    } finally {
      setState(() => _parsing = false);
    }
  }

  Future<void> _logAll() async {
    final result = _result;
    if (result == null) return;
    final toLog = _selections.entries.where((e) => e.value.foodId != null).toList();
    if (toLog.isEmpty) return;

    setState(() {
      _logging = true;
      _error = null;
    });
    try {
      final api = ref.read(nutriFlowApiProvider);
      for (final entry in toLog) {
        await api.logMeal(
          foodId: entry.value.foodId!,
          grams: entry.value.grams,
          mealType: _mealType,
          source: 'nlp',
        );
      }
      if (mounted) context.pop();
    } on ApiFailure catch (e) {
      setState(() => _error = 'No pudimos registrar la comida (${e.error}).');
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final result = _result;
    final canLog = _selections.values.any((s) => s.foodId != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar comida'),
        actions: [
          IconButton(
            tooltip: 'Escanear codigo de barras',
            icon: const Icon(LucideIcons.scanLine),
            onPressed: () => context.push('/log/barcode'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // Wrap, not a Row of Expanded: four equal shares of a phone's
            // width cut "Desayuno" to "Desayun" and "Almuerzo" to "Almue".
            // Chips size to their own label here and drop to a second line
            // when they need one.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mealType in kMealTypes)
                  ChoiceChip(
                    label: Text(labelForMealType(mealType)),
                    selected: _mealType == mealType,
                    onSelected: (_) => setState(() => _mealType = mealType),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Que comiste?',
                hintText: 'Ej. 2 huevos revueltos con pan',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _parse(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _parsing ? null : _parse,
              child: _parsing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analizar'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (result != null) ...[
              const SizedBox(height: 24),
              if (result.items.isEmpty)
                Text(
                  'No se detecto ningun alimento en ese texto.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
                ),
              for (var i = 0; i < result.items.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _ParsedItemCard(
                  item: result.items[i],
                  selection: _selections[i]!,
                  onChanged: () => setState(() {}),
                ),
              ],
              if (result.items.isNotEmpty) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: (_logging || !canLog) ? null : _logAll,
                  icon: _logging
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.check),
                  label: const Text('Registrar'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ParsedItemCard extends StatelessWidget {
  const _ParsedItemCard({
    required this.item,
    required this.selection,
    required this.onChanged,
  });

  final ParsedItem item;
  final _ItemSelection selection;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final extracted = item.extracted;
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(extracted.raw, style: theme.textTheme.titleMedium),
          Text(
            'Cantidad detectada: ${extracted.quantity} ${extracted.unit}',
            style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
          ),
          const SizedBox(height: 10),
          if (item.candidates.isEmpty)
            Text(
              'Sin coincidencias en el catalogo.',
              style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final candidate in item.candidates)
                  ChoiceChip(
                    label: Text(candidate.nameEs),
                    selected: selection.foodId == candidate.foodId,
                    onSelected: (_) {
                      selection.foodId = candidate.foodId;
                      onChanged();
                    },
                  ),
              ],
            ),
          if (selection.foodId != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.minus),
                  onPressed: () {
                    selection.grams = (selection.grams - 10).clamp(1, 100000);
                    onChanged();
                  },
                ),
                Expanded(
                  child: Text(
                    '${selection.grams.round()} g',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.plus),
                  onPressed: () {
                    selection.grams = (selection.grams + 10).clamp(1, 100000);
                    onChanged();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
