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

### Background

This is a placeholder story. The SOS API contract — including alert schema, recipient routing, trip pause behaviour, notification to the assigned driver, and Ministry of Interior integration — will be defined in a future sprint alongside the Mobile SOS story. Notifying the rider's trusted contacts with a live trip link is handled separately by #1780. This story must not be picked up for development until replaced with a complete specification.

### Acceptance Criteria

**Scenario 1 — PLACEHOLDER**
- Given [TBD]
- When a rider submits an SOS alert during an active trip
- Then the alert is recorded, the assigned driver is notified, and [TBD — full scenarios to be defined in a future sprint]

### Out of Scope
- All implementation details — pending requirements

### Dependencies
- #1780 — Trusted contacts notified with live trip link on SOS
- TBD — requires Ministry of Interior integration specification

## [API] #1727 — Driver is notified when a rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety API (#1779) · **ADO:** Removed (already) · **Pts:** —

**Description:** As the SheDrive platform, I want to send a push notification to the driver when a rider triggers SOS during an active trip so that the driver is immediately informed of the emergency.

### Background

This is a placeholder story. The push notification contract for driver SOS alerts will be defined in a future sprint. This story must not be picked up for development until replaced with a complete specification.

### Acceptance Criteria

**Scenario 1 — PLACEHOLDER**
- Given [TBD]
- When a rider submits an SOS alert
- Then [TBD — full scenarios to be defined in a future sprint]

### Out of Scope
- All implementation details — pending requirements

### Dependencies
- TBD

