import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/dish_analysis_repository.dart';
import '../datasources/dish_analysis_remote_data_source.dart';

class DishAnalysisRepositoryImpl implements DishAnalysisRepository {
  final DishAnalysisRemoteDataSource remoteDataSource;

  DishAnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> analyzeDish(String filePath) async {
    try {
      final response = await remoteDataSource.analyzeDish(filePath);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.runtimeType}'));
    }
  }
}
