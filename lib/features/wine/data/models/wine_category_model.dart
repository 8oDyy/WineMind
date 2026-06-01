import '../../domain/entities/wine_category.dart';
import 'wine_model.dart';

class WineCategoryModel extends WineCategory {
  const WineCategoryModel({
    required super.key,
    required super.title,
    super.subtitle,
    super.wines,
  });

  /// Parse une catégorie de la réponse `GET /api/discovery`.
  ///
  /// Forme attendue (contrat back↔front figé) :
  /// `{ "key", "title", "subtitle"|null, "wines": [ <row `wines` brute> ] }`.
  /// Chaque vin est une row catalogue brute → `WineModel.fromCatalogJson`.
  factory WineCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawWines = json['wines'] as List<dynamic>? ?? const [];
    return WineCategoryModel(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      wines: rawWines
          .map((e) => WineModel.fromCatalogJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
