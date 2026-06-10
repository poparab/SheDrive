# [Admin] Operations admin suspends a driver account

**ADO ID:** 1742
**Area Path:** SheDrive
**Type:** User Story

## User Story

As an operations admin, I want to suspend a driver's account so that a driver who has violated platform policies is immediately prevented from going online and accepting trips.

## Background

The suspend action is accessible from the driver detail screen in the admin portal. An admin can suspend any driver whose account is in active state. Suspension requires the admin to select a reason and optionally add a note. On confirmation, the driver's account status is updated to suspended via #1739, her online status is forced to offline, and all active sessions are invalidated. The driver cannot log in or go online while suspended.

## Acceptance Criteria

**Scenario 1 — Admin suspends an active driver account**
- Given an admin is viewing a driver's detail screen
- And the driver's account is in active state
- When the admin taps "Suspend Account," selects a reason, and confirms
- Then the driver's account status changes to suspended via #1739
- And the driver's online status is forced to offline
- And all active sessions are invalidated
- And the admin sees the updated account status on the detail screen

**Scenario 2 — Suspension reason is required**
- Given the admin opens the suspension dialog
- When they attempt to confirm without selecting a reason
- Then the confirm button is disabled or an inline error is shown

**Scenario 3 — Suspended driver cannot log in or go online**
- Given a driver's account is in suspended state
- When she attempts to log in
- Then she sees: "حسابك موقوف. تواصل مع الدعم" / "Your account has been suspended. Contact support."

## Out of Scope

- Automated suspension without admin review
- Driver notification on suspension (future sprint)

## Dependencies

- #1739 — Account suspension status is updated by admin (API — must be live)
- #1666 — Operations admin views driver detail (must be built)
