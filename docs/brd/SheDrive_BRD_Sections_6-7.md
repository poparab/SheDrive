# SheDrive – BRD Sections 6 and 7

**Project:** SheDrive
**Document:** Sections 6 and 7 (to be combined with `SheDrive_BRD_Draft_v0.2.md`)
**Version:** 0.1 (Draft)
**Status:** Draft for Review

---

# 6. Solution Overview (Module Architecture)

## 6.1 Module Map

The SheDrive platform is structured around ten business modules organised into three logical layers:

**User-Facing Surfaces** — applications that platform users interact with directly:

- Rider App
- Driver App
- Admin & Operations Portal

**Domain Capabilities** — the business and operational engines that power user actions:

- Identity & Verification
- Payments (Cash + Digital)
- Trip & Dispatch Engine
- Pricing & Neighborhood Zones
- Safety & SOS

**Cross-Cutting Capabilities** — services that support all modules:

- Notifications
- Reporting & Analytics

| #   | Module                          | Layer                     | Primary Users                              |
|-----|---------------------------------|---------------------------|--------------------------------------------|
| 1   | Rider App                       | User-Facing Surface       | Female Riders                              |
| 2   | Driver App                      | User-Facing Surface       | Female Drivers                             |
| 3   | Admin & Operations Portal       | User-Facing Surface       | Administrators, Operations, Support, Finance, Compliance |
| 4   | Identity & Verification         | Domain Capability         | Riders, Drivers (during onboarding)        |
| 5   | Payments (Cash + Digital)       | Domain Capability         | Riders, Drivers, Finance                   |
| 6   | Trip & Dispatch Engine          | Domain Capability         | Riders, Drivers (system-driven)            |
| 7   | Pricing & Neighborhood Zones    | Domain Capability         | Administrators (configuration)             |
| 8   | Safety & SOS                    | Domain Capability         | Riders, Drivers, Operations                |
| 9   | Notifications                   | Cross-Cutting Capability  | All users                                   |
| 10  | Reporting & Analytics           | Cross-Cutting Capability  | Operations, Management                     |

## 6.2 Module Summaries

### 6.2.1 Rider App

The Rider App is the primary touchpoint for female riders, providing a complete journey from account registration through identity verification, ride booking, real-time tracking, in-trip communication, payment, feedback, and access to safety features. The app supports child accompaniment declaration, trusted contacts setup, and live trip sharing — all positioned around the platform's safety-first promise.

The Rider App interacts with Identity & Verification during onboarding, with the Trip & Dispatch Engine during the ride lifecycle, with Payments during fare settlement, with Safety & SOS during emergencies, and with Notifications throughout for real-time updates.

### 6.2.2 Driver App

The Driver App enables verified female drivers to manage their availability, accept and execute rides using their own vehicles, navigate to pickups and destinations, confirm cash collection, view earnings, and access safety features. The app guides drivers through a structured onboarding process — identity verification, driving license validation, vehicle document submission, vehicle photo upload, and background check — before activation.

The Driver App interacts with the Trip & Dispatch Engine for ride lifecycle, with Payments for commission and cash balance tracking, with Safety & SOS during emergencies, and with Notifications for ride and operational alerts.

### 6.2.3 Admin & Operations Portal

The Admin & Operations Portal is the back-office hub for managing the platform's daily operations. It provides differentiated access to Operations, Customer Support, Finance, and Compliance teams via role-based permissions. The portal supports driver onboarding approvals, rider and driver account management, live ride monitoring, cancellation and incident handling, SOS response, pricing and zone configuration, cash reconciliation, refunds, and audit oversight.

The Admin & Operations Portal depends on every other module for the data and operations it surfaces, and is the primary control surface for enforcing platform-wide business rules.

### 6.2.4 Identity & Verification

The Identity & Verification module is the platform's gatekeeper. It validates user identity through national ID OCR, liveness-detected selfie capture, face matching against the ID, age and gender eligibility checks, and — for drivers — driving license and vehicle document verification along with background checks. The module enforces the platform's women-only and age-eligibility rules and routes edge cases to a manual review queue.

The Identity & Verification module serves both the Rider and Driver Apps during onboarding and is governed by the Admin & Operations Portal for review and approval workflows.

### 6.2.5 Payments (Cash + Digital)

The Payments module handles all financial flows on the platform, supporting both cash and digital rails from launch. It integrates with a single Payment Service Provider for digital card transactions, manages card tokenisation and saved cards, authorises and captures fares, and records cash payments through dual rider/driver confirmation. It maintains driver cash ledgers, calculates commission, supports cash settlement workflows, processes manual refunds, and generates receipts.

