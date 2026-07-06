# SheDrive — Software Requirements Specification (SRS)

**Detailed Functional, Business-Rule & Validation Specification**

| | |
|---|---|
| **Product** | SheDrive — women-only ride-hailing (Greater Cairo) |
| **Document** | SRS v1.0 (draft) |
| **Status** | For review |
| **Companion documents** | BRD v1.1 · Backlog user stories · HLD v1.5 |
| **Last updated** | 2026-06-30 |

---

## 1. Introduction & Document Ownership Map

### 1.1 Purpose

This SRS specifies SheDrive at the level of detail that the BRD, the user stories, and the HLD
each deliberately leave out: exact field validations, the precise business-rule and calculation
logic, the field-level data dictionary, the enumerations and configurable parameters, and the
bilingual system-message catalogue. It is the authoritative reference for QA test design,
implementation of validation and calculation logic, and bilingual content sign-off.

It is intentionally **not** a restatement of the other three documents. Where a topic is owned
elsewhere, this SRS references it rather than repeating it (see §1.3 and §7 Traceability).

### 1.2 Scope

In scope: the SheDrive MVP across three surfaces — Rider App, Driver App, and Admin Portal —
plus the API behaviour the apps depend on. Phase-1.5 items (online card payment, SOS, scheduled
rides, trusted contacts) are included where they affect validations, rules, or messages, and are
flagged as Phase 1.5.

Out of scope: everything the BRD §5.2 / HLD §3.4.3 mark out of scope (ride pooling, scheduled
rides at GA, wallets, multi-PSP, etc.). This SRS does not re-derive that list.

### 1.3 Document Ownership Boundaries

This is the rule that keeps the SRS non-redundant. Each concern has exactly one owning document;
the SRS owns only the right-hand column.

| Concern | Owning document | SRS treatment |
|---|---|---|
| Why / business case / market / strategy / commercial scope | **BRD v1.1** | Referenced only |
| What each actor does + acceptance scenarios | **User stories** (`docs/backlog/*.md`, ADO) | Referenced by story ID |
| System context, module decomposition, architecture | **HLD §4.1–4.2** | Referenced only |
| Non-functional / quality attributes (performance, availability, scalability, security posture, maintainability, operability, interoperability, testability) | **HLD §3.5** | Referenced only — **not** restated |
| Architectural & platform constraints | **HLD §3.3** | Referenced only |
| Conceptual data model, ownership, classification, retention, residency | **HLD §4.4** | Referenced; SRS adds the finer **field-level** dictionary (§4) |
| External integration contracts (Paymob, Google Maps, FCM/APNS, SMS) | **HLD §4.6** | Referenced only |
| Security architecture, auth flow, RBAC matrix, encryption | **HLD §4.5** | Referenced only |
| Deployment, hardware, risk, compliance, glossary, tech stack | **HLD §5–10** | Referenced only |
| **Field validations** | **SRS §3** | **Owned** (the one area that may duplicate stories, by design) |
| **Business rules & calculations** | **SRS §2** | **Owned** |
| **Field-level data dictionary** | **SRS §4** | **Owned** |
| **Enumerations & configurable parameters** | **SRS §5** | **Owned** |
| **System messages, errors & notifications** | **SRS §6** | **Owned** |

### 1.4 References

- **BRD:** `docs/brd/` and `docs/product/BRD.md` (Business Requirements Document v1.1).
- **HLD:** `docs/SheDrive_HLD_v1.5.pdf` (High-Level Design v1.5).
- **User stories:** `docs/backlog/mobile-rider-stories.md`, `mobile-driver-stories.md`,
  `admin-stories.md`, `api-stories.md`, `phase-1.5-stories.md` (canonical local mirror of ADO).
- **Bilingual content source of record:** `shedrive-web/shared/i18n/en.json` and `ar.json`.
- **Open decisions:** `docs/product/open-decisions.md` (referenced as OD-xxx below).

### 1.5 Definitions & glossary

This SRS does **not** carry its own glossary. Use **HLD §10.1 (Glossary of Key Terms)** and
**HLD §10.6 (Acronyms & Abbreviations)** as the single source. Terms used here (Rider, Driver,
Super Admin, Trip, SOS, KYC/first-trip verification, Working Zone, Zone Rate Card, Commission)
carry their HLD meanings.

### 1.6 Conventions

- **Shall / must** = mandatory; **should** = recommended; **may** = optional.
- All money is **EGP**, stored and displayed to **2 decimal places**, **VAT-inclusive**.
- All times are **EET/EEST (UTC+2/UTC+3)**; server timestamps are authoritative (HLD principle).
- "**Configurable**" means the value is set in the Admin Portal at runtime, not in code; where a
  launch baseline is not yet decided it is marked **TBD (OD-xxx)**.
- A rule that the i18n copy contradicts is flagged **⚠ reconcile** so it is fixed once, here.

---

## 2. Business Rules & Computation Specifications

These are the exhaustive, testable rules referenced by many stories but defined authoritatively
nowhere else. The HLD states the high-level formula; this section is the edge-complete spec.

