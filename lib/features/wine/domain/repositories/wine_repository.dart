import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine.dart';
import '../entities/wine_category.dart';

abstract class WineRepository {
  Future<Either<Failure, Wine>> getLastWine();
  Future<Either<Failure, List<Wine>>> getAllWines();

  /// Récupère les recommandations de la page Découvertes, groupées par
  /// catégorie (rows catalogue `wines`).
  Future<Either<Failure, List<WineCategory>>> getDiscovery({
    int limitPerCategory,
  });

  Future<Either<Failure, void>> addToCellar(Wine wine);
  Future<Either<Failure, void>> removeFromCellar(String cellarId);
  Future<Either<Failure, void>> updateCellarStock(String cellarId, int stock);

  /// Déclenche l'enrichissement IA d'un vin catalogue et renvoie le vin enrichi
  /// (champs catalogue : profil gustatif, accords, fenêtre de garde, enrichedAt).
  Future<Either<Failure, Wine>> enrichWine(String wineId);
}
