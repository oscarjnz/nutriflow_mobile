// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_meal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayMealEntry {

 String get mealItemId; String get mealLogId; String get foodName; String get mealType; num get quantityGrams; num get calories; num get protein; num get carbs; num get fat; DateTime get loggedAt;
/// Create a copy of DayMealEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayMealEntryCopyWith<DayMealEntry> get copyWith => _$DayMealEntryCopyWithImpl<DayMealEntry>(this as DayMealEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayMealEntry&&(identical(other.mealItemId, mealItemId) || other.mealItemId == mealItemId)&&(identical(other.mealLogId, mealLogId) || other.mealLogId == mealLogId)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.quantityGrams, quantityGrams) || other.quantityGrams == quantityGrams)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt));
}


@override
int get hashCode => Object.hash(runtimeType,mealItemId,mealLogId,foodName,mealType,quantityGrams,calories,protein,carbs,fat,loggedAt);

@override
String toString() {
  return 'DayMealEntry(mealItemId: $mealItemId, mealLogId: $mealLogId, foodName: $foodName, mealType: $mealType, quantityGrams: $quantityGrams, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, loggedAt: $loggedAt)';
}


}

/// @nodoc
abstract mixin class $DayMealEntryCopyWith<$Res>  {
  factory $DayMealEntryCopyWith(DayMealEntry value, $Res Function(DayMealEntry) _then) = _$DayMealEntryCopyWithImpl;
@useResult
$Res call({
 String mealItemId, String mealLogId, String foodName, String mealType, num quantityGrams, num calories, num protein, num carbs, num fat, DateTime loggedAt
});




}
/// @nodoc
class _$DayMealEntryCopyWithImpl<$Res>
    implements $DayMealEntryCopyWith<$Res> {
  _$DayMealEntryCopyWithImpl(this._self, this._then);

  final DayMealEntry _self;
  final $Res Function(DayMealEntry) _then;

/// Create a copy of DayMealEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mealItemId = null,Object? mealLogId = null,Object? foodName = null,Object? mealType = null,Object? quantityGrams = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? loggedAt = null,}) {
  return _then(_self.copyWith(
mealItemId: null == mealItemId ? _self.mealItemId : mealItemId // ignore: cast_nullable_to_non_nullable
as String,mealLogId: null == mealLogId ? _self.mealLogId : mealLogId // ignore: cast_nullable_to_non_nullable
as String,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,quantityGrams: null == quantityGrams ? _self.quantityGrams : quantityGrams // ignore: cast_nullable_to_non_nullable
as num,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as num,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as num,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as num,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as num,loggedAt: null == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DayMealEntry].
extension DayMealEntryPatterns on DayMealEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayMealEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayMealEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayMealEntry value)  $default,){
final _that = this;
switch (_that) {
case _DayMealEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayMealEntry value)?  $default,){
final _that = this;
switch (_that) {
case _DayMealEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mealItemId,  String mealLogId,  String foodName,  String mealType,  num quantityGrams,  num calories,  num protein,  num carbs,  num fat,  DateTime loggedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayMealEntry() when $default != null:
return $default(_that.mealItemId,_that.mealLogId,_that.foodName,_that.mealType,_that.quantityGrams,_that.calories,_that.protein,_that.carbs,_that.fat,_that.loggedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mealItemId,  String mealLogId,  String foodName,  String mealType,  num quantityGrams,  num calories,  num protein,  num carbs,  num fat,  DateTime loggedAt)  $default,) {final _that = this;
switch (_that) {
case _DayMealEntry():
return $default(_that.mealItemId,_that.mealLogId,_that.foodName,_that.mealType,_that.quantityGrams,_that.calories,_that.protein,_that.carbs,_that.fat,_that.loggedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mealItemId,  String mealLogId,  String foodName,  String mealType,  num quantityGrams,  num calories,  num protein,  num carbs,  num fat,  DateTime loggedAt)?  $default,) {final _that = this;
switch (_that) {
case _DayMealEntry() when $default != null:
return $default(_that.mealItemId,_that.mealLogId,_that.foodName,_that.mealType,_that.quantityGrams,_that.calories,_that.protein,_that.carbs,_that.fat,_that.loggedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DayMealEntry implements DayMealEntry {
  const _DayMealEntry({required this.mealItemId, required this.mealLogId, required this.foodName, required this.mealType, required this.quantityGrams, required this.calories, required this.protein, required this.carbs, required this.fat, required this.loggedAt});
  

@override final  String mealItemId;
@override final  String mealLogId;
@override final  String foodName;
@override final  String mealType;
@override final  num quantityGrams;
@override final  num calories;
@override final  num protein;
@override final  num carbs;
@override final  num fat;
@override final  DateTime loggedAt;

/// Create a copy of DayMealEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayMealEntryCopyWith<_DayMealEntry> get copyWith => __$DayMealEntryCopyWithImpl<_DayMealEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayMealEntry&&(identical(other.mealItemId, mealItemId) || other.mealItemId == mealItemId)&&(identical(other.mealLogId, mealLogId) || other.mealLogId == mealLogId)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.quantityGrams, quantityGrams) || other.quantityGrams == quantityGrams)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt));
}


@override
int get hashCode => Object.hash(runtimeType,mealItemId,mealLogId,foodName,mealType,quantityGrams,calories,protein,carbs,fat,loggedAt);

@override
String toString() {
  return 'DayMealEntry(mealItemId: $mealItemId, mealLogId: $mealLogId, foodName: $foodName, mealType: $mealType, quantityGrams: $quantityGrams, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, loggedAt: $loggedAt)';
}


}

/// @nodoc
abstract mixin class _$DayMealEntryCopyWith<$Res> implements $DayMealEntryCopyWith<$Res> {
  factory _$DayMealEntryCopyWith(_DayMealEntry value, $Res Function(_DayMealEntry) _then) = __$DayMealEntryCopyWithImpl;
@override @useResult
$Res call({
 String mealItemId, String mealLogId, String foodName, String mealType, num quantityGrams, num calories, num protein, num carbs, num fat, DateTime loggedAt
});




}
/// @nodoc
class __$DayMealEntryCopyWithImpl<$Res>
    implements _$DayMealEntryCopyWith<$Res> {
  __$DayMealEntryCopyWithImpl(this._self, this._then);

  final _DayMealEntry _self;
  final $Res Function(_DayMealEntry) _then;

/// Create a copy of DayMealEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mealItemId = null,Object? mealLogId = null,Object? foodName = null,Object? mealType = null,Object? quantityGrams = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? loggedAt = null,}) {
  return _then(_DayMealEntry(
mealItemId: null == mealItemId ? _self.mealItemId : mealItemId // ignore: cast_nullable_to_non_nullable
as String,mealLogId: null == mealLogId ? _self.mealLogId : mealLogId // ignore: cast_nullable_to_non_nullable
as String,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,quantityGrams: null == quantityGrams ? _self.quantityGrams : quantityGrams // ignore: cast_nullable_to_non_nullable
as num,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as num,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as num,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as num,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as num,loggedAt: null == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
