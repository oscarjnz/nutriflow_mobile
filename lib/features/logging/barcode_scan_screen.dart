import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/api/nutriflow_api.dart';
import '../../core/api/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/food_search_result.dart';
import '../../shared/meal_type.dart';

/// Barcode-scan logging (Fase 3.5). Flow: point the camera at a product's
/// EAN/UPC barcode -> POST /api/foods/barcode-lookup resolves it against
/// Open Food Facts (importing into the catalog server-side if new) ->
/// confirm grams and meal type -> POST /api/logging/log-meal
/// (source: 'barcode'). Mirrors LoggingScreen's confirm/log step; the only
/// new part is the camera capture replacing free-text + NLP.
class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _looking = false;
  String? _error;
  FoodSearchResult? _food;
  num _grams = 100;
  String _mealType = defaultMealTypeForNow();
  bool _logging = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_looking || _food != null) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    setState(() {
      _looking = true;
      _error = null;
    });
    unawaited(_scannerController.stop());
    try {
      final api = ref.read(nutriFlowApiProvider);
      final food = await api.lookupBarcode(raw);
      setState(() {
        _food = food;
        _grams = food.defaultServingGrams ?? 100;
      });
    } on ApiFailure catch (e) {
      setState(() => _error = e.error);
      unawaited(_scannerController.start());
    } finally {
      setState(() => _looking = false);
    }
  }

  Future<void> _logFood() async {
    final food = _food;
    if (food == null) return;

    setState(() {
      _logging = true;
      _error = null;
    });
    try {
      final api = ref.read(nutriFlowApiProvider);
      await api.logMeal(
        foodId: food.id,
        grams: _grams,
        mealType: _mealType,
        source: 'barcode',
      );
      if (mounted) context.pop();
    } on ApiFailure catch (e) {
      setState(() => _error = 'No pudimos registrar la comida (${e.error}).');
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  void _scanAgain() {
    setState(() {
      _food = null;
      _error = null;
      _grams = 100;
    });
    unawaited(_scannerController.start());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;
    final food = _food;

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear codigo de barras')),
      body: SafeArea(
        child: food == null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(controller: _scannerController, onDetect: _onDetect),
                  if (_looking)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  if (_error != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.onErrorContainer),
                        ),
                      ),
                    ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: semantics.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.nameEs, style: theme.textTheme.titleMedium),
                        if (food.brand != null)
                          Text(
                            food.brand!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: semantics.mutedForeground),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${food.caloriesPer100g.round()} kcal por 100 g',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: semantics.mutedForeground),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.minus),
                              onPressed: () => setState(
                                () => _grams = (_grams - 10).clamp(1, 100000),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${_grams.round()} g',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.plus),
                              onPressed: () => setState(
                                () => _grams = (_grams + 10).clamp(1, 100000),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (final mealType in kMealTypes) ...[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(labelForMealType(mealType)),
                              selected: _mealType == mealType,
                              onSelected: (_) => setState(() => _mealType = mealType),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _logging ? null : _scanAgain,
                          child: const Text('Escanear otro'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _logging ? null : _logFood,
                          icon: _logging
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(LucideIcons.check),
                          label: const Text('Registrar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
