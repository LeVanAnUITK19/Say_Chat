import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/dio_client.dart';

class UserAPI {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/api/user/me');
    return response.data as Map<String, dynamic>;
  }

  Future<String> uploadAndUpdateAvatar(XFile imageFile) async {
    // Dùng bytes để hỗ trợ cả web lẫn mobile
    final bytes = await imageFile.readAsBytes();
    final fileName = imageFile.name.isNotEmpty ? imageFile.name : 'avatar.jpg';
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'type': 'image',
    });
    final uploadRes = await _dio.post('/api/upload', data: formData);
    final avatarUrl = uploadRes.data['url'] as String;

    // Cập nhật avatar cho user
    await _dio.put('/api/user/avatar', data: {'avatarUrl': avatarUrl});
    return avatarUrl;
  }

  Future<Map<String, dynamic>> getUserStats() async {
    // Lấy thống kê: số bạn bè, số conversations
    final friendsResponse = await _dio.get('/api/friends');
    final conversationsResponse = await _dio.get('/api/conversations');
    
    return {
      'friendsCount': (friendsResponse.data['friends'] as List).length,
      'conversationsCount': (conversationsResponse.data['conversations'] as List).length,
    };
  }
}
