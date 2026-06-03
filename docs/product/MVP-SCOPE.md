# SheDrive — MVP Scope Review

> Based on BRD v1.2 §5.1 (In-Scope) and §5.2 (Out-of-Scope).
> Review and annotate this file, then return it for implementation planning.

---

## Module 1 — Rider App

### ✅ In MVP
- [ ] Phone + OTP registration and login
- [ ] Identity verification (National ID + selfie, one-time before first trip)
- [ ] Map-based pickup + destination selection
- [ ] Fare estimate before booking
- [ ] Child accompaniment declaration (under 12)
- [ ] Payment method selection (Cash / Digital card)
- [ ] Ride request submission
- [ ] Real-time driver tracking on map
- [ ] In-app communication with driver (masked call / chat)
- [ ] Ride cancellation
- [ ] Fare display + payment completion
- [ ] Rating & feedback after trip
- [ ] Trip history
- [ ] Arabic ⇄ English language switch
- [ ] Live trip sharing (shareable link)
- [ ] Trusted contacts management
- [ ] SOS button

### ❌ Not in MVP
- Ride scheduling / recurring bookings
- Ride pooling / shared rides
- Premium / family-plus service tier selection
- In-app wallet top-up and balance usage
- Promo codes, discounts, referral program
- Corporate / institutional account login
- Family account / multi-user management
- Guardian dashboard and parental controls
- Subscription or membership tiers

---

## Module 2 — Driver App

### ✅ In MVP
- [ ] Registration + identity verification
- [ ] Driving license upload + validation
- [ ] Vehicle document submission (driver-owned vehicle)
- [ ] Background check consent flow
- [ ] Onboarding status tracker
- [ ] Online / Offline toggle
- [ ] Working zone selection
- [ ] Ride request handling (accept / decline)
- [ ] Navigation deep-link to external maps (Google Maps / Apple Maps)
- [ ] Trip lifecycle controls (arrived → start trip → end trip)
- [ ] Ride cancellation
- [ ] Cash collection confirmation
- [ ] Digital payment status visibility
- [ ] Earnings dashboard
- [ ] Cash balance ledger (amount owed to platform)
- [ ] Driver rating view
- [ ] In-app communication with rider (masked call / chat)
- [ ] Arabic ⇄ English language switch
- [ ] SOS button

### ❌ Not in MVP
- Automated payouts / in-app bank transfer to driver
- In-app driver wallet
- Scheduled shift management
- Platform-supplied or leased vehicles
- Vehicle fleet management
- Advanced driver performance analytics
- Subscription / incentive tier programs

---

## Module 3 — Admin & Operations Portal

### ✅ In MVP
- [ ] 2FA login
- [ ] Role-Based Access Control (Admin, Operations Supervisor, Customer Support, Finance, Compliance)
- [ ] Live operational dashboard (active rides, online drivers, queue depth)
- [ ] Driver onboarding queue — document review, approve, reject
- [ ] Rider & driver account management (suspend, reactivate, edit)
- [ ] Live ride monitoring (map view + state)
- [ ] Ride detail + history search
- [ ] Cancellation & incident management
- [ ] SOS queue + escalation workflow + SLA tracker
- [ ] Neighborhood / zone management (polygon editor)
- [ ] Pricing rule configuration per zone
- [ ] Cancellation rule configuration
- [ ] Commission configuration
- [ ] Cash reconciliation workflow
- [ ] Manual refund processing
- [ ] Dispute management
- [ ] Audit logs
- [ ] Notification template management (Arabic + English)
- [ ] Static content management (T&Cs, FAQ)
- [ ] English language only (portal UI)

### ❌ Not in MVP
- Arabic language support for the portal UI
- Dispatcher / call-center manual ride booking
- Manual ride creation by admin
- Marketing campaign management tools
- Advanced BI dashboards / custom report builder
- Automated fraud detection controls
- White-label / multi-brand support
- Third-party marketplace integrations beyond core services

---

## Module 4 — Identity & Verification

### ✅ In MVP
- [ ] National ID OCR (Egyptian National ID)
- [ ] ID validity check + duplicate check
- [ ] Liveness detection (selfie capture)
- [ ] Face match (selfie vs ID photo)
- [ ] Age eligibility check (≥ 18)
- [ ] Gender eligibility check (women-only enforcement)
- [ ] Driving license validation (drivers only)
- [ ] Vehicle document + vehicle eligibility verification (drivers only)
- [ ] Background check provider integration (drivers only)
- [ ] Manual review queue for edge cases

### ❌ Not in MVP
- AI-driven risk scoring during onboarding
- Ongoing identity re-verification for active accounts
- Non-Egyptian identity documents
- Guardian-verified minor accounts

---

## Module 5 — Payments (Cash + Digital)

### ✅ In MVP
- [ ] Single PSP integration
- [ ] Card tokenization + saved cards
- [ ] Payment authorization + capture (digital trips)
- [ ] Cash payment recording (dual rider + driver confirmation)
- [ ] Driver cash balance ledger
- [ ] Commission calculation per trip
- [ ] Cash settlement workflow (operational, not automated)
- [ ] Payment failure handling
- [ ] Manual refunds (initiated by Ops via portal)
- [ ] Receipt generation
- [ ] Cancellation fee calculation
- [ ] Ride blocking for users with unresolved payment failures

