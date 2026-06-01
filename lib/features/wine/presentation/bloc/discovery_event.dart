import 'package:equatable/equatable.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Charge (ou recharge) les recommandations de la page Découvertes.
class LoadDiscoveryEvent extends DiscoveryEvent {
  const LoadDiscoveryEvent();
}
