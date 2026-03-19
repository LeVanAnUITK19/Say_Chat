import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:say_chat/features/home/views/setting_page_view.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../core/providers/auth_provider.dart';
import 'package:say_chat/features/home/views/person_page_view.dart';
import 'package:say_chat/features/home/views/createGroup_page_view.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final avatarUrl = user?['avatarUrl'] as String?;
    final username = user?['username'] as String? ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonPage()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            username.isNotEmpty ? username[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 28,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    username,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l10n.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(l10n.profile),
            onTap: () {
              Navigator.pop(context);
              //natigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: Text(l10n.createGroup),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.setting),
            onTap: () {
              //pop the drawer
              Navigator.pop(context);
              //natigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              // Dừng heartbeat service
              Provider.of<AuthProvider>(context, listen: false).onLogout();

              // Gọi API logout
              await AuthRepository().logout();

              // Navigate về login
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