The Payments module interacts closely with the Trip & Dispatch Engine for fare triggers and with the Admin & Operations Portal for reconciliation and dispute handling.

### 6.2.6 Trip & Dispatch Engine

The Trip & Dispatch Engine is the matching and lifecycle core of the platform. It receives ride requests from the Rider App, filters candidate drivers based on availability, working zone, and rating, broadcasts requests within a defined timeout, handles acceptance with atomic locking, and reassigns on decline or timeout. The engine maintains the trip state machine, streams driver location during active trips, calculates ETAs, and detects pickup and drop-off geofences.

The Trip & Dispatch Engine is central to the platform — every active ride flows through this module — and connects to Pricing for fare logic, to Payments for trigger events, to Notifications for status updates, and to Safety & SOS during emergencies.

### 6.2.7 Pricing & Neighborhood Zones

The Pricing & Neighborhood Zones module enables the platform to configure pricing at the granularity of individual neighborhoods within Greater Cairo. Administrators define zones as map polygons and configure base fare, per-kilometre and per-minute rates, minimum fare, zone-to-zone rules, and cancellation fees per zone. The module supports versioning of pricing rule changes for audit and rollback, and provides hooks for future peak-hour multipliers.

The Pricing & Neighborhood Zones module is consumed by the Trip & Dispatch Engine during fare estimation, by the Driver App for working zone selection, and by Payments during fare calculation.

### 6.2.8 Safety & SOS

The Safety & SOS module operationalises the platform's safety-first positioning as a first-class capability rather than a UI feature. It provides the SOS button surface in both apps, automated data capture on activation, real-time alert delivery to the Operations queue, response SLA tracking, defined escalation paths through to external authorities, live trip sharing with trusted contacts, incident logging, and post-incident follow-up. It also enforces the platform's women-only and age policies.

The Safety & SOS module receives triggers from both apps and integrates tightly with the Admin & Operations Portal for response and tracking.

### 6.2.9 Notifications

The Notifications module delivers all platform communications across SMS, push, in-app, and email channels. It supports template management in Arabic and English, delivery tracking with retry, user-level preferences for non-critical messages, and a critical-alert priority mode that bypasses quiet hours for SOS and safety messages.

Every other module produces notifications via this module, and SMS in particular is foundational from launch for OTP delivery during registration.

### 6.2.10 Reporting & Analytics

The Reporting & Analytics module provides foundational visibility for both daily operations and management decision-making. It includes a live operational dashboard, daily and weekly summaries, driver performance reports, cancellation analytics, payment reconciliation, safety incident reports, zone performance reports, and a management KPI view. It also supports CSV and Excel export.

The Reporting & Analytics module reads from every other module and outputs primarily to Operations and Management users via the Admin Portal.

## 6.3 Module Interaction Overview

At a high level, the modules interact as follows during a typical ride:

1. A Rider initiates registration via the Rider App. The Identity & Verification module validates her identity. The Notifications module delivers OTP and verification-status messages.
2. A Driver completes a similar onboarding flow with additional license, vehicle, and background check steps. The Admin & Operations Portal reviews and approves her account. Notifications keep her informed of progress.
3. The Rider submits a ride request through the Rider App. The Pricing & Neighborhood Zones module supplies the fare estimate based on the originating zone. The Trip & Dispatch Engine matches her with an eligible Driver, who accepts via her app.
4. The trip executes. The Trip & Dispatch Engine streams location to the Rider App and the Admin & Operations Portal. Notifications inform both parties of lifecycle events.
5. If safety is at risk, either party triggers SOS. The Safety & SOS module captures context, alerts Operations, tracks SLA, and supports escalation.
6. On trip completion, the Payments module triggers fare capture via the PSP for digital trips, or records cash payment via dual confirmation. Commission is calculated. The Driver's cash balance ledger updates.
7. All interactions feed into Reporting & Analytics for operational and management visibility.

The Admin & Operations Portal supervises the entire process, providing a unified view across modules and the controls needed to manage rides, drivers, riders, incidents, finances, and configuration.

---

# 7. Functional Requirements (MVP)

## 7.0 Reading Guide

Each functional requirement in this section is expressed as a single "shall" statement. Requirements are grouped by module and tagged with a unique identifier (e.g., `RA-001`) and a development priority from P1 to P4.

### Priority Definitions

