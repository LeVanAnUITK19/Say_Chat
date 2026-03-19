import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodels/createGroup_page_viewmodel.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ChangeNotifierProvider(
      create: (context) => CreateGroupPageViewmodel(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.createGroup),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Consumer<CreateGroupPageViewmodel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                // TextField nhập tên nhóm
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: vm.groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Tên nhóm',
                      hintText: 'Nhập tên nhóm...',
                      prefixIcon: const Icon(Icons.group),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // TextField tìm kiếm bạn bè
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: vm.searchController,
                    onChanged: vm.searchFriends,
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm bạn bè',
                      hintText: 'Nhập tên bạn bè...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Hiển thị số thành viên đã chọn
                if (vm.selectedFriendIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đã chọn ${vm.selectedFriendIds.length} thành viên',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 1),

                // Danh sách bạn bè
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.filteredFriends.isEmpty
                          ? const Center(
                              child: Text('Không có bạn bè nào'),
                            )
                          : ListView.builder(
                              itemCount: vm.filteredFriends.length,
                              itemBuilder: (context, index) {
                                final friend = vm.filteredFriends[index];
                                final friendId = friend['_id'] as String;
                                final isSelected = vm.isFriendSelected(friendId);

                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    vm.toggleFriendSelection(friendId);
                                  },
                                  secondary: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    backgroundImage: friend['avatarUrl'] != null
                                        ? NetworkImage(friend['avatarUrl'])
                                        : null,
                                    child: friend['avatarUrl'] == null
                                        ? Text(
                                            (friend['username'] ?? 'U')[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.white),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    friend['username'] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: friend['status'] != null
                                      ? Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: friend['status'] == 'online'
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              friend['status'] == 'online'
                                                  ? 'Online'
                                                  : 'Offline',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: friend['status'] == 'online'
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                );
                              },
                            ),
                ),

                // Nút tạo nhóm
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: vm.isCreating
                        ? null
                        : () async {
                            final success = await vm.createGroup();
                            if (success && context.mounted) {
                              Navigator.pop(context, true); // Trả về true để refresh
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: vm.isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Tạo nhóm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}