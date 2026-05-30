import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wine_analysis_result.dart';
import '../mappers/wine_proposal_mapper.dart';

abstract class WineLabelAnalysisRemoteDataSource {
  Future<WineAnalysisResult> analyzeLabel(String filePath, String userId);
}

class WineLabelAnalysisRemoteDataSourceImpl implements WineLabelAnalysisRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SupabaseClient supabase;

  WineLabelAnalysisRemoteDataSourceImpl({
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
  Future<WineAnalysisResult> analyzeLabel(String filePath, String userId) async {
    try {
      final requestBody = {
        'file_path': filePath,
        'stock': 1,
      };

      final response = await client.post(
        Uri.parse('$baseUrl/api/wine-label-analysis'),
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

        // existing_proposal peut être null si le catalogue n'a aucune correspondance.
        final existingJson =
            jsonResponse['existing_proposal'] as Map<String, dynamic>?;

        return WineAnalysisResult(
          chatResponse: jsonResponse['chat_response'] as String,
          existingProposal: existingJson != null
              ? WineProposalMapper.fromJson(existingJson)
              : null,
          newProposal: WineProposalMapper.fromJson(jsonResponse['new_proposal'] as Map<String, dynamic>),
          wineAnalysis: WineProposalMapper.fromJson(jsonResponse['wine_analysis'] as Map<String, dynamic>),
        );
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
