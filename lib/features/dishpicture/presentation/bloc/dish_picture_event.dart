import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class DishPictureEvent extends Equatable {
  const DishPictureEvent();
  
  @override
  List<Object?> get props => [];
}

class TakePictureEvent extends DishPictureEvent {
  final String userId;

  const TakePictureEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UploadPictureEvent extends DishPictureEvent {
  final String userId;
  final String fileName;
  final Uint8List fileBytes;

  const UploadPictureEvent({
    required this.userId,
    required this.fileName,
    required this.fileBytes,
  });

  @override
  List<Object?> get props => [userId, fileName, fileBytes];
}

