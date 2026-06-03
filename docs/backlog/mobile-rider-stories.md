# SheDrive — Mobile Rider Stories
> Canonical backlog for all [Mobile] Rider stories. Organized by sprint and feature.
> Last updated: 2026-06-03
> Stories with changes from original are marked ✏️

---

## Sprint 1

### Feature 2 — Rider Authentication

---

## [Mobile] #1545 — Rider registers
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want to register an account using my phone number and a one-time passcode so that I can access the SheDrive app with a verified identity.

### Background
The rider registration flow consists of two screens. Screen 1 collects the rider's Egyptian mobile number and, on tapping "إرسال الرمز" (Send Code), triggers OTP dispatch via #1620. Screen 2 collects the 6-digit OTP (auto-submits on the 6th digit entry) and the rider's full name, then creates the account via #1621. On success, the rider is taken to the home screen with an active session. If the phone number is already registered, the app displays a message and a link to the login flow.

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

**Scenario 2 — Phone number already registered**
- Given a rider enters a phone number that is already linked to an existing account
- When she taps "إرسال الرمز"
- Then the OTP is still sent (the server sends it regardless per #1620)
- And after OTP entry, the app detects the conflict via #1621 and displays "هذا الرقم مسجل بالفعل. سجّل الدخول بدلاً من ذلك" with a link to the login screen

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

## [Mobile] #1546 — Rider logs in
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

**Scenario 6 — Network error**
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
- Then the token is rejected by #1619 and the rider is shown the login screen

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

## [Mobile] #1553 — Rider submits trip request
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to submit a trip request from the home screen so that I can be matched with a nearby driver.

### Background
The rider has already set her pickup location and destination on the home screen and has seen the fare estimate. When she taps "Request Ride," the app sends her trip request to the platform and navigates her to the matching screen. The home screen inputs are not re-validated here — all validation occurred before the estimate was shown. The rider should experience a near-instant transition with no loading friction.

### Acceptance Criteria

**Scenario 1 — Successful trip request submission**
- Given the rider is authenticated and on the home screen with a valid pickup and destination set
- When she taps "Request Ride"
- Then the app sends the trip request to the platform
- And the rider is immediately navigated to the matching screen (#1554)
- And a loading indicator is shown briefly during the network call

**Scenario 2 — Network error during submission**
- Given the rider taps "Request Ride"
- When the network request fails (timeout or connectivity loss)
- Then a toast message is shown: "Something went wrong. Please try again."
- And the rider remains on the home screen with her pickup and destination still populated

**Scenario 3 — Server error during submission**
- Given the rider taps "Request Ride"
- When the platform returns a server-side error
- Then a toast message is shown: "Unable to submit request. Please try again."
- And the rider remains on the home screen

### Out of Scope
- Fare confirmation screen
- Scheduled rides
- Multiple stop trips
- Promo code entry
- Trip cancellation flow

### Dependencies
- #1629 — Rider creates trip request (API — must be live)
- #1554 — Rider sees matching screen (must be built)

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

## [Mobile] #1556 — Rider receives push on match confirmation ✏️
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when a driver is matched to my request so that I am informed even if the app is running in the background.

### Background
After a driver accepts the trip, the platform sends a push notification to the rider's device. The notification content is: "Driver found! [Driver name] is on the way." If the rider taps the notification while the app is in the background or closed, the app opens directly to the active trip screen. If the app is already in the foreground, the notification is handled silently and the UI transitions automatically without showing an OS-level banner.

### Acceptance Criteria

**Scenario 1 — Push notification delivered while app is in background**
- Given the rider's app is in the background and a driver has accepted the trip
- When the platform sends the match-confirmation push
- Then the rider's device displays a notification with the title "Driver found!" and body "[Driver name] is on the way."
- And tapping the notification opens the app to the active trip screen

**Scenario 2 — Push notification delivered while app is in foreground**
- Given the rider's app is in the foreground on the matching screen
- When the match-confirmation push arrives
- Then the app transitions automatically to the driver card / active trip view
- And no duplicate OS-level banner is shown unnecessarily

**Scenario 3 — Push notification token not registered**
- Given the rider's device token has not been registered with the platform
- When the platform attempts to send the match-confirmation push
- Then the push silently fails (no crash)
- And the rider still sees the driver card when she returns to the app (via polling)

**Scenario 4 — Push tapped when app is closed**
- Given the rider's app is fully closed
- When she taps the match-confirmation push notification
- Then the app launches and navigates directly to the active trip screen
- And the rider does not have to navigate manually

**Scenario 5 — Notification delivered in the rider's preferred language**
- Given the rider's language preference (`shedrive.lang`) is set to "ar" or "en"
- When the platform dispatches the match-confirmation push notification
- Then the notification title and body are rendered in the rider's preferred language
- And Arabic ("ar") is used as the default when no language preference is stored
- And the platform maintains both Arabic and English versions of all push notification templates

### Out of Scope
- Push notification settings management
- SMS fallback for push delivery failures
- In-app notification inbox

### Dependencies
- #1618 — Push notification service integration (must be live)
- #1634 — Match confirmation push trigger (API — must be live)

---

## [Mobile] #1557 — Rider sees no-driver error and returns home
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a clear message when no driver is available so that I understand what happened and can easily try again.

### Background
If all dispatched drivers reject the trip or their acceptance windows expire, or if no online drivers are within range when the request is submitted, the platform marks the trip as expired and notifies the rider. The rider is shown a full-screen or prominent error state with a human-friendly message and a single call-to-action to return to the home screen and resubmit. The rider should not feel abandoned — the screen must convey that the situation is temporary.

### Acceptance Criteria

**Scenario 1 — No-driver error screen displays correctly**
- Given the platform has marked the rider's trip as expired (no driver found)
- When the matching screen receives the no_driver status
- Then the rider sees the message "No drivers available right now"
- And a supportive sub-message is shown (e.g., "Please try again in a few minutes")
- And a "Try Again" button is displayed prominently

**Scenario 2 — Rider taps "Try Again"**
- Given the no-driver error screen is displayed
- When the rider taps "Try Again"
- Then the rider is returned to the home screen
- And her previously entered pickup and destination are pre-populated
- And she can immediately re-submit the request

**Scenario 3 — Rider receives push notification for no-driver**
- Given the platform has expired the trip
- When the push notification is received (from #1632)
- Then the notification reads "We couldn't find a driver. Please try again."
- And tapping the notification while app is backgrounded opens the app to the no-driver error screen

**Scenario 4 — Network error prevents status update**
- Given the rider is on the matching screen and the network is lost
- When connectivity is restored
- And the poll returns no_driver status
- Then the no-driver error screen is shown correctly

### Out of Scope
- Automatic retry without rider action
- Queueing the request for when a driver becomes available
- Driver availability map

### Dependencies
- #1632 — Trip expires and rider is notified via push (API — must be live)

---

### Feature 10 — Active Trip (Rider)

---

## [Mobile] #1558 — Rider sees driver live location while waiting
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location on the map while she heads to my pickup so that I know how close she is.

### Background
After a driver accepts the trip, the rider's active trip screen displays a map with two pins: the rider's pickup location and the driver's current position as a moving dot. The driver's ETA to the pickup is displayed and updated every 5 seconds as the platform receives new GPS coordinates. The rider remains on this screen until the driver marks arrival.

### Acceptance Criteria

**Scenario 1 — Driver location dot appears on rider's map**
- Given a driver has accepted the rider's trip
- When the rider opens the active trip screen
- Then a moving dot representing the driver's location is visible on the map
- And the rider's pickup pin is also shown

**Scenario 2 — Driver location updates in near real time**
- Given the active trip screen is displayed in en_route_pickup state
- When the platform receives a new GPS position from the driver
- Then the driver's dot moves to the updated position within 5 seconds
- And the displayed ETA refreshes accordingly

**Scenario 3 — Rider stays on screen until driver arrives**
- Given the trip is in en_route_pickup state
- When the rider is viewing the active trip screen
- Then no automatic navigation away from the screen occurs
- And the screen updates automatically when the driver marks arrival

### Out of Scope
- Turn-by-turn route preview for the rider
- ETA notifications via push during this phase
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1559 — Rider sees driver-arrived state
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want my screen to update when the driver arrives so that I know to head to the pickup point.

### Background
When the driver taps "I've Arrived" and the trip state advances to arrived_pickup, the rider's active trip screen automatically transitions to a "Your driver has arrived" state. The map continues to show the driver's pin at the pickup location. No action is required from the rider on this screen — she simply proceeds to board.

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

### Out of Scope
- Automated check-in for the rider
- Geofence detection on the rider's device
- SOS functionality

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

## [Mobile] #1561 — Rider sees driver live location during trip
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location on the map while we travel to the destination so that I can follow our progress.

### Background
Once the driver taps "Start Trip" and the state advances to trip_started, the rider's map updates to show the driver's location moving toward the destination. The destination pin is visible on the map. GPS coordinates received from the driver every 5 seconds update the moving dot in near real time. The rider remains on this screen until the trip ends.

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

**Scenario 3 — Rider screen transitions automatically on trip end**
- Given the rider is watching the map during trip_started state
- When the driver taps "End Trip" and the state advances to trip_ended
- Then the rider's screen automatically transitions to the trip summary

### Out of Scope
- Route polyline rendering on the rider's map
- Estimated arrival time to destination for the rider
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1562 — Rider sees driver details during trip
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's name, photo, and vehicle details throughout the trip so that I can confirm I am with the correct driver.

### Background
Throughout the active trip — from en_route_pickup through trip_ended — the rider sees a persistent driver card on the active trip screen. The card displays the driver's name, profile photo (or a placeholder avatar if no photo is set), vehicle make and model, vehicle color, and license plate number. This information is sourced from the trip details returned by the platform.

### Acceptance Criteria

**Scenario 1 — Driver card shows name and vehicle details**
- Given the rider is on the active trip screen in any active state
- When the driver card is rendered
- Then the driver's full name is displayed
- And the vehicle make, model, color, and plate number are displayed

**Scenario 2 — Driver photo or placeholder is shown**
- Given the rider is viewing the driver card
- When the driver has a profile photo on file
- Then the driver's profile photo is shown in the card avatar
- And when the driver has no profile photo, a placeholder avatar is shown instead

**Scenario 3 — Driver card is visible across all active states**
- Given the trip is in en_route_pickup, arrived_pickup, or trip_started state
- When the rider views the active trip screen
- Then the driver card remains visible without requiring any action

### Out of Scope
- Rider-initiated contact with the driver (chat or call)
- Sharing driver details with a third party from this screen
- SOS functionality

### Dependencies
- #1633 — Rider retrieves live trip state and driver location (must be live)

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

## [Mobile] #1566 — Rider skips rating
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to skip rating so that I can go home quickly without being forced to provide feedback.

### Background
A "Skip" option is available on both the trip summary screen and the rating screen. When the rider taps "Skip", no rating is submitted and the rider is taken directly to the home screen. The skip action is final — the rider cannot return to rate the same trip. The trip is still recorded as complete and visible in trip history.

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

**Scenario 3 — Skip is final — rider cannot return to rate**
- Given the rider has skipped the rating for a trip
- When she navigates back in the app
- Then the rating screen for that trip is no longer accessible
- And the trip is shown as complete in trip history without a rating

**Scenario 4 — Trip is still visible in history after skip**
- Given the rider has skipped the rating
- When the trip is viewed in trip history
- Then the trip record is present and complete
- And no rating is shown for that trip

### Out of Scope
- Prompting the rider to rate at a later time
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

## [Mobile] #1568 — Rider views past trip detail ✏️
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a rider, I want to view the full details of a past trip so that I can understand the fare breakdown and confirm where I travelled.

### Background
When a rider taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the complete picture of that trip: timing, addresses, fare breakdown, and who drove her. If she previously submitted a star rating for this trip, that rating is also shown. The screen is read-only — no actions are available.

### Acceptance Criteria

**Scenario 1 — Rider views detail of a rated trip**
- Given the rider has navigated to the detail screen for a past trip she rated
- When the screen loads
- Then it displays: date and time, pickup address, destination address, total fare (EGP), fare breakdown (base fare + distance charge + time charge), trip duration, distance travelled, driver name, and vehicle information
- And the star rating she submitted is shown

**Scenario 2 — Rider views detail of an unrated trip**
- Given the rider has navigated to the detail screen for a past trip she did not rate
- When the screen loads
- Then all trip details are shown as in Scenario 1
- And the rating section is absent or shows a placeholder indicating no rating was given

**Scenario 3 — Rider navigates back to the list**
- Given the rider is on the trip detail screen
- When she presses the back button
- Then she is returned to the trip history list at the same scroll position

### Out of Scope
- Submitting or editing a rating from this screen
- Disputing a fare
- Contacting the driver
- SOS history

### Dependencies
- #1641 — Rider retrieves trip history (must be live)
- #1639 — Rider submits driver rating (rating data source)
