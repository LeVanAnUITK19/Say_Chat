import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';

class ConversationAPI {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get('/api/conversations');
    return response.data['conversations'] as List<dynamic>;
  }
  Future<List<dynamic>> getConversationGroupInfo() async {
    final response = await _dio.get('/api/conversations/group');
    return response.data['conversations'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createConversation({
    required String type,
    required List<String> memberIds,
    String? name,
  }) async {
    final response = await _dio.post('/api/conversations', data: {
      'type': type,
      'memberIds': memberIds,
      if (name != null) 'name': name,
    });
    return response.data['conversation'] as Map<String, dynamic>;
  }

  Future<String> getCurrentUser() async {
    final response = await _dio.get('/api/auth/me');
    return response.data['user']['username'] as String;
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String recipientId,
    required String content,
    required String username,
    String? type,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final response = await _dio.post('/api/messages/direct', data: {
      'conversationId': conversationId,
      'recipientId': recipientId,
      'content': content,
      'username': username,
      if (type != null) 'type': type,
      if (attachments != null) 'attachments': attachments,
    });
    return response.data['message'] as Map<String, dynamic>;
  }
}