### ❌ Not in MVP
- In-app rider wallet
- In-app driver wallet
- Automated driver payouts (end-to-end settlement automation)
- Multiple PSPs / advanced payment routing
- Promo codes, discounts, referrals, loyalty points
- Automated refund processing
- Subscription pricing models
- Prepaid ride bundles

---

## Module 6 — Trip & Dispatch Engine

### ✅ In MVP
- [ ] Driver–rider matching algorithm
- [ ] Zone-aware eligibility filtering (working zone + availability + rating)
- [ ] Ride broadcast with configurable timeout
- [ ] Atomic acceptance handling (prevent double-assignment)
- [ ] Decline / timeout → automatic reassignment
- [ ] ETA calculation
- [ ] Trip lifecycle state machine: `requested → matched → driver_arrived → in_progress → completed / cancelled`
- [ ] Real-time driver location streaming (to rider + ops portal)
- [ ] Pickup geofence detection
- [ ] Drop-off geofence detection
- [ ] No-driver-available retry queue
- [ ] Operating-hours enforcement (daytime-only, no new bookings outside window)

### ❌ Not in MVP
- Ride pooling / multi-stop matching
- Scheduled ride queuing
- Surge / peak-hour demand multipliers (hooks exist, not activated)
- AI demand forecasting for pre-positioning drivers
- Dispatcher-initiated manual dispatch

---

## Module 7 — Pricing & Neighborhood Zones

### ✅ In MVP
- [ ] Polygon-based zone definition (map editor in Admin Portal)
- [ ] Per-zone base fare
- [ ] Per-km rate per zone
- [ ] Per-minute rate per zone
- [ ] Minimum fare per zone
- [ ] Zone-to-zone pricing rules
- [ ] Cancellation fee rules per zone
- [ ] Pricing rule versioning (audit trail + rollback)

### ❌ Not in MVP
- Peak-hour / surge multipliers (hooks exist but not activated)
- Promotional fare overrides
- Dynamic pricing based on demand signals
- Zone-specific operating hours (all zones share one window at MVP)
- Multiple service-tier pricing (premium, family-plus)

---

## Module 8 — Safety & SOS

### ✅ In MVP
- [ ] SOS button — Rider App
- [ ] SOS button — Driver App
- [ ] Automated data capture on trigger (location, trip snapshot, user, vehicle details)
- [ ] Real-time alert to Ops SOS queue
- [ ] Response SLA tracking per incident
- [ ] Defined escalation workflow (Ops → external authorities)
- [ ] Live trip sharing (shareable link sent to trusted contacts)
- [ ] Trusted contacts notification on SOS trigger
- [ ] Incident logging
- [ ] Post-incident follow-up workflow
- [ ] Women-only policy enforcement
- [ ] Age eligibility policy enforcement

### ❌ Not in MVP
- In-trip audio recording
- In-trip video recording
- AI-driven behavior monitoring and risk scoring
- Predictive safety analytics
- Automated fraud detection beyond basic controls
- Direct SOS integration with Ministry of Interior (aspirational; handled via manual escalation at MVP)

---

## Module 9 — Notifications

### ✅ In MVP
- [ ] SMS channel (foundational for OTP)
- [ ] Push notifications (rider + driver apps)
- [ ] In-app notifications
- [ ] Email channel
- [ ] Template management — Arabic + English
- [ ] Delivery tracking + automatic retry
- [ ] User notification preferences (non-critical messages only)
- [ ] Critical-alert priority mode (bypasses quiet hours for SOS / safety messages)

### ❌ Not in MVP
- WhatsApp / third-party messaging channel
- Rich media push notifications (images, deep-link cards)
- Granular per-notification-type preference controls
- Marketing / promotional broadcast messaging

---

## Module 10 — Reporting & Analytics

### ✅ In MVP
- [ ] Live operational dashboard
- [ ] Daily ride summary report
- [ ] Weekly ride summary report
- [ ] Driver performance report
- [ ] Cancellation analytics report
- [ ] Payment reconciliation report
- [ ] Safety incident report
- [ ] Zone performance report
- [ ] Management KPI dashboard
- [ ] CSV / Excel export for all reports

### ❌ Not in MVP
- Full Business Intelligence platform
- Predictive analytics and demand forecasting
- Custom / ad-hoc analytical dashboards
- Cross-platform data warehousing
- Real-time BI streaming dashboards
- Automated anomaly detection in reports

---

## Cross-Cutting Constraints (All Modules)

### ✅ In MVP
- Greater Cairo only (Cairo + Giza governorates)
- Daytime-only operating window (exact hours TBD by Operations)
- Drivers own and operate their own vehicles (no platform fleet)
- Women-only rider and driver eligibility
- Single PSP for digital payments
- Cash settlement is an operational process (not system-automated)
- Admin Portal in English only

### ❌ Not in MVP
- Multi-city or intercity expansion
- 24/7 operation
- Male opt-in driver pool (post-MVP liquidity lever)
- Platform-owned or leased vehicle fleet
- B2B / corporate billing
