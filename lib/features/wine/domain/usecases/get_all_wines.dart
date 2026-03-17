import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wine.dart';
import '../repositories/wine_repository.dart';

class GetAllWines implements UseCase<List<Wine>, NoParams> {
  final WineRepository repository;

  GetAllWines(this.repository);

  @override
  Future<Either<Failure, List<Wine>>> call(NoParams params) {
    return repository.getAllWines();
  }
}
