import 'package:equatable/equatable.dart';
import '../../domain/entities/wine.dart';

abstract class CellarState extends Equatable {
  const CellarState();

  @override
  List<Object?> get props => [];
}

class CellarInitial extends CellarState {
  const CellarInitial();
}

class CellarLoading extends CellarState {
  const CellarLoading();
}

class CellarLoaded extends CellarState {
  final List<Wine> allWines;
  final List<Wine> filteredWines;
  final String selectedType;
  final String searchQuery;

  const CellarLoaded({
    required this.allWines,
    required this.filteredWines,
    required this.selectedType,
    required this.searchQuery,
  });

  CellarLoaded copyWith({
    List<Wine>? allWines,
    List<Wine>? filteredWines,
    String? selectedType,
    String? searchQuery,
  }) {
    return CellarLoaded(
      allWines: allWines ?? this.allWines,
      filteredWines: filteredWines ?? this.filteredWines,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allWines, filteredWines, selectedType, searchQuery];
}

class CellarError extends CellarState {
  final String message;

  const CellarError(this.message);

  @override
  List<Object?> get props => [message];
}
