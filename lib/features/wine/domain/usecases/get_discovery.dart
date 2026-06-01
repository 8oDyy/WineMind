import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wine_category.dart';
import '../repositories/wine_repository.dart';

/// Récupère les recommandations de la page Découvertes, groupées par catégorie.
class GetDiscovery implements UseCase<List<WineCategory>, GetDiscoveryParams> {
  final WineRepository repository;

  GetDiscovery(this.repository);

  @override
  Future<Either<Failure, List<WineCategory>>> call(GetDiscoveryParams params) {
    return repository.getDiscovery(limitPerCategory: params.limitPerCategory);
  }
}

class GetDiscoveryParams extends Equatable {
  /// Nombre de vins demandés par catégorie (défaut 12, aligné sur le backend).
  final int limitPerCategory;

  const GetDiscoveryParams({this.limitPerCategory = 12});

  @override
  List<Object?> get props => [limitPerCategory];
}
