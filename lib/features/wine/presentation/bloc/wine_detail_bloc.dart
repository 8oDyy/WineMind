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
    final currentState = state;
    if (currentState is! WineDetailLoaded) return;

    final result = await updateWineStock(
      UpdateWineStockParams(
        cellarId: event.cellarId,
        newStock: event.newStock,
      ),
    );

    result.fold(
      (failure) => emit(const WineDetailError(message: 'Erreur de mise à jour du stock')),
      (_) => emit(WineDetailLoaded(
        wine: Wine(
          id: currentState.wine.id,
          cellarId: currentState.wine.cellarId,
          name: currentState.wine.name,
          year: currentState.wine.year,
          type: currentState.wine.type,
          region: currentState.wine.region,
          rating: currentState.wine.rating,
          points: currentState.wine.points,
          apogee: currentState.wine.apogee,
          stock: event.newStock,
          description: currentState.wine.description,
          designation: currentState.wine.designation,
          price: currentState.wine.price,
          province: currentState.wine.province,
          country: currentState.wine.country,
          variety: currentState.wine.variety,
          winery: currentState.wine.winery,
          location: currentState.wine.location,
          foodPairings: currentState.wine.foodPairings,
          bodyLevel: currentState.wine.bodyLevel,
          tanninLevel: currentState.wine.tanninLevel,
          fruitLevel: currentState.wine.fruitLevel,
          imageUrl: currentState.wine.imageUrl,
          notes: currentState.wine.notes,
          purchaseDate: currentState.wine.purchaseDate,
          purchasePrice: currentState.wine.purchasePrice,
        ),
      )),
    );
  }
}
