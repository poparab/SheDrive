# SheDrive — Sprint 1 & 2 Screen List for Designer

> **Purpose:** Reference for the designer covering every distinct screen that must be drawn across all three surfaces — Rider app, Driver app, and Admin portal — for Sprints 1 and 2.
> Ordered by priority. Existing prototypes noted so the designer can reference or deviate.

---

## What Already Exists in `shedrive-web`

These are frontend prototypes only — no real API connections. The demo scenario runs end-to-end in the browser as a click-through simulation.

### Rider App (`rider/`)

| File | Screen | Status | Notes |
|------|--------|--------|-------|
| `rider/index.html` | Splash + Phone entry + OTP | ✅ Built | Bilingual (AR/EN), full i18n, working demo login |
| `rider/home.html` | Home — map + ride request sheet | ⚠️ Partial | Map works; destination is free-text only — **no autocomplete, no fare estimate** |
| `rider/matching.html` | Matching / searching for driver | ✅ Built | Auto-advances after 3.5 s; cancel navigates back to home |
| `rider/active-trip.html` | Active trip — en route + in-ride | ✅ Built | Has both en-route and in-ride states; live map simulation |
| `rider/emergency.html` | SOS dashboard | ✅ Built | **Out of scope for S1/S2** — do not prioritise |
| `rider/trip-complete.html` | Trip summary + rate driver | ✅ Built | Star rating, tags, skip flow |
| `rider/verify-identity.html` | Rider ID verification | ✅ Built | **Removed from S1/S2 scope** — driver confirms identity manually |

### Driver App (`driver/`)

| File | Screen | Status | Notes |
|------|--------|--------|-------|
| `driver/index.html` | Phone entry + OTP | ✅ Built | Same pattern as rider login |
| `driver/onboarding.html` | Onboarding steps 1–4 + pending review | ✅ Built | 5-step flow: personal info → vehicle details → vehicle photo → docs upload → pending screen; **missing: approved / rejected result screen** |
| `driver/home.html` | Home — map + online/offline toggle | ✅ Built | Toggle pill, earnings chip, location streaming simulation |
| `driver/request.html` | Incoming trip request | ✅ Built | 10-second countdown, accept/reject, trip chip summary |
| `driver/trip.html` | Active trip state machine | ✅ Built | Navigate to pickup → arrived → identity confirm → in ride → end trip states |
| `driver/earnings.html` | Earnings breakdown | ✅ Built | **Out of scope for S1/S2** — do not prioritise |

### Admin Portal (`admin/` or `admin-portal/`)

| Status |
|--------|
| ❌ **Nothing exists.** All admin screens need to be designed and built from scratch. |

### Shared Infrastructure (`shared/`)

| Asset | Status |
|-------|--------|
| Design tokens (`shared/styles/tokens.css`) | ✅ Complete |
| Component library — `sd-page`, `sd-app-header`, `sd-button`, `sd-bottom-sheet`, `sd-driver-card`, `sd-rating-stars`, `sd-toast-host` | ✅ Complete |
| i18n — Arabic + English JSON (`shared/i18n/`) | ✅ Complete |
| Auth, map, storage, drawer utilities | ✅ Complete |
| API client (`shared/scripts/api.js`) | ✅ Wired — awaits real backend |

---

## Screens to Design — Sprint 1 (Priority 1)

### 📱 Rider App — Sprint 1

| # | Screen | Key States / Content | Sprint 1 Stories |
|---|--------|----------------------|------------------|
| **R1** | **Splash / Launch** | Logo animation, brand mark, routes to login or home | — |
| **R2** | **Phone number entry** | Number input field, "Send OTP" CTA; shared by register and login | #1545, #1546 |
| **R3** | **OTP verification** | 4/6-digit code entry, resend timer, error/expired states | #1545, #1546 |
| **R4** | **Rider Home — map + booking sheet** | Full-screen map; bottom sheet with pickup pin + destination field; "Request ride" CTA | #1548, #1550 |
| **R5** | **Address search / autocomplete** | Search input, live suggestion list, recent locations; opens from destination field on R4 | #1549, #1551 |
| **R6** | **Fare estimate panel** | Pickup → destination route chip, estimated fare, confirm / change | #1552 |

> **Designer note:** R4, R5, R6 are one continuous flow from the same home screen. Design as stacked states or a single deep-linked flow on the booking bottom sheet.

---

### 📱 Driver App — Sprint 1

| # | Screen | Key States / Content | Sprint 1 Stories |
|---|--------|----------------------|------------------|
| **D1** | **Phone number entry** | Same pattern as R2 | #1569, #1570 |
| **D2** | **OTP verification** | Same pattern as R3 | #1569, #1570 |
| **D3** | **Onboarding — Step 1: Personal details** | Full name, national ID, profile photo; step indicator | #1572 |
| **D4** | **Onboarding — Step 2: Vehicle details** | Make, model, year, plate, colour | #1573 |
| **D5** | **Onboarding — Step 3: Vehicle photo** | Camera capture + preview / retake | #1574 |
| **D6** | **Onboarding — Step 4: Documents upload** | Driver's licence + vehicle registration upload zones | #1575 |
| **D7** | **Application pending** | "Under review" confirmation; estimated 24–48 h; push notification opt-in | #1576 |
| **D8** | **Application decision** | Two variants: **Approved** (go to home) and **Rejected** (reason text + contact support) | #1577 |
| **D9** | **Driver Home — map + toggle** | Full-screen map; online / offline pill toggle; earnings chip; offline and online states | #1578, #1579, #1580 |

---

### 🖥️ Admin Portal — Sprint 1

