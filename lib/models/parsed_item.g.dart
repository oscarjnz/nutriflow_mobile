// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedItem _$ParsedItemFromJson(Map<String, dynamic> json) => _ParsedItem(
  extracted: ExtractedFood.fromJson(json['extracted'] as Map<String, dynamic>),
  candidates: (json['candidates'] as List<dynamic>)
      .map((e) => FoodCandidate.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ParsedItemToJson(_ParsedItem instance) =>
    <String, dynamic>{
      'extracted': instance.extracted,
      'candidates': instance.candidates,
    };
