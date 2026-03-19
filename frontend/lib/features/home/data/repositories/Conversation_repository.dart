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
}
