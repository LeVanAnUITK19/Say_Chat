import 'package:flutter/material.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_vi.dart';
import '../l10n/app_localizations.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('vi');

  Locale get currentLocale => _currentLocale;

  void changeLocale(Locale newLocale) {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      notifyListeners();
    }
  }

  AppLocalizations get localizations {
    switch (_currentLocale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'vi':
      default:
        return AppLocalizationsVi();
    }
  }
}