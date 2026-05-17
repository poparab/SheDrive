
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shedrive_rider/core/auth/auth_provider.dart';
import 'package:shedrive_rider/core/storage/prefs.dart';
import 'package:shedrive_rider/features/auth/presentation/screens/splash_screen.dart';
import 'package:shedrive_rider/features/auth/presentation/screens/rider_onboarding_screen.dart';
import 'package:shedrive_rider/features/auth/presentation/screens/login_screen.dart';
import 'package:shedrive_rider/features/auth/presentation/screens/otp_screen.dart';
import 'package:shedrive_rider/features/auth/presentation/screens/rider_ekyc_screen.dart';
import 'package:shedrive_rider/features/ride/presentation/screens/rider_home_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isSplash = state.matchedLocation == '/splash';
    final isOnboarding = state.matchedLocation == '/onboarding';
    final isLogin = state.matchedLocation == '/login';
    final isOtp = state.matchedLocation == '/otp';
    final isKyc = state.matchedLocation == '/kyc';

    final hasSeenOnboarding = Prefs.onboardingSeen;
    final session = Prefs.session;
    final isLoggedIn = session != null;
    final isKycVerified = session?.kycVerified ?? false;

    if (isSplash) return null; // Let splash decide when it's done via context.go

    if (!hasSeenOnboarding && !isOnboarding) {
      return '/onboarding';
    }

    if (hasSeenOnboarding && !isLoggedIn && !isLogin && !isOtp) {
      return '/login';
    }

    if (isLoggedIn && !isKycVerified && !isKyc) {
      return '/kyc';
    }

    if (isLoggedIn && isKycVerified && (isLogin || isOtp || isKyc || isOnboarding)) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const RiderOnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/kyc',
      builder: (context, state) => const RiderEkycScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const RiderHomeScreen(),
    ),
  ],
);

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authProvider, (_, __) => _router.refresh());
  return _router;
});
