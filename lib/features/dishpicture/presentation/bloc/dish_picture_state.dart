import 'package:equatable/equatable.dart';
import '../../domain/entities/dish_picture.dart';

abstract class DishPictureState extends Equatable {
  const DishPictureState();
  
  @override
  List<Object?> get props => [];
}

class DishPictureInitial extends DishPictureState {
  const DishPictureInitial();
}

class DishPictureLoading extends DishPictureState {
  const DishPictureLoading();
}

class PictureTaken extends DishPictureState {
  final String imagePath;

  const PictureTaken(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class PictureUploadSuccess extends DishPictureState {
  final DishPicture picture;

  const PictureUploadSuccess(this.picture);

  @override
  List<Object?> get props => [picture];
}


class DishPictureError extends DishPictureState {
  final String message;

  const DishPictureError(this.message);

  @override
  List<Object?> get props => [message];
}
