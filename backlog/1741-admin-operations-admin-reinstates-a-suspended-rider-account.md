# [Admin] Operations admin reinstates a suspended rider account

**ADO ID:** 1741
**Area Path:** SheDrive
**Type:** User Story

## User Story

As an operations admin, I want to reinstate a suspended rider's account so that a rider who has been cleared can resume using the service.

## Background

The reinstate action is accessible from the rider detail screen for accounts in suspended or pending_review state. The admin confirms reinstatement and optionally adds a note. On confirmation, the account status is updated to active via #1739. The rider can then log in and book trips again. This flow also resolves the pending_review state created by #1687 (gender mismatch report).

## Acceptance Criteria

**Scenario 1 — Admin reinstates a suspended rider**
- Given an admin is viewing a suspended rider's detail screen
- When the admin taps "Reinstate Account" and confirms
- Then the account status changes to active via #1739
- And the rider can log in and book trips
- And the admin sees the updated status on the detail screen

**Scenario 2 — Reinstate resolves a pending_review account**
- Given a rider's account is in pending_review state (flagged via #1687)
- When the admin reinstates the account
- Then the status changes to active
- And the gender mismatch flag is cleared

**Scenario 3 — Reinstate button is only shown for suspended or pending_review accounts**
- Given an admin views a rider account that is in active state
- Then no "Reinstate Account" button is shown

## Out of Scope

- Automated reinstatement
- Rider notification on reinstatement (future sprint)

## Dependencies

- #1739 — Account suspension status is updated by admin (API — must be live)
- #1662 — Operations admin views rider detail (must be built)
- #1687 — Rider account is suspended after gender mismatch report (context)
