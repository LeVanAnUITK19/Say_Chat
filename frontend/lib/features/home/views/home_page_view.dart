import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/my_drawer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_filterchip.dart';
import '../viewmodels/home_page_viewmodel.dart';
import 'search_page_view.dart';
import '../../chat/views/chat_page_view.dart';
import 'qr_scanner_page.dart';
import 'user_profile_page.dart';

enum ConversationFilter { all, unread, group }

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  ConversationFilter _filter = ConversationFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<HomePageViewmodel>(
      create: (context) => HomePageViewmodel(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.home),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: MyTextFieldSearch(
                    hintText: l10n.search,
                    obscureText: false,
                    controller: vm.searchController,
                    icon: Icons.search,
                    suffixIcon: Icons.qr_code,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPageView(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Online friends horizontal list
                if (vm.onlineFriends.isNotEmpty)
                  SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: vm.onlineFriends.length,
                      itemBuilder: (context, index) {
                        final friend =
                            vm.onlineFriends[index] as Map<String, dynamic>;
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
                                    radius: 24,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl == null
                                        ? Text(
                                            username.isNotEmpty
                                                ? username[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                  // Online dot
                                  Positioned(
                                    bottom: 1,
                                    right: 1,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  username,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 8),

                // Filter tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyFilterChip(
                        label: l10n.all,
                        selected: _filter == ConversationFilter.all,
                        onTap: () =>
                            setState(() => _filter = ConversationFilter.all),
                      ),
                      const SizedBox(width: 8),
                      MyFilterChip(
                        label: l10n.unRead,
                        selected: _filter == ConversationFilter.unread,
                        onTap: () =>
                            setState(() => _filter = ConversationFilter.unread),
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

                // Danh sách conversations
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
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
    // Chỉ All tab hiển thị list thật, Unread và Group để trống chờ implement
    if (_filter == ConversationFilter.unread) {
      return const Center(child: Text('Unread'));
    }
    if (_filter == ConversationFilter.group) {
      if (vm.conversationGroupInfo.isEmpty) {
        return const Center(child: Text('Chưa có nhóm nào'));
      }
      return ListView.separated(
        itemCount: vm.conversationGroupInfo.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 70, endIndent: 16),
        itemBuilder: (context, index) {
          return _buildConversationGroupItem(
              context, vm.conversationGroupInfo[index], vm);
        },
      );
    }

    if (vm.conversations.isEmpty) {
      return Center(
        child: Text(
          'Chưa có cuộc trò chuyện nào',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      itemCount: vm.conversations.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 70, endIndent: 16),
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
    final type = conversation['type'] ?? 'direct';
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    final lastMessage = conversation['lastMessage'] as Map<String, dynamic>?;
    final lastMessageAt = conversation['lastMessageAt'] as String?;

    // Lấy thông tin người chat (nếu là direct)
    String title = '';
    String? avatarUrl;

    if (type == 'direct') {
      // Tìm participant không phải là user hiện tại
      // participants đã được flatten bởi API: { _id, username, avatarUrl, joinedAt }
      final otherUser = participants.firstWhere(
        (p) => p['_id'] != null && p['_id'].toString() != vm.currentUserId,
        orElse: () => participants.isNotEmpty ? participants[0] : null,
      );

      title = otherUser?['username'] ?? 'Unknown';
      avatarUrl = otherUser?['avatarUrl'];
    } else {
      // Group chat
      title = conversation['group']?['name'] ?? 'Group Chat';
    }

    // Format last message
    String lastMessageText = '';
    if (lastMessage != null) {
      // senderId có thể là object (populated) hoặc string (chưa populate)
      final senderObj = lastMessage['senderId'];
      final String senderName;
      if (senderObj is Map) {
        senderName = senderObj['username'] as String? ?? 'Someone';
      } else {
        senderName = 'Someone';
      }
      final content = lastMessage['content'] ?? '';
      lastMessageText = '$senderName: $content';
    }

    // Format time
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
          timeText = '${difference.inDays} ngày trước';
        } else {
          timeText = '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        timeText = '';
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessageText.isEmpty ? 'Bắt đầu cuộc trò chuyện' : lastMessageText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          // TODO: Hiển thị unread count badge nếu có
        ],
      ),
      onTap: () {
        String? recipientId;

        if (type == 'direct') {
          // Với direct chat, lấy ID của người kia
          final otherUser = participants.firstWhere(
            (p) => p['_id'] != null && p['_id'].toString() != vm.currentUserId,
            orElse: () => null,
          );
          recipientId = otherUser?['_id']?.toString();
        }
        // Navigate to chat screen
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
    );
  }



 Widget _buildConversationGroupItem(
    BuildContext context,
    Map<String, dynamic> conversation,
    HomePageViewmodel vm,
  ) {
    final lastMessage = conversation['lastMessage'] as Map<String, dynamic>?;
    final lastMessageAt = conversation['lastMessageAt'] as String?;

    // Group chat — lấy tên nhóm và avatar nhóm (nếu có)
    final String title = conversation['group']?['name'] ?? 'Group Chat';
    final String? avatarUrl = conversation['group']?['avatarUrl'] as String?;

    // Format last message
    String lastMessageText = '';
    if (lastMessage != null) {
      final senderObj = lastMessage['senderId'];
      final String senderName = senderObj is Map
          ? senderObj['username'] as String? ?? 'Someone'
          : 'Someone';
      final content = lastMessage['content'] ?? '';
      lastMessageText = '$senderName: $content';
    }

    // Format time
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
          timeText = '${diff.inDays} ngày trước';
        } else {
          timeText = '${date.day}/${date.month}/${date.year}';
        }
      } catch (_) {}
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessageText.isEmpty ? 'Bắt đầu cuộc trò chuyện' : lastMessageText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Text(
        timeText,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPageView(
              conversationId: conversation['_id'] ?? '',
              chatTitle: title,
              type: 'group',
              avatarUrl: avatarUrl,
              recipientId: null, // group không có recipientId
            ),
          ),
        );
      },
    );
  }

  void _handleQrCodeScanned(BuildContext context, String scannedValue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfilePage(userId: scannedValue)),
    );
  }
}
