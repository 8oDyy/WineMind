import '../../domain/entities/wine.dart';

class WineModel extends Wine {
  /// Échelle source des niveaux gustatifs (`body_level`/`tannin_level`/
  /// `fruit_level`) tels que renvoyés par l'API / stockés en base.
  ///
  /// Le backend renvoie ces niveaux déjà normalisés dans `[0, 1]`
  /// (cf. coordination tâches #6/#7), donc l'échelle vaut `1.0`. Si l'échelle
  /// source changeait (ex. 0–5 ou 0–100), ajuster cette seule constante.
  static const double gustativeScaleMax = 1.0;

  /// Normalise un niveau gustatif brut vers `[0, 1]`, ou `null` si absent.
  /// Le `clamp` final est un garde-fou : aucune valeur aberrante ne peut
  /// saturer / déborder le rendu, même si l'échelle source est mal estimée.
  static double? _normalizeLevel(dynamic raw) {
    if (raw is! num) return null;
    return (raw.toDouble() / gustativeScaleMax).clamp(0.0, 1.0);
  }

  const WineModel({
    super.id,
    super.cellarId,
    required super.name,
    required super.year,
    required super.type,
    required super.region,
    required super.rating,
    required super.points,
    required super.apogee,
    required super.stock,
    super.description,
    super.designation,
    super.price,
    super.province,
    super.country,
    super.variety,
    super.winery,
    super.location,
    super.foodPairings,
    super.bodyLevel,
    super.tanninLevel,
    super.fruitLevel,
    super.drinkFrom,
    super.peakYear,
    super.drinkTo,
    super.enrichedAt,
    super.imageUrl,
    super.notes,
    super.purchaseDate,
    super.purchasePrice,
  });

  /// Parse une année (`drink_from`/`peak_year`/`drink_to`) : accepte un int
  /// ou un numérique sous forme de String ('2025'), `null` sinon.
  static int? _parseYear(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  /// Construit un WineModel depuis une row `user_cellar` avec join `wines`.
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
      description: json['custom_description'] as String? ??
          catalog?['description'] as String?,
      designation: catalog?['designation'] as String?,
      price: json['custom_price'] != null
          ? (json['custom_price'] as num).toDouble()
          : catalog?['price'] != null
              ? (catalog!['price'] as num).toDouble()
              : null,
      province: catalog?['province'] as String?,
      country: catalog?['country'] as String?,
      variety: json['custom_variety'] as String? ??
          catalog?['variety'] as String?,
      winery: json['custom_winery'] as String? ??
          catalog?['winery'] as String?,
      location: json['location'] as String?,
      foodPairings: (catalog?['food_pairings'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      bodyLevel: _normalizeLevel(catalog?['body_level']),
      tanninLevel: _normalizeLevel(catalog?['tannin_level']),
      fruitLevel: _normalizeLevel(catalog?['fruit_level']),
      drinkFrom: _parseYear(catalog?['drink_from']),
      peakYear: _parseYear(catalog?['peak_year']),
      drinkTo: _parseYear(catalog?['drink_to']),
      enrichedAt: catalog?['enriched_at'] as String?,
      imageUrl: catalog?['image_url'] as String?,
      notes: json['notes'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      purchasePrice: json['purchase_price'] != null
          ? (json['purchase_price'] as num).toDouble()
          : null,
    );
  }

  /// Construit un WineModel depuis une row du catalogue `wines`.
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
      stock: 0,
      description: json['description'] as String?,
      designation: json['designation'] as String?,
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : null,
      province: json['province'] as String?,
      country: json['country'] as String?,
      variety: json['variety'] as String?,
      winery: json['winery'] as String?,
      foodPairings: (json['food_pairings'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      bodyLevel: _normalizeLevel(json['body_level']),
      tanninLevel: _normalizeLevel(json['tannin_level']),
      fruitLevel: _normalizeLevel(json['fruit_level']),
      drinkFrom: _parseYear(json['drink_from']),
      peakYear: _parseYear(json['peak_year']),
      drinkTo: _parseYear(json['drink_to']),
      enrichedAt: json['enriched_at'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Corps JSON pour POST /api/cellar (l'user_id est déduit du JWT côté serveur).
  Map<String, dynamic> toCellarApiJson() {
    return {
      if (id != null) 'wine_id': id,
      if (id == null) 'custom_name': name,
      if (id == null) 'custom_year': year,
      if (id == null) 'custom_type': type,
      if (id == null) 'custom_region': region,
      if (id == null) 'custom_points': points,
      'stock': stock,
      'rating': rating,
      'apogee': apogee,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
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
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
    };
  }
}
