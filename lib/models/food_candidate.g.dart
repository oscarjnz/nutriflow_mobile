// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodCandidate _$FoodCandidateFromJson(Map<String, dynamic> json) =>
    _FoodCandidate(
      foodId: json['foodId'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
      score: (json['score'] as num).toDouble(),
      matchedVia: json['matchedVia'] as String,
    );

Map<String, dynamic> _$FoodCandidateToJson(_FoodCandidate instance) =>
    <String, dynamic>{
      'foodId': instance.foodId,
      'nameEs': instance.nameEs,
      'nameEn': instance.nameEn,
      'score': instance.score,
      'matchedVia': instance.matchedVia,
    };
