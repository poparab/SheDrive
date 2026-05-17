import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shedrive_rider/core/theme/app_theme.dart';
import 'package:shedrive_rider/core/storage/prefs.dart';
import 'package:shedrive_rider/core/auth/auth_provider.dart';
import 'package:shedrive_rider/features/auth/presentation/screens/login_screen.dart';

class DemoHud extends ConsumerStatefulWidget {
  const DemoHud({super.key});

  @override
  ConsumerState<DemoHud> createState() => _DemoHudState();
}

class _DemoHudState extends ConsumerState<DemoHud> {
  bool _showBanner = true;

  void _showDemoMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🛠️ Demo Developer Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Reset All Demo Data (Clear Prefs)'),
                  onTap: () async {
                    await Prefs.clear();
                    ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.visibility_off),
                  title: Text(_showBanner ? 'Hide DEMO Banner' : 'Show DEMO Banner'),
                  onTap: () {
                    setState(() => _showBanner = !_showBanner);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Trip Speed: 1x (Normal)'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Scenario: Happy Path'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Container(
                  height: 24,
                  color: AppTheme.secondaryColor.withOpacity(0.9),
                  child: const Center(
                    child: Text(
                      'DEMO MODE',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: FloatingActionButton(
              heroTag: 'demo_hud_fab_rider',
              mini: true,
              backgroundColor: Colors.black87,
              onPressed: () => _showDemoMenu(context),
              child: const Icon(Icons.construction, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
