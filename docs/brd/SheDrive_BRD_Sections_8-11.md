# SheDrive – BRD Sections 8 and 11

**Project:** SheDrive
**Document:** Sections 8 and 11 (to be combined with `SheDrive_BRD_Draft_v0.2.md` and `SheDrive_BRD_Sections_6-7.md`)
**Version:** 0.1 (Draft)
**Status:** Draft for Review

---

# 8. Business Rules

This section consolidates the platform's enforceable business rules. Each rule is expressed as a single, testable statement and is assigned a unique identifier (e.g., `BR-EL-01`) for cross-reference and traceability.

Rules marked **[TBD — Operations to confirm]** require explicit decision and approval by the relevant stakeholder before the document can be baselined as v1.0.

## 8.1 Eligibility & Identity Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-EL-01   | Only female users are permitted to register and operate as Riders or Drivers on the platform.                                                                       | Approved |
| BR-EL-02   | All users must be at least 18 years of age. The system rejects registrations of users under 18.                                                                     | Approved |
| BR-EL-03   | Riders must complete identity verification (national ID submission, live selfie, age check, gender check) before completing their first trip.                       | Approved |
| BR-EL-04   | Drivers must complete identity verification, valid driving license validation, vehicle document verification, and a successful background check before activation.  | Approved |
| BR-EL-05   | The platform enforces gender by extracting the gender field from the submitted national ID. Manual override of gender determination is not permitted.               | Approved |
| BR-EL-06   | A national ID number may be associated with only one active platform account. Duplicate registrations are blocked.                                                  | Approved |
| BR-EL-07   | A mobile phone number may be associated with only one active platform account at a time.                                                                            | Approved |
| BR-EL-08   | A user whose identity verification is rejected may resubmit verification a maximum of [TBD — Operations to confirm: e.g., 3] times before account suspension.       | TBD    |
| BR-EL-09   | A national ID with face-match confidence below the configured threshold is routed to manual review rather than auto-rejected.                                        | Approved |
| BR-EL-10   | The face-match confidence threshold for automatic approval is [TBD — Operations / Compliance to confirm with vendor].                                                | TBD    |
| BR-EL-11   | Identity verification status is permanently recorded against the user account and is not silently re-runnable without re-submission.                                | Approved |

## 8.2 Child Ride Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-CH-01   | Children under 12 may travel only when accompanied by a verified adult Rider. The platform does not support unaccompanied minor rides.                              | Approved |
| BR-CH-02   | Riders must declare child accompaniment (number of children and approximate ages) at the time of ride request. Undeclared child accompaniment is a policy violation. | Approved |
| BR-CH-03   | The maximum number of children per trip is [TBD — Operations to confirm, e.g., 2].                                                                                  | TBD    |
| BR-CH-04   | Total passengers per trip (Rider plus declared children) shall not exceed the seating capacity declared for the assigned vehicle, less the Driver.                  | Approved |
| BR-CH-05   | Driver acceptance of a ride implies acceptance of the declared child accompaniment. A Driver may decline a request based on child information at the request stage. | Approved |
| BR-CH-06   | Drivers may not transport additional children beyond those declared at booking. Discrepancies are subject to operational review and possible policy enforcement.    | Approved |
| BR-CH-07   | The platform recommends but does not enforce the use of child safety seats. The Rider is responsible for compliance with applicable Egyptian regulations.            | Approved |

