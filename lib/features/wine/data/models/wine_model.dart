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
    super.classification,
    super.subRegion,
    super.alcohol,
    super.grapes,
    super.location,
    super.foodPairings,
    super.bodyLevel,
    super.tanninLevel,
    super.fruitLevel,
  });

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
      classification: json['classification'] as String?,
      subRegion: json['subRegion'] as String?,
      alcohol: json['alcohol'] != null ? (json['alcohol'] as num).toDouble() : null,
      grapes: (json['grapes'] as List<dynamic>?)?.cast<String>() ?? const [],
      location: json['location'] as String?,
      foodPairings: (json['foodPairings'] as List<dynamic>?)?.cast<String>() ?? const [],
      bodyLevel: json['bodyLevel'] != null ? (json['bodyLevel'] as num).toDouble() : 0.5,
      tanninLevel: json['tanninLevel'] != null ? (json['tanninLevel'] as num).toDouble() : 0.5,
      fruitLevel: json['fruitLevel'] != null ? (json['fruitLevel'] as num).toDouble() : 0.5,
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
      'classification': classification,
      'subRegion': subRegion,
      'alcohol': alcohol,
      'grapes': grapes,
      'location': location,
      'foodPairings': foodPairings,
      'bodyLevel': bodyLevel,
      'tanninLevel': tanninLevel,
      'fruitLevel': fruitLevel,
    };
  }
}
