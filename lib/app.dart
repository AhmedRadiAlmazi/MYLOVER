import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';

class MyUniverseApp extends ConsumerWidget {
  const MyUniverseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        title: 'كوني أنت',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(seedColor: themeState.primaryColor, isDark: false),
        darkTheme: AppTheme.getTheme(seedColor: themeState.primaryColor, isDark: true),
        themeMode: themeState.themeMode,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ar', 'SA'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
