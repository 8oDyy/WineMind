import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wine_repository.dart';

class UpdateWineStock implements UseCase<void, UpdateWineStockParams> {
  final WineRepository repository;

  UpdateWineStock(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateWineStockParams params) {
    return repository.updateCellarStock(params.cellarId, params.newStock);
  }
}

class UpdateWineStockParams extends Equatable {
  final String cellarId;
  final int newStock;

  const UpdateWineStockParams({
    required this.cellarId,
    required this.newStock,
  });

  @override
  List<Object?> get props => [cellarId, newStock];
}