## 8.3 Pricing Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-PR-01   | Trip fare is calculated as: base fare + (distance × per-km rate) + (duration × per-minute rate), subject to a minimum fare floor.                                   | Approved |
| BR-PR-02   | All fare components (base, per-km, per-minute, minimum fare) are configured per neighborhood zone of trip origin.                                                   | Approved |
| BR-PR-03   | If a trip starts in Zone A and ends in Zone B, the system shall apply the rules configured for the zone of origin (Zone A), unless a Zone-A-to-Zone-B specific rule exists. | Approved |
| BR-PR-04   | The estimated fare displayed to the Rider before booking is non-binding. The final fare is calculated on trip completion based on actual distance and duration.     | Approved |
| BR-PR-05   | The final fare shall not exceed the estimated fare by more than [TBD — Operations to confirm, e.g., 25%] without operational notification, except in cases of route deviation requested by the Rider. | TBD    |
| BR-PR-06   | Pricing rule changes are applied prospectively only. Trips already in progress at the time of a pricing change use the rules in effect at the time of trip start.    | Approved |
| BR-PR-07   | All pricing rule changes are versioned with effective date and the identity of the Administrator making the change.                                                  | Approved |
| BR-PR-08   | Peak-hour multipliers, where configured, are applied transparently and shown in the fare estimate before the Rider confirms the ride request.                       | Approved |

## 8.4 Cancellation Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-CA-01   | A ride may be cancelled by either party at any point prior to trip completion.                                                                                       | Approved |
| BR-CA-02   | A cancellation reason is mandatory and must be selected from a predefined list configured by Administrators.                                                        | Approved |
| BR-CA-03   | A free cancellation window of [TBD — Operations to confirm, e.g., 2 minutes] applies after Driver assignment, during which no cancellation fee is charged.           | TBD    |
| BR-CA-04   | Cancellation by a Rider after the free window incurs a cancellation fee of [TBD — Operations to confirm, e.g., 15 EGP] charged via the active payment method.        | TBD    |
| BR-CA-05   | Cancellation by a Driver after the free window does not result in a fee to the Rider but is recorded against the Driver's performance metrics.                       | Approved |
| BR-CA-06   | If a Driver fails to arrive at the pickup location within [TBD — Operations to confirm, e.g., 10 minutes] of confirming the assignment, the Rider may cancel without a fee. | TBD    |
| BR-CA-07   | A Driver who exceeds [TBD — Operations to confirm, e.g., 3] cancellations within a 24-hour period is flagged for operational review.                                | TBD    |
| BR-CA-08   | A Rider who exceeds [TBD — Operations to confirm, e.g., 5] cancellations within a 7-day period is flagged for operational review and may be temporarily restricted. | TBD    |
| BR-CA-09   | All cancellation events are logged with reason, timestamp, initiating party, and trip stage.                                                                         | Approved |
| BR-CA-10   | Cancellation fees applied to digital trips are processed automatically through the PSP. Cancellation fees applied to cash trips accumulate to the Rider's account and must be settled before the next ride. | Approved |

## 8.5 Payment & Refund Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-PY-01   | The platform supports two payment methods: cash and digital (card via the configured PSP). Wallets and other methods are out of scope for the MVP.                  | Approved |
| BR-PY-02   | The Rider selects the payment method at the time of ride request. Mid-trip change of payment method is not supported.                                                | Approved |
| BR-PY-03   | For digital payments, the system pre-authorises the estimated fare on trip start and captures the actual fare on trip completion.                                    | Approved |
| BR-PY-04   | If digital payment authorisation fails at trip start, the trip cannot start. The Rider is prompted to retry or change payment method.                                | Approved |
| BR-PY-05   | If digital payment capture fails at trip completion, the trip is marked with a failed payment status and the Rider is restricted from booking further trips until resolved. | Approved |
| BR-PY-06   | A failed digital payment may be retried up to [TBD — Operations to confirm, e.g., 3] times by the Rider before requiring operational intervention.                  | TBD    |
| BR-PY-07   | Cash payments are recorded based on dual confirmation by both Rider and Driver. Discrepancies in confirmation are routed to operational review.                       | Approved |
| BR-PY-08   | Refunds, where applicable, are processed manually by authorised back-office users. Automated refunds are out of scope for the MVP.                                   | Approved |
| BR-PY-09   | All refunds are recorded with reason, amount, initiating Administrator, and PSP transaction reference (where applicable).                                            | Approved |
| BR-PY-10   | Receipts are generated and made available in-app for every completed trip, regardless of payment method.                                                              | Approved |

