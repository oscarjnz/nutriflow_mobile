// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parse_food_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParseFoodResult {

 List<ParsedItem> get items; bool get cached; String get model;
/// Create a copy of ParseFoodResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParseFoodResultCopyWith<ParseFoodResult> get copyWith => _$ParseFoodResultCopyWithImpl<ParseFoodResult>(this as ParseFoodResult, _$identity);

  /// Serializes this ParseFoodResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParseFoodResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.cached, cached) || other.cached == cached)&&(identical(other.model, model) || other.model == model));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),cached,model);

@override
String toString() {
  return 'ParseFoodResult(items: $items, cached: $cached, model: $model)';
}


}

/// @nodoc
abstract mixin class $ParseFoodResultCopyWith<$Res>  {
  factory $ParseFoodResultCopyWith(ParseFoodResult value, $Res Function(ParseFoodResult) _then) = _$ParseFoodResultCopyWithImpl;
@useResult
$Res call({
 List<ParsedItem> items, bool cached, String model
});




}
/// @nodoc
class _$ParseFoodResultCopyWithImpl<$Res>
    implements $ParseFoodResultCopyWith<$Res> {
  _$ParseFoodResultCopyWithImpl(this._self, this._then);

  final ParseFoodResult _self;
  final $Res Function(ParseFoodResult) _then;

/// Create a copy of ParseFoodResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? cached = null,Object? model = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ParsedItem>,cached: null == cached ? _self.cached : cached // ignore: cast_nullable_to_non_nullable
as bool,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ParseFoodResult].
extension ParseFoodResultPatterns on ParseFoodResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParseFoodResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParseFoodResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParseFoodResult value)  $default,){
final _that = this;
switch (_that) {
case _ParseFoodResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParseFoodResult value)?  $default,){
final _that = this;
switch (_that) {
case _ParseFoodResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ParsedItem> items,  bool cached,  String model)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParseFoodResult() when $default != null:
return $default(_that.items,_that.cached,_that.model);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ParsedItem> items,  bool cached,  String model)  $default,) {final _that = this;
switch (_that) {
case _ParseFoodResult():
return $default(_that.items,_that.cached,_that.model);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ParsedItem> items,  bool cached,  String model)?  $default,) {final _that = this;
switch (_that) {
case _ParseFoodResult() when $default != null:
return $default(_that.items,_that.cached,_that.model);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParseFoodResult implements ParseFoodResult {
  const _ParseFoodResult({required final  List<ParsedItem> items, required this.cached, required this.model}): _items = items;
  factory _ParseFoodResult.fromJson(Map<String, dynamic> json) => _$ParseFoodResultFromJson(json);

 final  List<ParsedItem> _items;
@override List<ParsedItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  bool cached;
@override final  String model;

/// Create a copy of ParseFoodResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParseFoodResultCopyWith<_ParseFoodResult> get copyWith => __$ParseFoodResultCopyWithImpl<_ParseFoodResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParseFoodResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParseFoodResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.cached, cached) || other.cached == cached)&&(identical(other.model, model) || other.model == model));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),cached,model);

@override
String toString() {
  return 'ParseFoodResult(items: $items, cached: $cached, model: $model)';
}


}

/// @nodoc
abstract mixin class _$ParseFoodResultCopyWith<$Res> implements $ParseFoodResultCopyWith<$Res> {
  factory _$ParseFoodResultCopyWith(_ParseFoodResult value, $Res Function(_ParseFoodResult) _then) = __$ParseFoodResultCopyWithImpl;
@override @useResult
$Res call({
 List<ParsedItem> items, bool cached, String model
});




}
/// @nodoc
class __$ParseFoodResultCopyWithImpl<$Res>
    implements _$ParseFoodResultCopyWith<$Res> {
  __$ParseFoodResultCopyWithImpl(this._self, this._then);

  final _ParseFoodResult _self;
  final $Res Function(_ParseFoodResult) _then;

/// Create a copy of ParseFoodResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? cached = null,Object? model = null,}) {
  return _then(_ParseFoodResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ParsedItem>,cached: null == cached ? _self.cached : cached // ignore: cast_nullable_to_non_nullable
as bool,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
