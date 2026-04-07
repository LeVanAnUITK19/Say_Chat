import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../data/repositories/friend_repository.dart';

class UserProfileViewmodel extends ChangeNotifier {
  final String userId;
  final FriendRepository _friendRepo = FriendRepository();
  final Dio _dio = DioClient().dio;

  UserProfileViewmodel(this.userId) {
    loadProfile();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSending = false;
  bool get isSending => _isSending;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  String get username => _profile?['username'] ?? '';
  String? get avatarUrl => _profile?['avatarUrl'];
  String get status => _profile?['status'] ?? 'offline';
  String get email => _profile?['email'] ?? '';
  String get friendshipStatus => _profile?['friendshipStatus'] ?? 'none';
  String? get conversationId => _profile?['conversationId']?.toString();

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _dio.get('/api/user/$userId/profile');
      _profile = Map<String, dynamic>.from(res.data);
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendFriendRequest() async {
    _isSending = true;
    notifyListeners();
    try {
      await _friendRepo.sendFriendRequest(userId);
      _profile?['friendshipStatus'] = 'pending_sent';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFriend() async {
    _isDeleting = true;
    notifyListeners();
    try {
      await _friendRepo.deleteFriend(userId);
      _profile?['friendshipStatus'] = 'none';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting friend: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  String formatJoinDate() {
    final raw = _profile?['createdAt'];
    if (raw == null) return 'N/A';
    try {
      final date = DateTime.parse(raw);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'N/A';
    }
  }
}
