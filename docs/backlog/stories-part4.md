# SheDrive — Feature 10 & 11 User Stories
## Active Trip + Trip Completion & Cash Payment
**Sprint:** 2

---

## [Mobile] #1586 — Driver navigates to pickup
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to see the rider's pickup location on a map and open turn-by-turn navigation so that I can reach the pickup point efficiently.

### Background
After accepting a trip request, the driver's screen displays a map with a pin marking the rider's pickup location. A navigation button allows the driver to deep-link into Google Maps or Waze with the pickup coordinates pre-filled. An "I've Arrived" button is visible at all times so the driver can signal her arrival. The driver's GPS position is streamed every 5 seconds so the rider can track progress in real time.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Map and arrival button are shown after acceptance**
- Given the driver has accepted a trip request
- When the active trip screen loads
- Then the map displays a pin at the rider's pickup coordinates
- And an "I've Arrived" button is visible on screen

**Scenario 2 — Navigation deep-link opens external app**
- Given the driver is on the active trip screen in en_route_pickup state
- When the driver taps the navigation button
- Then the app opens Google Maps (or Waze if installed) with the pickup coordinates pre-filled as the destination
- And the driver returns to the SheDrive active trip screen when she exits the navigation app

**Scenario 3 — Driver location streams to the platform**
- Given the driver is navigating to the pickup location
- When the driver's device has an active GPS signal
- Then the app sends the driver's current latitude and longitude to the platform every 5 seconds
- And those coordinates are available for the rider to see in real time

### Out of Scope
- In-app turn-by-turn navigation
- Automatic ETA calculation in the driver app
- SOS functionality
- Trip cancellation from this screen

### Dependencies
- #1649 — Trip acceptance flow (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1587 — Driver confirms arrival at pickup
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "I've Arrived" when I reach the pickup location so that the rider is notified and I can proceed to board her.

### Background
When the driver reaches the rider's pickup location, she taps the "I've Arrived" button on the active trip screen. This advances the trip state from en_route_pickup to arrived_pickup. The platform immediately sends a push notification to the rider. The driver's screen transitions to show either a "Confirm Rider Identity" button (if it is the rider's first trip) or a "Rider Has Boarded" button (for returning riders).

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver taps "I've Arrived" and state advances**
- Given the driver is on the active trip screen in en_route_pickup state
- When the driver taps "I've Arrived"
- Then the trip state advances to arrived_pickup
- And the platform sends a push notification to the rider

**Scenario 2 — First-trip rider: identity confirmation button appears**
- Given the trip's is_first_trip flag is true
- When the driver taps "I've Arrived" and the state advances to arrived_pickup
- Then the screen shows a "Confirm Rider Identity" button
- And the "Rider Has Boarded" button is not yet accessible

**Scenario 3 — Returning rider: board button appears immediately**
- Given the trip's is_first_trip flag is false
- When the driver taps "I've Arrived" and the state advances to arrived_pickup
- Then the screen shows a "Rider Has Boarded" (Start Trip) button
- And no identity confirmation step is presented

### Out of Scope
- Geofence-based automatic arrival detection
- SOS functionality
- Trip cancellation from this screen

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)

---

## [Mobile] #1588 — Driver confirms rider identity on first trip
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to verify the rider's identity against her registered name on her first trip so that I board the correct passenger.

### Background
When is_first_trip is true, the driver sees the rider's registered full name displayed prominently on the arrived_pickup screen. The driver asks the rider to show a government-issued ID and compares the name. Once satisfied, the driver taps "Identity Confirmed" to proceed to the boarding step. For all returning riders this step is skipped entirely and the driver proceeds directly to the "Start Trip" button.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Identity confirmation screen is shown for first-trip riders**
- Given the driver has arrived at the pickup location
- And the trip's is_first_trip flag is true
- When the arrived_pickup screen loads
- Then the driver sees the rider's registered full name
- And a prominent "Identity Confirmed" button is displayed

**Scenario 2 — Driver confirms identity and proceeds**
- Given the identity confirmation screen is visible
- When the driver taps "Identity Confirmed"
- Then the screen transitions to show the "Start Trip" button
- And the driver can now board the rider

**Scenario 3 — Identity step is skipped for returning riders**
- Given the trip's is_first_trip flag is false
- When the driver arrives and the arrived_pickup screen loads
- Then no identity confirmation step is shown
- And the "Start Trip" button is immediately accessible

### Out of Scope
- Biometric or document scanning
- SOS functionality
- Automatic identity verification via camera

### Dependencies
- #1635 — Trip detail includes first-trip flag (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [Mobile] #1589 — Driver confirms rider has boarded
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "Start Trip" after the rider boards so that the trip officially begins and I can navigate to the destination.

