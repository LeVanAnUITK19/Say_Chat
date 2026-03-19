import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';

class MessageAPI {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getMessages(String conversationId, {int limit = 100, String? cursor}) async {
    final response = await _dio.get(
      '/api/conversations/$conversationId/messages',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return response.data['messages'] as List<dynamic>;
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

  Future<Map<String, dynamic>> sendGroupMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required String username,
    String? type,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final response = await _dio.post('/api/messages/group', data: {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'username': username,
      if (type != null) 'type': type,
      if (attachments != null) 'attachments': attachments,
    });
    return response.data['message'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/api/user/me');
    return response.data as Map<String, dynamic>;
  }
}
