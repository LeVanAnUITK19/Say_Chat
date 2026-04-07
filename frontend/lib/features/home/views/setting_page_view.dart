import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/language_provider.dart';
import '../../../core/themes/theme_provider.dart';
import '../../../widgets/my_settingItem.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.setting),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Giao diện',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Settings card
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceBright,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  // Dark mode
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return _SettingRow(
                        icon: Icons.dark_mode_rounded,
                        iconColor: const Color(0xFF7B8FFF),
                        title: l10n.darkMode,
                        trailing: CupertinoSwitch(
                          value: themeProvider.isDarkMode,
                          activeColor: scheme.primary,
                          onChanged: (_) => themeProvider.toggleTheme(),
                        ),
                      );
                    },
                  ),

                  Divider(height: 1, indent: 56, color: scheme.outline.withOpacity(0.2)),

                  // Language
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, _) {
                      return _SettingRow(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF4F6AF5),
                        title: l10n.changeLanguage,
                        trailing: CupertinoSwitch(
                          value: languageProvider.currentLocale.languageCode == 'vi',
                          activeColor: scheme.primary,
                          onChanged: (_) => languageProvider.changeLocale(
                            languageProvider.currentLocale.languageCode == 'vi'
                                ? const Locale('en')
                                : const Locale('vi'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
