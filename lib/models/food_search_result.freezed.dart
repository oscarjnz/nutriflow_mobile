// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodSearchResult {

/// Local catalog rows carry their UUID; an OFF hit not yet imported into
/// the catalog cannot reach this model at all - the barcode-lookup
/// endpoint always imports before returning (see `lookupBarcodeAction`).
 String get id; String get origin; String? get barcode; String? get brand; String get nameEs; String get nameEn; double get caloriesPer100g; double get proteinPer100g; double get carbsPer100g; double get fatPer100g; double? get defaultServingGrams; String? get defaultServingLabel;
/// Create a copy of FoodSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodSearchResultCopyWith<FoodSearchResult> get copyWith => _$FoodSearchResultCopyWithImpl<FoodSearchResult>(this as FoodSearchResult, _$identity);

  /// Serializes this FoodSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodSearchResult&&(identical(other.id, id) || other.id == id)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.caloriesPer100g, caloriesPer100g) || other.caloriesPer100g == caloriesPer100g)&&(identical(other.proteinPer100g, proteinPer100g) || other.proteinPer100g == proteinPer100g)&&(identical(other.carbsPer100g, carbsPer100g) || other.carbsPer100g == carbsPer100g)&&(identical(other.fatPer100g, fatPer100g) || other.fatPer100g == fatPer100g)&&(identical(other.defaultServingGrams, defaultServingGrams) || other.defaultServingGrams == defaultServingGrams)&&(identical(other.defaultServingLabel, defaultServingLabel) || other.defaultServingLabel == defaultServingLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,origin,barcode,brand,nameEs,nameEn,caloriesPer100g,proteinPer100g,carbsPer100g,fatPer100g,defaultServingGrams,defaultServingLabel);

@override
String toString() {
  return 'FoodSearchResult(id: $id, origin: $origin, barcode: $barcode, brand: $brand, nameEs: $nameEs, nameEn: $nameEn, caloriesPer100g: $caloriesPer100g, proteinPer100g: $proteinPer100g, carbsPer100g: $carbsPer100g, fatPer100g: $fatPer100g, defaultServingGrams: $defaultServingGrams, defaultServingLabel: $defaultServingLabel)';
}


}

