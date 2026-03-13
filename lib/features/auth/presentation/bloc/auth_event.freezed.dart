// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() signOutRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? signOutRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? signOutRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStartedEvent value) started,
    required TResult Function(GoogleSignInRequestedEvent value)
        googleSignInRequested,
    required TResult Function(AppleSignInRequestedEvent value)
        appleSignInRequested,
    required TResult Function(SignOutRequestedEvent value) signOutRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStartedEvent value)? started,
    TResult? Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult? Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult? Function(SignOutRequestedEvent value)? signOutRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStartedEvent value)? started,
    TResult Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult Function(SignOutRequestedEvent value)? signOutRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AuthStartedEventImplCopyWith<$Res> {
  factory _$$AuthStartedEventImplCopyWith(_$AuthStartedEventImpl value,
          $Res Function(_$AuthStartedEventImpl) then) =
      __$$AuthStartedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthStartedEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$AuthStartedEventImpl>
    implements _$$AuthStartedEventImplCopyWith<$Res> {
  __$$AuthStartedEventImplCopyWithImpl(_$AuthStartedEventImpl _value,
      $Res Function(_$AuthStartedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AuthStartedEventImpl implements AuthStartedEvent {
  const _$AuthStartedEventImpl();

  @override
  String toString() {
    return 'AuthEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthStartedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() signOutRequested,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? signOutRequested,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? signOutRequested,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStartedEvent value) started,
    required TResult Function(GoogleSignInRequestedEvent value)
        googleSignInRequested,
    required TResult Function(AppleSignInRequestedEvent value)
        appleSignInRequested,
    required TResult Function(SignOutRequestedEvent value) signOutRequested,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStartedEvent value)? started,
    TResult? Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult? Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult? Function(SignOutRequestedEvent value)? signOutRequested,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStartedEvent value)? started,
    TResult Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult Function(SignOutRequestedEvent value)? signOutRequested,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class AuthStartedEvent implements AuthEvent {
  const factory AuthStartedEvent() = _$AuthStartedEventImpl;
}

/// @nodoc
abstract class _$$GoogleSignInRequestedEventImplCopyWith<$Res> {
  factory _$$GoogleSignInRequestedEventImplCopyWith(
          _$GoogleSignInRequestedEventImpl value,
          $Res Function(_$GoogleSignInRequestedEventImpl) then) =
      __$$GoogleSignInRequestedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GoogleSignInRequestedEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$GoogleSignInRequestedEventImpl>
    implements _$$GoogleSignInRequestedEventImplCopyWith<$Res> {
  __$$GoogleSignInRequestedEventImplCopyWithImpl(
      _$GoogleSignInRequestedEventImpl _value,
      $Res Function(_$GoogleSignInRequestedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GoogleSignInRequestedEventImpl implements GoogleSignInRequestedEvent {
  const _$GoogleSignInRequestedEventImpl();

  @override
  String toString() {
    return 'AuthEvent.googleSignInRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoogleSignInRequestedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() signOutRequested,
  }) {
    return googleSignInRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? signOutRequested,
  }) {
    return googleSignInRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? signOutRequested,
    required TResult orElse(),
  }) {
    if (googleSignInRequested != null) {
      return googleSignInRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStartedEvent value) started,
    required TResult Function(GoogleSignInRequestedEvent value)
        googleSignInRequested,
    required TResult Function(AppleSignInRequestedEvent value)
        appleSignInRequested,
    required TResult Function(SignOutRequestedEvent value) signOutRequested,
  }) {
    return googleSignInRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStartedEvent value)? started,
    TResult? Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult? Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult? Function(SignOutRequestedEvent value)? signOutRequested,
  }) {
    return googleSignInRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStartedEvent value)? started,
    TResult Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult Function(SignOutRequestedEvent value)? signOutRequested,
    required TResult orElse(),
  }) {
    if (googleSignInRequested != null) {
      return googleSignInRequested(this);
    }
    return orElse();
  }
}

abstract class GoogleSignInRequestedEvent implements AuthEvent {
  const factory GoogleSignInRequestedEvent() = _$GoogleSignInRequestedEventImpl;
}

