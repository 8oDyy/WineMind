import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/enrich_wine.dart';
import '../../domain/usecases/update_wine_stock.dart';
import 'wine_detail_event.dart';
import 'wine_detail_state.dart';

class WineDetailBloc extends Bloc<WineDetailEvent, WineDetailState> {
  final UpdateWineStock updateWineStock;
  final EnrichWine enrichWine;

  WineDetailBloc({
    required Wine wine,
    required this.updateWineStock,
    required this.enrichWine,
  }) : super(WineDetailLoaded(wine: wine)) {
    on<UpdateStockEvent>(_onUpdateStock);
    on<EnrichWineEvent>(_onEnrichWine);
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
      (failure) =>
          emit(const WineDetailError(message: 'Erreur de mise à jour du stock')),
      (_) => emit(currentState.copyWith(
        wine: currentState.wine.copyWith(stock: event.newStock),
      )),
    );
  }

  Future<void> _onEnrichWine(
    EnrichWineEvent event,
    Emitter<WineDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WineDetailLoaded) return;

    final wine = currentState.wine;

    // Pas d'enrichissement pour un vin custom (sans wine_id catalogue),
    // ni si le vin est déjà enrichi.
    if (!wine.isCatalogWine || wine.isEnriched) return;

    emit(currentState.copyWith(isEnriching: true, enrichmentFailed: false));

    final result = await enrichWine(EnrichWineParams(wineId: wine.id!));

    result.fold(
      // Échec : on garde le vin tel quel, on coupe le loading et on signale
      // l'échec (la page affiche une SnackBar + bouton « Réessayer »).
      (failure) => emit(currentState.copyWith(
        isEnriching: false,
        enrichmentFailed: true,
      )),
      // Succès : fusion des champs catalogue enrichis dans le vin de cave
      // (on préserve cellarId/stock/notes/location/purchase* propres à la row).
      (enriched) => emit(WineDetailLoaded(
        wine: wine.copyWith(
          bodyLevel: enriched.bodyLevel,
          tanninLevel: enriched.tanninLevel,
          fruitLevel: enriched.fruitLevel,
          foodPairings: enriched.foodPairings,
          drinkFrom: enriched.drinkFrom,
          peakYear: enriched.peakYear,
          drinkTo: enriched.drinkTo,
          enrichedAt: enriched.enrichedAt,
          description: enriched.description,
          designation: enriched.designation,
          variety: enriched.variety,
          winery: enriched.winery,
          imageUrl: enriched.imageUrl,
        ),
        isEnriching: false,
      )),
    );
  }
}