## 8.6 Cash Handling & Settlement Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-CS-01   | For each cash trip, the Driver collects the full fare from the Rider in cash.                                                                                        | Approved |
| BR-CS-02   | The platform's commission portion of every cash trip accrues to the Driver's "cash owed to platform" balance.                                                        | Approved |
| BR-CS-03   | Drivers must settle their outstanding cash owed to the platform when the balance reaches [TBD — Operations to confirm, e.g., 500 EGP] or after [TBD — e.g., 7] days, whichever occurs first. | TBD    |
| BR-CS-04   | A Driver whose outstanding cash balance exceeds the threshold and remains unsettled beyond a defined grace period is automatically restricted from accepting new rides until settlement. | Approved |
| BR-CS-05   | Cash settlement methods are operationally managed (bank deposit, in-person collection, etc.) and the platform records each settlement event with date, amount, and confirmation. | Approved |
| BR-CS-06   | Discrepancies between the Driver's recorded cash balance and the settlement amount received are flagged for finance review.                                          | Approved |
| BR-CS-07   | The Driver's earnings dashboard always reflects net earnings after platform commission, regardless of payment method.                                                | Approved |

## 8.7 Driver Onboarding & Approval Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-DO-01   | A Driver application progresses through the stages: registration → documents submitted → under review → approved or rejected.                                       | Approved |
| BR-DO-02   | A Driver may begin using the Driver App for non-trip functions immediately after registration but cannot accept ride requests until the application is approved.   | Approved |
| BR-DO-03   | All required documents (national ID, driving license, vehicle registration, valid insurance, vehicle photos) must be submitted before the application enters review. | Approved |
| BR-DO-04   | Driver approval requires successful identity verification, license validation, vehicle document verification, vehicle eligibility check, and background check clearance. | Approved |
| BR-DO-05   | A Driver application may be rejected with a documented reason. The Driver is informed of the reason and may resubmit corrected documents.                            | Approved |
| BR-DO-06   | Vehicle eligibility criteria are: maximum vehicle age of [TBD — Operations to confirm, e.g., 8 years]; accepted vehicle types include [TBD — Operations to confirm, e.g., 4-door sedans and SUVs]; vehicle must be in roadworthy condition with current registration and valid insurance. | TBD    |
| BR-DO-07   | A Driver's driving license must be currently valid and not expired at the time of approval. The system tracks license expiry and alerts the Driver before expiry.    | Approved |
| BR-DO-08   | A Driver's insurance must be currently valid throughout the period of platform participation. Lapsed insurance results in automatic Driver suspension until renewal evidence is provided. | Approved |
| BR-DO-09   | Background check requirements include criminal record review and traffic violation history. The acceptance criteria are defined by the background check provider in agreement with Compliance. | Approved |
| BR-DO-10   | A Driver may operate only the vehicle whose documents are on file. Use of an unregistered vehicle is a policy violation.                                              | Approved |
| BR-DO-11   | A Driver may register an additional vehicle by submitting full vehicle documents for that vehicle. Each registered vehicle is subject to independent eligibility verification. | Approved |

## 8.8 Commission Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-CM-01   | The platform retains a commission of [TBD — Operations / Finance to confirm, e.g., 20%] of the trip fare for every completed trip.                                  | TBD    |
| BR-CM-02   | Commission is calculated on the final trip fare exclusive of any cancellation fees.                                                                                  | Approved |
| BR-CM-03   | Commission is configurable globally and may be overridden per neighborhood zone. Zone-specific commission overrides take precedence over the global rate.            | Approved |
| BR-CM-04   | Commission rate changes are applied prospectively only. Trips already started use the commission rate in effect at the time of trip start.                           | Approved |
| BR-CM-05   | For digital trips, the Driver receives the trip fare net of platform commission via the operational settlement process (out of scope for MVP system automation).    | Approved |
| BR-CM-06   | For cash trips, the Driver retains the full fare collected from the Rider, and the platform's commission accrues to the Driver's "cash owed to platform" balance.   | Approved |
| BR-CM-07   | All commission calculations are recorded against each trip and made available for finance reconciliation.                                                            | Approved |

