import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  ResultFuture<AppUser> signInWithGoogle() async {
    try {
      final model = await remoteDataSource.signInWithGoogle();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<AppUser> signInWithApple() async {
    try {
      final model = await remoteDataSource.signInWithApple();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  ResultStream<AppUser?> getCurrentUser() {
    return remoteDataSource.getCurrentUser().map(
          (model) => Right(model?.toEntity()),
        );
  }
}
