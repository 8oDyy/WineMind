import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wine_analysis_result.dart';
import '../../domain/repositories/wine_label_analysis_repository.dart';
import '../datasources/wine_label_analysis_remote_data_source.dart';

class WineLabelAnalysisRepositoryImpl implements WineLabelAnalysisRepository {
  final WineLabelAnalysisRemoteDataSource remoteDataSource;

  WineLabelAnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WineAnalysisResult>> analyzeLabel(String filePath, String userId) async {
    try {
      final result = await remoteDataSource.analyzeLabel(filePath, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.runtimeType}'));
    }
  }
}
