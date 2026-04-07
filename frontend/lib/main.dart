import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/language_provider.dart';
import 'features/auth/views/login_page_view.dart';
import 'package:provider/provider.dart';
import 'core/themes/theme_provider.dart';
import 'features/home/views/home_page_view.dart';
import 'core/api/dio_client.dart';
import 'core/providers/auth_provider.dart';
import 'features/chat/views/chat_page_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  try {
    DioClient().initialize();
    print('✅ DioClient initialized successfully');
  } catch (e) {
    print('❌ Error initializing DioClient: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
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
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      title: 'SECRET_CHAT',
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        
      ],
      locale: Provider.of<LanguageProvider>(context).currentLocale,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const LoginPageView(),
      routes: {
        '/home': (context) => const HomePageView(),
        '/login': (context) => const LoginPageView(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChatPageView(
            conversationId: args['conversationId'] as String,
            chatTitle: args['username'] as String? ?? '',
            type: args['type'] as String? ?? 'direct',
            avatarUrl: args['avatarUrl'] as String?,
            recipientId: args['recipientId'] as String?,
          );
        },
      },
    );
  }
}
