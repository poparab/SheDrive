# SheDrive Demo — Current Status, Bugs & How to Run

**Date:** 2026-05-16
**Apps:** `shedrive_rider/` · `shedrive_driver/`

---

## Part 1 — What's Actually Working Right Now

### ✅ Fully working
| Item | Where |
|---|---|
| go_router wired with redirect guards | both `core/router/app_router.dart` |
| Riverpod properly used — authProvider, localBusProvider, mapServiceProvider | both apps |
| `main.dart` bootstrap (ensureInitialized, Prefs.init, ProviderScope, MaterialApp.router) | both apps |
| Session model serialises/deserialises from SharedPreferences | both `core/auth/` |
| `Prefs.driverOnline` persists across restarts | `shedrive_driver` |
| OTP — shake on wrong code, 60 s countdown, auto-submit on 4th digit, "Auto-fill 1234", error colour | both `otp_screen.dart` |
| Login — validation, loading spinner, "Auto-fill Demo Number" | both `login_screen.dart` |
| "Continue as Guest (Demo)" shortcut on rider login | rider `login_screen.dart` |
| DemoHud on every screen — "DEMO MODE" banner + wrench FAB + reset prefs | both apps |
| Asset pipeline — `login_bg.png`, `logo.png`, `otp_bg.png`, `cairo_pois.json` | both apps |
| Rider home state machine — `initial → confirming → matching → enRoute` in one screen | rider `rider_home_screen.dart` |
| "Where to" search modal opens with POI fuzzy-search | rider home |
| Polyline layer visible on map after destination selected (straight line, but visible) | rider home |
| Saved-place chips ("Home", "Work") tap directly to confirming state | rider home |
| Child-accompanied toggle | rider home |
| Incoming request bottom sheet — pickup/dropoff/price/child flag | driver home |
| "Simulate Incoming Request (Demo)" button — works standalone, no rider needed | driver home |
| Driver online/offline toggle — colour, label, persisted | driver home |
| Driver broadcasts `ride_accepted` on Accept | driver home |
| Rider listens for `ride_accepted` and transitions to enRoute (shows driver card) | rider home |
| SOS AlertDialog on both apps when in active/en-route state | both home screens |
| KYC calls `authProvider.completeKyc()` after 2 s delay | both eKYC screens |

### ⚠️ Partially working
| Item | Problem |
|---|---|
| Destination search | Only 5 POIs — typing anything unusual returns nothing |
| Rider eKYC upload tiles | Tap toggles boolean (looks correct visually) but no camera opens — `image_picker` imported but unused |
| Driver eKYC same | Same — all four tiles are tap-to-toggle, no camera |
| DemoHud speed/scenario controls | UI exists but buttons are no-ops (no logic wired) |
| SOS — both apps | Shows an AlertDialog, not a real screen; "I am safe now" just pops the dialog |

---

## Part 2 — What Is Broken (with exact cause)

### Bug 1 — CRITICAL: Router does not redirect after login or KYC ❌

**Symptom:** After entering OTP `1234` and tapping Verify/Auto-fill, nothing happens. App stays on the OTP screen. Same for KYC submit — stays on KYC.

**Root cause:** `routerProvider` is a `Provider<GoRouter>`. When `authProvider` changes (session updated), Riverpod recreates the GoRouter instance. A new GoRouter starts at `initialLocation: '/splash'` and fires the redirect from there. The splash redirect rule is `if (isSplash) return null` — so it just shows the splash screen, which itself does `context.go('/login')` after 3 s. Net result: the user gets bounced back through splash → login.

**Fix — OTP screen (both apps):** After `authProvider.login()` succeeds, explicitly navigate instead of relying on the router redirect:
```dart
// In _verifyOtp(), after authProvider.login():
ref.read(authProvider.notifier).login(phone);
if (context.mounted) context.go('/kyc');
```

**Fix — KYC screen (both apps):** After `authProvider.completeKyc()` succeeds, explicitly navigate:
```dart
// In the submit button, inside Future.delayed:
ref.read(authProvider.notifier).completeKyc();
if (mounted) context.go('/home');
```

