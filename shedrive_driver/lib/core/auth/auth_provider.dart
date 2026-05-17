import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shedrive_driver/core/auth/session.dart';
import 'package:shedrive_driver/core/storage/prefs.dart';

class AuthNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    return Prefs.session;
  }

  void login(String phone) {
    final newSession = Session(
      userId: 'driver_${DateTime.now().millisecondsSinceEpoch}',
      phone: phone,
      role: 'driver',
      kycVerified: false,
      loggedInAt: DateTime.now(),
    );
    state = newSession;
    Prefs.session = newSession;
  }

  void completeKyc() {
    if (state != null) {
      final updated = Session(
        userId: state!.userId,
        phone: state!.phone,
        role: state!.role,
        kycVerified: true,
        loggedInAt: state!.loggedInAt,
      );
      state = updated;
      Prefs.session = updated;
    }
  }

  void logout() {
    state = null;
    Prefs.clearSession();
    // In a real app, we'd also clear the bridge connection here
  }
}

final authProvider = NotifierProvider<AuthNotifier, Session?>(AuthNotifier.new);
