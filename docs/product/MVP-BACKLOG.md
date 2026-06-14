# SheDrive — MVP Product Backlog

> **Scope:** MVP only — Greater Cairo (Cairo + Giza), daytime operating hours.
> Each story has a short **Title** (`Persona` + action) and a full **User Story** with a `so that` clause.
> Acceptance criteria and estimates are added during sprint refinement.
>
> **ID format:** `MODULE-NNN`
> **Actors:** Rider · Driver · Admin · Ops · Support · Finance · Compliance · System

---

## Priority Legend

| Priority | Meaning |
|---|---|
| P1 | Launch blocker — must ship |
| P2 | Required for a complete ride cycle |
| P3 | Needed before go-live, not per-ride |
| P4 | Nice-to-have within MVP |

---

## Module 1 — Rider App

### Feature 1.1 — Registration & Login

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-001 | Rider enters phone number | As a rider, I want to enter my phone number to start registration, so that I can begin creating my SheDrive account | P1 |
| RIDER-002 | Rider receives OTP via SMS | As a rider, I want to receive an OTP via SMS to verify my phone number, so that the platform can confirm I own the number before activating my account | P1 |
| RIDER-003 | Rider submits OTP | As a rider, I want to enter my OTP to complete phone verification, so that my account is activated and ready to use | P1 |
| RIDER-004 | Rider redirected to identity verification | As a rider, I want to be redirected to identity verification automatically after my first login, so that I can complete the required KYC before my first trip | P1 |
| RIDER-005 | Rider logs in | As a rider, I want to log in with my phone number and OTP on subsequent visits, so that I can access my account securely | P1 |
| RIDER-006 | Rider session persists | As a rider, I want my session to persist so I am not forced to re-login every time, so that my experience is seamless and uninterrupted | P2 |
| RIDER-007 | Rider logs out | As a rider, I want to log out of my account, so that my account stays secure on shared or lost devices | P3 |

---

### Feature 1.2 — Identity Verification

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-008 | Rider photographs front of National ID | As a rider, I want to photograph the front of my National ID, so that the platform can extract and verify my identity details | P1 |
| RIDER-009 | Rider photographs back of National ID | As a rider, I want to photograph the back of my National ID, so that the platform has complete ID documentation for my verification | P1 |
| RIDER-010 | Rider takes liveness selfie | As a rider, I want to take a liveness selfie, so that the platform can confirm I am the person shown on the ID | P1 |
| RIDER-011 | Rider views verification status | As a rider, I want to see my verification status (pending, approved, rejected), so that I know when I am cleared to book rides | P1 |
| RIDER-012 | Rider sees verification rejection reason | As a rider, I want to be told why my verification was rejected and how to resubmit, so that I can fix the issue and complete my verification | P2 |
| RIDER-013 | System blocks unverified rider from booking | As a rider, I want to be blocked from booking rides until my identity is verified, so that the platform's safety standards are consistently enforced | P1 |

---

### Feature 1.3 — Ride Booking

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-014 | Rider sets pickup location | As a rider, I want to set my pickup location by searching an address or dropping a pin on the map, so that the driver knows exactly where to collect me | P1 |
| RIDER-015 | Rider uses GPS as pickup suggestion | As a rider, I want the map to suggest my current GPS location as the pickup, so that I can book faster without typing my address | P2 |
| RIDER-016 | Rider sets destination | As a rider, I want to set my destination by searching an address or dropping a pin, so that the platform can calculate my fare and match me with a driver | P1 |
| RIDER-017 | Rider sees fare estimate | As a rider, I want to see a fare estimate before I confirm my booking, so that I can decide whether to proceed | P1 |
| RIDER-018 | Rider declares child accompaniment | As a rider, I want to declare that I am travelling with a child under 12, so that the platform applies the correct safety and eligibility rules for my trip | P1 |
| RIDER-019 | Rider selects payment method | As a rider, I want to select cash or digital card as my payment method before booking, so that I can pay in the way that suits me | P1 |
| RIDER-020 | Rider submits ride request | As a rider, I want to confirm and submit my ride request, so that the platform begins searching for a driver | P1 |
| RIDER-021 | Rider sees driver search screen | As a rider, I want to see a waiting screen while the platform searches for a driver, so that I know my request is being processed | P1 |
| RIDER-022 | Rider notified of driver match | As a rider, I want to be notified when a driver has been matched to my ride, so that I know a driver is on the way | P1 |
| RIDER-023 | Rider sees matched driver details | As a rider, I want to see the matched driver's name, rating, and vehicle details, so that I can identify the correct car when it arrives | P1 |
| RIDER-024 | Rider notified when no driver is available | As a rider, I want to be notified when no driver is available, so that I can decide to wait, retry, or cancel | P2 |

---

### Feature 1.4 — Real-Time Trip Tracking

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-025 | Rider tracks driver on map | As a rider, I want to see the driver's real-time location on the map while they travel to me, so that I know when to expect them | P1 |
| RIDER-026 | Rider sees driver ETA | As a rider, I want to see the driver's ETA to my pickup point, so that I can plan my time accordingly | P1 |
| RIDER-027 | Rider notified when driver arrives | As a rider, I want to be notified when the driver has arrived at my pickup location, so that I know to come outside | P1 |
| RIDER-028 | Rider tracks live trip progress | As a rider, I want to see my route and live progress on the map during the trip, so that I can follow the journey and feel in control | P1 |
| RIDER-029 | Rider sees trip status updates | As a rider, I want to see the trip status update as it moves through each stage, so that I always know what is happening with my ride | P1 |

---

### Feature 1.5 — In-Trip Communication

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-030 | Rider calls driver via masked number | As a rider, I want to call my driver through a masked number, so that my personal phone number is never shared with the driver | P1 |
| RIDER-031 | Rider chats with driver in-app | As a rider, I want to send a text message to my driver in-app, so that I can communicate without making a phone call | P2 |

---

### Feature 1.6 — Ride Cancellation

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-032 | Rider cancels ride before driver arrives | As a rider, I want to cancel my ride before the driver arrives, so that I can change my plans when needed | P1 |
| RIDER-033 | Rider sees cancellation fee before confirming | As a rider, I want to see the cancellation fee (if any) before I confirm cancellation, so that I can make an informed decision | P1 |
| RIDER-034 | Rider selects cancellation reason | As a rider, I want to select a reason when cancelling a ride, so that the platform can track and improve service quality over time | P2 |

---

