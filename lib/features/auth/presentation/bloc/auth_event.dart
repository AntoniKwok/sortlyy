import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.started() = AuthStartedEvent;
  const factory AuthEvent.googleSignInRequested() = GoogleSignInRequestedEvent;
  const factory AuthEvent.appleSignInRequested() = AppleSignInRequestedEvent;
  const factory AuthEvent.signOutRequested() = SignOutRequestedEvent;
}
