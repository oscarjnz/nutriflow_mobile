// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fasting_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FastingSession {

 String get id; DateTime get startAt; DateTime? get endAt; int get targetHours; String get protocol; String? get notes;
/// Create a copy of FastingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FastingSessionCopyWith<FastingSession> get copyWith => _$FastingSessionCopyWithImpl<FastingSession>(this as FastingSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FastingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.targetHours, targetHours) || other.targetHours == targetHours)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,startAt,endAt,targetHours,protocol,notes);

@override
String toString() {
  return 'FastingSession(id: $id, startAt: $startAt, endAt: $endAt, targetHours: $targetHours, protocol: $protocol, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $FastingSessionCopyWith<$Res>  {
  factory $FastingSessionCopyWith(FastingSession value, $Res Function(FastingSession) _then) = _$FastingSessionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startAt, DateTime? endAt, int targetHours, String protocol, String? notes
});




}
/// @nodoc
class _$FastingSessionCopyWithImpl<$Res>
    implements $FastingSessionCopyWith<$Res> {
  _$FastingSessionCopyWithImpl(this._self, this._then);

  final FastingSession _self;
  final $Res Function(FastingSession) _then;

/// Create a copy of FastingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startAt = null,Object? endAt = freezed,Object? targetHours = null,Object? protocol = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,targetHours: null == targetHours ? _self.targetHours : targetHours // ignore: cast_nullable_to_non_nullable
as int,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FastingSession].
extension FastingSessionPatterns on FastingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FastingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FastingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FastingSession value)  $default,){
final _that = this;
switch (_that) {
case _FastingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FastingSession value)?  $default,){
final _that = this;
switch (_that) {
case _FastingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime startAt,  DateTime? endAt,  int targetHours,  String protocol,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FastingSession() when $default != null:
return $default(_that.id,_that.startAt,_that.endAt,_that.targetHours,_that.protocol,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime startAt,  DateTime? endAt,  int targetHours,  String protocol,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _FastingSession():
return $default(_that.id,_that.startAt,_that.endAt,_that.targetHours,_that.protocol,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime startAt,  DateTime? endAt,  int targetHours,  String protocol,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _FastingSession() when $default != null:
return $default(_that.id,_that.startAt,_that.endAt,_that.targetHours,_that.protocol,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _FastingSession implements FastingSession {
  const _FastingSession({required this.id, required this.startAt, this.endAt, required this.targetHours, required this.protocol, this.notes});
  

@override final  String id;
@override final  DateTime startAt;
@override final  DateTime? endAt;
@override final  int targetHours;
@override final  String protocol;
@override final  String? notes;

/// Create a copy of FastingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FastingSessionCopyWith<_FastingSession> get copyWith => __$FastingSessionCopyWithImpl<_FastingSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FastingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.targetHours, targetHours) || other.targetHours == targetHours)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,startAt,endAt,targetHours,protocol,notes);

@override
String toString() {
  return 'FastingSession(id: $id, startAt: $startAt, endAt: $endAt, targetHours: $targetHours, protocol: $protocol, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$FastingSessionCopyWith<$Res> implements $FastingSessionCopyWith<$Res> {
  factory _$FastingSessionCopyWith(_FastingSession value, $Res Function(_FastingSession) _then) = __$FastingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startAt, DateTime? endAt, int targetHours, String protocol, String? notes
});




}
/// @nodoc
class __$FastingSessionCopyWithImpl<$Res>
    implements _$FastingSessionCopyWith<$Res> {
  __$FastingSessionCopyWithImpl(this._self, this._then);

  final _FastingSession _self;
  final $Res Function(_FastingSession) _then;

/// Create a copy of FastingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startAt = null,Object? endAt = freezed,Object? targetHours = null,Object? protocol = null,Object? notes = freezed,}) {
  return _then(_FastingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,targetHours: null == targetHours ? _self.targetHours : targetHours // ignore: cast_nullable_to_non_nullable
as int,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