### 2.1 Authentication & OTP (BR-AUTH)

| ID | Rule |
|---|---|
| BR-AUTH-01 | Rider and Driver authenticate by **phone + SMS OTP**; no password. Super Admin authenticates by **email + password + TOTP 2FA** (Admin #1806). |
| BR-AUTH-02 | OTP is **exactly 6 numeric digits**. |
| BR-AUTH-03 | OTP **expires** after the configured validity window (**TBD**, recommend 5 min); an expired code is rejected with `login.error.expired`. |
| BR-AUTH-04 | After **3 incorrect** OTP entries the code is **invalidated**; the user must request a new one (`login.error.tooManyAttempts`). |
| BR-AUTH-05 | **Resend** is gated by a cooldown countdown (`login.resend.cooldown`, `{{n}}s`); duration **TBD**, recommend 30 s. |
| BR-AUTH-06 | Login on an **unregistered** number returns `login.error.notRegistered` (route to registration), never a generic failure. |
| BR-AUTH-07 | Session **persists across app restarts** (Rider #1745 / Driver #1746) until logout or suspension; logout invalidates the session (API #1624). |
| BR-AUTH-08 | Admin 2FA: repeated invalid TOTP codes **lock the attempt** for a cooldown; recovery codes are single-use (Admin #1806). |

### 2.2 Identity & Eligibility (BR-ID)

| ID | Rule |
|---|---|
| BR-ID-01 | **Women-only** is non-waivable (HLD constraint C01). No configuration or role can disable it. |
| BR-ID-02 | **Rider identity** in MVP = phone OTP at registration **+ driver visual verification on the first trip**. Riders do **not** upload a National ID. ⚠ reconcile: legacy `verify.*` (rider NID/selfie) i18n keys are not part of the MVP rider flow and should be retired. |
| BR-ID-03 | **First-trip verification** (Driver #1588): on a rider's first trip the driver confirms the rider is female → boards; or cancels with a gender-mismatch report. |
| BR-ID-04 | A gender-mismatch report **cancels the trip with no fare** and **suspends the rider account** for review (API #1687, Admin #1810/#1811). |
| BR-ID-05 | **Driver eligibility** = Admin approval after human review of documents + profile photo with an explicit "I confirm this applicant is female" confirmation (Admin #1659). No automated eKYC. |
| BR-ID-06 | **Driver minimum age = 18** (DOB check at onboarding). **Riders and drivers otherwise have no maximum age**; riders have no minimum age (HLD C03). |
| BR-ID-07 | **Child-passenger exception** (Rider #1790): a male child **under 15** may travel only when declared at booking; the flag is surfaced to the driver. This is the sole exception to women-only. |
| BR-ID-08 | A driver **cannot go online until approved** (API #1644). |

### 2.3 Fare Calculation (BR-FARE) — API #1627, #1628, #1747, #1636, #1829

| ID | Rule |
|---|---|
| BR-FARE-01 | **Route source:** Google Maps with `departure_time=now`; the route with the **lowest `duration_in_traffic`** is selected; tie-break = **shorter distance**. Only `distance_km` and `duration_in_traffic (min)` feed the fare engine. |
| BR-FARE-02 | **Zone resolution:** pickup coordinates resolve to exactly one **Zone Rate Card**. Outside all zones → reject `PICKUP_OUTSIDE_SERVICE_AREA` (HTTP 422). Zone with no rate card → `ZONE_RATE_CARD_MISSING` (HTTP 422). Missing/malformed coordinates → HTTP 400. |
| BR-FARE-03 | **Overlapping zones** resolve to the **smallest** containing zone (API #1829). |
| BR-FARE-04 | **Formula:** `fare = base_fare + (distance_km × per_km_rate) + (duration_min × per_min_rate)`, computed **before** the minimum-fare floor. |
| BR-FARE-05 | **Minimum-fare floor:** if formula result `< minimum_fare`, charge `minimum_fare` and set `minimum_fare_applied = true`; else return the formula result with `minimum_fare_applied = false`. |
| BR-FARE-06 | **Zero edge case:** distance = 0 and duration = 0 → fare = `base_fare` only, no error. |
| BR-FARE-07 | **VAT-inclusive:** rate-card values already include VAT; VAT is **never** added on top. |
| BR-FARE-08 | **Estimate vs final:** the pre-booking number is an **estimate**; the **final fare** is recomputed at completion from **actual** GPS distance/duration (API #1636) using the **same** engine, so the same inputs yield an identical fare in both contexts. |
| BR-FARE-09 | **Output:** `total_fare` (EGP, 2 dp), `zone_id`, `zone_name`, `distance_km`, `duration_min`, `minimum_fare_applied`. The rider is shown **total only** (no itemised breakdown by design); the **driver** trip detail shows the breakdown. |
| BR-FARE-10 | **No** surge, time-of-day multiplier, per-vehicle-type rate, or promo codes in MVP. |

### 2.4 Driver Matching & Dispatch (BR-MATCH) — API #1629, #1630, #1585, #1649, #1650

| ID | Rule |
|---|---|
| BR-MATCH-01 | **Candidate pool:** drivers who are **online**, **approved**, and **not currently assigned**, whose **ETA to pickup ≤ 15 minutes**. ETA computed **once** at pool construction (not recomputed mid-search). |
| BR-MATCH-02 | Candidates **ranked ascending by ETA**; pool **capped at the 20 lowest-ETA** drivers. |
| BR-MATCH-03 | **Dispatch loop:** offer to one driver at a time with a **10-second acceptance window**; on reject or timeout, advance to the next in the ranked list. No strike/penalty for rejecting or timing out; the driver stays online and eligible. |
| BR-MATCH-04 | A driver may sit in **multiple** pending pools; **first acceptance wins** — on accept she is removed from every other pool and any in-flight offer to her elsewhere is cancelled. |
| BR-MATCH-05 | **Expiry is list-driven, not timed:** the trip is `expired` only when the list is exhausted with no acceptance, or the pool was empty at construction. The rider then sees the no-driver state. |
| BR-MATCH-06 | While searching, the **driver currently being attempted** is published to the rider app ("trying with …"). |
| BR-MATCH-07 | **Operating-hours gate** (Rider #1791): new ride requests are rejected outside the configured operating window, enforced server-side. Exact window = **TBD (OD-001)**. |

### 2.5 Trip Lifecycle (BR-TRIP)

| ID | Rule |
|---|---|
| BR-TRIP-01 | The **canonical state machine and valid transitions are owned by HLD §4.2.4** (Requested → SearchingForDriver → DriverAssigned → DriverEnRoute → DriverArrived → TripStarted → TripInProgress → TripCompleted; terminal Cancelled / Expired). This SRS does not redraw it; the **enum values** are catalogued in §5.1. |
| BR-TRIP-02 | Transitions that **skip** states are rejected (server-side state machine). |
| BR-TRIP-03 | **Timers are derived from server timestamps** (waiting counter, acceptance window), so they survive app restart/background. |
| BR-TRIP-04 | On `DriverArrived` a **waiting counter** starts (Driver #1767, Rider #1559); it underpins the rider-no-show fee waiver (BR-CANCEL-05). |

### 2.6 Cancellation Fees (BR-CANCEL) — API #1764, #1715, #1720; config #1757/#1759

The clock for all cancellation rules starts at **driver acceptance**. The fee, grace periods,
split %, and wait-time used are those **active at acceptance time**, not at cancellation time.

| ID | Rule |
|---|---|
| BR-CANCEL-01 | **Rider cancels within rider grace period** → no fee; record `cancelled_by=rider, fee_charged=false`. |
| BR-CANCEL-02 | **Rider cancels after rider grace period** → the **zone's fixed cancellation fee** is charged to the rider and **split** between driver and platform by the configured **driver-share %**; record fee, driver share, platform share. |
| BR-CANCEL-03 | **Driver cancels within driver grace period** → no fee. |
| BR-CANCEL-04 | **Driver cancels after driver grace period** (reason other than qualifying no-show) → **fixed driver cancellation fee** charged to the driver. |
| BR-CANCEL-05 | **Rider no-show waiver:** a driver-cancel with reason **rider no-show** is fee-waived **only if** the driver had marked **arrived** and **waited ≥ the configured rider-no-show wait time**; otherwise the driver fee applies. |
| BR-CANCEL-06 | Every cancellation records **who cancelled** and the **cancellation reason** (driver reason set in §5.2). |

### 2.7 Settlement, Commission & Driver Balance (BR-PAY) — API #1636, #1735; Driver #1766, #1788

| ID | Rule |
|---|---|
| BR-PAY-01 | On completion the **final fare** is computed (BR-FARE-08) and the **platform commission** is deducted; **driver net = final_fare − commission**. Commission % is **configurable (#1759)**, launch value **TBD**. |
| BR-PAY-02 | **Cash trip:** the driver collects the **full fare** from the rider and **owes the platform its commission**; the owed amount accrues to the **driver cash balance** (Driver #1788). |
| BR-PAY-03 | **Card trip (Phase 1.5):** the platform captures the fare via Paymob; the driver receives net automatically; no cash owed. |
| BR-PAY-04 | A **settlement reminder** is raised when the driver cash balance exceeds the configured threshold (HLD §4.2.6); threshold **TBD**. |
| BR-PAY-05 | **Unresolved payment failure blocks new bookings** for that rider until resolved (API #1784, Rider #1793). |
| BR-PAY-06 | Cancellation-fee **driver share** is added to driver earnings; **platform share** to platform revenue (ties to BR-CANCEL-02). |

### 2.8 Rating (BR-RATE) — Rider #1565/#1799, API #1639/#1654

| ID | Rule |
|---|---|
| BR-RATE-01 | A rating is **1–5 whole stars**; submission **requires** a star value (`complete.starsError`). |
| BR-RATE-02 | Optional **tags**, optional **tip**, optional **comment** may accompany the rating. |
| BR-RATE-03 | Rating may be **skipped** (Rider #1799); an unrated trip can be rated later from history (Rider #1568). |
| BR-RATE-04 | The **driver aggregate rating** is recomputed on each new rating (API #1654). Aggregation method (simple mean vs trailing window) = **TBD**. |

### 2.9 Payment Method Selection (BR-PM) — Phase 1.5, #1730/#1732

| ID | Rule |
|---|---|
| BR-PM-01 | Per-rider default payment method is **Cash** or **Card**; default = **Cash** until changed. |
| BR-PM-02 | Card capture uses **Paymob hosted fields**; raw PAN never touches SheDrive (HLD §4.5.3). The app collects only what Paymob's hosted field requires (number, expiry, CVV) inside that field. |

---

## 3. Field Validation Specifications ⭐

The consolidated, bilingual validation catalogue. Format follows the project-standard 10-column
Admin table. EN/AR error strings are the source-of-record values from `en.json` / `ar.json`;
where the catalogue and the i18n copy disagree, the **⚠ reconcile** note states the intended rule.

### 3.1 Authentication & Registration

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Phone number | Yes | Egyptian mobile | Digits, format `01X XXXXXXXX`; prefixes 010/011/012/015 | 11 digits | 11 digits | — | Please enter a valid phone number / أدخلي رقم هاتف صحيح | Invalid phone number. Please enter a valid Egyptian mobile number / رقم هاتف غير صحيح | — ⚠ reconcile: `login.error.phone` says "10-digit"; Egyptian mobiles are 11 digits incl. leading 0 — align copy to 11. |
| OTP code | Yes | Numeric | Exactly 6 digits (0–9) | 6 | 6 | — | Please enter all 6 digits / أدخلي الأرقام الستة | Incorrect verification code / رمز التحقق غير صحيح | Code invalidated after 3 attempts / تم إلغاء الرمز بعد 3 محاولات |
| Full name (Rider/Driver) | Yes | Text, letters only | Letters and spaces (AR/EN); no digits/symbols | 2 chars | 50 chars | — | Enter your full name / أدخلي اسمك الكامل | Name must contain letters only / يجب أن يحتوي الاسم على حروف فقط | Name must be between 2 and 50 characters / يجب أن يكون الاسم بين 2 و50 حرفًا |
| Email (Admin login) | Yes | Email | `local@domain.tld` | — | 254 | — | Enter your email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح | Email must be ≤ 254 characters |
| Password (Admin) | Yes | Masked | Any printable character | 8 | 128 | — | Enter your password / أدخل كلمة المرور | — | Password must be at least 8 characters |
| TOTP code (Admin) | Yes | Numeric | Exactly 6 digits | 6 | 6 | — | Enter the authentication code / أدخل رمز المصادقة | Invalid or expired code / رمز غير صحيح أو منتهي الصلاحية | Code must be exactly 6 digits |

### 3.2 Rider Profile & Booking

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email (rider profile) | No | Email | `local@domain.tld` | — | 254 | empty | — | Invalid email address | — |
| Preferred language | Yes | Enum | `ar`, `en` | — | — | `ar` | — | — | — |
| Pickup location | Yes | Geo point | Lat/Lng within a service zone | — | — | Current GPS | Choose a pickup location / اختاري مكان الانطلاق | Pickup outside service area | — |
| Destination | Yes | Geo point | Lat/Lng, distinct from pickup | — | — | — | Choose your destination / اختاري وجهتك | Choose a destination different from pickup / اختاري وجهة مختلفة عن مكان الانطلاق | — |
| Child-passenger declaration | No | Boolean (+ implied age band) | true/false; child must be < 15 | — | — | false | — | — | — |

### 3.3 Driver Onboarding

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| National ID number | Yes | Numeric | Exactly 14 digits | 14 | 14 | — | Enter your National ID number / أدخلي رقمك القومي | National ID must be 14 digits / يجب أن يتكون الرقم القومي من 14 رقمًا | — |
| Date of birth | Yes | Date | Valid date; age ≥ 18 | age 18 | — | — | Please select your date of birth / اختاري تاريخ ميلادك | Invalid date format | You must be at least 18 years old / يجب ألا يقل عمرك عن 18 عامًا |
| Vehicle make | Yes | Text/enum | Picklist or "Other" free text | — | — | — | Enter the vehicle make / أدخلي ماركة السيارة | — | — |
| Vehicle model | Yes | Text/enum | Picklist or "Other" free text | — | — | — | Enter the vehicle model | — | — |
| Vehicle year | Yes | Numeric | 2010 … current year | 2010 | current year | — | Enter the year of manufacture | — | Year must be between 2010 and the current year / يجب أن تكون السنة بين 2010 والسنة الحالية |
| Plate number | Yes | Text | Egyptian plate format | — | — | — | Enter the plate number | Invalid plate number / رقم لوحة غير صحيح | — |
| Vehicle colour | Yes | Enum | white/black/silver/grey/red/blue/other | — | — | — | Select the vehicle colour | — | — |
| Vehicle type | Yes | Enum | Sedan / SUV / Minivan | — | — | — | Select the vehicle type | — | — |
| Vehicle photo | Yes | Image | JPEG, PNG | — | 10 MB | — | Please take a photo of your vehicle | Please upload a valid image (JPEG or PNG) | Image is too large, maximum 10 MB / الصورة كبيرة جدًا، الحد الأقصى 10 ميجابايت |
| Profile photo (selfie) | Yes | Image | JPEG, PNG | — | 10 MB | — | Please take a profile photo | Please upload a valid image (JPEG or PNG) | Image is too large, maximum 10 MB |
| Driving licence — front/back | Yes (each) | File | Image or PDF | — | 10 MB | — | Please upload this document | Please upload an image or PDF | File is too large, maximum 10 MB |
| Vehicle registration — front/back | Yes (each) | File | Image or PDF | — | 10 MB | — | Please upload this document | Please upload an image or PDF | File is too large, maximum 10 MB |
| Driving licence number | Yes | Alphanumeric | Letters and digits | 6 | 20 | — | Enter your driving licence number / أدخلي رقم رخصة القيادة | Invalid licence number / رقم الرخصة غير صحيح | Licence number must be 6–20 characters / يجب أن يكون رقم الرخصة بين 6 و20 خانة |
| Driving licence expiry date | Yes | Date (DD/MM/YYYY) | Future date (not expired) | — | — | — | Enter your driving licence expiry date / أدخلي تاريخ انتهاء رخصة القيادة | Invalid date format / صيغة التاريخ غير صحيحة | Driving licence has expired / رخصة القيادة منتهية الصلاحية |
| Vehicle registration expiry date | Yes | Date (DD/MM/YYYY) | Future date (not expired) | — | — | — | Enter your vehicle registration expiry date / أدخلي تاريخ انتهاء رخصة تسيير السيارة | Invalid date format / صيغة التاريخ غير صحيحة | Vehicle registration has expired / رخصة تسيير السيارة منتهية الصلاحية |
| Background-check consent | Yes | Boolean | must = true | — | — | false | You must agree to the background check to continue / يجب الموافقة على فحص السجل الجنائي للمتابعة | — | — |

### 3.4 Admin Portal (Pricing & Zones)

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Zone name | Yes | Text | Free text | 1 | 80 | — | Enter a zone name | — | Name must be ≤ 80 characters |
| Zone polygon | Yes | GeoJSON | Closed polygon, ≥ 3 vertices | 3 vertices | — | — | Draw the zone boundary | Polygon must be a closed shape | — |
| Base fare | Yes | Decimal (EGP) | ≥ 0, 2 dp | 0.00 | — | — | Enter the base fare | Must be a number | Must be ≥ 0 |
| Per-km rate | Yes | Decimal (EGP) | ≥ 0, 2 dp | 0.00 | — | — | Enter the per-km rate | Must be a number | Must be ≥ 0 |
| Per-minute rate | Yes | Decimal (EGP) | ≥ 0, 2 dp | 0.00 | — | — | Enter the per-minute rate | Must be a number | Must be ≥ 0 |
| Minimum fare | Yes | Decimal (EGP) | ≥ 0, 2 dp | 0.00 | — | — | Enter the minimum fare | Must be a number | Must be ≥ base fare |
| Cancellation fee (per zone) | Yes | Decimal (EGP) | ≥ 0, 2 dp | 0.00 | — | — | Enter the cancellation fee | Must be a number | Must be ≥ 0 |
| Platform commission % | Yes | Percentage | 0–100, 2 dp | 0 | 100 | — | Enter the commission rate | Must be a number | Must be between 0 and 100 |
| Driver share % (of cancellation fee) | Yes | Percentage | 0–100 | 0 | 100 | — | Enter the driver share | Must be a number | Must be between 0 and 100 |
| Rider grace period | Yes | Duration (sec) | ≥ 0 | 0 | — | — | Enter the grace period | Must be a number | Must be ≥ 0 |
| Driver grace period | Yes | Duration (sec) | ≥ 0 | 0 | — | — | Enter the grace period | Must be a number | Must be ≥ 0 |
| Rider no-show wait time | Yes | Duration (sec) | ≥ 0 | 0 | — | — | Enter the wait time | Must be a number | Must be ≥ 0 |
| Rejection reason (driver app review) | Yes (on reject) | Text | Free text | 1 | 500 | — | Enter a reason for rejection | — | Reason must be ≤ 500 characters |

---

## 4. Data Dictionary (field-level)

Finer grain than the HLD §4.4 conceptual entity model (which is explicitly "not physical
schema"). Only the **fields the user enters, sees, or that are computed** are listed — the SRS
dictionary, not the database schema. `D` = derived/computed by the system.

### 4.1 Rider

| Field | Type | Format / Unit | Req | Source | Notes |
|---|---|---|---|---|---|
| rider_id | UUID | — | — | D | System identifier |
| phone | string | `01XXXXXXXXX` | Yes | Entered | Unique; login identity |
| full_name | string | 2–50, letters | Yes | Entered | |
| email | string | email | No | Entered | Optional |
| language | enum | ar/en | Yes | Entered | Default ar |
| account_status | enum | active/suspended | — | D | §5.3 |
| is_first_trip | bool | — | — | D | Drives first-trip verification |
| has_unresolved_payment_failure | bool | — | — | D | Blocks booking (BR-PAY-05) |

### 4.2 Driver & Vehicle

| Field | Type | Format / Unit | Req | Source | Notes |
|---|---|---|---|---|---|
| driver_id | UUID | — | — | D | |
| phone | string | `01XXXXXXXXX` | Yes | Entered | Login identity |
| full_name | string | 2–50, letters | Yes | Entered | |
| national_id | string | 14 digits | Yes | Entered | |
| date_of_birth | date | — | Yes | Entered | Age ≥ 18 |
| background_check_consent | bool | — | Yes | Entered | Must be true |
| onboarding_status | enum | §5.3 | — | D | pending/approved/rejected |
| rejection_reason | string | ≤ 500 | Cond | Admin | Set on rejection |
| availability | enum | online/offline | — | Entered | |
| working_zones | array | zone_id[] | Yes | Entered | One or more |
| aggregate_rating | decimal | 1–5, 1 dp | — | D | API #1654 |
| cash_balance_owed | decimal | EGP 2 dp | — | D | BR-PAY-02 |
| vehicle.make / model | string | — | Yes | Entered | |
| vehicle.year | int | 2010–current | Yes | Entered | |
| vehicle.plate | string | EG plate | Yes | Entered | |
| vehicle.colour | enum | §5.2 | Yes | Entered | |
| vehicle.type | enum | Sedan/SUV/Minivan | Yes | Entered | |
| documents[] | file ref | JPEG/PNG/PDF ≤10MB | Yes | Uploaded | Licence ×2, registration ×2, vehicle photo, profile photo, NID photo |
| licence_number | string | 6–20 alphanumeric | Yes | Entered | Driving licence number |
| licence_expiry | date | future | Yes | Entered | Must not be expired |
| registration_expiry | date | future | Yes | Entered | Must not be expired |

### 4.3 Trip

| Field | Type | Format / Unit | Req | Source | Notes |
|---|---|---|---|---|---|
| trip_id | UUID | — | — | D | |
| rider_id / driver_id | UUID | — | — | D | driver_id null until assigned |
| pickup / destination | geo point | lat/lng | Yes | Entered | |
| zone_id / zone_name | ref | — | — | D | Resolved (BR-FARE-02/03) |
| status | enum | §5.1 | — | D | State machine (HLD §4.2.4) |
| child_passenger_declared | bool | — | No | Entered | BR-ID-07 |
| payment_method | enum | cash/card | Yes | Entered | Default cash |
| distance_km / duration_min | decimal | km / min | — | D | Estimate then actual |
| estimated_fare | decimal | EGP 2 dp | — | D | Pre-booking |
| final_fare | decimal | EGP 2 dp | — | D | At completion |
| minimum_fare_applied | bool | — | — | D | BR-FARE-05 |
| commission_amount / driver_net | decimal | EGP 2 dp | — | D | BR-PAY-01 |
| cancelled_by | enum | rider/driver | Cond | D | |
| cancellation_reason | enum/text | §5.2 | Cond | Entered | |
| fee_charged / fee_amount / driver_share / platform_share | bool / decimal | — | Cond | D | BR-CANCEL |
| rating.stars / tags / tip / comment | int / array / decimal / text | 1–5 / — / EGP / ≤ n | No | Entered | BR-RATE |

### 4.4 Pricing / Zone / Config

| Field | Type | Format / Unit | Req | Source | Notes |
|---|---|---|---|---|---|
| zone_id | UUID | — | — | D | |
| zone_name | string | ≤ 80 | Yes | Admin | |
| polygon | GeoJSON | closed, ≥3 pts | Yes | Admin | |
| base_fare / per_km / per_min / minimum_fare / cancellation_fee | decimal | EGP 2 dp ≥0 | Yes | Admin | Zone rate card |
| platform_commission_pct | decimal | 0–100 | Yes | Admin | Global (#1759) |
| driver_share_pct | decimal | 0–100 | Yes | Admin | Cancellation split |
| rider_grace_period / driver_grace_period / rider_no_show_wait | int | seconds | Yes | Admin | Global (#1759) |
| operating_hours | time range | EET | Yes | Admin | OD-001 |

---

## 5. Enumerations, Reference Data & Configurable Parameters

The HLD says behaviour is "configuration-driven" but never catalogues the values. This is the
single list QA and Admin work from.

### 5.1 Trip status (canonical set — values owned here, transitions owned by HLD §4.2.4)

`requested` · `searching` · `driver_assigned` · `en_route` (driver to pickup) ·
`arrived_pickup` · `trip_started` / `in_progress` · `trip_ended` · `completed` ·
`cancelled_before_start` · `cancelled_during_trip` · `expired` · `payment_recorded`.

### 5.2 Other enumerations

| Enum | Values |
|---|---|
| Vehicle type | Sedan, SUV, Minivan |
| Vehicle colour | White, Black, Silver, Grey, Red, Blue, Other |
| Payment method | Cash, Card (Card = Phase 1.5) |
| Driver cancellation reason | Rider no-show, Rider unreachable, Vehicle issue, Safety concern, Wrong pickup location, Other |
| Rating tags | Safe driving, Clean car, Friendly, On time, Calm, Professional |
| Application / onboarding status | Pending, Approved, Rejected |
| Account status | Active, Suspended |
| Language | ar, en |
| User role | Rider, Driver, Super Admin (single admin role this phase) |
| Gender-mismatch report status | Open, Actioned (Admin #1810/#1811) |

### 5.3 Configurable parameters (set in Admin Portal; launch values where known)

| Parameter | Scope | Valid range / unit | Launch value | Source |
|---|---|---|---|---|
| Base fare | Per zone | EGP ≥ 0 | **TBD** | #1757 |
| Per-km rate | Per zone | EGP ≥ 0 | **TBD** | #1757 |
| Per-minute rate | Per zone | EGP ≥ 0 | **TBD** | #1757 |
| Minimum fare | Per zone | EGP ≥ base | **TBD** | #1757 |
| Cancellation fee | Per zone | EGP ≥ 0 | **TBD** | #1757 |
| Platform commission % | Global | 0–100 | **TBD** | #1759 |
| Driver share % (cancellation) | Global | 0–100 | **TBD** | #1759 |
| Rider grace period | Global | seconds | **TBD** | #1759 |
| Driver grace period | Global | seconds | **TBD** | #1759 |
| Rider no-show wait time | Global | seconds | **TBD** | #1759 |
| Operating hours | Global | time range (EET) | **TBD** | OD-001 / Rider #1791 |
| Acceptance window | Global (fixed in MVP) | seconds | **10** | #1585/#1630 |
| Matching ETA cap | Global (fixed in MVP) | minutes | **15** | #1630 |
| Candidate pool cap | Global (fixed in MVP) | count | **20** | #1630 |
| OTP length | Global (fixed) | digits | **6** | i18n / API #1620 |
| OTP max attempts | Global (fixed) | count | **3** | i18n |
| Driver minimum age | Global (fixed) | years | **18** | onboarding |
| Child passenger max age | Global (fixed) | years | **< 15** | Rider #1790 / HLD C03 |
| Max upload size | Global (fixed) | MB | **10** | i18n |
| Settlement reminder threshold | Global | EGP | **TBD** | HLD §4.2.6 |

---

## 6. System Messages, Errors & Notification Content Catalogue

The bilingual strings live only in `en.json` / `ar.json` — that JSON pair remains the **source of
record** for exact wording. This section is the consolidated **trigger + severity + channel** view
QA and content reviewers need; the i18n key is the join column. Representative coverage of the
operationally significant messages follows; the validation-field error strings are in §3.

### 6.1 Authentication & session

| i18n key | Trigger | Severity | Channel |
|---|---|---|---|
| `login.error.phone` / `login.error.phoneFormat` | Phone fails format | Error | Inline |
| `login.error.notRegistered` | Login on unknown number | Error | Inline → route to register |
| `login.error.wrongOtp` | Wrong OTP | Error | Inline |
| `login.error.expired` | OTP expired | Error | Inline |
| `login.error.tooManyAttempts` | 3 wrong OTP attempts | Error | Inline |
| `login.resend.cooldown` | Resend countdown | Info | Inline (`{{n}}s`) |
| `login.error.network` | Connectivity loss | Warning | Banner/toast |

### 6.2 Booking, matching & trip

| i18n key | Trigger | Severity | Channel |
|---|---|---|---|
| `home.gps.denied` | Location permission denied | Warning | Banner + Open settings |
| `home.dest.sameAsPickup` | Destination = pickup | Error | Inline |
| `home.fare.error` / `home.fare.retry` | Fare estimate failed | Error | Inline + retry |
| `matching.confirmed.title` | Driver found | Success | Sheet |
| `matching.noDriver.*` | List exhausted / empty pool | Info | Screen + retry/home |
| `trip.arrivedBanner` / `trip.pushBanner` | Driver arrived / en route | Info | Push + banner |
| `request.autoDeclined` / `driver.request.expired*` | 10-s window lapsed | Info | Toast (driver) |
| `verifyRider.cancelledToast` | Gender-mismatch report submitted | Critical | Toast + account action |

### 6.3 Cancellation, payment & earnings

| i18n key | Trigger | Severity | Channel |
|---|---|---|---|
| `driver.cancel.fee.none` / `willApply` | Cancel preview, fee state | Info | Sheet (`{{amount}}`) |
| `driver.cancel.fee.noShowWait` | No-show waiver countdown | Info | Sheet (`{{time}}`) |
| `driver.cancel.cancelledNoFee` / `cancelledFee` | Cancellation outcome | Info | Toast |
| `payment.declined.*` | Card declined | Error | Screen |
| `payment.success.*` | Card captured | Success | Screen |
| `driver.balance.*` | Cash owed to platform | Info | Screen |
| `driver.cash.netEarnings` / `netNote` | Net after commission | Info | Screen |

### 6.4 Onboarding & decision

| i18n key | Trigger | Severity | Channel |
|---|---|---|---|
| `onboarding.pending.*` | Application under review | Info | Screen (24–48h ETA) |
| `driver.decision.approved.*` | Approved | Success | Push + screen |
| `driver.decision.rejected.*` / `onboarding.rejected.*` | Rejected + reason | Error | Push + screen + resubmit |
| `onboarding.error.consent` | Consent unchecked | Error | Inline |

### 6.5 SOS (Phase 1.5)

| i18n key | Trigger | Severity | Channel |
|---|---|---|---|
| `trip.sosConfirm*` / `trip.sosSent` | Rider triggers SOS | Critical | Modal → confirm → toast |
| `emergency.*` | SOS dashboard | Critical | Full screen + SMS to trusted contacts (#1780/#1787) |
| `trip.driver.sosBody` / `emergencyTitle` | Driver SOS | Critical | Modal/screen |

> Notification delivery semantics (push best-effort + pull reconciliation, SMS fallback for
> safety) are owned by **HLD §3.2 / §4.6.3 / §4.6.4** and not restated here.

---

## 7. Traceability Matrix

Maps each SRS rule/validation area to its user stories, the HLD section, and the BRD theme. This
is the mechanism that lets the SRS **cite** rather than repeat. (Story IDs are ADO/​backlog refs.)

| SRS item | User stories | HLD ref | BRD theme |
|---|---|---|---|
| §2.1 / §3.1 Auth & OTP | Rider #1545/#1546/#1745; Driver #1569/#1570/#1746; API #1620/#1621/#1622/#1624; Admin #1656/#1806/#1822 | §4.2.9, §4.5.1 | Access & onboarding |
| §2.2 / §3.3 Identity & eligibility | Driver #1572/#1854/#1686/#1588; Rider #1790; API #1642/#1644/#1687; Admin #1657–#1660/#1810/#1811 | §4.2.5, §4.2.13, §3.3 (C01–C03) | Women-only safety |
| §2.3 / §3.2 Fare | Rider #1549/#1550/#1551/#1552; API #1627/#1628/#1747/#1829/#1636 | §4.2.8, §4.2.12 | Pricing |
| §2.4 Matching & dispatch | Rider #1554/#1555; Driver #1581–#1585; API #1629/#1630/#1649/#1650 | §4.2.4 | Trip & dispatch |
| §2.5 Trip lifecycle | Rider #1559/#1561/#1564; Driver #1586–#1592/#1767 | §4.2.4 (state machine) | Trip lifecycle |
| §2.6 / §3.4 Cancellation fees | Rider #1719; Driver #1722; API #1715/#1720/#1764; Admin #1759 | §4.2.8 | Cancellation policy |
| §2.7 Settlement & commission | Driver #1766/#1788/#1736; API #1636/#1735; Admin #1759/#1833 | §4.2.6 | Finance |
| §2.8 Rating | Rider #1565/#1799/#1568; Driver #1792; API #1639/#1654 | §4.2.4 | Quality/feedback |
| §2.9 Payment method (P1.5) | Rider #1732/#1734/#1793; API #1730/#1733/#1784; Admin #1815 | §4.2.6, §4.6.1 | Payments |
| §3.4 / §5.3 Zone & pricing config | Admin #1756/#1757/#1759/#1830/#1831 | §4.2.8 | Pricing config |
| §5.1 Trip status enum | (all trip stories) | §4.2.4 | — |
| §6.5 SOS (P1.5) | Rider #1723/#1787; Driver #1726; API #1725/#1727/#1780 | §4.2.7 | Safety/SOS |

---

### Open items carried by this SRS

These are the values this SRS cannot finalise because the decision sits with the business; each is
flagged inline above and should be closed in `docs/product/open-decisions.md`:

1. **OTP validity window** and **resend cooldown** duration (BR-AUTH-03/05).
2. **Operating hours** (OD-001, BR-MATCH-07).
3. **Launch rate cards** — base/per-km/per-min/min fare/cancellation fee per zone (§5.3).
4. **Platform commission %, driver share %, grace periods, no-show wait time** (§5.3).
5. **Driver rating aggregation method** (BR-RATE-04).
6. **Settlement reminder threshold** (BR-PAY-04).
7. **Phone-format copy** — align `login.error.phone` ("10-digit") to the 11-digit rule (§3.1).
8. **Retire legacy rider `verify.*` NID/selfie i18n keys** not used by the MVP rider flow (BR-ID-02).
