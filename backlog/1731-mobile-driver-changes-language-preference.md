# [Mobile] Driver changes language preference from profile screen

**ADO ID:** 1731
**Area Path:** SheDrive\SheDrive Mobile Team
**Type:** User Story
**State:** New

## User Story

As a driver, I want to change my app language from my profile screen so that I can use the app in my preferred language.

## Background

The language preference toggle is available on the driver profile screen. The driver can switch between Arabic (default, RTL) and English (LTR). When she switches, the UI updates immediately. The new preference is persisted via #1728. If the preference cannot be saved due to connectivity loss, it is saved locally and synced when connectivity is restored.

## Acceptance Criteria

**Scenario 1 — Driver switches from Arabic to English**
- Given the driver is using the app in Arabic
- When she selects English on the language toggle on her profile screen
- Then the UI language switches to English immediately
- And the layout direction changes from RTL to LTR
- And the preference is saved via #1728

**Scenario 2 — Driver switches from English to Arabic**
- Given the driver is using the app in English
- When she selects Arabic on the language toggle
- Then the UI language switches to Arabic immediately
- And the layout direction changes to RTL
- And the preference is saved via #1728

**Scenario 3 — Language preference is restored after app restart**
- Given the driver has selected English
- When she closes and reopens the app
- Then the app launches in English

**Scenario 4 — Language preference is restored after re-login**
- Given the driver has selected English, logged out, and logs back in
- Then the app restores the English preference from the server

**Scenario 5 — Network error during preference save**
- Given the driver switches language while offline
- Then the language updates immediately in the UI
- And the preference is saved locally
- And it is synced to the server when connectivity is restored

## Out of Scope
- Languages other than Arabic and English
- Per-notification language settings

## Dependencies
- #1728 — User language preference is stored and retrieved (API — must be live)
