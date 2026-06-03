# SheDrive Flutter Apps — Demo Gap Analysis & TODO

**Scope:** [`shedrive_rider/`](shedrive_rider/) and [`shedrive_driver/`](shedrive_driver/) Flutter apps.
**Mode: FRONTEND-ONLY DEMO.** No backend, no Firebase, no real OTP, no real payments. The product must **look right and act right** end-to-end. Where a real backend or another app would normally drive state, we fake it with **timers, scripted scenarios, and "demo helper" buttons / dev overlays**.
**Reviewed against:** project CLAUDE.md (strategic positioning + flow map), the rider/driver flow already prototyped on the web (`shedrive-web/`), and the BRD docs in the repo root.
**Date:** 2026-05-15.

---

## 0. Current State Snapshot

### Rider app — what exists today
| Screen | File | Status |
|---|---|---|
| Splash | [splash_screen.dart](shedrive_rider/lib/features/auth/presentation/screens/splash_screen.dart) | Static 3 s delay, hard-codes next route |
| Onboarding (3 slides) | [rider_onboarding_screen.dart](shedrive_rider/lib/features/auth/presentation/screens/rider_onboarding_screen.dart) | UI only, **strings hard-coded in English**, no skip, no "seen-before" flag |
| Login (phone + OTP send) | [login_screen.dart](shedrive_rider/lib/features/auth/presentation/screens/login_screen.dart) | UI only — accepts any non-empty string, no validation, social buttons decorative |
| OTP | [otp_screen.dart](shedrive_rider/lib/features/auth/presentation/screens/otp_screen.dart) | UI only — accepts any digits, no countdown, resend is a no-op |
| eKYC (ID + selfie) | [rider_ekyc_screen.dart](shedrive_rider/lib/features/auth/presentation/screens/rider_ekyc_screen.dart) | Tap-to-toggle booleans only, no camera/gallery, **strings hard-coded** |
| Home (map + Where-to + Child toggle) | [rider_home_screen.dart](shedrive_rider/lib/features/ride/presentation/screens/rider_home_screen.dart) | Static map, "Where to" not tappable, saved places & menu items are no-ops |

### Driver app — what exists today
| Screen | File | Status |
|---|---|---|
| Splash | [splash_screen.dart](shedrive_driver/lib/features/auth/presentation/screens/splash_screen.dart) | Same as rider, routes to onboarding |
| Onboarding | [driver_onboarding_screen.dart](shedrive_driver/lib/features/auth/presentation/screens/driver_onboarding_screen.dart) | UI only, **strings hard-coded**, no skip |
| Login | [login_screen.dart](shedrive_driver/lib/features/auth/presentation/screens/login_screen.dart) | Identical to rider, no validation |
| OTP | [otp_screen.dart](shedrive_driver/lib/features/auth/presentation/screens/otp_screen.dart) | Identical to rider |
| eKYC (ID + license + Istimara + selfie) | [driver_ekyc_screen.dart](shedrive_driver/lib/features/auth/presentation/screens/driver_ekyc_screen.dart) | Tap-to-toggle only, **strings hard-coded** |
| Home (map + GO ONLINE + earnings card) | [driver_home_screen.dart](shedrive_driver/lib/features/driver/presentation/screens/driver_home_screen.dart) | Static map, toggle is local state only, "View Incoming Requests" is a no-op, drawer items are no-ops |

