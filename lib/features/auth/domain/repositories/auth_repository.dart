import '../../../../core/utils/typedef.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  ResultFuture<User> login({
    required String email,
    required String password,
  });

  ResultFuture<User> register({
    required String email,
    required String password,
    required String name,
  });

  ResultFuture<void> logout();

  ResultStream<User?> getCurrentUser();
}