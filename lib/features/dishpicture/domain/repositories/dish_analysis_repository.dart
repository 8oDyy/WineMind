import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class DishAnalysisRepository {
  Future<Either<Failure, String>> analyzeDish(String filePath);
}
