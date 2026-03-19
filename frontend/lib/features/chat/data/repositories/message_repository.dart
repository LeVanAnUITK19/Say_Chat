import '../api/message_api.dart';
import '../model/message.dart';

class MessageRepository {
  final MessageAPI _messageAPI = MessageAPI();

  Future<List<Message>> getMessages(String conversationId, {int limit = 100, String? cursor}) async {
    final data = await _messageAPI.getMessages(conversationId, limit: limit, cursor: cursor);
    return data.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String recipientId,
    required String content,
    required String username,
    String? type,
    List<MessageAttachment>? attachments,
  }) async {
    final data = await _messageAPI.sendMessage(
      conversationId: conversationId,
      recipientId: recipientId,
      content: content,
      username: username,
      type: type,
      attachments: attachments?.map((e) => e.toJson()).toList(),
    );
    return Message.fromJson(data);
  }

  Future<Message> sendGroupMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required String username,
    String? type,
    List<MessageAttachment>? attachments,
  }) async {
    final data = await _messageAPI.sendGroupMessage(
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      username: username,
      type: type,
      attachments: attachments?.map((e) => e.toJson()).toList(),
    );
    return Message.fromJson(data);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _messageAPI.getCurrentUser();
  }
}
