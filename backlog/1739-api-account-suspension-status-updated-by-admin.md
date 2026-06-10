# [API] Account suspension status is updated by admin

**ADO ID:** 1739
**Area Path:** SheDrive
**Type:** User Story

## User Story

As the admin portal, I want to update a rider's or driver's account suspension status so that the platform can enforce the admin's decision immediately across all active sessions.

## Background

This endpoint accepts PATCH requests from authenticated admin sessions. It updates the `account_status` field on a user record (rider or driver) to either `suspended` or `active`. The `user_type` parameter (rider or driver) determines which record is updated. On suspension, all active sessions for that user are invalidated and the user cannot log in. If the user is a driver, her online status is forced to offline. On reinstatement, no sessions are created — the user must log in again. A reason and optional note are stored on the suspension record for audit purposes.

## Acceptance Criteria

**Scenario 1 — Admin suspends a rider account**
- Given an authenticated admin sends PATCH with user_type: 'rider', user_id, action: 'suspend', and a reason
- When the endpoint is called
- Then the rider's account_status is updated to 'suspended'
- And all active sessions for that rider are invalidated
- And the suspension record is created with the reason and admin ID

**Scenario 2 — Admin reinstates a rider account**
- Given an authenticated admin sends PATCH with user_type: 'rider', user_id, action: 'reinstate'
- When the endpoint is called
- Then the rider's account_status is updated to 'active'

**Scenario 3 — Admin suspends a driver account**
- Given an authenticated admin sends PATCH with user_type: 'driver', user_id, action: 'suspend', and a reason
- When the endpoint is called
- Then the driver's account_status is updated to 'suspended'
- And the driver's online status is forced to offline
- And all active sessions are invalidated
- And the suspension record is created

**Scenario 4 — Admin reinstates a driver account**
- Given an authenticated admin sends PATCH with user_type: 'driver', user_id, action: 'reinstate'
- Then the driver's account_status is updated to 'active'

**Scenario 5 — Reason is required for suspension**
- Given a suspension request arrives without a reason field
- Then the platform returns a validation error

**Scenario 6 — Non-admin request is rejected**
- Given a request arrives from a non-admin session
- Then the platform returns an authorisation error

**Scenario 7 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

## Out of Scope

- Automated suspension rules
- Suspension history audit log UI

## Dependencies

- #1619 — Authentication service (must be live)
