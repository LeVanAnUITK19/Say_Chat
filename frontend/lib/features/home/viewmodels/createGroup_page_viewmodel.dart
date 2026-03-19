import 'package:flutter/material.dart';
import '../data/repositories/friend_repository.dart';
import '../data/repositories/conversation_repository.dart';

class CreateGroupPageViewmodel extends ChangeNotifier {
  final BuildContext context;
  final FriendRepository _friendRepository = FriendRepository();
  final ConversationRepository _conversationRepository = ConversationRepository();

  CreateGroupPageViewmodel(this.context) {
    loadFriends();
  }

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  List<dynamic> _allFriends = [];
  List<dynamic> _filteredFriends = [];
  List<dynamic> get filteredFriends => _filteredFriends;

  // Danh sách ID của friends đã chọn
  final Set<String> _selectedFriendIds = {};
  Set<String> get selectedFriendIds => _selectedFriendIds;

  // Load danh sách bạn bè
  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allFriends = await _friendRepository.getFriends();
      _filteredFriends = List.from(_allFriends);
    } catch (e) {
      debugPrint('Error loading friends: $e');
      _allFriends = [];
      _filteredFriends = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm bạn bè
  void searchFriends(String keyword) {
    if (keyword.trim().isEmpty) {
      _filteredFriends = List.from(_allFriends);
    } else {
      _filteredFriends = _allFriends.where((friend) {
        final username = (friend['username'] ?? '').toString().toLowerCase();
        return username.contains(keyword.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Toggle chọn/bỏ chọn friend
  void toggleFriendSelection(String friendId) {
    if (_selectedFriendIds.contains(friendId)) {
      _selectedFriendIds.remove(friendId);
    } else {
      _selectedFriendIds.add(friendId);
    }
    notifyListeners();
  }

  // Kiểm tra friend đã được chọn chưa
  bool isFriendSelected(String friendId) {
    return _selectedFriendIds.contains(friendId);
  }

  // Tạo group
  Future<bool> createGroup() async {
    final groupName = groupNameController.text.trim();

    // Validate
    if (groupName.isEmpty) {
      _showError('Vui lòng nhập tên nhóm');
      return false;
    }

    if (_selectedFriendIds.isEmpty) {
      _showError('Vui lòng chọn ít nhất 1 thành viên');
      return false;
    }

    _isCreating = true;
    notifyListeners();

    try {
      await _conversationRepository.createConversation(
        type: 'group',
        memberIds: _selectedFriendIds.toList(),
        name: groupName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo nhóm thành công!')),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error creating group: $e');
      _showError('Lỗi khi tạo nhóm');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    searchController.dispose();
    super.dispose();
  }
}