### Feature 1.7 — Fare & Payment

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-035 | Rider views final fare breakdown | As a rider, I want to see my final fare breakdown at the end of the trip, so that I understand what I am being charged for | P1 |
| RIDER-036 | Rider confirms cash payment | As a rider, I want to confirm that I paid cash at the end of a cash trip, so that the transaction is recorded for both parties | P1 |
| RIDER-037 | Rider saves a payment card | As a rider, I want to add a card and have it saved for future digital payments, so that I do not need to re-enter my card details on every trip | P1 |
| RIDER-038 | Rider pays by saved card at trip end | As a rider, I want to pay by my saved card automatically at trip completion, so that the payment process is seamless | P1 |
| RIDER-039 | Rider receives trip receipt | As a rider, I want to receive an in-app receipt after every completed trip, so that I have a record of the transaction | P2 |
| RIDER-040 | Rider notified of payment failure | As a rider, I want to be notified if my card payment fails and prompted to resolve it, so that I can sort out the issue and continue using the platform | P1 |
| RIDER-041 | System blocks rider with unresolved payment failure | As a rider, I want to be prevented from booking a new ride while I have an unresolved payment failure, so that drivers are not exposed to unpaid fares | P1 |

---

### Feature 1.8 — Post-Trip

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-042 | Rider rates driver after trip | As a rider, I want to rate my driver from 1 to 5 stars after a trip, so that I can give feedback that helps maintain service quality | P1 |
| RIDER-043 | Rider leaves written feedback for driver | As a rider, I want to leave optional written feedback for my driver, so that I can provide more detail beyond a star rating | P2 |
| RIDER-044 | Rider views trip history | As a rider, I want to view a list of my past trips, so that I can reference my travel history | P2 |
| RIDER-045 | Rider views individual trip details | As a rider, I want to see the details of any past trip (route, fare, driver), so that I can review or dispute a specific ride | P3 |

---

### Feature 1.9 — Safety

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-046 | Rider triggers SOS | As a rider, I want to tap an SOS button during a trip to immediately alert the operations team, so that I can get help quickly in an emergency | P1 |
| RIDER-047 | Rider shares live trip link | As a rider, I want to share a live tracking link with someone I trust, so that someone always knows where I am during a trip | P1 |
| RIDER-048 | Rider manages trusted contacts | As a rider, I want to add and manage trusted contacts who receive my trip link, so that I can keep my safety network up to date | P1 |

---

### Feature 1.10 — Settings & Localisation

| ID | Title | User Story | Priority |
|---|---|---|---|
| RIDER-049 | Rider switches app language | As a rider, I want to switch the app language between Arabic and English at any time, so that I can use the platform in my preferred language | P1 |
| RIDER-050 | App remembers rider language preference | As a rider, I want the app to default to my previously selected language on each launch, so that I do not need to change it every time I open the app | P2 |

---

## Module 2 — Driver App

### Feature 2.1 — Registration

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-001 | Driver registers with phone number | As a driver, I want to register with my phone number to start the onboarding process, so that I can begin applying to join SheDrive | P1 |
| DRIVER-002 | Driver receives and submits OTP | As a driver, I want to receive and enter an OTP to verify my phone number, so that the platform can confirm my number before onboarding begins | P1 |
| DRIVER-003 | Driver logs in | As a driver, I want to log in with my phone number and OTP on subsequent visits, so that I can access my driver app securely | P1 |

---

### Feature 2.2 — Identity & Document Onboarding

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-004 | Driver submits National ID photos | As a driver, I want to submit my National ID photos for identity verification, so that the platform can confirm who I am | P1 |
| DRIVER-005 | Driver takes liveness selfie | As a driver, I want to take a liveness selfie so the platform can match my face to my ID, so that my identity is confirmed before I can go online | P1 |
| DRIVER-006 | Driver uploads driving license | As a driver, I want to upload my driving license for validation, so that the platform can confirm I am legally permitted to drive | P1 |
| DRIVER-007 | Driver uploads vehicle registration | As a driver, I want to upload my vehicle registration document, so that the platform can verify my vehicle's ownership and eligibility | P1 |
| DRIVER-008 | Driver uploads vehicle insurance | As a driver, I want to upload my vehicle insurance document, so that the platform can confirm my vehicle is properly covered | P1 |
| DRIVER-009 | Driver uploads vehicle photos | As a driver, I want to photograph my vehicle exterior, so that the platform and riders can identify my car | P1 |
| DRIVER-010 | Driver consents to background check | As a driver, I want to consent to a background check before my application is reviewed, so that I understand and agree to the platform's safety requirements | P1 |
| DRIVER-011 | Driver tracks onboarding status | As a driver, I want to track my onboarding status so I know what is pending or approved, so that I can complete any remaining steps without confusion | P1 |
| DRIVER-012 | Driver notified of application decision | As a driver, I want to be notified when my application is approved or rejected, so that I know whether I can start accepting rides | P1 |
| DRIVER-013 | Driver sees rejection reason | As a driver, I want to be told why my application was rejected and what to fix, so that I can correct the issue and resubmit successfully | P2 |

---

### Feature 2.3 — Availability & Zone

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-014 | Driver toggles online or offline | As a driver, I want to toggle my status between Online and Offline, so that I only receive ride requests when I am ready to work | P1 |
| DRIVER-015 | Driver selects working zone | As a driver, I want to select the neighborhood zone I will work in for my current session, so that I only receive requests within my chosen area | P1 |

---

### Feature 2.4 — Ride Request Handling

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-016 | Driver receives ride request | As a driver, I want to receive a ride request notification with the pickup area and fare, so that I can decide whether to accept | P1 |
| DRIVER-017 | Driver accepts ride request | As a driver, I want to accept a ride request within the allowed timeout window, so that the rider is confirmed and I can begin navigating to the pickup | P1 |
| DRIVER-018 | Driver declines ride request | As a driver, I want to decline a ride request, so that I can skip trips that do not suit me at that moment | P1 |
| DRIVER-019 | Request expires on driver inaction | As a driver, I want the request to expire automatically if I do not respond in time, so that the rider is reassigned promptly without being left waiting | P1 |

---

