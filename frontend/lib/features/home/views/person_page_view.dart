import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodels/person_page_viewmodel.dart';
import 'qr_code_display_page.dart';

class PersonPage extends StatelessWidget {
  const PersonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ChangeNotifierProvider(
      create: (context) => PersonPageViewmodel(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.inPerson),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit profile
              },
            ),
          ],
        ),
        body: Consumer<PersonPageViewmodel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: vm.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Avatar và tên
                    _buildProfileHeader(context, vm),

                    const SizedBox(height: 24),

                    // Thống kê
                    _buildStatsSection(context, vm),

                    const SizedBox(height: 16),

                    // Thông tin chi tiết
                    _buildInfoSection(context, vm),

                    const SizedBox(height: 16),

                    // Actions
                    _buildActionsSection(context, vm),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, PersonPageViewmodel vm) {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: vm.avatarUrl != null
                  ? NetworkImage(vm.avatarUrl!)
                  : null,
              child: vm.avatarUrl == null
                  ? Text(
                      vm.username?.isNotEmpty == true
                          ? vm.username![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: vm.isUploadingAvatar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: vm.pickAndUpdateAvatar,
                        padding: EdgeInsets.zero,
                      ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Username
        Text(
          vm.username ?? 'Unknown',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 4),

        // Email
        Text(
          vm.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),

        const SizedBox(height: 8),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: vm.status == 'online' ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                vm.status == 'online' ? 'Online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, PersonPageViewmodel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.people,
              label: 'Bạn bè',
              value: vm.friendsCount.toString(),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.chat,
              label: 'Cuộc trò chuyện',
              value: vm.conversationsCount.toString(),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, PersonPageViewmodel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icon: Icons.person,
                label: 'Tên người dùng',
                value: vm.username ?? 'N/A',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                icon: Icons.email,
                label: 'Email',
                value: vm.email ?? 'N/A',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Ngày tham gia',
                value: vm.formatJoinDate(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, PersonPageViewmodel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildActionButton(
            context,
            icon: Icons.qr_code,
            label: 'Mã QR của tôi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCodeDisplayPage(
                    username: vm.username ?? '',
                    email: vm.email ?? '',
                    avatarUrl: vm.avatarUrl,
                    userId: vm.userInfo?['id'] ?? vm.userInfo?['_id'] ?? '',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            icon: Icons.lock,
            label: 'Đổi mật khẩu',
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            icon: Icons.settings,
            label: 'Cài đặt',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}