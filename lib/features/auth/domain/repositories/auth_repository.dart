import '../../../../core/utils/typedef.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  ResultFuture<AppUser> signInWithGoogle();
  ResultFuture<AppUser> signInWithApple();
  ResultFuture<void> signOut();
  ResultStream<AppUser?> getCurrentUser();
}
