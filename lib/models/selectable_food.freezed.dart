// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selectable_food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectableFood {

 String get id; String get nameEs; String get category;
/// Create a copy of SelectableFood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectableFoodCopyWith<SelectableFood> get copyWith => _$SelectableFoodCopyWithImpl<SelectableFood>(this as SelectableFood, _$identity);

  /// Serializes this SelectableFood to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectableFood&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEs,category);

@override
String toString() {
  return 'SelectableFood(id: $id, nameEs: $nameEs, category: $category)';
}


}

/// @nodoc
abstract mixin class $SelectableFoodCopyWith<$Res>  {
  factory $SelectableFoodCopyWith(SelectableFood value, $Res Function(SelectableFood) _then) = _$SelectableFoodCopyWithImpl;
@useResult
$Res call({
 String id, String nameEs, String category
});




}
/// @nodoc
class _$SelectableFoodCopyWithImpl<$Res>
    implements $SelectableFoodCopyWith<$Res> {
  _$SelectableFoodCopyWithImpl(this._self, this._then);

  final SelectableFood _self;
  final $Res Function(SelectableFood) _then;

/// Create a copy of SelectableFood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameEs = null,Object? category = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEs: null == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectableFood].
extension SelectableFoodPatterns on SelectableFood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectableFood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectableFood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectableFood value)  $default,){
final _that = this;
switch (_that) {
case _SelectableFood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectableFood value)?  $default,){
final _that = this;
switch (_that) {
case _SelectableFood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameEs,  String category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectableFood() when $default != null:
return $default(_that.id,_that.nameEs,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameEs,  String category)  $default,) {final _that = this;
switch (_that) {
case _SelectableFood():
return $default(_that.id,_that.nameEs,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameEs,  String category)?  $default,) {final _that = this;
switch (_that) {
case _SelectableFood() when $default != null:
return $default(_that.id,_that.nameEs,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelectableFood implements SelectableFood {
  const _SelectableFood({required this.id, required this.nameEs, required this.category});
  factory _SelectableFood.fromJson(Map<String, dynamic> json) => _$SelectableFoodFromJson(json);

@override final  String id;
@override final  String nameEs;
@override final  String category;

/// Create a copy of SelectableFood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectableFoodCopyWith<_SelectableFood> get copyWith => __$SelectableFoodCopyWithImpl<_SelectableFood>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectableFoodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectableFood&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEs,category);

@override
String toString() {
  return 'SelectableFood(id: $id, nameEs: $nameEs, category: $category)';
}


}

/// @nodoc
abstract mixin class _$SelectableFoodCopyWith<$Res> implements $SelectableFoodCopyWith<$Res> {
  factory _$SelectableFoodCopyWith(_SelectableFood value, $Res Function(_SelectableFood) _then) = __$SelectableFoodCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameEs, String category
});




}
/// @nodoc
class __$SelectableFoodCopyWithImpl<$Res>
    implements _$SelectableFoodCopyWith<$Res> {
  __$SelectableFoodCopyWithImpl(this._self, this._then);

  final _SelectableFood _self;
  final $Res Function(_SelectableFood) _then;

/// Create a copy of SelectableFood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameEs = null,Object? category = null,}) {
  return _then(_SelectableFood(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEs: null == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
