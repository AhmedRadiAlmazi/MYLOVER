import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';
import 'features/settings/screens/app_lock_overlay_screen.dart';

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
            child: AppLockWrapper(child: child!),
          );
        },
      ),
    );
  }
}

class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return widget.child;
    }
    
    // Lazy imports inside file to keep code structure clean
    return AppLockOverlayScreen(
      onUnlocked: () {
        setState(() {
          _isUnlocked = true;
        });
      },
    );
  }
}
