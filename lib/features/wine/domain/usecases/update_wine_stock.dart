import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wine.dart';
import '../repositories/wine_repository.dart';

class UpdateWineStock implements UseCase<Wine, UpdateWineStockParams> {
  final WineRepository repository;

  UpdateWineStock(this.repository);

  @override
  Future<Either<Failure, Wine>> call(UpdateWineStockParams params) {
    return repository.updateWineStock(params.wineName, params.newStock);
  }
}

class UpdateWineStockParams extends Equatable {
  final String wineName;
  final int newStock;

  const UpdateWineStockParams({
    required this.wineName,
    required this.newStock,
  });

  @override
  List<Object?> get props => [wineName, newStock];
}