### Background
After the driver has arrived (and confirmed the rider's identity if required), she taps the "Start Trip" button. This advances the trip state from arrived_pickup to trip_started. The map transitions to display the destination pin instead of the pickup pin. The navigation button now deep-links to the destination coordinates. GPS streaming continues throughout.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver taps "Start Trip" and state advances**
- Given the driver is on the arrived_pickup screen
- And identity confirmation has been completed (if required)
- When the driver taps "Start Trip"
- Then the trip state advances to trip_started
- And the map updates to show the destination pin

**Scenario 2 — Navigation button points to destination after boarding**
- Given the trip state is trip_started
- When the driver taps the navigation button
- Then the app opens Google Maps or Waze with the destination coordinates pre-filled
- And the driver returns to the SheDrive active trip screen on exit

**Scenario 3 — "Start Trip" is not accessible before identity confirmation on first trip**
- Given is_first_trip is true and the driver has not yet tapped "Identity Confirmed"
- When the arrived_pickup screen is displayed
- Then the "Start Trip" button is not accessible
- And only the "Identity Confirmed" button is shown

### Out of Scope
- Automatic boarding detection
- SOS functionality

### Dependencies
- #1652 — Driver advances trip state machine (must be live)

---

## [Mobile] #1590 — Driver navigates to destination
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to see the destination on the map and open navigation so that I can bring the rider to her destination safely.

### Background
Once the trip is started, the driver's active trip screen shows a pin at the destination. A navigation button allows the driver to deep-link to Google Maps or Waze with the destination coordinates. An "End Trip" button is visible so the driver can mark completion. GPS streaming continues every 5 seconds so the rider can follow progress on her screen.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Destination pin appears after trip starts**
- Given the trip state has advanced to trip_started
- When the active trip screen is displayed
- Then the map shows a pin at the destination coordinates
- And the pickup pin is no longer shown

**Scenario 2 — Navigation deep-link opens external app with destination**
- Given the trip is in trip_started state
- When the driver taps the navigation button
- Then the app opens Google Maps or Waze with the destination coordinates pre-filled
- And the driver can return to the SheDrive screen on exit

**Scenario 3 — "End Trip" button is visible during navigation**
- Given the trip is in trip_started state
- When the active trip screen is displayed
- Then an "End Trip" button is visible on screen

**Scenario 4 — GPS continues streaming during destination navigation**
- Given the trip is in trip_started state
- When the driver's device has an active GPS signal
- Then the app continues sending the driver's coordinates to the platform every 5 seconds

### Out of Scope
- In-app turn-by-turn navigation
- Geofence-based automatic trip ending
- SOS functionality

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1591 — Driver ends trip at destination
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "End Trip" when I reach the destination so that the fare is calculated and the rider is notified of completion.

### Background
When the driver arrives at the destination, she taps "End Trip" on the active trip screen. This advances the trip state from trip_started to trip_ended. The platform calculates the final fare from the actual distance and duration. The rider receives a push notification with the fare amount and sees the trip summary. The driver is shown the cash collection screen.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver taps "End Trip" and state advances**
- Given the driver is on the active trip screen in trip_started state
- When the driver taps "End Trip"
- Then the trip state advances to trip_ended
- And the platform calculates the final fare

**Scenario 2 — Rider receives push notification on trip end**
- Given the trip state has advanced to trip_ended
- When the fare calculation is complete
- Then the rider receives a push notification with the final fare amount
- And tapping the notification opens the rider's trip summary screen

**Scenario 3 — Driver sees cash collection screen after ending trip**
- Given the trip state has advanced to trip_ended
- When the driver's screen updates
- Then the driver sees the cash fare to collect from the rider
- And a "Done" button is available to dismiss the screen

### Out of Scope
- Automatic trip ending via geofence
- Digital payment processing
- SOS functionality

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1636 — Final fare is calculated from actual route and duration (must be live)

---

## [Mobile] #1558 — Rider sees driver live location while waiting
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location on the map while she heads to my pickup so that I know how close she is.

### Background
After a driver accepts the trip, the rider's active trip screen displays a map with two pins: the rider's pickup location and the driver's current position as a moving dot. The driver's ETA to the pickup is displayed and updated every 5 seconds as the platform receives new GPS coordinates. The rider remains on this screen until the driver marks arrival.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver location dot appears on rider's map**
- Given a driver has accepted the rider's trip
- When the rider opens the active trip screen
- Then a moving dot representing the driver's location is visible on the map
- And the rider's pickup pin is also shown

**Scenario 2 — Driver location updates in near real time**
- Given the active trip screen is displayed in en_route_pickup state
- When the platform receives a new GPS position from the driver
- Then the driver's dot moves to the updated position within 5 seconds
- And the displayed ETA refreshes accordingly

**Scenario 3 — Rider stays on screen until driver arrives**
- Given the trip is in en_route_pickup state
- When the rider is viewing the active trip screen
- Then no automatic navigation away from the screen occurs
- And the screen updates automatically when the driver marks arrival

### Out of Scope
- Turn-by-turn route preview for the rider
- ETA notifications via push during this phase
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1559 — Rider sees driver-arrived state
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want my screen to update when the driver arrives so that I know to head to the pickup point.

### Background
When the driver taps "I've Arrived" and the trip state advances to arrived_pickup, the rider's active trip screen automatically transitions to a "Your driver has arrived" state. The map continues to show the driver's pin at the pickup location. No action is required from the rider on this screen — she simply proceeds to board.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Rider screen transitions to arrived state automatically**
- Given the rider is viewing the active trip screen in en_route_pickup state
- When the trip state advances to arrived_pickup
- Then the rider's screen updates to display a "Your driver has arrived" message
- And no manual refresh is required

**Scenario 2 — Map continues to show driver pin at pickup location**
- Given the trip is in arrived_pickup state on the rider's screen
- When the rider views the map
- Then the driver's pin is shown at the pickup location
- And the rider's pickup pin is also visible

**Scenario 3 — No rider action is required on this screen**
- Given the rider sees the arrived state
- When she views the screen
- Then no buttons requiring rider input are shown
- And the screen simply instructs her to board

### Out of Scope
- Automated check-in for the rider
- Geofence detection on the rider's device
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)

