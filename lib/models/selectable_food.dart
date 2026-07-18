import 'package:freezed_annotation/freezed_annotation.dart';

part 'selectable_food.freezed.dart';
part 'selectable_food.g.dart';

/// Mirrors `SelectableFood` in
/// `nutriflow/src/features/onboarding/food-selection.ts`: one catalog food
/// the onboarding wizard's "available foods" step can offer, grouped by
/// [category] (see `food_category.dart` for the category metadata/minimums).
@freezed
abstract class SelectableFood with _$SelectableFood {
  const factory SelectableFood({
    required String id,
    required String nameEs,
    required String category,
  }) = _SelectableFood;

  factory SelectableFood.fromJson(Map<String, dynamic> json) => _$SelectableFoodFromJson(json);
}
