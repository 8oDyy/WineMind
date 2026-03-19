import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dish_picture.dart';

abstract class DishPictureRepository {
  Future<Either<Failure, DishPicture>> uploadPicture(String userId, String fileName, Uint8List fileBytes);
}