| Priority | Meaning                  | Description                                                                                              |
|----------|--------------------------|----------------------------------------------------------------------------------------------------------|
| **P1**   | Foundation               | Foundational capabilities every other feature depends on (auth, identity core, RBAC, core data models, platform-wide policies). Built first. |
| **P2**   | Core Ride Cycle          | Minimum end-to-end ride loop: registration → onboarding → booking → matching → trip lifecycle → basic payment → basic SOS. Built second. |
| **P3**   | Operational Completeness | Everything required to run real operations: full payment flows, cancellations, full admin tools, notifications, basic reporting. Built third. |
| **P4**   | Polish                   | Nice-to-haves and edge cases: advanced reports, optional features, peak pricing, post-incident workflows. Built last. |

### Priority Distribution

| Priority | Count | % of Total |
|----------|-------|------------|
| P1       | 28    | 18%        |
| P2       | 56    | 37%        |
| P3       | 53    | 35%        |
| P4       | 15    | 10%        |
| **Total**| **152** | **100%** |

---

## 7.1 Rider App

The Rider App provides female riders with the complete journey from registration through trip completion, including safety and payment features.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| RA-001  | Registration with mobile OTP              | The system shall allow Riders to register using an Egyptian mobile number, verified via a one-time SMS password.                                                                  | P1       |
| RA-002  | Login, logout & session management        | The system shall provide Riders with secure login, logout, and persistent session management with defined session expiry.                                                         | P1       |
| RA-003  | Profile management                        | The system shall allow Riders to view and edit their name, profile photo, email, and language preference.                                                                          | P1       |
| RA-004  | Emergency contacts management             | The system shall allow Riders to add, edit, and remove up to three trusted contacts, used for live trip sharing and SOS notifications.                                            | P3       |
| RA-005  | Identity verification (ID + live selfie)  | The system shall require Riders to complete identity verification (national ID front and back plus live selfie) before completing their first trip.                               | P1       |
| RA-006  | Map-based home screen                     | The system shall present Riders with a map-based home screen showing current location, recent destinations, and a primary call-to-action to request a ride.                       | P1       |
| RA-007  | Pickup location selection                 | The system shall allow Riders to set the pickup location via GPS auto-detection, manual map pin placement, or selection from saved places.                                        | P2       |
| RA-008  | Destination selection                     | The system shall allow Riders to set the destination by searching by name or address, placing a manual map pin, or selecting from saved places.                                   | P2       |
| RA-009  | Fare estimate before booking              | The system shall display an estimated fare and trip duration to the Rider before request submission, calculated using configured zone-based pricing rules.                        | P2       |
| RA-010  | Child accompaniment declaration           | The system shall require Riders to declare child accompaniment (count and approximate ages) for any ride involving children under 12 prior to ride request submission.            | P2       |
| RA-011  | Payment method selection                  | The system shall allow Riders to select between cash and digital (saved or new card) as the payment method for each ride.                                                          | P2       |
| RA-012  | Submit ride request                       | The system shall allow Riders to submit a ride request after confirming pickup, destination, payment method, and child accompaniment information.                                  | P2       |
| RA-013  | Driver matching status & wait screen      | The system shall display a "searching for driver" status to Riders during driver matching, with the option to cancel before driver assignment.                                    | P2       |
| RA-014  | Driver info card                          | The system shall display the assigned Driver's photo, name, vehicle make/model/colour, plate number, and average rating to the Rider upon assignment.                              | P2       |
| RA-015  | Real-time driver tracking on map          | The system shall provide Riders with real-time map tracking of the assigned Driver, with continuously updated estimated time of arrival.                                          | P2       |
| RA-016  | Trip status timeline                      | The system shall present Riders with a visual timeline showing trip progress through the states: assigned, driver arrived, trip started, and trip completed.                       | P2       |
| RA-017  | In-app text chat with driver              | The system shall provide Riders with limited in-app text messaging to the assigned Driver during the active ride, with messaging disabled after trip completion.                   | P3       |
| RA-018  | Call driver via masked number             | The system shall allow Riders to place voice calls to the assigned Driver via a masked-number proxy that protects both parties' personal phone numbers.                            | P3       |
| RA-019  | Live trip sharing with trusted contacts   | The system shall allow Riders to share a live trip status link with trusted contacts via SMS, displaying real-time location, ETA, and Driver information.                          | P3       |
| RA-020  | SOS button (in-trip)                      | The system shall provide Riders with an SOS button accessible during an active trip that triggers the safety alert workflow.                                                       | P2       |
| RA-021  | Cancel ride with reason                   | The system shall allow Riders to cancel a ride before trip completion, requiring selection of a reason from a predefined list, and shall display any applicable cancellation fee before confirmation. | P3       |
| RA-022  | Trip completion & fare breakdown          | The system shall display the final fare with itemised breakdown (base, distance, time, fees) to the Rider upon trip completion.                                                    | P2       |
| RA-023  | Cash payment confirmation flow            | The system shall require both Rider and Driver confirmation of cash payment for cash trips, closing the trip only upon dual confirmation.                                          | P2       |
| RA-024  | Digital payment processing flow           | The system shall capture authorised digital payment from the Rider's selected card upon trip completion and display the payment outcome to the Rider.                              | P2       |
| RA-025  | Rate driver + feedback                    | The system shall allow Riders to rate the Driver on a 1-to-5 scale and submit categorical tags and free-text feedback after trip completion.                                       | P3       |
| RA-026  | Trip history & receipts                   | The system shall provide Riders with a chronological list of past trips, including date, route, fare, payment method, and access to trip receipts.                                | P3       |
| RA-027  | Saved places                              | The system shall allow Riders to save home, work, and custom locations for quick selection during booking.                                                                         | P4       |
| RA-028  | Language switcher (AR/EN, RTL)            | The system shall allow Riders to switch the application language between Arabic (with full right-to-left support) and English, with the selection persisting across sessions.     | P1       |
| RA-029  | Help & support contact                    | The system shall provide Riders with access to in-app FAQs, a contact form, and direct contact channels to customer support.                                                       | P4       |

