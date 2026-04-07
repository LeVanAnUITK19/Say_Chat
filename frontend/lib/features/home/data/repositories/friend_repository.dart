import '../api/friend_api.dart';

class FriendRepository {
  final FriendAPI _friendAPI = FriendAPI();

  Future<List<dynamic>> getFriends() async {
    return await _friendAPI.getFriends();
  }

  Future<List<dynamic>> searchUsers(String keyword) async {
    return await _friendAPI.searchUsers(keyword);
  }

  Future<void> sendFriendRequest(String userId) async {
    return await _friendAPI.sendFriendRequest(userId);
  }

  Future<Map<String, dynamic>> getFriendRequests() async {
    return await _friendAPI.getFriendRequests();
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String requestId) async {
    return await _friendAPI.acceptFriendRequest(requestId);
  }

  Future<void> declineFriendRequest(String requestId) async {
    return await _friendAPI.declineFriendRequest(requestId);
  }
  Future<void> deleteFriend(String friendId) async {
    return await _friendAPI.deleteFriend(friendId);
  }

  Future<List<dynamic>> getFriendOnlineStatus() async {
    return await _friendAPI.getFriendOnlineStatus();
  }
}