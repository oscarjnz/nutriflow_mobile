// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extracted_food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExtractedFood {

 String get raw; String get name; String? get nameEn; double get quantity; String get unit; List<String> get queryTerms;
/// Create a copy of ExtractedFood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedFoodCopyWith<ExtractedFood> get copyWith => _$ExtractedFoodCopyWithImpl<ExtractedFood>(this as ExtractedFood, _$identity);

  /// Serializes this ExtractedFood to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedFood&&(identical(other.raw, raw) || other.raw == raw)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.queryTerms, queryTerms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,raw,name,nameEn,quantity,unit,const DeepCollectionEquality().hash(queryTerms));

@override
String toString() {
  return 'ExtractedFood(raw: $raw, name: $name, nameEn: $nameEn, quantity: $quantity, unit: $unit, queryTerms: $queryTerms)';
}


}

/// @nodoc
abstract mixin class $ExtractedFoodCopyWith<$Res>  {
  factory $ExtractedFoodCopyWith(ExtractedFood value, $Res Function(ExtractedFood) _then) = _$ExtractedFoodCopyWithImpl;
@useResult
$Res call({
 String raw, String name, String? nameEn, double quantity, String unit, List<String> queryTerms
});




}
/// @nodoc
class _$ExtractedFoodCopyWithImpl<$Res>
    implements $ExtractedFoodCopyWith<$Res> {
  _$ExtractedFoodCopyWithImpl(this._self, this._then);

  final ExtractedFood _self;
  final $Res Function(ExtractedFood) _then;

/// Create a copy of ExtractedFood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? raw = null,Object? name = null,Object? nameEn = freezed,Object? quantity = null,Object? unit = null,Object? queryTerms = null,}) {
  return _then(_self.copyWith(
raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,queryTerms: null == queryTerms ? _self.queryTerms : queryTerms // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedFood].
extension ExtractedFoodPatterns on ExtractedFood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractedFood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractedFood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractedFood value)  $default,){
final _that = this;
switch (_that) {
case _ExtractedFood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractedFood value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractedFood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String raw,  String name,  String? nameEn,  double quantity,  String unit,  List<String> queryTerms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractedFood() when $default != null:
return $default(_that.raw,_that.name,_that.nameEn,_that.quantity,_that.unit,_that.queryTerms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String raw,  String name,  String? nameEn,  double quantity,  String unit,  List<String> queryTerms)  $default,) {final _that = this;
switch (_that) {
case _ExtractedFood():
return $default(_that.raw,_that.name,_that.nameEn,_that.quantity,_that.unit,_that.queryTerms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String raw,  String name,  String? nameEn,  double quantity,  String unit,  List<String> queryTerms)?  $default,) {final _that = this;
switch (_that) {
case _ExtractedFood() when $default != null:
return $default(_that.raw,_that.name,_that.nameEn,_that.quantity,_that.unit,_that.queryTerms);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExtractedFood implements ExtractedFood {
  const _ExtractedFood({required this.raw, required this.name, this.nameEn, required this.quantity, required this.unit, required final  List<String> queryTerms}): _queryTerms = queryTerms;
  factory _ExtractedFood.fromJson(Map<String, dynamic> json) => _$ExtractedFoodFromJson(json);

@override final  String raw;
@override final  String name;
@override final  String? nameEn;
@override final  double quantity;
@override final  String unit;
 final  List<String> _queryTerms;
@override List<String> get queryTerms {
  if (_queryTerms is EqualUnmodifiableListView) return _queryTerms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queryTerms);
}


/// Create a copy of ExtractedFood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractedFoodCopyWith<_ExtractedFood> get copyWith => __$ExtractedFoodCopyWithImpl<_ExtractedFood>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtractedFoodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractedFood&&(identical(other.raw, raw) || other.raw == raw)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._queryTerms, _queryTerms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,raw,name,nameEn,quantity,unit,const DeepCollectionEquality().hash(_queryTerms));

@override
String toString() {
  return 'ExtractedFood(raw: $raw, name: $name, nameEn: $nameEn, quantity: $quantity, unit: $unit, queryTerms: $queryTerms)';
}


}

/// @nodoc
abstract mixin class _$ExtractedFoodCopyWith<$Res> implements $ExtractedFoodCopyWith<$Res> {
  factory _$ExtractedFoodCopyWith(_ExtractedFood value, $Res Function(_ExtractedFood) _then) = __$ExtractedFoodCopyWithImpl;
@override @useResult
$Res call({
 String raw, String name, String? nameEn, double quantity, String unit, List<String> queryTerms
});




}
/// @nodoc
class __$ExtractedFoodCopyWithImpl<$Res>
    implements _$ExtractedFoodCopyWith<$Res> {
  __$ExtractedFoodCopyWithImpl(this._self, this._then);

  final _ExtractedFood _self;
  final $Res Function(_ExtractedFood) _then;

/// Create a copy of ExtractedFood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? raw = null,Object? name = null,Object? nameEn = freezed,Object? quantity = null,Object? unit = null,Object? queryTerms = null,}) {
  return _then(_ExtractedFood(
raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,queryTerms: null == queryTerms ? _self._queryTerms : queryTerms // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
