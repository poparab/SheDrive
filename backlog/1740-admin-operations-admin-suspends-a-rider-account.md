# [Admin] Operations admin suspends a rider account

**ADO ID:** 1740
**Area Path:** SheDrive
**Type:** User Story

## User Story

As an operations admin, I want to suspend a rider's account so that a rider who has violated platform policies or is under review is immediately prevented from booking trips.

## Background

The suspend action is accessible from the rider detail screen in the admin portal. An admin can suspend any rider whose account is in active or pending_review state. Suspension requires the admin to select a reason from a predefined list and optionally add a note. On confirmation, the rider's account status is updated to suspended via #1739 and her active session (if any) is invalidated. The rider cannot log in or book trips while suspended.

## Acceptance Criteria

**Scenario 1 — Admin suspends an active rider account**
- Given an admin is viewing a rider's detail screen
- And the rider's account is in active state
- When the admin taps "Suspend Account," selects a reason, and confirms
- Then the rider's account status changes to suspended via #1739
- And the rider's active session is invalidated
- And the admin sees the updated account status on the detail screen

**Scenario 2 — Admin suspends a pending_review rider account**
- Given a rider's account is in pending_review state (e.g., flagged for gender mismatch via #1687)
- When the admin taps "Suspend Account" and confirms
- Then the account status changes to suspended

**Scenario 3 — Suspension reason is required**
- Given the admin opens the suspension dialog
- When they attempt to confirm without selecting a reason
- Then the confirm button is disabled or an inline error is shown

**Scenario 4 — Suspended rider cannot log in**
- Given a rider's account is in suspended state
- When she attempts to log in
- Then she sees: "حسابك موقوف. تواصل مع الدعم" / "Your account has been suspended. Contact support."

## Out of Scope

- Automated suspension without admin review
- Rider notification on suspension (future sprint)

## Dependencies

- #1739 — Account suspension status is updated by admin (API — must be live)
- #1662 — Operations admin views rider detail (must be built)
