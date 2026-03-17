import 'package:equatable/equatable.dart';
import '../../domain/entities/wine.dart';

abstract class WineState extends Equatable {
  const WineState();

  @override
  List<Object?> get props => [];
}

class WineInitial extends WineState {
  const WineInitial();
}

class WineLoading extends WineState {
  const WineLoading();
}

class WineLastLoaded extends WineState {
  final Wine wine;

  const WineLastLoaded(this.wine);

  @override
  List<Object?> get props => [wine];
}

class WineAllLoaded extends WineState {
  final List<Wine> wines;

  const WineAllLoaded(this.wines);

  @override
  List<Object?> get props => [wines];
}

class WineError extends WineState {
  final String message;

  const WineError(this.message);

  @override
  List<Object?> get props => [message];
}
