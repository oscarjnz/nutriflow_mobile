// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodSearchResult _$FoodSearchResultFromJson(Map<String, dynamic> json) =>
    _FoodSearchResult(
      id: json['id'] as String,
      origin: json['origin'] as String,
      barcode: json['barcode'] as String?,
      brand: json['brand'] as String?,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
      caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num).toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
      fatPer100g: (json['fatPer100g'] as num).toDouble(),
      defaultServingGrams: (json['defaultServingGrams'] as num?)?.toDouble(),
      defaultServingLabel: json['defaultServingLabel'] as String?,
    );

Map<String, dynamic> _$FoodSearchResultToJson(_FoodSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'origin': instance.origin,
      'barcode': instance.barcode,
      'brand': instance.brand,
      'nameEs': instance.nameEs,
      'nameEn': instance.nameEn,
      'caloriesPer100g': instance.caloriesPer100g,
      'proteinPer100g': instance.proteinPer100g,
      'carbsPer100g': instance.carbsPer100g,
      'fatPer100g': instance.fatPer100g,
      'defaultServingGrams': instance.defaultServingGrams,
      'defaultServingLabel': instance.defaultServingLabel,
    };
