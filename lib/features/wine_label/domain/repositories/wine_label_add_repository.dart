import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine_proposal.dart';

abstract class WineLabelAddRepository {
  Future<Either<Failure, String>> addExistingWine(String userId, String wineId, int stock, String? notes, String? location);
  Future<Either<Failure, String>> addNewWine(String userId, WineProposal wineData, int stock, String? notes, String? location);
}
