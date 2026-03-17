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

  const Wine({
    required this.name,
    required this.year,
    required this.type,
    required this.region,
    required this.rating,
    required this.points,
    required this.apogee,
    required this.stock,
  });

  @override
  List<Object?> get props => [name, year, type, region, rating, points, apogee, stock];
}
