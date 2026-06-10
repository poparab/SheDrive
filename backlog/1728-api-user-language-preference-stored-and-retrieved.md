# [API] User language preference is stored and retrieved

**ADO ID:** 1728
**Area Path:** SheDrive
**Type:** User Story
**State:** New

## User Story

As the rider app and driver app, I want to store and retrieve the authenticated user's language preference so that the correct language is applied consistently across sessions and devices.

## Background

This endpoint serves both the rider and driver apps. It supports GET (retrieve current preference) and PUT (update preference). Accepted values are `ar` (Arabic, default) and `en` (English). The preference is stored on the user's account record and returned on login so the app can apply the correct locale immediately on launch.

## Acceptance Criteria

**Scenario 1 — GET: Preference is returned for authenticated user**
- Given an authenticated user sends a GET request
- When the endpoint is called
- Then the response includes the current language preference: `ar` or `en`

**Scenario 2 — PUT: Preference updated to English**
- Given an authenticated user sends PUT with `language: 'en'`
- When the endpoint is called
- Then the preference is saved and the response confirms the update

**Scenario 3 — PUT: Preference updated to Arabic**
- Given an authenticated user sends PUT with `language: 'ar'`
- When the endpoint is called
- Then the preference is saved and the response confirms the update

**Scenario 4 — PUT: Invalid language value is rejected**
- Given an authenticated user sends PUT with an unsupported language code
- When the endpoint is called
- Then the platform returns a validation error

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

## Out of Scope
- Languages other than `ar` and `en`
- Per-notification language overrides

## Dependencies
- #1619 — Authentication service (must be live)
