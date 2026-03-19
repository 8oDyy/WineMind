import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine_analysis_result.dart';

abstract class WineLabelAnalysisRepository {
  Future<Either<Failure, WineAnalysisResult>> analyzeLabel(String filePath, String userId);
}