## 7.2 Driver App

The Driver App enables verified female drivers to onboard, manage availability, execute trips using their own vehicles, and access safety features.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| DA-001  | Registration with mobile OTP              | The system shall allow Drivers to register using an Egyptian mobile number, verified via a one-time SMS password.                                                                  | P1       |
| DA-002  | Login & session management                | The system shall provide Drivers with secure login, logout, and persistent session management with defined session expiry.                                                         | P1       |
| DA-003  | Profile management                        | The system shall allow Drivers to view and edit their name, profile photo, contact information, and language preference.                                                            | P1       |
| DA-004  | Identity verification (ID + live selfie)  | The system shall require Drivers to complete identity verification (national ID front and back plus live selfie) as part of onboarding.                                            | P1       |
| DA-005  | Driving license upload & validation       | The system shall require Drivers to upload front and back images of a valid Egyptian driving license, and shall validate format, expiry, and category as part of onboarding.       | P1       |
| DA-006  | Vehicle documents upload                  | The system shall require Drivers to upload current vehicle registration and valid insurance documents as part of onboarding.                                                       | P1       |
| DA-007  | Vehicle photo upload                      | The system shall require Drivers to upload exterior photographs of their vehicle so that Riders can visually identify the assigned vehicle.                                        | P2       |
| DA-008  | Background check consent flow             | The system shall require Drivers to acknowledge and consent to a background check before document review proceeds.                                                                | P2       |
| DA-009  | Onboarding status tracking                | The system shall display the current onboarding status to Drivers across each stage (documents submitted, under review, approved, or rejected).                                    | P2       |
| DA-010  | Online / offline toggle                   | The system shall provide Drivers with a single-tap toggle to switch between online (available) and offline (unavailable) status.                                                  | P2       |
| DA-011  | Working zone selection                    | The system shall allow Drivers to select one or more configured neighborhoods as their working zones for ride request eligibility.                                                | P2       |
| DA-012  | Incoming request popup with timer         | The system shall present incoming ride requests to available Drivers as a popup containing rider, route, and fare information, automatically dismissing after a defined timeout.   | P2       |
| DA-013  | Accept / decline ride request             | The system shall allow Drivers to accept or decline incoming ride requests within the timeout window, triggering reassignment upon decline or timeout.                            | P2       |
| DA-014  | Pickup navigation                         | The system shall provide Drivers with a deep link to a default mapping application for turn-by-turn navigation to the Rider's pickup location.                                    | P2       |
| DA-015  | Arrived at pickup confirmation            | The system shall allow Drivers to confirm arrival at the pickup location, triggering rider notification and starting the pickup wait window.                                       | P2       |
| DA-016  | Start trip                                | The system shall allow Drivers to start the trip after pickup, transitioning the trip lifecycle to "in progress" and initiating real-time location streaming.                      | P2       |
| DA-017  | In-trip navigation                        | The system shall provide Drivers with a deep link to a default mapping application for navigation to the destination during an active trip.                                       | P2       |
| DA-018  | Complete trip                             | The system shall allow Drivers to complete the trip upon reaching the destination, triggering fare calculation and payment processing.                                            | P2       |
| DA-019  | Cancel ride with reason                   | The system shall allow Drivers to cancel an assigned ride before trip completion, requiring a reason from a predefined list, with repeated cancellations flagged for review.      | P3       |
| DA-020  | Cash collection confirmation              | The system shall allow Drivers to confirm cash payment receipt for cash trips, matched against the Rider's confirmation to close the trip.                                         | P2       |
| DA-021  | Digital payment status visibility         | The system shall display the digital payment outcome to the Driver after trip completion.                                                                                          | P2       |
| DA-022  | Trip history list                         | The system shall provide Drivers with a chronological list of completed trips, including route, fare, and rider rating.                                                            | P3       |
| DA-023  | Earnings dashboard                        | The system shall provide Drivers with a daily, weekly, and per-trip earnings dashboard, including platform commission breakdown.                                                  | P3       |
| DA-024  | Cash owed to platform balance             | The system shall display a live balance of platform commission owed by the Driver from cash trips, with settlement reminders.                                                     | P3       |
| DA-025  | Rate rider + feedback                     | The system shall allow Drivers to rate the Rider on a 1-to-5 scale and submit categorical tags after trip completion.                                                              | P3       |
| DA-026  | SOS button (in-trip)                      | The system shall provide Drivers with an SOS button accessible during an active trip that triggers the safety alert workflow.                                                      | P2       |
| DA-027  | In-app chat with rider                    | The system shall provide Drivers with limited in-app text messaging to the assigned Rider during the active ride, with messaging disabled after trip completion.                   | P3       |
| DA-028  | Call rider via masked number              | The system shall allow Drivers to place voice calls to the assigned Rider via a masked-number proxy.                                                                               | P3       |
| DA-029  | Help & support contact                    | The system shall provide Drivers with access to in-app FAQs, a support form, and direct contact channels to customer support.                                                      | P4       |
| DA-030  | Language switcher (AR/EN)                 | The system shall allow Drivers to switch the application language between Arabic and English, with the selection persisting across sessions.                                       | P1       |