---

## [Mobile] #1560 — Rider receives push when driver arrives
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when my driver arrives so that I know to head to the pickup point even if the app is in the background.

### Background
When the driver taps "I've Arrived", the platform sends a push notification to the rider's device. The notification text is: "سائقتك وصلت! توجهي إلى موقع الانطلاق." Tapping the notification brings the app to the foreground and displays the active trip screen in the arrived_pickup state.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Push notification is received when driver arrives**
- Given the driver has tapped "I've Arrived" and the trip state is arrived_pickup
- When the platform processes the state change
- Then the rider's device receives a push notification
- And the notification text reads "سائقتك وصلت! توجهي إلى موقع الانطلاق."

**Scenario 2 — Tapping notification opens active trip screen**
- Given the rider receives the driver-arrived push notification
- When the rider taps the notification
- Then the SheDrive app opens (or comes to foreground)
- And the active trip screen is displayed in arrived_pickup state

**Scenario 3 — Push is delivered even when app is backgrounded**
- Given the rider's app is not in the foreground
- When the driver marks arrival
- Then the push notification still appears on the rider's device lock screen or notification tray

### Out of Scope
- SMS or email arrival alerts
- In-app banner if app is already in foreground (handled by screen transition in #1559)
- SOS functionality

### Dependencies
- #1618 — Push notification service (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)

---

## [Mobile] #1561 — Rider sees driver live location during trip
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location on the map while we travel to the destination so that I can follow our progress.

### Background
Once the driver taps "Start Trip" and the state advances to trip_started, the rider's map updates to show the driver's location moving toward the destination. The destination pin is visible on the map. GPS coordinates received from the driver every 5 seconds update the moving dot in near real time. The rider remains on this screen until the trip ends.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver dot continues moving during trip**
- Given the trip state is trip_started
- When the rider views the active trip screen
- Then the driver's location dot is visible on the map and updates as the driver moves
- And the destination pin is shown on the map

**Scenario 2 — Location updates in near real time during trip**
- Given the trip is in trip_started state
- When the platform receives a new GPS position from the driver
- Then the driver's dot on the rider's map moves to the new position within 5 seconds

**Scenario 3 — Rider screen transitions automatically on trip end**
- Given the rider is watching the map during trip_started state
- When the driver taps "End Trip" and the state advances to trip_ended
- Then the rider's screen automatically transitions to the trip summary

### Out of Scope
- Route polyline rendering on the rider's map
- Estimated arrival time to destination for the rider
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1562 — Rider sees driver details during trip
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's name, photo, and vehicle details throughout the trip so that I can confirm I am with the correct driver.

### Background
Throughout the active trip — from en_route_pickup through trip_ended — the rider sees a persistent driver card on the active trip screen. The card displays the driver's name, profile photo (or a placeholder avatar if no photo is set), vehicle make and model, vehicle color, and license plate number. This information is sourced from the trip details returned by the platform.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver card shows name and vehicle details**
- Given the rider is on the active trip screen in any active state
- When the driver card is rendered
- Then the driver's full name is displayed
- And the vehicle make, model, color, and plate number are displayed

**Scenario 2 — Driver photo or placeholder is shown**
- Given the rider is viewing the driver card
- When the driver has a profile photo on file
- Then the driver's profile photo is shown in the card avatar
- And when the driver has no profile photo, a placeholder avatar is shown instead

**Scenario 3 — Driver card is visible across all active states**
- Given the trip is in en_route_pickup, arrived_pickup, or trip_started state
- When the rider views the active trip screen
- Then the driver card remains visible without requiring any action

### Out of Scope
- Rider-initiated contact with the driver (chat or call)
- Sharing driver details with a third party from this screen
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)

---

## [API] #1652 — Driver advances trip state machine
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the driver app, I want to advance the trip state through each stage so that all downstream screens and notifications are triggered correctly.

### Background
This is the core state-transition endpoint consumed by the driver app. An authenticated driver sends the desired next state for an active trip. The platform validates that the new state follows the required sequence (accepted → en_route_pickup → arrived_pickup → trip_started → trip_ended) and rejects any attempt to skip a state. Each successful transition triggers the appropriate side effects: pushing a notification to the rider on arrived_pickup, calculating the fare on trip_ended, and making the new state immediately visible to the rider app via #1633.

