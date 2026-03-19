import 'package:equatable/equatable.dart';
import 'dart:typed_data';
import '../../domain/entities/wine_proposal.dart';

abstract class WineLabelEvent extends Equatable {
  const WineLabelEvent();

  @override
  List<Object?> get props => [];
}

class TakeLabelPictureEvent extends WineLabelEvent {
  final String userId;

  const TakeLabelPictureEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UploadLabelPictureEvent extends WineLabelEvent {
  final String userId;
  final String fileName;
  final Uint8List fileBytes;

  const UploadLabelPictureEvent({
    required this.userId,
    required this.fileName,
    required this.fileBytes,
  });

  @override
  List<Object?> get props => [userId, fileName, fileBytes];
}

class AnalyzeLabelEvent extends WineLabelEvent {
  final String filePath;
  final String userId;

  const AnalyzeLabelEvent(this.filePath, this.userId);

  @override
  List<Object?> get props => [filePath, userId];
}

class AddWineToCellarEvent extends WineLabelEvent {
  final String userId;
  final String wineId;
  final bool isExistingWine;
  final WineProposal? wineData;
  final int stock;
  final String? notes;
  final String? location;

  const AddWineToCellarEvent({
    required this.userId,
    required this.wineId,
    required this.isExistingWine,
    this.wineData,
    this.stock = 1,
    this.notes,
    this.location,
  });

  @override
  List<Object?> get props => [userId, wineId, isExistingWine, wineData, stock, notes, location];
}

class CancelWineAddingEvent extends WineLabelEvent {
  const CancelWineAddingEvent();
}
