import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_page_viewmodel.dart';
import '../widgets/message_bubble.dart';
import '../data/model/message.dart';
import '../../call/views/call_page.dart';
import '../../../main.dart' show routeObserver;
import '../../../core/utils/url_helper.dart';

class ChatPageView extends StatefulWidget {
  final String conversationId;
  final String chatTitle;
  final String? avatarUrl;
  final String type;
  final String? recipientId;

  const ChatPageView({
    super.key,
    required this.conversationId,
    required this.chatTitle,
    this.avatarUrl,
    required this.type,
    required this.recipientId,
  });

  @override
  State<ChatPageView> createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> with RouteAware {
  ChatPageViewmodel? _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() => _vm?.setActive(false);

  @override
  void didPopNext() => _vm?.setActive(true);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bottomInset > 0) {
        _vm?.scrollToBottom();
      }
    });

    return ChangeNotifierProvider<ChatPageViewmodel>(
      create: (ctx) {
        _vm = ChatPageViewmodel(
          context: ctx,
          conversationId: widget.conversationId,
          recipientId: widget.recipientId,
          type: widget.type,
        );
        return _vm!;
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(resolveMediaUrl(widget.avatarUrl))
                    : null,
                child: widget.avatarUrl == null
                    ? Text(
                        widget.chatTitle.isNotEmpty
                            ? widget.chatTitle[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.chatTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.call_rounded),
              onPressed: () {
                if (widget.recipientId == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallPage(
                      remoteUserId: widget.recipientId!,
                      remoteUserName: widget.chatTitle,
                      isVideo: false,
                      isCaller: true,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.videocam_rounded),
              onPressed: () {
                if (widget.recipientId == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallPage(
                      remoteUserId: widget.recipientId!,
                      remoteUserName: widget.chatTitle,
                      isVideo: true,
                      isCaller: true,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {},
            ),
          ],
        ),
        body: Consumer<ChatPageViewmodel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                // Recording indicator
                if (vm.isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.red.withOpacity(0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Đang ghi âm... (Giữ lâu để hủy)',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Messages
                Expanded(
                  child: vm.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: scheme.primary,
                          ),
                        )
                      : vm.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: scheme.outline,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có tin nhắn nào',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: ListView.builder(
                              controller: vm.scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemCount: vm.messages.length,
                              itemBuilder: (context, index) {
                                final message = vm.messages[index];
                                return _buildMessageBubble(
                                  context,
                                  message,
                                  vm,
                                );
                              },
                            ),
                          ),
                        ),
                ),

                // Input
                _buildMessageInput(context, vm),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message message,
    ChatPageViewmodel vm,
  ) {
    final isMe = message.senderId == vm.currentUserId;
    return MessageBubble(
      message: message,
      isMe: isMe,
      avatarUrl: isMe ? null : widget.avatarUrl,
      onReactionTap: (emoji) => vm.toggleReaction(message.id, emoji),
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatPageViewmodel vm) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceBright : Colors.white,
        border: Border(
          top: BorderSide(color: scheme.outline.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          // Image picker
          _InputIconButton(
            icon: Icons.image_rounded,
            color: scheme.primary,
            onPressed: vm.isLoading ? null : () => vm.showImagePickerOptions(),
          ),

          const SizedBox(width: 6),

          // Text input
          Expanded(
            child: TextField(
              controller: vm.messageController,
              style: TextStyle(color: scheme.onSurface, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? scheme.surfaceDim : scheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
          ),

          const SizedBox(width: 6),

          // Mic button
          _InputIconButton(
            icon: vm.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: vm.isRecording ? Colors.red : scheme.primary,
            onPressed: vm.isLoading
                ? null
                : () async {
                    if (vm.isRecording) {
                      await vm.stopRecordingAndSend();
                    } else {
                      await vm.startRecording();
                    }
                  },
            onLongPress: vm.isRecording
                ? () async => await vm.cancelRecording()
                : null,
          ),

          const SizedBox(width: 6),

          // Send button
          _InputIconButton(
            icon: Icons.send_rounded,
            color: scheme.primary,
            onPressed: vm.isLoading ? null : () => vm.sendMessage(),
          ),
        ],
      ),
    );
  }
}

class _InputIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  const _InputIconButton({
    required this.icon,
    required this.color,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onPressed == null
              ? Colors.grey.withOpacity(0.3)
              : color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            icon,
            size: 20,
            color: onPressed == null ? Colors.grey : color,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
