# SheDrive — Phase 1.5 Stories (Deferred)

**Status:** Deferred — scheduled for **Phase 1.5** (the increment between Phase 1 launch and Phase 2).
**Decision date:** 2026-06-17.
**ADO state:** All stories below have been set to **Removed** in Azure DevOps (project `SheDrive`). They are **intentionally not part of the live Phase 1 backlog**. This file is the maintained local record for Phase 1.5 — it is the one place these stories live outside ADO.

> **Sync note:** The four role-split backlog files (`api-stories.md`, `admin-stories.md`, `mobile-rider-stories.md`, `mobile-driver-stories.md`) mirror the **active** ADO backlog. The stories here have been moved out of those files into this document. Full original acceptance criteria also remain recoverable from the Removed ADO work items and this repo's git history.

## Why these were deferred

| Cluster | Rationale |
|---|---|
| **SOS / Emergency** | SheDrive's headline safety differentiator (SOS → Ministry of Interior). The API contract is still an undefined placeholder and needs dedicated requirements work with operations and legal before it can be built. Pulled out of Phase 1 so the empty placeholder is not mistaken for ready work. |
| **Online / card payment** | Phase 1 launches **cash-only**. Card/PSP processing and everything depending on it is deferred to keep the MVP lean for a cash-dominant market. The cash settlement stack (driver cash balance, cash reconciliation, revenue reporting) **stays** in Phase 1. |
| **Scheduled rides** | Advance booking + a continuous dispatch scheduler is a self-contained feature that is not required for launch. |
| **Overlapping-zone fare resolution** | Edge-case handling; at MVP, zones are configured not to overlap, so smallest-zone resolution is unnecessary complexity. |

## Decisions captured

- **Kept in Phase 1 (not deferred):** in-app routing (`#1817` driver turn-by-turn, `#1818` rider route geometry); the cash settlement stack (`#1781` driver cash balance, `#1813` cash reconciliation, `#1812` revenue & settlement reporting); `#1687` rider suspension after gender-mismatch report (women-only enforcement, **not** emergency SOS).
- **#1815 (manual refund)** is deferred **with** the payment cluster (its primary mechanism is PSP/online refunds).

---

## Deferred stories index

| # | Type | Title | Cluster | Orig. ADO parent feature | Pts |
|---|---|---|---|---|---|
| 1692 | Rider (legacy) | Emergency / SOS Screen | SOS | — (orphan, no parent) | — |
| 1723 | Mobile | Rider triggers SOS during active trip | SOS | #1773 | — |
| 1725 | API | Rider triggers SOS during active trip | SOS | #1779 | — |
| 1726 | Mobile | Driver is notified when a rider triggers SOS | SOS | #1774 | — |
| 1727 | API | Driver is notified when a rider triggers SOS | SOS | #1779 | — (already Removed) |
| 1780 | API | Trusted contacts notified with live trip link on SOS | SOS | #1779 | — |
| 1787 | Mobile | Rider sets up trusted contacts (live link on SOS) | SOS | #1773 | 3 |
| 1730 | API | Rider selects a payment method | Payment | #1775 | — |
| 1732 | Mobile | Rider selects a payment method | Payment | #1768 | 3 |
| 1733 | API | Rider completes online card payment at trip end | Payment | #1775 | — |
| 1734 | Mobile | Rider completes online card payment at trip end | Payment | #1768 | — |
| 1782 | API | Driver retrieves payment method / collection status | Payment | #1609 | — |
| 1789 | Mobile | Driver sees digital payment status at trip end | Payment | #1543 | — |
| 1784 | API | Booking blocked on unresolved payment failure | Payment | #1775 | — |
| 1793 | Mobile | Rider with unresolved payment failure blocked | Payment | #1768 | 3 |
| 1815 | Admin | Super admin processes a manual refund | Payment | #1803 | — |
| 1737 | Mobile | Rider schedules a ride in advance | Scheduling | #1770 | — |
| 1738 | API | Rider schedules a ride in advance | Scheduling | #1777 | — |
| 1829 | API | Fare engine resolves overlapping zones to smallest | Overlap | #1601 | — |

> `#1692` had no standalone section in the local backlog (legacy ADO-only orphan). `#1829` had no standalone local section — it was described inline in the zone-resolution narrative in `api-stories.md`; its dedicated ADO story is captured below.

---

# Cluster A — SOS / Emergency

## [API] #1725 — Rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety API (#1779) · **ADO:** Removed · **Pts:** —

**Description:** As the rider app, I want to submit an SOS alert during an active trip so that the platform can notify the operations team and initiate emergency protocols.

**Status:** PLACEHOLDER. The SOS API contract — alert schema, recipient routing, trip-pause behaviour, notification to the assigned driver, and Ministry of Interior integration — is to be defined in Phase 1.5 alongside the Mobile SOS story. Must not be picked up until replaced with a complete specification.

