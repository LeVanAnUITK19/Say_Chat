class MessageReaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final String? username;
  final String? avatarUrl;

  MessageReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.username,
    this.avatarUrl,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    // userId có thể là string hoặc object (khi được populate)
    String userId;
    String? username;
    String? avatarUrl;
    
    if (json['userId'] is Map) {
      final userMap = json['userId'] as Map<String, dynamic>;
      userId = userMap['_id'] as String;
      username = userMap['username'] as String?;
      avatarUrl = userMap['avatarUrl'] as String?;
    } else {
      userId = json['userId'] as String;
    }

    return MessageReaction(
      userId: userId,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      username: username,
      avatarUrl: avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MessageAttachment {
  final String type;
  final String url;
  final Map<String, dynamic>? metadata;

  MessageAttachment({
    required this.type,
    required this.url,
    this.metadata,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      type: json['type'] as String,
      url: json['url'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String username;
  final String type;
  final String content;
  final List<MessageAttachment> attachments;
  final List<MessageReaction> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.username,
    required this.type,
    required this.content,
    required this.attachments,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // senderId có thể là string hoặc object (khi populate)
    String senderId;
    String username;

    if (json['senderId'] is Map) {
      final senderMap = json['senderId'] as Map<String, dynamic>;
      senderId = senderMap['_id'] as String;
      username = senderMap['username'] as String? ?? '';
    } else {
      senderId = json['senderId'] as String;
      username = json['username'] as String? ?? '';
    }

    return Message(
      id: json['_id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: senderId,
      username: username,
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
