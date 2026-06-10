# [Admin] Operations admin reinstates a suspended driver account

**ADO ID:** 1743
**Area Path:** SheDrive
**Type:** User Story

## User Story

As an operations admin, I want to reinstate a suspended driver's account so that a driver who has been cleared can go online and accept trips again.

## Background

The reinstate action is accessible from the driver detail screen for accounts in suspended state. The admin confirms reinstatement and optionally adds a note. On confirmation, the account status is updated to active via #1739. The driver must log in again before she can go online — her online status is not automatically restored.

## Acceptance Criteria

**Scenario 1 — Admin reinstates a suspended driver**
- Given an admin is viewing a suspended driver's detail screen
- When the admin taps "Reinstate Account" and confirms
- Then the account status changes to active via #1739
- And the admin sees the updated status on the detail screen
- And the driver must log in again to go online

**Scenario 2 — Reinstate button is only shown for suspended accounts**
- Given an admin views a driver account that is in active state
- Then no "Reinstate Account" button is shown

## Out of Scope

- Automated reinstatement
- Driver notification on reinstatement (future sprint)

## Dependencies

- #1739 — Account suspension status is updated by admin (API — must be live)
- #1666 — Operations admin views driver detail (must be built)
