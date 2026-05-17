# SheDrive Demo — Full Rider↔Driver Cycle Implementation Plan

**Status:** ready to implement
**Scope:** technical demo only. **No backend, no business/strategy work.**
**Apps in scope:** [`shedrive_rider/`](../shedrive_rider/) and [`shedrive_driver/`](../shedrive_driver/)
**Definition of done:** anyone who picks up two phones (or one phone with two app instances) can perform a complete ride — rider books, driver receives, driver drives, rider rates, both apps return to their home screens with updated state — and can also **log out → relogin** with state restored correctly.

---

## 0. Critical-Path Summary (the 8 things that MUST work)

If only the items in this section ship, the demo still feels real. Everything later is enrichment.

1. **Shared state bridge** between rider and driver apps so they observe the same trip lifecycle.
2. **Full auth cycle**: signup → eKYC → home → **logout → forced back to login** → relogin → restored to right screen.
3. **Real map** with live GPS, tappable pickup/destination pin drops, a drawn route polyline, and an animated driver marker that moves along the route.
4. **Trip state machine** both apps obey: `idle → requested → matched → driver_en_route → arrived_at_pickup → in_trip → completed → rated`.
5. **Rider booking flow**: home → "Where to" search → destination selection → fare confirmation → matching → active trip → trip complete → rating → home (with the trip in history).
6. **Driver dispatch flow**: home (offline) → online → incoming request sheet → accept → en-route-to-pickup nav → at-pickup OTP verify → in-trip → end trip → rate rider → home (with earnings updated).
7. **SOS** flow on rider's active trip with a believable scripted response.
8. **Cold-start resume**: kill either app and relaunch — it lands on the right screen with the same trip state.

---

## 1. Cross-App Shared State Bridge — the core demo enabler

The two Flutter apps run as separate binaries. For them to behave like one product, they need a channel. Pick **one** of these and commit:

### 1.1 Recommended: Local-network event bus
Both apps speak to each other directly over the LAN.

- [ ] Add `web_socket_channel` + `shelf` + `shelf_web_socket` to both pubspecs.
- [ ] Create `core/bridge/local_bus.dart` shared logic (copy into both apps):
  - On startup, try to **bind** as the bus host on `ws://0.0.0.0:5557/bus`.
  - If port is busy, **connect** as a client to `ws://<host>:5557/bus` (host discovered via mDNS using `multicast_dns` or a hard-coded "look on localhost first, then 192.168.x.x" sweep for demo simplicity).
  - Expose `Stream<BusEvent> events` and `void publish(BusEvent e)`.
  - All clients receive everything; each app filters by event type.
- [ ] Define `BusEvent` schema:
  ```dart
  enum BusEventType {
    rideRequested, rideAccepted, rideRejected, rideCancelled,
    driverArrived, tripStarted, tripProgress, tripCompleted,
    sosTriggered, sosCleared, riderRated, driverRated,
    presence, // online/offline pings
  }
  class BusEvent { String id; BusEventType type; Map<String,dynamic> payload; int ts; }
  ```
- [ ] Persist the **current trip state** in a small JSON snapshot at `<appDocsDir>/trip_state.json`, refreshed on every event. Used for cold-start resume (§3.4).

**Why this approach:** works on a single device (both apps hit loopback), and across two devices on the same WiFi (one becomes host). No internet, no backend, no Firebase.

### 1.2 Fallback: Single-device file bridge
If §1.1 networking is flaky in the demo venue (locked-down conference WiFi, simulator quirks):

- [ ] On Android, write/read a shared JSON file at `/storage/emulated/0/Documents/shedrive_demo/state.json` (use `path_provider` + `MANAGE_EXTERNAL_STORAGE` permission gated behind a debug flag).
- [ ] On iOS simulator, use a shared **App Group** container.
- [ ] Both apps poll the file every 500 ms; diff against last snapshot; emit a `BusEvent` on change.