### Feature 2.5 — Trip Execution

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-020 | Driver navigates to pickup with in-app navigation | As a driver, I want in-app turn-by-turn navigation to the pickup, with the option to open an external maps app, so that I can reach the pickup using my preferred tool | P1 |
| DRIVER-021 | Driver navigates to destination with in-app navigation | As a driver, I want in-app turn-by-turn navigation to the destination, with the option to open an external maps app, so that I can navigate efficiently after the rider boards | P1 |
| DRIVER-022 | Driver marks arrival at pickup | As a driver, I want to mark myself as arrived at the pickup location, so that the rider is notified and the wait timer starts | P1 |
| DRIVER-023 | Driver starts trip | As a driver, I want to start the trip once the rider is in the vehicle, so that the fare meter begins and the trip is officially in progress | P1 |
| DRIVER-024 | Driver ends trip | As a driver, I want to end the trip when I reach the destination, so that the fare is finalised and the ride is closed | P1 |
| DRIVER-025 | Driver cancels accepted trip | As a driver, I want to cancel an accepted trip with a stated reason, so that the rider can be reassigned and the platform can track cancellation patterns | P1 |

---

### Feature 2.6 — Communication

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-026 | Driver calls rider via masked number | As a driver, I want to call the rider through a masked number, so that neither party's personal phone number is exposed | P1 |
| DRIVER-027 | Driver chats with rider in-app | As a driver, I want to send a text message to the rider in-app, so that I can communicate without making a phone call | P2 |

---

### Feature 2.7 — Cash & Earnings

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-028 | Driver confirms cash collection | As a driver, I want to confirm that I collected cash from the rider at the end of a cash trip, so that the transaction is recorded in the platform | P1 |
| DRIVER-029 | Driver views digital payment confirmation | As a driver, I want to see confirmation that the digital payment was processed at trip end, so that I know the fare has been settled | P1 |
| DRIVER-030 | Driver views earnings summary | As a driver, I want to view my earnings summary (total trips, total earned), so that I can track my income over time | P2 |
| DRIVER-031 | Driver views cash balance owed | As a driver, I want to see my current cash balance owed to the platform, so that I know how much I need to settle | P2 |

---

### Feature 2.8 — Rating & Feedback

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-032 | Driver views own rating | As a driver, I want to view my overall rating, so that I am aware of how riders perceive my service | P3 |
| DRIVER-033 | Driver rates rider after trip | As a driver, I want to rate my rider at the end of a trip, so that the platform can maintain a mutual accountability standard | P3 |

---

### Feature 2.9 — Safety

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-034 | Driver triggers SOS | As a driver, I want to tap an SOS button to immediately alert the operations team, so that I can get help quickly if I feel unsafe during a trip | P1 |

---

### Feature 2.10 — Settings & Localisation

| ID | Title | User Story | Priority |
|---|---|---|---|
| DRIVER-035 | Driver switches app language | As a driver, I want to switch the app language between Arabic and English, so that I can use the platform in my preferred language | P1 |
| DRIVER-036 | App remembers driver language preference | As a driver, I want the app to remember my language preference, so that I do not need to change it every time I open the app | P2 |

---

## Module 3 — Admin & Operations Portal

### Feature 3.1 — Authentication & Access Control

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-001 | Portal user logs in with 2FA | As a portal user, I want to log in with my credentials and a second-factor code, so that only authorised personnel can access the back-office system | P1 |
| ADMIN-002 | Admin creates portal user account | As an admin, I want to create portal user accounts and assign roles, so that team members can access the portal with the right permissions from day one | P1 |
| ADMIN-003 | Admin assigns role to portal user | As an admin, I want to assign one of five roles to each user (Admin, Ops, Support, Finance, Compliance), so that every user's access is scoped to their responsibilities | P1 |
| ADMIN-004 | System enforces role-based access | As an admin, I want the system to restrict each user to only the sections their role permits, so that sensitive operations are protected from unauthorised access | P1 |
| ADMIN-005 | Admin deactivates portal user | As an admin, I want to deactivate a portal user account, so that access is revoked immediately when a team member leaves or changes role | P2 |

---

### Feature 3.2 — Driver Onboarding Queue

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-006 | Ops views pending driver applications | As an Ops user, I want to see the list of driver applications pending review, so that I can work through the queue efficiently | P1 |
| ADMIN-007 | Ops reviews driver application documents | As an Ops user, I want to open a driver application and review each submitted document, so that I can make an informed approval decision | P1 |
| ADMIN-008 | Ops approves driver application | As an Ops user, I want to approve a driver application to activate the driver, so that qualified drivers can start accepting rides | P1 |
| ADMIN-009 | Ops rejects driver application | As an Ops user, I want to reject a driver application with a written rejection reason, so that the driver understands why and knows what to correct | P1 |
| ADMIN-010 | Ops requests additional documents | As an Ops user, I want to request additional documents from an applicant before deciding, so that I can make a complete assessment without an outright rejection | P2 |
| ADMIN-011 | Ops views automated verification results | As an Ops user, I want to see the verification results (OCR, face match, background check) for each application, so that I can validate the automated checks alongside my own review | P1 |

---

### Feature 3.3 — Account Management

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-012 | Support searches for rider account | As a Support user, I want to search for a rider account by name or phone number, so that I can locate the correct account quickly when handling a query | P1 |
| ADMIN-013 | Support searches for driver account | As a Support user, I want to search for a driver account by name or phone number, so that I can assist drivers with account-related issues | P1 |
| ADMIN-014 | Support views rider profile and history | As a Support user, I want to view a rider's profile, verification status, and trip history, so that I have full context when handling a support request | P1 |
| ADMIN-015 | Support views driver profile and history | As a Support user, I want to view a driver's profile, documents, and trip history, so that I can investigate driver-related issues effectively | P1 |
| ADMIN-016 | Ops suspends account | As an Ops user, I want to suspend a rider or driver account, so that I can take immediate action when a user violates platform policies | P1 |
| ADMIN-017 | Ops reactivates suspended account | As an Ops user, I want to reactivate a suspended account, so that users can return to the platform after resolving the issue | P1 |
| ADMIN-018 | Admin permanently deactivates account | As an Admin, I want to permanently deactivate an account, so that severe or repeat violators are removed from the platform | P2 |

---

### Feature 3.4 — Live Operations Dashboard

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-019 | Ops views live operational counts | As an Ops user, I want to see a live count of active rides, online drivers, and pending requests, so that I can assess the current state of operations at a glance | P1 |
| ADMIN-020 | Ops views active rides on live map | As an Ops user, I want to see all active rides on a real-time map, so that I can monitor the full operational picture | P1 |
| ADMIN-021 | Ops views online driver count by zone | As an Ops user, I want to see how many drivers are online per zone, so that I can identify supply gaps and take action | P1 |
| ADMIN-022 | Ops views active ride details | As an Ops user, I want to click any active ride on the map to see its full details, so that I can investigate or intervene when needed | P1 |
| ADMIN-023 | Ops searches historical ride records | As an Ops user, I want to search and view the details of any historical ride, so that I can support dispute resolution and audit requests | P2 |

