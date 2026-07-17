import 'package:freezed_annotation/freezed_annotation.dart';

import 'parsed_item.dart';

part 'parse_food_result.freezed.dart';
part 'parse_food_result.g.dart';

/// Mirrors `ParseFoodResult` in `nutriflow/src/lib/validation/nlp.ts` -
/// the full response of `POST /api/nlp/parse`.
@freezed
abstract class ParseFoodResult with _$ParseFoodResult {
  const factory ParseFoodResult({
    required List<ParsedItem> items,
    required bool cached,
    required String model,
  }) = _ParseFoodResult;

  factory ParseFoodResult.fromJson(Map<String, dynamic> json) => _$ParseFoodResultFromJson(json);
}
