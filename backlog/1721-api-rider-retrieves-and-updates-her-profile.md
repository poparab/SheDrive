# [API] Rider retrieves and updates her profile

**ADO ID:** 1721
**Area Path:** SheDrive
**Type:** User Story
**State:** New

## User Story

As the rider app, I want to retrieve and update the authenticated rider's profile information so that the rider can see and edit her registered details.

## Background

This covers two operations on the rider profile endpoint: GET (retrieve) and PATCH (update name). The GET request returns the rider's full name and phone number. Phone number is returned for display only and cannot be updated through this endpoint. The PATCH request accepts a new full name, validates it server-side, and persists the change. Both operations require a valid session token validated via #1619.

## Acceptance Criteria

**Scenario 1 — GET: Rider retrieves her profile**
- Given an authenticated rider sends a GET request to the profile endpoint
- When the endpoint is called
- Then the response includes `full_name` and `phone_number`
- And `phone_number` is read-only and cannot be updated via PATCH

**Scenario 2 — PATCH: Rider updates her name successfully**
- Given an authenticated rider sends a PATCH request with a valid `full_name` value
- When the endpoint is called
- Then the `full_name` is updated in the rider's record
- And the response returns the updated profile

**Scenario 3 — PATCH: Name validation fails (empty or invalid characters)**
- Given the rider sends a PATCH with an empty name or a name containing numbers or special characters
- When the endpoint is called
- Then the platform returns a validation error with the specific field and message
- And the rider's record is not updated

**Scenario 4 — PATCH: Name too short or too long**
- Given the rider sends a PATCH with a name shorter than 2 characters or longer than 60 characters
- When the endpoint is called
- Then the platform returns a length validation error

**Scenario 5 — PATCH: Phone number field is silently ignored**
- Given the rider sends a PATCH request that includes a `phone_number` field
- When the endpoint is called
- Then the `phone_number` field is silently ignored
- And only permitted fields are updated

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request via #1619

## Out of Scope
- Phone number change
- Profile photo management
- Account deletion

## Dependencies
- #1619 — Authentication service (must be live)
