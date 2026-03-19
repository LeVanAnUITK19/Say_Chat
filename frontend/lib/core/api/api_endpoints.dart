class ApiEndpoints {
  // Auth endpoints
  static const String signIn = '/api/auth/signin';
  static const String signUp = '/api/auth/signup';
  static const String signOut = '/api/auth/signout';
  static const String resetPassword = '/api/auth/reset-password';
  static const String sendResetPasswordOtp = '/api/auth/send-otp';
  static const String authMe = '/api/auth/me';
  
  // User endpoints
  static const String profile = '/api/user/profile';
  static const String updateProfile = '/api/user/profile';
  static const String heartbeat = '/api/user/heartbeat';
  
  // Chat endpoints (for future)
  static const String conversations = '/api/chat/conversations';
  static const String messages = '/api/chat/messages';

  //Friend endpoints
  static const String friends = '/api/friends';
  static const String searchUsers = '/api/users/:email/search';
  static const String addFriend = '/api/friends/add';
  static const String friendRequests = '/api/friends/requests';
  static const String acceptFriendRequest = '/api/friends/accept';
  static const String getFriendOnlineStatus = '/api/friends/online-status';

  //Message
  static const String sendMessage = '/api/messages/direct';
  static const String sendGroupMessage = '/api/messages/group';
  static const String getMessages = '/api/:conversationId/messages/';
  
  //Conversations
  static const String createConversation = '/api/conversations/';
  static const String getConversations = '/api/conversations/';
  static const String getConversationGroupInfo = '/api/conversations/group';
  
}