### Field Validation
State transitions are validated by the platform. Skipping states is rejected. No free-text input fields.

### Acceptance Criteria

**Scenario 1 — Valid state transition is accepted**
- Given an authenticated driver has an active trip in state S
- When the driver app sends the next valid state S+1
- Then the platform updates the trip record to the new state
- And the appropriate side effects are triggered

**Scenario 2 — Skipping a state is rejected**
- Given an active trip is in en_route_pickup state
- When the driver app sends trip_started (skipping arrived_pickup)
- Then the platform rejects the request
- And the trip remains in en_route_pickup state

**Scenario 3 — Arrived_pickup triggers rider push**
- Given an active trip is in en_route_pickup state
- When the driver advances state to arrived_pickup
- Then the platform sends a push notification to the rider via #1634

**Scenario 4 — Trip_ended triggers fare calculation**
- Given an active trip is in trip_started state
- When the driver advances state to trip_ended
- Then the platform triggers final fare calculation via #1636
- And the rider is notified via #1638

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets the state-advance endpoint
- Then the platform rejects the request
- And the trip state is unchanged

### Out of Scope
- Reverse state transitions
- Admin-initiated state changes
- SOS state handling

### Dependencies
- #1619 — Authentication service (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)
- #1636 — Final fare calculation (must be live)
- #1638 — System pushes trip completion to rider (must be live)

---

## [API] #1653 — Driver streams GPS from acceptance to completion
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the driver app, I want to send my GPS coordinates to the platform throughout the trip so that the rider can track my live location.

