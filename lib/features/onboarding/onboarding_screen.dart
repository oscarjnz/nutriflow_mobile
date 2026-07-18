import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/nutriflow_api.dart';
import '../../core/api/providers.dart';
import '../../core/theme/colors.dart';
import '../../models/selectable_food.dart';
import 'food_category.dart';
import 'onboarding_options.dart';

/// Onboarding wizard (Fase 3): body/goal/activity/diet questions plus the
/// mandatory "available foods" step, then `POST /api/onboarding/complete`
/// (the deterministic body-plan calculation, active goal and initial meal
/// plan all run server-side, CLAUDE.md §2). Mirrors
/// `nutriflow/src/app/onboarding/onboarding-client.tsx` field-for-field,
/// just grouped into fewer steps for a mobile-sized wizard.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Answers {
  String recordName = '';
  String sex = 'male';
  int age = 25;
  double heightCm = 170;
  double weightKg = 70;
  String measurementUnits = 'metric';

  String goal = 'lose_fat';
  double targetWeightKg = 65;
  String pace = 'recommended';

  String activityLevel = 'sedentary';
  int trainingDays = 0;
  bool strengthTraining = false;
  String method = 'meal_plan';
  String diet = 'recommended';

  int mealsPerDay = 3;
  int mainMeals = 3;
  String suggestionStyle = 'mixed';
  String intermittentFasting = 'never';
  String hardest = '';
  String extraGoal = '';

  final Set<String> selectedFoodIds = {};
}