---

### Feature 3.5 — Cancellation & Incident Management

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-024 | Ops views cancellation log | As an Ops user, I want to view a log of all ride cancellations with reasons and timestamps, so that I can identify patterns and follow up on problematic cancellations | P2 |
| ADMIN-025 | Ops logs a ride incident | As an Ops user, I want to log a ride-related incident with supporting notes, so that all safety and service events are tracked centrally | P2 |
| ADMIN-026 | Ops manages open incident reports | As an Ops user, I want to view and manage open incident reports, so that no incident is left unresolved | P2 |

---

### Feature 3.6 — SOS Queue & Escalation

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-027 | Ops views live SOS alert queue | As an Ops user, I want to see a live queue of all active SOS alerts, so that I can prioritise and respond to emergencies in real time | P1 |
| ADMIN-028 | Ops opens SOS incident details | As an Ops user, I want to open an SOS alert and see the rider or driver, location, and trip snapshot, so that I have full context before responding | P1 |
| ADMIN-029 | Ops logs response actions on SOS | As an Ops user, I want to log every action I take in response to an SOS incident, so that there is an auditable record of the entire response chain | P1 |
| ADMIN-030 | Ops monitors SOS response SLA | As an Ops user, I want to see the elapsed response time for each open SOS incident, so that I can ensure we are responding within the required SLA | P1 |
| ADMIN-031 | Ops escalates SOS to external authorities | As an Ops user, I want to escalate an SOS incident to external authorities and record the escalation details, so that the incident receives the right level of response | P1 |
| ADMIN-032 | Ops resolves SOS incident | As an Ops user, I want to mark an SOS incident as resolved with a written outcome summary, so that the incident is formally closed with a complete record | P1 |
| ADMIN-033 | Ops flags SOS for post-incident follow-up | As an Ops user, I want to flag an SOS incident for post-incident follow-up review, so that serious or recurring cases receive additional attention | P2 |

---

### Feature 3.7 — Zone Management

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-034 | Admin draws zone polygon | As an Admin, I want to draw a polygon on a map to define a new neighborhood zone, so that the platform can operate pricing and matching at the neighborhood level | P1 |
| ADMIN-035 | Admin names and saves zone | As an Admin, I want to name and save a new zone, so that it becomes available for pricing configuration and driver zone selection | P1 |
| ADMIN-036 | Admin edits zone boundary | As an Admin, I want to edit the boundary of an existing zone, so that zone definitions stay accurate as operational areas evolve | P2 |
| ADMIN-037 | Admin deactivates zone | As an Admin, I want to deactivate a zone without deleting its history, so that past pricing and trip records remain intact | P2 |

---

### Feature 3.8 — Pricing & Commission Configuration

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-038 | Admin sets zone fare rates | As an Admin, I want to set the base fare, per-km rate, and per-min rate for a zone, so that fares are calculated correctly for trips in that area | P1 |
| ADMIN-039 | Admin sets minimum fare per zone | As an Admin, I want to set a minimum fare for each zone, so that every trip meets the floor price needed for driver and platform viability | P1 |
| ADMIN-040 | Admin sets cross-zone pricing rules | As an Admin, I want to define pricing rules for trips that cross zone boundaries, so that cross-zone journeys are priced fairly | P1 |
| ADMIN-041 | Admin sets cancellation fees per zone | As an Admin, I want to set cancellation fee rules per zone, so that late cancellations are consistently penalised according to zone policy | P1 |
| ADMIN-042 | Admin publishes pricing rule set | As an Admin, I want to publish a new pricing rule set and have it take effect immediately, so that pricing changes apply to new trips right away | P1 |
| ADMIN-043 | Admin views pricing version history | As an Admin, I want to view the version history of pricing rule changes, so that I can audit what was changed and when | P2 |
| ADMIN-044 | Admin rolls back pricing rules | As an Admin, I want to roll back to a previous pricing rule version, so that a pricing error can be corrected quickly | P2 |
| ADMIN-045 | Admin sets platform commission | As an Admin, I want to configure the platform commission percentage, so that the correct share of each fare is allocated to the platform | P1 |

---

### Feature 3.9 — Financial Management

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-046 | Finance views cash reconciliation dashboard | As a Finance user, I want to view the cash reconciliation dashboard for all drivers, so that I can manage outstanding cash balances across the fleet | P1 |
| ADMIN-047 | Finance views driver outstanding balance | As a Finance user, I want to see the outstanding cash balance for each driver, so that I can prioritise who needs to settle | P1 |
| ADMIN-048 | Finance records cash settlement | As a Finance user, I want to record a cash settlement when a driver pays their balance, so that the driver's ledger is updated accurately | P1 |
| ADMIN-049 | Finance initiates manual refund | As a Finance user, I want to initiate a manual refund for a rider through the admin portal, so that payment errors and disputes are resolved fairly | P1 |
| ADMIN-050 | Finance manages payment disputes | As a Finance user, I want to view and manage open payment disputes, so that every dispute is tracked and resolved | P2 |
| ADMIN-051 | Finance views refund history | As a Finance user, I want to see a history of all processed refunds, so that I can reconcile refunds against our accounts | P2 |

---

### Feature 3.10 — Audit, Notifications & Content

| ID | Title | User Story | Priority |
|---|---|---|---|
| ADMIN-052 | Compliance views audit log | As a Compliance user, I want to view an immutable audit log of all admin portal actions, so that I can investigate any change made to the platform | P2 |
| ADMIN-053 | Admin manages notification templates | As an Admin, I want to view, create, and edit notification templates in Arabic and English, so that all automated messages are accurate and on-brand | P2 |
| ADMIN-054 | Admin manages static content pages | As an Admin, I want to manage static content pages such as Terms & Conditions and FAQ, so that user-facing legal and help content stays current | P3 |

---

## Module 4 — Identity & Verification

### Feature 4.1 — National ID Processing