## 8.9 Safety & SOS Response Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-SF-01   | The SOS feature is available to Riders and Drivers during any active trip and is disabled outside of an active trip.                                                | Approved |
| BR-SF-02   | Activation of SOS triggers automatic capture of location, trip identifier, and the relevant Rider and Driver details, which are sent to the Operations SOS queue.   | Approved |
| BR-SF-03   | The Operations team must acknowledge an SOS alert within [TBD — Operations to confirm, e.g., 60 seconds] of receipt. SLA breach triggers an automatic escalation.   | TBD    |
| BR-SF-04   | Unacknowledged SOS alerts are escalated to the Operations Supervisor after [TBD — Operations to confirm, e.g., 2 minutes] and to the on-call senior responder after [TBD — e.g., 5 minutes]. | TBD    |
| BR-SF-05   | The Operations team may, at its discretion, contact external authorities (police, emergency services) following the defined escalation script.                       | Approved |
| BR-SF-06   | All SOS activations create a permanent incident record, regardless of resolution outcome (resolved, false alarm, or escalated).                                      | Approved |
| BR-SF-07   | An SOS-triggered trip is monitored by Operations until safe completion or appropriate intervention. The trip lifecycle is not auto-completed during an active SOS.   | Approved |
| BR-SF-08   | Multiple SOS activations against the same Rider or Driver within a defined period trigger automatic operational review.                                              | Approved |
| BR-SF-09   | Riders may share their live trip status with Trusted Contacts at any time during an active trip, regardless of whether SOS is active.                                | Approved |
| BR-SF-10   | The platform retains the right to suspend or remove any user whose account is associated with a substantiated safety incident, in accordance with the platform's safety policy. | Approved |

## 8.10 Notification Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-NT-01   | One-time passwords (OTPs) and authentication-related notifications are delivered via SMS only.                                                                       | Approved |
| BR-NT-02   | Ride lifecycle notifications (Driver assigned, Driver arrived, trip started, trip completed) are delivered via push notification, with SMS fallback when push delivery fails. | Approved |
| BR-NT-03   | Payment-related notifications (success, failure, refund) are delivered via push and in-app notification.                                                              | Approved |
| BR-NT-04   | Safety-related notifications, including SOS confirmations and live trip share alerts, are treated as critical and bypass user-level notification preferences and device Do Not Disturb settings. | Approved |
| BR-NT-05   | Administrative notifications (driver onboarding pending, payment failure alerts, daily summaries) are delivered via email to authorised back-office recipients.       | Approved |
| BR-NT-06   | Notifications are delivered in the user's selected application language (Arabic or English).                                                                          | Approved |
| BR-NT-07   | OTP messages are valid for [TBD — Operations to confirm, e.g., 5 minutes] from the time of issuance and may be requested up to [TBD — e.g., 3] times within a defined window before account-level rate limits apply. | TBD    |
| BR-NT-08   | All outbound notifications are recorded with channel, delivery status, and timestamp for operational and audit review.                                                | Approved |
| BR-NT-09   | Users may, at their discretion, opt out of non-critical notifications (e.g., promotional, summary) but cannot opt out of safety, ride lifecycle, or payment notifications. | Approved |

## 8.11 Operating Hours Rules

| ID         | Rule                                                                                                                                                                | Status |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| BR-OH-01   | The platform operates within a defined daytime-only window during the MVP. Specific operating hours are [TBD — Operations to confirm, e.g., 06:00 to 22:00 local Egyptian time]. | TBD    |
| BR-OH-02   | New ride requests are not accepted outside the operating window. The Rider App displays a clear notification indicating that booking is unavailable.                 | Approved |
| BR-OH-03   | Trips already in progress at the end of the operating window proceed to completion. The Trip & Dispatch Engine does not interrupt active trips on cutoff.            | Approved |
| BR-OH-04   | Drivers may set themselves online only within the operating window. Drivers attempting to go online outside the window are presented with an informational message.  | Approved |
| BR-OH-05   | Operating hours apply uniformly across all neighborhood zones during the MVP. Zone-specific operating hours are not supported in the MVP.                            | Approved |
| BR-OH-06   | A defined "wind-down" period before end-of-window during which new ride requests may be restricted to short-range trips is [TBD — Operations to confirm whether this is required]. | TBD    |