const int _kStepCount = 5;

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _answers = _Answers();
  int _step = 0;
  bool _submitting = false;
  String? _error;

  List<SelectableFood>? _foods;
  bool _loadingFoods = false;
  String? _foodsError;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _loadingFoods = true;
      _foodsError = null;
    });
    try {
      final api = ref.read(nutriFlowApiProvider);
      final foods = await api.getSelectableFoods();
      setState(() => _foods = foods);
    } on ApiFailure catch (e) {
      setState(() => _foodsError = 'No pudimos cargar el catalogo de alimentos (${e.error}).');
    } finally {
      setState(() => _loadingFoods = false);
    }
  }

  bool get _canSubmitFoods {
    final foods = _foods;
    if (foods == null) return false;
    final categoryById = {for (final f in foods) f.id: f.category};
    return selectionMeetsMinimums(_answers.selectedFoodIds, categoryById);
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(nutriFlowApiProvider);
      await api.completeOnboarding({
        'recordName': _answers.recordName.trim(),
        'goal': _answers.goal,
        'method': _answers.method,
        'sex': _answers.sex,
        'age': _answers.age,
        'heightCm': _answers.heightCm,
        'weightKg': _answers.weightKg,
        'targetWeightKg': _answers.targetWeightKg,
        'pace': _answers.pace,
        'activityLevel': _answers.activityLevel,
        'trainingDays': _answers.trainingDays,
        'strengthTraining': _answers.strengthTraining,
        'diet': _answers.diet,
        'measurementUnits': _answers.measurementUnits,
        'mealsPerDay': _answers.mealsPerDay,
        'mainMeals': _answers.mainMeals,
        'suggestionStyle': _answers.suggestionStyle,
        'foodSelections': _answers.selectedFoodIds.toList(),
        'intermittentFasting': _answers.intermittentFasting,
        if (_answers.hardest.trim().isNotEmpty) 'hardest': _answers.hardest.trim(),
        if (_answers.extraGoal.trim().isNotEmpty) 'extraGoal': _answers.extraGoal.trim(),
      });
      ref.invalidate(onboardingStatusProvider);
      ref.invalidate(goalProvider);
      if (mounted) context.go('/');
    } on ApiFailure catch (e) {
      setState(() => _error = 'No pudimos guardar tu plan (${e.error}).');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _answers.recordName.trim().isNotEmpty;
      case 4:
        return _canSubmitFoods;
      default:
        return true;
    }
  }

  void _next() {
    if (_step == _kStepCount - 1) {
      _submit();
      return;
    }
    setState(() => _step += 1);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a NutriFlow'),
        leading: _step == 0
            ? null
            : IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: _submitting ? null : _back),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: LinearProgressIndicator(value: (_step + 1) / _kStepCount),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  switch (_step) {
                    0 => _ProfileStep(answers: _answers, onChanged: () => setState(() {})),
                    1 => _GoalStep(answers: _answers, onChanged: () => setState(() {})),
                    2 => _ActivityStep(answers: _answers, onChanged: () => setState(() {})),
                    3 => _PlanStep(answers: _answers, onChanged: () => setState(() {})),
                    _ => _FoodsStep(
                        answers: _answers,
                        foods: _foods,
                        loading: _loadingFoods,
                        error: _foodsError,
                        onRetry: _loadFoods,
                        onChanged: () => setState(() {}),
                      ),
                  },
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: FilledButton(
                onPressed: (_submitting || !_canAdvance) ? null : _next,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_step == _kStepCount - 1 ? 'Terminar' : 'Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

/// Selectable card for a single [OnboardingOption] - label + short
/// description, matching the wizard's option-picker fields (goal, method,
/// sex, activity, diet, pace, suggestionStyle, intermittentFasting).
class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option, required this.selected, required this.onTap});

  final OnboardingOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary.withValues(alpha: 0.1) : semantics.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: theme.textTheme.titleMedium),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(LucideIcons.circleCheck, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  final String label;
  final num value;
  final ValueChanged<num> onChanged;
  final num min;
  final num max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          IconButton(
            icon: const Icon(LucideIcons.circleMinus),
            onPressed: () => onChanged((value - 1).clamp(min, max)),
          ),
          SizedBox(
            width: 48,
            child: Text(
              value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.circlePlus),
            onPressed: () => onChanged((value + 1).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.answers, required this.onChanged});

  final _Answers answers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Tu perfil'),
        TextFormField(
          initialValue: answers.recordName,
          decoration: const InputDecoration(labelText: 'Como te llamamos?'),
          onChanged: (v) {
            answers.recordName = v;
            onChanged();
          },
        ),
        const SizedBox(height: 20),
        Text('Sexo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kSexOptions)
          _OptionCard(
            option: o,
            selected: answers.sex == o.value,
            onTap: () {
              answers.sex = o.value;
              onChanged();
            },
          ),
        const SizedBox(height: 12),
        _NumberField(
          label: 'Edad',
          value: answers.age,
          min: 14,
          max: 100,
          onChanged: (v) {
            answers.age = v.toInt();
            onChanged();
          },
        ),
        _NumberField(
          label: 'Altura (cm)',
          value: answers.heightCm,
          min: 100,
          max: 250,
          onChanged: (v) {
            answers.heightCm = v.toDouble();
            onChanged();
          },
        ),
        _NumberField(
          label: 'Peso (kg)',
          value: answers.weightKg,
          min: 30,
          max: 350,
          onChanged: (v) {
            answers.weightKg = v.toDouble();
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        Text('Unidades', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kMeasurementUnitsOptions)
          _OptionCard(
            option: o,
            selected: answers.measurementUnits == o.value,
            onTap: () {
              answers.measurementUnits = o.value;
              onChanged();
            },
          ),
      ],
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.answers, required this.onChanged});

  final _Answers answers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Tu meta'),
        for (final o in kGoalOptions)
          _OptionCard(
            option: o,
            selected: answers.goal == o.value,
            onTap: () {
              answers.goal = o.value;
              onChanged();
            },
          ),
        const SizedBox(height: 12),
        _NumberField(
          label: 'Peso objetivo (kg)',
          value: answers.targetWeightKg,
          min: 30,
          max: 350,
          onChanged: (v) {
            answers.targetWeightKg = v.toDouble();
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        Text('Ritmo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kPaceOptions)
          _OptionCard(
            option: o,
            selected: answers.pace == o.value,
            onTap: () {
              answers.pace = o.value;
              onChanged();
            },
          ),
      ],
    );
  }
}

class _ActivityStep extends StatelessWidget {
  const _ActivityStep({required this.answers, required this.onChanged});

