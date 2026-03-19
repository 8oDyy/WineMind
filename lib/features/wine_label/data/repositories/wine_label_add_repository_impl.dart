import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wine_proposal.dart';
import '../../domain/repositories/wine_label_add_repository.dart';
import '../datasources/wine_label_add_remote_data_source.dart';
import '../dtos/add_wine_request_dto.dart';

class WineLabelAddRepositoryImpl implements WineLabelAddRepository {
  final WineLabelAddRemoteDataSource remoteDataSource;

  WineLabelAddRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> addExistingWine(String userId, String wineId, int stock, String? notes, String? location) async {
    try {
      final request = AddWineRequestDto.forExistingWine(
        userId: userId,
        wineId: wineId,
        stock: stock,
        notes: notes,
        location: location,
      );
      final result = await remoteDataSource.addWine(request);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.runtimeType}'));
    }
  }

  @override
  Future<Either<Failure, String>> addNewWine(String userId, WineProposal wineData, int stock, String? notes, String? location) async {
    try {
      final request = AddWineRequestDto.forNewWine(
        userId: userId,
        wineData: wineData,
        stock: stock,
        notes: notes,
        location: location,
      );
      final result = await remoteDataSource.addWine(request);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.runtimeType}'));
    }
  }
}
