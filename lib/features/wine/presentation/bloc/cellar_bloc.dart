import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/get_all_wines.dart';
import 'cellar_event.dart';
import 'cellar_state.dart';

class CellarBloc extends Bloc<CellarEvent, CellarState> {
  final GetAllWines getAllWines;

  CellarBloc({
    required this.getAllWines,
  }) : super(const CellarInitial()) {
    on<LoadCellarEvent>(_onLoadCellar);
    on<FilterWinesByTypeEvent>(_onFilterWinesByType);
    on<SearchWinesEvent>(_onSearchWines);
  }

  Future<void> _onLoadCellar(
    LoadCellarEvent event,
    Emitter<CellarState> emit,
  ) async {
    emit(const CellarLoading());
    final result = await getAllWines(NoParams());
    result.fold(
      (failure) => emit(const CellarError('Impossible de charger les vins.')),
      (wines) => emit(CellarLoaded(
        allWines: wines,
        filteredWines: wines,
        selectedType: 'Tous',
        searchQuery: '',
      )),
    );
  }

  void _onFilterWinesByType(
    FilterWinesByTypeEvent event,
    Emitter<CellarState> emit,
  ) {
    if (state is CellarLoaded) {
      final current = state as CellarLoaded;
      final filtered = _applyFilters(
        current.allWines,
        event.type,
        current.searchQuery,
      );
      emit(current.copyWith(
        filteredWines: filtered,
        selectedType: event.type,
      ));
    }
  }

  void _onSearchWines(
    SearchWinesEvent event,
    Emitter<CellarState> emit,
  ) {
    if (state is CellarLoaded) {
      final current = state as CellarLoaded;
      final filtered = _applyFilters(
        current.allWines,
        current.selectedType,
        event.query,
      );
      emit(current.copyWith(
        filteredWines: filtered,
        searchQuery: event.query,
      ));
    }
  }

  List<Wine> _applyFilters(List<Wine> allWines, String type, String query) {
    var result = allWines;
    if (type != 'Tous') {
      result = result.where((w) => w.type == type).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((w) => '${w.name} ${w.year}'.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }
}
