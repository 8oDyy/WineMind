import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine_proposal.dart';
import '../repositories/wine_label_add_repository.dart';

class AddWineToCellar {
  final WineLabelAddRepository repository;

  AddWineToCellar(this.repository);

  Future<Either<Failure, String>> addExistingWine(String userId, String wineId, int stock, String? notes, String? location) {
    return repository.addExistingWine(userId, wineId, stock, notes, location);
  }

  Future<Either<Failure, String>> addNewWine(String userId, WineProposal wineData, int stock, String? notes, String? location) {
    return repository.addNewWine(userId, wineData, stock, notes, location);
  }
}