| # | Screen | Key States / Content | Sprint 1 Stories |
|---|--------|----------------------|------------------|
| **A1** | **Admin login** | Portal shell, email + password; no OTP | #1656 |
| **A2** | **Pending applications queue** | Sortable list/table of drivers awaiting review; name, submission date, status badge | #1657 |
| **A3** | **Driver application detail** | Full submission view; photo, vehicle, documents; Approve button + Reject-with-reason modal | #1658, #1659, #1660 |

---

## Screens to Design — Sprint 2 (Priority 2)

### 📱 Rider App — Sprint 2

| # | Screen | Key States / Content | Sprint 2 Stories |
|---|--------|----------------------|------------------|
| **R7** | **Trip request confirm** | Final pickup + destination + fare summary; single "Confirm & Request" CTA | #1553 |
| **R8** | **Matching / searching** | "Finding your driver" spinner + safety note; **No-driver error variant** (all drivers busy / retry) | #1554, #1557 |
| **R9** | **Driver confirmed card** | Matched driver name, avatar, rating, vehicle, ETA chip; "Driver is on the way" state | #1555 |
| **R10** | **Active trip — driver en route** | Live driver location on map; driver card with ETA; **Driver arrived** variant (pulsing marker) | #1558, #1559, #1562 |
| **R11** | **Active trip — in ride** | Live location during ride; route progress; driver details panel | #1561, #1562 |
| **R12** | **Trip summary — cash fare** | Trip end confirmation; route, duration, fare to pay in cash | #1564 |
| **R13** | **Rate your driver** | 1–5 stars; tag chips (clean car, friendly, etc.); submit + skip | #1565, #1566 |
| **R14** | **Trip history list** | Scrollable list of past trips; date, destination, fare, status | #1567 |
| **R15** | **Past trip detail** | Single trip: route, fare breakdown, driver card, rating given | #1568 |

---

### 📱 Driver App — Sprint 2

| # | Screen | Key States / Content | Sprint 2 Stories |
|---|--------|----------------------|------------------|
| **D10** | **Incoming trip request** | Trip origin + destination + estimated fare; Accept / Reject; **10-second countdown timer**; Expired variant | #1582, #1583, #1584, #1585 |
| **D11** | **Active trip — navigate to pickup** | Turn-by-turn map; rider name + ETA chip; "I've arrived" CTA | #1586, #1587 |
| **D12** | **Confirm rider identity** | Photo reference + "Confirm identity" prompt; first-trip flag | #1588 |
| **D13** | **Active trip — in ride** | "Rider has boarded" confirm → navigating to destination → "End trip" CTA | #1589, #1590, #1591 |
| **D14** | **Cash fare to collect** | Fare amount in EGP; "Collected — go online" CTA | #1592 |
| **D15** | **Trip history list** | Same pattern as R14 but from driver perspective | #1593 |
| **D16** | **Past trip detail** | Single trip: route, fare, rider rating received | #1594 |

---

### 🖥️ Admin Portal — Sprint 2

| # | Screen | Key States / Content | Sprint 2 Stories |
|---|--------|----------------------|------------------|
| **A4** | **Operations dashboard** | Live summary tiles: active drivers, active riders, trips in progress, completed today; real-time feed | #1669 |
| **A5** | **Trip list** | Paginated table: all trips; status filter, date range filter, search; status badges | #1670 |
| **A6** | **Trip detail** | State history timeline; driver + rider cards; fare + rating (completed variant); map route replay | #1671, #1672 |
| **A7** | **Rider list** | Table with search + filter; name, phone, registration date, trip count, status | #1661 |
| **A8** | **Rider profile** | Profile card + past trips list | #1662 |
| **A9** | **Driver list (all statuses)** | Table with status filter (pending / active / offline / rejected); search | #1665 |
| **A10** | **Driver profile** | Full profile + documents + trip history + current rating | #1666 |

---

## Screen Count Summary

| Surface | Sprint 1 | Sprint 2 | Total |
|---------|:--------:|:--------:|:-----:|
| Rider app | 6 | 9 | **15** |
| Driver app | 9 | 7 | **16** |
| Admin portal | 3 | 7 | **10** |
| **Total** | **18** | **23** | **41** |

---

## Design Notes for Handoff

### Already built — designer can reference or override
The existing prototype at `shedrive-web/` runs on `http://localhost:8000/rider/` via `py -m http.server 8000`. It is a click-through demo only — screens are implemented but not connected to a real backend.

### Screens that are built but need a redesign
| Screen | Gap |
|--------|-----|
| R4 Rider Home | Missing autocomplete panel and fare estimate — needs those states added |
| D8 Application decision | Not in the current prototype at all — needs approved + rejected variants |

### Screens built but out of scope for S1/S2
| Screen | Note |
|--------|------|
| `rider/emergency.html` | SOS — deferred to a later sprint |
| `rider/verify-identity.html` | Rider ID verify — removed from scope; driver confirms manually |
| `driver/earnings.html` | Earnings — deferred to a later sprint |

### Component reuse
Design these once and apply everywhere:
- OTP input (R3, D2)
- Map + pin base (R4, R10, R11, D9, D11, D13)
- Driver card (R9, R10, R11, A6)
- Incoming trip request card (D10)
- Trip history row (R14, D15)
- Status badges: `pending`, `active`, `offline`, `rejected`, `completed`
- Empty state (no trips, no drivers, no results)
- Error / no-driver state

### Push notification templates (not screens, but need copy + visual)
- Driver approved / rejected
- Trip matched to rider
- Driver arrived at pickup
- Trip completed

---

*Last updated: 2026-06-03 · Based on `mvp-demo-sprint-1-2.md`*
