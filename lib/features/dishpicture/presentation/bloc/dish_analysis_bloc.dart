import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/analyze_dish.dart';
import 'dish_analysis_event.dart';
import 'dish_analysis_state.dart';

class DishAnalysisBloc extends Bloc<DishAnalysisEvent, DishAnalysisState> {
  final AnalyzeDish analyzeDish;

  DishAnalysisBloc({
    required this.analyzeDish,
  }) : super(const DishAnalysisInitial()) {
    on<AnalyzeDishEvent>(_onAnalyzeDish);
  }

  Future<void> _onAnalyzeDish(
    AnalyzeDishEvent event,
    Emitter<DishAnalysisState> emit,
  ) async {
    emit(const DishAnalysisLoading());
    
    final result = await analyzeDish(event.filePath);
    
    result.fold(
      (failure) => emit(DishAnalysisError(failure.toString())),
      (response) => emit(DishAnalysisSuccess(response)),
    );
  }
}
