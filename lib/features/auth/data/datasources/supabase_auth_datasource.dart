import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class SupabaseAuthDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithPhone(String phone);
  Future<UserModel> verifyOTP({
    required String phone,
    required String token,
  });
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseClient supabaseClient;

  const SupabaseAuthDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      if (response == true) {
        final user = supabaseClient.auth.currentUser;
        if (user != null) {
          return _mapToUserModel(user);
        }
      }
      
      throw const ServerException(message: 'Google sign in failed');
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithPhone(String phone) async {
    try {
      await supabaseClient.auth.signInWithOtp(phone: phone);
      
      // Return a temporary user model indicating OTP was sent
      return const UserModel(
        id: 'otp_sent',
        email: '',
        name: 'OTP Verification Required',
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await supabaseClient.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      if (response.user != null) {
        return _mapToUserModel(response.user!);
      }
      
      throw const ServerException(message: 'OTP verification failed');
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return _mapToUserModel(response.user!);
      }
      
      throw const ServerException(message: 'Email sign in failed');
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        return _mapToUserModel(response.user!);
      }
      
      throw const ServerException(message: 'Email sign up failed');
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? _mapToUserModel(user) : null;
    });
  }

  UserModel _mapToUserModel(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? user.email ?? 'User',
      avatar: user.userMetadata?['avatar_url'],
    );
  }
}