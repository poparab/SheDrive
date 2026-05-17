import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shedrive_rider/core/theme/app_theme.dart';
import 'package:shedrive_rider/core/auth/auth_provider.dart';
import 'package:shedrive_rider/features/ride/presentation/screens/rider_home_screen.dart';

class RiderEkycScreen extends ConsumerStatefulWidget {
  const RiderEkycScreen({super.key});

  @override
  ConsumerState<RiderEkycScreen> createState() => _RiderEkycScreenState();
}

class _RiderEkycScreenState extends ConsumerState<RiderEkycScreen> {
  bool _idUploaded = false;
  bool _selfieUploaded = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Identity Verification', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure Your Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),
            const Text(
              'As a women-only app, verifying your identity ensures the safety of our entire community.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            
            _buildUploadCard(
              title: 'National ID',
              subtitle: 'Front and back of your official ID',
              icon: Icons.badge,
              isUploaded: _idUploaded,
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _idUploaded = true);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildUploadCard(
              title: 'Take a Selfie',
              subtitle: 'Must match your National ID photo',
              icon: Icons.camera_front,
              isUploaded: _selfieUploaded,
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _selfieUploaded = true);
                }
              },
            ),
            
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_idUploaded && _selfieUploaded) ? () {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      ref.read(authProvider.notifier).completeKyc();
                      context.go('/home');
                    }
                  });

                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text('Submit & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({required String title, required String subtitle, required IconData icon, required bool isUploaded, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: isUploaded ? Colors.green : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
          color: isUploaded ? Colors.green.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green.withOpacity(0.1) : AppTheme.secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isUploaded ? Colors.green : AppTheme.secondaryColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(isUploaded ? Icons.check_circle : Icons.upload_file, color: isUploaded ? Colors.green : Colors.grey),
          ],
        ),
      ),
    );
  }
}
