import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine.dart';

abstract class WineRepository {
  Future<Either<Failure, Wine>> getLastWine();
  Future<Either<Failure, List<Wine>>> getAllWines();
  Future<Either<Failure, Wine>> updateWineStock(String wineName, int newStock);
}
