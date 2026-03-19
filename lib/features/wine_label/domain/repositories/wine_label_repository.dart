import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine_label.dart';

abstract class WineLabelRepository {
  Future<Either<Failure, WineLabel>> uploadLabel(String userId, String fileName, Uint8List fileBytes);
}
