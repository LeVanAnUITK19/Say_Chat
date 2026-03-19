import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_page_viewmodel.dart';
import '../widgets/message_bubble.dart';
import '../data/model/message.dart';
import '../../call/views/call_page.dart';
import '../../../main.dart' show routeObserver;

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
  void didPushNext() {
    // Có page mới push lên trên → page này không còn visible
    _vm?.setActive(false);
  }

  @override
  void didPopNext() {
    // Page trên bị pop → page này visible lại
    _vm?.setActive(true);
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(widget.avatarUrl!)
                    : null,
                child: widget.avatarUrl == null
                    ? Text(
                        widget.chatTitle.isNotEmpty ? widget.chatTitle[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.chatTitle,
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.call),
              color: Theme.of(context).colorScheme.onPrimary,
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
              icon: const Icon(Icons.videocam),
              color: Theme.of(context).colorScheme.onPrimary,
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
              icon: const Icon(Icons.more_vert),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                // TODO: More options
              },
            ),
          ],
        ),
        body: Consumer<ChatPageViewmodel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                // Indicator khi đang ghi âm
                if (vm.isRecording)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Đang ghi âm... (Nhấn để dừng, giữ lâu để hủy)',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                
                // Danh sách tin nhắn
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.messages.isEmpty
                      ? const Center(child: Text('Chưa có tin nhắn nào'))
                      : ListView.builder(
                          reverse: false,
                          controller: vm.scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.messages.length,
                          itemBuilder: (context, index) {
                            final message = vm.messages[index];
                            return _buildMessageBubble(context, message , vm);
                          },
                        ),
                ),

                // Input box
                const Divider(height: 1),
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
      onReactionTap: (emoji) {
        vm.toggleReaction(message.id, emoji);
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatPageViewmodel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Folder button (chọn ảnh)
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.folder, color: Colors.white),
              onPressed: vm.isLoading ? null : () => vm.showImagePickerOptions(),
            ),
          ),
          
          Expanded(
            child: TextField(
              controller: vm.messageController,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: vm.isLoading ? null : () => vm.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          
          // Microphone button (ghi âm)
          CircleAvatar(
            backgroundColor: vm.isRecording 
                ? Colors.red 
                : Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: Icon(
                vm.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
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
                  ? () async {
                      await vm.cancelRecording();
                    }
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          
          
        ],
      ),
    );
  }
}
