import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shedrive_driver/core/theme/app_theme.dart';
import 'dart:async';
import 'package:shedrive_driver/core/storage/prefs.dart';
import 'package:shedrive_driver/core/bridge/local_bus.dart';
import 'package:shedrive_driver/core/map/map_service.dart';
import 'package:shedrive_driver/core/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

enum DriverTripStage { idle, enRouteToPickup, atPickup, inTrip }

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late bool _isOnline;
  DriverTripStage _driverTripStage = DriverTripStage.idle;
  Map<String, dynamic>? _currentTripData;
  double _currentFare = 0.0;
  Timer? _fareTimer;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isOnline = Prefs.driverOnline;
  }

  void _toggleOnline() {
    setState(() {
      _isOnline = !_isOnline;
      Prefs.driverOnline = _isOnline;
    });
  }

  @override
  void dispose() {
    _fareTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _showIncomingRequest(Map<String, dynamic>? data) {
    final String pickup = data?['pickupName'] ?? 'Zamalek';
    final String dropoff = data?['destName'] ?? 'Maadi';
    final String price = data?['price'] ?? '£ 65.00';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('New Ride Request!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pickup: $pickup', style: const TextStyle(fontSize: 16)),
                  const Text('3 min away', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dropoff: $dropoff', style: const TextStyle(fontSize: 16)),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.child_care, color: AppTheme.secondaryColor),
                  SizedBox(width: 8),
                  Text('Child Accompanied', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _driverTripStage = DriverTripStage.enRouteToPickup;
                          _currentTripData = data ?? {
                            'pickupName': pickup,
                            'destName': dropoff,
                            'price': price,
                          };
                        });
                        ref.read(localBusProvider.notifier).broadcast({'type': 'ride_accepted'});
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localBusProvider, (previous, next) {
      if (next.isNotEmpty) {
        final lastEvent = next.last;
        if (lastEvent['type'] == 'ride_request' && _isOnline && _driverTripStage == DriverTripStage.idle) {
          _showIncomingRequest(lastEvent);
        }
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.drive_eta, color: AppTheme.primaryColor, size: 35)),
                  SizedBox(height: 10),
                  Text('Captain Sarah', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () {}),
            ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('Earnings'), onTap: () {}),
            ListTile(leading: const Icon(Icons.directions_car), title: const Text('Vehicle Info'), onTap: () {}),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop(); // close the drawer first
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log out?'),
                    content: const Text('You will be returned to the login screen.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Log out', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(30.0444, 31.2357),
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.shedrive',
              ),
              if (_driverTripStage != DriverTripStage.idle) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: ref.read(mapServiceProvider).getRoute(
                        const LatLng(30.0444, 31.2357), 
                        const LatLng(30.0636, 30.9839)
                      ),
                      color: AppTheme.primaryColor,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(30.0636, 30.9839),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          // Menu Button & Top Status Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
                if (_driverTripStage == DriverTripStage.idle)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.power_settings_new, color: _isOnline ? Colors.white : Colors.black54, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline ? 'ONLINE' : 'OFFLINE',
                          style: TextStyle(
                            color: _isOnline ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 40), 
              ],
            ),
            ),
          
          // Online Toggle Button
          if (_driverTripStage == DriverTripStage.idle)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleOnline,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.red : AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: (_isOnline ? Colors.red : AppTheme.primaryColor).withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isOnline ? 'GO\nOFFLINE' : 'GO\nONLINE',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
          // SOS Button
          if (_driverTripStage != DriverTripStage.idle)
            Positioned(
              top: 50,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'sos_driver',
                mini: true,
                backgroundColor: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('SOS Emergency'),
                      content: const Text('Connecting to Ministry of Interior...\nOperator ETA 90s.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.sos, color: Colors.white),
              ),
            ),

          // Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  
                  if (_driverTripStage == DriverTripStage.idle) ...[
                    const Text('Today\'s Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard('Earnings', '£ 450.00', Icons.account_balance_wallet, AppTheme.primaryColor),
                        const SizedBox(width: 16),
                        _buildStatCard('Acceptance', '98%', Icons.check_circle, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isOnline ? () => _showIncomingRequest(null) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Text(
                          _isOnline ? 'Simulate Incoming Request (Demo)' : 'Go Online to receive requests', 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _isOnline ? Colors.white : Colors.grey.shade600)
                        ),
                      ),
                    ),
                  ] else ...[
                    // Active Trip View
                    Text(
                      _driverTripStage == DriverTripStage.enRouteToPickup ? 'En Route to Pickup' :
                      _driverTripStage == DriverTripStage.atPickup ? 'At Pickup' : 'Trip in Progress',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Passenger Reem', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(_driverTripStage == DriverTripStage.inTrip ? 'Fare: £ ${_currentFare.toStringAsFixed(2)}' : 'Rating: 4.9', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (_driverTripStage == DriverTripStage.enRouteToPickup)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _driverTripStage = DriverTripStage.atPickup);
                            ref.read(localBusProvider.notifier).broadcast({'type': 'driver_arrived'});
                          },
                          icon: const Icon(Icons.location_on, color: Colors.white),
                          label: const Text("I've Arrived", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      )
                    else if (_driverTripStage == DriverTripStage.atPickup)
                      Column(
                        children: [
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: const InputDecoration(
                              labelText: 'Enter OTP from Rider',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_otpController.text == '5678') {
                                  setState(() {
                                    _driverTripStage = DriverTripStage.inTrip;
                                    _currentFare = 65.0; // Base fare
                                  });
                                  _fareTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                                    setState(() => _currentFare += 0.25);
                                  });
                                  ref.read(localBusProvider.notifier).broadcast({'type': 'trip_started'});
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: const Text("Start Trip", style: TextStyle(color: Colors.white)),
                            ),
                          )
                        ],
                      )
                    else if (_driverTripStage == DriverTripStage.inTrip)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _fareTimer?.cancel();
                            ref.read(localBusProvider.notifier).broadcast({'type': 'trip_completed', 'fare': _currentFare});
                            setState(() {
                              _driverTripStage = DriverTripStage.idle;
                              _currentTripData = null;
                            });
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('End Trip', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