| ID | Title | User Story | Priority |
|---|---|---|---|
| IDV-001 | System runs OCR on National ID | As the system, I want to run OCR on a submitted National ID image and extract name, DOB, gender, and ID number, so that verification can proceed without manual data entry | P1 |
| IDV-002 | System validates ID expiry | As the system, I want to validate that the National ID has not expired, so that only current, valid IDs are accepted on the platform | P1 |
| IDV-003 | System rejects duplicate ID submission | As the system, I want to reject a submission if the ID number already exists on another account, so that each ID is tied to exactly one platform account | P1 |
| IDV-004 | System checks applicant age | As the system, I want to check that the ID holder is 18 years or older, so that the platform's age eligibility rule is enforced automatically | P1 |
| IDV-005 | System checks applicant gender | As the system, I want to check that the ID holder is female before allowing registration, so that the women-only rule is enforced from the very first step | P1 |

---

### Feature 4.2 — Liveness & Face Matching

| ID | Title | User Story | Priority |
|---|---|---|---|
| IDV-006 | System detects liveness on selfie | As the system, I want to perform liveness detection on the submitted selfie to prevent spoofing, so that fraudulent registrations using static photos are blocked | P1 |
| IDV-007 | System matches selfie to ID photo | As the system, I want to match the selfie face against the ID photo and produce a confidence score, so that the person registering is confirmed to be the ID holder | P1 |
| IDV-008 | System fails verification on low match score | As the system, I want to fail verification if the face match falls below the acceptance threshold, so that unconfirmed identities are not activated on the platform | P1 |

---

### Feature 4.3 — Driver Document Verification

| ID | Title | User Story | Priority |
|---|---|---|---|
| IDV-009 | System validates driving license | As the system, I want to validate a submitted driving license (type, validity, name match), so that only licensed drivers are approved to operate | P1 |
| IDV-010 | System validates vehicle registration | As the system, I want to validate the vehicle registration document (ownership, expiry), so that only legitimately registered vehicles are permitted on the platform | P1 |
| IDV-011 | System validates vehicle insurance | As the system, I want to verify the vehicle insurance document (validity, coverage), so that only properly insured vehicles operate on the platform | P1 |
| IDV-012 | System checks vehicle eligibility | As the system, I want to check the vehicle against platform-defined eligibility criteria, so that only suitable vehicles are approved | P1 |

---

### Feature 4.4 — Background Check

| ID | Title | User Story | Priority |
|---|---|---|---|
| IDV-013 | System submits driver for background check | As the system, I want to submit a driver's details to the background check provider after document approval, so that the check begins without manual Ops intervention | P1 |
| IDV-014 | System stores background check result | As the system, I want to receive and store the background check result, so that the outcome is available for Ops review and audit | P1 |
| IDV-015 | System flags driver pending background clearance | As the system, I want to flag the driver application as pending background clearance until the result arrives, so that no driver is activated before the check is complete | P1 |

---

### Feature 4.5 — Manual Review Queue

| ID | Title | User Story | Priority |
|---|---|---|---|
| IDV-016 | System routes uncertain case to manual review | As the system, I want to route any verification case that cannot be automatically decided to the manual review queue, so that edge cases are handled by a human rather than auto-rejected | P1 |
| IDV-017 | Ops views manual review queue | As an Ops user, I want to view all cases in the manual review queue, so that I can work through them systematically | P1 |
| IDV-018 | Ops decides on manual verification case | As an Ops user, I want to manually approve or reject a flagged verification case with a written reason, so that the decision is recorded and communicated to the applicant | P1 |

---

## Module 5 — Payments (Cash + Digital)

### Feature 5.1 — PSP Integration & Card Management

| ID | Title | User Story | Priority |
|---|---|---|---|
| PAY-001 | System connects to PSP | As the system, I want to connect to the configured PSP and handle communication errors gracefully, so that digital payments can be processed reliably | P1 |
| PAY-002 | Rider adds and tokenizes payment card | As a rider, I want to add a card and have it tokenized and saved for future use, so that I do not need to re-enter my card details on every trip | P1 |
| PAY-003 | Rider removes saved card | As a rider, I want to remove a saved card from my account, so that I can keep my payment methods current | P2 |
| PAY-004 | Rider selects from saved cards | As a rider, I want to see my saved cards and select which one to use, so that I can choose my preferred card at booking time | P2 |

---

### Feature 5.2 — Digital Payment Flow

| ID | Title | User Story | Priority |
|---|---|---|---|
| PAY-005 | System authorises card at trip start | As the system, I want to authorize a card payment at the start of a digital trip, so that the rider's card is confirmed as valid before the journey begins | P1 |
| PAY-006 | System captures fare at trip end | As the system, I want to capture the final fare from the rider's card when the trip ends, so that the correct amount is charged after actual distance and time are known | P1 |
| PAY-007 | System notifies rider of payment failure | As the system, I want to notify the rider if their card authorization or capture fails, so that the rider can take action to resolve the issue | P1 |
| PAY-008 | System blocks rider with outstanding payment failure | As the system, I want to block a rider from booking until they resolve an outstanding payment failure, so that drivers are not exposed to unpaid fares | P1 |

---

### Feature 5.3 — Cash Payment Flow

| ID | Title | User Story | Priority |
|---|---|---|---|
| PAY-009 | System requires dual confirmation for cash | As the system, I want to require both the rider and driver to confirm cash payment before closing a cash trip, so that cash transactions are recorded with agreement from both parties | P1 |
| PAY-010 | System records confirmed cash transaction | As the system, I want to record the cash transaction and the confirmed amount, so that the driver's cash balance ledger is updated accurately | P1 |

---

### Feature 5.4 — Commission & Ledger

| ID | Title | User Story | Priority |
|---|---|---|---|
| PAY-011 | System calculates trip commission | As the system, I want to calculate the platform commission for each completed trip based on the configured rate, so that the correct share is allocated to the platform | P1 |
| PAY-012 | System updates driver cash balance | As the system, I want to add the commission amount to the driver's outstanding cash balance after each cash trip, so that the driver always knows how much they owe the platform | P1 |
| PAY-013 | System reduces driver balance after settlement | As the system, I want to reduce a driver's cash balance when Finance records a settlement, so that the ledger accurately reflects payments made | P1 |

---

### Feature 5.5 — Cancellation Fees, Refunds & Receipts

