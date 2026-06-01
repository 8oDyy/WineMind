import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/add_wine_to_cellar.dart';
import '../../domain/usecases/enrich_wine.dart';
import '../../domain/usecases/update_wine_stock.dart';
import 'wine_detail_event.dart';
import 'wine_detail_state.dart';

class WineDetailBloc extends Bloc<WineDetailEvent, WineDetailState> {
  final UpdateWineStock updateWineStock;
  final EnrichWine enrichWine;
  final AddWineToCellar addWineToCellar;

  WineDetailBloc({
    required Wine wine,
    required this.updateWineStock,
    required this.enrichWine,
    required this.addWineToCellar,
  }) : super(WineDetailLoaded(wine: wine)) {
    on<UpdateStockEvent>(_onUpdateStock);
    on<EnrichWineEvent>(_onEnrichWine);
    on<AddToCellarEvent>(_onAddToCellar);
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
      (enriched) => emit(currentState.copyWith(
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

  Future<void> _onAddToCellar(
    AddToCellarEvent event,
    Emitter<WineDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WineDetailLoaded) return;

    // Déjà en cave ou ajout déjà fait : ne rien faire.
    if (currentState.wine.cellarId != null || currentState.addedToCellar) {
      return;
    }

    emit(currentState.copyWith(isAddingToCellar: true));

    // Stock par défaut à 1 pour un ajout depuis une reco (le vin venait du
    // catalogue avec stock 0). Le contrat `toCellarApiJson()` envoie `wine_id`.
    final result = await addWineToCellar(
      currentState.wine.copyWith(stock: 1),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(
        isAddingToCellar: false,
        addToCellarError: "Échec de l'ajout à la cave.",
      )),
      (_) => emit(currentState.copyWith(
        isAddingToCellar: false,
        addedToCellar: true,
      )),
    );
  }
}