## 7.3 Admin & Operations Portal

The Admin & Operations Portal supports the Operations, Customer Support, Finance, and Compliance teams in running daily platform operations.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| AP-001  | Admin authentication with 2FA             | The system shall require Administrators to authenticate using credentials and a second factor (TOTP or SMS), with enforced session timeout.                                       | P1       |
| AP-002  | Role-based access control                 | The system shall enforce role-based access control across portal features and data, supporting roles including Administrator, Operations Supervisor, Customer Support, Finance, and Compliance. | P1       |
| AP-003  | Live operational dashboard                | The system shall provide Administrators with a live dashboard displaying key operational indicators, including active rides, online drivers, open SOS events, and payment failures. | P3       |
| AP-004  | Driver onboarding queue                   | The system shall present Administrators with a queue of Drivers awaiting review, with filtering by status, working zone, and submission date.                                     | P2       |
| AP-005  | Driver document review                    | The system shall allow Administrators to inspect submitted Driver identity, license, and vehicle documents and to approve or reject onboarding with a captured reason.            | P2       |
| AP-006  | Driver account management                 | The system shall allow Administrators to activate, suspend, or deactivate Driver accounts, with each action recorded in the audit trail.                                          | P2       |
| AP-007  | Rider account management                  | The system shall allow Administrators to search, view, suspend, or block Rider accounts, including viewing trip history.                                                          | P3       |
| AP-008  | Live ride monitoring map                  | The system shall provide Administrators with a real-time map of all active rides, with filtering by zone, status, or driver.                                                      | P3       |
| AP-009  | Active rides list with filters            | The system shall provide Administrators with a tabular view of active rides, with filters for zone, status, payment method, and child accompaniment.                              | P3       |
| AP-010  | Ride detail view                          | The system shall provide Administrators with a complete trip-detail view, including event timeline, location trail, payment, and communication log.                               | P3       |
| AP-011  | Cancellation review queue                 | The system shall provide Administrators with a list of recent cancellations and their reasons, and shall flag accounts exhibiting abnormal cancellation patterns.                  | P3       |
| AP-012  | Incident management workflow              | The system shall allow Administrators to log incidents linked to specific rides or users, assign owners, track resolution, and close incidents with notes.                        | P3       |
| AP-013  | SOS alerts queue with response actions    | The system shall provide Administrators with a live queue of active SOS alerts, with one-click response actions including calling Rider, calling Driver, and triggering escalation. | P2       |
| AP-014  | SOS escalation workflow                   | The system shall enforce a defined escalation path for SOS incidents (Operations → Supervisor → External Authority) with time-based triggers.                                      | P3       |
| AP-015  | Neighborhood / zone management            | The system shall allow Administrators to define neighborhood polygons on a map and to activate, deactivate, or edit zone boundaries.                                              | P1       |
| AP-016  | Pricing configuration per zone            | The system shall allow Administrators to configure base fare, per-kilometre and per-minute rates, minimum fare, and zone-pair pricing rules per zone.                             | P2       |
| AP-017  | Cancellation rule configuration           | The system shall allow Administrators to configure cancellation time windows and applicable fees, globally or per zone.                                                            | P3       |
| AP-018  | Commission rate configuration             | The system shall allow Administrators to configure platform commission percentages globally or per zone, with effective-date scheduling.                                          | P2       |
| AP-019  | Cash reconciliation dashboard             | The system shall provide Administrators with an aggregate view of cash owed by Drivers versus cash settled, including identification of overdue settlements.                       | P3       |
| AP-020  | Driver cash balance tracking              | The system shall provide a per-Driver ledger of cash trips, commission accrued, and settlement history.                                                                            | P3       |
| AP-021  | Manual refund processing                  | The system shall allow Administrators to issue manual refunds for digital trips, with reason captured for audit.                                                                   | P4       |
| AP-022  | Dispute management workflow               | The system shall allow Administrators to log payment-related disputes, track status through resolution, and attach supporting evidence.                                            | P4       |
| AP-023  | Audit logs viewer                         | The system shall provide a searchable log of all administrative actions, including approvals, suspensions, configuration changes, and refunds.                                    | P3       |
| AP-024  | Notification template management          | The system shall allow authorised Administrators to edit SMS, push, email, and in-app notification templates per language without code deployment.                                | P4       |
| AP-025  | Static content management                 | The system shall allow Administrators to manage Terms & Conditions, privacy policy, and FAQ content shown in the apps without code deployment.                                    | P3       |

