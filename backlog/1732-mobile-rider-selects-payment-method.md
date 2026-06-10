# #1732 — [Mobile] Rider selects a payment method

**Area:** SheDrive\SheDrive Mobile Team
**Type:** User Story
**State:** New

## User Story

As a rider, I want to select my preferred payment method before booking a ride so that I and the driver both know how the fare will be settled at the end of the trip.

## Background

A payment method selector is shown on the home screen between the fare estimate and the "Request Ride" button. The available options for this sprint are Cash and Card (online payment). The default is Cash unless the rider has a saved preference. The selected method is included in the trip request payload via #1730 and is visible to the driver on the active trip screen. The payment method cannot be changed after the trip request is submitted.

## Acceptance Criteria

**Scenario 1 — Rider selects Cash**
- Given the rider is on the home screen with a pickup and destination set
- When she selects "Cash" as her payment method
- Then "Cash" is highlighted as the selected option
- And the fare estimate area shows "الدفع نقداً" / "Pay with Cash"

**Scenario 2 — Rider selects Card (online payment)**
- Given the rider selects "Card" as her payment method
- Then "Card" is highlighted as the selected option
- And the fare estimate area shows the estimated charge amount

**Scenario 3 — Default is Cash for a new rider**
- Given the rider has never selected a payment method before
- When she opens the home screen
- Then "Cash" is pre-selected by default

**Scenario 4 — Last used method is pre-selected on return**
- Given the rider previously used Card for her last trip
- When she opens the home screen for a new booking
- Then "Card" is pre-selected

**Scenario 5 — Selected method is passed with trip request**
- Given the rider has selected a payment method and taps "Request Ride"
- Then the selected payment method is included in the trip request payload sent via #1730

## Out of Scope
- Card details entry or saved card management (handled separately)
- Wallet top-up
- Payment method change after trip submission
- Promo codes

## Dependencies
- #1730 — Rider selects payment method for trip (API — must be live)
- #1552 — Rider sees fare estimate before requesting (must be built)
