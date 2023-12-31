import 'package:dartz/dartz.dart';
import 'package:digital_dreams_shop/core/errors/exceptions.dart';
import 'package:digital_dreams_shop/core/errors/failures.dart';
import 'package:digital_dreams_shop/core/utils/typdefs.dart';
import 'package:digital_dreams_shop/features/on_boarding/data/data_sources/on_boarding_local_data_sources.dart';
import 'package:digital_dreams_shop/features/on_boarding/domain/repositories/on_boarding_repos.dart';

class OnBoardingRepositoryImpl extends OnBoardingRepository {
  const OnBoardingRepositoryImpl(this.localDataSource);

  final OnBoardingLocalDataSource localDataSource;

  @override
  ResultFuture<void> cacheFirstTimer() async {
    try {
      await localDataSource.cacheFirstTimer();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    }
  }

  @override
  ResultFuture<bool> isFirstTimer() async {
    try {
      final result = await localDataSource.isFirstTimer();
      return Right(result);
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    }
  }
}
