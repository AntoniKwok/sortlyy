import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithAppleUseCase extends UseCase<AppUser, NoParams> {
  final AuthRepository repository;

  const SignInWithAppleUseCase({required this.repository});

  @override
  ResultFuture<AppUser> call(NoParams params) {
    return repository.signInWithApple();
  }
}
