import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    try {
      final response = await remoteDataSource.sendMessage(message, history);
      return Right(ChatMessage(
        content: response,
        role: ChatRole.assistant,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
