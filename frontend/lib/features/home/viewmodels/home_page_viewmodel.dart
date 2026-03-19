import 'package:flutter/material.dart';
import '../data/repositories/Conversation_repository.dart';
import '../data/repositories/friend_repository.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/services/socket_service.dart';

class HomePageViewmodel extends ChangeNotifier {
  final BuildContext context;
  final ConversationRepository _conversationRepository = ConversationRepository();
  final FriendRepository _friendRepository = FriendRepository();
  final SocketService _socketService = SocketService();

  HomePageViewmodel(this.context) {
    loadCurrentUserId();
    loadConversations();
    loadConversationGroupInfo();
    loadOnlineFriends();
    _initSocketListeners();
    searchController.addListener(() => onSearchChanged(searchController.text));
  }

  void _initSocketListeners() {
    _socketService.onNewConversation((data) {
      final convo = data['conversation'] as Map<String, dynamic>?;
      if (convo == null) return;
      final exists = _conversations.any((c) => c['_id'] == convo['_id']);
      if (!exists) {
        _conversations = [convo, ..._conversations];
        notifyListeners();
      }
    });

    _socketService.onConversationUpdated((data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId == null) return;

      final idx = _conversations.indexWhere((c) => c['_id'] == conversationId);
      if (idx == -1) {
        // Conversation chưa có trong list (vd: direct chat mới) → reload
        loadConversations();
        return;
      }

      // Cập nhật lastMessage và lastMessageAt
      final updated = Map<String, dynamic>.from(_conversations[idx] as Map);
      updated['lastMessage'] = data['lastMessage'];
      updated['lastMessageAt'] = data['lastMessageAt'];

      // Xóa khỏi vị trí cũ, đưa lên đầu
      final list = List<dynamic>.from(_conversations);
      list.removeAt(idx);
      list.insert(0, updated);
      _conversations = list;
      notifyListeners();
    });
  }

  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _conversations = [];
  List<dynamic> get conversations => _conversations;

  List<dynamic> _conversationGroupInfo = [];
  List<dynamic> get conversationGroupInfo => _conversationGroupInfo;

  List<dynamic> _onlineFriends = [];
  List<dynamic> get onlineFriends => _onlineFriends;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  Future<void> loadCurrentUserId() async {
  try {
    print('🔍 Loading current user...');
    // Gọi API /api/user/me để lấy thông tin user
    final response = await DioClient().dio.get('/api/user/me');
    print('✅ Current user response: ${response.data}');
    _currentUserId = response.data['id'] as String?;
    print('✅ Current user ID: $_currentUserId');
    notifyListeners();
  } catch (e) {
    print('❌ Error loading current user: $e');
    _currentUserId = null;
  }
}


  Future<void> loadOnlineFriends() async {
    try {
      _onlineFriends = await _friendRepository.getFriendOnlineStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading online friends: $e');
    }
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 Loading conversations...');
      _conversations = await _conversationRepository.getConversations();
      print('✅ Loaded ${_conversations.length} conversations');
    } catch (e) {
      print('❌ Error loading conversations: $e');
      _conversations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversationGroupInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 Loading conversation group info...');
      _conversationGroupInfo = await _conversationRepository.getConversationGroupInfo();
      print('✅ Loaded ${_conversationGroupInfo.length} conversation groups');
    } catch (e) {
      print('❌ Error loading conversation group info: $e');
      _conversationGroupInfo = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  String _keyword = '';
  String get keyword => _keyword;

  void onSearchChanged(String value) {
    _keyword = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.offNewConversation();
    _socketService.offConversationUpdated();
    searchController.dispose();
    super.dispose();
  }
}
