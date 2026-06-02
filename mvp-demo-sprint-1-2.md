# SheDrive — Demo MVP: Sprint 1 & Sprint 2

> **Purpose:** Define the minimum vertical slice that can be demonstrated end-to-end at the close of Sprint 2.
> This is a demo target, not a release candidate. No live payment processing, no live OTP gateway, no production backend required.

---

## Demo Scenario

> A female rider opens the SheDrive app for the first time, logs in, verifies her identity, books a ride, is matched with a driver, takes the trip, uses SOS, completes the ride, and rates the driver.
> The same demo switches to the driver app to show the other side of the handshake.
> An admin logs into the back-office portal and can see the trip appear live.

This single end-to-end story demonstrates SheDrive's three safety pillars — identity-verified riders, live SOS, and a fully supervised trip — without requiring a live third-party infrastructure.

---

## Demo Compromises (Accepted)

| Area | Demo Approach |
|------|---------------|
| OTP | Fixed demo code (`1234`) — no SMS gateway needed |
| Identity verification | Documents submitted and instantly auto-approved in demo mode |
| Driver matching | Auto-assigns a seeded demo driver after 3.5 s |
| Map / location | Mapbox with hardcoded Cairo demo coordinates; no real GPS required |
| Payments | Skipped — trip ends with cash-assumed fare |
| Push notifications | Replaced by polling or in-app state transitions |
| Admin portal | Read-only views, no destructive actions in demo build |

---

## Out of Scope for This Demo

- Driver onboarding and document submission
- Wallet top-up and payment processing
- Pricing and zone configuration
- Earnings history
- Real-time notifications infrastructure
- Admin audit log
- Reports and exports
- Trusted contacts management
- Account deactivation / suspension flows
- Localization completeness (Arabic is present but content gaps are acceptable)

---

## Sprint 1 — Foundation, Auth, Home Screens

**Sprint goal:** Every persona can log in and land on their home screen. The rider can request a ride. The driver is live and available.

---

### Feature 1: Design System & Shared Foundation

| Track | Story Title |
|-------|-------------|
| [Admin] | Design tokens, base components, and layout shell are available for all three surfaces |

