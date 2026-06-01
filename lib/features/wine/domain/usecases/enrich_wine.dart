import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wine.dart';
import '../repositories/wine_repository.dart';

class EnrichWine implements UseCase<Wine, EnrichWineParams> {
  final WineRepository repository;

  EnrichWine(this.repository);

  @override
  Future<Either<Failure, Wine>> call(EnrichWineParams params) {
    return repository.enrichWine(params.wineId);
  }
}

class EnrichWineParams extends Equatable {
  final String wineId;

  const EnrichWineParams({required this.wineId});

  @override
  List<Object?> get props => [wineId];
}
