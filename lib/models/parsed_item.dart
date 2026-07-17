import 'package:freezed_annotation/freezed_annotation.dart';

import 'extracted_food.dart';
import 'food_candidate.dart';

part 'parsed_item.freezed.dart';
part 'parsed_item.g.dart';

/// Mirrors `ParsedItem` in `nutriflow/src/lib/validation/nlp.ts`: one food
/// mention extracted from the user's text, with its ranked catalog matches.
@freezed
abstract class ParsedItem with _$ParsedItem {
  const factory ParsedItem({
    required ExtractedFood extracted,
    required List<FoodCandidate> candidates,
  }) = _ParsedItem;

  factory ParsedItem.fromJson(Map<String, dynamic> json) => _$ParsedItemFromJson(json);
}
