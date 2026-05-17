import 'package:flutter/material.dart';
import 'package:shedrive_driver/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shedrive_driver/core/theme/app_theme.dart';
import 'package:shedrive_driver/core/storage/prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final session = Prefs.session;
      if (session == null) {
        context.go(Prefs.onboardingSeen ? '/login' : '/onboarding');
      } else if (!session.kycVerified) {
        context.go('/kyc');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250, 
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.safeTrusted,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
