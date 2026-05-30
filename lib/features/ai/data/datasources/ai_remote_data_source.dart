import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message.dart';

abstract class AiRemoteDataSource {
  Future<String> sendMessage(String message, List<ChatMessage> history);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AiRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = AppConfig.apiBaseUrl,
  });

  @override
  Future<String> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    final body = jsonEncode({
      'message': message,
      'history': history
          .map((m) => {
                'role': m.role == ChatRole.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList(),
    });

    final response = await client.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw const ServerException(
        'Le serveur met trop de temps à répondre.',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String? ?? 'Réponse vide du serveur.';
    } else {
      throw ServerException(
        'Erreur serveur: ${response.statusCode}',
      );
    }
  }
}
