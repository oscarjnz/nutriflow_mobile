// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodCandidate {

 String get foodId; String get nameEs; String get nameEn; double get score; String get matchedVia;
/// Create a copy of FoodCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodCandidateCopyWith<FoodCandidate> get copyWith => _$FoodCandidateCopyWithImpl<FoodCandidate>(this as FoodCandidate, _$identity);

  /// Serializes this FoodCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodCandidate&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.score, score) || other.score == score)&&(identical(other.matchedVia, matchedVia) || other.matchedVia == matchedVia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodId,nameEs,nameEn,score,matchedVia);

@override
String toString() {
  return 'FoodCandidate(foodId: $foodId, nameEs: $nameEs, nameEn: $nameEn, score: $score, matchedVia: $matchedVia)';
}


}

/// @nodoc
abstract mixin class $FoodCandidateCopyWith<$Res>  {
  factory $FoodCandidateCopyWith(FoodCandidate value, $Res Function(FoodCandidate) _then) = _$FoodCandidateCopyWithImpl;
@useResult
$Res call({
 String foodId, String nameEs, String nameEn, double score, String matchedVia
});




}
/// @nodoc
class _$FoodCandidateCopyWithImpl<$Res>
    implements $FoodCandidateCopyWith<$Res> {
  _$FoodCandidateCopyWithImpl(this._self, this._then);

  final FoodCandidate _self;
  final $Res Function(FoodCandidate) _then;

/// Create a copy of FoodCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? foodId = null,Object? nameEs = null,Object? nameEn = null,Object? score = null,Object? matchedVia = null,}) {
  return _then(_self.copyWith(
foodId: null == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String,nameEs: null == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,matchedVia: null == matchedVia ? _self.matchedVia : matchedVia // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodCandidate].
extension FoodCandidatePatterns on FoodCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodCandidate value)  $default,){
final _that = this;
switch (_that) {
case _FoodCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _FoodCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String foodId,  String nameEs,  String nameEn,  double score,  String matchedVia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodCandidate() when $default != null:
return $default(_that.foodId,_that.nameEs,_that.nameEn,_that.score,_that.matchedVia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String foodId,  String nameEs,  String nameEn,  double score,  String matchedVia)  $default,) {final _that = this;
switch (_that) {
case _FoodCandidate():
return $default(_that.foodId,_that.nameEs,_that.nameEn,_that.score,_that.matchedVia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String foodId,  String nameEs,  String nameEn,  double score,  String matchedVia)?  $default,) {final _that = this;
switch (_that) {
case _FoodCandidate() when $default != null:
return $default(_that.foodId,_that.nameEs,_that.nameEn,_that.score,_that.matchedVia);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodCandidate implements FoodCandidate {
  const _FoodCandidate({required this.foodId, required this.nameEs, required this.nameEn, required this.score, required this.matchedVia});
  factory _FoodCandidate.fromJson(Map<String, dynamic> json) => _$FoodCandidateFromJson(json);

@override final  String foodId;
@override final  String nameEs;
@override final  String nameEn;
@override final  double score;
@override final  String matchedVia;

/// Create a copy of FoodCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodCandidateCopyWith<_FoodCandidate> get copyWith => __$FoodCandidateCopyWithImpl<_FoodCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodCandidate&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.score, score) || other.score == score)&&(identical(other.matchedVia, matchedVia) || other.matchedVia == matchedVia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodId,nameEs,nameEn,score,matchedVia);

@override
String toString() {
  return 'FoodCandidate(foodId: $foodId, nameEs: $nameEs, nameEn: $nameEn, score: $score, matchedVia: $matchedVia)';
}


}

/// @nodoc
abstract mixin class _$FoodCandidateCopyWith<$Res> implements $FoodCandidateCopyWith<$Res> {
  factory _$FoodCandidateCopyWith(_FoodCandidate value, $Res Function(_FoodCandidate) _then) = __$FoodCandidateCopyWithImpl;
@override @useResult
$Res call({
 String foodId, String nameEs, String nameEn, double score, String matchedVia
});




}
/// @nodoc
class __$FoodCandidateCopyWithImpl<$Res>
    implements _$FoodCandidateCopyWith<$Res> {
  __$FoodCandidateCopyWithImpl(this._self, this._then);

  final _FoodCandidate _self;
  final $Res Function(_FoodCandidate) _then;

/// Create a copy of FoodCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? foodId = null,Object? nameEs = null,Object? nameEn = null,Object? score = null,Object? matchedVia = null,}) {
  return _then(_FoodCandidate(
foodId: null == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String,nameEs: null == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,matchedVia: null == matchedVia ? _self.matchedVia : matchedVia // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