---

# 11. Non-Functional Business Requirements

This section defines non-functional expectations expressed at a business level. Technical realisation, including specific architectural and infrastructure approaches, is addressed in the High-Level Design document.

## 11.1 Availability Expectations

| ID         | Requirement                                                                                                                                                          |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NF-AV-01   | The platform shall be available during 100% of the configured operating hours, targeting a service availability of [TBD — Operations to confirm, e.g., 99.5%] measured monthly during the operating window. |
| NF-AV-02   | Planned maintenance shall be scheduled outside the operating window wherever possible, with advance notice to users.                                                  |
| NF-AV-03   | Unplanned outages affecting safety features (SOS, live trip sharing) shall be treated as severity-1 incidents with the highest operational priority for resolution.   |
| NF-AV-04   | The Admin & Operations Portal shall be available 24/7 to support back-office work outside the public operating window.                                                |
| NF-AV-05   | External provider unavailability (PSP, identity verification, maps, notifications, background check) shall not bring down core platform functions; degraded operation modes shall be defined for each. |

## 11.2 Performance Expectations

| ID         | Requirement                                                                                                                                                          |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NF-PF-01   | The Rider App shall display the fare estimate and present available drivers within a duration that feels immediate to a typical user (target: under [TBD — e.g., 3 seconds] under normal load). |
| NF-PF-02   | Driver matching shall complete within a duration that does not noticeably degrade the user experience (target: under [TBD — e.g., 30 seconds] under normal load).     |
| NF-PF-03   | SOS alerts shall be delivered to the Operations queue within [TBD — Operations to confirm, e.g., 5 seconds] of activation under normal load.                          |
| NF-PF-04   | Real-time location updates shall be delivered to the Rider App with a perceived latency consistent with industry-standard ride-hailing experiences.                   |
| NF-PF-05   | The platform shall support concurrent active rides and online drivers consistent with the projected MVP load envelope, defined in HLD.                                |
| NF-PF-06   | Payment processing latency (digital) shall not visibly delay the trip completion experience under normal PSP performance conditions.                                  |

## 11.3 Localization (Arabic / English, RTL)

| ID         | Requirement                                                                                                                                                          |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NF-LO-01   | The platform shall support Arabic and English as user-facing languages from launch.                                                                                   |
| NF-LO-02   | Arabic shall be the default language for end users in Egypt, with full right-to-left layout, typography, and component mirroring across the Rider and Driver apps.    |
| NF-LO-03   | All user-facing copy, including notifications, error messages, button labels, and static content, shall be available in both languages.                              |
| NF-LO-04   | Date formats, time formats, currency formatting (Egyptian Pound), and number formatting shall reflect locale conventions.                                            |
| NF-LO-05   | The Admin & Operations Portal shall support English as its primary language. Arabic support for the portal is out of scope for the MVP.                              |
| NF-LO-06   | Language switching within the apps shall be available without requiring re-login or app restart.                                                                      |
| NF-LO-07   | Notification templates shall be maintained in both languages, with the appropriate language selected based on the user's app preference.                             |

## 11.4 Accessibility

| ID         | Requirement                                                                                                                                                          |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NF-AC-01   | The Rider App and Driver App shall meet a baseline of accessible design, targeting compliance with WCAG 2.1 Level AA where applicable to mobile applications.        |
| NF-AC-02   | Visual elements shall provide sufficient colour contrast, font sizing, and tap-target sizing to support users with mild visual or motor impairments.                  |
| NF-AC-03   | Critical user flows (registration, identity verification, booking, SOS) shall be operable without reliance on colour alone.                                          |
| NF-AC-04   | The apps shall be usable with the device's native screen reader (VoiceOver / TalkBack) for primary flows, including ride request, ride status, and SOS activation.    |
| NF-AC-05   | The platform shall support standard system-level accessibility features available on iOS and Android (text resizing, dynamic type, high contrast modes).             |

