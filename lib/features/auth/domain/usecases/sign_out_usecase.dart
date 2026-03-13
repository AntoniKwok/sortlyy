import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  const SignOutUseCase({required this.repository});

  @override
  ResultFuture<void> call(NoParams params) {
    return repository.signOut();
  }
}
