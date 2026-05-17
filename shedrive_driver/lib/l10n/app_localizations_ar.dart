// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'شي درايف كابتن';

  @override
  String get welcomeGreeting => 'مرحباً بكِ في شي درايف، يا كابتن!';

  @override
  String get yourSafeJourney => 'رحلتك الآمنة تبدأ هنا.';

  @override
  String get enterPhone => 'أدخلي رقم هاتفك للمتابعة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get verifyNumber => 'تحققي من رقمك';

  @override
  String get sentCode => 'لقد أرسلنا رمزاً مكوناً من 4 أرقام إلى هاتفك';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get verifyLogin => 'تحقق وتسجيل الدخول';

  @override
  String get safeTrusted => 'آمنة، موثوقة، للنساء';

  @override
  String get phoneHint => '١٢٣ ٤٥٦ ٧٨٩٠';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get byContinuing => 'بالمتابعة، أنتِ توافقين على ';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get andText => ' و ';

  @override
  String get privacyPolicy => 'سياسة الخصوصية.';

  @override
  String get securitySupport => 'دعم أمني على مدار الساعة للنساء';
}