| ID | Title | User Story | Priority |
|---|---|---|---|
| PAY-014 | System calculates cancellation fee | As the system, I want to calculate a cancellation fee based on the applicable zone rules, so that riders are charged correctly for late cancellations | P1 |
| PAY-015 | System charges or flags cancellation fee | As the system, I want to charge the cancellation fee to the rider's saved card or flag it for manual collection, so that the fee is not lost | P1 |
| PAY-016 | System generates trip receipt | As the system, I want to generate and store a trip receipt at the end of every completed trip, so that both rider and driver have a record of the transaction | P1 |
| PAY-017 | Finance initiates rider refund | As a Finance user, I want to initiate a manual refund for a rider through the admin portal, so that payment errors and disputes are resolved promptly | P1 |
| PAY-018 | System processes refund via PSP | As the system, I want to process the refund instruction via the PSP and confirm the outcome, so that the rider receives the money and the transaction is recorded | P1 |

---

## Module 6 — Trip & Dispatch Engine

### Feature 6.1 — Matching & Broadcast

| ID | Title | User Story | Priority |
|---|---|---|---|
| TRIP-001 | System identifies eligible drivers near pickup | As the system, I want to identify all online drivers in or near the rider's pickup zone, so that a pool of candidates is ready for matching | P1 |
| TRIP-002 | System filters drivers by zone, availability, and rating | As the system, I want to filter candidate drivers by availability, working zone, and minimum rating threshold, so that only suitable drivers are offered the ride | P1 |
| TRIP-003 | System broadcasts ride request to drivers | As the system, I want to broadcast the ride request to eligible drivers in priority order within a configurable timeout, so that the fastest available driver can accept | P1 |
| TRIP-004 | System assigns ride to first accepting driver | As the system, I want to assign the ride to the first driver who accepts, with atomic locking to prevent double-assignment, so that only one driver is ever matched to a ride | P1 |
| TRIP-005 | System reassigns ride on driver decline or timeout | As the system, I want to move to the next eligible driver if the current one declines or times out, so that the rider's wait time is minimised | P1 |
| TRIP-006 | System notifies rider when no driver is available | As the system, I want to notify the rider that no driver is available and place the request in a retry queue, so that the rider is informed and the request is not simply dropped | P2 |

---

### Feature 6.2 — Trip State Machine

| ID | Title | User Story | Priority |
|---|---|---|---|
| TRIP-007 | System manages trip through state machine | As the system, I want to manage the trip through a defined state machine: Requested → Matched → Driver Arrived → In Progress → Completed / Cancelled, so that every stage is tracked and transitions are controlled | P1 |
| TRIP-008 | System prevents invalid state transitions | As the system, I want to prevent invalid state transitions, so that data integrity is maintained and billing is triggered only at the correct moments | P1 |
| TRIP-009 | System timestamps every state transition | As the system, I want to record a timestamp at every state transition, so that SLA tracking, billing, and audit all have accurate time references | P1 |

---

### Feature 6.3 — Location & ETA

| ID | Title | User Story | Priority |
|---|---|---|---|
| TRIP-010 | System streams driver location to rider | As the system, I want to stream the driver's GPS location to the rider app in real time during an active trip, so that the rider always knows where the driver is | P1 |
| TRIP-011 | System streams driver location to Ops portal | As the system, I want to stream the driver's GPS location to the Ops portal for live monitoring, so that the operations team can oversee all active trips | P1 |
| TRIP-012 | System calculates and updates driver ETA | As the system, I want to calculate and update the driver's ETA to the pickup point as they move, so that the rider sees an accurate, live arrival estimate | P1 |

---

### Feature 6.4 — Geofencing & Operating Hours

| ID | Title | User Story | Priority |
|---|---|---|---|
| TRIP-013 | System detects driver arrival at pickup geofence | As the system, I want to detect when the driver enters the pickup geofence and trigger the arrival state, so that the rider is notified automatically | P1 |
| TRIP-014 | System detects driver arrival at drop-off geofence | As the system, I want to detect when the driver enters the drop-off geofence to support trip completion, so that the trip end is confirmed accurately | P2 |
| TRIP-015 | System rejects rides outside operating hours | As the system, I want to reject any new ride request submitted outside the defined operating hours, so that the platform only accepts bookings within the daytime window | P1 |
| TRIP-016 | System displays platform closed message | As the system, I want to display a clear message to the rider when the platform is not accepting rides, so that riders understand why they cannot book | P1 |

---

## Module 7 — Pricing & Neighborhood Zones

### Feature 7.1 — Zone Definition

| ID | Title | User Story | Priority |
|---|---|---|---|
| ZONE-001 | Admin draws zone polygon | As an Admin, I want to draw a polygon on a map to define a new neighborhood zone, so that the platform can operate pricing and matching at the neighborhood level | P1 |
| ZONE-002 | Admin names and saves zone | As an Admin, I want to name, label, and save a zone, so that it is available for pricing configuration and driver zone selection | P1 |
| ZONE-003 | Admin edits zone boundary | As an Admin, I want to edit the boundary of an existing zone, so that zone definitions stay accurate as operational areas change | P2 |
| ZONE-004 | Admin deactivates zone | As an Admin, I want to deactivate a zone without erasing its historical data, so that past pricing and trip records remain intact | P2 |
| ZONE-005 | System resolves GPS coordinate to zone | As the system, I want to determine which zone a GPS coordinate belongs to, so that the correct pricing rules and driver filters are applied to every trip | P1 |

---

### Feature 7.2 — Pricing Rules

| ID | Title | User Story | Priority |
|---|---|---|---|
| ZONE-006 | Admin sets base fare per zone | As an Admin, I want to set a base fare for each zone, so that every trip in that zone starts from the correct floor price | P1 |
| ZONE-007 | Admin sets per-km rate per zone | As an Admin, I want to set a per-km rate for each zone, so that distance is priced appropriately for that neighborhood | P1 |
| ZONE-008 | Admin sets per-minute rate per zone | As an Admin, I want to set a per-minute rate for each zone, so that time spent in traffic is accounted for in the fare | P1 |
| ZONE-009 | Admin sets minimum fare per zone | As an Admin, I want to set a minimum fare for each zone, so that very short trips still cover a minimum viable threshold | P1 |
| ZONE-010 | Admin sets cross-zone pricing rules | As an Admin, I want to define pricing rules for trips that originate in one zone and end in another, so that cross-zone journeys are priced fairly | P1 |
| ZONE-011 | Admin sets cancellation fees per zone | As an Admin, I want to set cancellation fee rules (flat or percentage) for each zone, so that late cancellations are handled consistently | P1 |
| ZONE-012 | System calculates fare estimate | As the system, I want to calculate a fare estimate using the active pricing rules for the rider's origin zone, so that the rider sees an accurate price before confirming the booking | P1 |
| ZONE-013 | System calculates final fare at trip end | As the system, I want to calculate the final fare at trip end using the active pricing rule version, so that billing is based on the rules in effect when the trip started | P1 |

