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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.setting),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          /// 🌙 DARK MODE
          SettingItem(
            title: l10n.darkMode,
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return CupertinoSwitch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                );
              },
            ),
          ),

          /// 🌐 LANGUAGE
          SettingItem(
            title: l10n.changeLanguage,
            trailing: Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                return CupertinoSwitch(
                  value: languageProvider.currentLocale.languageCode == 'vi',
                  onChanged: (_) => languageProvider.changeLocale(
                    languageProvider.currentLocale.languageCode == 'vi'
                        ? const Locale('en')
                        : const Locale('vi'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
