import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class AiRepository {
  Future<Either<Failure, ChatMessage>> sendMessage(
    String message,
    List<ChatMessage> history,
  );
}
