import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dish_picture.dart';
import '../repositories/dish_picture_repository.dart';

class UploadPicture {
  final DishPictureRepository repository;

  UploadPicture(this.repository);

  Future<Either<Failure, DishPicture>> call(String userId, String fileName, Uint8List fileBytes) {
    return repository.uploadPicture(userId, fileName, fileBytes);
  }
}
