import '../../domain/entities/wine.dart';

class WineModel extends Wine {
  const WineModel({
    required super.name,
    required super.year,
    required super.type,
    required super.region,
    required super.rating,
    required super.points,
    required super.apogee,
    required super.stock,
    super.id,
    super.cellarId,
  });

  /// Construit un WineModel depuis une row `user_cellar` avec join `wines`.
  /// Structure attendue : { ...user_cellar_fields, wines: { ...catalog_fields } }
  factory WineModel.fromCellarJson(Map<String, dynamic> json) {
    final catalog = json['wines'] as Map<String, dynamic>?;

    return WineModel(
      cellarId: json['id'] as String?,
      id: json['wine_id'] as String? ?? catalog?['id'] as String?,
      name: json['custom_name'] as String? ??
          catalog?['name'] as String? ??
          'Inconnu',
      year: json['custom_year'] as String? ??
          (catalog?['year']?.toString() ?? ''),
      type: json['custom_type'] as String? ??
          catalog?['type'] as String? ??
          'Rouge',
      region: json['custom_region'] as String? ??
          catalog?['region'] as String? ??
          '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      points: json['custom_points'] as int? ??
          catalog?['points'] as int? ??
          0,
      apogee: json['apogee'] as String? ?? '',
      stock: json['stock'] as int? ?? 1,
    );
  }

  /// Construit un WineModel depuis une row du catalogue `wines` directement.
  factory WineModel.fromCatalogJson(Map<String, dynamic> json) {
    return WineModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Inconnu',
      year: json['year']?.toString() ?? '',
      type: json['type'] as String? ?? 'Rouge',
      region: json['region'] as String? ?? '',
      rating: 0.0,
      points: json['points'] as int? ?? 0,
      apogee: '',
      stock: json['stock'] as int? ?? 0,
    );
  }

  /// Ancien factory conservé pour compatibilité (données locales / tests).
  factory WineModel.fromJson(Map<String, dynamic> json) {
    return WineModel(
      name: json['name'] as String,
      year: json['year'] as String,
      type: json['type'] as String,
      region: json['region'] as String,
      rating: (json['rating'] as num).toDouble(),
      points: json['points'] as int,
      apogee: json['apogee'] as String,
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
      'type': type,
      'region': region,
      'rating': rating,
      'points': points,
      'apogee': apogee,
      'stock': stock,
    };
  }

  /// Sérialise pour INSERT dans user_cellar.
  Map<String, dynamic> toCellarInsert(String userId) {
    return {
      'user_id': userId,
      if (id != null) 'wine_id': id,
      if (id == null) 'custom_name': name,
      if (id == null) 'custom_year': year,
      if (id == null) 'custom_type': type,
      if (id == null) 'custom_region': region,
      if (id == null) 'custom_points': points,
      'stock': stock,
      'rating': rating,
      'apogee': apogee,
    };
  }
}
