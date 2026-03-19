import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../data/repositories/user_repository.dart';

class PersonPageViewmodel extends ChangeNotifier {
  final BuildContext context;
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();

  bool _isUploadingAvatar = false;
  bool get isUploadingAvatar => _isUploadingAvatar;

  PersonPageViewmodel(this.context) {
    loadUserInfo();
    loadUserStats();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? get userInfo => _userInfo;

  int _friendsCount = 0;
  int get friendsCount => _friendsCount;

  int _conversationsCount = 0;
  int get conversationsCount => _conversationsCount;

  String? get username => _userInfo?['username'];
  String? get email => _userInfo?['email'];
  String? get avatarUrl => _userInfo?['avatarUrl'];
  String? get status => _userInfo?['status'];
  String? get createdAt => _userInfo?['createdAt'];

  Future<void> loadUserInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userInfo = await _userRepository.getCurrentUser();
    } catch (e) {
      debugPrint('Error loading user info: $e');
      _userInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserStats() async {
    try {
      final stats = await _userRepository.getUserStats();
      _friendsCount = stats['friendsCount'] ?? 0;
      _conversationsCount = stats['conversationsCount'] ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    }
  }

  String formatJoinDate() {
    if (createdAt == null) return 'N/A';
    
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadUserInfo(),
      loadUserStats(),
    ]);
  }

  Future<void> pickAndUpdateAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    _isUploadingAvatar = true;
    notifyListeners();

    try {
      final newUrl = await _userRepository.uploadAndUpdateAvatar(picked);
      _userInfo = {...?_userInfo, 'avatarUrl': newUrl};
      // Cập nhật AuthProvider để drawer và các nơi khác tự refresh
      if (context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).updateUserAvatar(newUrl);
      }
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thất bại')),
        );
      }
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}
