import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/language_provider.dart';
import 'features/auth/views/login_page_view.dart';
import 'package:provider/provider.dart';
import 'core/themes/theme_provider.dart';
import 'features/chat/views/home_page_view.dart';
import 'core/api/dio_client.dart';

void main() {
  DioClient().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAY CHAT',
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Provider.of<LanguageProvider>(context).currentLocale,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePageView(),
      routes: {
        '/home': (context) => const HomePageView(),
        '/login': (context) => const LoginPageView(),
      },
    );
  }
}
