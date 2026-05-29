import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine_analysis_result.dart';
import '../repositories/wine_label_analysis_repository.dart';

class AnalyzeWineLabel {
  final WineLabelAnalysisRepository repository;

  AnalyzeWineLabel(this.repository);

  Future<Either<Failure, WineAnalysisResult>> call(String filePath, String userId) {
    return repository.analyzeLabel(filePath, userId);
  }
}