## 11.5 Security Expectations (Business Level)

| ID         | Requirement                                                                                                                                                          |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NF-SE-01   | Personal and identity data shall be protected against unauthorised access in storage and in transit, in accordance with applicable Egyptian data protection requirements. |
| NF-SE-02   | Card data shall not be stored by the platform. Card information shall be tokenised by the PSP, with the platform retaining only the resulting tokens.                |
| NF-SE-03   | Administrator access to sensitive data and actions shall require two-factor authentication and role-based access control.                                            |
| NF-SE-04   | All sensitive administrative actions (account approvals, suspensions, refunds, configuration changes) shall be recorded in an immutable audit log.                    |
| NF-SE-05   | User passwords, where applicable, shall be stored using industry-standard one-way hashing methods.                                                                    |
| NF-SE-06   | The platform shall implement reasonable rate limiting and abuse prevention on registration, OTP requests, login, and payment retry endpoints.                        |
| NF-SE-07   | Personal mobile phone numbers of Riders and Drivers shall not be exposed to the other party. In-trip communication shall be mediated via masked numbers and in-app chat. |
| NF-SE-08   | The platform shall support a defined process for users to request account deletion, with deletion handled in accordance with applicable retention obligations.        |
| NF-SE-09   | Biometric data submitted during identity verification shall be retained only as required for verification and audit purposes, in accordance with applicable regulations. |
| NF-SE-10   | All third-party providers (PSP, identity verification, maps, notifications, background check) shall be engaged under contractual terms that include data protection obligations consistent with the platform's standards. |

---

*End of Sections 8 and 11.*

*To be combined with `SheDrive_BRD_Draft_v0.2.md` (sections 1–5) and `SheDrive_BRD_Sections_6-7.md` (sections 6–7) to produce the consolidated BRD.*

---

## Open Items Summary (TBD List)

The following 19 items in §8 and §11 require Operations, Compliance, or Finance confirmation before the document can be baselined:

| Reference | Decision Required                                                                                            | Owner             |
|-----------|--------------------------------------------------------------------------------------------------------------|-------------------|
| BR-EL-08  | Maximum identity-verification resubmission attempts                                                           | Operations        |
| BR-EL-10  | Face-match confidence threshold                                                                               | Operations / Compliance |
| BR-CH-03  | Maximum number of children per trip                                                                           | Operations        |
| BR-PR-05  | Acceptable variance between estimated and final fare                                                          | Operations        |
| BR-CA-03  | Free cancellation window duration                                                                             | Operations        |
| BR-CA-04  | Rider cancellation fee amount                                                                                 | Operations / Finance |
| BR-CA-06  | Driver no-show timeout                                                                                        | Operations        |
| BR-CA-07  | Driver cancellation threshold for review                                                                      | Operations        |
| BR-CA-08  | Rider cancellation threshold for review                                                                       | Operations        |
| BR-PY-06  | Maximum digital payment retry attempts                                                                        | Operations        |
| BR-CS-03  | Cash settlement threshold (amount and timing)                                                                 | Operations / Finance |
| BR-DO-06  | Vehicle eligibility criteria (age, type, condition specifics)                                                 | Operations        |
| BR-CM-01  | Platform commission percentage                                                                                | Finance           |
| BR-SF-03  | SOS acknowledgement SLA                                                                                       | Operations        |
| BR-SF-04  | SOS escalation thresholds                                                                                     | Operations        |
| BR-NT-07  | OTP validity and resend limits                                                                                | Operations        |
| BR-OH-01  | Specific daytime operating hours                                                                              | Operations        |
| BR-OH-06  | Wind-down period requirement                                                                                  | Operations        |
| NF-AV-01  | Service availability target percentage                                                                        | Operations / Engineering |
| NF-PF-01–04 | Specific performance latency targets                                                                        | Operations / Engineering |
