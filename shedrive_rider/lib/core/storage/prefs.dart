import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shedrive_rider/core/auth/session.dart';

class Prefs {
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> clear() async => await _prefs.clear();
  
  static bool get onboardingSeen => _prefs.getBool('shedrive.onboardingSeen') ?? false;
  static set onboardingSeen(bool value) => _prefs.setBool('shedrive.onboardingSeen', value);

  static Session? get session {
    final str = _prefs.getString('shedrive.session');
    if (str != null) return Session.fromJson(jsonDecode(str));
    return null;
  }

  static set session(Session? value) {
    if (value != null) {
      _prefs.setString('shedrive.session', jsonEncode(value.toJson()));
    }
  }

  static void clearSession() {
    _prefs.remove('shedrive.session');
  }
}
