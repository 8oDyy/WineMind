import 'package:equatable/equatable.dart';

class Wine extends Equatable {
  final String? id;
  final String? cellarId;
  final String name;
  final String year;
  final String type;
  final String region;
  final double rating;
  final int points;
  final String apogee;
  final int stock;
  final String? description;
  final String? designation;
  final double? price;
  final String? province;
  final String? country;
  final String? variety;
  final String? winery;
  final String? location;
  final List<String> foodPairings;
  final double bodyLevel;
  final double tanninLevel;
  final double fruitLevel;
  final String? imageUrl;
  final String? notes;
  final String? purchaseDate;
  final double? purchasePrice;

  const Wine({
    this.id,
    this.cellarId,
    required this.name,
    required this.year,
    required this.type,
    required this.region,
    required this.rating,
    required this.points,
    required this.apogee,
    required this.stock,
    this.description,
    this.designation,
    this.price,
    this.province,
    this.country,
    this.variety,
    this.winery,
    this.location,
    this.foodPairings = const [],
    this.bodyLevel = 0.5,
    this.tanninLevel = 0.5,
    this.fruitLevel = 0.5,
    this.imageUrl,
    this.notes,
    this.purchaseDate,
    this.purchasePrice,
  });

  @override
  List<Object?> get props => [
        id,
        cellarId,
        name,
        year,
        type,
        region,
        rating,
        points,
        apogee,
        stock,
        description,
        designation,
        price,
        province,
        country,
        variety,
        winery,
        location,
        foodPairings,
        bodyLevel,
        tanninLevel,
        fruitLevel,
        imageUrl,
        notes,
        purchaseDate,
        purchasePrice,
      ];
}
