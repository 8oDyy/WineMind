import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wine.dart';
import '../../domain/repositories/wine_repository.dart';
import '../datasources/wine_local_data_source.dart';
import '../datasources/wine_remote_data_source.dart';
import '../models/wine_model.dart';

class WineRepositoryImpl implements WineRepository {
  final WineRemoteDataSource remoteDataSource;
  final WineLocalDataSource localDataSource;

  WineRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Wine>> getLastWine() async {
    try {
      final wine = await remoteDataSource.getLastCellarWine();
      if (wine != null) return Right(wine);
      // Cave vide → fallback local
      try {
        final localWine = await localDataSource.getLastWine();
        return Right(localWine);
      } on CacheException {
        return Left(CacheFailure());
      }
    } on ServerException {
      // Erreur réseau → fallback local
      try {
        final wine = await localDataSource.getLastWine();
        return Right(wine);
      } on CacheException {
        return Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async {
    try {
      final wines = await remoteDataSource.getUserCellar();
      return Right(wines);
    } on ServerException {
      // Fallback local
      try {
        final wines = await localDataSource.getAllWines();
        return Right(wines);
      } on CacheException {
        return Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> addToCellar(Wine wine) async {
    try {
      final model = WineModel(
        id: wine.id,
        name: wine.name,
        year: wine.year,
        type: wine.type,
        region: wine.region,
        rating: wine.rating,
        points: wine.points,
        apogee: wine.apogee,
        stock: wine.stock,
      );
      await remoteDataSource.addToCellar(model);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCellar(String cellarId) async {
    try {
      await remoteDataSource.removeFromCellar(cellarId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateCellarStock(
      String cellarId, int stock) async {
    try {
      await remoteDataSource.updateCellarStock(cellarId, stock);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
