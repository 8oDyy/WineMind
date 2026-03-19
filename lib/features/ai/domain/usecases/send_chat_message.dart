import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

class SendChatMessage implements UseCase<ChatMessage, SendChatMessageParams> {
  final AiRepository repository;

  SendChatMessage(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendChatMessageParams params) {
    return repository.sendMessage(params.message, params.history);
  }
}

class SendChatMessageParams extends Equatable {
  final String message;
  final List<ChatMessage> history;

  const SendChatMessageParams({
    required this.message,
    this.history = const [],
  });

  @override
  List<Object?> get props => [message, history];
}
