import 'package:equatable/equatable.dart';
import '../../domain/entities/wine_category.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {
  const DiscoveryInitial();
}

class DiscoveryLoading extends DiscoveryState {
  const DiscoveryLoading();
}

class DiscoveryLoaded extends DiscoveryState {
  final List<WineCategory> categories;

  const DiscoveryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError({required this.message});

  @override
  List<Object?> get props => [message];
}
