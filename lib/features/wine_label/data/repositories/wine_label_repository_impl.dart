import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wine_label.dart';
import '../../domain/repositories/wine_label_repository.dart';
import '../datasources/wine_label_remote_data_source.dart';

class WineLabelRepositoryImpl implements WineLabelRepository {
  final WineLabelRemoteDataSource remoteDataSource;

  WineLabelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WineLabel>> uploadLabel(String userId, String fileName, Uint8List fileBytes) async {
    try {
      final label = await remoteDataSource.uploadLabel(userId, fileName, fileBytes);
      return Right(label);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.runtimeType}'));
    }
  }
}
