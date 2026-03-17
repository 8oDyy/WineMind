import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/update_wine_stock.dart';
import 'wine_detail_event.dart';
import 'wine_detail_state.dart';

class WineDetailBloc extends Bloc<WineDetailEvent, WineDetailState> {
  final UpdateWineStock updateWineStock;

  WineDetailBloc({
    required Wine wine,
    required this.updateWineStock,
  }) : super(WineDetailLoaded(wine: wine)) {
    on<UpdateStockEvent>(_onUpdateStock);
  }

  Future<void> _onUpdateStock(
    UpdateStockEvent event,
    Emitter<WineDetailState> emit,
  ) async {
    final result = await updateWineStock(
      UpdateWineStockParams(
        wineName: event.wineName,
        newStock: event.newStock,
      ),
    );

    result.fold(
      (failure) => emit(const WineDetailError(message: 'Erreur de mise à jour du stock')),
      (updatedWine) => emit(WineDetailLoaded(wine: updatedWine)),
    );
  }
}
