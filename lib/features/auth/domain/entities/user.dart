import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isProUser,
  }) = _AppUser;
}
