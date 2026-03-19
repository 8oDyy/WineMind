import 'package:equatable/equatable.dart';

abstract class DishAnalysisState extends Equatable {
  const DishAnalysisState();
  
  @override
  List<Object?> get props => [];
}

class DishAnalysisInitial extends DishAnalysisState {
  const DishAnalysisInitial();
}

class DishAnalysisLoading extends DishAnalysisState {
  const DishAnalysisLoading();
}

class DishAnalysisSuccess extends DishAnalysisState {
  final String chatResponse;

  const DishAnalysisSuccess(this.chatResponse);

  @override
  List<Object?> get props => [chatResponse];
}

class DishAnalysisError extends DishAnalysisState {
  final String message;

  const DishAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
