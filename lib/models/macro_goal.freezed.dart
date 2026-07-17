// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macro_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MacroGoal {

 int get calorieTarget; int get proteinTarget; int get carbsTarget; int get fatTarget;
/// Create a copy of MacroGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MacroGoalCopyWith<MacroGoal> get copyWith => _$MacroGoalCopyWithImpl<MacroGoal>(this as MacroGoal, _$identity);

  /// Serializes this MacroGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MacroGoal&&(identical(other.calorieTarget, calorieTarget) || other.calorieTarget == calorieTarget)&&(identical(other.proteinTarget, proteinTarget) || other.proteinTarget == proteinTarget)&&(identical(other.carbsTarget, carbsTarget) || other.carbsTarget == carbsTarget)&&(identical(other.fatTarget, fatTarget) || other.fatTarget == fatTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calorieTarget,proteinTarget,carbsTarget,fatTarget);

@override
String toString() {
  return 'MacroGoal(calorieTarget: $calorieTarget, proteinTarget: $proteinTarget, carbsTarget: $carbsTarget, fatTarget: $fatTarget)';
}


}

/// @nodoc
abstract mixin class $MacroGoalCopyWith<$Res>  {
  factory $MacroGoalCopyWith(MacroGoal value, $Res Function(MacroGoal) _then) = _$MacroGoalCopyWithImpl;
@useResult
$Res call({
 int calorieTarget, int proteinTarget, int carbsTarget, int fatTarget
});




}
/// @nodoc
class _$MacroGoalCopyWithImpl<$Res>
    implements $MacroGoalCopyWith<$Res> {
  _$MacroGoalCopyWithImpl(this._self, this._then);

  final MacroGoal _self;
  final $Res Function(MacroGoal) _then;

/// Create a copy of MacroGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calorieTarget = null,Object? proteinTarget = null,Object? carbsTarget = null,Object? fatTarget = null,}) {
  return _then(_self.copyWith(
calorieTarget: null == calorieTarget ? _self.calorieTarget : calorieTarget // ignore: cast_nullable_to_non_nullable
as int,proteinTarget: null == proteinTarget ? _self.proteinTarget : proteinTarget // ignore: cast_nullable_to_non_nullable
as int,carbsTarget: null == carbsTarget ? _self.carbsTarget : carbsTarget // ignore: cast_nullable_to_non_nullable
as int,fatTarget: null == fatTarget ? _self.fatTarget : fatTarget // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MacroGoal].
extension MacroGoalPatterns on MacroGoal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MacroGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MacroGoal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MacroGoal value)  $default,){
final _that = this;
switch (_that) {
case _MacroGoal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MacroGoal value)?  $default,){
final _that = this;
switch (_that) {
case _MacroGoal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int calorieTarget,  int proteinTarget,  int carbsTarget,  int fatTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MacroGoal() when $default != null:
return $default(_that.calorieTarget,_that.proteinTarget,_that.carbsTarget,_that.fatTarget);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int calorieTarget,  int proteinTarget,  int carbsTarget,  int fatTarget)  $default,) {final _that = this;
switch (_that) {
case _MacroGoal():
return $default(_that.calorieTarget,_that.proteinTarget,_that.carbsTarget,_that.fatTarget);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int calorieTarget,  int proteinTarget,  int carbsTarget,  int fatTarget)?  $default,) {final _that = this;
switch (_that) {
case _MacroGoal() when $default != null:
return $default(_that.calorieTarget,_that.proteinTarget,_that.carbsTarget,_that.fatTarget);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MacroGoal implements MacroGoal {
  const _MacroGoal({required this.calorieTarget, required this.proteinTarget, required this.carbsTarget, required this.fatTarget});
  factory _MacroGoal.fromJson(Map<String, dynamic> json) => _$MacroGoalFromJson(json);

@override final  int calorieTarget;
@override final  int proteinTarget;
@override final  int carbsTarget;
@override final  int fatTarget;

/// Create a copy of MacroGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MacroGoalCopyWith<_MacroGoal> get copyWith => __$MacroGoalCopyWithImpl<_MacroGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MacroGoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MacroGoal&&(identical(other.calorieTarget, calorieTarget) || other.calorieTarget == calorieTarget)&&(identical(other.proteinTarget, proteinTarget) || other.proteinTarget == proteinTarget)&&(identical(other.carbsTarget, carbsTarget) || other.carbsTarget == carbsTarget)&&(identical(other.fatTarget, fatTarget) || other.fatTarget == fatTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calorieTarget,proteinTarget,carbsTarget,fatTarget);

@override
String toString() {
  return 'MacroGoal(calorieTarget: $calorieTarget, proteinTarget: $proteinTarget, carbsTarget: $carbsTarget, fatTarget: $fatTarget)';
}


}

/// @nodoc
abstract mixin class _$MacroGoalCopyWith<$Res> implements $MacroGoalCopyWith<$Res> {
  factory _$MacroGoalCopyWith(_MacroGoal value, $Res Function(_MacroGoal) _then) = __$MacroGoalCopyWithImpl;
@override @useResult
$Res call({
 int calorieTarget, int proteinTarget, int carbsTarget, int fatTarget
});




}
/// @nodoc
class __$MacroGoalCopyWithImpl<$Res>
    implements _$MacroGoalCopyWith<$Res> {
  __$MacroGoalCopyWithImpl(this._self, this._then);

  final _MacroGoal _self;
  final $Res Function(_MacroGoal) _then;

/// Create a copy of MacroGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calorieTarget = null,Object? proteinTarget = null,Object? carbsTarget = null,Object? fatTarget = null,}) {
  return _then(_MacroGoal(
calorieTarget: null == calorieTarget ? _self.calorieTarget : calorieTarget // ignore: cast_nullable_to_non_nullable
as int,proteinTarget: null == proteinTarget ? _self.proteinTarget : proteinTarget // ignore: cast_nullable_to_non_nullable
as int,carbsTarget: null == carbsTarget ? _self.carbsTarget : carbsTarget // ignore: cast_nullable_to_non_nullable
as int,fatTarget: null == fatTarget ? _self.fatTarget : fatTarget // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
