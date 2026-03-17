import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_wines.dart';
import '../../domain/usecases/get_last_wine.dart';
import 'wine_event.dart';
import 'wine_state.dart';

class WineBloc extends Bloc<WineEvent, WineState> {
  final GetLastWine getLastWine;
  final GetAllWines getAllWines;

  WineBloc({
    required this.getLastWine,
    required this.getAllWines,
  }) : super(const WineInitial()) {
    on<GetLastWineEvent>(_onGetLastWine);
    on<GetAllWinesEvent>(_onGetAllWines);
  }

  Future<void> _onGetLastWine(
    GetLastWineEvent event,
    Emitter<WineState> emit,
  ) async {
    emit(const WineLoading());
    final result = await getLastWine(NoParams());
    result.fold(
      (failure) => emit(const WineError('Impossible de charger le dernier vin.')),
      (wine) => emit(WineLastLoaded(wine)),
    );
  }

  Future<void> _onGetAllWines(
    GetAllWinesEvent event,
    Emitter<WineState> emit,
  ) async {
    emit(const WineLoading());
    final result = await getAllWines(NoParams());
    result.fold(
      (failure) => emit(const WineError('Impossible de charger les vins.')),
      (wines) => emit(WineAllLoaded(wines)),
    );
  }
}
