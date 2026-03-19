import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';

class ReactionAPI {
  final Dio _dio = DioClient().dio;

  /// Thêm hoặc cập nhật reaction
  Future<Map<String, dynamic>> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    final response = await _dio.post(
      '/api/reactions/$messageId',
      data: {'emoji': emoji},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Xóa reaction
  Future<Map<String, dynamic>> removeReaction({
    required String messageId,
  }) async {
    final response = await _dio.delete('/api/reactions/$messageId');
    return response.data as Map<String, dynamic>;
  }

  /// Lấy danh sách reactions
  Future<List<dynamic>> getReactions({
    required String messageId,
  }) async {
    final response = await _dio.get('/api/reactions/$messageId');
    return response.data['reactions'] as List<dynamic>;
  }
}
