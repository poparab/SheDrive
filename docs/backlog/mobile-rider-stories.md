# SheDrive — Mobile Rider Stories
> Canonical backlog for all [Mobile] Rider stories. Organized by sprint and feature.
> Last updated: 2026-06-14
> Stories with changes from original are marked ✏️

---

## Sprint 1

### Feature 2 — Rider Authentication

---

## [Mobile] #1545 — Rider registers
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want to register an account using my phone number and a one-time passcode so that I can access the SheDrive app with a verified identity.

### Background
The rider registration flow consists of two screens. Screen 1 collects the rider's Egyptian mobile number and, on tapping "إرسال الرمز" (Send Code), triggers OTP dispatch via #1620. Screen 2 collects the 6-digit OTP (auto-submits on the 6th digit entry) and the rider's full name, then creates the account via #1621. On success, the rider is taken to the home screen with an active session. If the phone number is already registered, #1621 auto-logs her in and she is taken to the home screen with an active session — no conflict error is shown.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Phone number | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |
| Full name | Yes | Arabic and/or Latin letters and spaces only; no digits or symbols | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخل اسمك الكامل | الاسم يجب أن يحتوي على حروف فقط | الاسم يجب أن يكون بين 2 و50 حرفاً |

### Acceptance Criteria

**Scenario 1 — Successful registration**
- Given a new rider opens the app and taps "إنشاء حساب"
- When she enters a valid Egyptian mobile number, receives and enters the correct 6-digit OTP, and enters a valid full name
- Then her account is created and she is taken to the home screen with an active session