> Note: Rider design system (tokens, components, shared shell) is already Active in ADO (#1515). This feature covers any gap for the driver and admin surfaces.

---

### Feature 2: Rider Authentication

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider sees splash screen and is prompted to log in |
| [Mobile] | Rider enters phone number to request an OTP |
| [Mobile] | Rider submits OTP and is authenticated |
| [Mobile] | Rider is redirected to identity verification on first login |
| [Mobile] | Rider session persists across app restarts |
| [Mobile] | Rider logs out |
| [API] | Rider requests OTP for a phone number — POST /auth/otp/request |
| [API] | Rider submits OTP and receives a session token — POST /auth/otp/verify |

---

### Feature 3: Rider Identity Verification (First Login Only)

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider photographs the front of her National ID |
| [Mobile] | Rider photographs the back of her National ID |
| [Mobile] | Rider takes a selfie for liveness confirmation |
| [Mobile] | Rider sees verification pending state and is held until approved |
| [API] | Rider uploads identity documents for review — POST /riders/identity |
| [API] | Identity record is auto-approved in demo mode — PATCH /riders/identity/:id/status |

---

### Feature 4: Rider Home & Ride Request

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider sees the map centred on her current location |
| [Mobile] | Rider sets a pickup point on the map |
| [Mobile] | Rider sets a destination |
| [Mobile] | Rider sees a fare estimate before confirming the request |
| [Mobile] | Rider submits a ride request |
| [API] | Rider gets a fare estimate for a route — GET /trips/estimate |
| [API] | Rider creates a trip request — POST /trips |

---

### Feature 5: Driver Authentication

| Track | Story Title |
|-------|-------------|
| [Mobile] | Driver sees splash screen and is prompted to log in |
| [Mobile] | Driver enters phone number to request an OTP |
| [Mobile] | Driver submits OTP and is authenticated |
| [Mobile] | Driver session persists across app restarts |
| [API] | Driver requests OTP — POST /auth/otp/request (shared endpoint, role-scoped) |
| [API] | Driver submits OTP and receives a session token — POST /auth/otp/verify |

---

### Feature 6: Driver Home — Available State

| Track | Story Title |
|-------|-------------|
| [Mobile] | Driver sees home screen in available state with a map |
| [Mobile] | Driver toggles her availability on and off |
| [API] | Driver sets availability status — PATCH /drivers/me/availability |

---

## Sprint 2 — The Trip

**Sprint goal:** A rider can complete a full trip from booking through rating. A driver receives, accepts, and closes the same trip. An admin watches it happen.

---

### Feature 7: Driver Trip Request & Acceptance

| Track | Story Title |
|-------|-------------|
| [Mobile] | Driver receives an incoming trip request with pickup and destination details |
| [Mobile] | Driver accepts the trip request |
| [Mobile] | Driver rejects the trip request and returns to available state |
| [API] | Trip request is dispatched to nearest available driver — internal matching event |
| [API] | Driver accepts a trip — POST /trips/:id/accept |
| [API] | Driver rejects a trip — POST /trips/:id/reject |

---

### Feature 8: Matching Screen — Rider

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider sees the matching screen while a driver is being found |
| [Mobile] | Rider sees the confirmed driver card with name, rating, and ETA |
| [Mobile] | Rider cancels the trip before the driver arrives |
| [API] | Rider polls for matching status — GET /trips/:id |

---

### Feature 9: Active Trip — Rider

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider sees the driver's position updating on the map |
| [Mobile] | Rider sees driver details (name, photo, vehicle, rating) during the trip |
| [Mobile] | Rider calls the driver via a masked number |
| [API] | Rider polls for live trip state and driver location — GET /trips/:id/live |

---

### Feature 10: Active Trip — Driver

| Track | Story Title |
|-------|-------------|
| [Mobile] | Driver sees navigation to the pickup point |
| [Mobile] | Driver confirms the rider has been picked up |
| [Mobile] | Driver ends the trip on arrival at destination |
| [API] | Driver advances trip state — PATCH /trips/:id/state |

---

### Feature 11: SOS & Emergency

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider triggers SOS from the active trip screen |
| [Mobile] | Rider sees the SOS dashboard with emergency call options |
| [Mobile] | Rider places a mock emergency call from the SOS screen |
| [Mobile] | Rider returns to the active trip from the SOS screen |
| [API] | SOS event is recorded against the trip — POST /trips/:id/sos |
| [Admin] | Admin sees an SOS alert appear on the dashboard |

---

### Feature 12: Trip Completion & Rating

| Track | Story Title |
|-------|-------------|
| [Mobile] | Rider sees the fare breakdown after the trip ends |
| [Mobile] | Rider rates the driver with stars and optional tags |
| [Mobile] | Rider skips rating and returns to home |
| [API] | Rider submits a driver rating — POST /trips/:id/rating |
| [API] | Trip is marked as completed — PATCH /trips/:id/state |

---

### Feature 13: Admin Basic Dashboard (Demo View)

| Track | Story Title |
|-------|-------------|
| [Admin] | Admin logs into the back-office portal |
| [Admin] | Admin sees live trip count and active driver count on the dashboard |
| [Admin] | Admin views the trip list with status, rider, driver, and timestamp |
| [Admin] | Admin views a single trip detail with state history |
| [Admin] | Admin views the rider list |
| [Admin] | Admin views the driver list |
| [API] | Dashboard summary is served — GET /admin/dashboard |
| [API] | Trip list is served with filters — GET /admin/trips |
| [API] | Rider list is served — GET /admin/riders |
| [API] | Driver list is served — GET /admin/drivers |

---

## Story Count Summary

| Sprint | Feature | Mobile | API | Admin | Total |
|--------|---------|--------|-----|-------|-------|
| 1 | Design System & Foundation | — | — | 1 | 1 |
| 1 | Rider Authentication | 6 | 2 | — | 8 |
| 1 | Rider Identity Verification | 4 | 2 | — | 6 |
| 1 | Rider Home & Ride Request | 5 | 2 | — | 7 |
| 1 | Driver Authentication | 4 | 2 | — | 6 |
| 1 | Driver Home — Available State | 3 | 1 | — | 4 |
| | **Sprint 1 Total** | **22** | **9** | **1** | **32** |
| 2 | Driver Trip Request & Acceptance | 3 | 3 | — | 6 |
| 2 | Matching Screen — Rider | 3 | 1 | — | 4 |
| 2 | Active Trip — Rider | 3 | 1 | — | 4 |
| 2 | Active Trip — Driver | 3 | 1 | — | 4 |
| 2 | SOS & Emergency | 4 | 1 | 1 | 6 |
| 2 | Trip Completion & Rating | 3 | 2 | — | 5 |
| 2 | Admin Basic Dashboard | — | 4 | 6 | 10 |
| | **Sprint 2 Total** | **19** | **13** | **7** | **39** |
| | **Grand Total** | **41** | **22** | **8** | **71** |

---

## Team Split

| Team | Sprint 1 Stories | Sprint 2 Stories |
|------|-----------------|-----------------|
| Mobile | 22 | 19 |
| Web / Main (API + Admin) | 10 | 20 |

Sprint 1 is heavier on Mobile because the rider and driver authentication and home screens are the foundation everything else depends on. Sprint 2 balances out as the API and admin views catch up to support the trip lifecycle.

---

## Recommended Next Step

Run each feature through the **SheDrive Story Writer** agent to produce full acceptance criteria, validation tables, and Azure DevOps work items before sprint planning begins.