/// @nodoc
abstract class _$$AppleSignInRequestedEventImplCopyWith<$Res> {
  factory _$$AppleSignInRequestedEventImplCopyWith(
          _$AppleSignInRequestedEventImpl value,
          $Res Function(_$AppleSignInRequestedEventImpl) then) =
      __$$AppleSignInRequestedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AppleSignInRequestedEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$AppleSignInRequestedEventImpl>
    implements _$$AppleSignInRequestedEventImplCopyWith<$Res> {
  __$$AppleSignInRequestedEventImplCopyWithImpl(
      _$AppleSignInRequestedEventImpl _value,
      $Res Function(_$AppleSignInRequestedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AppleSignInRequestedEventImpl implements AppleSignInRequestedEvent {
  const _$AppleSignInRequestedEventImpl();

  @override
  String toString() {
    return 'AuthEvent.appleSignInRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppleSignInRequestedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() signOutRequested,
  }) {
    return appleSignInRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? signOutRequested,
  }) {
    return appleSignInRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? signOutRequested,
    required TResult orElse(),
  }) {
    if (appleSignInRequested != null) {
      return appleSignInRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStartedEvent value) started,
    required TResult Function(GoogleSignInRequestedEvent value)
        googleSignInRequested,
    required TResult Function(AppleSignInRequestedEvent value)
        appleSignInRequested,
    required TResult Function(SignOutRequestedEvent value) signOutRequested,
  }) {
    return appleSignInRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStartedEvent value)? started,
    TResult? Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult? Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult? Function(SignOutRequestedEvent value)? signOutRequested,
  }) {
    return appleSignInRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStartedEvent value)? started,
    TResult Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult Function(SignOutRequestedEvent value)? signOutRequested,
    required TResult orElse(),
  }) {
    if (appleSignInRequested != null) {
      return appleSignInRequested(this);
    }
    return orElse();
  }
}

abstract class AppleSignInRequestedEvent implements AuthEvent {
  const factory AppleSignInRequestedEvent() = _$AppleSignInRequestedEventImpl;
}

/// @nodoc
abstract class _$$SignOutRequestedEventImplCopyWith<$Res> {
  factory _$$SignOutRequestedEventImplCopyWith(
          _$SignOutRequestedEventImpl value,
          $Res Function(_$SignOutRequestedEventImpl) then) =
      __$$SignOutRequestedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignOutRequestedEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SignOutRequestedEventImpl>
    implements _$$SignOutRequestedEventImplCopyWith<$Res> {
  __$$SignOutRequestedEventImplCopyWithImpl(_$SignOutRequestedEventImpl _value,
      $Res Function(_$SignOutRequestedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignOutRequestedEventImpl implements SignOutRequestedEvent {
  const _$SignOutRequestedEventImpl();

  @override
  String toString() {
    return 'AuthEvent.signOutRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignOutRequestedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() signOutRequested,
  }) {
    return signOutRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? signOutRequested,
  }) {
    return signOutRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? signOutRequested,
    required TResult orElse(),
  }) {
    if (signOutRequested != null) {
      return signOutRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStartedEvent value) started,
    required TResult Function(GoogleSignInRequestedEvent value)
        googleSignInRequested,
    required TResult Function(AppleSignInRequestedEvent value)
        appleSignInRequested,
    required TResult Function(SignOutRequestedEvent value) signOutRequested,
  }) {
    return signOutRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStartedEvent value)? started,
    TResult? Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult? Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult? Function(SignOutRequestedEvent value)? signOutRequested,
  }) {
    return signOutRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStartedEvent value)? started,
    TResult Function(GoogleSignInRequestedEvent value)? googleSignInRequested,
    TResult Function(AppleSignInRequestedEvent value)? appleSignInRequested,
    TResult Function(SignOutRequestedEvent value)? signOutRequested,
    required TResult orElse(),
  }) {
    if (signOutRequested != null) {
      return signOutRequested(this);
    }
    return orElse();
  }
}

abstract class SignOutRequestedEvent implements AuthEvent {
  const factory SignOutRequestedEvent() = _$SignOutRequestedEventImpl;
}
