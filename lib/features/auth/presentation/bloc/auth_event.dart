import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = LoginRequested;

  const factory AuthEvent.registerRequested({
    required String email,
    required String password,
    required String name,
  }) = RegisterRequested;

  const factory AuthEvent.logoutRequested() = LogoutRequested;

  const factory AuthEvent.getCurrentUser() = GetCurrentUser;
}