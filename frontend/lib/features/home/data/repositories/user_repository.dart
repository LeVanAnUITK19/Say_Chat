import 'package:image_picker/image_picker.dart';
import '../api/user_api.dart';

class UserRepository {
  final UserAPI _userAPI = UserAPI();

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _userAPI.getCurrentUser();
  }

  Future<Map<String, dynamic>> getUserStats() async {
    return await _userAPI.getUserStats();
  }

  Future<String> uploadAndUpdateAvatar(XFile imageFile) async {
    return await _userAPI.uploadAndUpdateAvatar(imageFile);
  }
}
