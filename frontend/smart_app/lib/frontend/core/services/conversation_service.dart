import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_constants.dart';
import 'storage_service.dart';

/// Result wrapper for conversation-related calls.
class ConversationResult {
  final bool success;
  final String message;
  final String? conversationId;

  const ConversationResult({
    required this.success,
    required this.message,
    this.conversationId,
  });
}

/// Handles creating/fetching conversations between users.
///
/// Calls `POST /api/conversations` with the target user id.
/// Backend is expected to find an existing 1:1 conversation or create one
/// and return the conversation id.
class ConversationService {
  ConversationService._();
  static final ConversationService instance = ConversationService._();

  /// Starts a 1:1 conversation with [otherUserId] (user_details.id).
  Future<ConversationResult> startConversation(String otherUserId) async {
    try {
      final token = await StorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ConversationResult(
          success: false,
          message: 'Not signed in',
        );
      }

      final response = await http
          .post(
            Uri.parse(ApiConstants.conversations),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'participant_ids': [otherUserId],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.body.isEmpty) {
        return const ConversationResult(
          success: false,
          message: 'Empty response',
        );
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final int status = json['status'] as int? ?? 0;
      final String message = json['message'] as String? ?? '';

      if (status == 1 &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final data = json['data'];
        String? id;
        if (data is Map<String, dynamic>) {
          id = data['id']?.toString() ?? data['conversation_id']?.toString();
        }
        if (id == null || id.isEmpty) {
          return ConversationResult(
            success: false,
            message: message.isNotEmpty
                ? message
                : 'Conversation id missing in response',
          );
        }
        return ConversationResult(
          success: true,
          message: message,
          conversationId: id,
        );
      }

      return ConversationResult(
        success: false,
        message: message.isNotEmpty ? message : 'Failed to start conversation',
      );
    } on http.ClientException catch (e) {
      return ConversationResult(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (_) {
      return const ConversationResult(
        success: false,
        message: 'Unable to start conversation. Please try again.',
      );
    }
  }
}
