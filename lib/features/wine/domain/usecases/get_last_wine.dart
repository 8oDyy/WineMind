import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wine.dart';
import '../repositories/wine_repository.dart';

class GetLastWine implements UseCase<Wine, NoParams> {
  final WineRepository repository;

  GetLastWine(this.repository);

  @override
  Future<Either<Failure, Wine>> call(NoParams params) {
    return repository.getLastWine();
  }
}
