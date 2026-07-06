# Driver App — Design Discrepancies (for the Designer)

**Purpose:** This is the list of changes the SheDrive driver-app **designs** (the screenshots in `Design/Driver App/`) need so they match the **user stories**, which are the single source of truth.

**How to read this:** For each screen we list what deviates from the stories and what to change. Where a corrected reference exists, we link the **live mockup** — the mockup already conforms to the stories, so use it as the target.

- **Mockup base URL:** `https://shedrive-web.abdelrahman-arcorp.workers.dev/`
- **Story IDs** (e.g. `#1572`) refer to the Mobile-Driver backlog in ADO / `docs/backlog/mobile-driver-stories.md`.

**Severity legend**
- 🔴 **Must fix** — breaks the intended logic or a hard rule.
- 🟠 **Scope/contract** — adds something with no story, or contradicts a story's scope.
- 🟡 **Polish** — minor/cosmetic.

---

## A. Cross-cutting issues (apply to multiple screens)

| # | Severity | Issue | Fix |
|---|---|---|---|
| A1 | 🔴 | **Currency shown in USD (`$`)** on several screens ($145.50, $18.50, $23.50, $168.00). | All money is **EGP / جنيه**. Replace every `$` value with EGP. |
| A2 | 🔴 | **Driver shown gross fare / fare breakdown.** Story #1766 requires the driver to see **net earnings** only and **never** the gross fare or commission. | On Trip Completed, Trip History, Trip Details: show **net earnings** (and cash-to-collect), remove gross "Total Fare" and the Base/Distance/Time/Taxes breakdown. |
| A3 | 🔴 | **Onboarding wizard is the wrong shape.** Design is a 4-step KYC flow (ID photo → Selfie → Vehicle docs). Stories define a **5-step** flow. | Re-sequence to the 5 steps in section B (Onboarding). See mockup `/driver/onboarding.html`. |
| A4 | 🟠 | **Acceptance countdown shows 00:26.** Story #1582/#1585 specify a **10-second** window. | Change the request countdown to 10s (or raise it as a product decision). |
| A5 | 🟠 | **Out-of-scope components present this phase:** in-app **Call/Chat**, **SOS / Safety Tools**, **queued/next rides**, **driver-rates-passenger**. | See per-screen rows. Remove or mark "Phase 2 / pending story". |

---

## B. Per-screen discrepancies

### Authentication & Onboarding

**`Splash.png`** — ✅ No issues. (No splash user story exists; acceptable.)

**`Login.png`** — 🟠 Shows "Welcome back" (returning user only).
- Add the **new-driver registration** path and make routing explicit after OTP: **new → onboarding**, **pending → "Verification Submitted"**, **rejected → rejection screen**, **approved → Home**. Mockup: `/driver/index.html`.

**`OTP.png`** — ✅ No issues (6-digit + resend).

**`Step 02 - Upload ID` / `View Photo Examples` / `Take Photo - Front Side` / `Review Photo` / `ID Uploaded Successfully`** — 🔴 This whole **National-ID-photo** sub-flow is **not in the stories**.
- Story #1572 captures the National ID as a **typed 14-digit number** inside a **Personal Details form** (full name, date of birth, NID number) plus a **background-check consent checkbox** — there is no "upload ID photo" step.
- **Replace** this sub-flow with the **Step 1 — Personal Details form**. Mockup: `/driver/onboarding.html`.

