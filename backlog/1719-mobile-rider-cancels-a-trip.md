# #1719 — [Mobile] Rider cancels a trip

**Area:** SheDrive\SheDrive Mobile Team  
**Type:** User Story  
**Status:** New

---

## Description

As a rider, I want to cancel my trip at any point before the driver starts the journey so that I am not charged when my plans change.

---

## Acceptance Criteria

### Background

The rider can cancel at two points in the trip lifecycle: (1) while the trip is in searching state on the matching screen — no driver has been assigned yet — in which case no cancellation fee is charged; (2) after a driver has been matched and is en_route_pickup, again with no fee; (3) if the driver has already arrived (arrived_pickup state), a cancellation fee applies to discourage late cancellations. Once the driver starts the trip (trip_started), cancellation is no longer available to the rider. On successful cancellation the rider is returned to the home screen with her pickup and destination fields still populated, and the assigned driver (if any) is notified via #1715.

### Scenario 1 — Rider cancels while searching (no driver assigned, no fee)

- Given the rider has submitted a trip request and is on the matching screen in searching state
- When the rider taps "Cancel" and confirms in the confirmation dialog
- Then the trip is cancelled with no fee
- And the rider is navigated to the home screen with her pickup and destination still populated

### Scenario 2 — Rider cancels after match, driver en route (no fee)

- Given a driver has been matched and the trip is in en_route_pickup state
- When the rider taps "Cancel" and confirms
- Then the trip is cancelled with no fee
- And the driver receives a push notification informing her the trip was cancelled
- And the rider is navigated to the home screen

### Scenario 3 — Rider cancels after driver arrives (cancellation fee applies)

- Given the trip is in arrived_pickup state
- When the rider taps "Cancel"
- Then a confirmation dialog is shown informing the rider that a cancellation fee applies
- When the rider confirms
- Then the trip is cancelled and the cancellation fee is recorded against the rider's account
- And the driver receives a push notification
- And the rider is navigated to the home screen

### Scenario 4 — Rider dismisses the cancellation dialog

- Given the rider taps "Cancel" at any stage
- When the confirmation dialog appears and the rider taps "Go Back"
- Then the dialog is dismissed and the rider remains on the current screen
- And the trip is not cancelled

### Scenario 5 — Cancel button is not shown after trip starts

- Given the trip is in trip_started state
- Then no cancel button is shown on the active trip screen

### Scenario 6 — Network error during cancellation

- Given the rider confirms cancellation
- When the network request fails
- Then a toast message is shown: "Unable to cancel. Please try again."
- And the rider remains on the current screen

---

## Out of Scope

- Cancellation fee payment processing
- Cancellation fee waiver or dispute
- Admin-initiated cancellation
- Driver-initiated trip cancellation (separate story)

---

## Dependencies

- #1715 — Rider cancels a trip (API — must be live)
- #1554 — Rider sees matching screen (must be built)
- #1652 — Driver advances trip state machine (must be live)
