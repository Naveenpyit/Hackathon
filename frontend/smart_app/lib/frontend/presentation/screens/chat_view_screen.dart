import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../widgets/chat_components.dart';
import 'chats_screen.dart'; // To access ChatItem

class ChatMessage {
  final String text;
  final String time;
  final bool isSent;

  ChatMessage({required this.text, required this.time, required this.isSent});
}

class ChatViewScreen extends StatefulWidget {
  final ChatItem chat;

  const ChatViewScreen({super.key, required this.chat});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with some dummy messages
    _messages.addAll([
      ChatMessage(text: 'Hi there!', time: '10:00 AM', isSent: false),
      ChatMessage(text: 'How are you?', time: '10:01 AM', isSent: false),
      if (widget.chat.lastMessage.isNotEmpty)
        ChatMessage(text: widget.chat.lastMessage, time: widget.chat.timestamp, isSent: false),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        time: 'Just now',
        isSent: true,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate reply after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.insert(0, ChatMessage(
            text: 'I received: $text',
            time: 'Just now',
            isSent: false,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.chatBackground,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              name: widget.chat.name,
              status: widget.chat.isOnline ? 'Online' : 'Offline',
              avatar: widget.chat.avatar,
              avatarColor: widget.chat.avatarColor,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: _messages.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingM),
                                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (_isTyping && index == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              if (widget.chat.isGroup)
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: widget.chat.avatarColor,
                                                  child: Text(
                                                    widget.chat.avatar,
                                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 28),
                                              const SizedBox(width: 8),
                                              const TypingIndicator(),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final messageIndex = _isTyping ? index - 1 : index;
                                    final message = _messages[messageIndex];
                                    
                                    return MessageBubble(
                                      text: message.text,
                                      time: message.time,
                                      isSent: message.isSent,
                                      showAvatar: widget.chat.isGroup && !message.isSent,
                                      avatar: widget.chat.avatar,
                                      avatarColor: widget.chat.avatarColor,
                                    );
                                  },
                                ),
                        ),
                        ChatInput(onSend: _sendMessage),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: AppTheme.chatBubbleReceived,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXL,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          const Text(
            'Send a message to get started.',
            style: TextStyle(
              fontSize: AppTheme.fontSizeM,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