### Cross-cutting observations
- No routing layer (every screen uses `Navigator.push(MaterialPageRoute(...))` directly — tight coupling).
- No state-management beyond local `setState` (Riverpod is pulled in but unused).
- No data layer (Dio + Firebase pulled in but never used — for a demo we won't need them; can be removed or kept dormant).
- No persistence (`shared_preferences` declared, never used → no resumed sessions, no "seen onboarding" flag).
- No `core/` infrastructure besides theme — no `core/router`, no `core/storage`, no mock services.
- Each app uses `flutter_map` + OpenStreetMap tiles — the web app uses Mapbox. Pick one and document.
- Locales are declared but `locale:` is hard-pinned to `Locale('en')` in both `main.dart` files — Arabic is never actually used in flow, and **most onboarding/eKYC strings bypass i18n entirely** (hard-coded English literals).
- No RTL-aware layout testing. Several screens use `Alignment.topCenter`, `Positioned(left:)`, `EdgeInsets.only(left:)` that won't auto-flip.

---

## 1. Demo Architecture — The Fake-Backend Plan

The demo needs to feel real without a server. The way to do that is a **single shared in-memory simulation layer** that both apps would conceptually agree on, plus per-app **scripted scenarios** and **dev-mode helper buttons** to advance state where the other side would normally drive it.

### 1.1 Mock service layer (`core/mock/`)
- [ ] `core/mock/mock_clock.dart` — a `StreamController<DateTime>` ticking at 1 s; lets us speed up "ETA" or compress trips for demo (1 s = 30 s of trip time, toggleable).
- [ ] `core/mock/mock_data.dart` — hard-coded but realistic fixtures:
    - 6–8 mock drivers (name, photo URL/asset, rating, vehicle make+plate, gender flag, first-aid badge, ETA seconds, camera-on flag).
    - 5–6 mock saved places in Cairo/Giza with realistic LatLngs.
    - 4–5 mock past trips for ride history.
    - Earnings ledger (one entry per simulated completed trip).
    - Promo codes (`SHE50`, `WELCOME`, expired/invalid for negative-path demo).
    - Mock notifications.
- [ ] `core/mock/mock_router_polylines.dart` — a few pre-computed polylines between common Cairo points (Tahrir↔Heliopolis, Maadi↔Zamalek, etc.) loaded from a JSON asset so route lines look real without calling a directions API.
- [ ] `core/mock/mock_trip_engine.dart` — drives an in-progress trip's lat/lng marker along a polyline using `mock_clock`. Exposes `Stream<TripState>`.
- [ ] `core/mock/mock_dispatcher.dart` — given a rider request, picks a mock driver (respecting child/male-opt-in/gender flags), publishes an "incoming request" event the driver app would see.
- [ ] `core/mock/scenarios.dart` — preset demo scripts ("Happy path", "SOS midway", "Driver no-show / cancel", "Male-driver fallback after 90 s", "First-time eKYC rejection then approval"). Selectable from the dev drawer.

### 1.2 Shared simulation between rider and driver apps
Both apps are separate Flutter binaries — they cannot share runtime memory. Three options, in order of demo-quality vs. effort:

- [ ] **Option A — Independent simulators (simplest).** Each app runs its own `mock_dispatcher` and `mock_trip_engine`. Rider's "matching" screen plays a 6 s search animation, then picks from `mock_data.drivers`. Driver's home gets incoming requests from a **demo helper button** ("Simulate incoming ride request"). This is the recommended path for a stage demo where one device is shown at a time.
- [ ] **Option B — File-bridge (medium).** Both apps read/write a tiny JSON file on the device (`/sdcard/shedrive_demo/state.json`) via `path_provider`. Useful only when both apps run side-by-side on **the same device/emulator**.
- [ ] **Option C — Local socket / FCM emulator (heavy).** Overkill for a demo; skip.

Pick **Option A** for v1. Document Option B as a stretch if a side-by-side demo is needed.

### 1.3 Demo helper / dev overlay (the "magic button")
- [ ] Add a single `DemoHud` widget (floating action button or long-press-on-logo) available on **every screen in debug builds**, opening a bottom sheet with:
    - Scenario picker (Happy / SOS / Cancel / Male-fallback / KYC-reject).
    - Speed control (1×, 2×, 5×, 10× clock).
    - **Advance flow** buttons specific to the current screen (see §1.4).
    - "Reset demo data" — clears `shared_preferences` and reloads the splash.
    - "Skip to…" jump-list — go straight to any screen with seeded state.
    - Toggle: `Demo Banner ON/OFF` — a thin pink banner at the top reading "DEMO MODE" so reviewers know what they're looking at.
- [ ] Gate the HUD behind `kDebugMode || const bool.fromEnvironment('DEMO_HUD')` so it can be enabled in release builds for stakeholder demos.

### 1.4 Per-screen "advance state" helpers (these replace a backend)
| Screen | Helper button | What it fakes |
|---|---|---|
| Rider OTP | "Fill 1234" | Auto-fills the correct OTP |
| Rider eKYC | "Auto-approve" / "Auto-reject" | Skips camera, simulates verification result |
| Rider Home | "Pick random destination" | Seeds destination + opens confirm |
| Rider Confirm | "Confirm & match in 6 s" | Default path; helper is the existing CTA |
| Rider Matching | "Force male-driver fallback" / "Force no-driver" | Switches the scenario mid-search |
| Rider Active Trip | "Skip to 50% / arrived" | Jumps the trip engine forward |
| Rider Active Trip | "Fire SOS" | Triggers emergency screen |
| Rider Trip Complete | (n/a) | Already user-driven |
| Driver Splash | "Skip onboarding" | Seeds `onboarding_seen` |
| Driver eKYC | "Auto-approve all docs" | Bypasses camera per tile |
| Driver Home | **"Simulate incoming ride request"** | **The critical one** — pops the incoming-request sheet using mock rider data. Without this the driver has nothing to do |
| Driver Home | "Auto-accept next request" | Demos the happy-path acceptance |
| Driver Home | "Simulate rider SOS during trip" | Drives the driver-side SOS banner |
| Driver Active Trip | "Skip to arrived" | Jumps the trip engine forward |
| Driver Trip Complete | "Add tip" | Demos the tip notification |
| Both apps | "Toggle language AR/EN" | Quick locale switch |
| Both apps | "Toggle network down" | Demos offline / error states without real network |

### 1.5 Persistence (still needed even without backend)
- [ ] Wrap `shared_preferences` in `core/storage/prefs.dart`. Keys mirror the web app:
    - `shedrive.session` — JSON `{role, phone, loginAt}`
    - `shedrive.lang` — `'ar'` / `'en'`
    - `shedrive.onboardingSeen` — `'1'`
    - `shedrive.savedPlaces` — JSON array
    - `shedrive.rideHistory` — JSON array of completed mock trips (append on each demo trip)
    - `shedrive.driverOnline` — driver app's online status, restored after restart
    - `shedrive.demoScenario` — current scenario id
- [ ] Restoring state on cold-start is half the perception of "this is a real product".

### 1.6 Routing
- [ ] Introduce **go_router** with named routes; auth-gate redirect (splash → check prefs → onboarding / login / home / eKYC).
- [ ] Define route constants in `core/router/routes.dart`.

### 1.7 State management (Riverpod is in pubspec — use it)
- [ ] `auth_provider` — reads/writes session prefs.
- [ ] `locale_provider` — controls + persists locale.
- [ ] `ride_request_provider`, `active_trip_provider` (rider).
- [ ] `driver_status_provider` (online/offline), `incoming_request_provider`, `earnings_provider` (driver).
- [ ] `demo_provider` — current scenario, speed, banner visibility.

### 1.8 Theming
- [ ] Move repeated `Color(0xFFFFF5F8)` / `Color(0xFFF9EAF2)` literals into `AppTheme`.
- [ ] Add a full design token set mirroring `shared/styles/tokens.css` (spacing, radii, typography, shadows, success/danger).
- [ ] Configure a brand font with Arabic glyph coverage (Cairo, Tajawal, IBM Plex Sans Arabic). `pubspec.yaml` `fonts:` section is currently commented out.

### 1.9 i18n (CRITICAL — currently ~70% of UI bypasses it)
- [ ] **Rider** ARB additions: all 3 onboarding slides, eKYC ("Secure Your Account", "National ID", "Take a Selfie", "Submit & Continue", front/back, must-match), home ("Where to, Sister?", "Home", "Work", "Child Accompanied", "Extra safety for kids"), drawer ("Ride History", "Payment Methods", "Promotions", "Settings", "Support", "Logout", "Sister Passenger").
- [ ] **Driver** ARB additions: onboarding slides, eKYC ("Captain Verification", "Upload Documents", per-doc titles + subtitles, "Submit Documents"), home ("Today's Overview", "Earnings", "Acceptance", "View Incoming Requests", "ONLINE/OFFLINE", "GO ONLINE/OFFLINE"), drawer ("Dashboard", "Earnings", "Vehicle Info", "Documents", "Settings", "Support", "Logout", "Captain Sarah").
- [ ] Driver l10n is currently identical to rider — diverge persona-specific keys (Captain vs Sister).
- [ ] Remove `locale: const Locale('en')` from both `main.dart` files; respect device locale + the locale_provider override.
- [ ] Add a language toggle in both drawers (web app has one in the top bar).
- [ ] Force RTL when `locale.languageCode == 'ar'` via `MaterialApp.builder` wrapping with `Directionality`.
- [ ] Audit `Positioned`/`EdgeInsets` and replace `.left`/`.right` with `.start`/`.end` (`EdgeInsetsDirectional`).

### 1.10 Permissions & device features (still relevant for "feels real")
- [ ] `permission_handler` — camera (eKYC), location (map centering), notifications (incoming request).
- [ ] `geolocator` — center the map on the user instead of hard-coded Cairo.
- [ ] `image_picker` — eKYC can save the captured photo locally and show a real thumbnail. We don't upload it anywhere; demo realism only.
- [ ] `url_launcher` — SOS tile-to-dial 122; "call driver" → opens dialer prefilled with a fake number.
- [ ] `flutter_local_notifications` — fire a real OS notification when the driver-side "Simulate incoming request" helper is tapped (more demo-real than an in-app sheet alone).
- [ ] iOS `Info.plist` / Android `AndroidManifest.xml`: camera, location-when-in-use, notifications.

### 1.11 Cleanup (now that we know it's demo-only)
- [ ] Decide: keep Dio + Firebase in `pubspec.yaml` as "scaffolding for later" or remove them. Recommend **remove for now** to keep build times and surprises down; document the removal in the README.
- [ ] Remove `firebase_core: ^4.9.0` from both pubspecs if not used. (It's currently never initialized — no `Firebase.initializeApp()` exists anywhere, so removal is safe.)

### 1.12 Testing
- [ ] Widget tests per primary screen (smoke + happy path).
- [ ] Golden tests for LTR + RTL of every primary screen.
- [ ] A "scenario walkthrough" integration test that exercises Happy Path end-to-end via the DemoHud (great for recording demo videos).

### 1.13 CI / hygiene
- [ ] Tighten `analysis_options.yaml` beyond default flutter_lints.
- [ ] Add `.gitignore` entries; remove `build/` from version control if present.

---

## 2. Rider App — Per-Screen TODO

### 2.1 Splash ([rider/splash_screen.dart](shedrive_rider/lib/features/auth/presentation/screens/splash_screen.dart))
- [ ] Replace `Future.delayed(3s)` with `await` on prefs bootstrap + locale init.
- [ ] Branch: first-run → onboarding; returning + no session → login; returning + session + verified → home; returning + session + unverified → eKYC.
- [ ] Replace the `errorBuilder` placeholder with a real SheDrive PNG from `/files` (logos are PDFs at repo root — export PNGs to `assets/images/`).

### 2.2 Rider Onboarding
- [ ] Localize all 3 slides (currently English-only literals in `_onboardingData`).
- [ ] "Skip" button on slides 1–2.
- [ ] Persist `onboardingSeen=true` on completion.
- [ ] Replace generic Material icons with branded illustrations.
- [ ] Add an explicit slide highlighting **the 3 safety pillars** (live cabin cameras / SOS to Ministry / first-aid drivers) — currently nowhere in the app.

### 2.3 Rider Login
- [ ] Validate phone format (Egyptian: starts 1xx, 10 digits after +20). Disable Send-OTP until valid.
- [ ] Country picker chevron is decorative — make it open a country list **or** remove the chevron.
- [ ] "OR CONTINUE WITH" + social buttons are non-functional. For demo, either remove them or make them go straight to a fake "logged in via Google" path — don't leave dead.
- [ ] T&C / Privacy links should open a bundled markdown / asset modal.
- [ ] Demo helper: "Use demo number" pre-fills `100 000 0000`.
- [ ] Loading state on the button + button disabled while "sending".

### 2.4 Rider OTP
- [ ] 60 s countdown before "Resend Code" enables.
- [ ] Auto-submit on 4th digit.
- [ ] Wrong-code path: hard-code `1234` as correct; anything else shows shake + inline error.
- [ ] Backspace-to-previous-field.
- [ ] Demo helper: "Auto-fill 1234".
- [ ] On success, persist session + navigate to home screen.


### 2.6 Rider Home — **biggest gap area**
Currently only a static map + decorative bottom sheet. The web app has a full flow this screen is missing:

- [ ] **Where-to**: tap the "Where to, Sister?" pill → opens destination-search screen.
- [ ] **Pickup**: `geolocator` for current location; draggable pin; manual override.
- [ ] **Saved places**: "Home" / "Work" persisted via `mock_data` + prefs; add/edit; today they're hard-coded "2.5 km" / "8.1 km".
- [ ] **Ride options**: economy / premium / XL.
- [ ] **Fare estimate + ETA** — computed from mock pricing (`base + per-km * distance`) using the mock polyline length.
- [ ] **Payment method selector** — cash / card / wallet (all UI-only; no real charge).
- [ ] **Promo code field** — validate against `mock_data.promoCodes` for realistic accept/reject feedback.
- [ ] **Driver-gender preference** — critical for SheDrive positioning. Per CLAUDE.md the male-driver pool is **opt-in, never default**. Add an explicit toggle here.
- [ ] **Child-accompanied** toggle exists but does nothing — should affect mock dispatcher (only pick drivers with `childFriendly=true`) and fare.
- [ ] **Schedule for later**.
- [ ] **"Request Ride" CTA** — entirely missing today. Without it the rider can't actually book.
- [ ] **Drawer items** — wire each or remove the dead ones.
- [ ] Profile name "Sister Passenger" hard-coded — read from auth provider.
- [ ] Add language toggle.

### 2.7 Missing rider screens (entire flows not implemented)
Compare to the web app's nav map in CLAUDE.md — these don't exist yet in Flutter:

- [ ] **Destination search** — autocomplete fed by `mock_data.savedPlaces` + a small hand-curated POI list (no real Places API needed).
- [ ] **Ride confirmation / quote** — fare breakdown, ETA, vehicle class, child option, male-driver opt-in, payment method, promo, "Confirm Ride".
- [ ] **Matching screen** — searching animation; after `scenario.matchDelaySeconds` (default 6 s) pick a driver from `mock_data` and route to active trip. Cancel returns to home.
- [ ] **Active trip** — live map with the trip engine moving the driver marker along the polyline, driver card (photo, name, rating, plate, ETA), call/message (dialer + SMS deep link), SOS button, share-trip-status (`share_plus`), demo "End trip now" helper.
- [ ] **Emergency / SOS dashboard** — direct line to Ministry of Interior **mock** (button shows "Connecting to Ministry of Interior…" then "Operator ETA 90 s"), in-cabin camera live-view stub (loop a short MP4 from assets), 122 quick-dial via `tel:`, share location with trusted contacts, "I'm safe now" returns to active trip. **Core to safety-first positioning and entirely missing.**
- [ ] **Trip complete / rating** — stars 1–5, tag chips, optional tip, optional written feedback, fare summary, mock receipt. Persists into `rideHistory`.
- [ ] **Receipt / trip detail** — map of route, fare breakdown, "Download receipt" generates a local PDF (or shows a PDF asset).
- [ ] **Ride history** — list from `rideHistory` pref, filterable.
- [ ] **Payment methods** — list with one fake Visa "•••• 4242" and a cash option; "Add card" opens a UI-only form that just adds to the in-memory list.
- [ ] **Promotions** — list from `mock_data.promoCodes`.
- [ ] **Profile / settings** — name, email, photo, language, notifications.
- [ ] **Trusted contacts** — add/remove people (just stored in prefs); "Notify them" in SOS path shows a mock toast.
- [ ] **Support / chat** — FAQ accordion + a fake chat (canned auto-replies).
- [ ] **Notifications inbox**.

---

## 3. Driver App — Per-Screen TODO

### 3.1 Driver Splash
- [ ] Same as rider splash (prefs bootstrap, branch).
- [ ] Add a 4th branch: "documents under review" → route to a pending-review screen for the scripted-rejection scenario.

### 3.2 Driver Onboarding
- [ ] Localize 3 slides (currently English literals).
- [ ] "Skip" option.
- [ ] Persist `onboardingSeen=true`.
- [ ] Add a slide explaining **the 3 safety pillars + first-aid training** as part of becoming a SheDrive captain.
- [ ] If male drivers will be in the supply pool (per CLAUDE.md), a slide on the male-driver opt-in dynamic so they understand they're only matched to opted-in riders.

### 3.3 Driver Login + OTP
- [ ] Same gaps as rider (validation, countdown, paste, error states, loading, demo "Auto-fill 1234").

### 3.4 Driver eKYC
- [ ] Same as rider eKYC + driver-specific docs:
- [ ] National ID front + back (two captures).
- [ ] Driver's license front + back; manual expiry-date entry; "License expired" demo path.
- [ ] Vehicle Registration (Istimara) front + back; manual plate + model + year entry.
- [ ] Selfie with face-oval overlay.
- [ ] **Missing per BRD:**
    - Criminal background certificate (الفيش والتشبيه).
    - Vehicle inspection certificate.
    - Insurance certificate.
    - First-aid training certificate (or in-app completion module — see §5).
    - Vehicle photos: front, back, both sides, interior, plate close-up.
    - Bank account / mobile-wallet details for payouts (UI-only).
    - Emergency contact.
- [ ] On submit: a 2 s spinner → by default approved; demo helper to force rejected / pending-review.
- [ ] "Under review" screen for the pending scenario.

### 3.5 Driver Home — major gaps
Currently a static map, hard-coded earnings (£450), no real online state, drawer is dead.

- [ ] **Online / Offline toggle** — persist via prefs; show a foreground-service-style notification on Android while online (`flutter_local_notifications`) so it feels real.
- [ ] **Driver marker animation** while online: jitter the marker every few seconds so the map feels alive.
- [ ] **Incoming ride request bottom sheet** — never implemented. Triggered by:
    - **Demo helper button "Simulate incoming ride request"** (primary trigger — no rider needed).
    - Optionally a timer when online: every 30–60 s if scenario = Happy, auto-fire a request.
    - Sheet shows pickup, destination, fare estimate, distance to pickup, rider rating, child-accompanied flag, **15 s accept/decline countdown** with a progress ring.
- [ ] **Accept** → routes to "en route to pickup" screen. **Decline** → returns to home and decrements a mock acceptance rate.
- [ ] **Full trip state machine** — en route to pickup → arrived → start trip (OTP from rider, see §3.6) → en route to dropoff → end trip → rate rider.
- [ ] **Earnings "£ 450.00"** — drive from `earnings_provider`; each completed mock trip appends to the ledger so the number actually changes during the demo.
- [ ] **Acceptance rate "98%"** — recomputed from accept/decline history.
- [ ] **"View Incoming Requests" button** is a no-op — either wire to a request-history screen or remove.
- [ ] **Drawer items** — wire or remove.
- [ ] Driver name "Captain Sarah" hard-coded — read from auth.
- [ ] Add language toggle.
- [ ] **SOS button for drivers** — drivers face safety risks too. Add a discrete SOS affordance.

### 3.6 Missing driver screens (entire flows not implemented)
- [ ] **Documents pending review** — shown after eKYC submission in the scripted-pending scenario; tap a demo helper to "approve" and unlock home.
- [ ] **Incoming ride request sheet** — described above.
- [ ] **En route to pickup** — map, rider info, call/message rider (dialer/SMS deep link), "Cancel" with reason chips, "I've arrived" button.
- [ ] **At pickup / verify rider** — rider supplies a 4-digit OTP; demo helper "Auto-fill OTP from rider" reveals the same code the rider app would have shown (for a single-device demo this is a "show OTP" reveal toggle).
- [ ] **Active trip / en route to dropoff** — map (trip engine moves marker), live fare ticker, SOS, "End trip" button, demo helper "Skip to arrived".
- [ ] **Trip complete / cash collection** — fare due, cash-confirmation, rate the rider, tip notification (driven by rider's tip on the other side; in demo, helper "Add tip").
- [ ] **Earnings dashboard** — daily/weekly/monthly chart from the ledger; trip-by-trip list; cash-out balance; payout history.
- [ ] **Cash-out / payout** — UI-only; clicking "Withdraw" zeroes the balance and adds an entry to payout history.
- [ ] **Vehicle info** — model, plate, photos, inspection date.
- [ ] **Documents management** — list of submitted docs with status; re-upload expired; expiry alerts (demo helper: "Expire my license" to demonstrate the alert state).
- [ ] **Driver profile / settings**.
- [ ] **Driver SOS dashboard** — driver-side analog of rider SOS.
- [ ] **First-aid training module** — in-app slides + 5-question quiz + completion certificate. Strategic safety pillar.
- [ ] **In-cabin camera setup / status** — verify the camera (3rd safety pillar) is "operational"; show last-checked timestamp; demo helper "Simulate camera offline" for the alert path.
- [ ] **Ratings & feedback** — rider ratings list; dispute a rating.
- [ ] **Support / chat**.
- [ ] **Notifications inbox**.
- [ ] **Trip history**.
- [ ] **Heat-map / demand zones** (optional but expected — overlay a colored polygon layer over Cairo).
- [ ] **Schedule shift / preferred hours** — the onboarding says "set your own schedule"; today there's no UI.

---

## 4. The "Driver-needs-to-see-an-order" Problem — Solved

This is the demo's central challenge: there is no rider app driving requests to the driver. Solutions, picked together:

### 4.1 Primary: Demo Helper button (Option A)
- [ ] **"Simulate incoming ride request"** floating button on the driver home (debug HUD + visible in the bottom sheet next to "View Incoming Requests" for live demos).
- [ ] Tapping it picks a random `mock_data.riders` + `mock_data.tripScripts` and presents the incoming-request sheet exactly as production would.
- [ ] Configurable per scenario: child-accompanied request, premium request, far-pickup request, low-rating rider, etc.

### 4.2 Secondary: Auto-stream of requests when online
- [ ] When the driver is **online** and scenario = `auto`, fire one incoming request every 30–60 s automatically. This makes hands-off demos / videos easier.
- [ ] Show a small "Auto-requests ON" pill so the presenter knows.

### 4.3 Tertiary: Companion rider device path (if both apps run on the same device or two devices)
- [ ] **File-bridge mode** (§1.2 Option B): rider's "Confirm Ride" writes a request JSON to a known path; driver app's home polls or uses `Watcher` to read it. Same machine only.
- [ ] Document this as a stretch / live-demo-only mode behind a `DEMO_BRIDGE=on` flag.

### 4.4 The reverse problem (rider needs the trip to progress without a real driver)
- [ ] Rider's matching screen uses `mock_dispatcher` to pick a driver after the scenario delay; no driver app needed.
- [ ] Rider's active trip uses `mock_trip_engine` to advance position; demo helper "Skip to arrived" jumps to trip-complete.
- [ ] Rider's SOS path is fully local — the "Ministry of Interior responder" is a scripted 90 s countdown with a mock "operator connected" toast.

### 4.5 Visible "DEMO" signals
- [ ] Optional thin pink banner at the top reading **"DEMO MODE"** (toggleable from the HUD).
- [ ] Long-press the app logo anywhere to open the DemoHud bottom sheet.

---

## 5. Strategic-Positioning Gaps (per CLAUDE.md)

The three safety pillars are **not surfaced anywhere** in either app today. For the demo to land its strategic story, each pillar needs a visible touchpoint:

- [ ] **Live in-vehicle cameras**
    - Rider trip screen: "Camera active" badge + a "View cabin" affordance opening a short looping MP4 from assets.
    - Driver home: camera health card, last ping timestamp, demo helper "Simulate camera offline" for the alert path.
- [ ] **SOS direct line to Ministry of Interior** (aspirational)
    - Rider has no SOS button anywhere today; driver has none either. Build the SOS dashboards in both apps.
    - SOS flow: tap → confirmation modal → "Connecting to Ministry of Interior…" 3 s → "Operator on the line — ETA 90 s" mock state → "I'm safe now" returns to trip.
- [ ] **First-aid trained drivers**
    - Rider onboarding slide + driver card on active trip: "Your captain is first-aid certified" badge.
    - Driver eKYC + in-app first-aid training module + completion certificate stored in prefs.

CLAUDE.md also calls out the **male-driver opt-in** mechanic (the lesson from Fyonka / Pink Taxi):
- [ ] Rider Confirm screen: explicit opt-in toggle, OFF by default, labelled clearly (e.g. "Include male drivers if female wait > 5 min — saves time").
- [ ] Driver onboarding (if male drivers are in the pool): explain they only see opted-in riders.

---

## 6. Suggested Implementation Order

1. **Foundations** (§1.6 router, §1.5 prefs, §1.7 Riverpod providers, §1.9 i18n cleanup, §1.8 theme tokens). Without these, every screen below is rebuilt on sand.
2. **Mock infrastructure** (§1.1 mock layer, §1.3 DemoHud, §1.4 per-screen helpers). This is what makes a frontend-only demo possible.
3. **Auth + KYC realism** (§2.3, 2.4, 2.5 / §3.3, 3.4): validation, countdowns, real image capture with `image_picker`, the "Auto-fill 1234" helpers.
4. **Rider booking core** (§2.6 home + §2.7 destination/confirm/matching/active-trip/complete). This is the product.
5. **Driver dispatch core** (§3.5 home + §3.6 incoming/pickup/active/complete). Driven by §4.1 helper.
6. **Safety pillars** (§5 SOS dashboards, camera badges, first-aid module).
7. **Side flows** (history, promos, support, ratings, earnings dashboard).
8. **Polish** (RTL audit, golden tests, scenario walkthrough integration test for demo recording).

---

## 7. Quick-Wins (each can land in one short PR)

- [ ] Remove hard-pinned `locale: const Locale('en')` and respect device locale.
- [ ] Pull repeated `Color(0xFFFFF5F8)` / `Color(0xFFF9EAF2)` into `AppTheme`.
- [ ] Localize the onboarding strings (move from `_onboardingData` Map literals into ARB files).
- [ ] Add phone-number regex validation on the login screen.
- [ ] Add the **OTP `1234` shortcut** + 60 s countdown + paste support.
- [ ] Replace the dead "social login" row with a single "Continue as guest" or remove the block.
- [ ] Make the drawer Logout actually clear `shared_preferences` + route to login.
- [ ] Make "Where to, Sister?" pill at least open a placeholder destination screen instead of being inert.
- [ ] Make "GO ONLINE" survive an app restart (persist to `shared_preferences`).
- [ ] Add the **DemoHud** scaffold (empty bottom sheet behind a long-press on the logo) so future helpers can be slotted in.
- [ ] Add the **"Simulate incoming ride request"** button on the driver home — the single most important demo helper.
- [ ] Remove unused `firebase_core` from both pubspecs (it's never initialized).
