import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_profile_viewmodel.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;
  final String? initialUsername;
  final String? initialAvatarUrl;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.initialUsername,
    this.initialAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileViewmodel(userId),
      child: Consumer<UserProfileViewmodel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(vm.isLoading ? (initialUsername ?? '') : vm.username),
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileViewmodel vm) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header với avatar + tên + status
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                  backgroundImage: vm.avatarUrl != null ? NetworkImage(vm.avatarUrl!) : null,
                  child: vm.avatarUrl == null
                      ? Text(
                          vm.username.isNotEmpty ? vm.username[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 40,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  vm.username,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                _buildStatusBadge(context, vm.status),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Thông tin
          _buildInfoCard(context, vm),

          const SizedBox(height: 16),

          // Nút hành động
          _buildActionButton(context, vm),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final isOnline = status == 'online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, UserProfileViewmodel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _infoRow(context, Icons.person, 'Tên người dùng', vm.username),
              const Divider(height: 20),
              _infoRow(context, Icons.email, 'Email', vm.email),
              const Divider(height: 20),
              _infoRow(context, Icons.calendar_today, 'Ngày tham gia', vm.formatJoinDate()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, UserProfileViewmodel vm) {
    final status = vm.friendshipStatus;

    if (status == 'friend') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, color: Colors.green),
              SizedBox(width: 8),
              Text('Đã là bạn bè', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    if (status == 'pending_sent') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, color: Colors.orange),
              SizedBox(width: 8),
              Text('Đã gửi lời mời', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    if (status == 'pending_received') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, color: Colors.blue),
              SizedBox(width: 8),
              Text('Đã gửi lời mời cho bạn', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    // status == 'none' → nút gửi lời mời
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: vm.isSending
              ? null
              : () async {
                  final ok = await vm.sendFriendRequest();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Đã gửi lời mời kết bạn' : 'Gửi lời mời thất bại')),
                    );
                  }
                },
          icon: vm.isSending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.person_add),
          label: const Text('Kết bạn'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
