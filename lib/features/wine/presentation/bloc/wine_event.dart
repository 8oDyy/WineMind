import 'package:equatable/equatable.dart';

abstract class WineEvent extends Equatable {
  const WineEvent();

  @override
  List<Object?> get props => [];
}

class GetLastWineEvent extends WineEvent {
  const GetLastWineEvent();
}

class GetAllWinesEvent extends WineEvent {
  const GetAllWinesEvent();
}
