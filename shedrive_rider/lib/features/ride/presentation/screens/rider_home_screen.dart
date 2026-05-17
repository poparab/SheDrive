import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shedrive_rider/core/theme/app_theme.dart';
import 'package:shedrive_rider/core/map/map_service.dart';
import 'package:shedrive_rider/core/bridge/local_bus.dart';
import 'package:shedrive_rider/core/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

enum RiderState { initial, confirming, matching, enRoute, atPickup, inTrip }

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isChildAccompanied = false;
  RiderState _currentState = RiderState.initial;
  String _selectedDestination = '';
  final LatLng _startLocation = const LatLng(30.0444, 31.2357);
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mapServiceProvider).loadPois());
  }

  void _selectDestination(String dest, LatLng loc) {
    setState(() {
      _selectedDestination = dest;
      _selectedLocation = loc;
      _currentState = RiderState.confirming;
    });
  }

  void _confirmRide() {
    setState(() {
      _currentState = RiderState.matching;
    });

    ref.read(localBusProvider.notifier).broadcast({
      'type': 'ride_request',
      'riderId': 'rider_1',
      'pickupName': 'Current Location',
      'destName': _selectedDestination,
      'price': '£ 45.00',
    });
  }

  void _cancelRide() {
    setState(() {
      _currentState = RiderState.initial;
      _selectedDestination = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localBusProvider, (previous, next) {
      if (next.isNotEmpty) {
        final lastEvent = next.last;
        if (lastEvent['type'] == 'ride_accepted' && _currentState == RiderState.matching) {
          if (mounted) {
            setState(() {
              _currentState = RiderState.enRoute;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Captain is on the way!'), backgroundColor: Colors.green),
            );
          }
        } else if (lastEvent['type'] == 'driver_arrived' && _currentState == RiderState.enRoute) {
          if (mounted) {
            setState(() => _currentState = RiderState.atPickup);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Captain has arrived!'), backgroundColor: Colors.green));
          }
        } else if (lastEvent['type'] == 'trip_started' && _currentState == RiderState.atPickup) {
          if (mounted) {
            setState(() => _currentState = RiderState.inTrip);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip started!'), backgroundColor: Colors.green));
          }
        } else if (lastEvent['type'] == 'trip_completed' && _currentState == RiderState.inTrip) {
          if (mounted) {
            setState(() {
              _currentState = RiderState.initial;
              _selectedDestination = '';
            });
            final fare = lastEvent['fare'] ?? 65.0;
            showDialog(
              context: context, 
              builder: (_) => AlertDialog(
                title: const Text('Trip Completed'), 
                content: Text('Total Fare: £${fare.toStringAsFixed(2)}'), 
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]
              )
            );
          }
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
                  CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppTheme.primaryColor, size: 35)),
                  SizedBox(height: 10),
                  Text('Sister Passenger', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.history), title: const Text('Ride History'), onTap: () {}),
            ListTile(leading: const Icon(Icons.payment), title: const Text('Payment Methods'), onTap: () {}),
            ListTile(leading: const Icon(Icons.local_offer), title: const Text('Promotions'), onTap: () {}),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.support_agent), title: const Text('Support'), onTap: () {}),
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
              initialCenter: LatLng(30.0444, 31.2357), // Cairo, Egypt
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.shedrive',
              ),
              PolylineLayer(
                polylines: [
                  if (_currentState != RiderState.initial && _selectedLocation != null)
                    Polyline(
                      points: ref.read(mapServiceProvider).getRoute(_startLocation, _selectedLocation!),
                      color: AppTheme.primaryColor,
                      strokeWidth: 4.0,
                    ),
                ],
              ),
            ],
          ),
          
          // Menu Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ),
          
          // SOS Button (Safety Pillar)
          if (_currentState == RiderState.enRoute || _currentState == RiderState.atPickup || _currentState == RiderState.inTrip)
            Positioned(
              top: 50,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'sos',
                mini: true,
                backgroundColor: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('SOS Emergency'),
                      content: const Text('Connecting to Ministry of Interior...\nOperator ETA 90s.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('I am safe now'))
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
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
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
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_currentState == RiderState.initial) ...[
            GestureDetector(
              onTap: _showSearchSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Where to, Sister?', style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSavedPlace(Icons.home, 'Home', '2.5 km', () => _selectDestination('Home', const LatLng(30.0276, 31.2101))),
                const SizedBox(width: 16),
                _buildSavedPlace(Icons.work, 'Work', '8.1 km', () => _selectDestination('Work', const LatLng(30.0765, 30.0163))),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.secondaryColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.child_care, color: AppTheme.secondaryColor),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Child Accompanied', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Extra safety for kids', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _isChildAccompanied,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) => setState(() => _isChildAccompanied = val),
                ),
              ],
            ),
          ] 
          else if (_currentState == RiderState.confirming) ...[
            Text('To: $_selectedDestination', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Economy Female Driver', style: TextStyle(fontSize: 16)),
                Text('£ 45.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmRide,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Confirm Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: _cancelRide,
              child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.grey))),
            )
          ]
          else if (_currentState == RiderState.matching) ...[
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 20),
                  Text('Finding your captain...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ]
          else if (_currentState == RiderState.enRoute || _currentState == RiderState.atPickup || _currentState == RiderState.inTrip) ...[
            Text(
              _currentState == RiderState.enRoute ? 'Captain is on the way' :
              _currentState == RiderState.atPickup ? 'Captain has arrived' : 'Trip in Progress',
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amira H.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' 4.9 • Hyundai Tucson'),
                        ],
                      ),
                      Text('س ص ع 123', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                if (_currentState == RiderState.enRoute)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Column(
                      children: [
                        Text('3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        Text('min', style: TextStyle(fontSize: 12, color: Colors.green)),
                      ],
                    ),
                  ),
              ],
            ),
            if (_currentState == RiderState.atPickup) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.vpn_key, color: Colors.amber),
                    SizedBox(width: 12),
                    Text('Your OTP: ', style: TextStyle(fontSize: 16)),
                    Text('5678', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('First-Aid Certified Captain', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text('Call', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('Message', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            if (_currentState != RiderState.inTrip)
              TextButton(
                onPressed: _cancelRide,
                child: const Center(child: Text('Cancel Trip', style: TextStyle(color: Colors.red))),
              )
          ]
        ],
      ),
    );
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final pois = ref.read(mapServiceProvider).searchPois(query);
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search destination...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      setModalState(() => query = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pois.length,
                      itemBuilder: (context, index) {
                        final poi = pois[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.grey),
                          title: Text(poi.name),
                          subtitle: Text(poi.type),
                          onTap: () {
                            Navigator.pop(context);
                            _selectDestination(poi.name, poi.location);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSavedPlace(IconData icon, String title, String distance, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