## [API] #1780 — Rider's trusted contacts are notified with a live trip link on SOS
**Orig. feature:** Emergency & Safety API (#1779) · **ADO:** Removed · **Pts:** —

**Description:** As the SheDrive platform, I want to store a rider's trusted contacts and, when she triggers SOS during an active trip, notify those contacts with a live trip-tracking link so that the people she trusts can follow her location in real time during an emergency.

### Background

This endpoint set supports two things: (1) CRUD for a rider's trusted contacts (name + phone number), and (2) on SOS trigger (#1725), dispatching a notification that contains a secure, time-limited live trip-tracking link to each stored trusted contact. Live-location sharing is scoped to the SOS event only — there is no standalone share-my-trip feature in Phase 1. The tracking link exposes the in-progress trip's live driver/vehicle location and trip details to the contact until the trip ends or a configured time limit elapses.

### Acceptance Criteria

**Scenario 1 — Rider stores trusted contacts**
- Given an authenticated rider submits one or more trusted contacts, each with a name and a valid Egyptian mobile number
- When the endpoint processes the request
- Then the contacts are persisted against her account and returned on subsequent reads

**Scenario 2 — Validation: contact limit and phone format**
- Given the rider submits more than the allowed number of contacts or an invalid phone number
- When the endpoint processes the request
- Then a validation error is returned identifying the offending field
- And no contact is saved

**Scenario 3 — SOS dispatches a live link to all trusted contacts**
- Given a rider with at least one trusted contact triggers SOS during an active trip (#1725)
- When the SOS is recorded
- Then each trusted contact is sent a notification containing a secure live trip-tracking link
- And the dispatch is logged against the SOS incident

**Scenario 4 — Live link reflects real-time location until the trip ends**
- Given a trusted contact opens the tracking link for an in-progress trip
- Then the link shows the live driver/vehicle location and trip details
- And the link stops resolving once the trip completes or the configured time limit elapses

**Scenario 5 — SOS with no trusted contacts still records the incident**
- Given a rider with no trusted contacts triggers SOS
- Then the SOS incident is still recorded for operations (#1725)
- And no trusted-contact notification is dispatched

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- Then it is rejected and no contacts are read or written

### Out of Scope
- Standalone (non-SOS) live trip sharing
- Two-way chat or calling with trusted contacts
- Trusted-contact identity verification
- Notifying trusted contacts on normal (non-SOS) trip events

### Dependencies
- #1725 — Rider triggers SOS during active trip (API — must be live)

## [Mobile] #1723 — Rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety / Mobile (#1773) · **ADO:** Removed · **Pts:** —

**Description:** As a rider, I want to trigger an SOS alert during an active trip so that emergency assistance can be dispatched immediately.

### Background

This is a placeholder story. The SOS and emergency flow is SheDrive’s primary safety differentiator — direct line to the Ministry of Interior — and requires dedicated requirements-gathering with the operations and legal teams before implementation can begin. The full scope will be defined in a future sprint. This story must not be picked up for development until replaced with a complete specification.

### Acceptance Criteria

**Scenario 1 — PLACEHOLDER**
- Given [TBD]
- When the rider activates SOS during an active trip
- Then [TBD — full scenarios to be defined in a future sprint]

### Out of Scope
- All implementation details — pending requirements

### Dependencies
- TBD — requires Ministry of Interior integration specification

## [Mobile] #1726 — Driver is notified when a rider triggers SOS during active trip
**Orig. feature:** Emergency & Safety / Mobile-Driver (#1774) · **ADO:** Removed · **Pts:** —

**Description:** As a driver, I want to be notified immediately when a rider triggers SOS during our active trip so that I can respond appropriately and assist with emergency coordination.

### Background

This is a placeholder story. The driver-side SOS notification behaviour — including what the driver sees, what actions are available, and how the trip state is affected — will be defined in a future sprint alongside the Rider SOS story. This story must not be picked up for development until replaced with a complete specification.

### Acceptance Criteria

**Scenario 1 — PLACEHOLDER**
- Given [TBD]
- When a rider triggers SOS during an active trip
- Then [TBD — full scenarios to be defined in a future sprint]

### Out of Scope
- All implementation details — pending requirements

### Dependencies
- TBD

## [Mobile] #1787 — Rider sets up trusted contacts who receive a live trip link on SOS
**Orig. feature:** Emergency & Safety / Mobile (#1773) · **ADO:** Removed · **Pts:** 3

**Description:** As a rider, I want to save trusted contacts and have them automatically receive a live trip-tracking link when I trigger SOS so that people I trust can follow my location during an emergency.

### Background

From the profile/safety section the rider can add, edit, and remove trusted contacts (name + phone number). Having a contact is encouraged but not required. Live-location sharing is tied to SOS only: when the rider triggers SOS during an active trip (#1723), the platform sends each saved trusted contact a secure live trip-tracking link (#1780). There is no standalone "share my trip" button in Phase 1. All user-visible strings flow through data-i18n keys with Arabic fallback text.

### Field Validation
| Field | Required | Rule | Error (AR) |
|---|---|---|---|
| Contact name | Yes | 2–50 letters and spaces | أدخلي اسم جهة الاتصال |
| Contact phone | Yes | Valid Egyptian mobile number | رقم الهاتف غير صالح |

### Acceptance Criteria

**Scenario 1 — Rider adds a trusted contact Max 5 contacts**
- Given an authenticated rider opens the trusted contacts screen
- When she enters a valid name and phone number and saves
- Then the contact is stored via #1780 and shown in her list

**Scenario 2 — Rider edits or removes a trusted contact**
- Given the rider has at least one trusted contact
- When she edits or removes it
- Then the change is persisted via #1780

**Scenario 3 — Invalid phone shows a validation error**
- Given the rider enters an invalid phone number
- When she taps save
- Then a bilingual validation error is shown and nothing is saved

### Out of Scope
- Standalone (non-SOS) live trip sharing
- Calling or chatting with trusted contacts
- Notifying trusted contacts on normal (non-SOS) trip events

### Dependencies
- #1780 — Rider's trusted contacts are notified with a live trip link on SOS (API — must be live)
- #1723 — Rider triggers SOS during active trip

## [Rider] #1692 — Emergency / SOS Screen *(legacy ADO orphan)*
**Orig. feature:** none · **ADO:** Removed · **Pts:** —

Legacy ADO-only story (old `[Rider]` prefix, no parent, no local backlog section). Superseded by the `[Mobile]` SOS stories above. Recorded here for completeness.

---

# Cluster B — Online / Card Payment

## [API] #1730 — Rider selects a payment method
**Orig. feature:** Payments API (#1775) · **ADO:** Removed · **Pts:** —

**Description:** As the rider app, I want to include the selected payment method in the trip request so that the platform records the agreed payment method for the trip.

### Background

The payment_method field is added to the trip creation request. The platform stores the selected method (cash or card) on the trip record. The driver app retrieves this value as part of the trip detail response. No payment processing occurs at trip creation — the field is informational only at this stage. Defaults to 'cash' if omitted.

### Acceptance Criteria

**Scenario 1 — Trip created with payment_method: cash**
- Given a rider submits a trip request with payment_method: 'cash'
- When the endpoint is called
- Then the trip record includes payment_method: 'cash'
- And the driver app receives this value in the trip detail response

**Scenario 2 — Trip created with payment_method: card**
- Given a rider submits a trip request with payment_method: 'card'
- When the endpoint is called
- Then the trip record includes payment_method: 'card'

**Scenario 3 — Invalid payment method is rejected**
- Given a rider submits a trip request with an unrecognised payment_method value
- When the endpoint is called
- Then the platform returns a validation error

**Scenario 4 — Missing payment method defaults to cash**
- Given a rider submits a trip request without a payment_method field
- When the endpoint is called
- Then the trip record defaults to payment_method: 'cash'

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

### Out of Scope
- Card tokenisation or payment gateway integration
- Payment method change after trip creation

### Dependencies
- #1619 — Authentication service (must be live)
- #1629 — Rider creates trip request (must be live)

## [API] #1733 — Rider completes online card payment at trip end
**Orig. feature:** Payments API (#1775) · **ADO:** Removed · **Pts:** —

**Description:** As the SheDrive platform, I want to charge the agreed fare to the rider's saved card when a card-payment trip ends so that the fare is collected without cash exchange.

### Background

This endpoint is triggered when a trip with payment_method: 'card' transitions to trip_ended state. The platform retrieves the rider's saved card token, calls the payment gateway to charge the final fare amount, records the transaction result on the trip record, and sends push notifications to both the rider (receipt) and the driver (payment received). If the charge fails, the trip is marked payment_failed and the rider app is notified to prompt retry or cash fallback.

### Acceptance Criteria

**Scenario 1 — Card charge succeeds**
- Given a trip with payment_method: 'card' transitions to trip_ended
- When the payment endpoint is called
- Then the fare is charged to the rider's saved card
- And the trip record is updated with payment_status: paid and transaction_id
- And a push notification is sent to the rider with the receipt
- And a push notification is sent to the driver confirming payment received

**Scenario 2 — Card charge fails**
- Given the payment gateway returns a failure
- When the charge is attempted
- Then the trip record is updated with payment_status: payment_failed
- And the rider app is notified to prompt retry or cash fallback

**Scenario 3 — Retry charge succeeds**
- Given a trip with payment_status: payment_failed
- When the rider retries payment and the gateway succeeds
- Then the trip record is updated to payment_status: paid

**Scenario 4 — Cash trip skips card processing**
- Given a trip with payment_method: 'cash' transitions to trip_ended
- Then no card charge is attempted
- And the trip record is updated with payment_status: cash

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

### Out of Scope
- Refund processing
- Partial payments
- Payment gateway provider selection

### Dependencies
- #1619 — Authentication service (must be live)
- #1639 — Driver ends trip at destination (must be live)

## [API] #1784 — Booking is blocked when the rider has an unresolved payment failure
**Orig. feature:** Payments API (#1775) · **ADO:** Removed · **Pts:** —

**Description:** As the SheDrive platform, I want to reject new trip requests from a rider who has an unresolved payment failure so that an outstanding balance is settled before she can ride again.

### Background

When a card payment fails at trip end (#1733), the rider's account is flagged with an unresolved payment failure and an outstanding amount. While that flag is set, the platform must block new bookings: the trip-request endpoint (#1629) rejects the request with a clear, machine-readable, localizable reason and the outstanding amount. The block is cleared when the outstanding payment is settled (the rider pays via the app or operations resolves it). Riders with no outstanding failure are unaffected.

### Acceptance Criteria

**Scenario 1 — Rider with an unresolved failure is blocked**
- Given an authenticated rider has an unresolved payment failure on her account
- When she submits a trip request
- Then the request is rejected with a payment-required reason and the outstanding amount
- And no trip is created

**Scenario 2 — Settling the balance restores booking**
- Given the rider settles the outstanding amount
- When she submits a new trip request
- Then the request is accepted

**Scenario 3 — Rider with no outstanding failure books normally**
- Given the rider has no unresolved payment failure
- When she submits a trip request
- Then the request proceeds normally

**Scenario 4 — Block reason is machine-readable and localizable**
- Given a blocked request
- Then the response carries a stable reason code and a localizable message in Arabic and English

**Scenario 5 — Unauthenticated request is rejected**
- Given a request without a valid session token
- Then it is rejected

### Out of Scope
- The card-charge flow itself (#1733)
- Refunds and partial payments
- Operations manual-override UI (admin)

### Dependencies
- #1733 — Rider completes online card payment at trip end (API — must be live)
- #1629 — Rider creates trip request

## [API] #1782 — Driver retrieves payment method and collection status for a completed trip
**Orig. feature:** Driver Active Trip / Completion API (#1609) · **ADO:** Removed · **Pts:** —

**Description:** As the driver app, I want each completed trip to tell me how the rider paid and whether I need to collect cash so that I never ask for cash on a trip the rider already paid for by card.

### Background

When a trip completes, the driver's completion screen must reflect the rider's payment method. For cash trips the driver collects the fare; for card (digital) trips the platform charges the rider's card (#1733) and the driver collects nothing. For the authenticated driver's completed trip, this returns: the payment method (cash or card), the fare amount, the amount to collect from the rider (equal to fare for cash, zero for card), and the digital payment status (e.g., paid, pending, failed) for card trips. Digital payment is part of Phase 1 scope.

### Acceptance Criteria

**Scenario 1 — Cash trip returns full fare to collect**
- Given the completed trip's payment method is cash
- When the driver retrieves the trip's payment status
- Then the method is cash and the amount to collect equals the fare

**Scenario 2 — Card trip paid: nothing to collect**
- Given the completed trip's payment method is card and the charge succeeded
- When the driver retrieves the trip's payment status
- Then the method is card, the digital payment status is paid, and the amount to collect is zero

**Scenario 3 — Card trip with pending or failed payment**
- Given the completed trip's payment method is card and the charge is pending or failed
- When the driver retrieves the trip's payment status
- Then the digital payment status is surfaced, the amount to collect is zero, and the driver is not asked to collect cash (settlement is handled by the platform/ops)

**Scenario 4 — Driver can only retrieve her own trips**
- Given a driver requests the payment status of a trip she did not drive
- Then the request is rejected as not found or not authorized

**Scenario 5 — Unauthenticated request is rejected**
- Given a request without a valid session token
- Then it is rejected

### Out of Scope
- Card charge processing itself (#1733)
- Refunds
- Cash settlement workflow (admin)

### Dependencies
- #1733 — Rider completes online card payment at trip end (API — must be live)
- #1637 — Completed trip is served with fare breakdown

## [Mobile] #1732 — Rider selects a payment method
**Orig. feature:** Payments / Mobile (#1768) · **ADO:** Removed · **Pts:** 3

**Description:** As a rider, I want to select my preferred payment method before booking a ride so that I and the driver both know how the fare will be settled at the end of the trip.

### Background

A payment method selector is shown on the home screen between the fare estimate and the "Request Ride" button. The available options for this sprint are Cash and Card (online payment). The default is Cash unless the rider has a saved preference. The selected method is included in the trip request payload via #1730 and is visible to the driver on the active trip screen. The payment method cannot be changed after the trip request is submitted.

### Acceptance Criteria

**Scenario 1 — Rider selects Cash**
- Given the rider is on the home screen with a pickup and destination set
- When she selects "Cash" as her payment method
- Then "Cash" is highlighted as the selected option
- And the fare estimate area shows "الدفع نقداً" / "Pay with Cash"

**Scenario 2 — Rider selects Card (online payment)**
- Given the rider selects "Card" as her payment method
- Then "Card" is highlighted as the selected option
- And the fare estimate area shows the estimated charge amount

**Scenario 3 — Default is Cash for a new rider**
- Given the rider has never selected a payment method before
- When she opens the home screen
- Then "Cash" is pre-selected by default

**Scenario 4 — Last used method is pre-selected on return**
- Given the rider previously used Card for her last trip
- When she opens the home screen for a new booking
- Then "Card" is pre-selected

**Scenario 5 — Selected method is passed with trip request**
- Given the rider has selected a payment method and taps "Request Ride"
- Then the selected payment method is included in the trip request payload sent via #1730

### Out of Scope
- Card details entry or saved card management (handled separately)
- Wallet top-up
- Payment method change after trip submission
- Promo codes

### Dependencies
- #1730 — Rider selects payment method for trip (API — must be live)
- #1552 — Rider sees fare estimate before requesting (must be built)

## [Mobile] #1734 — Rider completes online card payment at trip end
**Orig. feature:** Payments / Mobile (#1768) · **ADO:** Removed · **Pts:** —

**Description:** As a rider, I want to be charged automatically via my card at the end of a trip so that I do not need to carry cash.

### Background

When the trip's payment method is Card, the trip-complete screen shows a payment processing state before the usual trip summary and rating prompt. The payment is charged automatically via #1733. If payment succeeds, the rider sees the charged amount and a receipt note. If payment fails, the rider is offered a Retry option and a "Pay Cash to Driver" fallback.

### Acceptance Criteria

**Scenario 1 — Card payment processes successfully**
- Given the trip ends and the payment method is Card
- When the trip-complete screen loads
- Then a payment processing indicator is shown briefly
- And on success, the trip summary is shown with the charged amount
- And a receipt confirmation is shown to the rider
- And the driver is notified that payment was received

**Scenario 2 — Card payment fails — rider retries**
- Given the card payment fails
- When the rider taps "Retry Payment"
- Then the payment is attempted again via #1733
- And on success, the normal completion flow continues

**Scenario 3 — Card payment fails — rider switches to cash**
- Given the card payment fails after retry
- When the rider taps "Pay Cash to Driver"
- Then the trip is marked as cash-settled
- And the driver is notified to collect cash
- And the rider sees the cash amount to hand over

**Scenario 4 — Cash trip skips card payment screen**
- Given the trip's payment method is Cash
- When the trip-complete screen loads
- Then no payment processing state is shown
- And the cash fare amount to hand to the driver is displayed

### Out of Scope
- Card details entry (card is pre-saved separately)
- Partial payments
- Refunds

### Dependencies
- #1733 — Trip fare is charged to rider's card at trip completion (API — must be live)
- #1564 — Rider sees trip summary with cash fare (must be built)

## [Mobile] #1789 — Driver sees digital payment status at trip end
**Orig. feature:** Trip Completion & Cash Payment / Mobile-Driver (#1543) · **ADO:** Removed · **Pts:** —

**Description:** As a driver, I want the trip-end screen to tell me when the rider paid by card so that I do not ask for cash on a card trip.

### Background

At trip completion the driver's screen reflects the rider's payment method, retrieved via #1782. For cash trips it shows the amount to collect; for card (digital) trips it shows a clear "paid by card — collect nothing" state with the digital payment status. Digital payment is part of Phase 1 scope. This complements #1592 (cash collection and return to available). All strings flow through data-i18n keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Cash trip shows the amount to collect**
- Given the completed trip's payment method is cash
- When the trip-end screen loads
- Then the cash amount to collect is displayed (per #1592)

**Scenario 2 — Card trip shows nothing to collect**
- Given the completed trip's payment method is card and the charge succeeded
- When the trip-end screen loads
- Then a bilingual "paid by card — collect nothing" state is shown with the digital payment status

**Scenario 3 — Card trip with pending or failed payment**
- Given the completed trip's payment method is card and the charge is pending or failed
- When the trip-end screen loads
- Then the status is shown and the driver is not asked to collect cash

**Scenario 4 — Driver returns to available**
- Given the driver acknowledges the trip-end screen
- Then she returns to her available/home state

**Scenario 5 — Network error**
- Given the payment-status request fails
- Then a bilingual toast error is shown

### Out of Scope
- Card payment processing (#1733/#1734)
- Refunds
- Cash settlement workflow

### Dependencies
- #1782 — Driver retrieves payment method and collection status for a completed trip (API — must be live)
- #1592 — Driver sees cash fare to collect and returns to available

## [Mobile] #1793 — Rider with an unresolved payment failure is blocked from booking
**Orig. feature:** Payments / Mobile (#1768) · **ADO:** Removed · **Pts:** 3

**Description:** As a rider, I want to be told when a past payment failed and be guided to settle it so that I can book rides again.

### Background

If a previous card payment failed (#1734/#1733) and remains unresolved, the platform rejects new trip requests (#1784). When the rider taps Request Ride, she sees a clear, bilingual blocking message stating the outstanding amount and offering a path to settle it. Once the amount is settled, booking works again. All strings flow through data-i18n keys with Arabic fallback; transient errors use a toast.

### Acceptance Criteria

**Scenario 1 — Blocked rider is informed on booking**
- Given the rider has an unresolved payment failure
- When she taps Request Ride
- Then a bilingual message shows the outstanding amount and a way to settle it
- And no trip request is submitted

**Scenario 2 — Rider settles and can book**
- Given the rider settles the outstanding amount
- When she taps Request Ride again
- Then the booking proceeds normally

**Scenario 3 — Rider with no failure books normally**
- Given the rider has no unresolved payment failure
- When she taps Request Ride
- Then booking proceeds normally

**Scenario 4 — Network error**
- Given the eligibility check fails on the network
- Then a bilingual toast error is shown and she can retry

### Out of Scope
- The card charge flow itself (#1734/#1733)
- Refunds
- Operations manual override

### Dependencies
- #1784 — Booking is blocked when the rider has an unresolved payment failure (API — must be live)
- #1734 — Rider completes online card payment at trip end

## [Admin] #1815 — Super admin processes a manual refund
**Orig. feature:** Admin Financial Reporting & Reconciliation (#1803) · **ADO:** Removed · **Pts:** —

**Description:** As a super admin, I want to issue a manual refund against a completed trip so that I can resolve billing disputes and overcharges.

### Background

From a completed trip's detail (#1672) the super admin can issue a refund. For digital-paid trips she enters a refund amount (full or partial, not exceeding the amount charged) and a mandatory reason, then confirms; the refund is submitted to the PSP, the trip record is annotated, and the action is recorded in the audit log (#1816). Cash trips are refunded operationally (recorded as an offline refund, not PSP-processed).

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Refund amount | Yes | Decimal (EGP) | Positive number, up to 2 decimals; not more than the amount charged | 0.01 | amount charged | empty | Enter a refund amount / أدخل مبلغ الاسترداد | Enter a valid amount / أدخل مبلغًا صحيحًا | Amount must be greater than 0 and not exceed the amount charged / يجب أن يكون المبلغ أكبر من 0 وألا يتجاوز المبلغ المدفوع |
| Reason | Yes | Free text (textarea) | Any character | 10 chars | 500 chars | empty | Please enter a refund reason / يرجى إدخال سبب الاسترداد | — | Too short — please explain in more detail / السبب قصير جدًا، يرجى التوضيح بشكل أكثر تفصيلاً · Too long — must be ≤ 500 characters / يجب ألا يتجاوز السبب 500 حرف |

### Acceptance Criteria

**Scenario 1 — Full refund of a digital trip**
- Given a completed digital-paid trip
- When the super admin refunds the full amount with a reason
- Then the PSP refund is submitted and the trip is annotated with the refund

**Scenario 2 — Partial refund**
- Given a completed digital-paid trip
- When the super admin refunds part of the amount
- Then only that amount is refunded

**Scenario 3 — Amount cannot exceed amount charged**
- Given a refund amount greater than the amount charged
- Then a validation error is shown

**Scenario 4 — Reason is required**
- Given no reason is entered
- Then confirm is blocked

**Scenario 5 — PSP failure**
- Given the PSP is unavailable
- When the refund is submitted
- Then an error is shown, no refund is recorded, and the admin can retry

**Scenario 6 — Refund is visible and audited**
- Given a refund succeeds
- Then it is shown on the trip detail and recorded in the audit log (#1816)

**Scenario 7 — Cash trip**
- Given a completed cash trip
- When the super admin records a refund
- Then it is recorded as a manual/offline refund with no PSP call

### Out of Scope
- Automated or rule-based refunds
- Commission reversal logic (defined later)
- Full dispute case management

### Dependencies
- #1672 — Admin views completed trip with fare and rating
- #1759 — Platform commission
- Payments / PSP integration
- #1816 — Admin activity audit log

---

# Cluster C — Scheduled Rides

## [API] #1738 — Rider schedules a ride in advance
**Orig. feature:** Scheduled Rides API (#1777) · **ADO:** Removed · **Pts:** —

**Description:** As the rider app, I want to create, list, and cancel scheduled trip requests so that a rider can book a ride in advance and the platform can automatically dispatch it at the right time.

### Background

This covers the scheduled-trip endpoints. POST creates a scheduled trip from pickup, destination, scheduled_at, payment_method, and is_child_passenger; the platform validates that scheduled_at is at least 30 minutes ahead, no more than 7 days ahead, and within the configured daytime operating window (OD-001). GET returns the rider's upcoming scheduled trips. DELETE cancels a scheduled trip while it is still in "scheduled" status (before dispatch). A scheduler process runs continuously and, 15 minutes before each scheduled_at, transitions the scheduled trip into a live trip request via the standard creation path (#1629) and matching (#1630), notifying the rider. If no driver is found, standard no-driver handling (#1632) applies. All times are handled in Africa/Cairo local time. The lead time (30 minutes minimum ahead), horizon (7 days maximum ahead), and dispatch window (matching begins 15 minutes before scheduled_at) are final, confirmed product values.

### Field Validation
| Field | Required | Format | Rule |
|---|---|---|---|
| scheduled_at | Yes | ISO-8601 datetime | ≥ now + 30 min; ≤ now + 7 days; within operating window |
| pickup / destination | Yes | lat/lng | within defined service zones |
| payment_method | Yes | enum | "cash" or "card" (per #1730) |
| is_child_passenger | No | boolean | defaults to false (per #1783) |

### Acceptance Criteria

**Scenario 1 — POST: scheduled trip created successfully**
- Given an authenticated rider sends a valid scheduled-trip payload
- When the endpoint is called
- Then a scheduled trip is created with status = scheduled and fee = 0
- And the response returns the scheduled trip record

**Scenario 2 — POST: scheduled_at too soon**
- Given scheduled_at is less than 30 minutes ahead
- When the endpoint is called
- Then a validation error is returned and no scheduled trip is created

**Scenario 3 — POST: scheduled_at outside operating hours**
- Given scheduled_at falls outside the configured operating window (OD-001)
- When the endpoint is called
- Then a validation error is returned and no scheduled trip is created

**Scenario 4 — POST: scheduled_at beyond horizon**
- Given scheduled_at is more than 7 days ahead
- When the endpoint is called
- Then a validation error is returned and no scheduled trip is created

**Scenario 5 — GET: rider retrieves her upcoming scheduled trips**
- Given an authenticated rider has scheduled trips
- When she calls GET
- Then her upcoming scheduled trips are returned, soonest first

**Scenario 6 — DELETE: rider cancels a scheduled trip before dispatch**
- Given a scheduled trip is still in "scheduled" status
- When the rider sends DELETE for it
- Then the scheduled trip is cancelled with no fee

**Scenario 7 — Auto-dispatch at lead time**
- Given a scheduled trip reaches its dispatch window (15 minutes before scheduled_at) and the service is open
- When the scheduler runs
- Then it creates a live trip request via #1629 and enters matching via #1630
- And the rider is notified

**Scenario 8 — Auto-dispatch with no driver**
- Given a dispatched scheduled trip finds no driver within the matching window
- When matching ends
- Then no-driver handling (#1632) applies and the rider is notified

**Scenario 9 — Cancel after dispatch is rejected**
- Given a scheduled trip has already been dispatched into a live trip
- When the rider sends DELETE on the scheduled trip
- Then it is rejected and she is directed to the live trip cancellation flow (#1715)

**Scenario 10 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- When it targets any scheduled-trip endpoint
- Then the platform rejects the request via #1744

### Out of Scope
- Recurring scheduled trips
- Editing a scheduled trip in place (cancel + recreate)
- Scheduled-ride surge pricing
- Notification template content (handled by the notification service)

### Dependencies
- #1629 — Rider creates trip request (dispatch path)
- #1630 — Platform matches trip to nearest driver
- #1632 — No-driver handling
- #1730 — Rider selects payment method for trip
- #1783 — Trip request captures a per-trip child-passenger flag
- #1744 — Auth middleware validates session tokens
- OD-001 — Operating hours

## [Mobile] #1737 — Rider schedules a ride in advance
**Orig. feature:** Scheduled Rides / Mobile (#1770) · **ADO:** Removed · **Pts:** —

**Description:** As a rider, I want to schedule a ride for a future date and time within operating hours so that I can arrange transportation in advance and be matched with a driver automatically when the time approaches.

### Background

From the home screen the rider can switch from "Request now" to "Schedule for later". After setting pickup (#1550) and destination (#1551), she opens a date/time picker and chooses when she wants to be picked up. The scheduled pickup time must be at least 30 minutes ahead, no more than 7 days ahead, and fall inside the daytime operating window (OD-001; see #1791). She selects a payment method (#1732) and, if applicable, declares a child passenger (#1790). An indicative fare estimate (#1552) is shown but is recalculated at dispatch. On confirmation the scheduled trip is created via #1738 and appears in her "Scheduled rides" list, where she can review or cancel it before dispatch. Approximately 15 minutes before the scheduled pickup time the platform automatically begins matching (creating a live trip request and entering the matching flow #1554); the rider is notified by push when matching starts and again when a driver is found. Modifying a scheduled ride is done by cancelling and rebooking. The lead time (30 minutes minimum ahead), booking horizon (7 days maximum ahead), and dispatch window (matching begins 15 minutes before the scheduled pickup time) are final, confirmed product values. All user-visible strings flow through data-i18n keys with Arabic fallback.

### Field Validation
| Field | Required | Rule | Error (AR / EN) |
|---|---|---|---|
| Scheduled date & time | Yes | ≥ 30 min from now; ≤ 7 days ahead; within daytime operating hours (OD-001) | يجب اختيار وقت ضمن ساعات العمل وبعد 30 دقيقة على الأقل / Choose a time at least 30 minutes ahead and within operating hours |
| Pickup | Yes | Set via map/autocomplete (per #1550) | اختاري موقع الانطلاق / Choose a pickup |
| Destination | Yes | Set via map/autocomplete (per #1551) | اختاري وجهتك / Choose a destination |
| Payment method | Yes | Cash or Card (per #1732) | اختاري طريقة الدفع / Choose a payment method |

### Acceptance Criteria

**Scenario 1 — Rider schedules a ride successfully**
- Given the rider has set a valid pickup, destination, payment method, and a scheduled time that is ≥ 30 min ahead, ≤ 7 days ahead, and within operating hours
- When she taps "Schedule ride"
- Then the scheduled trip is created via #1738
- And it appears in her "Scheduled rides" list with its date, time, pickup, destination, and payment method

**Scenario 2 — Scheduled time is too soon**
- Given the rider selects a time less than 30 minutes from now
- When she confirms
- Then a bilingual validation error is shown and no scheduled trip is created

**Scenario 3 — Scheduled time is outside operating hours**
- Given the rider selects a time outside the daytime operating window (OD-001)
- When she confirms
- Then a bilingual message explains the service is closed at that time and suggests a time inside the window
- And no scheduled trip is created

**Scenario 4 — Scheduled time is beyond the booking horizon**
- Given the rider selects a time more than 7 days ahead
- When she confirms
- Then a bilingual validation error is shown and no scheduled trip is created

**Scenario 5 — Payment method and child declaration are carried into the scheduled trip**
- Given the rider selected a payment method (#1732) and optionally declared a child passenger (#1790)
- When the scheduled trip is created
- Then both are stored with the scheduled trip and applied when it is dispatched

**Scenario 6 — Rider views her upcoming scheduled rides**
- Given the rider has at least one upcoming scheduled ride
- When she opens the "Scheduled rides" list
- Then each entry shows the scheduled date/time, pickup, destination, and payment method, soonest first

**Scenario 7 — Rider cancels a scheduled ride before dispatch**
- Given a scheduled ride has not yet been dispatched
- When the rider cancels it and confirms
- Then it is removed from her scheduled rides via #1738 with no fee

**Scenario 8 — Platform auto-dispatches at lead time**
- Given a scheduled ride reaches its dispatch window (15 minutes before the scheduled pickup time) and the service is open
- When the platform dispatches it
- Then a live trip request is created and the matching flow (#1554) begins
- And the rider receives a push that matching has started, and again when a driver is found

**Scenario 9 — No driver available at dispatch**
- Given a scheduled ride is dispatched but no driver is found within the matching window
- Then standard no-driver handling applies and the rider is notified

**Scenario 10 — Network error during scheduling**
- Given the rider taps "Schedule ride"
- When the request fails
- Then a bilingual toast error is shown and she can retry
- And no duplicate scheduled trip is created

### Out of Scope
- Recurring / repeating scheduled rides
- Modifying a scheduled ride in place (cancel and rebook instead)
- Scheduled-ride-specific surge or pricing
- Guaranteed driver assignment at the exact scheduled minute

### Dependencies
- #1738 — Rider schedules a ride in advance (API — must be live)
- #1552 — Rider sees fare estimate before requesting (indicative estimate)
- #1732 — Rider selects a payment method
- #1790 — Rider declares the passenger is a child (optional, per trip)
- #1791 — Rider cannot book outside operating hours / OD-001
- #1554 — Rider sees matching screen (reused at dispatch)

---

# Cluster D — Overlapping-zone fare resolution

## [API] #1829 — Fare engine resolves overlapping service zones to the smallest zone
**Orig. feature:** Fare Estimate API (#1601) · **ADO:** Removed · **Pts:** —

**Description:** As the fare service, I want to deterministically pick the smallest (most specific) zone when pickup coordinates fall inside more than one overlapping zone, so that fares are always priced from the correct rate card.

### Background

Service zones may overlap. When pickup coordinates fall inside two or more overlapping zones, the engine must deterministically select the smallest-area (most specific) zone and use its rate card. This extends the fare-calculation engine (#1628), which handles single-zone resolution, the outside-all-zones block, and the missing-rate-card (Inactive zone) case. A zone is Inactive when it has no rate card; an Inactive zone never accepts trips, even if a larger Active zone also covers the same point (there is no fallback).

### Acceptance Criteria

**Scenario 1 — Two overlapping zones**
- Given pickup coordinates that fall inside exactly two overlapping zones
- When the engine resolves the zone
- Then the smaller-area zone is selected and its rate card is used

**Scenario 2 — Nested or multiple overlapping zones**
- Given pickup coordinates that fall inside three or more overlapping (e.g. nested) zones
- Then the smallest-area zone among all matches is selected

**Scenario 3 — Equal-area tie-break is deterministic**
- Given two or more candidate zones have the same area
- When the engine must choose between them
- Then it applies a deterministic tie-break (the most recently created zone wins) so the same coordinates always resolve to the same zone

**Scenario 4 — Selected zone drives the fare**
- Given the smallest overlapping zone has been selected
- Then its rate card is handed to the fare-calculation engine (#1628) for the fare computation

**Scenario 5 — No overlap is unaffected**
- Given pickup coordinates that fall inside exactly one zone (no overlap)
- Then resolution follows the single-zone path in #1628 and this logic does not alter the result

**Scenario 6 — Smallest matching zone is Inactive**
- Given the smallest-area matching zone has no rate card (Inactive)
- When the engine resolves the zone
- Then the trip is blocked via #1628 (ZONE_RATE_CARD_MISSING) and the engine does not fall through to a larger Active zone covering the same point

### Out of Scope
- Preventing or warning about zone overlap at admin configuration time (#1756)
- The fare formula and minimum-fare enforcement (#1628)

### Dependencies
- #1628 — Fare calculation engine (single-zone resolution and fare computation)
- #1756 — Super admin creates a service zone
- #1757 — Super admin configures zone rate card (drives Active/Inactive status)
