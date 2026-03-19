import 'package:equatable/equatable.dart';

abstract class DishAnalysisEvent extends Equatable {
  const DishAnalysisEvent();
  
  @override
  List<Object?> get props => [];
}

class AnalyzeDishEvent extends DishAnalysisEvent {
  final String filePath;

  const AnalyzeDishEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