/// @nodoc
abstract mixin class $FoodSearchResultCopyWith<$Res>  {
  factory $FoodSearchResultCopyWith(FoodSearchResult value, $Res Function(FoodSearchResult) _then) = _$FoodSearchResultCopyWithImpl;
@useResult
$Res call({
 String id, String origin, String? barcode, String? brand, String nameEs, String nameEn, double caloriesPer100g, double proteinPer100g, double carbsPer100g, double fatPer100g, double? defaultServingGrams, String? defaultServingLabel
});




}
/// @nodoc
class _$FoodSearchResultCopyWithImpl<$Res>
    implements $FoodSearchResultCopyWith<$Res> {
  _$FoodSearchResultCopyWithImpl(this._self, this._then);

  final FoodSearchResult _self;
  final $Res Function(FoodSearchResult) _then;

/// Create a copy of FoodSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? origin = null,Object? barcode = freezed,Object? brand = freezed,Object? nameEs = null,Object? nameEn = null,Object? caloriesPer100g = null,Object? proteinPer100g = null,Object? carbsPer100g = null,Object? fatPer100g = null,Object? defaultServingGrams = freezed,Object? defaultServingLabel = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,nameEs: null == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,caloriesPer100g: null == caloriesPer100g ? _self.caloriesPer100g : caloriesPer100g // ignore: cast_nullable_to_non_nullable
as double,proteinPer100g: null == proteinPer100g ? _self.proteinPer100g : proteinPer100g // ignore: cast_nullable_to_non_nullable
as double,carbsPer100g: null == carbsPer100g ? _self.carbsPer100g : carbsPer100g // ignore: cast_nullable_to_non_nullable
as double,fatPer100g: null == fatPer100g ? _self.fatPer100g : fatPer100g // ignore: cast_nullable_to_non_nullable
as double,defaultServingGrams: freezed == defaultServingGrams ? _self.defaultServingGrams : defaultServingGrams // ignore: cast_nullable_to_non_nullable
as double?,defaultServingLabel: freezed == defaultServingLabel ? _self.defaultServingLabel : defaultServingLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodSearchResult].
extension FoodSearchResultPatterns on FoodSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _FoodSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _FoodSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String origin,  String? barcode,  String? brand,  String nameEs,  String nameEn,  double caloriesPer100g,  double proteinPer100g,  double carbsPer100g,  double fatPer100g,  double? defaultServingGrams,  String? defaultServingLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodSearchResult() when $default != null:
return $default(_that.id,_that.origin,_that.barcode,_that.brand,_that.nameEs,_that.nameEn,_that.caloriesPer100g,_that.proteinPer100g,_that.carbsPer100g,_that.fatPer100g,_that.defaultServingGrams,_that.defaultServingLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String origin,  String? barcode,  String? brand,  String nameEs,  String nameEn,  double caloriesPer100g,  double proteinPer100g,  double carbsPer100g,  double fatPer100g,  double? defaultServingGrams,  String? defaultServingLabel)  $default,) {final _that = this;
switch (_that) {
case _FoodSearchResult():
return $default(_that.id,_that.origin,_that.barcode,_that.brand,_that.nameEs,_that.nameEn,_that.caloriesPer100g,_that.proteinPer100g,_that.carbsPer100g,_that.fatPer100g,_that.defaultServingGrams,_that.defaultServingLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String origin,  String? barcode,  String? brand,  String nameEs,  String nameEn,  double caloriesPer100g,  double proteinPer100g,  double carbsPer100g,  double fatPer100g,  double? defaultServingGrams,  String? defaultServingLabel)?  $default,) {final _that = this;
switch (_that) {
case _FoodSearchResult() when $default != null:
return $default(_that.id,_that.origin,_that.barcode,_that.brand,_that.nameEs,_that.nameEn,_that.caloriesPer100g,_that.proteinPer100g,_that.carbsPer100g,_that.fatPer100g,_that.defaultServingGrams,_that.defaultServingLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodSearchResult implements FoodSearchResult {
  const _FoodSearchResult({required this.id, required this.origin, this.barcode, this.brand, required this.nameEs, required this.nameEn, required this.caloriesPer100g, required this.proteinPer100g, required this.carbsPer100g, required this.fatPer100g, this.defaultServingGrams, this.defaultServingLabel});
  factory _FoodSearchResult.fromJson(Map<String, dynamic> json) => _$FoodSearchResultFromJson(json);

/// Local catalog rows carry their UUID; an OFF hit not yet imported into
/// the catalog cannot reach this model at all - the barcode-lookup
/// endpoint always imports before returning (see `lookupBarcodeAction`).
@override final  String id;
@override final  String origin;
@override final  String? barcode;
@override final  String? brand;
@override final  String nameEs;
@override final  String nameEn;
@override final  double caloriesPer100g;
@override final  double proteinPer100g;
@override final  double carbsPer100g;
@override final  double fatPer100g;
@override final  double? defaultServingGrams;
@override final  String? defaultServingLabel;

/// Create a copy of FoodSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodSearchResultCopyWith<_FoodSearchResult> get copyWith => __$FoodSearchResultCopyWithImpl<_FoodSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodSearchResult&&(identical(other.id, id) || other.id == id)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.caloriesPer100g, caloriesPer100g) || other.caloriesPer100g == caloriesPer100g)&&(identical(other.proteinPer100g, proteinPer100g) || other.proteinPer100g == proteinPer100g)&&(identical(other.carbsPer100g, carbsPer100g) || other.carbsPer100g == carbsPer100g)&&(identical(other.fatPer100g, fatPer100g) || other.fatPer100g == fatPer100g)&&(identical(other.defaultServingGrams, defaultServingGrams) || other.defaultServingGrams == defaultServingGrams)&&(identical(other.defaultServingLabel, defaultServingLabel) || other.defaultServingLabel == defaultServingLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,origin,barcode,brand,nameEs,nameEn,caloriesPer100g,proteinPer100g,carbsPer100g,fatPer100g,defaultServingGrams,defaultServingLabel);

@override
String toString() {
  return 'FoodSearchResult(id: $id, origin: $origin, barcode: $barcode, brand: $brand, nameEs: $nameEs, nameEn: $nameEn, caloriesPer100g: $caloriesPer100g, proteinPer100g: $proteinPer100g, carbsPer100g: $carbsPer100g, fatPer100g: $fatPer100g, defaultServingGrams: $defaultServingGrams, defaultServingLabel: $defaultServingLabel)';
}


}

/// @nodoc
abstract mixin class _$FoodSearchResultCopyWith<$Res> implements $FoodSearchResultCopyWith<$Res> {
  factory _$FoodSearchResultCopyWith(_FoodSearchResult value, $Res Function(_FoodSearchResult) _then) = __$FoodSearchResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String origin, String? barcode, String? brand, String nameEs, String nameEn, double caloriesPer100g, double proteinPer100g, double carbsPer100g, double fatPer100g, double? defaultServingGrams, String? defaultServingLabel
});




}
/// @nodoc
class __$FoodSearchResultCopyWithImpl<$Res>
    implements _$FoodSearchResultCopyWith<$Res> {
  __$FoodSearchResultCopyWithImpl(this._self, this._then);

  final _FoodSearchResult _self;
  final $Res Function(_FoodSearchResult) _then;

/// Create a copy of FoodSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? origin = null,Object? barcode = freezed,Object? brand = freezed,Object? nameEs = null,Object? nameEn = null,Object? caloriesPer100g = null,Object? proteinPer100g = null,Object? carbsPer100g = null,Object? fatPer100g = null,Object? defaultServingGrams = freezed,Object? defaultServingLabel = freezed,}) {
  return _then(_FoodSearchResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,nameEs: null == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,caloriesPer100g: null == caloriesPer100g ? _self.caloriesPer100g : caloriesPer100g // ignore: cast_nullable_to_non_nullable
as double,proteinPer100g: null == proteinPer100g ? _self.proteinPer100g : proteinPer100g // ignore: cast_nullable_to_non_nullable
as double,carbsPer100g: null == carbsPer100g ? _self.carbsPer100g : carbsPer100g // ignore: cast_nullable_to_non_nullable
as double,fatPer100g: null == fatPer100g ? _self.fatPer100g : fatPer100g // ignore: cast_nullable_to_non_nullable
as double,defaultServingGrams: freezed == defaultServingGrams ? _self.defaultServingGrams : defaultServingGrams // ignore: cast_nullable_to_non_nullable
as double?,defaultServingLabel: freezed == defaultServingLabel ? _self.defaultServingLabel : defaultServingLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
