# [Mobile] Rider changes language preference from profile screen

**ADO ID:** 1729
**Area Path:** SheDrive\SheDrive Mobile Team
**Type:** User Story
**State:** New

## User Story

As a rider, I want to change my app language from my profile screen so that I can use the app in my preferred language.

## Background

The language preference toggle is available on the rider profile screen. The rider can switch between Arabic (default, RTL) and English (LTR). When she switches, the UI updates immediately without requiring a restart. The new preference is persisted via #1728. If the preference cannot be saved to the server due to connectivity loss, it is saved locally and synced when connectivity is restored.

## Acceptance Criteria

**Scenario 1 — Rider switches from Arabic to English**
- Given the rider is using the app in Arabic
- When she selects English on the language toggle on the profile screen
- Then the UI language switches to English immediately
- And the layout direction changes from RTL to LTR
- And the preference is saved via #1728

**Scenario 2 — Rider switches from English to Arabic**
- Given the rider is using the app in English
- When she selects Arabic on the language toggle
- Then the UI language switches to Arabic immediately
- And the layout direction changes to RTL
- And the preference is saved via #1728

**Scenario 3 — Language preference is restored after app restart**
- Given the rider has selected English
- When she closes and reopens the app
- Then the app launches in English

**Scenario 4 — Language preference is restored after re-login**
- Given the rider has selected English, logged out, and logs back in
- Then the app restores the English preference from the server

**Scenario 5 — Network error during preference save**
- Given the rider switches language while offline
- Then the language updates immediately in the UI
- And the preference is saved locally
- And it is synced to the server when connectivity is restored

## Out of Scope
- Languages other than Arabic and English
- Per-notification language settings

## Dependencies
- #1728 — User language preference is stored and retrieved (API — must be live)
