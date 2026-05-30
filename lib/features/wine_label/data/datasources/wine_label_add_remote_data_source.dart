import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../dtos/add_wine_request_dto.dart';

abstract class WineLabelAddRemoteDataSource {
  Future<String> addWine(AddWineRequestDto request);
}

class WineLabelAddRemoteDataSourceImpl implements WineLabelAddRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SupabaseClient supabase;

  WineLabelAddRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.supabase,
  });

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) throw const ServerException('Utilisateur non connecté');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<String> addWine(AddWineRequestDto request) async {
    if (!request.isValid) {
      throw const ServerException('Requête invalide');
    }

    try {
      final requestBody = request.toJson();

      final response = await client.post(
        Uri.parse('$baseUrl/api/wine-label-add'),
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const ServerException(
          'Le serveur met trop de temps à répondre.',
        ),
      );

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
      throw ServerException('Ajout échoué: $e');
    }
  }
}
