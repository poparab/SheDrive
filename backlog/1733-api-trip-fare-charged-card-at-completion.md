# #1733 — [API] Trip fare is charged to rider's card at trip completion

**Area:** SheDrive (Web / Main)
**Type:** User Story
**State:** New

## User Story

As the SheDrive platform, I want to charge the agreed fare to the rider's saved card when a card-payment trip ends so that the fare is collected without cash exchange.

## Background

This endpoint is triggered when a trip with `payment_method: 'card'` transitions to `trip_ended` state. The platform retrieves the rider's saved card token, calls the payment gateway to charge the final fare amount, records the transaction result on the trip record, and sends push notifications to both the rider (receipt) and the driver (payment received). If the charge fails, the trip is marked `payment_failed` and the rider app is notified to prompt retry or cash fallback.

## Acceptance Criteria

**Scenario 1 — Card charge succeeds**
- Given a trip with `payment_method: 'card'` transitions to `trip_ended`
- When the payment endpoint is called
- Then the fare is charged to the rider's saved card
- And the trip record is updated with `payment_status: paid` and `transaction_id`
- And a push notification is sent to the rider with the receipt
- And a push notification is sent to the driver confirming payment received

**Scenario 2 — Card charge fails**
- Given the payment gateway returns a failure
- When the charge is attempted
- Then the trip record is updated with `payment_status: payment_failed`
- And the rider app is notified to prompt retry or cash fallback

**Scenario 3 — Retry charge succeeds**
- Given a trip with `payment_status: payment_failed`
- When the rider retries payment and the gateway succeeds
- Then the trip record is updated to `payment_status: paid`

**Scenario 4 — Cash trip skips card processing**
- Given a trip with `payment_method: 'cash'` transitions to `trip_ended`
- Then no card charge is attempted
- And the trip record is updated with `payment_status: cash`

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

## Out of Scope
- Refund processing
- Partial payments
- Payment gateway provider selection

## Dependencies
- #1619 — Authentication service (must be live)
- #1639 — Driver ends trip at destination (must be live)
