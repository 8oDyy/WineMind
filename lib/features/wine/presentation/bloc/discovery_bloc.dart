import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_discovery.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final GetDiscovery getDiscovery;

  DiscoveryBloc({required this.getDiscovery})
      : super(const DiscoveryInitial()) {
    on<LoadDiscoveryEvent>(_onLoadDiscovery);
  }

  Future<void> _onLoadDiscovery(
    LoadDiscoveryEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(const DiscoveryLoading());
    final result = await getDiscovery(const GetDiscoveryParams());
    result.fold(
      (failure) => emit(
        const DiscoveryError(
          message: 'Impossible de charger les découvertes pour le moment.',
        ),
      ),
      (categories) => emit(DiscoveryLoaded(categories: categories)),
    );
  }
}