---

### Feature 7.3 — Rule Versioning

| ID | Title | User Story | Priority |
|---|---|---|---|
| ZONE-014 | Admin publishes new pricing rule version | As an Admin, I want to publish a new pricing rule set as a versioned snapshot with a timestamp, so that the full history of pricing changes is available for audit | P1 |
| ZONE-015 | Admin views pricing version history | As an Admin, I want to view the history of all published pricing rule versions, so that I can understand what changed and when | P2 |
| ZONE-016 | Admin rolls back pricing rules | As an Admin, I want to roll back to a previous pricing rule version, so that a pricing error can be corrected quickly without re-entering all rules | P2 |

---

## Module 8 — Safety & SOS

### Feature 8.1 — SOS Trigger

| ID | Title | User Story | Priority |
|---|---|---|---|
| SOS-001 | Rider triggers SOS | As a rider, I want to tap an SOS button that is always visible during an active trip, so that I can call for help without navigating through menus | P1 |
| SOS-002 | Driver triggers SOS | As a driver, I want to tap an SOS button that is always visible during an active trip, so that I can call for help without navigating through menus | P1 |
| SOS-003 | System confirms SOS trigger to prevent accidents | As the system, I want to require a confirmation tap to prevent accidental SOS triggers, so that false alerts do not overwhelm the Ops team | P2 |

---

### Feature 8.2 — Data Capture & Alert

| ID | Title | User Story | Priority |
|---|---|---|---|
| SOS-004 | System captures context at SOS trigger | As the system, I want to capture the exact GPS coordinates, trip state, rider identity, driver identity, and vehicle details at the moment of SOS trigger, so that Ops has full context without needing to ask | P1 |
| SOS-005 | System sends real-time alert to Ops queue | As the system, I want to send a real-time alert to the Ops SOS queue within seconds of trigger, so that the team can respond without delay | P1 |
| SOS-006 | System starts SLA timer on SOS creation | As the system, I want to start an SLA timer from the moment the SOS alert is created, so that response time can be tracked and managed | P1 |

---

### Feature 8.3 — Ops Response & Escalation

| ID | Title | User Story | Priority |
|---|---|---|---|
| SOS-007 | Ops sees new SOS alerts in real time | As an Ops user, I want to see new SOS alerts appear in my queue in real time, so that no alert is missed | P1 |
| SOS-008 | Ops claims SOS incident | As an Ops user, I want to claim and open an SOS incident to prevent duplicate handling, so that only one responder manages each event | P1 |
| SOS-009 | Ops logs response actions | As an Ops user, I want to log every action I take in response to an SOS incident, so that the full response chain is documented | P1 |
| SOS-010 | Ops monitors SOS SLA timer | As an Ops user, I want to see the elapsed SLA time for each open SOS incident, so that I can prioritise the oldest or most critical alerts | P1 |
| SOS-011 | Ops escalates SOS to external authorities | As an Ops user, I want to escalate an SOS incident to external authorities and record the escalation details, so that the incident receives the right level of response | P1 |
| SOS-012 | Ops resolves and closes SOS incident | As an Ops user, I want to mark an SOS incident as resolved with a written outcome summary, so that the incident is formally closed with a complete record | P1 |
| SOS-013 | Ops flags SOS for follow-up | As an Ops user, I want to flag an SOS incident for post-incident follow-up review, so that serious or recurring cases receive additional attention | P2 |

---

### Feature 8.4 — Live Trip Sharing & Trusted Contacts

| ID | Title | User Story | Priority |
|---|---|---|---|
| SOS-014 | Rider generates live tracking link | As a rider, I want to generate a shareable live tracking link during any active trip, so that I can let someone I trust follow my journey | P1 |
| SOS-015 | System notifies trusted contacts on SOS | As the system, I want to notify the rider's trusted contacts via SMS or push when the rider triggers SOS, so that the rider's support network is alerted alongside Ops | P1 |
| SOS-016 | Trusted contact views rider live location | As a trusted contact, I want to open the shared link and see the rider's live position, so that I can monitor the situation and act if needed | P1 |

---

### Feature 8.5 — Policy Enforcement

| ID | Title | User Story | Priority |
|---|---|---|---|
| SOS-017 | System blocks male registrations | As the system, I want to prevent any male-identified user from registering as a rider or driver, so that the women-only platform rule is enforced from the point of entry | P1 |
| SOS-018 | System blocks underage registrations | As the system, I want to prevent any user under 18 from registering as a rider or driver, so that the age eligibility rule is consistently enforced | P1 |

---

## Module 9 — Notifications

### Feature 9.1 — Channel Delivery

| ID | Title | User Story | Priority |
|---|---|---|---|
| NOTIF-001 | System sends SMS | As the system, I want to send SMS messages via the configured SMS provider, so that users receive time-critical messages even without an internet connection | P1 |
| NOTIF-002 | System sends push notifications to Rider App | As the system, I want to send push notifications to the Rider App, so that riders are informed of ride events in real time | P1 |
| NOTIF-003 | System sends push notifications to Driver App | As the system, I want to send push notifications to the Driver App, so that drivers receive ride requests and trip updates promptly | P1 |
| NOTIF-004 | System delivers in-app notification banners | As the system, I want to deliver in-app notification banners within both apps, so that users see important updates while actively using the app | P1 |
| NOTIF-005 | System sends transactional emails | As the system, I want to send transactional emails (receipts, account events), so that users have a written record of key platform interactions | P2 |

---

### Feature 9.2 — Critical Event Notifications

