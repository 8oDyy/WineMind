import 'package:equatable/equatable.dart';
import '../../domain/entities/wine.dart';

abstract class WineDetailState extends Equatable {
  const WineDetailState();

  @override
  List<Object?> get props => [];
}

class WineDetailLoaded extends WineDetailState {
  final Wine wine;

  const WineDetailLoaded({required this.wine});

  @override
  List<Object?> get props => [wine];
}

class WineDetailError extends WineDetailState {
  final String message;

  const WineDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
