# #1720 — [API] Driver cancels an accepted trip

**Area:** SheDrive  
**Type:** User Story  
**Status:** New

---

## Description

As the driver app, I want to send a trip cancellation request so that the platform can cancel the trip, notify the rider, flag the cancellation on the driver's record if appropriate, and return the driver to available status.

---

## Acceptance Criteria

### Background

This endpoint is called when an authenticated driver confirms a trip cancellation. The platform validates the trip belongs to the requesting driver, checks the current state (cancellation is only permitted in en_route_pickup or arrived_pickup), updates the trip status to cancelled, sends a push notification to the rider, flags the cancellation on the driver's performance record if the trip was in arrived_pickup state, updates the driver's status to online/available, and returns the updated trip record.

### Scenario 1 — Successful cancellation in en_route_pickup (no flag)

- Given an authenticated driver sends a cancellation for a trip in en_route_pickup state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And a push notification is sent to the rider
- And the driver's status is updated to online/available
- And no performance flag is added

### Scenario 2 — Successful cancellation in arrived_pickup (flagged)

- Given an authenticated driver sends a cancellation for a trip in arrived_pickup state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And the cancellation is flagged on the driver's performance record
- And a push notification is sent to the rider
- And the driver's status is updated to online/available

### Scenario 3 — Cancellation rejected in trip_started state

- Given the trip is in trip_started state
- When the endpoint is called
- Then the platform returns an error: trip cannot be cancelled after it has started

### Scenario 4 — Cancellation rejected for wrong driver

- Given an authenticated driver attempts to cancel a trip that does not belong to her
- When the endpoint is called
- Then the platform returns an authorisation error

### Scenario 5 — Unauthenticated request is rejected

- Given a request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request via #1619

---

## Out of Scope

- Penalty deduction from driver earnings
- Rider compensation for driver cancellation

---

## Dependencies

- #1619 — Authentication service (must be live)
- #1652 — Driver advances trip state machine (must be live)
