import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracted_food.freezed.dart';
part 'extracted_food.g.dart';

/// Mirrors `ExtractedFood` in `nutriflow/src/lib/validation/nlp.ts` - the
/// LLM's raw extraction (name/quantity/unit guess), before catalog matching.
/// `quantity`/`unit` are display-only here: converting them to grams is
/// `lib/nutrition/units.ts` server-side logic (CLAUDE.md §2), not reimplemented
/// in Dart - the user enters grams directly when confirming a log.
@freezed
abstract class ExtractedFood with _$ExtractedFood {
  const factory ExtractedFood({
    required String raw,
    required String name,
    String? nameEn,
    required double quantity,
    required String unit,
    required List<String> queryTerms,
  }) = _ExtractedFood;

  factory ExtractedFood.fromJson(Map<String, dynamic> json) => _$ExtractedFoodFromJson(json);
}
