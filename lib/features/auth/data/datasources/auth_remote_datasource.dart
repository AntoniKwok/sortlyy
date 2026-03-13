import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  Stream<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  const AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const ServerException(message: 'Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const ServerException(
            message: 'Failed to get Google ID token');
      }

      await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'Authentication failed');
      }

      return UserModel.fromSupabaseUser(user);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const ServerException(
            message: 'Failed to get Apple identity token');
      }

      await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'Authentication failed');
      }

      return UserModel.fromSupabaseUser(user);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        supabaseClient.auth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> getCurrentUser() {
    return supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }
}
