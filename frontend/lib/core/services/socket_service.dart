import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  // Lưu các conversationId cần join, để join lại khi reconnect
  final Set<String> _joinedRooms = {};

  String get _baseUrl {


    return 'https://say-chat.onrender.com';
  }

  Future<void> connect() async {
    if (isConnected) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('🔌 Socket connected');
      // Rejoin tất cả rooms sau khi (re)connect
      for (final roomId in _joinedRooms) {
        _socket?.emit('join_conversation', roomId);
      }
      // Re-register new_message listener nếu có callbacks
      if (_newMessageCallbacks.isNotEmpty) {
        _socket?.off('new_message');
        _socket?.on('new_message', _handleNewMessage);
      }
      // Re-register persistent listeners (new_conversation, conversation_updated)
      _reRegisterPersistentListeners();
    });
    _socket!.onDisconnect((_) => debugPrint('🔌 Socket disconnected'));
    _socket!.onConnectError((e) => debugPrint('❌ Socket connect error: $e'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinConversation(String conversationId) {
    _joinedRooms.add(conversationId);
    _socket?.emit('join_conversation', conversationId);
  }

  void leaveConversation(String conversationId) {
    _joinedRooms.remove(conversationId);
    _socket?.emit('leave_conversation', conversationId);
  }

  // Map lưu callbacks theo conversationId để tránh các chat page ghi đè nhau
  final Map<String, void Function(Map<String, dynamic>)> _newMessageCallbacks = {};

  // Persistent callbacks cho home-level events
  void Function(Map<String, dynamic>)? _newConversationCallback;
  void Function(Map<String, dynamic>)? _conversationUpdatedCallback;

  void _handleNewMessage(dynamic data) {
    Map<String, dynamic> msgData;
    if (data is Map<String, dynamic>) {
      msgData = data;
    } else if (data is Map) {
      msgData = Map<String, dynamic>.from(data);
    } else {
      return;
    }
    for (final cb in _newMessageCallbacks.values) {
      cb(msgData);
    }
  }

  void _reRegisterPersistentListeners() {
    if (_newConversationCallback != null) {
      _socket?.off('new_conversation');
      _socket?.on('new_conversation', (data) {
        final cb = _newConversationCallback;
        if (cb == null) return;
        if (data is Map<String, dynamic>) cb(data);
        else if (data is Map) cb(Map<String, dynamic>.from(data));
      });
    }
    if (_conversationUpdatedCallback != null) {
      _socket?.off('conversation_updated');
      _socket?.on('conversation_updated', (data) {
        final cb = _conversationUpdatedCallback;
        if (cb == null) return;
        if (data is Map<String, dynamic>) cb(data);
        else if (data is Map) cb(Map<String, dynamic>.from(data));
      });
    }
  }

  /// Đăng ký listener theo conversationId — an toàn khi mở nhiều chat
  void onNewMessageForConversation(
      String conversationId, void Function(Map<String, dynamic> data) callback) {
    _newMessageCallbacks[conversationId] = callback;
    // Chỉ đăng ký 1 listener gốc duy nhất
    _socket?.off('new_message');
    _socket?.on('new_message', _handleNewMessage);
  }

  void offNewMessageForConversation(String conversationId) {
    _newMessageCallbacks.remove(conversationId);
    if (_newMessageCallbacks.isEmpty) {
      _socket?.off('new_message');
    }
  }

  /// @deprecated dùng onNewMessageForConversation thay thế
  void onNewMessage(void Function(Map<String, dynamic> data) callback) {
    _socket?.off('new_message');
    _socket?.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void offNewMessage() {
    _socket?.off('new_message');
  }

  /// Lắng nghe conversation mới (tạo nhóm, direct chat mới)
  void onNewConversation(void Function(Map<String, dynamic> data) callback) {
    _newConversationCallback = callback;
    _socket?.off('new_conversation');
    _socket?.on('new_conversation', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void offNewConversation() {
    _newConversationCallback = null;
    _socket?.off('new_conversation');
  }

  /// Lắng nghe cập nhật lastMessage của conversation (để sort list ở home)
  void onConversationUpdated(void Function(Map<String, dynamic> data) callback) {
    _conversationUpdatedCallback = callback;
    _socket?.off('conversation_updated');
    _socket?.on('conversation_updated', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void offConversationUpdated() {
    _conversationUpdatedCallback = null;
    _socket?.off('conversation_updated');
  }

  // --- Call signaling ---

  void sendCallOffer(String to, Map offer, String callType) {
    _socket?.emit('call_offer', {'to': to, 'offer': offer, 'callType': callType});
  }

  void sendCallAnswer(String to, Map answer) {
    _socket?.emit('call_answer', {'to': to, 'answer': answer});
  }

  void sendIceCandidate(String to, Map candidate) {
    _socket?.emit('ice_candidate', {'to': to, 'candidate': candidate});
  }

  void sendCallEnd(String to) => _socket?.emit('call_end', {'to': to});

  void sendCallRejected(String to) => _socket?.emit('call_rejected', {'to': to});

  void onCallOffer(void Function(Map<String, dynamic>) cb) {
    _socket?.on('call_offer', (d) => cb(Map<String, dynamic>.from(d as Map)));
  }

  void onCallAnswer(void Function(Map<String, dynamic>) cb) {
    _socket?.on('call_answer', (d) => cb(Map<String, dynamic>.from(d as Map)));
  }

  void onIceCandidate(void Function(Map<String, dynamic>) cb) {
    _socket?.on('ice_candidate', (d) => cb(Map<String, dynamic>.from(d as Map)));
  }

  void onCallEnd(void Function() cb) => _socket?.on('call_end', (_) => cb());

  void onCallRejected(void Function() cb) => _socket?.on('call_rejected', (_) => cb());

  void offCallEvents() {
    for (final e in ['call_offer', 'call_answer', 'ice_candidate', 'call_end', 'call_rejected']) {
      _socket?.off(e);
    }
  }
}
