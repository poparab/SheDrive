# [Mobile] Rider views and edits her profile

**ADO ID:** 1724
**Area Path:** SheDrive\SheDrive Mobile Team
**Type:** User Story
**State:** New

## User Story

As a rider, I want to view and edit my profile information so that my registered details are accurate and current.

## Background

The rider profile screen is accessible from the app's drawer menu. It displays the rider's registered full name, phone number (display only — cannot be changed in this sprint), and current language preference. The rider can edit her full name by tapping the name field. Changes are saved via #1721. The phone number field is visually styled as read-only.

## Field Validation

| Field | Required | Format | Min | Max | Error — empty | Error — invalid |
|-------|----------|--------|-----|-----|---------------|-----------------|
| Full name | Yes | Letters and spaces only (Arabic or Latin) | 2 chars | 60 chars | الاسم مطلوب / Name is required | الاسم يحتوي على أحرف غير صالحة / Name contains invalid characters |

## Acceptance Criteria

**Scenario 1 — Rider views her profile**
- Given an authenticated rider opens the profile screen
- Then her registered full name is displayed
- And her phone number is displayed in a read-only field
- And her current language preference is shown

**Scenario 2 — Rider edits and saves her name successfully**
- Given the rider taps the name field to edit it
- And she enters a valid new name
- When she taps "Save"
- Then the profile is updated via #1721
- And a success toast is shown: "تم حفظ التغييرات" / "Changes saved"
- And the profile screen reflects the updated name

**Scenario 3 — Name field validation fails**
- Given the rider clears the name field or enters invalid characters
- When she taps "Save"
- Then the inline validation error is shown
- And the save request is not sent

**Scenario 4 — Phone number field is read-only**
- Given the rider views her profile
- When she taps the phone number field
- Then the field does not enter edit mode
- And a note indicates: رقم الهاتف لا يمكن تغييره / Phone number cannot be changed

**Scenario 5 — Network error during save**
- Given the rider taps "Save"
- When the network request fails
- Then a toast message is shown: "فشل الحفظ. حاول مجدداً" / "Save failed. Please try again."
- And the rider remains on the profile screen in edit mode

## Out of Scope
- Phone number change
- Profile photo upload
- Account deletion
- Password management (OTP-based auth only)

## Dependencies
- #1721 — Rider retrieves and updates her profile (API — must be live)
