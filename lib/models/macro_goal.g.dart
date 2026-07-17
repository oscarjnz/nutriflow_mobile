// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MacroGoal _$MacroGoalFromJson(Map<String, dynamic> json) => _MacroGoal(
  calorieTarget: (json['calorieTarget'] as num).toInt(),
  proteinTarget: (json['proteinTarget'] as num).toInt(),
  carbsTarget: (json['carbsTarget'] as num).toInt(),
  fatTarget: (json['fatTarget'] as num).toInt(),
);

Map<String, dynamic> _$MacroGoalToJson(_MacroGoal instance) =>
    <String, dynamic>{
      'calorieTarget': instance.calorieTarget,
      'proteinTarget': instance.proteinTarget,
      'carbsTarget': instance.carbsTarget,
      'fatTarget': instance.fatTarget,
    };
