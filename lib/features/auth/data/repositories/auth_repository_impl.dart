import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StreamController<User?> _userController = StreamController<User?>.broadcast();

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  ResultFuture<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      final user = userModel.toEntity();
      _userController.add(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(Failure.serverFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(Failure.networkFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      final user = userModel.toEntity();
      _userController.add(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(Failure.serverFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(Failure.networkFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> logout() async {
    try {
      await remoteDataSource.logout();
      _userController.add(null);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.serverFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(Failure.networkFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  ResultStream<User?> getCurrentUser() async* {
    yield* _userController.stream.map((user) => Right(user));
  }

  void dispose() {
    _userController.close();
  }
}