| ID | Title | User Story | Priority |
|---|---|---|---|
| NOTIF-006 | System sends OTP via SMS | As the system, I want to send an OTP via SMS during registration and login, so that users can verify their identity securely | P1 |
| NOTIF-007 | System notifies rider of driver match | As the system, I want to notify a rider when a driver has been matched to their ride, so that the rider knows a driver is on the way | P1 |
| NOTIF-008 | System notifies rider of driver arrival | As the system, I want to notify a rider when their driver has arrived at the pickup, so that the rider knows to come outside | P1 |
| NOTIF-009 | System notifies driver of new ride request | As the system, I want to notify a driver when a ride request is broadcast to them, so that the driver can accept or decline quickly | P1 |
| NOTIF-010 | System notifies both parties at trip completion | As the system, I want to notify both rider and driver when a trip is completed, so that both parties can review the fare and submit their rating | P1 |
| NOTIF-011 | System notifies rider of cancellation | As the system, I want to notify a rider when a ride is cancelled by the driver or system, so that the rider can book again without waiting | P1 |
| NOTIF-012 | System notifies driver of onboarding decision | As the system, I want to notify a driver when their onboarding application is approved or rejected, so that the driver knows their status without repeatedly checking the app | P1 |
| NOTIF-013 | System sends SOS alerts with critical priority | As the system, I want to deliver SOS-related notifications with critical priority, bypassing all quiet-hour settings, so that safety messages always get through | P1 |

---

### Feature 9.3 — Reliability & Preferences

| ID | Title | User Story | Priority |
|---|---|---|---|
| NOTIF-014 | System tracks notification delivery status | As the system, I want to track the delivery status of every notification, so that failed deliveries can be identified and retried | P2 |
| NOTIF-015 | System retries failed non-critical notifications | As the system, I want to automatically retry failed non-critical notifications with backoff, so that transient errors do not result in permanently missed messages | P2 |
| NOTIF-016 | User configures notification preferences | As a rider or driver, I want to configure which non-critical notification types I receive, so that I can reduce noise without missing important alerts | P3 |

---

### Feature 9.4 — Template Management

| ID | Title | User Story | Priority |
|---|---|---|---|
| NOTIF-017 | Admin views notification templates | As an Admin, I want to view all notification templates in the portal, so that I have a complete picture of every automated message the platform sends | P2 |
| NOTIF-018 | Admin edits notification template | As an Admin, I want to edit a notification template in Arabic and English, so that message content can be updated without a code deployment | P2 |
| NOTIF-019 | System renders template in user's language | As the system, I want to render a notification template in the recipient's preferred language, so that every user receives messages in Arabic or English as they chose | P1 |

---

## Module 10 — Reporting & Analytics

### Feature 10.1 — Live Operational Dashboard

| ID | Title | User Story | Priority |
|---|---|---|---|
| RPT-001 | Ops views live operational dashboard | As an Ops user, I want to see a real-time dashboard showing active rides, online drivers, and pending requests, so that I can manage daily operations from a single view | P1 |
| RPT-002 | Ops views live SOS count | As an Ops user, I want to see the live SOS incident count on the dashboard, so that I immediately notice when an emergency is open | P1 |

---

### Feature 10.2 — Scheduled Reports

| ID | Title | User Story | Priority |
|---|---|---|---|
| RPT-003 | Ops views daily ride summary | As an Ops user, I want to view a daily ride summary report (total rides, completions, cancellations, revenue), so that I can track daily performance against targets | P2 |
| RPT-004 | Ops views weekly ride summary | As an Ops user, I want to view a weekly ride summary report, so that I can spot trends and issues not visible in a single day | P2 |
| RPT-005 | Ops manager views driver performance report | As an Ops manager, I want to view a driver performance report (trips, ratings, cancellation rate), so that I can identify drivers who need coaching or recognition | P2 |
| RPT-006 | Ops views cancellation analytics | As an Ops user, I want to view a cancellation analytics report (rates by zone, reason, and time of day), so that I can understand and reduce avoidable cancellations | P2 |
| RPT-007 | Finance views payment reconciliation report | As a Finance user, I want to view a payment reconciliation report (cash vs digital, outstanding balances), so that I can reconcile the platform's financials | P2 |
| RPT-008 | Compliance views safety incident report | As a Compliance user, I want to view a safety incident report (SOS events, resolution times, escalations), so that I can assess how well the platform is handling safety events | P2 |
| RPT-009 | Management views zone performance report | As a Management user, I want to view a zone performance report (rides, demand, revenue by zone), so that I can make data-driven decisions about zone coverage and pricing | P3 |
| RPT-010 | Management views KPI dashboard | As a Management user, I want to view a KPI dashboard with top-level business health metrics, so that I can monitor overall platform performance at a glance | P3 |

---

### Feature 10.3 — Export

| ID | Title | User Story | Priority |
|---|---|---|---|
| RPT-011 | User exports report to CSV | As any authorised portal user, I want to export any report to CSV, so that I can work with the data in external tools | P2 |
| RPT-012 | User exports report to Excel | As any authorised portal user, I want to export any report to Excel (.xlsx), so that I can share formatted reports with stakeholders | P2 |

---

## Backlog Summary

| Module | Features | Stories | P1 | P2 | P3 |
|---|---|---|---|---|---|
| Rider App | 10 | 50 | 31 | 13 | 6 |
| Driver App | 10 | 36 | 24 | 9 | 3 |
| Admin & Ops Portal | 10 | 54 | 30 | 19 | 5 |
| Identity & Verification | 5 | 18 | 18 | 0 | 0 |
| Payments | 5 | 18 | 16 | 2 | 0 |
| Trip & Dispatch | 4 | 16 | 14 | 2 | 0 |
| Pricing & Zones | 3 | 16 | 12 | 4 | 0 |
| Safety & SOS | 5 | 18 | 16 | 2 | 0 |
| Notifications | 4 | 19 | 13 | 4 | 1 |
| Reporting & Analytics | 3 | 12 | 2 | 8 | 2 |
| **Total** | **59** | **257** | **176** | **63** | **17** |

---

## Open Questions — Resolve Before Sprint 1

These are blockers that affect acceptance criteria and cannot be assumed:

1. **Operating hours** — exact daytime window (e.g. 06:00–22:00) must be confirmed by Operations before `TRIP-015` and `TRIP-016` can be built
2. **PSP provider** — the specific Payment Service Provider must be selected before any `PAY-*` stories begin
3. **Identity verification provider** — OCR, liveness, and face-match vendor must be contracted before `IDV-001` through `IDV-008` begin
4. **Background check provider** — vendor must be selected before `IDV-013` through `IDV-015` begin
5. **Platform commission rate** — must be agreed before `PAY-011` can be built
6. **Minimum driver rating threshold** — the filter value used in `TRIP-002` must be defined
7. **Driver response timeout window** — the configurable timeout in `TRIP-003` must be specified
8. **Face match confidence threshold** — the acceptance score for `IDV-007` and `IDV-008` must be agreed with the identity provider