**Fix — routerProvider (both apps):** Change `Provider<GoRouter>` to a stable instance using `ref.listen` on `authProvider` and calling `router.refresh()`. Replace the current pattern:
```dart
// Replace routerProvider with:
final _router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) { /* same logic */ },
  routes: [ /* same routes */ ],
);

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authProvider, (_, __) => _router.refresh());
  return _router;
});
```
This creates the router once, and `ref.listen` calls `router.refresh()` whenever the session changes, which triggers the redirect guard without recreating the router or resetting navigation to splash.

---

### Bug 2 — CRITICAL: Bridge is client-only — cross-app communication is dead ❌

**Symptom:** Rider taps "Confirm Ride" → broadcasts `ride_request` → nothing arrives on the driver. Driver taps "Accept" → broadcasts `ride_accepted` → nothing arrives on the rider. The matching screen spins forever.

**Root cause:** Both `local_bus.dart` files only contain a WebSocket **client** that connects to `ws://localhost:8080`. There is no WebSocket **server**. The `shelf` and `shelf_web_socket` packages are in both pubspecs but never used. Every `broadcast()` call goes nowhere.

**Fix — `local_bus.dart` (identical change in both apps):**

Replace the entire file with a host/client auto-negotiating implementation:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocalBusNotifier extends Notifier<List<Map<String, dynamic>>> {
  final List<WebSocketChannel> _clients = [];  // server tracks connected clients
  WebSocketChannel? _selfChannel;              // our own client connection
  HttpServer? _server;
  bool _isHost = false;

  @override
  List<Map<String, dynamic>> build() {
    Future.microtask(_init);
    ref.onDispose(_dispose);
    return [];
  }

  Future<void> _init() async {
    // Try to become the host (server). If port 8080 is already taken, connect as client.
    try {
      final handler = webSocketHandler((WebSocketChannel incoming) {
        _clients.add(incoming);
        incoming.stream.listen(
          (raw) {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;
            // Deliver locally
            state = [...state, data];
            // Fan out to every other connected client
            for (final c in List.of(_clients)) {
              if (c != incoming) {
                try { c.sink.add(raw); } catch (_) { _clients.remove(c); }
              }
            }
          },
          onDone: () => _clients.remove(incoming),
          onError: (_) => _clients.remove(incoming),
        );
      });
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      _isHost = true;
      // Connect our own client to ourselves so broadcast() works uniformly
      await Future.delayed(const Duration(milliseconds: 100));
      _connectClient();
    } catch (_) {
      // Port busy → another app is already hosting → just connect as client
      _connectClient();
    }
  }

  void _connectClient() {
    try {
      _selfChannel = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8080'));
      _selfChannel!.stream.listen(
        (raw) {
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          state = [...state, data];
        },
        onError: (_) {},
        onDone: () {},
      );
    } catch (_) {}
  }

  void broadcast(Map<String, dynamic> event) {
    _selfChannel?.sink.add(jsonEncode(event));
  }

  void _dispose() {
    _selfChannel?.sink.close();
    for (final c in _clients) { c.sink.close(); }
    _server?.close(force: true);
  }
}

final localBusProvider =
    NotifierProvider<LocalBusNotifier, List<Map<String, dynamic>>>(
        LocalBusNotifier.new);
