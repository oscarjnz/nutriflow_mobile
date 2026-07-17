// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedItem {

 ExtractedFood get extracted; List<FoodCandidate> get candidates;
/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedItemCopyWith<ParsedItem> get copyWith => _$ParsedItemCopyWithImpl<ParsedItem>(this as ParsedItem, _$identity);

  /// Serializes this ParsedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedItem&&(identical(other.extracted, extracted) || other.extracted == extracted)&&const DeepCollectionEquality().equals(other.candidates, candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,extracted,const DeepCollectionEquality().hash(candidates));

@override
String toString() {
  return 'ParsedItem(extracted: $extracted, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $ParsedItemCopyWith<$Res>  {
  factory $ParsedItemCopyWith(ParsedItem value, $Res Function(ParsedItem) _then) = _$ParsedItemCopyWithImpl;
@useResult
$Res call({
 ExtractedFood extracted, List<FoodCandidate> candidates
});


$ExtractedFoodCopyWith<$Res> get extracted;

}
/// @nodoc
class _$ParsedItemCopyWithImpl<$Res>
    implements $ParsedItemCopyWith<$Res> {
  _$ParsedItemCopyWithImpl(this._self, this._then);

  final ParsedItem _self;
  final $Res Function(ParsedItem) _then;

/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? extracted = null,Object? candidates = null,}) {
  return _then(_self.copyWith(
extracted: null == extracted ? _self.extracted : extracted // ignore: cast_nullable_to_non_nullable
as ExtractedFood,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<FoodCandidate>,
  ));
}
/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExtractedFoodCopyWith<$Res> get extracted {
  
  return $ExtractedFoodCopyWith<$Res>(_self.extracted, (value) {
    return _then(_self.copyWith(extracted: value));
  });
}
}


/// Adds pattern-matching-related methods to [ParsedItem].
extension ParsedItemPatterns on ParsedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedItem value)  $default,){
final _that = this;
switch (_that) {
case _ParsedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedItem value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExtractedFood extracted,  List<FoodCandidate> candidates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
return $default(_that.extracted,_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExtractedFood extracted,  List<FoodCandidate> candidates)  $default,) {final _that = this;
switch (_that) {
case _ParsedItem():
return $default(_that.extracted,_that.candidates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExtractedFood extracted,  List<FoodCandidate> candidates)?  $default,) {final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
return $default(_that.extracted,_that.candidates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedItem implements ParsedItem {
  const _ParsedItem({required this.extracted, required final  List<FoodCandidate> candidates}): _candidates = candidates;
  factory _ParsedItem.fromJson(Map<String, dynamic> json) => _$ParsedItemFromJson(json);

@override final  ExtractedFood extracted;
 final  List<FoodCandidate> _candidates;
@override List<FoodCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedItemCopyWith<_ParsedItem> get copyWith => __$ParsedItemCopyWithImpl<_ParsedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedItem&&(identical(other.extracted, extracted) || other.extracted == extracted)&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,extracted,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'ParsedItem(extracted: $extracted, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class _$ParsedItemCopyWith<$Res> implements $ParsedItemCopyWith<$Res> {
  factory _$ParsedItemCopyWith(_ParsedItem value, $Res Function(_ParsedItem) _then) = __$ParsedItemCopyWithImpl;
@override @useResult
$Res call({
 ExtractedFood extracted, List<FoodCandidate> candidates
});


@override $ExtractedFoodCopyWith<$Res> get extracted;

}
/// @nodoc
class __$ParsedItemCopyWithImpl<$Res>
    implements _$ParsedItemCopyWith<$Res> {
  __$ParsedItemCopyWithImpl(this._self, this._then);

  final _ParsedItem _self;
  final $Res Function(_ParsedItem) _then;

/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? extracted = null,Object? candidates = null,}) {
  return _then(_ParsedItem(
extracted: null == extracted ? _self.extracted : extracted // ignore: cast_nullable_to_non_nullable
as ExtractedFood,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<FoodCandidate>,
  ));
}

/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExtractedFoodCopyWith<$Res> get extracted {
  
  return $ExtractedFoodCopyWith<$Res>(_self.extracted, (value) {
    return _then(_self.copyWith(extracted: value));
  });
}
}

// dart format on