**Scenario 2 — Phone number already registered auto-logs the rider in**
- Given a rider enters a phone number that is already linked to an existing account
- When she taps "إرسال الرمز"
- Then the OTP is still sent (the server sends it regardless per #1620)
- And after OTP + name entry, #1621 detects the existing account and auto-logs her in with a session token
- And she is taken to the home screen with an active session

**Scenario 3 — OTP expires before entry**
- Given a rider received an OTP but did not enter it within 5 minutes
- When she submits the expired code
- Then the app displays "انتهت صلاحية رمز التحقق. اطلب رمزاً جديداً"
- And a "إعادة إرسال الرمز" button is available (active after the 60-second cooldown)

**Scenario 4 — Wrong OTP entered**
- Given a rider enters an incorrect OTP
- When she submits
- Then the app displays "رمز التحقق غير صحيح"
- And after 3 consecutive wrong attempts, the code is invalidated and she must request a new one

**Scenario 5 — OTP resend cooldown**
- Given a rider has just requested an OTP
- When she taps "إعادة إرسال الرمز" within 60 seconds of the last request
- Then the button is disabled and a countdown timer shows remaining seconds
- And after 60 seconds, the button becomes active and a new OTP is sent on tap

**Scenario 6 — Invalid phone number format**
- Given a rider enters a phone number that does not match 01[0125]XXXXXXXX
- When she taps "إرسال الرمز"
- Then the error "رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً" is displayed inline
- And no OTP is sent

**Scenario 7 — Full name validation failure**
- Given a rider enters a name containing digits or special characters, or a name shorter than 2 characters
- When she taps "إنشاء حساب"
- Then the relevant validation error is displayed inline and the account is not created

**Scenario 8 — Network error during OTP request**
- Given the device has no internet connection when the rider taps "إرسال الرمز"
- When the request fails
- Then the app displays "تحقق من اتصالك بالإنترنت وحاول مرة أخرى"

### Out of Scope
- Social sign-in (Google, Apple, Facebook)
- Email registration
- Driver registration (covered by #1569)
- Rider identity document upload at registration time
- In-app masked calling
- Trusted contacts

### Dependencies
- #1620 — User requests OTP via SMS (must be live)
- #1621 — User registers with OTP verification (must be live)

---

## [Mobile] #1546 — Rider logs in ✏️
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want to log in to my existing account using my phone number and a one-time passcode so that I can access the app without remembering a password.

### Background
The rider login flow consists of two screens. Screen 1 collects the rider's phone number; tapping "إرسال الرمز" triggers OTP dispatch via #1620. Screen 2 collects only the 6-digit OTP (no name field on login) and auto-submits on the 6th digit. On success, the rider is taken to the home screen with an active session. If the number is not registered, an error is shown. The OTP rules (5-minute expiry, 3-attempt limit, 60-second resend cooldown) are identical to registration.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Phone number | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |

### Acceptance Criteria

**Scenario 1 — Successful login**
- Given a registered rider enters her phone number and taps "إرسال الرمز"
- When she receives and correctly enters the 6-digit OTP (auto-submits on 6th digit)
- Then she is authenticated and taken to the home screen with an active session

**Scenario 2 — Phone number not registered**
- Given a rider enters a phone number that has no existing account
- When she taps "إرسال الرمز" and the OTP request is processed
- Then the app displays "هذا الرقم غير مسجل. أنشئ حساباً جديداً" with a link to the registration screen

**Scenario 3 — OTP expires before entry**
- Given a rider received an OTP but did not enter it within 5 minutes
- When she submits the expired code
- Then the app displays "انتهت صلاحية رمز التحقق. اطلب رمزاً جديداً"

**Scenario 4 — Wrong OTP entered**
- Given a rider enters an incorrect OTP
- When she submits
- Then the app displays "رمز التحقق غير صحيح"
- And after 3 consecutive wrong attempts, the code is invalidated and she must request a new one

**Scenario 5 — OTP resend cooldown**
- Given a rider has just requested an OTP
- When she taps "إعادة إرسال الرمز" within 60 seconds
- Then the button is disabled showing a countdown
- And after 60 seconds, a new OTP is sent on tap

**Scenario 6 — Invalid phone number format**
- Given a rider enters a phone number that does not match 01[0125]XXXXXXXX
- When she taps "إرسال الرمز"
- Then the error "رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً" is displayed inline
- And no OTP is sent

**Scenario 7 — OTP resend during 60-second cooldown**
- Given a rider has just received an OTP
- When she taps "إعادة إرسال الرمز" before 60 seconds have elapsed
- Then the button is disabled and shows remaining seconds
- And no new OTP is sent until the cooldown expires

**Scenario 8 — OTP resend after cooldown expires**
- Given 60 seconds have elapsed since the previous OTP request
- When the rider taps "إعادة إرسال الرمز"
- Then the button is active
- And a new OTP is sent immediately

**Scenario 9 — Network error**
- Given the device has no internet connection
- When the rider taps "إرسال الرمز"
- Then the app displays "تحقق من اتصالك بالإنترنت وحاول مرة أخرى"

### Out of Scope
- Password-based login
- Social sign-in
- Driver login (covered by #1570)
- In-app masked calling
- Trusted contacts

### Dependencies
- #1620 — User requests OTP via SMS (must be live)
- #1622 — User logs in with OTP verification (must be live)

---

## [Mobile] #1547 — Rider logs out
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want to log out of the app so that my account is secured when I hand my device to someone else or no longer want an active session.

### Background
The logout action is accessible from the app's menu or profile screen. Tapping logout calls #1624 to invalidate the session token and deregister the device's push token. After logout completes, the rider is taken back to the splash/login screen. The action is always immediate and does not require confirmation in this sprint.

### Acceptance Criteria

**Scenario 1 — Successful logout**
- Given a rider is authenticated and navigates to the menu or profile screen
- When she taps "تسجيل الخروج"
- Then the session token is invalidated via #1624
- And the push notification device token is deregistered
- And she is taken to the splash/login screen

**Scenario 2 — Session is rejected after logout**
- Given a rider has successfully logged out
- When any subsequent request is made using the old session token (e.g., app is reopened)
- Then the token is rejected by #1744 and the rider is shown the login screen

**Scenario 3 — Network error during logout**
- Given the device has no internet connection when the rider taps "تسجيل الخروج"
- When the logout request fails
- Then the app clears the local session and takes the rider to the login screen regardless
- And the token is invalidated on the server the next time connectivity is restored (or on token expiry)

### Out of Scope
- Logout confirmation dialog
- Remote logout from another device
- Account deletion
- SOS/emergency features
- Trusted contacts

### Dependencies
- #1624 — User session is invalidated on logout (must be live)

---

## [Mobile] #1745 — Rider session persists across app restarts
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want the app to keep me logged in between sessions so that I don't have to go through OTP verification every time I open the app.

### Background
After a successful login or registration the session token is stored in the device's secure storage (iOS Keychain / Android Keystore — never in plain SharedPreferences or AsyncStorage). On every app launch and on each foreground resume event the app reads the stored token and validates it silently against the backend. If the token is valid the rider is taken directly to the home screen with no OTP prompt. If no token is found or the server rejects the token the local session is cleared and the rider is shown the splash/login screen. Any 401 response from a protected endpoint during an active session also clears the stored token immediately and redirects the rider to the login screen.

### Scenario 1 — Valid stored token → home screen on relaunch
- Given a rider has previously logged in and her session token is stored in secure storage
- When she relaunches the app
- Then the app validates the token silently in the background
- And she is taken directly to the home screen with no OTP or login prompt

### Scenario 2 — No stored token → login screen
- Given the device has no stored session token (first launch or after logout)
- When the app launches
- Then the rider is shown the splash/login screen
- And no background validation request is made

### Scenario 3 — Expired token on launch → login screen
- Given a rider's stored token has passed its 90-day lifetime
- When the app validates it on launch and the server returns 401
- Then the local token is cleared from secure storage
- And the rider is shown the login screen

### Scenario 4 — Mid-session 401 → clear session and redirect to login
- Given a rider is actively using the app and any API call returns 401
- When the app intercepts the 401 response
- Then the stored session token is cleared from secure storage
- And the rider is navigated to the login screen
- And a message is shown indicating her session has expired

### Scenario 5 — Token is stored in secure storage only
- Given a session token is issued after login or registration
- When the token is persisted on the device
- Then it is stored exclusively in iOS Keychain (iOS) or Android Keystore (Android)
- And it is never written to plain SharedPreferences, AsyncStorage, or any unencrypted store

### Scenario 6 — Token is cleared on explicit logout
- Given a rider taps تسجيل الخروج (#1547)
- When logout completes
- Then the session token is removed from secure storage
- And the next app launch shows the login screen with no auto-login attempt

### Scenario 7 — Network unavailable on launch → offline grace period
- Given a rider has a valid stored token but the device has no internet on launch
- When background validation times out
- Then the rider is shown the home screen using the cached session
- And the next network request that returns 401 triggers Scenario 4

### Out of Scope
- Biometric re-authentication
- Token refresh or silent renewal
- Multi-device session management
- Session timeout on inactivity

### Dependencies
- #1744 — Auth middleware validates session tokens (must be live)
- #1547 — Rider logs out (token must be cleared on logout)

---

### Feature 7 — Rider Home, Address Search & Fare Estimate

---

## [Mobile] #1548 — Rider sees home screen with map
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want to see a map of Cairo/Giza centered on my current location with pickup and destination inputs so that I can quickly start booking a ride.

### Background
The rider home screen is the main screen after login for verified riders. It shows a full-screen map centered on the rider's GPS location. Two input fields are shown: pickup and destination. The "Request Ride" CTA is visible but inactive until both fields are filled and a fare estimate has been fetched (#1552). GPS permission is needed to auto-detect the pickup address; if denied, the pickup field is empty and the rider must enter it manually.

### Acceptance Criteria

**Scenario 1 — Happy path: GPS available, map centered on rider**
- Given a verified rider opens the app and GPS permission is granted
- When the home screen loads
- Then a full-screen Cairo/Giza map is displayed, centered on the rider's current location
- And a pickup input and a destination input are both visible
- And the pickup input is pre-filled with the rider's current address (reverse-geocoded)
- And the "Request Ride" button is visible but inactive

**Scenario 2 — GPS permission denied**
- Given the rider has not granted GPS permission
- When the home screen loads
- Then the map shows a default Cairo center
- And the pickup input is empty with placeholder text prompting manual entry
- And no auto-detected address is shown

**Scenario 3 — Both fields filled, fare shown, CTA active**
- Given the rider has set both pickup and destination and fare has been fetched
- Then the "Request Ride" button becomes active
- And the fare estimate and trip duration are displayed

### Out of Scope
- Requesting a ride (covered in a later story)
- SOS functionality
- In-app calling

### Dependencies
- #1626 — Address autocomplete returns suggestions
- #1627 — Fare estimate uses Google Maps route data

---

## [Mobile] #1549 — Rider searches address with autocomplete
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want address autocomplete suggestions to appear as I type so that I can quickly find and select my pickup or destination without typing the full address.

### Background
When the rider taps either the pickup or destination input on the home screen (#1548) and begins typing, the app calls the autocomplete API (#1626) after 2 characters are entered. Results are biased to the Cairo/Giza area. Up to 5 suggestions are displayed below the input. Tapping a suggestion fills the input field with the selected address and dismisses the suggestion list. Fewer than 2 characters typed results in no suggestions being shown (not an error state).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search query | No | Free text | 2 chars to trigger suggestions | 200 chars | Arabic and Latin text | — (no suggestions shown below 2 chars) | — | — |

### Acceptance Criteria

**Scenario 1 — Happy path: suggestions appear after 2 characters**
- Given the rider taps the pickup or destination input and types 2 or more characters
- When the API (#1626) returns results
- Then up to 5 address suggestions appear in a list below the input

**Scenario 2 — Suggestion tapped fills the field**
- Given suggestions are displayed
- When the rider taps one
- Then the input field is filled with the selected address
- And the suggestion list is dismissed

**Scenario 3 — Fewer than 2 characters typed**
- Given the rider has typed fewer than 2 characters
- Then no suggestion list is shown and no API call is made

**Scenario 4 — No results returned**
- Given the rider types 2 or more characters but the API returns no matching suggestions
- Then an empty state message is shown (e.g., "لا توجد نتائج")

**Scenario 5 — Network error during autocomplete**
- Given the rider types 2 or more characters but the API call fails
- Then the suggestion list is not shown
- And the input field remains editable for manual entry

### Out of Scope
- Saving favourite addresses
- Offline address search
- Full-address validation beyond selection from suggestions

### Dependencies
- #1626 — Address autocomplete returns suggestions

---

## [Mobile] #1550 — Rider sets pickup point
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want to set my pickup location by choosing an autocomplete suggestion, using my current location, or dropping a pin on the map so that the driver knows exactly where to pick me up.

### Background
The rider can set her pickup using three methods on the home screen (#1548): (a) selecting an autocomplete suggestion from #1549, (b) tapping "Use my current location" which requires GPS permission, or (c) dropping a pin on the map by long-pressing or using a crosshair. The selected address is displayed in the pickup field. Once set, the fare estimate can be calculated when the destination is also set.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Pickup location | Yes (before fare/ride request) | Address or coordinates | — | — | — | اختاري موقع الانطلاق | — | — |

### Acceptance Criteria

**Scenario 1 — Happy path: pickup set via autocomplete**
- Given the rider types in the pickup field and selects a suggestion (#1549)
- Then the pickup field displays the selected address
- And a pin marker appears on the map at the selected location

**Scenario 2 — Happy path: pickup set via current location**
- Given GPS permission is granted
- When the rider taps "Use my current location"
- Then the pickup field fills with the reverse-geocoded current address
- And the map centers on that location

**Scenario 3 — Happy path: pickup set via map pin**
- Given the rider long-presses or uses a crosshair on the map
- When she confirms the pin position
- Then the pickup field fills with the reverse-geocoded address of the pinned location

**Scenario 4 — GPS denied when using current location**
- Given GPS permission is denied
- When the rider taps "Use my current location"
- Then a prompt explains that GPS is needed
- And a link to device settings is shown

**Scenario 5 — Ride requested without setting pickup**
- Given the rider attempts to request a ride without setting a pickup location
- Then an inline error is shown: "اختاري موقع الانطلاق"
- And the ride request is blocked

### Out of Scope
- Scheduled or future pickup times
- Multiple pickup stops

### Dependencies
- #1626 — Address autocomplete returns suggestions

---

## [Mobile] #1551 — Rider sets destination
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want to set my destination using autocomplete or a map pin so that the driver and platform know where I want to go.

### Background
The rider sets her destination on the home screen (#1548) using either: (a) selecting an autocomplete suggestion from #1549, or (b) dropping a pin on the map. The "Use my current location" option is not available for the destination. The selected address appears in the destination field. The destination must differ from the pickup location; if they match, an inline error is shown. Once both pickup and destination are set, the fare estimate is automatically triggered (#1552).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Destination | Yes (before fare/ride request) | Address or coordinates | — | — | — | اختاري وجهتك | يرجى اختيار وجهة مختلفة عن موقع الانطلاق | — |

### Acceptance Criteria

**Scenario 1 — Happy path: destination set via autocomplete**
- Given the rider types in the destination field and selects a suggestion (#1549)
- Then the destination field displays the selected address
- And a destination pin appears on the map
- And the fare estimate is triggered automatically if pickup is also set

**Scenario 2 — Happy path: destination set via map pin**
- Given the rider drops or moves a pin on the map for the destination
- When she confirms the position
- Then the destination field fills with the reverse-geocoded address

**Scenario 3 — Destination matches pickup**
- Given the rider selects a destination that is the same location as the pickup
- Then an inline error is shown: "يرجى اختيار وجهة مختلفة عن موقع الانطلاق"
- And the ride request CTA remains inactive

**Scenario 4 — Ride requested without setting destination**
- Given the rider attempts to request a ride without setting a destination
- Then an inline error is shown: "اختاري وجهتك"
- And the ride request is blocked

### Out of Scope
- Multiple destination stops
- "Use my current location" for destination

### Dependencies
- #1626 — Address autocomplete returns suggestions

---

## [Mobile] #1552 — Rider sees fare estimate before requesting
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want to see an estimated fare and trip duration before I request a ride so that I can make an informed decision about booking.

### Background
Once both pickup and destination are set on the home screen (#1548), the app automatically calls the fare estimate API (#1627). The response is displayed as a fare range (e.g., "45–55 EGP") and an estimated trip duration in minutes. The "Request Ride" CTA activates only after a successful fare fetch. If the fetch fails, a retry option is shown. If the rider changes either address, the estimate is recalculated automatically.

### Acceptance Criteria

**Scenario 1 — Happy path: fare and duration displayed**
- Given both pickup and destination are set
- When the fare estimate API (#1627) returns a result
- Then a fare range (e.g., "45–55 EGP") is displayed on screen
- And an estimated trip duration (in minutes) is displayed
- And the "Request Ride" button becomes active

**Scenario 2 — Fare fetch fails**
- Given both pickup and destination are set but the API call fails
- Then an error message is shown with a "Retry" button
- And the "Request Ride" button remains inactive

**Scenario 3 — Address changed, estimate recalculated**
- Given a fare estimate is already displayed
- When the rider changes the pickup or destination address
- Then the displayed estimate is cleared
- And a new fare fetch is triggered automatically
- And the "Request Ride" button deactivates until the new estimate arrives

**Scenario 4 — Same pickup and destination**
- Given the rider somehow has the same pickup and destination (edge case)
- When the fare estimate is triggered
- Then the API returns a validation error
- And the app shows an inline message: "يرجى اختيار وجهة مختلفة عن موقع الانطلاق"

### Out of Scope
- Surge pricing display
- Fare breakdown (base, per-km, per-min) shown to rider
- Payment method selection

### Dependencies
- #1627 — Fare estimate uses Google Maps route data
- #1628 — Fare applies base, per-km, and per-minute rates

---

## Sprint 2

### Feature 8 — Trip Request & Matching

---

## [Mobile] #1554 — Rider sees matching screen
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a "Finding your driver" screen after submitting my request so that I know the system is actively searching on my behalf.

### Background
After the trip request is created, the rider is taken to the matching screen where the platform searches for a nearby driver. The screen provides animated visual feedback to reassure the rider that the search is in progress. The app polls the match-status endpoint periodically. A cancel button is visible on screen but is non-functional in this sprint (marked as "coming soon" or disabled). When a match is found, the screen transitions to the driver card view (#1555). If no match is found within the matching window, the rider sees the no-driver error screen (#1557).

### Acceptance Criteria

**Scenario 1 — Matching screen displays correctly**
- Given the rider has just submitted a trip request
- When the matching screen loads
- Then an animated "Finding your driver..." indicator is displayed
- And the screen shows the rider's pickup area name or address
- And a disabled or visually suppressed "Cancel" button is visible

**Scenario 2 — Driver is matched**
- Given the matching screen is polling for status
- When the platform returns status = matched
- Then the screen transitions to the driver card view (#1555) without requiring any rider action
- And the transition is smooth (no full-page reload)

**Scenario 3 — No driver found**
- Given the matching screen is polling for status
- When the platform returns status = no_driver
- Then the rider is navigated to the no-driver error screen (#1557)

**Scenario 4 — Network error during polling**
- Given the matching screen is actively polling
- When a poll request fails due to network loss
- Then the screen continues to show the searching animation
- And retries the poll after a short interval
- And if connectivity is not restored within a reasonable time, shows a connectivity warning

### Out of Scope
- Trip cancellation (cancel button is visible but non-functional this sprint)
- Ride scheduling
- Driver filtering or preferences

### Dependencies
- #1631 — Rider polls for match status (API — must be live)

---

## [Mobile] #1555 — Rider sees confirmed driver card
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see my matched driver's details after a driver accepts my request so that I know who is coming to pick me up and when to expect them.

### Background
When a driver accepts the trip, the matching screen transitions to display a driver card. The rider sees the driver's name, photo or placeholder avatar, vehicle information (make, model, color, and plate number), star rating, and the estimated arrival time at the pickup location. A map view shows a pin at the driver's current location so the rider can track the driver approaching in real time. This screen marks the start of the active trip flow.

### Acceptance Criteria

**Scenario 1 — Driver card displays all required fields**
- Given a driver has accepted the rider's trip request
- When the matching screen transitions to the driver card
- Then the rider sees the driver's full name
- And the driver's photo is displayed (or a placeholder avatar if no photo is on file)
- And the vehicle make, model, color, and plate number are displayed
- And the driver's average star rating is shown
- And the estimated arrival time (ETA) at the pickup location is shown

**Scenario 2 — Map pin shows driver location**
- Given the driver card is displayed
- When the map renders
- Then a map pin shows the driver's current location
- And the rider's pickup location is also marked on the map

**Scenario 3 — ETA is unavailable**
- Given the driver card is displayed
- When the platform cannot compute an ETA
- Then "ETA unavailable" or equivalent placeholder text is shown instead of a time value

**Scenario 4 — Driver photo is missing**
- Given the matched driver has no profile photo
- When the driver card renders
- Then a gender-neutral placeholder avatar is displayed in place of a photo

### Out of Scope
- Real-time driver location tracking updates (live GPS trail)
- In-app messaging with driver
- Calling the driver
- Trip cancellation

### Dependencies
- #1631 — Rider polls for match status (API — must be live)
- #1633 — Driver profile retrieval (API — must be live)

---

## [Mobile] #1790 — Rider declares the passenger is a child before requesting a ride 🆕
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** Phase 1

**Description:** As a rider, I want to declare when the passenger for this trip will be a child so that a child may ride and the driver knows to expect one — the only exception to the women-only rule.

### Background
On the home screen, before requesting a ride, the rider can turn on "This ride is for a child (under 12)". Gender is not asked. The flag is sent with the trip request (#1783) and shown to the matched driver. Because SheDrive is women-only, a male passenger is normally not allowed; declaring a child permits a child passenger of any gender to ride. The default is off (adult woman). All strings flow through `data-i18n` keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Rider declares a child passenger**
- Given the rider is on the home screen with pickup and destination set
- When she turns on the child-passenger declaration and taps "Request Ride"
- Then the declaration is included in the trip request via #1783

**Scenario 2 — Default is off**
- Given the rider has not changed the toggle
- When she requests a ride
- Then the declaration is sent as false (adult woman)

**Scenario 3 — Helper text explains the exception**
- Given the rider views the child-passenger option
- Then bilingual helper text explains that a child may ride as the only exception to the women-only policy

**Scenario 4 — Declaration cannot change after submission**
- Given the trip request has been submitted
- Then the child declaration can no longer be changed for that trip

**Scenario 5 — Declaration is visible to the driver**
- Given a child passenger was declared
- When the driver views the trip
- Then she sees that the passenger is a declared child (supports #1588)

### Out of Scope
- Capturing the child's gender or exact age
- Child safety-seat handling
- Child-specific fares

### Dependencies
- #1783 — Trip request captures a per-trip child-passenger flag and exposes it to the driver (API — must be live)
- #1588 — Driver verifies rider is female on first trip (honors the child exception)

---

## [Mobile] #1791 — Rider cannot book outside operating hours 🆕
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** Phase 1

**Description:** As a rider, I want to see when SheDrive is closed for the day so that I understand why I cannot book and when I can.

### Background
SheDrive runs daytime-only in Phase 1 (open decision OD-001). Outside the operating window, the home screen shows a clear service-closed state, disables "Request Ride", and shows the next opening time. Any request attempted outside hours is rejected by #1785. A trip already in progress is not affected. All strings flow through `data-i18n` keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Inside operating hours**
- Given the current time is within the operating window
- When the rider opens the home screen
- Then booking is available as normal

**Scenario 2 — Outside operating hours**
- Given the current time is outside the operating window
- When the rider opens the home screen
- Then a bilingual service-closed state is shown with the next opening time
- And "Request Ride" is disabled

**Scenario 3 — Request attempted outside hours is rejected**
- Given the rider submits a request outside hours
- When it reaches the platform (#1785)
- Then it is rejected and a bilingual service-closed message is shown

**Scenario 4 — In-progress trip is unaffected**
- Given a trip is in progress when the window closes
- Then the trip continues uninterrupted

**Scenario 5 — State updates when hours resume**
- Given the operating window reopens
- When the rider returns to the home screen
- Then booking becomes available again

### Out of Scope
- Per-zone operating hours
- Scheduled rides (#1737)
- 24/7 operation

### Dependencies
- #1785 — Trip requests outside operating hours are rejected (API — must be live)
- Open decision OD-001 — operating hours

---

### Feature 10 — Active Trip (Rider)

---


## [Mobile] #1559 — Rider sees driver-arrived state
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want my screen to update when the driver arrives so that I know to head to the pickup point.

### Background
When the driver taps "I've Arrived" and the trip state advances to arrived_pickup, the rider's active trip screen automatically transitions to a "Your driver has arrived" state. A waiting counter starts from 0:00 and increments each second until the driver taps "Start Trip" and the state advances to trip_started. The map continues to show the driver's pin at the pickup location. No action is required from the rider on this screen — she simply proceeds to board.

### Acceptance Criteria

**Scenario 1 — Rider screen transitions to arrived state automatically**
- Given the rider is viewing the active trip screen in en_route_pickup state
- When the trip state advances to arrived_pickup
- Then the rider's screen updates to display a "Your driver has arrived" message
- And no manual refresh is required

**Scenario 2 — Map continues to show driver pin at pickup location**
- Given the trip is in arrived_pickup state on the rider's screen
- When the rider views the map
- Then the driver's pin is shown at the pickup location
- And the rider's pickup pin is also visible

**Scenario 3 — No rider action is required on this screen**
- Given the rider sees the arrived state
- When she views the screen
- Then no buttons requiring rider input are shown
- And the screen simply instructs her to board

**Scenario 4 — Waiting counter starts when driver arrives**
- Given the trip state has advanced to arrived_pickup
- When the rider views the active trip screen
- Then a waiting counter is displayed starting from 0:00
- And the counter increments each second
- And the counter is visible alongside the "Your driver has arrived" message
- And the counter stops when the trip state advances to trip_started

### Out of Scope
- Automated check-in for the rider
- Geofence detection on the rider's device
- SOS functionality
- Waiting fee calculation or billing (separate story if needed)

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)

---

## [Mobile] #1560 — Rider receives push when driver arrives ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when my driver arrives so that I know to head to the pickup point even if the app is in the background.

### Background
When the driver taps "I've Arrived", the platform sends a push notification to the rider's device. The notification text is: "سائقتك وصلت! توجهي إلى موقع الانطلاق." Tapping the notification brings the app to the foreground and displays the active trip screen in the arrived_pickup state.

### Acceptance Criteria

**Scenario 1 — Push notification is received when driver arrives**
- Given the driver has tapped "I've Arrived" and the trip state is arrived_pickup
- When the platform processes the state change
- Then the rider's device receives a push notification
- And the notification text reads "سائقتك وصلت! توجهي إلى موقع الانطلاق."

**Scenario 2 — Tapping notification opens active trip screen**
- Given the rider receives the driver-arrived push notification
- When the rider taps the notification
- Then the SheDrive app opens (or comes to foreground)
- And the active trip screen is displayed in arrived_pickup state

**Scenario 3 — Push is delivered even when app is backgrounded**
- Given the rider's app is not in the foreground
- When the driver marks arrival
- Then the push notification still appears on the rider's device lock screen or notification tray

**Scenario 4 — Notification delivered in the rider's preferred language**
- Given the rider's language preference (`shedrive.lang`) is set to "ar" or "en"
- When the platform dispatches the driver-arrived push notification
- Then the notification title and body are rendered in the rider's preferred language
- And Arabic ("ar") is used as the default when no language preference is stored
- And the platform maintains both Arabic and English versions of all push notification templates

### Out of Scope
- SMS or email arrival alerts
- In-app banner if app is already in foreground (handled by screen transition in #1559)
- SOS functionality

### Dependencies
- #1618 — Push notification service (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)

---

## [Mobile] #1561 — Rider sees driver live location and details during trip
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location and the trip route on the map, plus the driver's name, photo, and vehicle details throughout the trip, so that I can follow our progress in-app and confirm I am with the correct driver.

### Background
Once the driver taps "Start Trip" and the state advances to trip_started, the rider's map updates to show the driver's location moving toward the destination. The destination pin is visible on the map. GPS coordinates received from the driver every 5 seconds update the moving dot in near real time. The trip route is rendered on the rider's map in-app. This is a live view of the driver's location — not navigation — so the rider is never offered an external maps app. The rider remains on this screen until the trip ends.

Throughout the active trip — from en_route_pickup through trip_ended — the rider sees a persistent driver card on the active trip screen. The card displays the driver's name, profile photo (or a placeholder avatar if no photo is set), vehicle make and model, vehicle color, and license plate number. This information is sourced from the trip details returned by the platform.

### Acceptance Criteria

**Scenario 1 — Driver dot continues moving during trip**
- Given the trip state is trip_started
- When the rider views the active trip screen
- Then the driver's location dot is visible on the map and updates as the driver moves
- And the destination pin is shown on the map

**Scenario 2 — Location updates in near real time during trip**
- Given the trip is in trip_started state
- When the platform receives a new GPS position from the driver
- Then the driver's dot on the rider's map moves to the new position within 5 seconds

**Scenario 3 — Trip route is rendered on the rider's map in-app**
- Given the trip is in trip_started state
- When the rider views the active trip screen
- Then the trip route to the destination is rendered on the map within the app
- And the rider is not offered an external maps app option

**Scenario 4 — Rider screen transitions automatically on trip end**
- Given the rider is watching the map during trip_started state
- When the driver taps "End Trip" and the state advances to trip_ended
- Then the rider's screen automatically transitions to the trip summary

**Scenario 5 — Driver card shows name and vehicle details**
- Given the rider is on the active trip screen in any active state
- When the driver card is rendered
- Then the driver's full name is displayed
- And the vehicle make, model, color, and plate number are displayed

**Scenario 6 — Driver photo or placeholder is shown**
- Given the rider is viewing the driver card
- When the driver has a profile photo on file
- Then the driver's profile photo is shown in the card avatar
- And when the driver has no profile photo, a placeholder avatar is shown instead

**Scenario 7 — Driver card is visible across all active states**
- Given the trip is in en_route_pickup, arrived_pickup, or trip_started state
- When the rider views the active trip screen
- Then the driver card remains visible without requiring any action

### Out of Scope
- Turn-by-turn navigation for the rider (the rider only views the route)
- Estimated arrival time to destination for the rider
- Rider-initiated contact with the driver (chat or call)
- Sharing driver details with a third party from this screen
- SOS functionality

### Dependencies
- #1818 — Platform serves active-trip route geometry to the rider for an in-app trip view (must be live)
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

### Feature 11 — Trip Completion & Cash Payment (Rider)

---

## [Mobile] #1563 — Rider receives push on trip completion ✏️
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when my trip ends so that I know the fare and can review my trip summary.

### Background
When the driver taps "End Trip" and the trip state advances to trip_ended, the platform sends a push notification to the rider. The notification text includes the final fare: "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." where [X] is the calculated fare in Egyptian Pounds. Tapping the notification brings the SheDrive app to the foreground and displays the trip summary screen.

### Acceptance Criteria

**Scenario 1 — Push notification is received when trip ends**
- Given the driver has tapped "End Trip" and the trip state is trip_ended
- When the platform processes the state change and fare calculation is complete
- Then the rider's device receives a push notification
- And the notification text includes the final fare in EGP

**Scenario 2 — Notification text format is correct**
- Given the final fare is calculated
- When the trip completion push is sent
- Then the notification text reads "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." with the actual fare substituted

**Scenario 3 — Tapping notification opens trip summary**
- Given the rider receives the trip completion push notification
- When the rider taps the notification
- Then the SheDrive app opens or comes to the foreground
- And the trip summary screen is displayed

**Scenario 4 — Push is delivered even when app is backgrounded**
- Given the rider's app is not in the foreground when the trip ends
- When the platform sends the completion push
- Then the notification appears on the device's lock screen or notification tray

**Scenario 5 — Notification delivered in the rider's preferred language**
- Given the rider's language preference (`shedrive.lang`) is set to "ar" or "en"
- When the platform dispatches the trip completion push notification
- Then the notification title and body are rendered in the rider's preferred language
- And Arabic ("ar") is used as the default when no language preference is stored
- And the platform maintains both Arabic and English versions of all push notification templates

### Out of Scope
- Email or SMS receipt
- In-app banner if app is already in foreground (handled by screen transition)
- SOS functionality

### Dependencies
- #1618 — Push notification service (must be live)
- #1638 — System pushes trip completion to rider (must be live)

---

## [Mobile] #1564 — Rider sees trip summary with cash fare
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to see the full trip summary with the cash fare breakdown after my trip ends so that I know exactly what to pay.

### Background
After the trip ends, the rider's screen displays a trip summary. The total fare in EGP is shown in bold at the top. Below it is a fare breakdown with three line items: base fee, distance charge, and time charge. The summary also shows total trip distance (km), trip duration (minutes), pickup address, destination address, and the driver's name. Two actions are available: a "Rate Your Driver" button leading to the rating screen, and a "Skip" link leading directly to home.

### Acceptance Criteria

**Scenario 1 — Total fare is prominently displayed**
- Given the trip has ended and the fare has been calculated
- When the rider views the trip summary screen
- Then the total fare in EGP is shown in bold at the top of the summary

**Scenario 2 — Fare breakdown is shown**
- Given the rider is viewing the trip summary
- When the breakdown section is rendered
- Then three line items are shown: base fee, distance charge, and time charge
- And they sum to the total fare

**Scenario 3 — Trip metadata is displayed**
- Given the rider is viewing the trip summary
- When the screen is fully loaded
- Then the total distance in km is shown
- And the trip duration in minutes is shown
- And the pickup and destination addresses are shown
- And the driver's name is shown

**Scenario 4 — "Rate Your Driver" leads to rating screen**
- Given the rider is on the trip summary screen
- When she taps "Rate Your Driver"
- Then the rating screen (#1565) is displayed

**Scenario 5 — "Skip" leads to home screen**
- Given the rider is on the trip summary screen
- When she taps "Skip"
- Then the rider is taken to the home screen
- And no rating is submitted

### Out of Scope
- Digital payment processing
- Receipt download or email
- SOS functionality

### Dependencies
- #1637 — Completed trip served with fare breakdown (must be live)
- #1636 — Final fare calculation (must be live)

---

## [Mobile] #1565 — Rider rates driver
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to rate my driver with stars and optional tags after a trip so that I can give feedback on my experience.

### Background
The rating screen shows a 5-star selector where the rider taps to choose a rating between 1 and 5 stars. Below the stars, three optional predefined tags are shown: "سائق آمن", "سيارة نظيفة", "ودود". The rider may select any combination of these tags. A "Submit Rating" button submits the rating and tags, then takes the rider to the home screen. A star rating is required before the submission is accepted.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Stars | Yes | Integer | 1 | 5 | Numeric (tap selection) | "يرجى اختيار عدد النجوم قبل الإرسال" | — | — |
| Tags | No | Multi-select from predefined list | 0 | 3 | Predefined tag strings only | — | — | — |

### Acceptance Criteria

**Scenario 1 — Rating screen displays stars and tags**
- Given the rider navigates to the rating screen after a trip
- When the screen loads
- Then a 5-star selector is displayed
- And three predefined tags are shown: "سائق آمن", "سيارة نظيفة", "ودود"

**Scenario 2 — Rider submits a valid rating**
- Given the rider has selected a star rating between 1 and 5
- When she taps "Submit Rating"
- Then the rating and any selected tags are submitted to the platform
- And the rider is taken to the home screen

**Scenario 3 — Submission without stars shows error**
- Given the rider has not selected any stars
- When she taps "Submit Rating"
- Then the error message "يرجى اختيار عدد النجوم قبل الإرسال" is displayed
- And the rating is not submitted

**Scenario 4 — Tags are optional**
- Given the rider has selected a star rating but no tags
- When she taps "Submit Rating"
- Then the rating is submitted successfully without any tags
- And the rider is taken to the home screen

**Scenario 5 — Tags are multi-select from predefined list only**
- Given the rating screen is displayed
- When the rider taps one or more predefined tags
- Then those tags are marked as selected
- And only the three predefined tags are available for selection

### Out of Scope
- Free-text comment field
- Photo or media attachment
- Rating the vehicle separately from the driver
- Editing a submitted rating

### Dependencies
- #1639 — Rider submits driver rating (must be live)

---

## [Mobile] #1799 — Rider skips rating
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to skip rating so that I can go home quickly without being forced to provide feedback.

### Background
A "Skip" option is available on both the trip summary screen and the rating screen. When the rider taps "Skip", no rating is submitted and the rider is taken directly to the home screen. The post-trip rating prompt is no longer shown for that trip. The rider can still rate the trip later by opening the trip detail screen in her trip history (#1568). The trip is still recorded as complete and visible in trip history.

### Acceptance Criteria

**Scenario 1 — Tapping "Skip" from trip summary takes rider home**
- Given the rider is on the trip summary screen
- When she taps "Skip"
- Then the rider is taken to the home screen
- And no rating submission is made

**Scenario 2 — Tapping "Skip" from rating screen takes rider home**
- Given the rider is on the rating screen
- When she taps "Skip"
- Then the rider is taken to the home screen
- And no rating submission is made

**Scenario 3 — Post-trip rating screen is no longer accessible after skip**
- Given the rider has skipped the rating for a trip
- When she navigates back in the app
- Then the post-trip rating screen for that trip is no longer accessible
- And the trip is visible in trip history with a "Rate this trip" prompt in the detail screen (#1568)

**Scenario 4 — Trip is still visible in history after skip**
- Given the rider has skipped the rating
- When the trip is viewed in trip history
- Then the trip record is present and complete
- And a "Rate this trip" prompt is shown in the trip detail screen (#1568)

### Out of Scope
- Partial rating save
- SOS functionality

### Dependencies
- #1640 — Trip closes without rating on skip (must be live)

---

### Feature 12 — Trip History (Rider)

---

## [Mobile] #1567 — Rider views trip history
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a rider, I want to view a list of my past trips so that I can review where I have travelled and how much I have spent.

### Background
Riders access trip history from the menu or profile section of the app. The list is sorted most recent first and shows a summary row for each past trip. This screen gives riders a quick overview without surfacing every detail — tapping any row opens the full trip detail screen (#1568). If the rider has not yet completed any trips, an empty state message is displayed instead of the list.

### Acceptance Criteria

**Scenario 1 — Rider opens trip history with past trips**
- Given the rider is authenticated and has at least one completed trip
- When she opens the trip history screen from the menu
- Then a paginated list of her past trips is displayed, most recent first
- And each row shows: trip date, destination name, fare paid (EGP), and status "Completed"

**Scenario 2 — Rider taps a trip row**
- Given the trip history list is visible with at least one row
- When the rider taps any trip row
- Then the app navigates to the trip detail screen (#1568) for that trip

**Scenario 3 — Rider has no past trips**
- Given the rider is authenticated and has never completed a trip
- When she opens the trip history screen
- Then an empty state message is shown indicating no trips are available yet
- And no list rows are rendered

**Scenario 4 — Rider paginates the list**
- Given the rider has more than one page of past trips
- When she scrolls to the bottom of the current page
- Then the next page of trips loads and appends to the list
- And the order remains most recent first

### Out of Scope
- Cancellations and in-progress trips
- Filtering or searching trip history
- Exporting trip history
- SOS-related trip records

### Dependencies
- #1641 — Rider retrieves trip history (must be live)

---

## [Mobile] #1568 — Rider views past trip detail and rates unrated trips ✏️
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a rider, I want to view the full details of a past trip and submit a rating if I skipped it after the trip, so that I can review my journey and still provide feedback at my convenience.

### Background
When a rider taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the complete picture of that trip: timing, addresses, fare breakdown, and who drove her. If she previously submitted a star rating, it is displayed. If she skipped the post-trip rating prompt, a "Rate this trip" section appears so she can still submit a rating.

### Acceptance Criteria

**Scenario 1 — Rider views detail of a rated trip**
- Given the rider has navigated to the detail screen for a past trip she rated
- When the screen loads
- Then it displays: date and time, pickup address, destination address, total fare (EGP), fare breakdown (base fare + distance charge + time charge), trip duration, distance travelled, driver name, and vehicle information
- And the star rating she submitted is shown

**Scenario 2 — Rider submits a rating for an unrated trip**
- Given the rider has navigated to the detail screen for a past trip she did not rate
- When the screen loads
- Then all trip details are shown as in Scenario 1
- And a "Rate this trip" section is displayed with a five-star control
- When she selects a star rating and taps "Submit"
- Then the rating is submitted and the screen updates to show the submitted rating in place of the prompt

**Scenario 3 — Rider navigates back to the list**
- Given the rider is on the trip detail screen
- When she presses the back button
- Then she is returned to the trip history list at the same scroll position

### Out of Scope
- Editing a previously submitted rating
- Disputing a fare
- Contacting the driver
- SOS history

### Dependencies
- #1641 — Rider retrieves trip history (must be live)
- #1639 — Rider submits driver rating (rating data source)

---

## [Mobile] #1724 — Rider views and edits her profile 🆕
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 2

**Description:** As a rider, I want to view and edit my profile information so that I can keep my account details current.

### Background
The profile screen is accessible from the menu or drawer. It displays the rider's registered phone number (read-only), full name, email (if provided), and language preference. The rider can edit her full name. Changes are submitted to #1721 and validated before saving.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Full name | Yes | Arabic and/or Latin letters and spaces only | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخلي اسمك الكامل | الاسم يجب أن يحتوي على حروف فقط | الاسم يجب أن يكون بين 2 و50 حرفاً |

### Acceptance Criteria

**Scenario 1 — Rider opens her profile**
- Given an authenticated rider navigates to the profile screen
- When the page loads
- Then her registered phone number, full name, email, and language preference are displayed

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

**Scenario 5 — Language preference is shown**
- Given the rider is on her profile screen
- When she views the language section
- Then the current language preference (ar or en) is indicated
- And a link to change it is available (leading to #1729)

**Scenario 6 — Network error during save**
- Given the rider taps "Save"
- When the network request fails
- Then a toast message is shown: "فشل الحفظ. حاول مجدداً" / "Save failed. Please try again."
- And the rider remains on the profile screen in edit mode

### Out of Scope
- Phone number change
- Profile photo upload
- Account deletion
- Password management (OTP-based auth only)

### Dependencies
- #1721 — Rider retrieves and updates her profile (API — must be live)

---

## [Mobile] #1729 — Rider changes language preference from profile screen 🆕
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 2

**Description:** As a rider, I want to change my language preference from the profile screen so that the app displays all content in my chosen language.

### Background
A language selector on the profile screen allows the rider to toggle between Arabic (ar) and English (en). Upon selection, the preference is saved to the backend via #1728 and the entire app UI updates immediately to reflect the new language without requiring a refresh.

### Acceptance Criteria

**Scenario 1 — Rider changes language to English**
- Given the rider is on her profile screen with language set to Arabic
- When she taps the English option
- Then the preference is saved via #1728
- And the entire app UI updates to English immediately

**Scenario 2 — Rider changes language to Arabic**
- Given the rider is on her profile screen with language set to English
- When she taps the Arabic option
- Then the preference is saved via #1728
- And the entire app UI updates to Arabic immediately

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

### Out of Scope
- Languages other than Arabic and English
- Per-notification language settings

### Dependencies
- #1728 — User language preference is stored and retrieved (API — must be live)

---

### Feature 17 — Payments (Rider)

---

## [Mobile] #1732 — Rider selects a payment method 🆕
**Feature:** Feature 17 — Payments | **Sprint:** 2

**Description:** As a rider, I want to select my preferred payment method before or after a trip so that I can choose between cash and card payment.

### Background
A payment method selector is shown on the home screen between the fare estimate and the "Request Ride" button. The available options for this sprint are Cash and Card (online payment). The default is Cash unless the rider has a saved preference. The selected method is included in the trip request payload via #1730 and is visible to the driver on the active trip screen. The payment method cannot be changed after the trip request is submitted.

### Acceptance Criteria

**Scenario 1 — Rider selects Cash**
- Given the rider is on the home screen with a pickup and destination set
- When she selects "Cash" as her payment method
- Then "Cash" is highlighted as the selected option
- And the fare estimate area shows "الدفع نقداً" / "Pay with Cash"

**Scenario 2 — Rider selects Card (online payment)**
- Given the rider selects "Card" as her payment method
- Then "Card" is highlighted as the selected option
- And the fare estimate area shows the estimated charge amount

**Scenario 3 — Default is Cash for a new rider**
- Given the rider has never selected a payment method before
- When she opens the home screen
- Then "Cash" is pre-selected by default

**Scenario 4 — Last used method is pre-selected on return**
- Given the rider previously used Card for her last trip
- When she opens the home screen for a new booking
- Then "Card" is pre-selected

**Scenario 5 — Selected method is passed with trip request**
- Given the rider has selected a payment method and taps "Request Ride"
- Then the selected payment method is included in the trip request payload sent via #1730

### Out of Scope
- Card details entry or saved card management (handled separately)
- Wallet top-up
- Payment method change after trip submission
- Promo codes

### Dependencies
- #1730 — Rider selects payment method for trip (API — must be live)
- #1552 — Rider sees fare estimate before requesting (must be built)

---

## [Mobile] #1734 — Rider completes online card payment at trip end 🆕
**Feature:** Feature 17 — Payments | **Sprint:** 2

**Description:** As a rider, I want to pay by card at the end of my trip so that I don't need to carry cash.

### Background
When the trip's payment method is Card, the trip-complete screen shows a payment processing state before the usual trip summary and rating prompt. The payment is charged automatically via #1733. If payment succeeds, the rider sees the charged amount and a receipt note. If payment fails, the rider is offered a Retry option and a "Pay Cash to Driver" fallback.

### Acceptance Criteria

**Scenario 1 — Card payment processes successfully**
- Given the trip ends and the payment method is Card
- When the trip-complete screen loads
- Then a payment processing indicator is shown briefly
- And on success, the trip summary is shown with the charged amount
- And a receipt confirmation is shown to the rider
- And the driver is notified that payment was received

**Scenario 2 — Card payment fails — rider retries**
- Given the card payment fails
- When the rider taps "Retry Payment"
- Then the payment is attempted again via #1733
- And on success, the normal completion flow continues

**Scenario 3 — Card payment fails — rider switches to cash**
- Given the card payment fails after retry
- When the rider taps "Pay Cash to Driver"
- Then the trip is marked as cash-settled
- And the driver is notified to collect cash
- And the rider sees the cash amount to hand over

**Scenario 4 — Cash trip skips card payment screen**
- Given the trip's payment method is Cash
- When the trip-complete screen loads
- Then no payment processing state is shown
- And the cash fare amount to hand to the driver is displayed

### Out of Scope
- Card details entry (card is pre-saved separately)
- Partial payments
- Refunds

### Dependencies
- #1733 — Trip fare is charged to rider's card at trip completion (API — must be live)
- #1564 — Rider sees trip summary with cash fare (must be built)

---

## [Mobile] #1793 — Rider with an unresolved payment failure is blocked from booking 🆕
**Feature:** Feature 17 — Payments (Rider) | **Sprint:** Phase 1

**Description:** As a rider, I want to be told when a past payment failed and be guided to settle it so that I can book rides again.

### Background
If a previous card payment failed (#1734/#1733) and remains unresolved, the platform rejects new trip requests (#1784). When the rider taps "Request Ride", she sees a clear, bilingual blocking message stating the outstanding amount and offering a path to settle it. Once the amount is settled, booking works again. All strings flow through `data-i18n` keys with Arabic fallback; transient errors use a toast.

### Acceptance Criteria

**Scenario 1 — Blocked rider is informed on booking**
- Given the rider has an unresolved payment failure
- When she taps "Request Ride"
- Then a bilingual message shows the outstanding amount and a way to settle it
- And no trip request is submitted

**Scenario 2 — Rider settles and can book**
- Given the rider settles the outstanding amount
- When she taps "Request Ride" again
- Then the booking proceeds normally

**Scenario 3 — Rider with no failure books normally**
- Given the rider has no unresolved payment failure
- When she taps "Request Ride"
- Then booking proceeds normally

**Scenario 4 — Network error**
- Given the eligibility check fails on the network
- Then a bilingual toast error is shown and she can retry

### Out of Scope
- The card charge flow itself (#1734/#1733)
- Refunds
- Operations manual override

### Dependencies
- #1784 — Booking is blocked when the rider has an unresolved payment failure (API — must be live)
- #1734 — Rider completes online card payment at trip end

---

### Feature 19 — Scheduled Rides (Rider)

---

## [Mobile] #1737 — Rider schedules a ride in advance 🆕
**Feature:** Feature 19 — Scheduled Rides | **Sprint:** 2

**Description:** As a rider, I want to schedule a ride for a future date and time within operating hours so that I can arrange transportation in advance and be matched with a driver automatically when the time approaches.

### Background
From the home screen the rider can switch from "Request now" to "Schedule for later". After setting pickup (#1550) and destination (#1551), she opens a date/time picker and chooses when she wants to be picked up. The scheduled pickup time must be at least 30 minutes ahead, no more than 7 days ahead, and fall inside the daytime operating window (OD-001; see #1791). She selects a payment method (#1732) and, if applicable, declares a child passenger (#1790). An indicative fare estimate (#1552) is shown but is recalculated at dispatch. On confirmation the scheduled trip is created via #1738 and appears in her "Scheduled rides" list, where she can review or cancel it before dispatch. Approximately 15 minutes before the scheduled pickup time the platform automatically begins matching (creating a live trip request and entering the matching flow #1554); the rider is notified by push when matching starts and again when a driver is found. Modifying a scheduled ride is done by cancelling and rebooking. The lead time (30 minutes minimum ahead), booking horizon (7 days maximum ahead), and dispatch window (matching begins 15 minutes before the scheduled pickup time) are final, confirmed product values. All user-visible strings flow through `data-i18n` keys with Arabic fallback.

### Field Validation

| Field | Required | Rule | Error (AR / EN) |
|---|---|---|---|
| Scheduled date & time | Yes | ≥ 30 min from now; ≤ 7 days ahead; within daytime operating hours (OD-001) | يجب اختيار وقت ضمن ساعات العمل وبعد 30 دقيقة على الأقل / Choose a time at least 30 minutes ahead and within operating hours |
| Pickup | Yes | Set via map/autocomplete (per #1550) | اختاري موقع الانطلاق / Choose a pickup |
| Destination | Yes | Set via map/autocomplete (per #1551) | اختاري وجهتك / Choose a destination |
| Payment method | Yes | Cash or Card (per #1732) | اختاري طريقة الدفع / Choose a payment method |

### Acceptance Criteria

**Scenario 1 — Rider schedules a ride successfully**
- Given the rider has set a valid pickup, destination, payment method, and a scheduled time that is ≥ 30 min ahead, ≤ 7 days ahead, and within operating hours
- When she taps "Schedule ride"
- Then the scheduled trip is created via #1738
- And it appears in her "Scheduled rides" list with its date, time, pickup, destination, and payment method

**Scenario 2 — Scheduled time is too soon**
- Given the rider selects a time less than 30 minutes from now
- When she confirms
- Then a bilingual validation error is shown and no scheduled trip is created

**Scenario 3 — Scheduled time is outside operating hours**
- Given the rider selects a time outside the daytime operating window (OD-001)
- When she confirms
- Then a bilingual message explains the service is closed at that time and suggests a time inside the window
- And no scheduled trip is created

**Scenario 4 — Scheduled time is beyond the booking horizon**
- Given the rider selects a time more than 7 days ahead
- When she confirms
- Then a bilingual validation error is shown and no scheduled trip is created

**Scenario 5 — Payment method and child declaration are carried into the scheduled trip**
- Given the rider selected a payment method (#1732) and optionally declared a child passenger (#1790)
- When the scheduled trip is created
- Then both are stored with the scheduled trip and applied when it is dispatched

**Scenario 6 — Rider views her upcoming scheduled rides**
- Given the rider has at least one upcoming scheduled ride
- When she opens the "Scheduled rides" list
- Then each entry shows the scheduled date/time, pickup, destination, and payment method, soonest first

**Scenario 7 — Rider cancels a scheduled ride before dispatch**
- Given a scheduled ride has not yet been dispatched
- When the rider cancels it and confirms
- Then it is removed from her scheduled rides via #1738 with no fee

**Scenario 8 — Platform auto-dispatches at lead time**
- Given a scheduled ride reaches its dispatch window (about 15 minutes before pickup) and the service is open
- When the platform dispatches it
- Then a live trip request is created and the matching flow (#1554) begins
- And the rider receives a push that matching has started, and again when a driver is found

**Scenario 9 — No driver available at dispatch**
- Given a scheduled ride is dispatched but no driver is found within the matching window
- Then standard no-driver handling applies and the rider is notified

**Scenario 10 — Network error during scheduling**
- Given the rider taps "Schedule ride"
- When the request fails
- Then a bilingual toast error is shown and she can retry
- And no duplicate scheduled trip is created

### Out of Scope
- Recurring / repeating scheduled rides
- Modifying a scheduled ride in place (cancel and rebook instead)
- Scheduled-ride-specific surge or pricing
- Guaranteed driver assignment at the exact scheduled minute

### Dependencies
- #1738 — Rider schedules a ride in advance (API — must be live)
- #1552 — Rider sees fare estimate before requesting (indicative estimate)
- #1732 — Rider selects a payment method
- #1790 — Rider declares the passenger is a child (optional, per trip)
- #1791 — Rider cannot book outside operating hours / OD-001
- #1554 — Rider sees matching screen (reused at dispatch)

---

### Feature 20 — Trip Cancellation (Rider)

---

## [Mobile] #1719 — Rider cancels a trip 🆕
**Feature:** Feature 20 — Trip Cancellation | **Sprint:** 2

**Description:** As a rider, I want to cancel an active trip request so that I can change my mind before a driver accepts and I'm not charged a fare.

### Background
The rider can cancel at two points in the trip lifecycle: (1) while the trip is in searching state on the matching screen — no driver has been assigned yet — in which case no cancellation fee is charged; (2) after a driver has been matched and is en_route_pickup, with no fee if the driver took less than 3 minutes en route (if more, a fee applies); (3) if the driver has already arrived (arrived_pickup state), a cancellation fee applies to discourage late cancellations. Once the driver starts the trip (trip_started), cancellation is no longer available to the rider. On successful cancellation the rider is returned to the home screen with her pickup and destination fields still populated, and the assigned driver (if any) is notified via #1715.

### Acceptance Criteria

**Scenario 1 — Rider cancels while searching (no driver assigned, no fee)**
- Given the rider has submitted a trip request and is on the matching screen in searching state
- When the rider taps "Cancel" and confirms in the confirmation dialog
- Then the trip is cancelled with no fee
- And the rider is navigated to the home screen with her pickup and destination still populated with the fare estimate recalculated

**Scenario 2 — Rider cancels after match, driver en route**
- Given a driver has been matched and the trip is in en_route_pickup state
- When the rider taps "Cancel" and confirms
- Then the trip is cancelled with no fee if the driver took less than 3 minutes en route; if more, a fee applies
- And the driver receives a push notification informing her the trip was cancelled
- And the rider is navigated to the home screen

**Scenario 3 — Rider cancels after driver arrives (cancellation fee applies)**
- Given the trip is in arrived_pickup state
- When the rider taps "Cancel"
- Then a confirmation dialog is shown informing the rider that a cancellation fee applies
- When the rider confirms
- Then the trip is cancelled and the cancellation fee is recorded against the rider's account
- And the driver receives a push notification
- And the rider is navigated to the home screen

**Scenario 4 — Rider dismisses the cancellation dialog**
- Given the rider taps "Cancel" at any stage
- When the confirmation dialog appears and the rider taps "Go Back"
- Then the dialog is dismissed and the rider remains on the current screen
- And the trip is not cancelled

**Scenario 5 — Cancel button is not shown after trip starts**
- Given the trip is in trip_started state
- Then no cancel button is shown on the active trip screen

**Scenario 6 — Network error during cancellation**
- Given the rider confirms cancellation
- When the network request fails
- Then a toast message is shown: "Unable to cancel. Please try again."
- And the rider remains on the current screen

### Out of Scope
- Cancellation fee payment processing
- Cancellation fee waiver or dispute
- Admin-initiated cancellation
- Driver-initiated trip cancellation (separate story)

### Dependencies
- #1715 — Rider cancels a trip (API — must be live)
- #1554 — Rider sees matching screen (must be built)
- #1652 — Driver advances trip state machine (must be live)

---

### Feature 21 — Emergency & Safety (Rider)

---

## [Mobile] #1723 — Rider triggers SOS during active trip 🆕
**Feature:** Feature 21 — Emergency & Safety | **Sprint:** 2

**Description:** As a rider, I want to trigger an SOS alert during an active trip so that emergency assistance can be dispatched immediately.

### Background
This is a placeholder story. The SOS and emergency flow is SheDrive's primary safety differentiator — direct line to the Ministry of Interior — and requires dedicated requirements-gathering with the operations and legal teams before implementation can begin. The full scope will be defined in a future sprint. This story must not be picked up for development until replaced with a complete specification.

### Acceptance Criteria

**Scenario 1 — PLACEHOLDER**
- Given [TBD]
- When the rider activates SOS during an active trip
- Then [TBD — full scenarios to be defined in a future sprint]

### Out of Scope
- All implementation details — pending requirements

### Dependencies
- TBD — requires Ministry of Interior integration specification

---

## [Mobile] #1787 — Rider sets up trusted contacts who receive a live trip link on SOS 🆕
**Feature:** Feature 21 — Emergency & Safety (Rider) | **Sprint:** Phase 1

**Description:** As a rider, I want to save trusted contacts and have them automatically receive a live trip-tracking link when I trigger SOS so that people I trust can follow my location during an emergency.

### Background
From the profile/safety section the rider can add, edit, and remove trusted contacts (name + phone number). Having a contact is encouraged but not required. Live-location sharing is tied to SOS only: when the rider triggers SOS during an active trip (#1723), the platform sends each saved trusted contact a secure live trip-tracking link (#1780). There is no standalone "share my trip" button in Phase 1. All user-visible strings flow through `data-i18n` keys with Arabic fallback.

### Field Validation

| Field | Required | Rule | Error (AR) |
|---|---|---|---|
| Contact name | Yes | 2–50 letters and spaces | أدخلي اسم جهة الاتصال |
| Contact phone | Yes | Valid Egyptian mobile number | رقم الهاتف غير صالح |

### Acceptance Criteria

**Scenario 1 — Rider adds a trusted contact (max 5 contacts)**
- Given an authenticated rider opens the trusted contacts screen
- When she enters a valid name and phone number and saves
- Then the contact is stored via #1780 and shown in her list

**Scenario 2 — Rider edits or removes a trusted contact**
- Given the rider has at least one trusted contact
- When she edits or removes it
- Then the change is persisted via #1780

**Scenario 3 — Invalid phone shows a validation error**
- Given the rider enters an invalid phone number
- When she taps save
- Then a bilingual validation error is shown and nothing is saved

**Scenario 4 — On SOS, trusted contacts are alerted with a live link**
- Given the rider has at least one trusted contact and triggers SOS during an active trip (#1723)
- When the SOS is sent
- Then the app confirms that her trusted contacts have been alerted with a live trip-tracking link

**Scenario 5 — SOS with no trusted contacts**
- Given the rider has no trusted contacts and triggers SOS
- Then SOS is still sent
- And she is informed that no trusted contacts are configured and is prompted to add one

### Out of Scope
- Standalone (non-SOS) live trip sharing
- Calling or chatting with trusted contacts
- Notifying trusted contacts on normal (non-SOS) trip events

### Dependencies
- #1780 — Rider's trusted contacts are notified with a live trip link on SOS (API — must be live)
- #1723 — Rider triggers SOS during active trip
