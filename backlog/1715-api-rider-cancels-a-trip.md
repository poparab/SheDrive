# #1715 — [API] Rider cancels a trip

**Area:** SheDrive  
**Type:** User Story  
**Status:** New

---

## Description

As the rider app, I want to send a trip cancellation request so that the platform can cancel the trip, notify the driver, and record any applicable cancellation fee.

---

## Acceptance Criteria

### Background

This endpoint is called when an authenticated rider confirms a trip cancellation on the mobile app. The platform validates the trip belongs to the requesting rider, checks the current trip state to determine whether a cancellation fee applies (fee applies only in arrived_pickup state), updates the trip status to cancelled, sends a push notification to the driver, and returns the final trip record including the fee amount (zero or non-zero). Cancellation is not permitted once the trip is in trip_started or trip_ended state.

### Scenario 1 — Successful cancellation in searching state (no fee)

- Given an authenticated rider sends a cancellation request for a trip in searching state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And the response includes cancellation_fee: 0

### Scenario 2 — Successful cancellation in en_route_pickup state (no fee)

- Given an authenticated rider sends a cancellation request for a trip in en_route_pickup state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And a push notification is sent to the driver
- And the response includes cancellation_fee: 0

### Scenario 3 — Successful cancellation in arrived_pickup state (fee applies)

- Given an authenticated rider sends a cancellation request for a trip in arrived_pickup state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And a cancellation fee is recorded against the rider's account
- And a push notification is sent to the driver
- And the response includes the cancellation_fee amount in EGP

### Scenario 4 — Cancellation rejected in trip_started state

- Given the trip is in trip_started state
- When the endpoint is called
- Then the platform returns an error: trip cannot be cancelled after it has started

### Scenario 5 — Cancellation rejected for wrong rider

- Given an authenticated rider attempts to cancel a trip that does not belong to her
- When the endpoint is called
- Then the platform returns an authorisation error

### Scenario 6 — Unauthenticated request is rejected

- Given a request arrives without a valid auth token
- When it targets the cancellation endpoint
- Then the platform rejects the request via #1619

---

## Out of Scope

- Cancellation fee payment processing or collection
- Refund processing
- Admin-initiated cancellation

---

## Dependencies

- #1619 — Authentication service (must be live)
- #1652 — Driver advances trip state machine (must be live)