**Dependencies:** #1780 (trusted contacts live link); MoI integration spec (TBD).

## [API] #1727 — Driver is notified when a rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety API (#1779) · **ADO:** Removed (already) · **Pts:** —

**Description / AC:** Placeholder (all [TBD]) — to be defined with the SOS contract.

## [API] #1780 — Rider's trusted contacts are notified with a live trip link on SOS
**Orig. feature:** Emergency & Safety API (#1779) · **ADO:** Removed · **Pts:** —

**Description:** As the SheDrive platform, I want to store a rider's trusted contacts and, when she triggers SOS during an active trip, notify those contacts with a live trip-tracking link so that the people she trusts can follow her location in real time during an emergency.

**Background:** CRUD for a rider's trusted contacts (name + phone), plus — on SOS trigger (#1725) — dispatching a secure, time-limited live trip-tracking link to each stored contact. Live-location sharing is scoped to the SOS event only (no standalone share-my-trip in Phase 1). The link exposes the in-progress trip's live driver/vehicle location and trip details until the trip ends or a configured time limit elapses.

**Scenarios:** (1) Rider stores trusted contacts · (2) Validation: contact limit & phone format · (3) SOS dispatches a live link to all trusted contacts · (4) Live link reflects real-time location until trip ends · (5) SOS with no trusted contacts still records the incident · (6) Unauthenticated request rejected.

**Out of scope:** standalone non-SOS live sharing; two-way chat/calling; contact identity verification; non-SOS event notifications.
**Dependencies:** #1725.

## [Mobile] #1723 — Rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety / Mobile (#1773) · **ADO:** Removed · **Pts:** —

**Description:** As a rider, I want to trigger an SOS alert during an active trip so that emergency assistance can be dispatched immediately.

**Status:** PLACEHOLDER. SheDrive's primary safety differentiator (direct line to the Ministry of Interior); requires dedicated requirements-gathering with operations and legal. Full scope defined in Phase 1.5. Must not be picked up until replaced with a complete specification.

## [Mobile] #1726 — Driver is notified when a rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety / Mobile-Driver (#1774) · **ADO:** Removed · **Pts:** —

**Description / AC:** Placeholder (all [TBD]) — to be defined with the SOS contract.

## [Mobile] #1787 — Rider sets up trusted contacts who receive a live trip link on SOS
**Orig. feature:** Emergency & Safety / Mobile (#1773) · **ADO:** Removed · **Pts:** 3

**Description:** As a rider, I want to save trusted contacts and have them automatically receive a live trip-tracking link when I trigger SOS so that people I trust can follow my location during an emergency.

**Background:** From the profile/safety section the rider can add, edit, and remove trusted contacts (name + phone). Having a contact is encouraged but not required. Live-location sharing is tied to SOS only (#1723 → #1780). No standalone "share my trip" in Phase 1. All strings via `data-i18n` with Arabic fallback.

**Field validation:** Contact name — required, 2–50 letters/spaces. Contact phone — required, valid Egyptian mobile.
**Scenarios:** (1) Add a trusted contact (max 5) · (2) Edit/remove a contact · (3) Invalid phone shows validation error · (4) On SOS, contacts alerted with live link · (5) SOS with no contacts still sends, prompts to add one.
**Dependencies:** #1780, #1723.

## [Rider] #1692 — Emergency / SOS Screen *(legacy ADO orphan)*
**Orig. feature:** none · **ADO:** Removed · **Pts:** —

Legacy ADO-only story (old `[Rider]` prefix, no parent, no local backlog section). Superseded by the `[Mobile]` SOS stories above. Recorded here for completeness.

---

# Cluster B — Online / Card Payment

## [API] #1730 — Rider selects a payment method
**Orig. feature:** Payments API (#1775) · **ADO:** Removed · **Pts:** —

**Description:** As the rider app, I want to store the rider's preferred payment method so that it is used as the default for future trips.
**Field validation:** `payment_method` — required, enum `cash`|`card`.
**Scenarios:** (1) Selects cash · (2) Selects card · (3) Preference retrieved (GET), defaults to cash · (4) Invalid value rejected · (5) Unauthenticated rejected.
**Out of scope:** card tokenization/processing; multiple payment-method management.
**Dependencies:** #1744.

## [API] #1733 — Rider completes online card payment at trip end
**Orig. feature:** Payments API (#1775) · **ADO:** Removed · **Pts:** —

**Description:** As the SheDrive platform, I want to charge the agreed fare to the rider's saved card when a card-payment trip ends so that the fare is collected without cash exchange.
**Background:** Triggered when a `payment_method: card` trip reaches `trip_ended`. Retrieves saved card token, calls the payment gateway, records the result, pushes receipt (rider) and payment-received (driver). On failure marks `payment_failed` and prompts retry/cash fallback.
**Scenarios:** (1) Card charge succeeds · (2) Card charge fails · (3) Retry succeeds · (4) Cash trip skips card processing · (5) Unauthenticated rejected.
**Out of scope:** refunds; partial payments; gateway provider selection.
**Dependencies:** #1744, #1639 (driver ends trip).

## [API] #1784 — Booking is blocked when the rider has an unresolved payment failure
**Orig. feature:** Payments API (#1775) · **ADO:** Removed · **Pts:** —

**Description:** As the SheDrive platform, I want to reject new trip requests from a rider who has an unresolved payment failure so that an outstanding balance is settled before she can ride again.
**Background:** A failed card charge (#1733) flags the account with an outstanding amount; while set, #1629 rejects new bookings with a machine-readable, localizable reason. Cleared on settlement.
**Scenarios:** (1) Blocked while unresolved · (2) Settling restores booking · (3) No failure → books normally · (4) Reason machine-readable & localizable · (5) Unauthenticated rejected.
**Dependencies:** #1733, #1629.

## [API] #1782 — Driver retrieves payment method and collection status for a completed trip
**Orig. feature:** Driver Active Trip / Completion API (#1609) · **ADO:** Removed · **Pts:** —

**Description:** As the driver app, I want each completed trip to tell me how the rider paid and whether I need to collect cash so that I never ask for cash on a trip the rider already paid for by card.
**Note:** In cash-only Phase 1 this is fully covered by #1717 (driver retrieves completed-trip fare); the card distinction returns with the payment cluster.
**Scenarios:** (1) Cash → full fare to collect · (2) Card paid → nothing to collect · (3) Card pending/failed → status surfaced, no cash ask · (4) Own trips only · (5) Unauthenticated rejected.
**Dependencies:** #1733, #1637.

## [Mobile] #1732 — Rider selects a payment method
**Orig. feature:** Payments / Mobile (#1768) · **ADO:** Removed · **Pts:** 3

**Description:** As a rider, I want to select my preferred payment method before or after a trip so that I can choose between cash and card payment.
**Background:** Payment selector on the home screen (Cash / Card), default Cash, carried into the trip request via #1730, visible to the driver. Cannot change after submission.
**Scenarios:** (1) Selects Cash · (2) Selects Card · (3) Default Cash for new rider · (4) Last-used pre-selected · (5) Method passed with trip request.
**Dependencies:** #1730, #1552.

## [Mobile] #1734 — Rider completes online card payment at trip end
**Orig. feature:** Payments / Mobile (#1768) · **ADO:** Removed · **Pts:** —

**Description:** As a rider, I want to pay by card at the end of my trip so that I don't need to carry cash.
**Background:** For card trips the trip-complete screen shows a processing state, charges via #1733, then receipt or retry / "Pay Cash to Driver" fallback.
**Scenarios:** (1) Card processes successfully · (2) Fails → retry · (3) Fails → switch to cash · (4) Cash trip skips card screen.
**Dependencies:** #1733, #1564.

## [Mobile] #1789 — Driver sees digital payment status at trip end
**Orig. feature:** Trip Completion & Cash Payment / Mobile-Driver (#1543) · **ADO:** Removed · **Pts:** —

**Description:** As a driver, I want the trip-end screen to tell me when the rider paid by card so that I do not ask for cash on a card trip.
**Background:** Trip-end screen reflects payment method via #1782 — cash shows amount to collect; card shows "paid by card — collect nothing" with digital status. Complements #1592.
**Scenarios:** (1) Cash → amount to collect · (2) Card → nothing to collect · (3) Card pending/failed → status, no cash ask · (4) Returns to available · (5) Network error toast.
**Dependencies:** #1782, #1592.

## [Mobile] #1793 — Rider with an unresolved payment failure is blocked from booking
**Orig. feature:** Payments / Mobile (#1768) · **ADO:** Removed · **Pts:** 3

**Description:** As a rider, I want to be told when a past payment failed and be guided to settle it so that I can book rides again.
**Background:** When #1784 blocks booking, "Request Ride" shows a bilingual blocking message with the outstanding amount and a path to settle; once settled, booking resumes. Strings via `data-i18n`; transient errors use a toast.
**Scenarios:** (1) Blocked rider informed on booking · (2) Settles → can book · (3) No failure → books normally · (4) Network error → toast + retry.
**Dependencies:** #1784, #1734.

## [Admin] #1815 — Super admin processes a manual refund
**Orig. feature:** Admin Financial Reporting & Reconciliation (#1803) · **ADO:** Removed · **Pts:** —

**Description:** As a super admin, I want to issue a manual refund against a completed trip so that I can resolve billing disputes and overcharges.
**Background:** From a completed trip's detail (#1672), refund digital-paid trips via PSP (full/partial ≤ amount charged, mandatory reason, audited via #1816); cash trips recorded as offline refunds.
**Field validation:** Refund amount — required, decimal EGP, 0.01 ≤ amount ≤ amount charged. Reason — required, 10–500 chars.
**Scenarios:** (1) Full refund (digital) · (2) Partial refund · (3) Amount ≤ charged · (4) Reason required · (5) PSP failure → retry · (6) Refund visible & audited · (7) Cash trip → offline refund.
**Out of scope:** automated refunds; commission reversal; full dispute case management.
**Dependencies:** #1672, #1759, PSP integration, #1816.

---

# Cluster C — Scheduled Rides

## [API] #1738 — Rider schedules a ride in advance
**Orig. feature:** Scheduled Rides API (#1777) · **ADO:** Removed · **Pts:** —

**Description:** As the rider app, I want to create, list, and cancel scheduled trip requests so that a rider can book a ride in advance and the platform can automatically dispatch it at the right time.
**Background:** POST/GET/DELETE scheduled trips. Validates `scheduled_at` ≥ now+30 min, ≤ now+7 days, within operating window (OD-001). A continuous scheduler dispatches ~15 min before `scheduled_at` via #1629 + #1630; no-driver handling via #1632. Africa/Cairo local time. Lead time (30 min), horizon (7 days), dispatch window (15 min) are final confirmed values.
**Field validation:** `scheduled_at` (ISO-8601, the rule above); pickup/destination (lat/lng within zones); `payment_method` (cash|card per #1730); `is_child_passenger` (bool, default false per #1783).
**Scenarios:** (1) Created successfully · (2) Too soon · (3) Outside operating hours · (4) Beyond horizon · (5) GET upcoming · (6) DELETE before dispatch · (7) Auto-dispatch at lead time · (8) Auto-dispatch with no driver · (9) Cancel after dispatch rejected · (10) Unauthenticated rejected.
**Out of scope:** recurring rides; in-place edit; scheduled-ride surge; notification template content.
**Dependencies:** #1629, #1630, #1632, #1730, #1783, #1744, OD-001.

## [Mobile] #1737 — Rider schedules a ride in advance
**Orig. feature:** Scheduled Rides / Mobile (#1770) · **ADO:** Removed · **Pts:** —

**Description:** As a rider, I want to schedule a ride for a future date and time within operating hours so that I can arrange transportation in advance and be matched with a driver automatically when the time approaches.
**Background:** "Schedule for later" flow: date/time picker (≥30 min, ≤7 days, within OD-001), payment method (#1732), optional child declaration (#1790), indicative estimate (#1552). Created via #1738; appears in "Scheduled rides" list; auto-matches ~15 min before via #1554; push when matching starts and when driver found. Modify = cancel + rebook.
**Field validation:** Scheduled date & time; Pickup; Destination; Payment method — all required (rules as above).
**Scenarios:** (1) Schedules successfully · (2) Too soon · (3) Outside hours · (4) Beyond horizon · (5) Payment & child carried into trip · (6) Views upcoming · (7) Cancels before dispatch · (8) Auto-dispatch at lead time · (9) No driver at dispatch · (10) Network error.
**Out of scope:** recurring rides; in-place edit; scheduled-ride surge/pricing; guaranteed assignment at exact minute.
**Dependencies:** #1738, #1552, #1732, #1790, #1791, #1554.

---

# Cluster D — Overlapping-zone fare resolution

## [API] #1829 — Fare engine resolves overlapping service zones to the smallest zone
**Orig. feature:** Fare Estimate API (#1601) · **ADO:** Removed · **Pts:** —

**Description:** As the fare service, I want to deterministically pick the smallest (most specific) zone when pickup coordinates fall inside more than one overlapping zone, so that fares are always priced from the correct rate card.
**Background:** Extends #1628. When coordinates fall inside ≥2 overlapping zones, select the smallest-area zone and use its rate card. Inactive (no rate card) smallest zone blocks the trip with no fallback to a larger active zone. *(In the local backlog this behaviour was described inline within the zone-resolution narrative rather than as a standalone section.)*
**Scenarios:** (1) Two overlapping zones → smaller wins · (2) Nested/multiple → smallest wins · (3) Equal-area tie-break = most recently created · (4) Selected zone drives the fare · (5) No overlap unaffected · (6) Smallest matching zone Inactive → blocked, no fallback.
**Out of scope:** preventing/warning about overlap at admin config time (#1756); the fare formula & minimum-fare (#1628).
**Dependencies:** #1628, #1756, #1757.
