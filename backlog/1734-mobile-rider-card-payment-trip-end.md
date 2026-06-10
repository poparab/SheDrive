# #1734 — [Mobile] Rider completes online card payment at trip end

**Area:** SheDrive\SheDrive Mobile Team
**Type:** User Story
**State:** New

## User Story

As a rider, I want to be charged automatically via my card at the end of a trip so that I do not need to carry cash.

## Background

When the trip's payment method is Card, the trip-complete screen shows a payment processing state before the usual trip summary and rating prompt. The payment is charged automatically via #1733. If payment succeeds, the rider sees the charged amount and a receipt note. If payment fails, the rider is offered a Retry option and a "Pay Cash to Driver" fallback.

## Acceptance Criteria

**Scenario 1 — Card payment processes successfully**
- Given the trip ends and the payment method is Card
- When the trip-complete screen loads
- Then a payment processing indicator is shown briefly
- And on success, the trip summary is shown with the charged amount
- And a receipt confirmation is shown to the rider
- And the driver is notified that payment was received

**Scenario 2 — Card payment fails — rider retries**
- Given the card payment fails
- When the rider taps "Retry Payment"
- Then the payment is attempted again via #1733
- And on success, the normal completion flow continues

**Scenario 3 — Card payment fails — rider switches to cash**
- Given the card payment fails after retry
- When the rider taps "Pay Cash to Driver"
- Then the trip is marked as cash-settled
- And the driver is notified to collect cash
- And the rider sees the cash amount to hand over

**Scenario 4 — Cash trip skips card payment screen**
- Given the trip's payment method is Cash
- When the trip-complete screen loads
- Then no payment processing state is shown
- And the cash fare amount to hand to the driver is displayed

## Out of Scope
- Card details entry (card is pre-saved separately)
- Partial payments
- Refunds

## Dependencies
- #1733 — Trip fare is charged to rider's card at trip completion (API — must be live)
- #1564 — Rider sees trip summary with cash fare (must be built)