## 7.4 Identity & Verification

The Identity & Verification module is the platform's gatekeeper for both Riders and Drivers.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| IV-001  | National ID OCR & data extraction              | The system shall extract name, ID number, date of birth, and gender from submitted national ID images via Optical Character Recognition.                                          | P1       |
| IV-002  | National ID validity & duplicate checks        | The system shall validate the national ID number format, check expiry, and detect duplicate registrations across user accounts.                                                   | P1       |
| IV-003  | Liveness detection during selfie capture       | The system shall apply anti-spoofing checks during selfie capture, including motion or vendor-defined liveness validations.                                                       | P1       |
| IV-004  | Face matching (ID vs live selfie)              | The system shall compare the photo on the submitted national ID with the live selfie and produce a confidence score evaluated against a defined threshold.                        | P1       |
| IV-005  | Age eligibility check                          | The system shall calculate the user's age from the national ID date of birth and reject registrations of users below 18 years of age.                                              | P1       |
| IV-006  | Gender verification                            | The system shall extract gender from the national ID and reject registrations from non-female users to enforce the platform's women-only policy.                                  | P1       |
| IV-007  | Driving license validation                     | The system shall validate Drivers' submitted driving license images for format, expiry, and category.                                                                              | P2       |
| IV-008  | Vehicle document verification                  | The system shall verify that submitted vehicle registration documents match the Driver and that the insurance document is currently valid.                                         | P2       |
| IV-009  | Background check integration                   | The system shall submit Driver data to the configured background check provider and capture the resulting clearance for Driver onboarding.                                        | P3       |
| IV-010  | Manual review queue                            | The system shall route verification edge cases (low OCR confidence, low face-match score) to a queue for human review.                                                            | P3       |

## 7.5 Payments (Cash + Digital)

The Payments module handles all financial flows for both cash and digital rails.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| PY-001  | PSP integration                           | The system shall integrate with the configured Payment Service Provider for processing card payments, tokenisation, and refunds.                                                  | P1       |
| PY-002  | Card tokenization & saved cards           | The system shall securely tokenise Rider card details via the PSP and allow Riders to save cards for use in future trips.                                                          | P1       |
| PY-003  | Payment authorization on trip start       | The system shall pre-authorise the estimated fare amount on the Rider's payment method when the trip starts.                                                                      | P2       |
| PY-004  | Payment capture on trip completion        | The system shall capture the final fare amount after trip completion, supporting partial-capture scenarios.                                                                        | P2       |
| PY-005  | Cash payment recording                    | The system shall record cash trip payments based on dual confirmation from the Rider and Driver.                                                                                   | P2       |
| PY-006  | Driver cash balance ledger                | The system shall maintain a per-Driver ledger of cash trips, commission accrued, and amounts owed to the platform.                                                                | P3       |
| PY-007  | Commission calculation & deduction        | The system shall calculate platform commission for each completed trip and apply it to Driver earnings or cash balance.                                                            | P2       |
| PY-008  | Cash settlement workflow                  | The system shall support a defined workflow for Drivers to settle outstanding cash owed to the platform, including settlement events and confirmation.                            | P3       |
| PY-009  | Payment failure handling & retry          | The system shall detect payment failures, notify the Rider, and allow retry using the same or an alternative payment method.                                                       | P3       |
| PY-010  | Manual refund processing                  | The system shall provide back-office capability to issue manual refunds for digital trips, with audit trail and PSP reconciliation.                                                | P4       |
| PY-011  | Digital + cash receipt generation         | The system shall generate trip receipts for both cash and digital trips, viewable in-app and exportable.                                                                           | P3       |
| PY-012  | Cancellation fee calculation              | The system shall calculate cancellation fees based on configured zone-level rules and timing, and shall charge them via the active payment method.                                | P3       |
| PY-013  | Block new rides on unresolved failure     | The system shall prevent Riders from booking new rides while a previous payment failure remains unresolved.                                                                        | P3       |