```

**How it works:** Whichever app launches first binds on port 8080 and becomes the server. The second app finds port 8080 busy and connects as a client. Both apps then send/receive through the server. Same-device (emulator or physical): loopback `127.0.0.1` works. Two physical devices on the same WiFi: replace `127.0.0.1` with the host device's LAN IP (make it configurable in DemoHud for two-device demos).

---

### Bug 3 — CRITICAL: Splash always routes to `/login` regardless of session ❌

**Symptom:** Kill and reopen either app with a valid session — always lands on login instead of home.

**Root cause:** Both `splash_screen.dart` files hard-code `context.go('/login')`.

**Fix — `splash_screen.dart` (both apps):**
```dart
Future.delayed(const Duration(seconds: 2), () {
  if (!mounted) return;
  final session = Prefs.session;
  if (session == null) {
    context.go(Prefs.onboardingSeen ? '/login' : '/onboarding');
  } else if (!session.kycVerified) {
    context.go('/kyc');
  } else {
    context.go('/home');
  }
});
```

---

### Bug 4 — CRITICAL: Logout is a no-op in both apps ❌

**Symptom:** Tapping Logout in either drawer does nothing.

**Root cause:** Both drawer Logout `ListTile`s have `onTap: () {}`.

**Fix — rider `rider_home_screen.dart` drawer Logout tile:**
```dart
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
```

**Fix — driver `driver_home_screen.dart` drawer Logout tile:** Identical code, replacing `rider` package names with `driver` package names.

**Also fix:** The drawer Logout tile in both apps is inside a `StatefulWidget` — change both home screens to `ConsumerStatefulWidget` (rider home already is; driver home already is). The `ref.read(authProvider.notifier).logout()` call works as-is.

---

### Bug 5 — Onboarding "seen" flag never persists ❌

**Symptom:** Onboarding shows every cold start because `Prefs.onboardingSeen` is never set to `true`.

**Root cause:** Both onboarding screens navigate to login on the last slide but never call `Prefs.onboardingSeen = true`.

**Fix — both `*_onboarding_screen.dart`:** In the "last page" branch of the Next/Get Started button:
```dart
if (_currentPage == _onboardingData.length - 1) {
  Prefs.onboardingSeen = true;     // ADD THIS LINE
  context.go('/login');            // replace Navigator.pushReplacement
} else {
  _pageController.nextPage(...);
}
```

Also replace the final `Navigator.pushReplacement(MaterialPageRoute(...))` with `context.go('/login')` to stay in the go_router world.

---

### Bug 6 — KYC screens import unused packages and don't navigate after submit ❌

**Symptom — rider eKYC:** `image_picker` is imported but never called. Tiles are tap-to-toggle. After submit button → 2 s delay → `completeKyc()` → stuck on KYC screen (Bug 1 router issue means no redirect fires).

**Fix — rider `rider_ekyc_screen.dart`:**
1. Add explicit navigation after `completeKyc()`:
```dart
ref.read(authProvider.notifier).completeKyc();
if (mounted) context.go('/home');
```
2. Remove the dead import of `rider_home_screen.dart` (line 6 — unused).
3. Optionally wire `image_picker` (even just gallery pick so a thumbnail shows) — see §Camera below.

**Fix — driver `driver_ekyc_screen.dart`:** Same — add `context.go('/home')` after `completeKyc()`. Remove dead import of `driver_home_screen.dart`.

---

### Bug 7 — cairo_pois.json only has 5 entries ⚠️

**Symptom:** The search sheet opens but searching for anything beyond the 5 POIs (Cairo University, Mall of Arabia, Smart Village, Tahrir Square, Airport) returns nothing. Demo feels empty.

**Fix:** Expand `assets/data/cairo_pois.json` in both apps to 40+ POIs covering all major areas a Cairo demo would use:
```json
[
  {"id":"p1","name":"Tahrir Square","lat":30.0444,"lng":31.2357,"type":"landmark"},
  {"id":"p2","name":"Cairo International Airport","lat":30.1219,"lng":31.4056,"type":"airport"},
  {"id":"p3","name":"Mall of Egypt","lat":29.9737,"lng":31.0089,"type":"mall"},
  {"id":"p4","name":"Cairo Festival City Mall","lat":30.0282,"lng":31.4019,"type":"mall"},
  {"id":"p5","name":"Mall of Arabia","lat":30.0636,"lng":30.9839,"type":"mall"},
  {"id":"p6","name":"City Stars Mall","lat":30.0731,"lng":31.3408,"type":"mall"},
  {"id":"p7","name":"Cairo University","lat":30.0276,"lng":31.2101,"type":"university"},
  {"id":"p8","name":"American University in Cairo","lat":30.0216,"lng":31.4998,"type":"university"},
  {"id":"p9","name":"Smart Village","lat":30.0765,"lng":30.9163,"type":"office"},
  {"id":"p10","name":"Maadi","lat":29.9602,"lng":31.2569,"type":"district"},
  {"id":"p11","name":"Zamalek","lat":30.0626,"lng":31.2197,"type":"district"},
  {"id":"p12","name":"Heliopolis","lat":30.0875,"lng":31.3222,"type":"district"},
  {"id":"p13","name":"New Cairo","lat":30.0099,"lng":31.4800,"type":"district"},
  {"id":"p14","name":"6th of October City","lat":29.9352,"lng":30.9231,"type":"district"},
  {"id":"p15","name":"Sheikh Zayed City","lat":30.0629,"lng":30.9496,"type":"district"},
  {"id":"p16","name":"Nasr City","lat":30.0669,"lng":31.3419,"type":"district"},
  {"id":"p17","name":"Mohandessin","lat":30.0574,"lng":31.2006,"type":"district"},
  {"id":"p18","name":"Downtown Cairo","lat":30.0477,"lng":31.2366,"type":"landmark"},
  {"id":"p19","name":"Khan el-Khalili","lat":30.0478,"lng":31.2614,"type":"landmark"},
  {"id":"p20","name":"The Cairo Tower","lat":30.0459,"lng":31.2243,"type":"landmark"},
  {"id":"p21","name":"Giza Pyramids","lat":29.9773,"lng":31.1325,"type":"landmark"},
  {"id":"p22","name":"Egyptian Museum","lat":30.0478,"lng":31.2336,"type":"landmark"},
  {"id":"p23","name":"Ramses Station","lat":30.0626,"lng":31.2469,"type":"transport"},
  {"id":"p24","name":"Cairo Metro — Tahrir","lat":30.0431,"lng":31.2353,"type":"transport"},
  {"id":"p25","name":"Al-Azhar Park","lat":30.0417,"lng":31.2672,"type":"park"},
  {"id":"p26","name":"Hyde Park","lat":30.0141,"lng":31.4581,"type":"park"},
  {"id":"p27","name":"Qasr El Aini Hospital","lat":30.0341,"lng":31.2272,"type":"hospital"},
  {"id":"p28","name":"As-Salam International Hospital","lat":30.0208,"lng":31.3206,"type":"hospital"},
  {"id":"p29","name":"Kids Castle School","lat":30.0302,"lng":31.4563,"type":"school"},
  {"id":"p30","name":"British International School Cairo","lat":29.9832,"lng":31.3631,"type":"school"},
  {"id":"p31","name":"Four Seasons Hotel Cairo","lat":30.0463,"lng":31.2263,"type":"hotel"},
  {"id":"p32","name":"Kempinski Nile Hotel","lat":30.0440,"lng":31.2262,"type":"hotel"},
  {"id":"p33","name":"Fairmont Nile City","lat":30.0622,"lng":31.2294,"type":"hotel"},
  {"id":"p34","name":"Maadi Degla Club","lat":29.9579,"lng":31.2559,"type":"club"},
  {"id":"p35","name":"Gezira Sporting Club","lat":30.0614,"lng":31.2214,"type":"club"},
  {"id":"p36","name":"Al Rehab City","lat":30.0600,"lng":31.4900,"type":"district"},
  {"id":"p37","name":"Katameya Dunes","lat":29.9602,"lng":31.4659,"type":"district"},
  {"id":"p38","name":"Sodic West","lat":30.0788,"lng":30.8631,"type":"district"},
  {"id":"p39","name":"Palm Hills October","lat":29.9601,"lng":30.8741,"type":"district"},
  {"id":"p40","name":"Fifth Settlement","lat":30.0000,"lng":31.4700,"type":"district"}
]
```
This file should be identical in both `shedrive_rider/assets/data/` and `shedrive_driver/assets/data/`.

---

### Bug 8 — Route polyline is two points (a straight ruler across Cairo) ⚠️

**Symptom:** The route line drawn between pickup and destination ignores all roads.

**Fix — `core/map/map_service.dart` (both apps):** Replace the 2-point stub with a waypoint interpolation that looks like a real route:
```dart
List<LatLng> getRoute(LatLng start, LatLng end) {
  // Generates a curved multi-segment path that follows a plausible road pattern.
  // Not accurate to real roads but looks believable on a city-scale map.
  final rand = math.Random(start.hashCode ^ end.hashCode);
  final points = <LatLng>[start];
  const segments = 8;
  for (int i = 1; i < segments; i++) {
    final t = i / segments;
    final lat = start.latitude + (end.latitude - start.latitude) * t
        + (rand.nextDouble() - 0.5) * 0.008;
    final lng = start.longitude + (end.longitude - start.longitude) * t
        + (rand.nextDouble() - 0.5) * 0.008;
    points.add(LatLng(lat, lng));
  }
  points.add(end);
  return points;
}
```
Add `import 'dart:math' as math;` at the top. The random seed is derived from the start/end points so the same trip always produces the same route shape.

---

### Bug 9 — No trip progression after the rider–driver handshake ❌

**Symptom:** Rider hears "Captain is on the way!" but the driver card just sits there — ETA never changes, driver marker doesn't move, no OTP, no "trip started", no trip-complete screen. Driver taps "Arrived / Finish" → resets home screen to idle.

This is the biggest UX gap for the demo cycle. The state machine works for `initial → matching → enRoute` but nothing after that is built.

**What needs to be added (in order):**

**A. Driver — multi-stage active trip (in `driver_home_screen.dart`):**

Change `_hasActiveTrip` to a `_driverTripStage` enum:
```dart
enum DriverTripStage { idle, enRouteToPickup, atPickup, inTrip }
```

Add the following stage transitions with explicit buttons:
- `enRouteToPickup` → bottom card: rider name/rating, "I've Arrived" button → tapping broadcasts `{type: driver_arrived}` and advances to `atPickup`
- `atPickup` → bottom card: "Enter OTP from Rider" — a 4-digit input. Correct OTP is `5678` (hardcoded, rider shows it) → tapping "Start Trip" broadcasts `{type: trip_started}` and advances to `inTrip`
- `inTrip` → bottom card: fare ticker (ticks up by 0.25 EGP/s via a Timer), "End Trip" button → broadcasts `{type: trip_completed, fare: X}` → resets to idle and shows a brief rating dialog

**B. Rider — react to driver stage events (in `rider_home_screen.dart`):**

The `ref.listen(localBusProvider, ...)` block already handles `ride_accepted`. Extend it:
```dart
case 'driver_arrived':
  // Show "Your captain has arrived!" banner
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Your captain has arrived!'), backgroundColor: Colors.green),
  );
  // Show the pickup OTP to the rider so she can read it to the driver
  showDialog(context: context, builder: (_) => AlertDialog(
    title: const Text('Show this to your captain'),
    content: const Text('OTP: 5678', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 8)),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
  ));
  break;