### Background
From the moment a driver accepts a trip until the trip reaches trip_ended, the driver app calls the location update endpoint every 5 seconds with the current latitude and longitude. This endpoint (the same contract as #1646 for driver availability) associates the incoming coordinates with the active trip record, making them immediately available to the rider app through #1633. The platform uses these coordinates to update the rider's map in near real time.

### Field Validation
Payload is the same lat/lng structure as #1646. No additional validation for this story.

### Acceptance Criteria

**Scenario 1 — Driver coordinates are associated with the active trip**
- Given the driver has an active trip and is sending GPS updates
- When the platform receives a location update
- Then the coordinates are stored against the active trip record
- And the rider app can retrieve the updated location via #1633

**Scenario 2 — Location updates are available in near real time**
- Given the driver sends a GPS update
- When the rider app polls or receives the update via #1633
- Then the driver's position reflects the most recent coordinate within 5 seconds

**Scenario 3 — Streaming stops after trip_ended**
- Given the trip has advanced to trip_ended
- When the driver app sends a GPS update
- Then the update is not associated with a completed trip
- And no live location data is served to the rider for this trip

**Scenario 4 — Unauthenticated GPS updates are rejected**
- Given a GPS update arrives without a valid driver auth token
- When it targets the location streaming endpoint
- Then the platform rejects the update

### Out of Scope
- Historical route replay
- GPS accuracy validation
- Battery optimization on the driver device

### Dependencies
- #1619 — Authentication service (must be live)
- #1646 — Driver location update endpoint (must be live)

---

## [API] #1633 — Rider retrieves live trip state and driver location
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the rider app, I want to poll the platform for the current trip state and driver location so that the rider's screen always reflects reality.

### Background
The rider app calls this endpoint periodically (approximately every 5 seconds) while the trip is active. The response includes the current trip state, the driver's last known GPS coordinates, the driver's ETA to the pickup point (included while in en_route_pickup state, omitted once the trip has started), and the driver card details (name, photo, vehicle, plate). The rider app uses this data to update the map dot, the ETA display, and the driver card without requiring a page reload.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Response includes trip state and driver location**
- Given an authenticated rider has an active trip
- When the rider app calls this endpoint
- Then the response includes the current trip state
- And the driver's last known latitude and longitude

**Scenario 2 — ETA is included while driver is en route to pickup**
- Given the trip is in en_route_pickup state
- When the rider app calls this endpoint
- Then the response includes the driver's estimated arrival time to the pickup location

**Scenario 3 — ETA is omitted once the trip has started**
- Given the trip is in trip_started state
- When the rider app calls this endpoint
- Then the response does not include an ETA field
- And the driver's GPS position continues to be returned

**Scenario 4 — Driver card details are included in the response**
- Given an active trip exists
- When the rider app calls this endpoint
- Then the response includes the driver's name, profile photo URL (or null), vehicle make, model, color, and plate number

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- WebSocket or server-sent event push (polling model only for MVP)
- Trip history retrieval
- Driver contact details

### Dependencies
- #1619 — Authentication service (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [API] #1634 — System pushes driver-arrived to rider
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when the driver marks arrival so that the rider is alerted even if the app is backgrounded.

### Background
This is an internal platform process, not a direct app call. When the driver advances the trip state to arrived_pickup via #1652, the state machine immediately triggers a push notification to the rider's registered device. The notification text is "سائقتك وصلت!" and is delivered via the push service established in #1618. No app-to-platform call initiates this — it is purely event-driven.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on arrived_pickup transition**
- Given a driver has advanced a trip to arrived_pickup state
- When the platform processes the state transition
- Then a push notification is sent to the rider's device automatically
- And no separate API call from any app is required to trigger it

**Scenario 2 — Push text is correct**
- Given the arrived_pickup push is triggered
- When the notification is delivered
- Then the notification text reads "سائقتك وصلت!"

**Scenario 3 — Push failure does not block the state transition**
- Given the push delivery service is temporarily unavailable
- When the driver advances to arrived_pickup
- Then the trip state is still saved as arrived_pickup
- And the platform logs the push delivery failure for retry

### Out of Scope
- SMS fallback for push delivery failures
- Rider acknowledgement of the push
- SOS notifications

### Dependencies
- #1619 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1635 — Trip detail includes first-trip flag
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the driver app, I want the trip detail response to include a first-trip flag so that I know whether to show the identity verification step before starting the trip.

### Background
When the driver app fetches the active trip details, the response includes a boolean field is_first_trip. This field is true if the trip belongs to a rider who has never previously completed a trip on SheDrive. It is derived from the rider's trip history at the time the trip is created and stored on the trip record. The driver app reads this flag to conditionally display the identity confirmation step (#1588).

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — is_first_trip is true for a rider's very first trip**
- Given a rider has no prior completed trips on SheDrive
- When the driver app fetches the trip detail
- Then the response includes is_first_trip: true

**Scenario 2 — is_first_trip is false for returning riders**
- Given a rider has at least one previously completed trip on SheDrive
- When the driver app fetches the trip detail
- Then the response includes is_first_trip: false

**Scenario 3 — Flag is stable throughout the trip lifecycle**
- Given the trip was created with is_first_trip: true
- When the driver fetches trip details at any point during the trip
- Then the is_first_trip value remains true and does not change mid-trip

**Scenario 4 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets the trip detail endpoint
- Then the platform rejects the request

### Out of Scope
- Recalculating first-trip status after trip creation
- Exposing this flag to the rider app
- Historical trip count in the response

### Dependencies
- #1619 — Authentication service (must be live)
- #1629 — Rider profile with trip history (must be live)

---

## [Mobile] #1563 — Rider receives push on trip completion
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when my trip ends so that I know the fare and can review my trip summary.

### Background
When the driver taps "End Trip" and the trip state advances to trip_ended, the platform sends a push notification to the rider. The notification text includes the final fare: "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." where [X] is the calculated fare in Egyptian Pounds. Tapping the notification brings the SheDrive app to the foreground and displays the trip summary screen.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Push notification is received when trip ends**
- Given the driver has tapped "End Trip" and the trip state is trip_ended
- When the platform processes the state change and fare calculation is complete
- Then the rider's device receives a push notification
- And the notification text includes the final fare in EGP

**Scenario 2 — Notification text format is correct**
- Given the final fare is calculated
- When the trip completion push is sent
- Then the notification text reads "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." with the actual fare substituted

**Scenario 3 — Tapping notification opens trip summary**
- Given the rider receives the trip completion push notification
- When the rider taps the notification
- Then the SheDrive app opens or comes to the foreground
- And the trip summary screen is displayed

**Scenario 4 — Push is delivered even when app is backgrounded**
- Given the rider's app is not in the foreground when the trip ends
- When the platform sends the completion push
- Then the notification appears on the device's lock screen or notification tray

### Out of Scope
- Email or SMS receipt
- In-app banner if app is already in foreground (handled by screen transition)
- SOS functionality

### Dependencies
- #1618 — Push notification service (must be live)
- #1638 — System pushes trip completion to rider (must be live)

---

## [Mobile] #1564 — Rider sees trip summary with cash fare
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to see the full trip summary with the cash fare breakdown after my trip ends so that I know exactly what to pay.

### Background
After the trip ends, the rider's screen displays a trip summary. The total fare in EGP is shown in bold at the top. Below it is a fare breakdown with three line items: base fee, distance charge, and time charge. The summary also shows total trip distance (km), trip duration (minutes), pickup address, destination address, and the driver's name. Two actions are available: a "Rate Your Driver" button leading to the rating screen, and a "Skip" link leading directly to home.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Total fare is prominently displayed**
- Given the trip has ended and the fare has been calculated
- When the rider views the trip summary screen
- Then the total fare in EGP is shown in bold at the top of the summary

**Scenario 2 — Fare breakdown is shown**
- Given the rider is viewing the trip summary
- When the breakdown section is rendered
- Then three line items are shown: base fee, distance charge, and time charge
- And they sum to the total fare

**Scenario 3 — Trip metadata is displayed**
- Given the rider is viewing the trip summary
- When the screen is fully loaded
- Then the total distance in km is shown
- And the trip duration in minutes is shown
- And the pickup and destination addresses are shown
- And the driver's name is shown

**Scenario 4 — "Rate Your Driver" leads to rating screen**
- Given the rider is on the trip summary screen
- When she taps "Rate Your Driver"
- Then the rating screen (#1565) is displayed

**Scenario 5 — "Skip" leads to home screen**
- Given the rider is on the trip summary screen
- When she taps "Skip"
- Then the rider is taken to the home screen
- And no rating is submitted

### Out of Scope
- Digital payment processing
- Receipt download or email
- SOS functionality

### Dependencies
- #1637 — Completed trip served with fare breakdown (must be live)
- #1636 — Final fare calculation (must be live)

---

## [Mobile] #1565 — Rider rates driver
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to rate my driver with stars and optional tags after a trip so that I can give feedback on my experience.

### Background
The rating screen shows a 5-star selector where the rider taps to choose a rating between 1 and 5 stars. Below the stars, three optional predefined tags are shown: "سائق آمن", "سيارة نظيفة", "ودود". The rider may select any combination of these tags. A "Submit Rating" button submits the rating and tags, then takes the rider to the home screen. A star rating is required before the submission is accepted.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Stars | Yes | Integer | 1 | 5 | Numeric (tap selection) | "يرجى اختيار عدد النجوم قبل الإرسال" | — | — |
| Tags | No | Multi-select from predefined list | 0 | 3 | Predefined tag strings only | — | — | — |

### Acceptance Criteria

**Scenario 1 — Rating screen displays stars and tags**
- Given the rider navigates to the rating screen after a trip
- When the screen loads
- Then a 5-star selector is displayed
- And three predefined tags are shown: "سائق آمن", "سيارة نظيفة", "ودود"

**Scenario 2 — Rider submits a valid rating**
- Given the rider has selected a star rating between 1 and 5
- When she taps "Submit Rating"
- Then the rating and any selected tags are submitted to the platform
- And the rider is taken to the home screen

**Scenario 3 — Submission without stars shows error**
- Given the rider has not selected any stars
- When she taps "Submit Rating"
- Then the error message "يرجى اختيار عدد النجوم قبل الإرسال" is displayed
- And the rating is not submitted

**Scenario 4 — Tags are optional**
- Given the rider has selected a star rating but no tags
- When she taps "Submit Rating"
- Then the rating is submitted successfully without any tags
- And the rider is taken to the home screen

**Scenario 5 — Tags are multi-select from predefined list only**
- Given the rating screen is displayed
- When the rider taps one or more predefined tags
- Then those tags are marked as selected
- And only the three predefined tags are available for selection

### Out of Scope
- Free-text comment field
- Photo or media attachment
- Rating the vehicle separately from the driver
- Editing a submitted rating

### Dependencies
- #1639 — Rider submits driver rating (must be live)

---

## [Mobile] #1566 — Rider skips rating
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to skip rating so that I can go home quickly without being forced to provide feedback.

### Background
A "Skip" option is available on both the trip summary screen and the rating screen. When the rider taps "Skip", no rating is submitted and the rider is taken directly to the home screen. The skip action is final — the rider cannot return to rate the same trip. The trip is still recorded as complete and visible in trip history.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Tapping "Skip" from trip summary takes rider home**
- Given the rider is on the trip summary screen
- When she taps "Skip"
- Then the rider is taken to the home screen
- And no rating submission is made

**Scenario 2 — Tapping "Skip" from rating screen takes rider home**
- Given the rider is on the rating screen
- When she taps "Skip"
- Then the rider is taken to the home screen
- And no rating submission is made

**Scenario 3 — Skip is final — rider cannot return to rate**
- Given the rider has skipped the rating for a trip
- When she navigates back in the app
- Then the rating screen for that trip is no longer accessible
- And the trip is shown as complete in trip history without a rating

**Scenario 4 — Trip is still visible in history after skip**
- Given the rider has skipped the rating
- When the trip is viewed in trip history
- Then the trip record is present and complete
- And no rating is shown for that trip

### Out of Scope
- Prompting the rider to rate at a later time
- Partial rating save
- SOS functionality

### Dependencies
- #1640 — Trip closes without rating on skip (must be live)

---

## [Mobile] #1592 — Driver sees cash fare to collect and returns to available
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a driver, I want to see how much cash to collect from the rider after ending the trip so that I collect the correct amount before becoming available again.

### Background
Immediately after the driver taps "End Trip" and the trip state advances to trip_ended, the driver's screen shows a full-screen prompt displaying the cash amount to collect from the rider in EGP. A single "Done" button is shown. When the driver taps "Done", this screen is dismissed and the driver is returned to her home screen in the online/available state, ready to receive the next trip request.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Cash collection screen appears after ending trip**
- Given the driver has tapped "End Trip" and the trip is in trip_ended state
- When the driver's screen updates
- Then a full-screen cash collection prompt is displayed
- And the final fare amount in EGP is shown prominently

**Scenario 2 — "Done" dismisses the screen and returns driver to available**
- Given the driver is viewing the cash collection screen
- When she taps "Done"
- Then the screen is dismissed
- And the driver is returned to her home screen in the available state

**Scenario 3 — Fare amount matches the calculated fare**
- Given the platform has calculated the final fare
- When the cash collection screen is displayed
- Then the amount shown to the driver matches the final fare stored on the trip record

### Out of Scope
- Digital payment confirmation
- Receipt generation for the driver
- Fare dispute workflow

### Dependencies
- #1636 — Final fare calculation (must be live)

---

## [API] #1636 — Final fare is calculated from actual route and duration
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to calculate the final trip fare from the actual GPS distance and duration when the trip ends so that the rider and driver see the correct amount to exchange.

### Background
This is a platform process triggered automatically when the driver advances the trip state to trip_ended via #1652. The platform calculates the fare using the rate formula defined in #1628: base fee + (per-km rate × actual GPS distance in km) + (per-minute rate × actual trip duration in minutes). The resulting final fare is stored on the trip record and made available to all downstream consumers: the rider's push notification (#1638), the trip summary (#1637), and the driver's cash collection screen (#1592).

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Fare is calculated automatically on trip_ended**
- Given a trip has advanced to trip_ended state
- When the platform processes the state transition
- Then the final fare is calculated immediately using actual GPS distance and duration
- And the fare is stored on the trip record

**Scenario 2 — Fare uses the correct rate formula**
- Given the rate formula from #1628 is: base fee + (per-km rate × km) + (per-minute rate × minutes)
- When the fare is calculated for a trip of D km and T minutes
- Then the stored fare equals base fee + (per-km rate × D) + (per-minute rate × T)

**Scenario 3 — Fare is immediately available to downstream consumers**
- Given the fare has been calculated and stored
- When the rider app requests trip details (#1637) or the push is sent (#1638)
- Then both receive the same final fare amount

**Scenario 4 — Fare is not recalculated after storage**
- Given the final fare has been stored on the trip record
- When any downstream endpoint reads the fare
- Then the stored value is returned without recalculation

### Out of Scope
- Surge pricing or dynamic multipliers
- Fare disputes or manual overrides
- Digital payment processing

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1628 — Rate formula configuration (must be live)

---

## [API] #1637 — Completed trip is served with fare breakdown
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to retrieve a completed trip's full details including the fare breakdown so that the rider sees exactly what she owes.

### Background
After a trip reaches trip_ended state, the rider app calls this endpoint to populate the trip summary screen. The response includes the total fare in EGP, a breakdown of the three fare components (base fee, distance charge, time charge), total distance in km, trip duration in minutes, pickup address, destination address, driver name, vehicle details, and the rider's rating if one has been submitted.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Response includes fare total and breakdown**
- Given a trip is in trip_ended state
- When the rider app calls this endpoint
- Then the response includes the total fare in EGP
- And separate line items for base fee, distance charge, and time charge

**Scenario 2 — Response includes trip metadata**
- Given the endpoint is called for a completed trip
- When the response is returned
- Then it includes total distance in km, trip duration in minutes, pickup address, and destination address

**Scenario 3 — Response includes driver details**
- Given the endpoint is called for a completed trip
- When the response is returned
- Then the driver's name and vehicle details are included

**Scenario 4 — Rating is included if submitted**
- Given the rider has submitted a rating for the trip
- When this endpoint is called
- Then the response includes the star rating and any selected tags

**Scenario 5 — Rating field is absent or null if not yet submitted**
- Given the rider has not yet rated the trip
- When this endpoint is called
- Then the rating field is absent or null in the response

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Full trip history listing
- Fare dispute submission
- Receipt PDF generation

### Dependencies
- #1619 — Authentication service (must be live)
- #1636 — Final fare calculation (must be live)

---

## [API] #1638 — System pushes trip completion to rider
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when the trip ends so that she is alerted to the final fare even if the app is backgrounded.

### Background
This is an internal platform process triggered when the trip state advances to trip_ended via #1652. Once the fare is calculated, the platform sends a push notification to the rider's registered device via the push service in #1618. The notification text includes the final fare: "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." No app-to-platform call initiates this — it is event-driven from the state machine.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on trip_ended**
- Given the driver has advanced the trip to trip_ended and the fare has been calculated
- When the platform processes the state transition
- Then a push notification is sent to the rider's device automatically
- And no separate app call is required to trigger it

**Scenario 2 — Push text includes the final fare**
- Given the completion push is triggered
- When the notification is delivered
- Then the text reads "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." with the actual fare substituted

**Scenario 3 — Push failure does not block state transition**
- Given the push delivery service is temporarily unavailable
- When the driver advances to trip_ended
- Then the trip state is still saved as trip_ended
- And the fare is still calculated and stored
- And the platform logs the push delivery failure for retry

### Out of Scope
- SMS or email fallback for push delivery failures
- Rider acknowledgement of the push
- Digital payment confirmation push

### Dependencies
- #1619 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1639 — Rider submits driver rating
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to submit a star rating and optional tags for a completed trip so that the driver's performance is recorded.

### Background
After a trip ends, the rider may rate the driver through this authenticated endpoint. The request must include the trip ID, a star rating between 1 and 5, and optionally up to 3 predefined tags. The platform validates that the trip belongs to the requesting rider and that the trip is in completed state before storing the rating. On success, the platform triggers an update to the driver's aggregate rating via #1654.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| trip_id | Yes | String / UUID | — | — | Alphanumeric, hyphens | Return validation error | Return not-found or forbidden error if trip not found or not this rider's | — |
| stars | Yes | Integer | 1 | 5 | Numeric | Return validation error | — | Return validation error if out of range |
| tags | No | Array of predefined strings | 0 items | 3 items | Predefined tag strings only | — | Return validation error if tag not in predefined list | Return validation error if more than 3 tags |

### Acceptance Criteria

**Scenario 1 — Valid rating is accepted and stored**
- Given an authenticated rider submits a trip ID, a star rating between 1 and 5, and optional valid tags
- When the platform processes the request
- Then the rating is stored against the trip record
- And the driver's aggregate rating update is triggered via #1654

**Scenario 2 — Missing stars returns validation error**
- Given the rider submits a request without a stars value
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 3 — Stars out of range returns validation error**
- Given the rider submits a stars value of 0 or 6
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 4 — Trip not found or not rider's trip returns error**
- Given the rider submits a trip ID that does not exist or belongs to a different rider
- When the platform processes the request
- Then a not-found or forbidden error is returned
- And no rating is stored

**Scenario 5 — Invalid tag value returns validation error**
- Given the rider submits a tag string that is not in the predefined list
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 6 — More than 3 tags returns validation error**
- Given the rider submits 4 or more tag values
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 7 — Tags are optional**
- Given the rider submits a valid trip ID and stars but no tags
- When the platform processes the request
- Then the rating is stored successfully without tags

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Free-text comment submission
- Rating edit or deletion after submission
- Rider receiving confirmation of rating impact

### Dependencies
- #1619 — Authentication service (must be live)
- #1654 — Driver aggregate rating update (must be live)

---

## [API] #1654 — Driver aggregate rating is updated
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to recalculate the driver's average rating after each new rating is submitted so that the driver's profile always reflects her current standing.

### Background
This is an internal platform process triggered after a rating is successfully stored by #1639. The platform recalculates the driver's average star rating across all rated trips (excluding skipped trips). The updated average is written to the driver's profile record. All driver-detail endpoints reflect the new average immediately on their next call. No app-to-platform call initiates this — it is triggered internally by the rating submission flow.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Aggregate rating is recalculated after a new rating**
- Given a rider has successfully submitted a rating for a driver
- When #1654 is triggered by #1639
- Then the driver's average star rating is recalculated across all rated trips
- And the updated average is stored on the driver's profile record

**Scenario 2 — Updated average is reflected immediately**
- Given the driver's aggregate rating has been updated
- When any driver-detail endpoint is called
- Then the new average is returned in the response

**Scenario 3 — Skipped trips do not affect the aggregate**
- Given a trip was completed with a skipped rating (rating_status = skipped)
- When the driver's aggregate is calculated
- Then that trip is excluded from the average calculation
- And only trips with submitted ratings are counted

**Scenario 4 — First rating sets the aggregate correctly**
- Given a driver has no prior ratings
- When the first rating (e.g., 4 stars) is submitted
- Then the driver's aggregate rating is set to 4.0

### Out of Scope
- Weighted or time-decayed rating formulas
- Exposing individual rating breakdowns to the driver
- Minimum rating threshold enforcement

### Dependencies
- #1639 — Rider submits driver rating (must be live)

---

## [API] #1640 — Trip closes without rating on skip
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to mark a trip as completed without a rating when the rider skips so that the trip history remains accurate and the driver's rating is unaffected.

### Background
When the rider taps "Skip" on the rating or summary screen, the platform marks the trip with rating_status = skipped. No rating record is created for this trip. The driver's aggregate rating is not recalculated. The trip remains fully visible in both the rider's and the driver's trip history with all trip details intact. The skipped status is final and cannot be changed to a rated status later.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Trip is marked skipped when rider skips rating**
- Given the rider has tapped "Skip" on the rating or summary screen
- When the platform processes the skip action
- Then the trip record is updated with rating_status = skipped
- And no rating record is created

**Scenario 2 — Driver aggregate rating is unchanged after skip**
- Given a trip has been marked rating_status = skipped
- When the platform processes the skip
- Then the driver's aggregate star rating is not recalculated
- And the driver's average remains the same as before the trip

**Scenario 3 — Trip is visible in history for rider and driver**
- Given a trip has rating_status = skipped
- When either the rider or driver views their trip history
- Then the trip record is present with all trip details
- And no rating is shown for that trip

**Scenario 4 — Skipped status is final**
- Given a trip has been marked rating_status = skipped
- When any subsequent request attempts to submit a rating for that trip
- Then the platform rejects the request
- And the trip remains in skipped status

**Scenario 5 — Unauthenticated skip request is rejected**
- Given a skip request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Prompting the rider to rate a skipped trip at a later time
- Displaying skip statistics to the driver
- Admin override of skipped status

### Dependencies
- #1619 — Authentication service (must be live)
