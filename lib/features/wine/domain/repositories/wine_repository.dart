import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine.dart';

abstract class WineRepository {
  Future<Either<Failure, Wine>> getLastWine();
  Future<Either<Failure, List<Wine>>> getAllWines();
  Future<Either<Failure, void>> addToCellar(Wine wine);
  Future<Either<Failure, void>> removeFromCellar(String cellarId);
  Future<Either<Failure, void>> updateCellarStock(String cellarId, int stock);
}