## 7.6 Trip & Dispatch Engine

The Trip & Dispatch Engine governs matching, lifecycle, and real-time location.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| TD-001  | Driver-rider matching algorithm                | The system shall match each ride request to the most suitable eligible Driver based on proximity, working zone, and driver rating.                                                | P2       |
| TD-002  | Zone-aware driver eligibility filtering        | The system shall include only Drivers whose configured working zones encompass the pickup location in matching candidate sets.                                                     | P2       |
| TD-003  | Ride request broadcasting                      | The system shall broadcast ride requests to candidate Drivers, sequentially or in parallel, within a defined timeout window.                                                       | P2       |
| TD-004  | Driver acceptance handling                     | The system shall process Driver acceptance with an atomic lock to prevent multiple Drivers from being assigned to the same ride.                                                  | P2       |
| TD-005  | Decline / timeout reassignment logic           | The system shall re-broadcast a ride request to the next eligible Driver upon decline or response timeout.                                                                         | P2       |
| TD-006  | ETA calculation                                | The system shall calculate the Estimated Time of Arrival using the configured maps service and recalculate it as the Driver's location updates.                                   | P2       |
| TD-007  | Trip lifecycle state machine                   | The system shall enforce valid state transitions across the trip lifecycle: requested, assigned, arrived, started, completed, and cancelled.                                       | P1       |
| TD-008  | Real-time location streaming                   | The system shall stream the Driver's location during an active trip to the Rider App and the Operations portal.                                                                    | P2       |
| TD-009  | Geofence detection (pickup & drop-off)         | The system shall detect Driver entry into pickup and drop-off zones and trigger relevant lifecycle events.                                                                          | P2       |
| TD-010  | No-driver-available retry queue                | The system shall queue ride requests for re-broadcast with exponential backoff when no eligible Driver is available, notifying the Rider after a defined number of attempts.       | P3       |

## 7.7 Pricing & Neighborhood Zones

The Pricing & Neighborhood Zones module enables polygon-based zone configuration and per-zone fare rules.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| PZ-001  | Polygon-based neighborhood definition          | The system shall allow Administrators to define neighborhood boundaries as map polygons, persisted as geo-fences.                                                                 | P1       |
| PZ-002  | Per-zone base fare configuration               | The system shall allow Administrators to set a base fare per zone, applied to trips originating in that zone.                                                                     | P2       |
| PZ-003  | Per-km & per-minute rate configuration         | The system shall allow Administrators to set distance-based and duration-based rates per zone.                                                                                     | P2       |
| PZ-004  | Minimum fare per zone                          | The system shall allow Administrators to define a minimum fare per zone to ensure short trips remain commercially viable.                                                          | P2       |
| PZ-005  | Zone-to-zone pricing rules                     | The system shall support specific pricing rules for trips between defined zone pairs.                                                                                              | P3       |
| PZ-006  | Cancellation fee rules per zone                | The system shall allow Administrators to configure cancellation timing windows and fee amounts per zone.                                                                           | P3       |
| PZ-007  | Pricing rule versioning & history              | The system shall maintain a history of pricing rule changes with effective dates for audit and rollback purposes.                                                                  | P4       |
| PZ-008  | Peak-hour multiplier                           | The system shall optionally apply a configured multiplier to base pricing during defined peak hours per zone.                                                                      | P4       |

## 7.8 Safety & SOS

