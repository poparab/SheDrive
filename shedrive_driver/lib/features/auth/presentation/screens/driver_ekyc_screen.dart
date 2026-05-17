import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:shedrive_driver/core/theme/app_theme.dart';
import 'package:shedrive_driver/core/auth/auth_provider.dart';
import 'package:shedrive_driver/features/driver/presentation/screens/driver_home_screen.dart';

class DriverEkycScreen extends ConsumerStatefulWidget {
  const DriverEkycScreen({super.key});

  @override
  ConsumerState<DriverEkycScreen> createState() => _DriverEkycScreenState();
}

class _DriverEkycScreenState extends ConsumerState<DriverEkycScreen> {
  bool _idUploaded = false;
  bool _licenseUploaded = false;
  bool _vehicleUploaded = false;
  final ImagePicker _picker = ImagePicker();
  bool _selfieUploaded = false;

  bool get _isAllUploaded => _idUploaded && _licenseUploaded && _vehicleUploaded && _selfieUploaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Captain Verification', style: TextStyle(color: Colors.black87)),
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
              'Upload Documents',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please provide clear photos of the following documents to activate your captain account.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            
            _buildUploadCard(
              title: 'National ID',
              subtitle: 'Front and back',
              icon: Icons.badge,
              isUploaded: _idUploaded,
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _idUploaded = true);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Driver\'s License',
              subtitle: 'Valid local license',
              icon: Icons.card_membership,
              isUploaded: _licenseUploaded,
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _licenseUploaded = true);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Vehicle Registration',
              subtitle: 'Official Istimara',
              icon: Icons.directions_car,
              isUploaded: _vehicleUploaded,
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _vehicleUploaded = true);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Take a Selfie',
              subtitle: 'Clear photo of your face',
              icon: Icons.camera_front,
              isUploaded: _selfieUploaded,
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _selfieUploaded = true);
                }
              },
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAllUploaded ? () {
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
                child: const Text('Submit Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isUploaded ? Colors.green : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
          color: isUploaded ? Colors.green.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green.withOpacity(0.1) : AppTheme.secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isUploaded ? Colors.green : AppTheme.secondaryColor, size: 24),
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
