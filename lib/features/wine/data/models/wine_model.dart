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
}
