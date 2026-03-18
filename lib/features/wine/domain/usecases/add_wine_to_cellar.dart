import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wine.dart';
import '../repositories/wine_repository.dart';

class AddWineToCellar implements UseCase<void, Wine> {
  final WineRepository repository;

  AddWineToCellar(this.repository);

  @override
  Future<Either<Failure, void>> call(Wine params) {
    return repository.addToCellar(params);
  }
}
