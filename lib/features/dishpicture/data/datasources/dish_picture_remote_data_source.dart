import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/dish_picture.dart';

abstract class DishPictureRemoteDataSource {
  Future<DishPicture> uploadPicture(String userId, String fileName, Uint8List fileBytes);}

class DishPictureRemoteDataSourceImpl implements DishPictureRemoteDataSource {
  final SupabaseClient _client;

  DishPictureRemoteDataSourceImpl(this._client);

  @override
  Future<DishPicture> uploadPicture(String userId, String fileName, Uint8List fileBytes) async {
    try {
      // Upload file to Supabase storage
      final filePath = 'dishpicture/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _client.storage
          .from('dishpicture')
          .uploadBinary(filePath, fileBytes);

      // Get public URL
      final publicUrl = _client.storage
          .from('dishpicture')
          .getPublicUrl(filePath);

      // Save metadata to database
      final response = await _client
          .from('dish_pictures')
          .insert({
            'user_id': userId,
            'file_name': fileName,
            'file_path': filePath,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return DishPicture(
        id: response['id'],
        userId: response['user_id'],
        fileName: response['file_name'],
        filePath: publicUrl,
        storagePath: filePath,
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      throw ServerException('Upload failed: $e');
    }
  }
}
