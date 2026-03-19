import 'package:equatable/equatable.dart';

class WineProposal extends Equatable {
  final String? id;
  final String name;
  final String winery;
  final int year;
  final String region;
  final String country;
  final String? variety;
  final String? type;
  final double? alcoholPercentage;
  final String? description;
  final String? designation;
  final String? province;
  final double? price;
  final int? points;
  final double? bodyLevel;
  final double? tanninLevel;
  final double? fruitLevel;
  final List<String>? foodPairings;
  final double confidence;
  final String matchType;
  final double matchConfidence;

  const WineProposal({
    this.id,
    required this.name,
    required this.winery,
    required this.year,
    required this.region,
    required this.country,
    this.variety,
    this.type,
    this.alcoholPercentage,
    this.description,
    this.designation,
    this.province,
    this.price,
    this.points,
    this.bodyLevel,
    this.tanninLevel,
    this.fruitLevel,
    this.foodPairings,
    required this.confidence,
    required this.matchType,
    required this.matchConfidence,
  });

  
  @override
  List<Object?> get props => [
        id,
        name,
        winery,
        year,
        region,
        country,
        variety,
        type,
        alcoholPercentage,
        description,
        designation,
        province,
        price,
        points,
        bodyLevel,
        tanninLevel,
        fruitLevel,
        foodPairings,
        confidence,
        matchType,
        matchConfidence,
      ];
}
