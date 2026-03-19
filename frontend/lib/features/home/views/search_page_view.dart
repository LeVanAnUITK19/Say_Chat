import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../viewmodels/search_page_viewmodel.dart';
import 'user_profile_page.dart';

class SearchPageView extends StatelessWidget {
  const SearchPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<SearchPageViewmodel>(
      create: (context) => SearchPageViewmodel(context),

      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.search),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Consumer<SearchPageViewmodel>(
          builder: (context, vm, _) {
            // Kiểm tra xem đang search hay không
            final isSearchMode = vm.searchController.text.isNotEmpty;

            // Chọn danh sách nào để hiển thị
            final displayList = isSearchMode ? vm.searchResults : vm.friends;

            // Chọn loading state
            final isLoading = isSearchMode ? vm.isSearching : vm.isLoading;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  MyTextFieldSearch(
                    hintText: l10n.search,
                    obscureText: false,
                    controller: vm.searchController,
                    icon: Icons.search,
                    suffixIcon: Icons.qr_code,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    isSearchMode ? l10n.searchResult : l10n.listFriends,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Danh sách lời mời kết bạn (chỉ hiện khi không search)
                                if (!isSearchMode &&
                                    vm.friendRequests.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      'Lời mời kết bạn',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: vm.friendRequests.length,
                                    itemBuilder: (context, index) {
                                      final request = vm.friendRequests[index];
                                      final from = request['from'];
                                      final fromAvatar = from['avatarUrl'] as String?;
                                      final fromUsername = from['username'] as String? ?? '';
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          backgroundImage: fromAvatar != null
                                              ? NetworkImage(fromAvatar)
                                              : null,
                                          child: fromAvatar == null
                                              ? Text(
                                                  fromUsername.isNotEmpty
                                                      ? fromUsername[0].toUpperCase()
                                                      : 'U',
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          fromUsername.isNotEmpty ? fromUsername : 'Unknown',
                                        ),
                                        subtitle: const Text(
                                          'Muốn kết bạn với bạn',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              onPressed: () async {
                                                await vm.acceptFriendRequest(
                                                  request['_id'],
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Đã chấp nhận lời mời',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                await vm.declineFriendRequest(
                                                  request['_id'],
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Đã từ chối lời mời',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(thickness: 2),
                                ],

                                // Danh sách bạn bè hoặc kết quả tìm kiếm
                                if (displayList.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        isSearchMode
                                            ? l10n.noResult
                                            : l10n.noFriend,
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: displayList.length,
                                    itemBuilder: (context, index) {
                                      final user = displayList[index];
                                      final userAvatar = user['avatarUrl'] as String?;
                                      final userUsername = user['username'] as String? ?? '';
                                      return ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => UserProfilePage(
                                                userId: user['_id'],
                                                initialUsername: user['username'],
                                                initialAvatarUrl: user['avatarUrl'],
                                              ),
                                            ),
                                          );
                                        },
                                        leading: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => UserProfilePage(
                                                  userId: user['_id'],
                                                  initialUsername: user['username'],
                                                  initialAvatarUrl: user['avatarUrl'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            backgroundImage: userAvatar != null
                                                ? NetworkImage(userAvatar)
                                                : null,
                                            child: userAvatar == null
                                                ? Text(
                                                    userUsername.isNotEmpty
                                                        ? userUsername[0].toUpperCase()
                                                        : 'U',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        title: Text(
                                          userUsername.isNotEmpty ? userUsername : 'Unknown',
                                        ),
                                        subtitle: Text(user['email'] ?? ''),
                                        trailing: _buildTrailing(
                                          context,
                                          vm,
                                          user,
                                          isSearchMode,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    SearchPageViewmodel vm,
    Map<String, dynamic> user,
    bool isSearchMode,
  ) {
    // Nếu đang ở danh sách bạn bè → hiển thị trạng thái online/offline
    if (!isSearchMode) {
      final status = user['status'] ?? 'offline';
      final isOnline = status == 'online';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: isOnline ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
        ],
      );
    }

    // Nếu đang search → kiểm tra friendship status
    final friendshipStatus = user['friendshipStatus']; // 'friend', 'pending', 'none'

    if (friendshipStatus == 'friend') {
      return const Text('Bạn bè', style: TextStyle(fontSize: 12));
    } else if (friendshipStatus == 'pending') {
      return const Text('Đã gửi lời mời', style: TextStyle(fontSize: 12));
    } else {
      // friendshipStatus == 'none' → chưa kết bạn
      return ElevatedButton(
        onPressed: () {
          vm.sendFriendRequest(user['_id']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi lời mời kết bạn')),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text('Kết bạn', style: TextStyle(fontSize: 12)),
      );
    }
  }
}
