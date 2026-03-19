import 'package:flutter/material.dart';
import '../data/repositories/friend_repository.dart';

class SearchPageViewmodel extends ChangeNotifier {
  final BuildContext context;
  final FriendRepository _friendRepository = FriendRepository();

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
    if (_keyword.trim().isEmpty) {
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

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _friendRepository.acceptFriendRequest(requestId);
      // Refresh cả friends và requests
      await Future.wait([
        loadFriends(),
        loadFriendRequests(),
      ]);
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