The Safety & SOS module operationalises the platform's safety-first positioning.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| SS-001  | SOS button (rider + driver)               | The system shall provide a single-tap SOS button visible during active trips in both the Rider and Driver applications.                                                            | P2       |
| SS-002  | Auto-data capture on SOS trigger          | The system shall, upon SOS activation, automatically capture the user's location, trip identifier, and the relevant Rider and Driver details.                                     | P2       |
| SS-003  | Real-time SOS alert to ops queue          | The system shall deliver SOS alerts in real time to the Operations SOS queue with full context and audible/visual notification on the operator side.                              | P2       |
| SS-004  | Ops response SLA tracking                 | The system shall measure the elapsed time from SOS activation to first operator action and alert when defined SLA thresholds are breached.                                        | P3       |
| SS-005  | Escalation workflow                       | The system shall enforce a defined SOS escalation path from initial responder, through supervisor, to external authority handoff, with prescribed scripts.                         | P3       |
| SS-006  | Live trip sharing (rider)                 | The system shall provide a shareable live link to a Rider's trip status, automatically delivered to Trusted Contacts on trip start or SOS activation.                              | P3       |
| SS-007  | Trusted contacts management               | The system shall allow Riders to maintain a list of up to three Trusted Contacts to be notified during live trip sharing or SOS activation.                                       | P3       |
| SS-008  | Incident logging & status tracking        | The system shall create an incident record for each SOS event and shall track its status through to resolution.                                                                    | P3       |
| SS-009  | Post-incident follow-up workflow          | The system shall support an operations-led post-incident follow-up process, including outcome capture and review notes.                                                            | P4       |
| SS-010  | Women-only & age policy enforcement       | The system shall enforce that all Riders and Drivers are female and at least 18 years of age across all platform interactions.                                                     | P1       |

## 7.9 Notifications

The Notifications module delivers all platform communications across channels.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| NT-001  | SMS gateway integration                        | The system shall integrate with the configured SMS gateway for delivery of one-time passwords and critical alerts.                                                                | P1       |
| NT-002  | Push notification service (FCM / APNS)         | The system shall integrate with Firebase Cloud Messaging (Android) and Apple Push Notification Service (iOS) for push delivery, with managed device-token storage.                | P2       |
| NT-003  | In-app notification center                     | The system shall provide a persistent in-app inbox of recent notifications in the Rider, Driver, and Administrator applications.                                                  | P3       |
| NT-004  | Email notifications (admin / finance)          | The system shall support email delivery for administrative and finance notifications, including reconciliation summaries.                                                          | P3       |
| NT-005  | Notification template management (AR + EN)     | The system shall provide editable notification templates per channel and language, supporting variable substitution.                                                              | P4       |
| NT-006  | Delivery tracking & retry                      | The system shall track delivery status per notification and shall retry failed deliveries with backoff.                                                                            | P3       |
| NT-007  | Notification preferences per user              | The system shall allow users to set their preferences for non-critical notification channels; critical notifications shall always be delivered.                                    | P4       |
| NT-008  | Critical alert priority                        | The system shall ensure that SOS and other safety-related alerts bypass quiet hours and Do Not Disturb settings on user devices.                                                   | P3       |

## 7.10 Reporting & Analytics

The Reporting & Analytics module provides operational and management visibility.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| RP-001  | Live operational dashboard                | The system shall provide a live operational dashboard showing active rides, online drivers, payment success rate, open SOS events, and cancellation rate.                         | P3       |
| RP-002  | Daily / weekly ride summary               | The system shall produce daily and weekly summary reports of trips, gross merchandise value, completion rate, and average fare, grouped by day, week, and zone.                   | P3       |
| RP-003  | Driver performance report                 | The system shall produce per-Driver performance reports including trips completed, earnings, cancellation rate, average rating, and hours online.                                 | P3       |
| RP-004  | Cancellation analytics report             | The system shall produce reports on cancellation reasons, timing patterns, and correlation with zones, Drivers, and Riders.                                                       | P3       |
| RP-005  | Payment reconciliation report             | The system shall produce a payment reconciliation report covering cash and digital splits, success and failure rates, and outstanding cash balances.                              | P3       |
| RP-006  | Safety incident report                    | The system shall produce safety incident reports including SOS counts, response times, escalation outcomes, and accounts with repeat incidents.                                    | P3       |
| RP-007  | Zone performance report                   | The system shall produce per-zone performance reports including trips, gross merchandise value, supply versus demand balance, and cancellation rate.                              | P4       |
| RP-008  | Management KPI dashboard                  | The system shall provide an executive-level KPI dashboard covering gross merchandise value, active users, retention, safety, and financial health.                                | P4       |
| RP-009  | CSV / Excel export                        | The system shall support exporting filtered data from any report to CSV or Microsoft Excel formats.                                                                                | P4       |

---

*End of Sections 6 and 7.*

*To be combined with `SheDrive_BRD_Draft_v0.2.md` to produce the consolidated BRD.*
