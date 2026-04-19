import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../network/api_constants.dart';
import 'storage_service.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myUserId) {
    final isMyMessage = json['sender_id'] == myUserId;
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'Unknown',
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isMe: isMyMessage,
    );
  }
}

class WebSocketService {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _messageController = StreamController<List<ChatMessage>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<List<ChatMessage>> get messages => _messageController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  List<ChatMessage> _cachedMessages = [];

  Future<bool> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(ApiConstants.wsChat));

      final accessToken = await StorageService.instance.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        _channel!.sink.add(jsonEncode({
          'type': 'auth',
          'token': accessToken,
        }));
      }

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _isConnected = true;
      _connectionController.add(true);
      return true;
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'history':
          final messages = (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>, ''))
              .toList() ??
              [];
          _cachedMessages = messages;
          _messageController.add(messages);
          break;

        case 'message':
          final newMessage = ChatMessage.fromJson(json, '');
          _cachedMessages = [..._cachedMessages, newMessage];
          _messageController.add(_cachedMessages);
          break;

        case 'error':
          final error = json['message'] as String? ?? 'Unknown error';
          debugPrint('WebSocket error: $error');
          break;
      }
    } catch (e) {
      debugPrint('WebSocket message parse error: $e');
    }
  }

  void _onError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  void _onDone() {
    _isConnected = false;
    _connectionController.add(false);
  }

  Future<void> sendMessage(String content) async {
    if (_channel == null || !_isConnected) {
      debugPrint('WebSocket not connected');
      return;
    }

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'message',
        'content': content,
      }));
    } catch (e) {
      debugPrint('WebSocket send error: $e');
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}