**`Step 03 - Selfie Verification` / `Capture Selfie`** — 🟠 Correct content (#1686 profile photo), wrong position.
- This is the **final step (Step 5)**, after vehicle details, vehicle photos and documents — not step 3.
- Add a **gallery fallback** when the camera is unavailable/denied (#1686).

**`Step 04 - Vehicle Verification` / `Vehicle Upload Document` / `Take Photo - Insurance Doc` / `Review Insurance Doc` / `Vehicle Document Uploaded`** — 🔴 Wrong documents + missing steps.
- Documents per #1575 are **driving licence (front/back)** + **vehicle registration (front/back)** — **4 slots**. The design uploads **"Vehicle License + Insurance"**: **insurance is not in the stories**, and the **driver's driving licence is missing**.
- Also **missing two whole steps** that belong before documents:
  - **Vehicle Details form** (#1573): make, model, year (2010–current), plate, colour, vehicle type (Sedan/SUV/Minivan).
  - **Vehicle Photos** (#1574): exactly **5 labelled angle slots** — front, rear, driver side, passenger side, interior.
- Mockup: `/driver/onboarding.html` (steps 2, 3, 4).

**`Verification Submitted.png`** — 🟠 Happy path only.
- Add the **Rejected** variant (#1577 / #1660): rejection reason shown + a resubmit/contact-support action. Mockup: `/driver/onboarding.html?status=rejected`.

> **Corrected 5-step onboarding (target):** 1) Personal details (name, DOB, NID number, consent) · 2) Vehicle details form · 3) Vehicle photos (5 angles) · 4) Licence + registration docs · 5) Profile selfie → Submit → Pending/Rejected.

### Home & Trip Acceptance

