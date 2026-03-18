import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wine_repository.dart';

class RemoveWineFromCellar implements UseCase<void, RemoveWineParams> {
  final WineRepository repository;

  RemoveWineFromCellar(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveWineParams params) {
    return repository.removeFromCellar(params.cellarId);
  }
}

class RemoveWineParams extends Equatable {
  final String cellarId;

  const RemoveWineParams({required this.cellarId});

  @override
  List<Object?> get props => [cellarId];
}
