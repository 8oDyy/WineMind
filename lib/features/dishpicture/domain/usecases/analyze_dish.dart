import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/dish_analysis_repository.dart';

class AnalyzeDish {
  final DishAnalysisRepository repository;

  AnalyzeDish(this.repository);

  Future<Either<Failure, String>> call(String filePath) {
    return repository.analyzeDish(filePath);
  }
}
