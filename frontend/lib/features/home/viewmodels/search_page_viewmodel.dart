import 'package:flutter/material.dart';
import 'package:say_chat/features/home/data/repositories/Conversation_repository.dart';
import '../data/repositories/friend_repository.dart';
import '../../chat/views/chat_page_view.dart';

class SearchPageViewmodel extends ChangeNotifier {
  final BuildContext context;
  final FriendRepository _friendRepository = FriendRepository();
  final ConversationRepository _conversationRepository =
      ConversationRepository();

  SearchPageViewmodel(this.context) {
    loadFriends();
    loadFriendRequests();

    // Lắng nghe thay đổi của searchController
    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

  final TextEditingController searchController = TextEditingController();

  List<dynamic> _friends = [];
  List<dynamic> get friends => _friends;

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  List<dynamic> _friendRequests = [];
  List<dynamic> get friendRequests => _friendRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isLoadingRequests = false;
  bool get isLoadingRequests => _isLoadingRequests;

  String _keyword = '';
  String get keyword => _keyword;

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _friendRepository.getFriends();
    } catch (e) {
      debugPrint('Error loading friends: $e');
      _friends = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFriendRequests() async {
    _isLoadingRequests = true;
    notifyListeners();

    try {
      final result = await _friendRepository.getFriendRequests();
      _friendRequests = result['received'] ?? [];
    } catch (e) {
      debugPrint('Error loading friend requests: $e');
      _friendRequests = [];
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers() async {
    if (_keyword.trim().isEmpty || !_keyword.contains('@')) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _friendRepository.searchUsers(_keyword);
    } catch (e) {
      debugPrint('Error searching users: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    _keyword = value;
    searchUsers(); // Gọi search ngay khi text thay đổi
  }

  Future<void> sendFriendRequest(String userId) async {
    try {
      await _friendRepository.sendFriendRequest(userId);
      // Refresh search results sau khi gửi
      await searchUsers();
    } catch (e) {
      debugPrint('Error sending friend request: $e');
    }
  }

  Future<void> createConversationWithUser(
    String userId,
    String username,
    String? avatarUrl,
  ) async {
    try {
      final conversation = await _conversationRepository.createConversation(
        type: "direct",
        memberIds: [userId],
      );

      final conversationId = conversation['_id']?.toString() ?? '';

      // Lấy thông tin participant từ response (đã được populate)
      final participants = conversation['participants'] as List<dynamic>? ?? [];
      final other = participants.firstWhere(
        (p) {
          final id = p['_id']?.toString() ?? p['userId']?['_id']?.toString() ?? '';
          return id == userId;
        },
        orElse: () => <String, dynamic>{},
      );

      // Ưu tiên data từ API response, fallback về data truyền vào
      final resolvedUsername = (other['username'] as String?)?.isNotEmpty == true
          ? other['username'] as String
          : username;
      final resolvedAvatar = (other['avatarUrl'] as String?) ?? avatarUrl;

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPageView(
              conversationId: conversationId,
              chatTitle: resolvedUsername,
              type: 'direct',
              avatarUrl: resolvedAvatar,
              recipientId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating conversation: $e');
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final result = await _friendRepository.acceptFriendRequest(requestId);
      // Backend trả về newFriend với đầy đủ thông tin
      final newFriend = result['newFriend'] as Map<String, dynamic>?;
      final newFriendId = newFriend?['_id']?.toString();
      final newFriendUsername = newFriend?['username'] as String? ?? '';
      final newFriendAvatar = newFriend?['avatarUrl'] as String?;

      if (newFriendId != null) {
        await createConversationWithUser(newFriendId, newFriendUsername, newFriendAvatar);
      }
      // Refresh cả friends và requests
      await Future.wait([loadFriends(), loadFriendRequests()]);
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    try {
      await _friendRepository.declineFriendRequest(requestId);
      // Refresh requests
      await loadFriendRequests();
    } catch (e) {
      debugPrint('Error declining friend request: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
