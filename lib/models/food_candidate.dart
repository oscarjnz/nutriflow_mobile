import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_candidate.freezed.dart';
part 'food_candidate.g.dart';

/// Mirrors `FoodCandidate` in `nutriflow/src/lib/validation/nlp.ts`: one
/// ranked catalog match for a single parsed food item.
@freezed
abstract class FoodCandidate with _$FoodCandidate {
  const factory FoodCandidate({
    required String foodId,
    required String nameEs,
    required String nameEn,
    required double score,
    required String matchedVia,
  }) = _FoodCandidate;

  factory FoodCandidate.fromJson(Map<String, dynamic> json) => _$FoodCandidateFromJson(json);
}
