import 'package:flutter/material.dart';
import '../data/model/message.dart';
import '../../home/views/user_profile_page.dart';
import '../../../core/utils/url_helper.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_page_viewmodel.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final String? avatarUrl;
  final Function(String emoji)? onReactionTap;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.avatarUrl,
    this.onReactionTap,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showEmojiPicker = false;

  // Danh sách emoji phổ biến
  final List<String> _quickEmojis = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar cho tin nhắn của người khác
          if (!widget.isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(resolveMediaUrl(widget.avatarUrl))
                    : null,
                child: widget.avatarUrl == null
                    ? Text(
                        widget.message.username.isNotEmpty
                            ? widget.message.username[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
            ),

          // Nội dung tin nhắn
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Tên người gửi (chỉ hiện khi không phải mình)
                if (!widget.isMe && widget.message.username.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(
                              userId: widget.message.senderId, // cần có field này
                              initialUsername: widget.message.username,
                              initialAvatarUrl: widget.avatarUrl,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        widget.message.username,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isMe
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hiển thị attachments nếu có
                        if (widget.message.attachments.isNotEmpty)
                          ...widget.message.attachments.map(
                            (attachment) =>
                                _buildAttachment(attachment, context),
                          ),

                        // Hiển thị text content nếu có
                        if (widget.message.content.isNotEmpty)
                          Text(
                            widget.message.content,
                            style: TextStyle(
                              color: widget.isMe
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),

                        // Timestamp
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(widget.message.createdAt),
                          style: TextStyle(
                            color: widget.isMe
                                ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.7)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hiển thị reactions
                if (widget.message.reactions.isNotEmpty) _buildReactionsBar(),

                // Emoji picker
                if (_showEmojiPicker) _buildEmojiPicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionsBar() {
    // Nhóm reactions theo emoji
    final Map<String, List<MessageReaction>> groupedReactions = {};
    for (var reaction in widget.message.reactions) {
      if (!groupedReactions.containsKey(reaction.emoji)) {
        groupedReactions[reaction.emoji] = [];
      }
      groupedReactions[reaction.emoji]!.add(reaction);
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: groupedReactions.entries.map((entry) {
          final emoji = entry.key;
          final reactions = entry.value;
          final count = reactions.length;

          return GestureDetector(
            onTap: () {
              // Toggle reaction khi tap
              if (widget.onReactionTap != null) {
                widget.onReactionTap!(emoji);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  if (count > 1) ...[
                    const SizedBox(width: 4),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _quickEmojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              if (widget.onReactionTap != null) {
                widget.onReactionTap!(emoji);
              }
              setState(() {
                _showEmojiPicker = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Trên mobile, URL lưu trong DB có thể là localhost -> thay bằng IP thực
  // Đã thay bằng resolveMediaUrl từ url_helper.dart

  Widget _buildAttachment(MessageAttachment attachment, BuildContext context) {
    switch (attachment.type) {
      case 'image':
        return _buildImageAttachment(attachment);
      case 'audio':
        return _buildAudioAttachment(attachment);
      case 'sticker':
        return _buildStickerAttachment(attachment);
      case 'video':
        return _buildVideoAttachment(attachment);
      case 'file':
        return _buildFileAttachment(attachment);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageAttachment(MessageAttachment attachment) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        resolveMediaUrl(attachment.url),
        fit: BoxFit.cover,

        // 👇 FIX NẰM Ở ĐÂY
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            // ảnh load xong → scroll lại
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<ChatPageViewmodel>().scrollToBottom();
              }
            });
            return child;
          }

          return Container(
            height: 150,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },

        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    ),
  );
}

  Widget _buildAudioAttachment(MessageAttachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.audiotrack, size: 20),
          const SizedBox(width: 8),
          const Text('Tin nhắn thoại'),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 20),
            onPressed: () {
              // TODO: Implement audio player
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickerAttachment(MessageAttachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: 120,
      height: 120,
      child: Image.network(
        resolveMediaUrl(attachment.url),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.emoji_emotions, size: 80);
        },
      ),
    );
  }

  Widget _buildVideoAttachment(MessageAttachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
          // TODO: Implement video player
        ],
      ),
    );
  }

  Widget _buildFileAttachment(MessageAttachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 20),
          const SizedBox(width: 8),
          const Text('Tệp đính kèm'),
        ],
      ),
    );
  }
}
