import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wine_label.dart';
import '../repositories/wine_label_repository.dart';

class UploadWineLabel {
  final WineLabelRepository repository;

  UploadWineLabel(this.repository);

  Future<Either<Failure, WineLabel>> call(String userId, String fileName, Uint8List fileBytes) {
    return repository.uploadLabel(userId, fileName, fileBytes);
  }
}
