import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';

abstract class DishAnalysisRemoteDataSource {
  Future<String> analyzeDish(String filePath);
}

class DishAnalysisRemoteDataSourceImpl implements DishAnalysisRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  DishAnalysisRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<String> analyzeDish(String filePath) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/wine-pairing'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file_path': filePath,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const ServerException(
          'Le serveur met trop de temps à répondre.',
        ),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse['chat_response'] as String;
      } else {
        throw ServerException(
          'Erreur serveur: ${response.statusCode} - ${response.body}',
        );
      }
    } on ServerException catch (_) {
      rethrow;
    } catch (e) {
      throw ServerException('Analyse échouée: $e');
    }
  }
}