Implement §1.1 first. Keep §1.2 stub code behind `--dart-define=BRIDGE=file`.

### 1.3 Last-resort: Solo demo mode
If only one app is available (presenter has only one phone):
- [ ] `--dart-define=BRIDGE=mock` — the bridge fakes the other side using scripted scenarios from the Demo HUD (§9). Rider booking auto-spawns a fake driver; driver "Simulate incoming request" auto-spawns a fake rider.

---

## 2. Project Structure Changes

Apply to both apps. Create the following packages under `lib/`:

```
lib/
  core/
    router/            <- go_router config, route guards
    storage/           <- SharedPreferences + secure wrappers
    auth/              <- AuthProvider, session model
    bridge/            <- LocalBus, BusEvent, TripStateSnapshot
    map/               <- MapService (current loc, geocode, route, markers)
    trip/              <- TripStateMachine, TripModel, transitions
    demo/              <- DemoHud, scenarios, time-warp clock
    theme/             <- (exists)
  features/
    auth/              <- (exists; rewire to provider)
    home/              <- rider home or driver home (renamed)
    ride/              <- rider trip flow
    driver/            <- driver trip flow
    sos/               <- emergency screen (both apps)
    history/           <- ride/earnings history
    settings/          <- profile, language, logout
```

- [ ] Add `go_router`, `riverpod` providers, `flutter_secure_storage`, `geolocator`, `permission_handler`, `flutter_local_notifications`, `url_launcher`, `uuid`, `web_socket_channel`, `shelf`, `shelf_web_socket` to both pubspecs.
- [ ] Drop `firebase_core` and `dio` from pubspecs — unused and pulled in for a backend we're not building.

---

## 3. Auth Full Cycle — including the logout you called out

### 3.1 Session model
- [ ] `core/auth/session.dart`: `Session { String userId; String phone; String role; bool kycVerified; DateTime loggedInAt; }`
- [ ] Persist as JSON in `SharedPreferences` under key `shedrive.session` (matches web app convention).

