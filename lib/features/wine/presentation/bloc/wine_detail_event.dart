import 'package:equatable/equatable.dart';

abstract class WineDetailEvent extends Equatable {
  const WineDetailEvent();

  @override
  List<Object?> get props => [];
}

class UpdateStockEvent extends WineDetailEvent {
  final String cellarId;
  final int newStock;

  const UpdateStockEvent({required this.cellarId, required this.newStock});

  @override
  List<Object?> get props => [cellarId, newStock];
}

/// Déclenche l'enrichissement IA du vin courant (à l'ouverture de la fiche).
class EnrichWineEvent extends WineDetailEvent {
  const EnrichWineEvent();
}
