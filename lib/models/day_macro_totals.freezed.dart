// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_macro_totals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayMacroTotals {

 num get calories; num get protein; num get carbs; num get fat;
/// Create a copy of DayMacroTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayMacroTotalsCopyWith<DayMacroTotals> get copyWith => _$DayMacroTotalsCopyWithImpl<DayMacroTotals>(this as DayMacroTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayMacroTotals&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat));
}


@override
int get hashCode => Object.hash(runtimeType,calories,protein,carbs,fat);

@override
String toString() {
  return 'DayMacroTotals(calories: $calories, protein: $protein, carbs: $carbs, fat: $fat)';
}


}

/// @nodoc
abstract mixin class $DayMacroTotalsCopyWith<$Res>  {
  factory $DayMacroTotalsCopyWith(DayMacroTotals value, $Res Function(DayMacroTotals) _then) = _$DayMacroTotalsCopyWithImpl;
@useResult
$Res call({
 num calories, num protein, num carbs, num fat
});




}
/// @nodoc
class _$DayMacroTotalsCopyWithImpl<$Res>
    implements $DayMacroTotalsCopyWith<$Res> {
  _$DayMacroTotalsCopyWithImpl(this._self, this._then);

  final DayMacroTotals _self;
  final $Res Function(DayMacroTotals) _then;

/// Create a copy of DayMacroTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,}) {
  return _then(_self.copyWith(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as num,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as num,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as num,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [DayMacroTotals].
extension DayMacroTotalsPatterns on DayMacroTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayMacroTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayMacroTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayMacroTotals value)  $default,){
final _that = this;
switch (_that) {
case _DayMacroTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayMacroTotals value)?  $default,){
final _that = this;
switch (_that) {
case _DayMacroTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num calories,  num protein,  num carbs,  num fat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayMacroTotals() when $default != null:
return $default(_that.calories,_that.protein,_that.carbs,_that.fat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num calories,  num protein,  num carbs,  num fat)  $default,) {final _that = this;
switch (_that) {
case _DayMacroTotals():
return $default(_that.calories,_that.protein,_that.carbs,_that.fat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num calories,  num protein,  num carbs,  num fat)?  $default,) {final _that = this;
switch (_that) {
case _DayMacroTotals() when $default != null:
return $default(_that.calories,_that.protein,_that.carbs,_that.fat);case _:
  return null;

}
}

}

/// @nodoc


class _DayMacroTotals extends DayMacroTotals {
  const _DayMacroTotals({required this.calories, required this.protein, required this.carbs, required this.fat}): super._();
  

@override final  num calories;
@override final  num protein;
@override final  num carbs;
@override final  num fat;

/// Create a copy of DayMacroTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayMacroTotalsCopyWith<_DayMacroTotals> get copyWith => __$DayMacroTotalsCopyWithImpl<_DayMacroTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayMacroTotals&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat));
}


@override
int get hashCode => Object.hash(runtimeType,calories,protein,carbs,fat);

@override
String toString() {
  return 'DayMacroTotals(calories: $calories, protein: $protein, carbs: $carbs, fat: $fat)';
}


}

/// @nodoc
abstract mixin class _$DayMacroTotalsCopyWith<$Res> implements $DayMacroTotalsCopyWith<$Res> {
  factory _$DayMacroTotalsCopyWith(_DayMacroTotals value, $Res Function(_DayMacroTotals) _then) = __$DayMacroTotalsCopyWithImpl;
@override @useResult
$Res call({
 num calories, num protein, num carbs, num fat
});




}
/// @nodoc
class __$DayMacroTotalsCopyWithImpl<$Res>
    implements _$DayMacroTotalsCopyWith<$Res> {
  __$DayMacroTotalsCopyWithImpl(this._self, this._then);

  final _DayMacroTotals _self;
  final $Res Function(_DayMacroTotals) _then;

/// Create a copy of DayMacroTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,}) {
  return _then(_DayMacroTotals(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as num,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as num,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as num,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
