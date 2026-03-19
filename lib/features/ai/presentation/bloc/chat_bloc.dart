import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatMessage sendChatMessage;

  ChatBloc({required this.sendChatMessage}) : super(const ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<AddAssistantMessageEvent>(_onAddAssistantMessage);
    on<ResetChatEvent>(_onReset);
  }

  void _onReset(ResetChatEvent event, Emitter<ChatState> emit) {
    emit(const ChatInitial());
  }

  void _onAddAssistantMessage(
    AddAssistantMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentMessages = state is ChatLoaded
        ? (state as ChatLoaded).messages
        : <ChatMessage>[];

    final assistantMessage = ChatMessage(
      content: event.message,
      role: ChatRole.assistant,
    );

    final updatedMessages = [...currentMessages, assistantMessage];
    emit(ChatLoaded(messages: updatedMessages));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentMessages = state is ChatLoaded
        ? (state as ChatLoaded).messages
        : <ChatMessage>[];

    final userMessage = ChatMessage(
      content: event.message,
      role: ChatRole.user,
    );

    final updatedMessages = [...currentMessages, userMessage];
    emit(ChatLoaded(messages: updatedMessages, isTyping: true));

    final result = await sendChatMessage(
      SendChatMessageParams(
        message: event.message,
        history: updatedMessages,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = ChatMessage(
          content: 'Désolé, une erreur est survenue. Réessayez.',
          role: ChatRole.assistant,
        );
        emit(ChatLoaded(messages: [...updatedMessages, errorMessage]));
      },
      (assistantMessage) {
        emit(ChatLoaded(messages: [...updatedMessages, assistantMessage]));
      },
    );
  }
}
