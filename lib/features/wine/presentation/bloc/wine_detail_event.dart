import 'package:equatable/equatable.dart';

abstract class WineDetailEvent extends Equatable {
  const WineDetailEvent();

  @override
  List<Object?> get props => [];
}

class UpdateStockEvent extends WineDetailEvent {
  final String wineName;
  final int newStock;

  const UpdateStockEvent({required this.wineName, required this.newStock});

  @override
  List<Object?> get props => [wineName, newStock];
}
