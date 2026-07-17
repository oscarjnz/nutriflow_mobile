// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extracted_food.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExtractedFood _$ExtractedFoodFromJson(Map<String, dynamic> json) =>
    _ExtractedFood(
      raw: json['raw'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      queryTerms: (json['queryTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExtractedFoodToJson(_ExtractedFood instance) =>
    <String, dynamic>{
      'raw': instance.raw,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'queryTerms': instance.queryTerms,
    };
