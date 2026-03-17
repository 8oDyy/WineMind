import 'package:equatable/equatable.dart';

class Wine extends Equatable {
  final String name;
  final String year;
  final String type;
  final String region;
  final double rating;
  final int points;
  final String apogee;
  final int stock;
  final String? classification;
  final String? subRegion;
  final double? alcohol;
  final List<String> grapes;
  final String? location;
  final List<String> foodPairings;
  final double bodyLevel;
  final double tanninLevel;
  final double fruitLevel;

  const Wine({
    required this.name,
    required this.year,
    required this.type,
    required this.region,
    required this.rating,
    required this.points,
    required this.apogee,
    required this.stock,
    this.classification,
    this.subRegion,
    this.alcohol,
    this.grapes = const [],
    this.location,
    this.foodPairings = const [],
    this.bodyLevel = 0.5,
    this.tanninLevel = 0.5,
    this.fruitLevel = 0.5,
  })  : assert(bodyLevel >= 0.0 && bodyLevel <= 1.0, 'bodyLevel must be between 0.0 and 1.0'),
        assert(tanninLevel >= 0.0 && tanninLevel <= 1.0, 'tanninLevel must be between 0.0 and 1.0'),
        assert(fruitLevel >= 0.0 && fruitLevel <= 1.0, 'fruitLevel must be between 0.0 and 1.0');

  @override
  List<Object?> get props => [
        name,
        year,
        type,
        region,
        rating,
        points,
        apogee,
        stock,
        classification,
        subRegion,
        alcohol,
        grapes,
        location,
        foodPairings,
        bodyLevel,
        tanninLevel,
        fruitLevel,
      ];
}