### 3.2 AuthProvider (Riverpod)
- [ ] `authProvider`: `StateNotifier<Session?>` with `login()`, `logout()`, `completeKyc()`.
- [ ] On `logout()`:
  - Clear `shedrive.session`, but **keep** `shedrive.onboardingSeen` and `shedrive.lang`.
  - Cancel any active trip subscription on the bridge.
  - Emit `BusEvent(presence: offline)`.
  - Call `router.go('/login')` and **flush the back-stack** (`pushReplacement` is not enough — use go_router's `go()` which replaces the entire stack, so the user cannot back-button into the home screen).

### 3.3 Router guards
- [ ] `core/router/app_router.dart` with these routes:
  - `/splash` → bootstrap, decides where to go
  - `/onboarding` → first-run only
  - `/login`, `/otp`, `/kyc`
  - `/home` (the role-appropriate home)
  - `/ride/*` (rider flow) or `/driver/*` (driver flow)
  - `/sos`, `/history`, `/settings`, `/trip-complete`
- [ ] Redirect rules:
  - No session → `/login` (unless on `/onboarding`).
  - Session but `kycVerified=false` → `/kyc`.
  - Session + KYC + an active trip in the bridge snapshot → jump straight to `/ride/active` or `/driver/active`.
  - All other → `/home`.

### 3.4 Cold-start resume
- [ ] Splash reads `shedrive.session` AND `trip_state.json`. The router redirect logic uses both. This is what makes the demo feel real after a force-kill.

### 3.5 OTP & KYC for the demo
- [ ] OTP correct code is hard-coded `1234`. Any other digits → shake + inline error. 60 s countdown for "Resend".
- [ ] KYC: real camera capture via `image_picker` (so the reviewer sees the camera actually open), thumbnails shown after capture, 2 s fake "verifying…" spinner, then approved. Demo HUD can force a rejection state.
- [ ] **Both apps must accept the same demo phone** so the cycle works without coordinating numbers: rider `+20 100 000 0001`, driver `+20 100 000 0002`. Document this on the login screen as helper text in debug mode.

### 3.6 Settings → Logout
- [ ] Add a `/settings` route, reached from drawer.
- [ ] Logout button → confirmation dialog → `authProvider.logout()`.
- [ ] After logout the drawer must close and the user lands on `/login` with no path back to `/home` via the system back button.

---

## 4. Map Enhancements — the big one

Both apps share the same `MapService`. Use **Mapbox** for parity with the web app, or stay on `flutter_map` + OSM if you want zero API keys; pick one and document.

### 4.1 Core map service (`core/map/map_service.dart`)
- [ ] `getCurrentLocation() → Future<LatLng>` using `geolocator` with `permission_handler`. Cache last known location.
- [ ] `watchLocation() → Stream<LatLng>` while a screen subscribes (used during driver online + active trip).
- [ ] `geocodeForward(String query) → Future<List<Place>>` — for the demo, **don't call a real API**; load `assets/cairo_pois.json` (50–80 hand-picked points in Cairo/Giza: Mall of Egypt, Cairo Festival City, Tahrir Square, Heliopolis Korba, Maadi Degla, Zamalek 26 July, Sheikh Zayed, AUC New Cairo, etc.) and fuzzy-match locally.
- [ ] `geocodeReverse(LatLng) → Future<String>` — return the nearest POI from the same asset, or "Cairo, Egypt" as a fallback.
- [ ] `route(LatLng a, LatLng b) → Future<List<LatLng>>` — for the demo, compute a **fake but plausible route** using a great-circle interpolation between A and B, with 3–5 random waypoints offset by ±0.002° to look like real road bends. Return ~40 points. Cache by `(a,b)` hash.
- [ ] `estimateEta(List<LatLng> route, {double kmh = 30}) → Duration` — total polyline distance / speed.
- [ ] `boundsFor(List<LatLng>) → LatLngBounds`.

### 4.2 Map widget capabilities
A reusable `SheMap` widget on top of the underlying map plugin:

- [ ] **Live user dot** with accuracy ring; updates from `watchLocation()`.
- [ ] **Tap to drop pickup pin** (debug long-press alternative) and **tap to drop destination pin** — two-pin mode used on the rider home.
- [ ] **Custom markers**: rider pin (pink dot), pickup pin (green flag), destination pin (purple flag), driver car icon (rotates to face direction of travel).
- [ ] **Polyline rendering** with animated **"draw-in"** effect (reveal points one by one over ~600 ms) when a route appears.
- [ ] **Camera modes**:
  - `free` — user controls pan/zoom.
  - `followUser` — recenters on every location update.
  - `followDriver` — used on the rider's active trip; camera follows the driver marker.
  - `fitBounds` — zooms to fit pickup + destination + driver. Used briefly when a route appears.
- [ ] **Recenter FAB** in the bottom-right that switches back to `followUser` from `free`.
- [ ] **Driver marker animation**: on receiving `tripProgress` events, smoothly tween the marker between positions (use `AnimationController` with `Curves.linear`, 1 s duration matching the tick rate).
- [ ] **Heading rotation**: rotate driver icon by `bearing(prev, current)` so the car always points forward.
- [ ] **Map style toggle** in settings (light / dark / satellite — different tile URLs for OSM, different style URIs for Mapbox).
- [ ] **Compass** + **north-up** button (most plugins ship this; just enable).
- [ ] **Pickup-to-destination line** visible on the rider home as soon as both pins are set, with a small floating "X km · Y min" label at the polyline midpoint.

### 4.3 Map integrations per screen
- [ ] **Rider home**: live user dot + drop-destination-pin behavior + saved-places quick chips + "Where to" search opens a full-screen search.
- [ ] **Rider matching**: zoomed-in on pickup, pulsing radar ring, search animation.
- [ ] **Rider active trip**: `followDriver` camera, animated car marker, dashed line of route remaining vs. solid line of route taken, top sheet with "Driver arriving in 4 min" → "Trip in progress 12 min remaining".
- [ ] **Driver home (offline)**: `followUser`, plain map.
- [ ] **Driver home (online)**: `followUser` + a subtle animated ping circle showing "you are visible".
- [ ] **Driver en-route to pickup**: route polyline from driver's current loc to pickup; driver marker = user.
- [ ] **Driver in-trip**: route polyline to destination; fare ticker top.
- [ ] **Trip complete (both apps)**: static mini-map preview showing the full route taken, with start + end pins.

---

## 5. Trip State Machine — the spine

`core/trip/trip_state.dart`:

```dart
enum TripState {
  idle, requested, matched, driverEnRoute, arrivedAtPickup,
  inTrip, completed, cancelledByRider, cancelledByDriver, sosActive,
}
class Trip {
  String id;
  TripState state;
  RiderRef rider; DriverRef? driver;
  LatLng pickup; LatLng destination;
  List<LatLng> routeToPickup; List<LatLng> routeOfTrip;
  String pickupOtp; // 4-digit
  DateTime requestedAt; DateTime? acceptedAt; DateTime? startedAt; DateTime? completedAt;
  double fareEgp;
  int? riderRating; int? driverRating;
  bool sosFlag;
}
```

- [ ] Transitions only via `TripStateMachine.transition(event)` — invalid transitions throw in debug, log + ignore in release.
- [ ] Every transition emits a `BusEvent` on the bridge AND updates the local `trip_state.json` snapshot.
- [ ] Both apps subscribe to the bridge and apply transitions to their local `Trip` copy. The host's copy is authoritative; clients reconcile if they diverge.

---

## 6. Rider App — Critical-Path Screens

Only the screens needed for the cycle. Other screens (promotions, support chat, payment methods) are explicitly **out of scope** (§11).

### 6.1 Splash → Onboarding → Login → OTP → KYC
- [ ] Already exist as UI; rewire navigation through the router + auth provider.
- [ ] Onboarding: localize all 3 slides via ARB; "Skip" on slides 1–2; persist `onboardingSeen`.
- [ ] Login: phone validation + "demo: +20 100 000 0001" hint in debug.
- [ ] OTP: countdown, paste, auto-submit, `1234` correct.
- [ ] KYC: real camera, two captures for ID (front + back), selfie, 2 s "verifying", success.

### 6.2 Home — rewrite the bottom sheet
- [ ] Drawer: Profile / History / Settings / **Logout**. Wire Logout to `authProvider.logout()`.
- [ ] Map fills the screen; live user dot; recenter FAB.
- [ ] Bottom sheet:
  - "Where to, Sister?" tap → opens **Destination Search** screen (§6.3).
  - Two saved-place chips: Home + Work (from prefs; tappable to set as destination directly).
  - Child-accompanied toggle (functional — passed to the request payload).
  - Male-driver opt-in toggle (functional — affects matching filter).
- [ ] When a destination is set, sheet morphs into a Ride Confirm card (§6.4) instead of pushing a new screen — feels snappier.

### 6.3 Destination Search
- [ ] Full-screen search with `TextField`, debounced; results from `MapService.geocodeForward()`.
- [ ] Recents list at top (from prefs), then suggestions.
- [ ] "Choose on map" button → returns to home in pin-drop mode.

### 6.4 Ride Confirm
- [ ] Card or screen showing: pickup address, destination address, fare estimate, ETA, vehicle class radios (Economy / Premium), payment method (Cash / Card "•••• 4242" — UI only), child + male-opt-in toggles, "Request Ride" CTA.
- [ ] Tapping CTA → publishes `BusEvent(rideRequested, payload: ...)` → transitions local Trip to `requested` → navigates to Matching screen.

### 6.5 Matching
- [ ] Pulsing ring + "Finding a captain near you" text.
- [ ] Subscribed to `rideAccepted` events on the bridge.
- [ ] **Driver side has 25 s** to accept (driver-app countdown). If timer expires, rider sees "Trying nearby drivers…" reshuffle (no real reshuffle — just a UX delay), and if still no accept, "No captains available — try again" with a cancel option.
- [ ] Cancel CTA → publishes `rideCancelled` → returns to home.

### 6.6 Active Trip
- [ ] Top sheet with driver card: photo, name, rating, vehicle make + plate, "Camera active" badge, "First-aid certified" badge, ETA countdown.
- [ ] Map in `followDriver` mode; animated car marker; route polyline.
- [ ] Buttons: Call (opens dialer via `url_launcher` to a fake number — the driver app does the same for rider), Message (opens SMS), Share trip (`share_plus` — copies a "https://shedrive.app/share/<tripId>" string), **SOS** (large red).
- [ ] Listens for `driverArrived`, `tripStarted`, `tripProgress`, `tripCompleted` events — UI reflects each.
- [ ] When trip reaches destination → auto-navigates to Trip Complete.

### 6.7 SOS
- [ ] Full-screen take-over; pulsing red header.
- [ ] Mock "Connecting to emergency line…" 3 s → "Operator on the line — stay calm, share location."
- [ ] Buttons: Call 122 (`tel:122`), Share live location with trusted contacts (UI-only — toast "Shared with 3 contacts"), "I'm safe now" → publishes `sosCleared` → returns to active trip.
- [ ] Trusted Contacts list lives in settings; demo: pre-seeded with 2 fake contacts.

### 6.8 Trip Complete
- [ ] Mini-map of the route taken.
- [ ] Fare summary card.
- [ ] 5-star rating (required to submit) + tag chips ("Polite", "Clean car", "Safe driver", "On time") + optional comment + optional tip (`+10`, `+20`, `+50` EGP).
- [ ] "Submit" → publishes `riderRated` → navigates to home → appends to `shedrive.rideHistory` in prefs.

### 6.9 History (drawer item)
- [ ] List of completed trips from `shedrive.rideHistory`. Tap to view a trip-detail with mini-map.

### 6.10 Settings (drawer item)
- [ ] Profile (name, photo from KYC selfie), language toggle AR/EN, map style (light/dark/satellite), trusted contacts, **Logout**.

---

## 7. Driver App — Critical-Path Screens

### 7.1 Splash → Onboarding → Login → OTP → KYC
- [ ] Same as rider, but KYC includes ID front+back, license front+back, Istimara front+back, selfie, plate-number text field, vehicle model+year text fields.
- [ ] Demo helper: "Auto-approve all" — fills tiles + advances.

### 7.2 Home
- [ ] Drawer: Earnings / History / Settings / **Logout** (wired).
- [ ] Map fills screen; live user dot.
- [ ] Floating ONLINE/OFFLINE button (large pink circle). Online state persisted across restarts.
- [ ] When online: emits `presence: online` every 10 s on the bridge; map shows a subtle pulsing visibility ring.
- [ ] Bottom card: "Today's earnings: <live value from earnings provider>" + "Acceptance: <computed>".
- [ ] Subscribes to `rideRequested` events on the bridge; when one matches the driver's filter (proximity in demo: always-match), shows the Incoming Request sheet (§7.3).

### 7.3 Incoming Request sheet
- [ ] Modal bottom sheet that **cannot be dismissed by swipe** during its 25 s window.
- [ ] Shows rider name + rating, pickup address + distance, destination address, fare estimate, child flag, "Accept" + "Decline" buttons with a circular progress ring counting down.
- [ ] Accept → publishes `rideAccepted` → navigates to En-Route-to-Pickup.
- [ ] Decline → publishes `rideRejected` → returns to home; acceptance rate recomputed.
- [ ] Timeout → same as Decline.

### 7.4 En-Route to Pickup
- [ ] Map with route from driver loc → pickup; turn-by-turn-ish styling.
- [ ] Top sheet: rider name, photo, rating, "ETA 4 min" computed from polyline.
- [ ] Buttons: Call rider, Message rider, "I've arrived" (CTA).
- [ ] "I've arrived" → publishes `driverArrived` → navigates to At-Pickup screen.

### 7.5 At Pickup — OTP verify
- [ ] 4-digit OTP entry; correct code is the trip's `pickupOtp` (the rider sees this code on their active-trip screen — emitted via the `matched` event payload).
- [ ] "Start Trip" → publishes `tripStarted` → navigates to In-Trip.
- [ ] Demo helper: "Reveal OTP" — for single-device demos when both apps aren't both visible.

### 7.6 In-Trip
- [ ] Map with route polyline to destination; driver marker = user (followUser camera).
- [ ] **Tick loop**: every 2 s, advance the driver position along the route by `step = totalRouteLength / (etaSeconds / 2)`. Publish `tripProgress` events so the rider's map updates in sync.
- [ ] Live fare ticker.
- [ ] SOS button.
- [ ] "End Trip" CTA → publishes `tripCompleted` → navigates to Trip Complete.

### 7.7 Trip Complete (Driver)
- [ ] Fare summary (with cash collection note if applicable).
- [ ] Rate the rider (5-star) + comment.
- [ ] "Submit" → publishes `driverRated` → home, earnings appended in prefs.

### 7.8 Earnings (drawer)
- [ ] Today / week / month tabs, simple bar visualization, trip-by-trip list. Sourced from `shedrive.earningsLedger` prefs.

### 7.9 Settings (drawer)
- [ ] Same shape as rider's; **Logout** behaves identically.

---

## 8. Logout Behavior — explicit spec

Common bug source. Spec it once:

- [ ] Logout button → `showDialog` confirmation ("Are you sure?").
- [ ] On confirm:
  1. Cancel all bridge subscriptions.
  2. If a trip is active, publish `rideCancelled` with reason `userLoggedOut` (so the other app's UI also resets).
  3. Clear `shedrive.session`. Keep `shedrive.lang` and `shedrive.onboardingSeen`.
  4. `router.go('/login')` — this **replaces the entire stack**.
  5. The drawer closes (`Navigator.pop(context)` first to dismiss the drawer, then route change).
- [ ] System back button on `/login` should exit the app (not return to `/home`).
- [ ] If the user relogins with the same phone, the router lands on `/home` (KYC was already verified).
- [ ] If the user relogins with a different phone, KYC restarts (`/kyc`).

---

## 9. Demo HUD — the cheat panel

A debug-only overlay accessible by **long-pressing the SheDrive logo** on the app bar (works in any screen).

- [ ] Scenario picker:
  - "Happy path"
  - "Driver declines twice then accepts"
  - "Rider triggers SOS at 30% of trip"
  - "Driver cancels mid-pickup"
  - "Network error on KYC submit"
- [ ] Time-warp: 1× / 2× / 5× / 10× (multiplies the trip tick rate).
- [ ] Force-events: `Emit fake ride request`, `Emit fake accept`, `Skip to arrived`, `Skip to complete`.
- [ ] Reset demo: wipes prefs + trip snapshot + restarts to splash.
- [ ] Bridge inspector: live log of `BusEvent`s on screen with timestamps (priceless for debugging during a demo).
- [ ] Toggle "DEMO MODE" banner across the top.

---

## 10. Implementation Order

Build in this exact order so the demo is usable at every checkpoint:

**Checkpoint 1 — Foundation** (1–2 days)
- [ ] Router + auth provider + session prefs (§2, §3.1–3.3).
- [ ] Cold-start resume (§3.4).
- [ ] **Logout cycle works end-to-end** (§8). Demo-able: launch, log in, log out, can't get back without logging in.

**Checkpoint 2 — Map fundamentals** (2 days)
- [ ] MapService with current location, forward/reverse geocode, route generation (§4.1).
- [ ] SheMap widget with live dot + recenter + pin drop (§4.2).
- [ ] Rider home with new bottom sheet + destination search + saved chips (§6.2, §6.3).
- [ ] Demo-able: open rider app, see your real location, search "Tahrir", drop a pin, see route line drawn.

**Checkpoint 3 — The bridge** (2 days)
- [ ] LocalBus (§1.1) with WebSocket host/client auto-negotiation.
- [ ] BusEvent + trip snapshot persistence.
- [ ] Bridge inspector panel in the Demo HUD.
- [ ] Demo-able: open both apps on one phone, publish a test event from one, see it in the other.

**Checkpoint 4 — Rider booking happy path** (2 days)
- [ ] Ride Confirm card (§6.4) → emits `rideRequested`.
- [ ] Matching screen (§6.5) listening for `rideAccepted`.
- [ ] Driver app: Incoming Request sheet (§7.3) listening for `rideRequested`, accept emits `rideAccepted`.
- [ ] Demo-able: rider books, driver phone buzzes, driver accepts, rider sees driver assigned.

**Checkpoint 5 — Active trip both sides** (3 days)
- [ ] Driver: en-route → at-pickup → in-trip with tick loop (§7.4–7.6).
- [ ] Rider: active trip with animated marker following driver's `tripProgress` events (§6.6, §4.2 animation).
- [ ] OTP at pickup (§7.5).
- [ ] Trip complete on both sides (§6.8, §7.7).
- [ ] Demo-able: full ride from booking to rating, both apps in sync.

**Checkpoint 6 — SOS + history + earnings** (1–2 days)
- [ ] Rider SOS (§6.7).
- [ ] Trip history persists on both sides (§6.9, §7.8).

**Checkpoint 7 — Polish** (1–2 days)
- [ ] i18n cleanup — replace all hard-coded strings with ARB keys.
- [ ] Locale switcher in settings, RTL audit.
- [ ] Demo HUD scenarios + time-warp (§9).
- [ ] Loading states + snackbars + empty states everywhere.

Total ≈ 10–12 working days for a tight solo developer. Cut polish (Checkpoint 7) if pressed.

---

## 11. Out of Scope (do not build during this phase)

Explicitly excluded so the implementer doesn't drift:

- Promotions / promo codes UI.
- Support chat / FAQ.
- Schedule shifts / preferred hours.
- Heat-maps / demand zones.
- Payouts / cash-out flow (just show earnings number).
- First-aid training module (just a badge on the driver card).
- Vehicle photos / inspection certs in driver KYC (ID + license + Istimara + selfie is enough).
- Ratings dispute.
- Notifications inbox screen.
- Real payment provider integrations.
- Backend of any kind (the bridge is local-only).
- Web app changes.
- Tests (unit / widget / golden) — add only smoke tests if time permits.

---

## 12. Acceptance Criteria (the "feels working" checklist)

A reviewer holds two phones. Tester confirms each:

- [ ] On both apps, opening from a fresh install shows onboarding → login.
- [ ] After OTP `1234` and KYC capture, lands on the role-appropriate home.
- [ ] Map shows the tester's actual current location, not Cairo center.
- [ ] Rider taps "Where to" → search works → fares + ETA appear → Request Ride.
- [ ] Driver phone immediately shows an Incoming Request modal with 25 s countdown.
- [ ] On Accept, both apps transition smoothly to their active-trip views within ~1 s.
- [ ] Rider sees the driver's car icon move on the map in real time as the driver's tick loop ticks.
- [ ] Rider taps SOS — full-screen takeover, mocked operator connection, "I'm safe now" returns to trip.
- [ ] Driver taps "End trip" — both apps land on their rate-the-other-party screens.
- [ ] Both apps return to home with the trip in History and the driver's earnings number incremented.
- [ ] Force-kill either app and reopen — it lands on the right screen (logged in / mid-trip / home).
- [ ] Logout from either app → login screen → system back button exits the app.
- [ ] Switch language to Arabic in settings → entire app re-renders RTL with Arabic strings.

If every checkbox in §12 passes, the demo is done.
