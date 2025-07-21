import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.serverFailure({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.networkFailure({
    required String message,
  }) = NetworkFailure;

  const factory Failure.cacheFailure({
    required String message,
  }) = CacheFailure;

  const factory Failure.unknownFailure({
    required String message,
  }) = UnknownFailure;
}