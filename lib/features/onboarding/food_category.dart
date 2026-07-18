/// Config for the "available food selection by category" onboarding step.
/// Mirrors `nutriflow/src/features/onboarding/food-selection.ts` verbatim -
/// the server re-validates the submitted selection authoritatively
/// (`completeOnboardingAction`), this is only for client-side gating of the
/// "Continuar" button so the user doesn't submit and get bounced.
class FoodCategoryMeta {
  const FoodCategoryMeta({
    required this.value,
    required this.label,
    required this.hint,
    required this.min,
  });

  final String value;
  final String label;
  final String hint;

  /// Minimum foods the user must pick in this category to continue.
  final int min;
}

const List<FoodCategoryMeta> kFoodCategories = [
  FoodCategoryMeta(value: 'protein', label: 'Proteinas', hint: 'Elige al menos 2.', min: 2),
  FoodCategoryMeta(value: 'grain', label: 'Cereales y almidones', hint: 'Elige al menos 1.', min: 1),
  FoodCategoryMeta(value: 'vegetable', label: 'Verduras', hint: 'Elige al menos 2.', min: 2),
  FoodCategoryMeta(value: 'fruit', label: 'Frutas', hint: 'Elige al menos 1.', min: 1),
  FoodCategoryMeta(value: 'fat', label: 'Grasas saludables', hint: 'Elige al menos 1.', min: 1),
  FoodCategoryMeta(value: 'legume', label: 'Legumbres', hint: 'Opcional.', min: 0),
  FoodCategoryMeta(value: 'dairy', label: 'Lacteos', hint: 'Opcional.', min: 0),
];

/// Whether [selectedIds] satisfies every category minimum, given the
/// [catalog] of selectable foods (id -> category).
bool selectionMeetsMinimums(
  Set<String> selectedIds,
  Map<String, String> catalogCategoryById,
) {
  for (final category in kFoodCategories) {
    if (category.min == 0) continue;
    final count = catalogCategoryById.entries
        .where((e) => e.value == category.value && selectedIds.contains(e.key))
        .length;
    if (count < category.min) return false;
  }
  return true;
}
