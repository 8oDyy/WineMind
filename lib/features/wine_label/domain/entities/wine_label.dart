import 'package:equatable/equatable.dart';

class WineLabel extends Equatable {
  final String id;
  final String userId;
  final String fileName;
  final String filePath;
  final String storagePath;
  final DateTime createdAt;

  const WineLabel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.filePath,
    required this.storagePath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, fileName, filePath, storagePath, createdAt];
}
