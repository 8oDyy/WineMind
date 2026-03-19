import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  final String content;
  final ChatRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [content, role];
}
