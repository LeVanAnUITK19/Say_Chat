import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/api_endpoints.dart';

class  FriendAPI{
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getFriends() async {
    final response = await _dio.get(ApiEndpoints.friends);
    // Backend trả về {friends: [...]}
    return response.data['friends'] as List<dynamic>;
  }

  Future<List<dynamic>> searchUsers(String keyword) async {
    final response = await _dio.get('${ApiEndpoints.friends}/search?q=$keyword');
    return response.data['users'] as List<dynamic>;
  }

  Future<void> sendFriendRequest(String userId) async {
    await _dio.post('${ApiEndpoints.friends}/requests', data: {'to': userId});
  }

  Future<Map<String, dynamic>> getFriendRequests() async {
    final response = await _dio.get('${ApiEndpoints.friends}/requests');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String requestId) async {
    final response = await _dio.post('${ApiEndpoints.friends}/requests/$requestId/accept');
    return response.data as Map<String, dynamic>;
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _dio.post('${ApiEndpoints.friends}/requests/$requestId/decline');
  }
  Future<void> deleteFriend(String friendId) async {
    await _dio.delete('${ApiEndpoints.friends}/$friendId');
  }

  Future<Map<String, dynamic>> findUserByQrCode(String qrCode) async {
    final response = await _dio.get('/users/qr/$qrCode');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getFriendOnlineStatus() async {
    final response = await _dio.get('${ApiEndpoints.friends}/online-status');
    return response.data['friends'] as List<dynamic>;
  }
}