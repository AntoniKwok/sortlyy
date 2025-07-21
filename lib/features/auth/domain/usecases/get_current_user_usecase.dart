import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase extends StreamUseCase<User?, NoParams> {
  final AuthRepository repository;

  const GetCurrentUserUseCase({required this.repository});

  @override
  ResultStream<User?> call(NoParams params) {
    return repository.getCurrentUser();
  }
}