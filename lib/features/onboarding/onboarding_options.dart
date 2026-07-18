/// Option metadata for the onboarding wizard. Mirrors
/// `nutriflow/src/features/onboarding/options.ts` - keep values, labels and
/// descriptions in sync with that file (it's the source of truth; this is a
/// straight port, not a reinterpretation).
class OnboardingOption {
  const OnboardingOption({required this.value, required this.label, required this.description});

  final String value;
  final String label;
  final String description;
}

const List<OnboardingOption> kGoalOptions = [
  OnboardingOption(
    value: 'lose_fat',
    label: 'Perder grasa',
    description: 'Baja de peso conservando musculo.',
  ),
  OnboardingOption(
    value: 'gain_muscle',
    label: 'Ganar musculo',
    description: 'Crece fuerte con superavit controlado.',
  ),
  OnboardingOption(
    value: 'maintain',
    label: 'Mantener peso',
    description: 'Sosten tu peso y composicion.',
  ),
];

const List<OnboardingOption> kMethodOptions = [
  OnboardingOption(
    value: 'meal_plan',
    label: 'Plan nutricional',
    description: 'NutriFlow arma tus comidas.',
  ),
  OnboardingOption(
    value: 'count_calories',
    label: 'Contar calorias',
    description: 'Registras tu, te guiamos.',
  ),
];

const List<OnboardingOption> kSexOptions = [
  OnboardingOption(value: 'male', label: 'Hombre', description: 'Para calcular tu metabolismo.'),
  OnboardingOption(value: 'female', label: 'Mujer', description: 'Para calcular tu metabolismo.'),
];

const List<OnboardingOption> kActivityOptions = [
  OnboardingOption(
    value: 'sedentary',
    label: 'Mayormente sentado',
    description: 'Escritorio casi todo el dia.',
  ),
  OnboardingOption(
    value: 'light',
    label: 'A veces de pie',
    description: 'Caminas o te mueves algo.',
  ),
  OnboardingOption(
    value: 'active',
    label: 'Mayormente de pie',
    description: 'En movimiento buena parte del dia.',
  ),
  OnboardingOption(
    value: 'very_active',
    label: 'Trabajo fisico',
    description: 'Esfuerzo fisico intenso a diario.',
  ),
];

const List<OnboardingOption> kDietOptions = [
  OnboardingOption(value: 'recommended', label: 'Recomendada', description: 'Balance que arma NutriFlow.'),
  OnboardingOption(
    value: 'high_protein',
    label: 'Alta en proteina',
    description: 'Mas proteina, ideal con pesas.',
  ),
  OnboardingOption(
    value: 'low_carb',
    label: 'Baja en carbos',
    description: 'Menos carbohidratos, mas saciedad.',
  ),
  OnboardingOption(
    value: 'keto',
    label: 'Keto',
    description: 'Carbohidratos muy bajos, grasa alta.',
  ),
];

const List<OnboardingOption> kPaceOptions = [
  OnboardingOption(value: 'slow', label: 'Lento', description: 'Mas comodo y sostenible.'),
  OnboardingOption(
    value: 'recommended',
    label: 'Recomendado',
    description: 'El mejor equilibrio para ti.',
  ),
  OnboardingOption(value: 'fast', label: 'Rapido', description: 'Resultados antes, mayor esfuerzo.'),
];

const List<OnboardingOption> kSuggestionOptions = [
  OnboardingOption(
    value: 'recipes',
    label: 'Recetas completas',
    description: 'Platos listos para preparar.',
  ),
  OnboardingOption(
    value: 'ingredients',
    label: 'Ingredientes sueltos',
    description: 'Tu combinas a tu gusto.',
  ),
  OnboardingOption(value: 'mixed', label: 'Una mezcla', description: 'Recetas e ingredientes.'),
];

const List<OnboardingOption> kFastingOptions = [
  OnboardingOption(value: 'never', label: 'Nunca', description: 'No lo he probado.'),
  OnboardingOption(value: 'tried', label: 'Lo probe', description: 'Lo hice antes, no ahora.'),
  OnboardingOption(value: 'current', label: 'Lo hago', description: 'Ayuno actualmente.'),
  OnboardingOption(value: 'want', label: 'Quiero probarlo', description: 'Me interesa empezar.'),
];

const List<OnboardingOption> kMeasurementUnitsOptions = [
  OnboardingOption(value: 'metric', label: 'Metrico', description: 'kg y cm.'),
  OnboardingOption(value: 'imperial', label: 'Imperial', description: 'lb y ft/in.'),
];
