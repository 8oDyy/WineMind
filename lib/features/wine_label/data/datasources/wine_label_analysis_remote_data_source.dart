import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wine_analysis_result.dart';
import '../mappers/wine_proposal_mapper.dart';

abstract class WineLabelAnalysisRemoteDataSource {
  Future<WineAnalysisResult> analyzeLabel(String filePath, String userId);
}

class WineLabelAnalysisRemoteDataSourceImpl implements WineLabelAnalysisRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  WineLabelAnalysisRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<WineAnalysisResult> analyzeLabel(String filePath, String userId) async {
    try {
      print('🔍 DEBUG: Starting wine label analysis');
      print('🔍 DEBUG: File path: $filePath');
      print('🔍 DEBUG: User ID: $userId');
      print('🔍 DEBUG: Request URL: $baseUrl/api/wine-label-analysis');
      
      final requestBody = {
        'file_path': filePath,
        'user_id': userId,
        'stock': 1,
      };
      print('🔍 DEBUG: Request body: ${jsonEncode(requestBody)}');
      
      final response = await client.post(
        Uri.parse('$baseUrl/api/wine-label-analysis'),
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
        print('🔍 DEBUG: Parsed JSON response successfully');
        
        return WineAnalysisResult(
          chatResponse: jsonResponse['chat_response'] as String,
          existingProposal: WineProposalMapper.fromJson(jsonResponse['existing_proposal'] as Map<String, dynamic>),
          newProposal: WineProposalMapper.fromJson(jsonResponse['new_proposal'] as Map<String, dynamic>),
          wineAnalysis: WineProposalMapper.fromJson(jsonResponse['wine_analysis'] as Map<String, dynamic>),
        );
      } else {
        print('🔍 DEBUG: Server error response');
        throw ServerException(
          'Erreur serveur: ${response.statusCode} - ${response.body}',
        );
      }
    } on ServerException catch (_) {
      rethrow;
    } catch (e) {
      print('🔍 DEBUG: Analysis error: $e');
      throw ServerException('Analyse échouée: $e');
    }
  }
}
