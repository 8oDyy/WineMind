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

  const WineDetailLoaded({
    required this.wine,
    this.isEnriching = false,
    this.enrichmentFailed = false,
  });

  WineDetailLoaded copyWith({
    Wine? wine,
    bool? isEnriching,
    bool? enrichmentFailed,
  }) =>
      WineDetailLoaded(
        wine: wine ?? this.wine,
        isEnriching: isEnriching ?? this.isEnriching,
        enrichmentFailed: enrichmentFailed ?? this.enrichmentFailed,
      );

  @override
  List<Object?> get props => [wine, isEnriching, enrichmentFailed];
}

class WineDetailError extends WineDetailState {
  final String message;

  const WineDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