  final _Answers answers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Actividad y dieta'),
        Text('Nivel de actividad', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kActivityOptions)
          _OptionCard(
            option: o,
            selected: answers.activityLevel == o.value,
            onTap: () {
              answers.activityLevel = o.value;
              onChanged();
            },
          ),
        const SizedBox(height: 12),
        _NumberField(
          label: 'Dias de entrenamiento/semana',
          value: answers.trainingDays,
          min: 0,
          max: 7,
          onChanged: (v) {
            answers.trainingDays = v.toInt();
            onChanged();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Entrenamiento de fuerza'),
          value: answers.strengthTraining,
          onChanged: (v) {
            answers.strengthTraining = v;
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        Text('Metodo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kMethodOptions)
          _OptionCard(
            option: o,
            selected: answers.method == o.value,
            onTap: () {
              answers.method = o.value;
              onChanged();
            },
          ),
        const SizedBox(height: 12),
        Text('Dieta', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kDietOptions)
          _OptionCard(
            option: o,
            selected: answers.diet == o.value,
            onTap: () {
              answers.diet = o.value;
              onChanged();
            },
          ),
      ],
    );
  }
}

class _PlanStep extends StatelessWidget {
  const _PlanStep({required this.answers, required this.onChanged});

  final _Answers answers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Tu plan de comidas'),
        _NumberField(
          label: 'Comidas por dia',
          value: answers.mealsPerDay,
          min: 1,
          max: 8,
          onChanged: (v) {
            answers.mealsPerDay = v.toInt();
            if (answers.mainMeals > answers.mealsPerDay) answers.mainMeals = answers.mealsPerDay;
            onChanged();
          },
        ),
        _NumberField(
          label: 'Comidas principales',
          value: answers.mainMeals,
          min: 1,
          max: answers.mealsPerDay,
          onChanged: (v) {
            answers.mainMeals = v.toInt();
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        Text('Estilo de sugerencias', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kSuggestionOptions)
          _OptionCard(
            option: o,
            selected: answers.suggestionStyle == o.value,
            onTap: () {
              answers.suggestionStyle = o.value;
              onChanged();
            },
          ),
        const SizedBox(height: 12),
        Text('Ayuno intermitente', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in kFastingOptions)
          _OptionCard(
            option: o,
            selected: answers.intermittentFasting == o.value,
            onTap: () {
              answers.intermittentFasting = o.value;
              onChanged();
            },
          ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: answers.hardest,
          decoration: const InputDecoration(labelText: 'Que es lo mas dificil para ti? (opcional)'),
          onChanged: (v) => answers.hardest = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: answers.extraGoal,
          decoration: const InputDecoration(labelText: 'Otra meta? (opcional)'),
          onChanged: (v) => answers.extraGoal = v,
        ),
      ],
    );
  }
}

class _FoodsStep extends StatelessWidget {
  const _FoodsStep({
    required this.answers,
    required this.foods,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onChanged,
  });

  final _Answers answers;
  final List<SelectableFood>? foods;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<NutriFlowSemanticColors>()!;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('Alimentos disponibles'),
          Text(error!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      );
    }

    final byCategory = <String, List<SelectableFood>>{};
    for (final food in foods ?? const <SelectableFood>[]) {
      byCategory.putIfAbsent(food.category, () => []).add(food);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Alimentos disponibles'),
        Text(
          'Elige lo que sueles tener a mano - NutriFlow arma tu plan con esto.',
          style: theme.textTheme.bodyMedium?.copyWith(color: semantics.mutedForeground),
        ),
        for (final category in kFoodCategories) ...[
          const SizedBox(height: 20),
          Text(category.label, style: theme.textTheme.titleMedium),
          Text(
            category.hint,
            style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedForeground),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final food in byCategory[category.value] ?? const <SelectableFood>[])
                FilterChip(
                  label: Text(food.nameEs),
                  selected: answers.selectedFoodIds.contains(food.id),
                  onSelected: (selected) {
                    if (selected) {
                      answers.selectedFoodIds.add(food.id);
                    } else {
                      answers.selectedFoodIds.remove(food.id);
                    }
                    onChanged();
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}
