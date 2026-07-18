import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_search_result.freezed.dart';
part 'food_search_result.g.dart';

/// Mirrors `FoodSearchResult` in `nutriflow/src/repositories/foods.repo.ts`:
/// a fully-resolved catalog food with per-100g macros, returned by
/// `POST /api/foods/barcode-lookup` (and reusable for a future free-text
/// food search endpoint - CLAUDE.md §8 Fase 3.5).
@freezed
abstract class FoodSearchResult with _$FoodSearchResult {
  const factory FoodSearchResult({
    /// Local catalog rows carry their UUID; an OFF hit not yet imported into
    /// the catalog cannot reach this model at all - the barcode-lookup
    /// endpoint always imports before returning (see `lookupBarcodeAction`).
    required String id,
    required String origin,
    String? barcode,
    String? brand,
    required String nameEs,
    required String nameEn,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double? defaultServingGrams,
    String? defaultServingLabel,
  }) = _FoodSearchResult;

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) =>
      _$FoodSearchResultFromJson(json);
}
