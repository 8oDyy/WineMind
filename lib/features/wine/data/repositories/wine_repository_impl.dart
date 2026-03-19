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
        cellarId: wine.cellarId,
        name: wine.name,
        year: wine.year,
        type: wine.type,
        region: wine.region,
        rating: wine.rating,
        points: wine.points,
        apogee: wine.apogee,
        stock: wine.stock,
        description: wine.description,
        designation: wine.designation,
        price: wine.price,
        province: wine.province,
        country: wine.country,
        variety: wine.variety,
        winery: wine.winery,
        location: wine.location,
        foodPairings: wine.foodPairings,
        bodyLevel: wine.bodyLevel,
        tanninLevel: wine.tanninLevel,
        fruitLevel: wine.fruitLevel,
        imageUrl: wine.imageUrl,
        notes: wine.notes,
        purchaseDate: wine.purchaseDate,
        purchasePrice: wine.purchasePrice,
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

}
