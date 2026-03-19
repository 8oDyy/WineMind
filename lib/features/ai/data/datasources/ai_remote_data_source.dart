import '../../domain/entities/chat_message.dart';

abstract class AiRemoteDataSource {
  Future<String> sendMessage(String message, List<ChatMessage> history);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  // TODO: Inject OpenAI API key via environment or secure config
  final String? apiKey;

  AiRemoteDataSourceImpl({this.apiKey});

  @override
  Future<String> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return 'Je suis Paul, votre sommelier virtuel. '
          'Mon cerveau IA n\'est pas encore connecté, '
          'mais je serai bientôt prêt à vous conseiller !';
    }

    // TODO: Implement OpenAI API call here
    // Use apiKey to authenticate with the OpenAI API
    // Send message + history as conversation context
    throw UnimplementedError('OpenAI integration not yet configured');
  }
}
