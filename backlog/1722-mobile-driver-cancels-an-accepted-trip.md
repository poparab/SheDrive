# #1722 — [Mobile] Driver cancels an accepted trip

**Area:** SheDrive\SheDrive Mobile Team  
**Type:** User Story  
**Status:** New

---

## Description

As a driver, I want to cancel an accepted trip before the rider boards so that I can exit a trip I am genuinely unable to complete due to an emergency or vehicle issue.

---

## Acceptance Criteria

### Background

The driver can cancel at two points: (1) while navigating to the pickup (en_route_pickup state), or (2) after confirming arrival at the pickup location (arrived_pickup state). Cancellation is not available once the driver has started the trip (trip_started). A cancellation in arrived_pickup state is flagged on the driver's performance record. On successful cancellation the driver's status returns to online/available, and the rider receives a push notification informing her that the driver has cancelled. The cancellation request calls #1720.

### Scenario 1 — Driver cancels while en route to pickup

- Given the trip is in en_route_pickup state
- When the driver taps "Cancel Trip" and confirms in the confirmation dialog
- Then the trip is cancelled
- And the rider receives a push notification: "Your driver has cancelled. We are finding you a new driver."
- And the driver's status returns to online/available

### Scenario 2 — Driver cancels after arriving at pickup (flagged on record)

- Given the trip is in arrived_pickup state
- When the driver taps "Cancel Trip" and confirms
- Then the trip is cancelled
- And the cancellation is flagged on the driver's performance record
- And the rider receives a push notification
- And the driver's status returns to online/available

### Scenario 3 — Driver dismisses the cancellation dialog

- Given the driver taps "Cancel Trip"
- When the confirmation dialog appears and the driver taps "Go Back"
- Then the dialog is dismissed and the driver remains on the current screen
- And the trip is not cancelled

### Scenario 4 — Cancel button is not shown after trip starts

- Given the trip is in trip_started state
- Then no cancel trip button is visible on the active trip screen

### Scenario 5 — Network error during cancellation

- Given the driver confirms cancellation
- When the network request fails
- Then a toast message is shown: "Unable to cancel. Please try again."
- And the driver remains on the current screen

---

## Out of Scope

- Driver cancellation after trip starts
- Penalty deduction from driver earnings
- Rider-initiated cancellation (separate story)

---

## Dependencies

- #1720 — Driver cancels an accepted trip (API — must be live)
- #1652 — Driver advances trip state machine (must be live)