case 'trip_started':
  setState(() => _currentState = RiderState.inTrip);
  break;
case 'trip_completed':
  setState(() => _currentState = RiderState.rating);
  break;
```

Add `inTrip` and `rating` to `RiderState` enum. `inTrip` shows a "Trip in progress" card. `rating` shows a 5-star rating widget — on submit, broadcasts `{type: rider_rated, stars: N}` and resets to `initial`.

---

### Bug 10 — Driver active trip map has no route or marker ⚠️

**Symptom:** When the driver has an active trip, the map shows the same plain Cairo view with no route and no markers.

**Fix:** When transitioning to `enRouteToPickup`, store the pickup and destination `LatLng` from the request event, compute the route via `mapServiceProvider.getRoute()`, and add a `MarkerLayer` and `PolylineLayer` to the driver's `FlutterMap` that render conditionally on `_driverTripStage != DriverTripStage.idle`. Same for the `inTrip` stage — swap the polyline for the pickup→destination route.

---

## Part 3 — How to Run the Demo Right Now

### Prerequisites
```
Flutter SDK installed and on PATH
Both apps have had `flutter pub get` run inside their directories
An Android emulator or physical device connected
```

### Step 1 — Run the rider app
```bash
cd E:\SheDrive\shedrive_rider
flutter pub get
flutter run
```

### Step 2 — Run the driver app (in a separate terminal)
```bash
cd E:\SheDrive\shedrive_driver
flutter pub get
flutter run
```

> If you only have one device/emulator: run the rider app, then use VS Code's device switcher or `flutter run -d <device-id>` to run the driver app on a second emulator instance. Both can run on the same machine — they communicate over loopback `127.0.0.1:8080`.

---

### Current demo walkthrough (what you can do TODAY, before fixes)

#### Rider App — what works now
1. Launch → splash (3 s) → login screen.
2. Tap **"Continue as Guest (Demo)"** → lands directly on home. *(The OTP flow is broken — use guest mode for now.)*
3. Tap **"Where to, Sister?"** → search sheet opens → type "Mall" or "Tahrir" → 5 results appear → tap one.
4. Destination selected → route line appears on map (straight line) → "Confirm Ride" card slides in.
5. Tap **"Confirm Ride"** → transitions to matching (spinner).
6. ⚠️ Spinner will wait forever unless the driver accepts — bridge is broken.
7. Wrench FAB (bottom-right) → Demo Tools → "Reset All Demo Data" → returns to login.

#### Driver App — what works now
1. Launch → splash (3 s) → login screen.
2. *(No "Continue as Guest" exists on driver)* — type any 10-digit number → tap Send OTP → type **1234** or tap Auto-fill → ⚠️ stuck on OTP (navigation broken). **Workaround:** use the DemoHud to reset, or pre-clear the app data so onboarding runs and then use the login form noting that after entering 1234 nothing visibly happens but you could try going back and forward. **Easiest workaround until Bug 1 is fixed: temporarily change the driver OTP screen's `_verifyOtp` to call `context.go('/home')` after `authProvider.login()`.**
3. Once on home: tap the **GO ONLINE** circle → turns red / "GO OFFLINE" / persists.
4. Tap **"Simulate Incoming Request (Demo)"** → incoming request sheet appears with Zamalek → Maadi, £65.00.
5. Tap **Accept** → "En Route to Pickup" card appears, SOS button appears on map.
6. Tap **"Arrived / Finish"** → resets to idle home.
7. Wrench FAB → Demo Tools → Reset.

#### Cross-app cycle — NOT working yet (bridge is down)
- The rider's Confirm Ride broadcasts `ride_request` but the driver never sees it.
- The driver's Accept broadcasts `ride_accepted` but the rider never sees it.
- The "Simulate Incoming Request" on the driver bypasses the bridge entirely and works in isolation.

---

### After applying all fixes — demo walkthrough (target state)

**Device A = Rider, Device B = Driver (or two emulators)**

1. Launch both apps.
2. **Rider:** Guest mode → Home.
3. **Driver:** Login → OTP `1234` → KYC (tap all tiles) → Submit → Home.
4. **Driver:** Tap **GO ONLINE**.
5. **Rider:** "Where to" → search "Maadi" → tap → Confirm Ride → tap **"Confirm Ride"**.
6. **Driver:** Incoming request sheet pops automatically within ~1 s. Accept.
7. **Rider:** Snackbar "Captain is on the way!" + driver card shows.
8. **Driver:** Card shows "En Route to Pickup" → tap **"I've Arrived"**.
9. **Rider:** "Captain has arrived!" snackbar + OTP dialog shows **5678**.
10. **Driver:** Enter `5678` → tap **Start Trip**.
11. **Rider:** Card changes to "Trip in progress".
12. **Driver:** Fare ticker ticking up → tap **"End Trip"**.
13. **Rider:** Rating screen — tap stars → Submit.
14. **Driver:** Rate rider dialog → submit → back to idle home.
15. Either app: Drawer → **Logout** → confirmation dialog → login screen. Back button exits the app.

---

## Part 4 — Priority Fix Order

Apply fixes in this order. Each one is independently valuable and doesn't block the others.

| Priority | Fix | File(s) | Time estimate |
|---|---|---|---|
| 1 | Bridge server-side (Bug 2) | `core/bridge/local_bus.dart` × 2 | 30 min |
| 2 | Splash smart routing (Bug 3) | `splash_screen.dart` × 2 | 10 min |
| 3 | OTP explicit navigation (Bug 1 — OTP side) | `otp_screen.dart` × 2 | 5 min |
| 4 | KYC explicit navigation (Bug 1 — KYC side) | `*_ekyc_screen.dart` × 2 | 5 min |
| 5 | Logout wired (Bug 4) | both home screen drawer sections | 15 min |
| 6 | Onboarding seen flag (Bug 5) | `*_onboarding_screen.dart` × 2 | 5 min |
| 7 | Expand cairo_pois.json (Bug 7) | `assets/data/cairo_pois.json` × 2 | 5 min |
| 8 | Route waypoints (Bug 8) | `core/map/map_service.dart` × 2 | 10 min |
| 9 | Driver multi-stage trip (Bug 9A) | `driver_home_screen.dart` | 60 min |
| 10 | Rider trip events + OTP + rating (Bug 9B) | `rider_home_screen.dart` | 60 min |
| 11 | Driver active trip map route+marker (Bug 10) | `driver_home_screen.dart` | 30 min |
| 12 | Remove unused firebase_core + dio | `pubspec.yaml` × 2 | 5 min |

**Total to a working full cycle: ~4 hours of focused implementation.**
Items 1–8 (the non-trip-flow fixes) take under 90 minutes and alone get you to a state where auth + logout + search all work correctly. Items 9–11 complete the actual ride cycle.
