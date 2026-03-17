import 'package:equatable/equatable.dart';

abstract class CellarEvent extends Equatable {
  const CellarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCellarEvent extends CellarEvent {
  const LoadCellarEvent();
}

class FilterWinesByTypeEvent extends CellarEvent {
  final String type;

  const FilterWinesByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class SearchWinesEvent extends CellarEvent {
  final String query;

  const SearchWinesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
