import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wine.dart';
import '../../domain/repositories/wine_repository.dart';
import '../datasources/wine_remote_data_source.dart';
import '../models/wine_model.dart';

class WineRepositoryImpl implements WineRepository {
  final WineRemoteDataSource remoteDataSource;

  WineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Wine>> getLastWine() async {
    try {
      final wine = await remoteDataSource.getLastCellarWine();
      if (wine != null) return Right(wine);
      return Left(CacheFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    }
  }

  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async {
    try {
      final wines = await remoteDataSource.getUserCellar();
      return Right(wines);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCellar(String cellarId) async {
    try {
      await remoteDataSource.removeFromCellar(cellarId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCellarStock(
      String cellarId, int stock) async {
    try {
      await remoteDataSource.updateCellarStock(cellarId, stock);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    }
  }

  @override
  Future<Either<Failure, Wine>> updateWineStock(String wineName, int newStock) async {
    try {
      await remoteDataSource.updateCellarStock(wineName, newStock);
      return Right(Wine(
        name: wineName,
        year: '',
        type: '',
        region: '',
        rating: 0,
        points: 0,
        apogee: '',
        stock: newStock,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
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
