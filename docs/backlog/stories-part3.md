# SheDrive — User Stories Part 3
## Features 8–9: Trip Request & Matching · Driver Trip Acceptance
**Sprint:** 2

---

## [Mobile] #1553 — Rider submits trip request
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to submit a trip request from the home screen so that I can be matched with a nearby driver.

### Background
The rider has already set her pickup location and destination on the home screen and has seen the fare estimate. When she taps "Request Ride," the app sends her trip request to the platform and navigates her to the matching screen. The home screen inputs are not re-validated here — all validation occurred before the estimate was shown. The rider should experience a near-instant transition with no loading friction.

### Field Validation
No input fields on this screen — pickup and destination were captured on the home screen.

### Acceptance Criteria

**Scenario 1 — Successful trip request submission**
- Given the rider is authenticated and on the home screen with a valid pickup and destination set
- When she taps "Request Ride"
- Then the app sends the trip request to the platform
- And the rider is immediately navigated to the matching screen (#1554)
- And a loading indicator is shown briefly during the network call

**Scenario 2 — Network error during submission**
- Given the rider taps "Request Ride"
- When the network request fails (timeout or connectivity loss)
- Then a toast message is shown: "Something went wrong. Please try again."
- And the rider remains on the home screen with her pickup and destination still populated

**Scenario 3 — Server error during submission**
- Given the rider taps "Request Ride"
- When the platform returns a server-side error
- Then a toast message is shown: "Unable to submit request. Please try again."
- And the rider remains on the home screen

### Out of Scope
- Fare confirmation screen
- Scheduled rides
- Multiple stop trips
- Promo code entry
- Trip cancellation flow

### Dependencies
- #1629 — Rider creates trip request (API — must be live)
- #1554 — Rider sees matching screen (must be built)

---

## [Mobile] #1554 — Rider sees matching screen
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a "Finding your driver" screen after submitting my request so that I know the system is actively searching on my behalf.

### Background
After the trip request is created, the rider is taken to the matching screen where the platform searches for a nearby driver. The screen provides animated visual feedback to reassure the rider that the search is in progress. The app polls the match-status endpoint periodically. A cancel button is visible on screen but is non-functional in this sprint (marked as "coming soon" or disabled). When a match is found, the screen transitions to the driver card view (#1555). If no match is found within the matching window, the rider sees the no-driver error screen (#1557).

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Matching screen displays correctly**
- Given the rider has just submitted a trip request
- When the matching screen loads
- Then an animated "Finding your driver..." indicator is displayed
- And the screen shows the rider's pickup area name or address
- And a disabled or visually suppressed "Cancel" button is visible

**Scenario 2 — Driver is matched**
- Given the matching screen is polling for status
- When the platform returns status = matched
- Then the screen transitions to the driver card view (#1555) without requiring any rider action
- And the transition is smooth (no full-page reload)

**Scenario 3 — No driver found**
- Given the matching screen is polling for status
- When the platform returns status = no_driver
- Then the rider is navigated to the no-driver error screen (#1557)

**Scenario 4 — Network error during polling**
- Given the matching screen is actively polling
- When a poll request fails due to network loss
- Then the screen continues to show the searching animation
- And retries the poll after a short interval
- And if connectivity is not restored within a reasonable time, shows a connectivity warning

### Out of Scope
- Trip cancellation (cancel button is visible but non-functional this sprint)
- Ride scheduling
- Driver filtering or preferences

### Dependencies
- #1631 — Rider polls for match status (API — must be live)

---

## [Mobile] #1555 — Rider sees confirmed driver card
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see my matched driver's details after a driver accepts my request so that I know who is coming to pick me up and when to expect them.

### Background
When a driver accepts the trip, the matching screen transitions to display a driver card. The rider sees the driver's name, photo or placeholder avatar, vehicle information (make, model, color, and plate number), star rating, and the estimated arrival time at the pickup location. A map view shows a pin at the driver's current location so the rider can track the driver approaching in real time. This screen marks the start of the active trip flow.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Driver card displays all required fields**
- Given a driver has accepted the rider's trip request
- When the matching screen transitions to the driver card
- Then the rider sees the driver's full name
- And the driver's photo is displayed (or a placeholder avatar if no photo is on file)
- And the vehicle make, model, color, and plate number are displayed
- And the driver's average star rating is shown
- And the estimated arrival time (ETA) at the pickup location is shown

**Scenario 2 — Map pin shows driver location**
- Given the driver card is displayed
- When the map renders
- Then a map pin shows the driver's current location
- And the rider's pickup location is also marked on the map

**Scenario 3 — ETA is unavailable**
- Given the driver card is displayed
- When the platform cannot compute an ETA
- Then "ETA unavailable" or equivalent placeholder text is shown instead of a time value

**Scenario 4 — Driver photo is missing**
- Given the matched driver has no profile photo
- When the driver card renders
- Then a gender-neutral placeholder avatar is displayed in place of a photo

### Out of Scope
- Real-time driver location tracking updates (live GPS trail)
- In-app messaging with driver
- Calling the driver
- Trip cancellation

### Dependencies
- #1631 — Rider polls for match status (API — must be live)
- #1633 — Driver profile retrieval (API — must be live)

---

## [Mobile] #1556 — Rider receives push on match confirmation
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when a driver is matched to my request so that I am informed even if the app is running in the background.

### Background
After a driver accepts the trip, the platform sends a push notification to the rider's device. The notification content is: "Driver found! [Driver name] is on the way." If the rider taps the notification while the app is in the background or closed, the app opens directly to the active trip screen. If the app is already in the foreground, the notification is handled silently and the UI transitions automatically without showing an OS-level banner.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Push notification delivered while app is in background**
- Given the rider's app is in the background and a driver has accepted the trip
- When the platform sends the match-confirmation push
- Then the rider's device displays a notification with the title "Driver found!" and body "[Driver name] is on the way."
- And tapping the notification opens the app to the active trip screen

**Scenario 2 — Push notification delivered while app is in foreground**
- Given the rider's app is in the foreground on the matching screen
- When the match-confirmation push arrives
- Then the app transitions automatically to the driver card / active trip view
- And no duplicate OS-level banner is shown unnecessarily

**Scenario 3 — Push notification token not registered**
- Given the rider's device token has not been registered with the platform
- When the platform attempts to send the match-confirmation push
- Then the push silently fails (no crash)
- And the rider still sees the driver card when she returns to the app (via polling)

**Scenario 4 — Push tapped when app is closed**
- Given the rider's app is fully closed
- When she taps the match-confirmation push notification
- Then the app launches and navigates directly to the active trip screen
- And the rider does not have to navigate manually

### Out of Scope
- Push notification settings management
- SMS fallback for push delivery failures
- In-app notification inbox

### Dependencies
- #1618 — Push notification service integration (must be live)
- #1634 — Match confirmation push trigger (API — must be live)

---

## [Mobile] #1557 — Rider sees no-driver error and returns home
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a clear message when no driver is available so that I understand what happened and can easily try again.

### Background
If all dispatched drivers reject the trip or their acceptance windows expire, or if no online drivers are within range when the request is submitted, the platform marks the trip as expired and notifies the rider. The rider is shown a full-screen or prominent error state with a human-friendly message and a single call-to-action to return to the home screen and resubmit. The rider should not feel abandoned — the screen must convey that the situation is temporary.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — No-driver error screen displays correctly**
- Given the platform has marked the rider's trip as expired (no driver found)
- When the matching screen receives the no_driver status
- Then the rider sees the message "No drivers available right now"
- And a supportive sub-message is shown (e.g., "Please try again in a few minutes")
- And a "Try Again" button is displayed prominently

**Scenario 2 — Rider taps "Try Again"**
- Given the no-driver error screen is displayed
- When the rider taps "Try Again"
- Then the rider is returned to the home screen
- And her previously entered pickup and destination are pre-populated
- And she can immediately re-submit the request

**Scenario 3 — Rider receives push notification for no-driver**
- Given the platform has expired the trip
- When the push notification is received (from #1632)
- Then the notification reads "We couldn't find a driver. Please try again."
- And tapping the notification while app is backgrounded opens the app to the no-driver error screen

**Scenario 4 — Network error prevents status update**
- Given the rider is on the matching screen and the network is lost
- When connectivity is restored
- And the poll returns no_driver status
- Then the no-driver error screen is shown correctly

### Out of Scope
- Automatic retry without rider action
- Queueing the request for when a driver becomes available
- Driver availability map

### Dependencies
- #1632 — Trip expires and rider is notified via push (API — must be live)

---

## [API] #1629 — Rider creates trip request
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the rider app, I want to submit a trip request with pickup and destination coordinates so that the platform can create a trip record and begin the matching process.

### Background
This is the authenticated endpoint called when a rider taps "Request Ride." The platform receives pickup and destination locations, validates that they are distinct and within the supported service area, creates a trip record with status = "searching," and immediately triggers the internal matching process (#1630). The endpoint returns a trip ID that the rider app uses to poll for match status (#1631). Only riders with an active session may call this endpoint.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| pickup | Yes | Object: lat/lng pair or place_id string | — | — | Numeric coordinates or alphanumeric place ID | "Pickup location is required" | "Invalid pickup location format" | — |
| pickup.lat | Conditional (if no place_id) | Decimal number | -90 | 90 | Digits, decimal point, optional leading minus | "Pickup latitude is required" | "Pickup latitude must be a number between -90 and 90" | — |
| pickup.lng | Conditional (if no place_id) | Decimal number | -180 | 180 | Digits, decimal point, optional leading minus | "Pickup longitude is required" | "Pickup longitude must be a number between -180 and 180" | — |
| destination | Yes | Object: lat/lng pair or place_id string | — | — | Numeric coordinates or alphanumeric place ID | "Destination is required" | "Invalid destination location format" | — |
| destination.lat | Conditional (if no place_id) | Decimal number | -90 | 90 | Digits, decimal point, optional leading minus | "Destination latitude is required" | "Destination latitude must be a number between -90 and 90" | — |
| destination.lng | Conditional (if no place_id) | Decimal number | -180 | 180 | Digits, decimal point, optional leading minus | "Destination longitude is required" | "Destination longitude must be a number between -180 and 180" | — |

### Acceptance Criteria

**Scenario 1 — Successful trip request creation**
- Given an authenticated rider submits a valid pickup and destination that are distinct locations
- When the endpoint is called
- Then a trip record is created with status = "searching"
- And the matching process (#1630) is triggered
- And the response includes the new trip ID

**Scenario 2 — Pickup equals destination**
- Given an authenticated rider submits a pickup location identical to the destination
- When the endpoint is called
- Then a validation error is returned: "Pickup and destination must be different locations"
- And no trip record is created

**Scenario 3 — Pickup field is missing**
- Given an authenticated rider submits a request with no pickup location
- When the endpoint is called
- Then a validation error is returned: "Pickup location is required"

**Scenario 4 — Destination field is missing**
- Given an authenticated rider submits a request with no destination
- When the endpoint is called
- Then a validation error is returned: "Destination is required"

**Scenario 5 — Invalid coordinate format**
- Given an authenticated rider submits coordinates outside the valid range (e.g., lat = 999)
- When the endpoint is called
- Then a validation error is returned indicating the invalid field and its constraint

**Scenario 6 — Unauthenticated request**
- Given a request is made without a valid session token
- When the endpoint is called
- Then the request is rejected with an authentication error
- And no trip record is created

**Scenario 7 — Rider already has an active trip**
- Given a rider already has a trip in "searching" or "matched" status
- When she attempts to create another trip request
- Then a conflict error is returned: "You already have an active trip request"

### Out of Scope
- Fare estimation (handled before request submission)
- Scheduled trips
- Multiple destinations
- Promo code processing

### Dependencies
- #1619 — Session validation (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1630 — System matches request to nearest available driver
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically match a new trip request to the nearest online, available driver so that the rider is connected to a driver as quickly as possible.

### Background
This is an internal platform orchestration process triggered immediately after a trip request is created (#1629). It is not called directly by any client app. The process queries for online, approved drivers who do not have an active trip, ranks them by distance to the rider's pickup location, and dispatches the trip to the nearest driver via #1647. If no eligible drivers are found, the trip is immediately marked as expired and the rider is notified (#1632). If a driver rejects or times out, the process continues to the next nearest driver via #1651.

### Field Validation
No direct input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Nearest driver found and dispatched**
- Given a trip request enters "searching" status
- When the matching process runs
- Then the nearest online, approved driver without an active trip is identified
- And the trip request is dispatched to that driver (#1647)
- And the trip record is updated to reflect the driver currently being evaluated

**Scenario 2 — No eligible drivers available**
- Given a trip request enters "searching" status
- When no online, approved, available drivers exist within the service area
- Then the trip is marked as expired immediately
- And the rider is notified via push that no driver was found (#1632)

**Scenario 3 — Driver rejects or times out — next driver tried**
- Given a trip has been dispatched to a driver
- When that driver rejects or the 10-second window expires (#1651)
- Then the matching process selects the next nearest eligible driver
- And dispatches the trip to that driver

**Scenario 4 — All drivers exhaust without acceptance**
- Given the trip has been dispatched to all eligible drivers in sequence
- When every driver has rejected or timed out
- Then the trip is marked as expired
- And the rider is notified via push (#1632)

### Out of Scope
- Driver preference filters (gender, vehicle type)
- Surge pricing
- Batch matching for multiple simultaneous requests
- SOS trip prioritization

### Dependencies
- #1619 — Session validation (must be live)
- #1645 — Driver online status and location tracking (must be live)
- #1647 — System pushes trip request to matched driver (must be live)
- #1632 — Trip expires and rider is notified via push (must be live)

---

## [API] #1631 — Rider polls for match status
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the rider app, I want to poll the platform for the current match status of my trip request so that the UI can transition from "searching" to the driver card when a match is confirmed.

### Background
After creating a trip request, the rider app calls this endpoint periodically (e.g., every 2–3 seconds) to check whether a driver has been matched. The endpoint returns the current trip status: searching, matched, or no_driver. When the status is matched, the response also includes the driver's name, vehicle details, star rating, and ETA to the pickup location, as well as the driver's live location for the map pin. When the status is no_driver, the app navigates the rider to the error screen. This endpoint is authenticated and scoped to the requesting rider's own trip.

### Field Validation
No input fields — the trip ID is derived from the rider's active session or passed as a path parameter.

### Acceptance Criteria

**Scenario 1 — Trip is still searching**
- Given an authenticated rider polls for match status
- When the trip is still in "searching" status
- Then the response returns status = searching
- And no driver details are included

**Scenario 2 — Trip is matched**
- Given an authenticated rider polls for match status
- When a driver has accepted the trip
- Then the response returns status = matched
- And the response includes: driver name, driver photo URL (or null), vehicle make, model, color, plate number, star rating, ETA to pickup, and driver's current lat/lng

**Scenario 3 — Trip has expired (no driver found)**
- Given an authenticated rider polls for match status
- When the trip has been marked as expired
- Then the response returns status = no_driver
- And the rider app navigates to the no-driver error screen

**Scenario 4 — Trip not found**
- Given an authenticated rider polls with a trip ID that does not exist or belongs to another rider
- When the endpoint is called
- Then a not-found error is returned

**Scenario 5 — Unauthenticated request**
- Given a request is made without a valid session token
- When the endpoint is called
- Then the request is rejected with an authentication error

### Out of Scope
- WebSocket or server-sent event streaming (polling only this sprint)
- Polling rate limiting (handled client-side)
- Historical trip status history

### Dependencies
- #1619 — Session validation (must be live)
- #1629 — Rider creates trip request (must be live)

---

## [API] #1632 — Trip expires and rider is notified via push
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to mark a trip as expired and send a push notification to the rider when no driver accepts so that the rider is promptly informed and can choose to try again.

### Background
This is an internal platform process triggered by #1630 when the matching pool is exhausted — either no drivers were available at all, or all dispatched drivers rejected or timed out. The platform marks the trip record status as expired and sends a push notification to the rider's registered device: "We couldn't find a driver. Please try again." The rider app, on its next poll (#1631), will receive status = no_driver and display the error screen. The push notification provides immediate feedback even if the rider is not actively watching the app.

### Field Validation
No direct input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Trip marked as expired and push sent**
- Given the matching process has exhausted all eligible drivers
- When this process is triggered
- Then the trip record status is updated to expired
- And a push notification is sent to the rider's registered device
- And the push notification reads: "We couldn't find a driver. Please try again."

**Scenario 2 — Rider's device token is not registered**
- Given the rider's push notification token is not on file
- When the platform attempts to send the expiry push
- Then the push silently fails
- And the trip is still marked as expired
- And the rider will see the no-driver status on her next poll

**Scenario 3 — Trip already in a terminal status**
- Given a trip is already in matched or expired status
- When the expiry process is triggered (e.g., due to a race condition)
- Then the trip status is not overwritten
- And no duplicate push notification is sent

### Out of Scope
- Automatic re-queuing of the expired trip
- Rider compensation or credits for no-driver situations
- SMS fallback for push failures

### Dependencies
- #1619 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [Mobile] #1581 — Driver receives push for incoming trip request
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to receive a push notification when a new trip request is assigned to me so that I can respond within the acceptance window even if the app is in the background.

### Background
When the platform dispatches a trip to a matched driver (#1647), a push notification is sent to the driver's registered device. The notification displays the pickup area and estimated fare so the driver can make an informed decision before opening the app. Tapping the notification opens the trip request details screen (#1582) with the 10-second countdown already running. If the driver does not tap the notification in time, the countdown expires on the server side regardless, and the screen auto-dismisses if the driver opens the app late.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Push notification delivered while driver app is in background**
- Given the driver is online and her app is in the background
- When a trip is dispatched to her
- Then her device displays a push notification with the pickup area name and estimated fare
- And the notification title indicates an incoming trip request (e.g., "New trip request!")
- And tapping the notification opens the trip request details screen (#1582) with the countdown running

**Scenario 2 — Push notification delivered while driver app is in foreground**
- Given the driver's app is open and in the foreground
- When a trip is dispatched to her
- Then the app navigates automatically to the trip request details screen (#1582)
- And the countdown begins immediately
- And no duplicate OS banner is shown unnecessarily

**Scenario 3 — Driver app is fully closed**
- Given the driver's app is closed
- When a push notification arrives for an incoming trip
- Then the device displays the notification
- And tapping it launches the app and navigates to the trip request details screen (#1582)
- And if the 10-second window has already expired by the time the screen loads, the screen shows "Request expired" and the driver returns to her home screen

**Scenario 4 — Driver's device token is not registered**
- Given the driver's push notification token is not on file
- When the platform dispatches a trip to her
- Then the push silently fails
- And after the 10-second window elapses with no response, the system treats it as a timeout and reassigns the trip (#1651)

### Out of Scope
- In-app notification inbox
- SMS fallback for push failures
- Audio or vibration settings management

### Dependencies
- #1618 — Push notification service integration (must be live)
- #1647 — System pushes trip request to matched driver (API — must be live)

---

## [Mobile] #1582 — Driver sees trip request details
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to see full trip request details with a countdown timer so that I can decide to accept or reject within the 10-second window.

### Background
When a driver receives a trip request (via push notification or app foreground transition), she is shown a full-screen or modal trip request details screen. The screen displays the pickup address, destination summary, estimated distance, and estimated fare. A 10-second countdown timer is prominently visible and begins immediately when the screen loads. Two action buttons are shown: "Accept" and "Reject." If the timer reaches zero without action, the screen auto-dismisses, a brief "Request expired" message is shown, and the driver returns to her home/available screen. The system treats the non-response as a rejection and reassigns the trip.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Trip request details screen displays correctly**
- Given a trip has been dispatched to the driver
- When the trip request details screen loads
- Then the pickup address is displayed
- And the destination summary is displayed
- And the estimated distance is displayed
- And the estimated fare is displayed
- And a 10-second countdown timer is prominently shown
- And "Accept" and "Reject" buttons are both visible and tappable

**Scenario 2 — Countdown timer counts down visibly**
- Given the trip request details screen is open
- When time passes
- Then the countdown timer decrements visibly second by second
- And the timer urgency is communicated clearly (e.g., color change at 3 seconds)

**Scenario 3 — Timer expires without driver action**
- Given the driver does not tap Accept or Reject within 10 seconds
- When the countdown reaches zero
- Then the screen auto-dismisses
- And a brief "Request expired" toast or message is shown
- And the driver is returned to her home/available screen
- And the system treats the non-response as a rejection and reassigns (#1651)

**Scenario 4 — Driver is offline when screen loads**
- Given the driver's device loses connectivity while the request screen is open
- When the timer expires
- Then the screen dismisses locally
- And when connectivity is restored, the driver is on her home/available screen
- And the server has already reassigned the trip

### Out of Scope
- Driver chat or messaging before acceptance
- Viewing the rider's profile or rating before accepting
- Fare negotiation
- Trip cancellation after acceptance (separate feature)

### Dependencies
- #1648 — Driver retrieves pending trip request (API — must be live)

---

## [Mobile] #1583 — Driver accepts trip
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Accept" on the trip request screen so that the trip is confirmed and I can begin navigating to the rider's pickup location.

### Background
When the driver taps "Accept" within the 10-second window, the app calls the accept endpoint (#1649). On success, the trip status is updated to accepted, and the driver is taken to the navigation-to-pickup screen (active trip feature). Simultaneously, the rider receives a push confirmation that her driver is on the way (#1634). If the acceptance window has already expired server-side (e.g., due to network lag), the endpoint returns a conflict and the driver sees an expired message and returns to her home screen.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Successful acceptance within window**
- Given the driver taps "Accept" while the countdown is still running
- When the acceptance request reaches the server within the 10-second window
- Then the trip status is updated to accepted
- And the driver is navigated to the active trip / navigation-to-pickup screen
- And the rider receives a push notification confirming the match (#1634)

**Scenario 2 — Acceptance after server-side window expiry**
- Given the driver taps "Accept" but the server has already expired the window (network delay)
- When the endpoint returns a conflict error
- Then the driver sees a message: "This request has expired"
- And the driver is returned to her home/available screen
- And the system has already reassigned the trip

**Scenario 3 — Network error on acceptance**
- Given the driver taps "Accept"
- When the network request fails
- Then a toast is shown: "Network error. Your response was not recorded."
- And the driver remains on the request screen if time permits, or sees the expired message if the countdown has elapsed

**Scenario 4 — Accept button shows loading state**
- Given the driver taps "Accept"
- When the request is in flight
- Then the Accept button shows a loading indicator
- And both buttons are disabled to prevent double submission

### Out of Scope
- Driver navigation / GPS turn-by-turn (active trip feature)
- Calling the rider before pickup
- Rejecting after acceptance

### Dependencies
- #1649 — Driver accepts trip (API — must be live)

---

## [Mobile] #1584 — Driver rejects trip and returns to available
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Reject" on the trip request screen so that I can decline the trip and remain available for other requests.

### Background
A driver may choose to reject a trip request within the 10-second window. Tapping "Reject" calls the rejection endpoint (#1650), which marks the driver as available again and triggers reassignment of the trip to the next nearest driver (#1651). The driver returns to her home/available screen immediately. No penalty or strike is applied in this sprint. If the window has already expired server-side, the rejection call returns a conflict (the rejection is effectively a no-op since the system has already treated it as a timeout).

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Successful rejection within window**
- Given the driver taps "Reject" while the countdown is still running
- When the rejection request reaches the server within the 10-second window
- Then the trip is returned to the platform for reassignment
- And the driver's status is set back to available
- And the driver is returned to her home/available screen immediately

**Scenario 2 — Rejection after server-side window expiry**
- Given the driver taps "Reject" but the server has already expired the window
- When the endpoint returns a conflict error
- Then the driver sees a brief message: "This request has already expired"
- And the driver is returned to her home/available screen
- And no duplicate reassignment is triggered

**Scenario 3 — Network error on rejection**
- Given the driver taps "Reject"
- When the network request fails
- Then a toast is shown: "Network error. Please check your connection."
- And when the countdown expires, the system automatically treats the non-response as a rejection

**Scenario 4 — No penalty applied**
- Given the driver has rejected the trip
- When she is on her home/available screen
- Then her status remains "online" and available for future requests
- And no rejection penalty or notification is shown

### Out of Scope
- Rejection reason collection
- Rejection rate tracking or penalties (future sprint)
- Driver going offline after rejection

### Dependencies
- #1650 — Driver rejects trip (API — must be live)

---

## [Mobile] #1585 — Driver acceptance screen expires after 10 seconds
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want the acceptance screen to automatically dismiss after 10 seconds if I do not respond so that I am not left on a stale screen and the system can reassign the trip promptly.

### Background
If the driver neither accepts nor rejects within the 10-second window, the platform server-side timer expires and triggers reassignment (#1651). On the client side, the countdown UI reaches zero and automatically dismisses the screen. A brief "Request expired" toast or message is displayed so the driver understands what happened. The driver is returned to her home/available screen and remains online. This behavior mirrors a rejection from the platform's perspective.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Screen auto-dismisses at countdown zero**
- Given the driver is on the trip request details screen and does not tap either button
- When the 10-second countdown reaches zero
- Then the screen automatically dismisses without requiring any driver action
- And a brief message is shown: "Request expired"
- And the driver is returned to her home/available screen

**Scenario 2 — Driver remains online after expiry**
- Given the acceptance screen has expired
- When the driver is back on her home/available screen
- Then her online status is preserved
- And she remains eligible for the next dispatched trip

**Scenario 3 — System reassigns the trip**
- Given the driver's 10-second window has expired
- When the server processes the timeout
- Then the trip is passed to the next nearest available driver (#1651)
- And the current driver is not double-dispatched for the same trip

**Scenario 4 — App in background during countdown**
- Given the driver received the push notification but did not open the app
- When 10 seconds elapse from dispatch
- Then the server-side timer expires and reassigns the trip
- And if the driver later opens the app, no acceptance screen is shown for the expired request
- And a brief "Request expired" message is shown if the screen was mid-open

### Out of Scope
- Configurable acceptance window duration
- Penalty or strike for timeout (future sprint)
- Notification to driver that she missed a request (beyond the brief toast)

### Dependencies
- #1651 — Trip is reassigned on rejection or timeout (API — must be live)

---

## [API] #1647 — System pushes trip request to matched driver
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the SheDrive platform, I want to push a trip request notification and pending record to the matched driver so that she can review the details and respond within the acceptance window.

### Background
This is an internal platform process triggered by the matching engine (#1630) after selecting the nearest eligible driver. The process creates a pending trip record for the driver (so she can retrieve details via #1648) and sends a push notification to her registered device with the pickup area and estimated fare. The 10-second server-side acceptance clock starts from the moment this notification is dispatched. The driver app uses the pending record to populate the trip request details screen (#1582).

### Field Validation
No direct client input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Pending trip record created and push sent**
- Given the matching engine has selected a driver
- When this process is triggered
- Then a pending trip record is created associating the driver with the trip
- And a push notification is sent to the driver's registered device
- And the notification includes the pickup area name and estimated fare
- And the server-side 10-second acceptance clock starts

**Scenario 2 — Driver's push token is not registered**
- Given the selected driver's push notification token is not on file
- When the process attempts to send the push
- Then the push silently fails
- And the pending trip record is still created
- And after 10 seconds with no acceptance, the trip is reassigned (#1651)

**Scenario 3 — Driver is no longer available at dispatch time**
- Given the selected driver went offline between matching selection and dispatch
- When this process checks her status at dispatch
- Then the dispatch is aborted for this driver
- And the matching engine is notified to select the next nearest driver

### Out of Scope
- Driver in-app messaging
- Driver acceptance confirmation (handled by #1649)
- Multiple simultaneous dispatch to several drivers

### Dependencies
- #1619 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1648 — Driver retrieves pending trip request
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the details of my pending trip request so that I can display the pickup address, destination, distance, and fare to the driver on the acceptance screen.

### Background
After the driver receives a push notification for an incoming trip, the driver app calls this endpoint to fetch the full trip request details. The endpoint returns the pickup address, destination summary, estimated distance, and estimated fare for the pending trip assigned to this driver. If the 10-second window has already expired (trip reassigned) before the driver's app calls this endpoint, a not-found or expired response is returned and the app shows the "Request expired" message. This endpoint is authenticated and returns only the trip pending for the calling driver.

### Field Validation
No input fields — the pending trip is identified by the authenticated driver's session.

### Acceptance Criteria

**Scenario 1 — Pending trip returned successfully**
- Given an authenticated driver has a pending trip dispatched to her
- When she calls this endpoint
- Then the response includes: pickup address, destination summary, estimated distance, estimated fare
- And the data is sufficient to populate the trip request details screen (#1582)

**Scenario 2 — No pending trip exists**
- Given an authenticated driver has no pending trip (none dispatched, or window already expired)
- When she calls this endpoint
- Then a not-found or "no pending trip" response is returned
- And the driver app shows the "Request expired" message and returns to the home screen

**Scenario 3 — Unauthenticated request**
- Given a request is made without a valid driver session token
- When the endpoint is called
- Then the request is rejected with an authentication error

**Scenario 4 — Trip was reassigned before retrieval**
- Given the 10-second window expired and the trip was reassigned before the driver's app called this endpoint
- When the endpoint is called
- Then an expired or not-found response is returned
- And no trip details are shown to the driver

### Out of Scope
- Rider profile details visible to driver before acceptance
- Destination full address (summary only for privacy at this stage)
- Historical pending trips

### Dependencies
- #1619 — Session validation (must be live)
- #1647 — System pushes trip request to matched driver (must be live)

---

## [API] #1649 — Driver accepts trip
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to submit an acceptance for a pending trip request so that the trip is confirmed and the rider is notified that her driver is on the way.

### Background
This endpoint is called when the driver taps "Accept" on the trip request details screen. The platform checks that the driver's pending trip record still exists and that the 10-second acceptance window has not expired. If valid, the trip status is updated to accepted, the driver's status changes to "on trip," and the rider receives a match-confirmation push (#1634). If the window has already expired (because the server timer elapsed or the trip was reassigned), a conflict error is returned and the acceptance is ignored.

### Field Validation
No input fields — the acceptance is tied to the authenticated driver's pending trip.

### Acceptance Criteria

**Scenario 1 — Successful acceptance within window**
- Given an authenticated driver has a pending trip and the 10-second window is still open
- When she calls the accept endpoint
- Then the trip status is updated to accepted
- And the driver's status is updated to "on trip"
- And the rider receives a push notification confirming the match
- And the response signals success to the driver app

**Scenario 2 — Acceptance window has expired**
- Given an authenticated driver calls the accept endpoint after the 10-second window has elapsed
- When the endpoint processes the request
- Then a conflict error is returned: "Acceptance window has expired"
- And the trip status is not changed (it has already been reassigned or expired)
- And the driver app shows "This request has expired" and returns to the home screen

**Scenario 3 — No pending trip for this driver**
- Given an authenticated driver calls the accept endpoint when she has no pending trip
- When the endpoint processes the request
- Then a not-found error is returned
- And no trip status change occurs

**Scenario 4 — Unauthenticated request**
- Given a request is made without a valid driver session token
- When the endpoint is called
- Then the request is rejected with an authentication error

**Scenario 5 — Duplicate acceptance call**
- Given a driver's acceptance has already been recorded
- When the same accept endpoint is called again (e.g., double-tap)
- Then the endpoint returns a conflict or idempotent success
- And no duplicate state changes occur

### Out of Scope
- Driver navigation / GPS (active trip feature)
- Rider rating or profile visible at acceptance
- Accepting on behalf of another driver

### Dependencies
- #1619 — Session validation (must be live)
- #1648 — Driver retrieves pending trip request (must be live)

---

## [API] #1650 — Driver rejects trip
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to submit a rejection for a pending trip request so that I can decline the trip and the platform can reassign it to another driver.

### Background
This endpoint is called when the driver taps "Reject" on the trip request details screen. The platform marks the driver's pending record as rejected, sets the driver's status back to available, and triggers the reassignment process (#1651). If the 10-second window has already expired server-side (the trip was already reassigned due to timeout), a conflict error is returned — the rejection is a no-op since the system has already handled it. No penalty is applied to the driver in this sprint.

### Field Validation
No input fields — the rejection is tied to the authenticated driver's pending trip.

### Acceptance Criteria

**Scenario 1 — Successful rejection within window**
- Given an authenticated driver has a pending trip and the 10-second window is still open
- When she calls the reject endpoint
- Then the pending trip record is marked as rejected
- And the driver's status is set to available
- And the reassignment process (#1651) is triggered
- And the response signals success to the driver app

**Scenario 2 — Rejection after server-side window expiry**
- Given an authenticated driver calls the reject endpoint after the 10-second window has elapsed
- When the endpoint processes the request
- Then a conflict error is returned: "Acceptance window has already expired"
- And no duplicate reassignment is triggered (the system already handled the timeout)
- And the driver app shows the expired message and returns to the home screen

**Scenario 3 — No pending trip for this driver**
- Given an authenticated driver calls the reject endpoint when she has no pending trip
- When the endpoint processes the request
- Then a not-found error is returned

**Scenario 4 — Unauthenticated request**
- Given a request is made without a valid driver session token
- When the endpoint is called
- Then the request is rejected with an authentication error

**Scenario 5 — Driver status remains available after rejection**
- Given the driver has successfully rejected the trip
- When the response is processed by the driver app
- Then the driver's status is confirmed as available
- And no penalty or flag is recorded against the driver in this sprint

### Out of Scope
- Rejection reason capture
- Rejection rate tracking or thresholds (future sprint)
- Driver going offline via rejection

### Dependencies
- #1619 — Session validation (must be live)
- #1648 — Driver retrieves pending trip request (must be live)
- #1651 — Trip is reassigned on rejection or timeout (must be live)

---

## [API] #1651 — Trip is reassigned on rejection or timeout
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically reassign a trip when a driver rejects it or the acceptance window times out so that the rider is matched to another driver without any manual intervention.

### Background
This internal platform process is triggered in two cases: (1) a driver explicitly rejects via #1650, or (2) the server-side 10-second acceptance timer for a dispatched trip elapses with no acceptance recorded. When triggered, the process marks the current driver dispatch as rejected/timed-out, finds the next nearest eligible driver, and repeats the dispatch (#1647). If no further eligible drivers are available, the trip is expired and the rider is notified (#1632). This process is entirely server-side and not directly callable by client apps.

### Field Validation
No direct client input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Reassignment to next nearest driver**
- Given a driver has rejected a trip or the 10-second window has expired
- When this process is triggered
- Then the current driver dispatch record is marked as rejected or timed-out
- And the next nearest online, approved, available driver is identified
- And the trip is dispatched to that driver (#1647)

**Scenario 2 — No further eligible drivers**
- Given the reassignment process runs and finds no remaining eligible drivers
- When the process completes its search
- Then the trip is marked as expired
- And the rider is notified via push: "We couldn't find a driver. Please try again." (#1632)

**Scenario 3 — Race condition — driver accepted just before timeout**
- Given a driver's acceptance and the server-side timeout arrive nearly simultaneously
- When the acceptance is recorded first
- Then the trip is marked as accepted and this reassignment process is not triggered
- And if the timeout fires first, the acceptance call returns a conflict (#1649)

**Scenario 4 — Repeated reassignment chain**
- Given multiple drivers are tried in sequence
- When each rejects or times out
- Then each rejection triggers another reassignment iteration
- And the process continues until either a driver accepts or the pool is exhausted

### Out of Scope
- Driver penalty for rejection or timeout (future sprint)
- Rider notification of individual reassignment attempts (only final no-driver notification)
- Manual override or admin reassignment

### Dependencies
- #1619 — Session validation (must be live)
- #1630 — System matches request to nearest available driver (must be live)
- #1632 — Trip expires and rider is notified via push (must be live)
