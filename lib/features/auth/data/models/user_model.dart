import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._(); // Required to define instance methods below

  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isProUser,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabaseUser(User supabaseUser) {
    final meta = supabaseUser.userMetadata ?? {};
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: meta['full_name'] as String? ?? meta['name'] as String?,
      avatarUrl:
          meta['avatar_url'] as String? ?? meta['picture'] as String?,
    );
  }

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isProUser: isProUser,
      );
}
