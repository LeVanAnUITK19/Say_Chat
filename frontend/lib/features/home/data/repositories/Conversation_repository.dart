import '../api/conversation_api.dart';

class ConversationRepository {
  final ConversationAPI _conversationAPI = ConversationAPI();

  Future<List<dynamic>> getConversations() async {
    return await _conversationAPI.getConversations();
  }
  Future<List<dynamic>> getConversationGroupInfo() async {
    return await _conversationAPI.getConversationGroupInfo();
  }

  Future<Map<String, dynamic>> createConversation({
    required String type,
    required List<String> memberIds,
    String? name,
  }) async {
    return await _conversationAPI.createConversation(
      type: type,
      memberIds: memberIds,
      name: name,
    );
  }

  Future<String> getCurrentUser() async {
    return await _conversationAPI.getCurrentUser();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String recipientId,
    required String content,
    required String username,
    String? type,
    List<Map<String, dynamic>>? attachments,
  }) async {
    return await _conversationAPI.sendMessage(
      conversationId: conversationId,
      recipientId: recipientId,
      content: content,
      username: username,
      type: type,
      attachments: attachments,
    );
  }
}
