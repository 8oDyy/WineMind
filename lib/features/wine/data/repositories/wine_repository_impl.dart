import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wine.dart';
import '../../domain/repositories/wine_repository.dart';
import '../datasources/wine_local_data_source.dart';

class WineRepositoryImpl implements WineRepository {
  final WineLocalDataSource localDataSource;

  WineRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Wine>> getLastWine() async {
    try {
      final wine = await localDataSource.getLastWine();
      return Right(wine);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async {
    try {
      final wines = await localDataSource.getAllWines();
      return Right(wines);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Wine>> updateWineStock(String wineName, int newStock) async {
    try {
      final wine = await localDataSource.updateWineStock(wineName, newStock);
      return Right(wine);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
