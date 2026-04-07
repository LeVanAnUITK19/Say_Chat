import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/my_drawer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_filterchip.dart';
import '../viewmodels/home_page_viewmodel.dart';
import 'search_page_view.dart';
import '../../chat/views/chat_page_view.dart';
import '../../call/views/incoming_call_page.dart';
import 'qr_scanner_page.dart';
import 'user_profile_page.dart';
import '../../../core/utils/url_helper.dart';
import '../../../core/services/socket_service.dart';
import '../../../main.dart' show navigatorKey;

enum ConversationFilter { all, unread, group }

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  ConversationFilter _filter = ConversationFilter.all;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _socketService.onCallOffer((data) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => IncomingCallPage(
          callerId: data['from'].toString(),
          callerName: data['fromUsername']?.toString() ?? 'Unknown',
          callType: data['callType']?.toString() ?? 'audio',
          offer: Map<String, dynamic>.from(data['offer'] as Map),
        ),
      ));
    });
  }

  @override
  void dispose() {
    _socketService.offCallEvents();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<HomePageViewmodel>(
      create: (context) => HomePageViewmodel(context),
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: Text(l10n.home),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () async {
                final qrCode = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QrScannerPage(),
                  ),
                );
                if (qrCode != null && context.mounted) {
                  _handleQrCodeScanned(context, qrCode);
                }
              },
            ),
          ],
        ),
        body: Consumer<HomePageViewmodel>(
          builder: (context, vm, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Search bar
                MyTextFieldSearch(
                  hintText: l10n.search,
                  obscureText: false,
                  controller: vm.searchController,
                  icon: Icons.search_rounded,
                  suffixIcon: Icons.qr_code_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPageView(),
                      ),
                    );
                  },
                ),

                // Online friends
                if (vm.onlineFriends.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      'Đang hoạt động',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: vm.onlineFriends.length,
                      itemBuilder: (context, index) {
                        final friend = vm.onlineFriends[index] as Map<String, dynamic>;
                        final username = friend['username'] as String? ?? '';
                        final avatarUrl = friend['avatarUrl'] as String?;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: scheme.primaryContainer,
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(resolveMediaUrl(avatarUrl))
                                        : null,
                                    child: avatarUrl == null
                                        ? Text(
                                            username.isNotEmpty
                                                ? username[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              color: scheme.primary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 1,
                                    right: 1,
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00C853),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: scheme.surface,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  username,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      MyFilterChip(
                        label: l10n.all,
                        selected: _filter == ConversationFilter.all,
                        onTap: () => setState(() => _filter = ConversationFilter.all),
                      ),
                      const SizedBox(width: 8),
                      MyFilterChip(
                        label: l10n.unRead,
                        selected: _filter == ConversationFilter.unread,
                        onTap: () => setState(() => _filter = ConversationFilter.unread),
                      ),
                      const SizedBox(width: 8),
                      MyFilterChip(
                        label: l10n.group,
                        selected: _filter == ConversationFilter.group,
                        onTap: () {
                          setState(() => _filter = ConversationFilter.group);
                          vm.loadConversationGroupInfo();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: vm.isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: scheme.primary),
                        )
                      : _buildConversationList(context, vm),
                ),
              ],
            );
          },
        ),
        drawer: const MyDrawer(),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context, HomePageViewmodel vm) {
    final scheme = Theme.of(context).colorScheme;

    if (_filter == ConversationFilter.unread) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_chat_unread_outlined, size: 48, color: scheme.outline),
            const SizedBox(height: 12),
            Text('Không có tin nhắn chưa đọc',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (_filter == ConversationFilter.group) {
      if (vm.conversationGroupInfo.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_outlined, size: 48, color: scheme.outline),
              const SizedBox(height: 12),
              Text('Chưa có nhóm nào',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        );
      }
      return ListView.separated(
        itemCount: vm.conversationGroupInfo.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
          color: scheme.outline.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          return _buildConversationGroupItem(
              context, vm.conversationGroupInfo[index], vm);
        },
      );
    }

    if (vm.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              'Chưa có cuộc trò chuyện nào',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: vm.conversations.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 72,
        endIndent: 16,
        color: scheme.outline.withOpacity(0.2),
      ),
      itemBuilder: (context, index) {
        return _buildConversationItem(context, vm.conversations[index], vm);
      },
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Map<String, dynamic> conversation,
    HomePageViewmodel vm,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final type = conversation['type'] ?? 'direct';
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    final lastMessage = conversation['lastMessage'] as Map<String, dynamic>?;
    final lastMessageAt = conversation['lastMessageAt'] as String?;

    String title = '';
    String? avatarUrl;

    if (type == 'direct') {
      final otherUser = participants.firstWhere(
        (p) => p['_id'] != null && p['_id'].toString() != vm.currentUserId,
        orElse: () => participants.isNotEmpty ? participants[0] : null,
      );
      title = otherUser?['username'] ?? 'Unknown';
      avatarUrl = otherUser?['avatarUrl'];
    } else {
      title = conversation['group']?['name'] ?? 'Group Chat';
    }

    String lastMessageText = '';
    if (lastMessage != null) {
      final senderObj = lastMessage['senderId'];
      final String senderName = senderObj is Map
          ? senderObj['username'] as String? ?? 'Someone'
          : 'Someone';
      final content = lastMessage['content'] ?? '';
      lastMessageText = '$senderName: $content';
    }

    String timeText = '';
    if (lastMessageAt != null) {
      try {
        final date = DateTime.parse(lastMessageAt);
        final now = DateTime.now();
        final difference = now.difference(date);
        if (difference.inDays == 0) {
          timeText = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        } else if (difference.inDays == 1) {
          timeText = 'Hôm qua';
        } else if (difference.inDays < 7) {
          timeText = '${difference.inDays} ngày';
        } else {
          timeText = '${date.day}/${date.month}';
        }
      } catch (e) {
        timeText = '';
      }
    }

    return InkWell(
      onTap: () {
        String? recipientId;
        if (type == 'direct') {
          final otherUser = participants.firstWhere(
            (p) => p['_id'] != null && p['_id'].toString() != vm.currentUserId,
            orElse: () => null,
          );
          recipientId = otherUser?['_id']?.toString();
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPageView(
              conversationId: conversation['_id'] ?? '',
              chatTitle: title,
              type: type,
              avatarUrl: avatarUrl,
              recipientId: recipientId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.primaryContainer,
              backgroundImage: avatarUrl != null ? NetworkImage(resolveMediaUrl(avatarUrl)) : null,
              child: avatarUrl == null
                  ? Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: scheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessageText.isEmpty
                        ? 'Bắt đầu cuộc trò chuyện'
                        : lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationGroupItem(
    BuildContext context,
    Map<String, dynamic> conversation,
    HomePageViewmodel vm,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final lastMessage = conversation['lastMessage'] as Map<String, dynamic>?;
    final lastMessageAt = conversation['lastMessageAt'] as String?;
    final String title = conversation['group']?['name'] ?? 'Group Chat';
    final String? avatarUrl = conversation['group']?['avatarUrl'] as String?;

    String lastMessageText = '';
    if (lastMessage != null) {
      final senderObj = lastMessage['senderId'];
      final String senderName = senderObj is Map
          ? senderObj['username'] as String? ?? 'Someone'
          : 'Someone';
      final content = lastMessage['content'] ?? '';
      lastMessageText = '$senderName: $content';
    }

    String timeText = '';
    if (lastMessageAt != null) {
      try {
        final date = DateTime.parse(lastMessageAt);
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inDays == 0) {
          timeText = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        } else if (diff.inDays == 1) {
          timeText = 'Hôm qua';
        } else if (diff.inDays < 7) {
          timeText = '${diff.inDays} ngày';
        } else {
          timeText = '${date.day}/${date.month}';
        }
      } catch (_) {}
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPageView(
              conversationId: conversation['_id'] ?? '',
              chatTitle: title,
              type: 'group',
              avatarUrl: avatarUrl,
              recipientId: null,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.secondaryContainer,
              backgroundImage: avatarUrl != null ? NetworkImage(resolveMediaUrl(avatarUrl)) : null,
              child: avatarUrl == null
                  ? Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: scheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: scheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessageText.isEmpty ? 'Bắt đầu cuộc trò chuyện' : lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQrCodeScanned(BuildContext context, String scannedValue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfilePage(userId: scannedValue)),
    );
  }
}
