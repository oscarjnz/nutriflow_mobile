// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeightLog {

 String get id; double get weightKg; double? get bodyFatPct; double? get waistCm; double? get neckCm; double? get hipsCm; DateTime get loggedAt;
/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightLogCopyWith<WeightLog> get copyWith => _$WeightLogCopyWithImpl<WeightLog>(this as WeightLog, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightLog&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyFatPct, bodyFatPct) || other.bodyFatPct == bodyFatPct)&&(identical(other.waistCm, waistCm) || other.waistCm == waistCm)&&(identical(other.neckCm, neckCm) || other.neckCm == neckCm)&&(identical(other.hipsCm, hipsCm) || other.hipsCm == hipsCm)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,weightKg,bodyFatPct,waistCm,neckCm,hipsCm,loggedAt);

@override
String toString() {
  return 'WeightLog(id: $id, weightKg: $weightKg, bodyFatPct: $bodyFatPct, waistCm: $waistCm, neckCm: $neckCm, hipsCm: $hipsCm, loggedAt: $loggedAt)';
}


}

/// @nodoc
abstract mixin class $WeightLogCopyWith<$Res>  {
  factory $WeightLogCopyWith(WeightLog value, $Res Function(WeightLog) _then) = _$WeightLogCopyWithImpl;
@useResult
$Res call({
 String id, double weightKg, double? bodyFatPct, double? waistCm, double? neckCm, double? hipsCm, DateTime loggedAt
});




}
/// @nodoc
class _$WeightLogCopyWithImpl<$Res>
    implements $WeightLogCopyWith<$Res> {
  _$WeightLogCopyWithImpl(this._self, this._then);

  final WeightLog _self;
  final $Res Function(WeightLog) _then;

/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? weightKg = null,Object? bodyFatPct = freezed,Object? waistCm = freezed,Object? neckCm = freezed,Object? hipsCm = freezed,Object? loggedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyFatPct: freezed == bodyFatPct ? _self.bodyFatPct : bodyFatPct // ignore: cast_nullable_to_non_nullable
as double?,waistCm: freezed == waistCm ? _self.waistCm : waistCm // ignore: cast_nullable_to_non_nullable
as double?,neckCm: freezed == neckCm ? _self.neckCm : neckCm // ignore: cast_nullable_to_non_nullable
as double?,hipsCm: freezed == hipsCm ? _self.hipsCm : hipsCm // ignore: cast_nullable_to_non_nullable
as double?,loggedAt: null == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightLog].
extension WeightLogPatterns on WeightLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightLog value)  $default,){
final _that = this;
switch (_that) {
case _WeightLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightLog value)?  $default,){
final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double weightKg,  double? bodyFatPct,  double? waistCm,  double? neckCm,  double? hipsCm,  DateTime loggedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
return $default(_that.id,_that.weightKg,_that.bodyFatPct,_that.waistCm,_that.neckCm,_that.hipsCm,_that.loggedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double weightKg,  double? bodyFatPct,  double? waistCm,  double? neckCm,  double? hipsCm,  DateTime loggedAt)  $default,) {final _that = this;
switch (_that) {
case _WeightLog():
return $default(_that.id,_that.weightKg,_that.bodyFatPct,_that.waistCm,_that.neckCm,_that.hipsCm,_that.loggedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double weightKg,  double? bodyFatPct,  double? waistCm,  double? neckCm,  double? hipsCm,  DateTime loggedAt)?  $default,) {final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
return $default(_that.id,_that.weightKg,_that.bodyFatPct,_that.waistCm,_that.neckCm,_that.hipsCm,_that.loggedAt);case _:
  return null;

}
}

}

/// @nodoc


class _WeightLog implements WeightLog {
  const _WeightLog({required this.id, required this.weightKg, this.bodyFatPct, this.waistCm, this.neckCm, this.hipsCm, required this.loggedAt});
  

@override final  String id;
@override final  double weightKg;
@override final  double? bodyFatPct;
@override final  double? waistCm;
@override final  double? neckCm;
@override final  double? hipsCm;
@override final  DateTime loggedAt;

/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightLogCopyWith<_WeightLog> get copyWith => __$WeightLogCopyWithImpl<_WeightLog>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightLog&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyFatPct, bodyFatPct) || other.bodyFatPct == bodyFatPct)&&(identical(other.waistCm, waistCm) || other.waistCm == waistCm)&&(identical(other.neckCm, neckCm) || other.neckCm == neckCm)&&(identical(other.hipsCm, hipsCm) || other.hipsCm == hipsCm)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,weightKg,bodyFatPct,waistCm,neckCm,hipsCm,loggedAt);

@override
String toString() {
  return 'WeightLog(id: $id, weightKg: $weightKg, bodyFatPct: $bodyFatPct, waistCm: $waistCm, neckCm: $neckCm, hipsCm: $hipsCm, loggedAt: $loggedAt)';
}


}

/// @nodoc
abstract mixin class _$WeightLogCopyWith<$Res> implements $WeightLogCopyWith<$Res> {
  factory _$WeightLogCopyWith(_WeightLog value, $Res Function(_WeightLog) _then) = __$WeightLogCopyWithImpl;
@override @useResult
$Res call({
 String id, double weightKg, double? bodyFatPct, double? waistCm, double? neckCm, double? hipsCm, DateTime loggedAt
});




}
/// @nodoc
class __$WeightLogCopyWithImpl<$Res>
    implements _$WeightLogCopyWith<$Res> {
  __$WeightLogCopyWithImpl(this._self, this._then);

  final _WeightLog _self;
  final $Res Function(_WeightLog) _then;

/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? weightKg = null,Object? bodyFatPct = freezed,Object? waistCm = freezed,Object? neckCm = freezed,Object? hipsCm = freezed,Object? loggedAt = null,}) {
  return _then(_WeightLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyFatPct: freezed == bodyFatPct ? _self.bodyFatPct : bodyFatPct // ignore: cast_nullable_to_non_nullable
as double?,waistCm: freezed == waistCm ? _self.waistCm : waistCm // ignore: cast_nullable_to_non_nullable
as double?,neckCm: freezed == neckCm ? _self.neckCm : neckCm // ignore: cast_nullable_to_non_nullable
as double?,hipsCm: freezed == hipsCm ? _self.hipsCm : hipsCm // ignore: cast_nullable_to_non_nullable
as double?,loggedAt: null == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
