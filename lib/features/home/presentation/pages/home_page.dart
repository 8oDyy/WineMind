import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ai/domain/entities/chat_message.dart';
import '../../../ai/presentation/bloc/chat_bloc.dart';
import '../../../ai/presentation/bloc/chat_event.dart';
import '../../../ai/presentation/bloc/chat_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getUserPrenom(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.prenom;
    }
    return '';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(message: text));
    _messageController.clear();
  }

  void _sendQuickAction(String message) {
    context.read<ChatBloc>().add(SendMessageEvent(message: message));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prenom = _getUserPrenom(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocListener<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) _scrollToBottom();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      _buildHeroSection(),
                      const SizedBox(height: 32),
                      _buildChatBubble(prenom),
                      const SizedBox(height: 16),
                      _buildChatMessages(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'WM',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryWine,
              fontStyle: FontStyle.italic,
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: AppColors.primaryWine.withValues(alpha: 0.15),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const Text(
            'WineMind',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        const Text(
          'Trouvez votre\naccord idéal.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Découvrez des vins parfaitement\nadaptés à vos goûts et à chaque occasion.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(String prenom) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cardAccent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryWine.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryWine,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: AppColors.primaryWine.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paul',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryWine,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bonjour${prenom.isNotEmpty ? ' "$prenom"' : ''}, \n'
                  'Moi, c\'est Paul, votre assistant sommelier.\n'
                  'Je suis là pour vous guider et vous aider à trouver le vin parfait.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessages() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is! ChatLoaded || state.messages.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            ...state.messages.map((msg) {
              final isUser = msg.role == ChatRole.user;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.cardAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                AppColors.primaryWine.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primaryWine,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primaryWine
                              : const Color(0xFFFDF2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            fontSize: 13.5,
                            color:
                                isUser ? Colors.white : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (state.isTyping)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cardAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryWine.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryWine,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryWine.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Paul écrit...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('Voir ma cave', Icons.wine_bar),
      ('Conseil du jour', Icons.lightbulb_outline),
      ('Accords mets', Icons.restaurant_menu),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final (label, icon) = actions[index];
          return GestureDetector(
            onTap: () => _sendQuickAction(label),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryWine.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: AppColors.primaryWine),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryWine,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Implement camera / scan feature
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryWine,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Demandez à votre sommelier...',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryWine,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
