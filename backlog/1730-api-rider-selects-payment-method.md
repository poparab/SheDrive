# #1730 — [API] Rider selects payment method for trip

**Area:** SheDrive (Web / Main)
**Type:** User Story
**State:** New

## User Story

As the rider app, I want to include the selected payment method in the trip request so that the platform records the agreed payment method for the trip.

## Background

The `payment_method` field is added to the trip creation request. The platform stores the selected method (cash or card) on the trip record. The driver app retrieves this value as part of the trip detail response. No payment processing occurs at trip creation — the field is informational only at this stage. Defaults to `cash` if omitted.

## Acceptance Criteria

**Scenario 1 — Trip created with payment_method: cash**
- Given a rider submits a trip request with `payment_method: 'cash'`
- When the endpoint is called
- Then the trip record includes `payment_method: 'cash'`
- And the driver app receives this value in the trip detail response

**Scenario 2 — Trip created with payment_method: card**
- Given a rider submits a trip request with `payment_method: 'card'`
- When the endpoint is called
- Then the trip record includes `payment_method: 'card'`

**Scenario 3 — Invalid payment method is rejected**
- Given a rider submits a trip request with an unrecognised `payment_method` value
- When the endpoint is called
- Then the platform returns a validation error

**Scenario 4 — Missing payment method defaults to cash**
- Given a rider submits a trip request without a `payment_method` field
- When the endpoint is called
- Then the trip record defaults to `payment_method: 'cash'`

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

## Out of Scope
- Card tokenisation or payment gateway integration
- Payment method change after trip creation

## Dependencies
- #1619 — Authentication service (must be live)
- #1629 — Rider creates trip request (must be live)
