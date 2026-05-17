import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shedrive_driver/l10n/app_localizations.dart';
import 'package:shedrive_driver/core/theme/app_theme.dart';
import 'package:shedrive_driver/core/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shedrive_driver/features/auth/presentation/screens/driver_ekyc_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _hasError = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  void _verifyOtp() {
    String code = _controllers.map((c) => c.text).join();
    if (code == '1234') {
      setState(() => _hasError = false);
      ref.read(authProvider.notifier).login('+201000000001');
      if (mounted) context.go('/kyc');
    } else {
      setState(() => _hasError = true);
      _shake();
      for (var c in _controllers) { c.clear(); }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var c in _controllers) { c.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lightPinkBg = const Color(0xFFFFF5F8);
    final inputBg = _hasError ? Colors.red.shade50 : const Color(0xFFF9EAF2);

    return Scaffold(
      backgroundColor: lightPinkBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/otp_bg.png',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.verifyNumber,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.sentCode,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // OTP Card
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final sineValue = 
                          math.sin(4 * 3.1415926535 * _shakeController.value) * 8.0;
                      return Transform.translate(
                        offset: Offset(sineValue, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              4,
                              (index) => SizedBox(
                                width: 60,
                                height: 65,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontSize: 28, 
                                    fontWeight: FontWeight.bold, 
                                    color: _hasError ? Colors.red : AppTheme.primaryColor
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    fillColor: inputBg,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: _hasError ? Colors.red : AppTheme.primaryColor, 
                                        width: 2
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() => _hasError = false);
                                    if (value.isNotEmpty && index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isNotEmpty && index == 3) {
                                      _verifyOtp();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (_hasError)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text('Invalid code. Try 1234 for demo.', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l10n.verifyLogin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              for (int i = 0; i < 4; i++) {
                                _controllers[i].text = '${i + 1}';
                              }
                              _verifyOtp();
                            },
                            child: const Text('Auto-fill 1234', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: _secondsRemaining == 0 ? _startTimer : null,
                      child: Text(
                        _secondsRemaining > 0 
                          ? '${l10n.resendCode} in ${_secondsRemaining}s'
                          : l10n.resendCode,
                        style: TextStyle(
                          color: _secondsRemaining > 0 ? Colors.grey : AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
