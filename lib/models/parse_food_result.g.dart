// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parse_food_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParseFoodResult _$ParseFoodResultFromJson(Map<String, dynamic> json) =>
    _ParseFoodResult(
      items: (json['items'] as List<dynamic>)
          .map((e) => ParsedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cached: json['cached'] as bool,
      model: json['model'] as String,
    );

Map<String, dynamic> _$ParseFoodResultToJson(_ParseFoodResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'cached': instance.cached,
      'model': instance.model,
    };
