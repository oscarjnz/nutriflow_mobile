import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Matches `mealTypeSchema` in `nutriflow/src/lib/validation/meal.ts` -
/// keep values in sync with that enum.
const List<String> kMealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

IconData iconForMealType(String mealType) {
  return switch (mealType) {
    'breakfast' => LucideIcons.coffee,
    'lunch' => LucideIcons.utensils,
    'dinner' => LucideIcons.utensilsCrossed,
    _ => LucideIcons.cookie,
  };
}

String labelForMealType(String mealType) {
  return switch (mealType) {
    'breakfast' => 'Desayuno',
    'lunch' => 'Almuerzo',
    'dinner' => 'Cena',
    _ => 'Snack',
  };
}

/// Same time-of-day heuristic as `defaultMealType` in
/// `nutriflow/src/app/(dashboard)/log/log-client.tsx`.
String defaultMealTypeForNow() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'breakfast';
  if (hour < 16) return 'lunch';
  if (hour < 21) return 'dinner';
  return 'snack';
}
