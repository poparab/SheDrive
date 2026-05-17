import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shedrive_rider/l10n/app_localizations.dart';
import 'package:shedrive_rider/core/theme/app_theme.dart';
import 'package:shedrive_rider/core/storage/prefs.dart';
import 'package:shedrive_rider/core/demo/demo_hud.dart';
import 'package:shedrive_rider/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(
    const ProviderScope(
      child: SheDriveApp(),
    ),
  );
}

class SheDriveApp extends ConsumerWidget {
  const SheDriveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SheDrive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const DemoHud(),
          ],
        );
      },
    );
  }
}
