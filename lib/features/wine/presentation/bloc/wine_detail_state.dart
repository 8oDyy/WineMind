import 'package:equatable/equatable.dart';
import '../../domain/entities/wine.dart';

abstract class WineDetailState extends Equatable {
  const WineDetailState();

  @override
  List<Object?> get props => [];
}

class WineDetailLoaded extends WineDetailState {
  final Wine wine;

  /// Vrai pendant la génération IA du profil (radar/apogée/accords en loading).
  final bool isEnriching;

  /// Vrai si la dernière tentative d'enrichissement a échoué (→ SnackBar +
  /// bouton « Réessayer »). Réinitialisé à chaque nouvelle tentative.
  final bool enrichmentFailed;

  /// Vrai pendant l'ajout du vin à la cave (contexte Découvertes : bouton en
  /// loading). Pertinent seulement quand `wine.cellarId == null`.
  final bool isAddingToCellar;

  /// Vrai une fois le vin ajouté à la cave avec succès (→ SnackBar de
  /// confirmation, bouton désactivé).
  final bool addedToCellar;

  /// Message d'échec d'ajout à la cave (→ SnackBar), `null` sinon.
  final String? addToCellarError;

  const WineDetailLoaded({
    required this.wine,
    this.isEnriching = false,
    this.enrichmentFailed = false,
    this.isAddingToCellar = false,
    this.addedToCellar = false,
    this.addToCellarError,
  });

  WineDetailLoaded copyWith({
    Wine? wine,
    bool? isEnriching,
    bool? enrichmentFailed,
    bool? isAddingToCellar,
    bool? addedToCellar,
    String? addToCellarError,
  }) =>
      WineDetailLoaded(
        wine: wine ?? this.wine,
        isEnriching: isEnriching ?? this.isEnriching,
        enrichmentFailed: enrichmentFailed ?? this.enrichmentFailed,
        isAddingToCellar: isAddingToCellar ?? this.isAddingToCellar,
        addedToCellar: addedToCellar ?? this.addedToCellar,
        addToCellarError: addToCellarError,
      );

  @override
  List<Object?> get props => [
        wine,
        isEnriching,
        enrichmentFailed,
        isAddingToCellar,
        addedToCellar,
        addToCellarError,
      ];
}

class WineDetailError extends WineDetailState {
  final String message;

  const WineDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
