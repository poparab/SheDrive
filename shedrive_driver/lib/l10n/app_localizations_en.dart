// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SheDrive Driver';

  @override
  String get welcomeGreeting => 'Welcome to SheDrive, Captain!';

  @override
  String get yourSafeJourney => 'Your safe journey starts here.';

  @override
  String get enterPhone => 'Enter your phone number to continue';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyNumber => 'Verify your number';

  @override
  String get sentCode => 'We sent a 4-digit code to your phone';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get verifyLogin => 'Verify & Login';

  @override
  String get safeTrusted => 'Safe, Trusted, For Women';

  @override
  String get phoneHint => '123 456 7890';

  @override
  String get orContinueWith => 'OR CONTINUE WITH';

  @override
  String get byContinuing => 'By continuing, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andText => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy.';

  @override
  String get securitySupport => '24/7 Security Support for Women';
}