**`Home.png` (offline)** — 🔴 Shows a **"Nearby Requests" list with Accept buttons while Offline**.
- A driver **cannot** accept trips while offline, and SheDrive dispatches **one request at a time via push** (#1582, #1630) — drivers don't browse a list.
- Remove the nearby-requests browse list. Offline home = status + "Go Online" + today's earnings summary.
- 🟡 "Performance" (Acceptance/Completion rate) and "Daily Goal" have no story — keep only if desired; mark as extra.
- 🔴 Currency `$` → EGP (A1). Mockup: `/driver/home.html`.

**`Waiting New Request.png` (online idle)** — ✅ Correct "searching for requests" idle state.
- 🟡 Make it consistent with `Home.png` (the two home screens currently disagree — keep this searching model, drop the browse-list one).

**`New Request.png`** — 🟠 Countdown 00:26 → **10s** (A4). 🔴 `$18.50` → EGP (A1).
- ✅ Women-Only + Verified rider tags and Accept/Decline are correct. Mockup: `/driver/request.html`.

### Active Trip

**`Navigate To Pickup.png`** — 
- 🟠 **Call / Chat** buttons are **out of scope** (#1583/#1586) — remove or mark Phase 2.
- 🔴 **Missing "Open in external app"** (Google Maps / Waze) handoff button (#1586).
- 🔴 **Missing "Cancel Trip"** entry (#1722). Mockup: `/driver/trip.html?state=en-route`.

**`Waiting For Passenger.png`** — 🔴 Jumps straight to "Start Ride".
- On the driver's **first trip**, #1588 requires a **gender-verification gate** before starting: **"Rider Verified — Board"** and **"Cancel — Rider Not Female"**. Missing.
- **Missing Cancel Trip** with reason picker + **rider no-show fee-free countdown** (#1722). The "Free waiting time" counter (#1767) is correct but must feed the no-show cancel option.
- 🟠 Call/Chat out of scope. Mockup: `/driver/trip.html?state=arrived`.

**`Ride In Progress.png` / `Ride In Progress - Slide Up.png`** —
- ✅ Correctly has **no Cancel** after the trip starts (#1722 S7).
- 🟠 Slide-up **Safety Tools** (Share Live Location, Emergency Contact) = SOS — **out of scope** this phase.
- 🔴 **Missing "Open in external app"** (#1590). Mockup: `/driver/trip.html`.

**`Next Ride Opportunity.png` / `Next Ride Reserved.png` / `Queued Ride Ready.png`** — 🟠 **No user story.**
- This queued / back-to-back ride feature contradicts the dispatch model (a trip is dispatched to the nearest **available** driver; a driver mid-trip isn't available).
- **Hold** these three pending a product decision: either user stories get written, or the screens are cut.

**`You've Arrived.png` / `Arrived at Destination - Slide Up.png`** — maps to trip end (#1591).
- 🟠 Slide-up Safety Tools out of scope. Otherwise OK. Mockup: `/driver/trip.html`.

### Completion

**`Trip Completed.png`** — 🔴 Shows gross **"Total Fare $18.50"**.
- Show **net earnings** + a clear **cash-to-collect** amount in EGP (#1766, #1592). Remove gross fare.
- 🟠 The embedded **"How was your passenger?"** stars = driver-rates-passenger, which has **no story** — remove or story it.
- 🔴 Currency `$` → EGP. Mockup: `/driver/cash-collection.html`.

**`Rate Passenger.png` / `Rate Submited Successfully.png`** — 🟠 **No user story** for the driver rating the passenger.
- Decide: write a story, or remove these screens.

### History & Menu

**`Trip History.png`** — 🔴 Shows **"Trip Fare 650 LE"** (gross).
- Show **net earnings** per trip (#1766 S2).
- 🟠 The **Today / This Week / This Month** tabs exceed #1593 (filtering is out of scope for history) — they belong to the **Earnings dashboard** (#1736). Remove from history. Mockup: `/driver/history.html`.

**`Trip Details.png`** — 🔴 Shows a full **gross fare breakdown** (Base / Distance / Time / Taxes / Total 650).
- #1766 forbids showing gross/commission to the driver; #1594 wants the **net (driver-earned)** amount. Replace the breakdown with net earnings.
- ✅ Keep: date, pickup/destination, distance, duration, and the **rating received from the rider**. Mockup: `/driver/trip-detail.html`.

**`Menu.png` / `Menu - Theme 2.png`** — 🟠 Several items have **no story / are out of scope**:
- Out of scope this phase: **Safety Center** (SOS), **Help Center** & **Contact Support** (#1576 in-app support out of scope), **Notifications** settings (#1577 out of scope). Also **Documents** and **App Settings** have no story.
- **Ensure present:** Earnings (#1736), Trip History (#1593), **Cash Balance owed** (#1788 — "Transactions" should be this), **Profile** (#1801), **Language** toggle (#1731), Logout (#1571). Mockup: `/driver/profile.html`.

---

## C. Missing screens to design (no design exists today)

| Screen | Story | Corrected mockup |
|---|---|---|
| Onboarding **Step 1 — Personal details** (name, DOB, NID number, consent) | #1572 | `/driver/onboarding.html` |
| Onboarding **Vehicle details form** (make/model/year/colour/plate/type) | #1573 | `/driver/onboarding.html?step=2` |
| Onboarding **Vehicle photos — 5 angles** | #1574 | `/driver/onboarding.html?step=3` |
| Onboarding **Driving licence + vehicle registration** (4 slots, not insurance) | #1575 | `/driver/onboarding.html?step=4` |
| **Application Rejected** screen (reason + resubmit) | #1577 / #1660 | `/driver/onboarding.html?status=rejected` |
| **First-trip female verification** gate (board / not-female) | #1588 | `/driver/trip.html?state=arrived` |
| **Cancel Trip** — reason picker + fee + no-show countdown | #1722 | `/driver/trip.html?state=arrived` |
| **Cash Balance Owed** to the platform | #1788 | `/driver/balance.html` |
| **Earnings dashboard** (today/week/month + recent trips) — only partial today | #1736 | `/driver/earnings.html` |

---

## D. Screens / components with NO user story (decide: story or remove)

- **Next Ride Opportunity / Next Ride Reserved / Queued Ride Ready** (queued back-to-back rides).
- **Rate Passenger / Rating Submitted** (driver rating the passenger).
- **Safety Tools / Safety Center / Emergency Contact** (SOS) — deferred past Phase 1.
- In-app **Call / Chat** with the rider — deferred past Phase 1.
- Home **Performance** metrics (acceptance/completion rate) and **Daily Goal**.

---

*Generated from the screenshots in `Design/Driver App/` checked against `docs/backlog/mobile-driver-stories.md`. The mockup pages linked above already conform to the stories and should be treated as the visual/logic target.*
