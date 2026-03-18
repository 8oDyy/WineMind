import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wine_repository.dart';

class UpdateCellarStock implements UseCase<void, UpdateStockParams> {
  final WineRepository repository;

  UpdateCellarStock(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStockParams params) {
    return repository.updateCellarStock(params.cellarId, params.stock);
  }
}

class UpdateStockParams extends Equatable {
  final String cellarId;
  final int stock;

  const UpdateStockParams({required this.cellarId, required this.stock});

  @override
  List<Object?> get props => [cellarId, stock];
}
