import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wine_label.dart';

abstract class WineLabelRemoteDataSource {
  Future<WineLabel> uploadLabel(String userId, String fileName, Uint8List fileBytes);
}

class WineLabelRemoteDataSourceImpl implements WineLabelRemoteDataSource {
  final SupabaseClient _client;

  WineLabelRemoteDataSourceImpl(this._client);

  @override
  Future<WineLabel> uploadLabel(String userId, String fileName, Uint8List fileBytes) async {
    try {
      // Upload file to Supabase storage
      final filePath = 'wine-labels/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _client.storage
          .from('wine-labels')
          .uploadBinary(filePath, fileBytes);

      // Get public URL
      final publicUrl = _client.storage
          .from('wine-labels')
          .getPublicUrl(filePath);

      // Save metadata to database
      final response = await _client
          .from('wine_labels')
          .insert({
            'user_id': userId,
            'file_name': fileName,
            'file_path': filePath,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return WineLabel(
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
