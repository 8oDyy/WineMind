import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../dtos/add_wine_request_dto.dart';

abstract class WineLabelAddRemoteDataSource {
  Future<String> addWine(AddWineRequestDto request);
}

class WineLabelAddRemoteDataSourceImpl implements WineLabelAddRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  WineLabelAddRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<String> addWine(AddWineRequestDto request) async {
    if (!request.isValid) {
      throw const ServerException('Requête invalide');
    }

    try {
      final requestBody = request.toJson();
      print('🔍 DEBUG: Adding wine to cellar');
      print('🔍 DEBUG: Request URL: $baseUrl/api/wine-label-add');
      print('🔍 DEBUG: Request body: ${jsonEncode(requestBody)}');
      
      final response = await client.post(
        Uri.parse('$baseUrl/api/wine-label-add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const ServerException(
          'Le serveur met trop de temps à répondre.',
        ),
      );
      
      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse['message'] as String;
      } else {
        throw ServerException(
          'Erreur serveur: ${response.statusCode} - ${response.body}',
        );
      }
    } on ServerException catch (_) {
      rethrow;
    } catch (e) {
      print('🔍 DEBUG: Add wine error: $e');
      throw ServerException('Ajout échoué: $e');
    }
  }
}
