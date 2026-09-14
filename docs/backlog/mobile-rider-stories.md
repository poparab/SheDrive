# SheDrive — Mobile Rider Stories
> Canonical backlog for all [Mobile] Rider stories. Organized by sprint and feature.
> Last updated: 2026-08-05
> Stories with changes from original are marked ✏️

---

## Sprint 1

### Feature 2 — Rider Authentication

---

## [Mobile] #1545 — Rider registers
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want to register an account using my phone number and a one-time passcode so that I can access the SheDrive app with a verified identity.

### Background

The rider registration flow consists of two screens. Screen 1 collects the rider’s Egyptian mobile number and, on tapping "إرسال الرمز" (Send Code), triggers OTP dispatch via #1620. Screen 2 collects the 6-digit OTP (auto-submits on the 6th digit entry) and the rider’s full name, then creates the account via #1621. On success, the rider is taken to the home screen with an active session. If the phone number is already registered, #1621 auto-logs her in and she is taken to the home screen with an active session — no conflict error is shown.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| رقم الهاتف | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |
| الاسم الكامل | Yes | Arabic and/or Latin letters and spaces only; no digits or symbols | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخل اسمك الكامل | الاسم يجب أن يحتوي على حروف فقط | الاسم يجب أن يكون بين 2 و 50 حرفاً |

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

---

## [Mobile] #1546 — Rider logs in ✏️
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 1

**Description:** As a rider, I want to log in to my existing account using my phone number and a one-time passcode so that I can access the app without remembering a password.

### Background

The login flow uses OTP-based authentication. The rider enters her registered phone number, the platform sends a one-time code via SMS (#1622), and she enters the code to authenticate. A valid session token is created on success. If the entered phone number is not found in the system, the rider is directed to the registration screen. The OTP is valid for a limited window; up to 3 incorrect attempts are permitted before the session is locked and a fresh OTP must be requested.

### Field Validation

| Field | Required | Format | Min | Max | Error — empty | Error — invalid format |
|---|---|---|---|---|---|---|
| Phone number | Yes | Egyptian mobile: 01X-XXXXXXXX (10 digits, starts with 010 011 012 or 015) | 10 digits | 10 digits | رقم الهاتف مطلوب / Phone number is required | رقم هاتف غير صحيح / Invalid phone number |
| OTP code | Yes | 6-digit numeric code | 6 digits | 6 digits | أدخل رمز التحقق / Enter verification code | الرمز يجب أن يكون 6 أرقام / Code must be 6 digits |

### Acceptance Criteria

**Scenario 1 — Successful login**
- Given the rider enters a valid registered phone number and taps "إرسال الرمز" / "Send Code"
- Then the OTP is sent via #1622
- And she is navigated to the OTP entry screen
- When she enters the correct 6-digit code within the validity window
- Then she is authenticated and navigated to the home screen

**Scenario 2 — Phone number not registered**
- Given the rider enters a phone number that is not in the system
- When she taps "إرسال الرمز"
- Then a message is shown: "هذا الرقم غير مسجل. هل تريدين إنشاء حساب جديد؟" / "This number is not registered. Would you like to create a new account?"
- And a link to the registration screen is shown

**Scenario 3 — Wrong OTP entered**
- Given the rider enters an incorrect 6-digit code
- When she taps "تأكيد" / "Verify"
- Then an error is shown: "الرمز غير صحيح. حاول مجدداً" / "Incorrect code. Please try again."
- And the attempt counter increments
- And she remains on the OTP entry screen

**Scenario 4 — OTP expires before submission**
- Given the rider does not enter the OTP within the validity window
- When the OTP expires
- Then the input is disabled and a message is shown: "انتهت صلاحية الرمز" / "Code has expired."
- And a "إعادة إرسال الرمز" / "Resend Code" link becomes active

**Scenario 5 — Resend OTP during cooldown period**
- Given the OTP was just sent
- When the rider taps "إعادة إرسال الرمز" before the cooldown period expires
- Then the button is disabled and shows the remaining cooldown seconds

**Scenario 6 — Resend OTP after cooldown**
- Given the cooldown period has elapsed
- When the rider taps "إعادة إرسال الرمز"
- Then a new OTP is sent via #1622
- And the cooldown timer resets

**Scenario 7 — Maximum OTP attempts reached (3 failed attempts)**
- Given the rider has entered 3 incorrect OTP codes
- Then the OTP entry screen is locked
- And a message is shown: "تم تجاوز الحد المسموح. يرجى طلب رمز جديد." / "Too many attempts. Please request a new code."
- And the rider must request a fresh OTP to continue

**Scenario 8 — Network error during phone number submission**
- Given the rider taps "إرسال الرمز"
- When the network request fails
- Then a toast is shown: "حدث خطأ. تحقق من اتصالك وحاول مجدداً." / "Something went wrong. Check your connection and try again."
- And the rider remains on the phone entry screen

**Scenario 9 — Network error during OTP verification**
- Given the rider taps "تأكيد" to submit the OTP
- When the network request fails
- Then a toast is shown: "حدث خطأ. تحقق من اتصالك وحاول مجدداً." / "Something went wrong. Check your connection and try again."
- And the rider remains on the OTP entry screen with her entered code preserved

### Out of Scope
- Password-based login
- Social login (Google, Facebook)
- Biometric login
- Device trust / remember this device
- Account deletion from login screen

### Dependencies
- #1622 — OTP is sent to rider's phone for login (must be live)

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
- And she is taken to the splash/login screen



**Scenario 2 — Network error during logout**
- Given the device has no internet connection when the rider taps "تسجيل الخروج"
- When the logout request fails
- Then the app clears the local session and takes the rider to the login screen regardless
- And the token is invalidated on the server the next time connectivity is restored (or on token expiry)

### Out of Scope
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

**Scenario 1 — Valid stored token → home screen on relaunch**
- Given a rider has previously logged in and her session token is stored in secure storage
- When she relaunches the app
- Then the app validates the token silently in the background
- And she is taken directly to the home screen with no OTP or login prompt

**Scenario 2 — No stored token → login screen**
- Given the device has no stored session token (first launch or after logout)
- When the app launches
- Then the rider is shown the splash/login screen
- And no background validation request is made

**Scenario 3 — Expired token on launch → login screen**
- Given a rider's stored token has passed its 90-day lifetime
- When the app validates it on launch and the server returns 401
- Then the local token is cleared from secure storage
- And the rider is shown the login screen

**Scenario 4 — Mid-session 401 → clear session and redirect to login**
- Given a rider is actively using the app and any API call returns 401
- When the app intercepts the 401 response
- Then the stored session token is cleared from secure storage
- And the rider is navigated to the login screen
- And a message is shown indicating her session has expired

**Scenario 5 — Token is stored in secure storage only**
- Given a session token is issued after login or registration
- When the token is persisted on the device
- Then it is stored exclusively in iOS Keychain (iOS) or Android Keystore (Android)
- And it is never written to plain SharedPreferences, AsyncStorage, or any unencrypted store

**Scenario 6 — Token is cleared on explicit logout**
- Given a rider taps تسجيل الخروج (#1547)
- When logout completes
- Then the session token is removed from secure storage
- And the next app launch shows the login screen with no auto-login attempt

**Scenario 7 — Network unavailable on launch → offline grace period**
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
- #1619 — Auth middleware validates session tokens (must be live)
- #1547 — Rider logs out (token must be cleared on logout)

---

### Feature 7 — Rider Home, Address Search & Fare Estimate

---

## [Mobile] #1548 — Rider sees home screen with map
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want to see a map of Cairo/Giza centered on my current location with pickup and destination inputs so that I can quickly start booking a ride.

### Background

The rider home screen is the main screen after login for verified riders. It shows a full-screen map centered on the rider’s GPS location. Two input fields are shown: pickup and destination. The "Request Ride" CTA is visible but inactive until both fields are filled and a fare estimate has been fetched (#1552). GPS permission is needed to auto-detect the pickup address; if denied, the pickup field is empty and the rider must enter it manually.

### Acceptance Criteria

**Scenario 1 — Happy path: GPS available, map centered on rider**
- Given a verified rider opens the app and GPS permission is granted
- When the home screen loads
- Then a full-screen Cairo/Giza map is displayed, centered on the rider’s current location
- And a pickup input and a destination input are both visible
- And the pickup input is pre-filled with the rider’s current address (reverse-geocoded)
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
- #1626 — Address autocomplete returns suggestions (must be live)
- #1627 — Fare estimate uses Google Maps route data (must be live)

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

---

## [Mobile] #1552 — Rider sees fare estimate before requesting
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a rider, I want to see an estimated fare and trip duration before I request a ride so that I can make an informed decision about booking.

### Background

Once both pickup and destination are set on the home screen (#1548), the app automatically calls the fare estimate API (#1627). The response is displayed fare and an estimated trip duration in minutes. The "Request Ride" CTA activates only after a successful fare fetch. If the fetch fails, a retry option is shown. If the rider changes either address, the estimate is recalculated automatically.

### Acceptance Criteria

**Scenario 1 — Happy path: fare and duration displayed**
- Given both pickup and destination are set
- When the fare estimate API (#1627) returns a result
- Then fare is displayed on screen
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
- #1627 — Fare estimate uses Google Maps route data (must be live)
- #1628 — Fare applies base, per-km, and per-minute rates (must be live)

---

## [Mobile] #3995 — Rider sees an outstanding fee before she requests a ride 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** Phase 1

**Description:** As a rider with an outstanding fee, I want to see that fee as its own amount before I confirm a ride so that I know it is being added to this trip and never discover it hidden inside the fare.

### Background

When a rider has an outstanding fee (financial core design §3) and both pickup and destination are set on the home screen (#1548), the fee that will be added to this trip is shown as its own line, separate from the fare estimate (#1552) — for example: fare estimate 100.00 EGP, outstanding fee 20.00 EGP, next-ride total 120.00 EGP. The fee amount is never folded silently into the displayed fare estimate; the fare estimate itself is unchanged from what a rider with no outstanding fee would see.

Only one outstanding fee is applied per trip, oldest first, matching the order shown on the payments screen (#3992). If she owes more than one fee, the remaining fees stay outstanding and are carried into a later trip in turn.

This is the moment a rider first sees, concretely, that today's ride is paying for something that happened on an earlier one. The copy names the earlier trip plainly — its date, and that it was a late cancellation — rather than presenting the charge as an unexplained addition to today's fare, so she understands why it is there before she commits to the ride.

All strings — the fee banner, its amount, and its explanation — flow through `data-i18n` keys with Arabic fallback text in the HTML.

### Acceptance Criteria

**Scenario 1 — Outstanding fee shown as its own amount before confirming**
- Given the rider has one outstanding fee of 20.00 EGP and sets pickup and destination
- When the fare estimate is displayed
- Then the outstanding fee is shown as its own line of 20.00 EGP, separate from the fare estimate
- And the combined total she will pay this trip is also shown

**Scenario 2 — Fee is never folded into the fare estimate silently**
- Given the rider has an outstanding fee
- When she views the fare estimate
- Then the fare estimate itself is unchanged from what a rider with no outstanding fee would see
- And the fee appears only as its own separate, clearly labelled line

**Scenario 3 — Fee names the trip it came from**
- Given the rider has an outstanding fee
- When she views the fee line before requesting
- Then it states which earlier trip the fee is from and that it was a late cancellation

**Scenario 4 — Oldest fee first, one trip at a time**
- Given the rider has more than one outstanding fee
- When she views the fee line before requesting
- Then only the oldest outstanding fee is shown as being added to this trip
- And the remaining fees stay outstanding for a later trip

**Scenario 5 — No outstanding fee**
- Given the rider owes nothing
- When she sets pickup and destination
- Then no fee line is shown and the fare estimate is displayed as it is today

**Scenario 6 — Fee line persists through to the request**
- Given an outstanding fee is shown before she requests
- When she taps "Request Ride"
- Then the same fee amount is carried through with the trip request so it can be recovered when the trip completes (#3999)

### Out of Scope
- Paying the fee directly instead of carrying it into the next trip
- Splitting one fee's recovery across multiple trips
- Disputing the fee from this screen (Phase 2)

### Dependencies
- `#4000` — Rider outstanding fee is recovered on her next trip (API — must be live)
- #1552 — Rider sees fare estimate before requesting (extended by this story)
- `#3992` — Rider views her payment method and outstanding fees (fee ordering shown here matches that screen)

---

## [Mobile] #3998 — Rider is told when her full outstanding balance will be added to her next ride 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** Phase 1

**Description:** As a rider whose outstanding fees have reached the recovery threshold, I want to be told clearly that my whole balance will be added to this ride rather than one fee at a time so that the larger amount on my fare is never a surprise.

### Background

Below the recovery threshold a rider clears her fees gently — one fee per ride, oldest first (#3995). At or above the threshold that changes: **her entire outstanding balance is recovered on her next ride, in a single payment.** This story is that escalated state.

**There is deliberately no booking block.** An earlier draft of the design blocked a rider from booking once she passed the threshold. That deadlocks — a rider pays in cash on the ride, so the only way she can ever clear a fee is by taking a ride. Blocking her booking would make the debt permanent and lose the customer with no money recovered. Escalating the *recovery* instead is self-clearing: she books, she pays it all, she is square. Persistent abuse is handled by an admin suspending the rider (#1740), which is a human decision, not an automatic trap.

The recovery threshold is a policy value (financial core design §4; default 60.00 EGP) that a super admin configures with no code deploy. A threshold of 0 disables the escalation entirely — recovery then always stays at one fee per ride.

The notice in this state is **not dismissible**, unlike the ordinary #3995 banner. She must see the amount before she confirms. The tone stays factual, never punitive: state the amount, state that it clears her completely, and let her decide.

All strings — the heading, the amount, and the explanation — flow through `data-i18n` keys with Arabic fallback text in the HTML.

### Acceptance Criteria

**Scenario 1 — Full balance is recovered above the threshold**
- Given the recovery threshold is 60.00 EGP and the rider owes 65.00 EGP across three fees
- When she opens the home screen
- Then she is told her full 65.00 EGP will be added to this ride
- And the notice cannot be dismissed

**Scenario 2 — She can still book normally**
- Given the rider is above the recovery threshold
- Then the "Request Ride" action is available exactly as it is for any other rider
- And she is never blocked from booking on account of what she owes

**Scenario 3 — The fare summary reflects the full amount**
- Given she owes 65.00 EGP and the fare for the ride is 100.00 EGP
- When the ride completes
- Then the fee line reads 65.00 EGP and the total to pay is 165.00 EGP (#3999)
- And her outstanding balance becomes 0.00 EGP

**Scenario 4 — Below the threshold she gets the gentle drip instead**
- Given the rider owes 40.00 EGP across two fees and the threshold is 60.00 EGP
- When she opens the home screen
- Then she sees the ordinary dismissible notice for her oldest fee only (#3995)

**Scenario 5 — Crossing the threshold changes the state**
- Given the rider owes 55.00 EGP and cancels late again for a further 20.00 EGP
- When she next opens the home screen
- Then she is in the full-recovery state for the whole 75.00 EGP

**Scenario 6 — A threshold of 0 disables the escalation**
- Given the recovery threshold is configured at 0
- When the rider owes any amount
- Then recovery always stays at one fee per ride and this state is never shown

**Scenario 7 — An admin waiver drops her back**
- Given an admin waives a fee (#4005) bringing her below the threshold
- When she returns to the home screen
- Then she sees the ordinary #3995 notice instead

**Scenario 8 — Network error checking her fee status**
- Given the app cannot reach the platform to check her outstanding-fee status
- When the home screen loads
- Then it retries silently and shows the ordinary booking state rather than a wrong amount from a stale read

### Out of Scope
- Paying a fee directly from this screen
- Any automatic booking block — abuse is handled by rider suspension (#1740)
- Appealing or disputing a fee (Phase 2)
- Partial clearing of a single fee

### Dependencies
- `#4002` — Rider fees above the recovery threshold are recovered in a single payment (API — must be live)
- `#3994` — Super admin configures balance and fee policy (sets the threshold)
- `#3995` — Rider sees an outstanding fee before she requests a ride (the below-threshold state)
- `#3999` — Rider sees the recovered fee on her fare summary
- `#1740` — Operations admin suspends a rider account (the only block on a rider)

---

## Sprint 2

### Feature 8 — Trip Request & Matching

---

## [Mobile] #1554 — Rider sees matching screen
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a "Finding your driver" screen after submitting my request so that I know the system is actively searching on my behalf.

### Background

After the trip request is created, the rider is taken to the matching screen where the platform searches for a nearby driver. The screen provides animated visual feedback to reassure the rider that the search is in progress. The app polls the match-status endpoint periodically. A cancel button is visible on screen. When a match is found, the screen transitions to the driver card view (#1555). If no match is found within the matching window, the rider sees the no-driver error screen (#1557).

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
- #1633 — Rider tracks her active trip (API — must be live; supplies the driver's live position and ETA on this screen)

---

## [Mobile] #3768 — Rider is told her account is under review after a gender-mismatch report 🆕
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** Phase 1

**Description:** As a rider whose account has been flagged, I want to be told clearly that my account is under review and that I cannot book right now so that I understand why my ride request was refused and how to reach support.

### Background

When a driver raises a gender-mismatch report at pickup (#1588), the API cancels the trip and sets the rider's account to `pending_review` (#1687). #1687 Scenario 4 requires that a subsequent trip request is refused with a forbidden error and that "the rider app shows a message indicating the account is suspended pending review" — this story owns that screen, which had no owner until now.

The rider completes her booking as normal; the block is applied at the moment she requests the ride, mirroring the server behaviour rather than pre-emptively disabling the UI. She is then shown a dedicated account-under-review screen: account status, the report reference, the date it was raised, a note that no fare was charged for the cancelled trip, and routes to support or sign-out. The wording is deliberately non-accusatory — the report has not yet been adjudicated (#1811), and the rider may be reinstated on dismissal. All strings flow through data-i18n keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Request is refused while the account is under review**
- Given the rider's account is in pending_review after a gender-mismatch report
- When she sets pickup and destination and taps the request-ride action
- Then no trip request is created
- And she is shown the account-under-review screen

**Scenario 2 — Screen explains the status without accusing**
- Given the account-under-review screen is displayed
- Then it shows the account status as "Pending review"
- And it states that a report relating to the women-only policy is being reviewed by the safety team
- And it does not state that a violation has been established

**Scenario 3 — Report reference and date are shown**
- Given the account-under-review screen is displayed
- Then it shows the report reference and the date the report was raised

**Scenario 4 — No fare was charged**
- Given the trip was cancelled by the gender-mismatch report
- Then the screen confirms that no fare was charged for the cancelled trip

**Scenario 5 — Routes out of the screen**
- Given the account-under-review screen is displayed
- Then the rider can contact support
- And she can sign out

**Scenario 6 — Access is restored on dismissal**
- Given the super admin dismisses the report (#1811) and the account returns to active
- When the rider next requests a ride
- Then the request proceeds normally and the account-under-review screen is not shown

**Scenario 7 — Suspension is distinguished from review**
- Given the super admin upholds the report and suspends the account (#1811)
- When the rider opens the app
- Then she is shown the suspended state rather than the pending-review state

### Out of Scope
- Appealing or disputing the report in-app
- In-app chat with the safety team
- Showing the reporting driver's identity or statement to the rider
- The generic account-suspension screen for non-gender-mismatch suspensions

### Dependencies
- #1687 — Rider account is placed under review after a gender mismatch report (API — must be live)
- #1588 — Driver verifies rider is female on first trip (raises the report)
- #1811 — Super admin actions a gender-mismatch report (clears or upholds it)
- #1629 — Rider creates trip request (the call that is refused)

---

## [Mobile] #1791 — Rider cannot book outside operating hours 🆕
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** Phase 1

**Description:** As a rider, I want to see when SheDrive is closed for the day so that I understand why I cannot book and when I can.

### Background

SheDrive runs daytime-only in Phase 1 (open decision OD-001). Outside the operating window, the home screen shows a clear service-closed state, disables Request Ride, and shows the next opening time. Any request attempted outside hours is rejected by #1785. A trip already in progress is not affected. All strings flow through data-i18n keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Inside operating hours**
- Given the current time is within the operating window
- When the rider opens the home screen
- Then booking is available as normal

**Scenario 2 — Outside operating hours**
- Given the current time is outside the operating window
- When the rider opens the home screen
- Then a bilingual service-closed state is shown with the next opening time
- And Request Ride is disabled

**Scenario 3 — Request attempted outside hours is rejected**
- Given the rider somehow submits a request outside hours
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
- #1633 — Rider tracks her active trip (must be live; drives this screen's state)
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
- #1633 — Rider tracks her active trip (must be live; drives this screen's state)
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
- #3058 — Completed-trip fare is served to rider and driver (must be live)
- #3058 — Completed-trip fare and summary are served to the rider (must be live)

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

## [Mobile] #3999 — Rider sees the recovered fee on her fare summary 🆕
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** Phase 1

**Description:** As a rider whose outstanding fee was recovered on this trip, I want to see it as its own line on my fare summary, both right after the trip and later in my trip history, so that I can see clearly what I paid and why.

### Background

When a rider's outstanding fee is recovered on a trip (#3995 shows it to her before she confirms; the platform posts the recovery when the trip completes, #4000), the fare summary screen (#1564) gains an explicit "recovered fee" line above the total — for example: fare 100.00 EGP, recovered fee 20.00 EGP, total 120.00 EGP. The total shown is what she actually paid the driver in cash, matching what she was told before she confirmed the ride (#3995). The same recovered-fee line appears later whenever she opens that trip's detail in her trip history (#1568), so the record does not quietly change once she has already paid it.

When no fee was recovered on a trip, the fare summary and trip detail look exactly as they do today — no empty or zero recovered-fee row is shown.

All strings — the recovered-fee line label and its explanation — flow through `data-i18n` keys with Arabic fallback text in the HTML.

### Acceptance Criteria

**Scenario 1 — Recovered fee shown on the fare summary**
- Given a trip completes with a fare of 100.00 EGP and a 20.00 EGP outstanding fee is recovered on it
- When the rider views the trip summary screen
- Then a "recovered fee" line of 20.00 EGP is shown above the total
- And the total shown is 120.00 EGP, the amount she actually paid

**Scenario 2 — No recovered fee, summary is unchanged**
- Given a trip completes with no outstanding fee recovered
- When the rider views the trip summary screen
- Then no recovered-fee line is shown
- And the total equals the fare, as today

**Scenario 3 — Recovered fee persists in trip history**
- Given a past trip had a recovered fee
- When the rider opens that trip's detail screen (#1568) later
- Then the same recovered-fee line and total are shown

**Scenario 4 — Recovered fee amount matches what was shown before the ride**
- Given the rider saw a 20.00 EGP fee added before she requested the ride (#3995)
- When the trip completes
- Then the recovered-fee line on the summary shows the same 20.00 EGP

**Scenario 5 — Only one fee is recovered per trip**
- Given the rider had more than one outstanding fee before this trip
- When the trip completes
- Then only the oldest fee is shown as recovered on this summary
- And any remaining fees stay outstanding for a later trip

### Out of Scope
- Itemising the recovered fee further (it is shown as a single line, not broken down)
- Receipts or invoices as PDFs
- Disputing the recovered fee from this screen (Phase 2)

### Dependencies
- `#4000` — Rider outstanding fee is recovered on her next trip (API — must be live)
- #1564 — Rider sees trip summary with cash fare (extended by this story)
- #1568 — Rider views past trip detail and rates unrated trips (extended by this story)

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
- #1639 — Rider submits driver rating (rating submission endpoint)

---

## [Mobile] #1724 — Rider views and edits her profile 🆕
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 2

**Description:** As a rider, I want to view and edit my profile information so that my registered details are accurate and current.

### Background

The rider profile screen is accessible from the app's drawer menu. It displays the rider's registered full name, phone number (display only — cannot be changed in this sprint), and current language preference. The rider can edit her full name by tapping the name field. Changes are saved via #1721. The phone number field is visually styled as read-only.

### Field Validation

| Field | Required | Format | Min | Max | Error — empty | Error — invalid |
|---|---|---|---|---|---|---|
| Full name | Yes | Letters and spaces only (Arabic or Latin) | 2 chars | 60 chars | الاسم مطلوب / Name is required | الاسم يحتوي على أحرف غير صالحة / Name contains invalid characters |

### Acceptance Criteria

**Scenario 1 — Rider views her profile**
- Given an authenticated rider opens the profile screen
- Then her registered full name is displayed
- And her phone number is displayed in a read-only field
- And her current language preference is shown

**Scenario 2 — Rider edits and saves her name successfully**
- Given the rider taps the name field to edit it
- And she enters a valid new name
- When she taps “Save”
- Then the profile is updated via #1721
- And a success toast is shown: “تم حفظ التغييرات” / “Changes saved”
- And the profile screen reflects the updated name

**Scenario 3 — Name field validation fails**
- Given the rider clears the name field or enters invalid characters
- When she taps “Save”
- Then the inline validation error is shown
- And the save request is not sent

**Scenario 4 — Phone number field is read-only**
- Given the rider views her profile
- When she taps the phone number field
- Then the field does not enter edit mode
- And a note indicates: رقم الهاتف لا يمكن تغييره / Phone number cannot be changed

**Scenario 5 — Network error during save**
- Given the rider taps “Save”
- When the network request fails
- Then a toast message is shown: “فشل الحفظ. حاول مجدداً” / “Save failed. Please try again.”
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

**Description:** As a rider, I want to change my app language from my profile screen so that I can use the app in my preferred language.

### Background

The language preference toggle is available on the rider profile screen. The rider can switch between Arabic (default, RTL) and English (LTR). When she switches, the UI updates immediately without requiring a restart. The new preference is persisted via #1728. If the preference cannot be saved to the server due to connectivity loss, it is saved locally and synced when connectivity is restored.

### Acceptance Criteria

**Scenario 1 — Rider switches from Arabic to English**
- Given the rider is using the app in Arabic
- When she selects English on the language toggle on the profile screen
- Then the UI language switches with app restart
- And the layout direction changes from RTL to LTR
- And the preference is saved via #1728

**Scenario 2 — Rider switches from English to Arabic**
- Given the rider is using the app in English
- When she selects Arabic on the language toggle
- Then the UI language switches to Arabic with app restart
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

### Out of Scope
- Languages other than Arabic and English
- Per-notification language settings

### Dependencies
- #1728 — User language preference is stored and retrieved (API — must be live)

---

### Feature 20 — Trip Cancellation (Rider)

---

## [Mobile] #1719 — Rider cancels a trip 🆕
**Feature:** Feature 20 — Trip Cancellation | **Sprint:** 2

**Description:** As a rider, I want to cancel my trip at any point before the driver starts the journey so that I am not charged when my plans change.

### Background

The rider can cancel at two points in the trip lifecycle: (1) while the trip is in searching state on the matching screen — no driver has been assigned yet — in which case no cancellation fee is charged; (2) after a driver has been matched and is en_route_pickup, again with no fee if the driver took less than 3 minutes in route if more fees is applied; (3) if the driver has already arrived (arrived_pickup state), a cancellation fee applies to discourage late cancellations. Once the driver starts the trip (trip_started), cancellation is no longer available to the rider. On successful cancellation the rider is returned to the home screen with her pickup and destination fields still populated, and the assigned driver (if any) is notified via #1715.

### Acceptance Criteria

**Scenario 1 — Rider cancels while searching (no driver assigned, no fee)**
- Given the rider has submitted a trip request and is on the matching screen in searching state
- When the rider taps “Cancel” and confirms in the confirmation dialog
- Then the trip is cancelled with no fee
- And the rider is navigated to the home screen with her pickup and destination still populated with the fare estimate recalculated

**Scenario 2 — Rider cancels after match, driver en route **
- Given a driver has been matched and the trip is in en_route_pickup state
- When the rider taps “Cancel” and confirms
- Then the trip is cancelled with no fee if the driver took less than 3 minutes in route if more fees is applied;
- And the driver receives a push notification informing her the trip was cancelled
- And the rider is navigated to the home screen

**Scenario 3 — Rider cancels after driver arrives (cancellation fee applies)**
- Given the trip is in arrived_pickup state
- When the rider taps “Cancel”
- Then a confirmation dialog is shown informing the rider that a cancellation fee applies
- When the rider confirms
- Then the trip is cancelled and the cancellation fee is recorded against the rider’s account
- And the driver receives a push notification
- And the rider is navigated to the home screen

**Scenario 4 — Rider dismisses the cancellation dialog**
- Given the rider taps “Cancel” at any stage
- When the confirmation dialog appears and the rider taps “Go Back”
- Then the dialog is dismissed and the rider remains on the current screen
- And the trip is not cancelled

**Scenario 5 — Cancel button is not shown after trip starts**
- Given the trip is in trip_started state
- Then no cancel button is shown on the active trip screen

**Scenario 6 — Network error during cancellation**
- Given the rider confirms cancellation
- When the network request fails
- Then a toast message is shown: “Unable to cancel. Please try again.”
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

## [Mobile] #1787 — Rider sets up emergency contacts who receive a live location link on SOS 🆕
**Feature:** Feature 21 — Emergency & Safety (Rider) | **Sprint:** 2

**Description:** As a rider, I want to save emergency contacts and have them alerted with a live link to my location when I trigger SOS during a trip, so that the people I trust can follow my location in real time during an emergency.

### Background

Phase 1 SOS is limited to personal emergency contacts and sharing the rider's live location with those contacts. There is no control room and no operations team. Public emergency numbers (Police 122, Ambulance 123) are shown for direct dialling. Contacts are managed from the Emergency Contacts screen (reached from the side menu) and are alerted automatically when the rider triggers SOS on the active-trip screen.

### Acceptance Criteria

**Scenario 1 — She adds an emergency contact**
- Given the rider is on the emergency contacts screen
- When she enters a name, a phone number and a relationship and saves
- Then the contact is added to her list
- And it is still there the next time she opens the app

**Scenario 2 — She edits a saved contact**
- Given she has at least one saved emergency contact
- When she opens that contact, changes any of its details and saves
- Then the updated details replace the previous ones

**Scenario 3 — She removes a contact**
- Given she has at least one saved emergency contact
- When she removes it and confirms
- Then it no longer appears in her list
- And it is no longer alerted when she raises SOS

**Scenario 4 — The list is capped at five contacts**
- Given she has 5 saved emergency contacts
- When she looks at the emergency contacts screen
- Then the add control is unavailable
- And she is told she has reached the maximum of 5 and must remove one before adding another

**Scenario 5 — Removing at the maximum frees a slot**
- Given she has 5 saved emergency contacts
- When she removes one of them
- Then the add control becomes available again

**Scenario 6 — Empty state guides her to add someone**
- Given she has no saved emergency contacts
- When she opens the emergency contacts screen
- Then an empty state is shown guiding her to add someone she trusts

**Scenario 7 — Every contact is alerted on SOS**
- Given she has at least one saved emergency contact
- When she triggers SOS during an active trip
- Then every saved contact is alerted
- And each of them receives a live link to her current location

**Scenario 8 — The confirmation states what was done**
- Given she has confirmed an SOS
- When the emergency screen opens
- Then it states that her contacts have been notified and that her live location is being shared with them

**Scenario 9 — SOS with no contacts saved**
- Given she has no saved emergency contacts
- When she triggers SOS during an active trip
- Then she is prompted to add emergency contacts
- And Police (122) and Ambulance (123) remain available to dial directly

### Out of Scope
- Control-room / operations-team escalation (post-Phase 1)
- Live in-vehicle camera and third-party monitoring (post-Phase 1)

### Dependencies
- #1780 — Rider's emergency contacts are notified with a live location link on SOS (API — must be live)
- #3968 — Rider raises SOS and reaches the emergency screen (shows these contacts and their delivery status)

---

## [Mobile] #3968 — Rider raises SOS and reaches the emergency screen 🆕
**Feature:** Feature 21 — Emergency & Safety (Rider) | **Sprint:** 2

**Description:** As a rider on an active trip, I want to raise SOS and be taken straight to a full emergency screen that confirms my contacts were alerted and my location is being shared, so that I can get help quickly without alerting the driver I am riding with.

### Background

SOS is reachable only from an active trip. Tapping SOS opens a single confirmation step to guard against an accidental or pocket press; confirming raises the alert and opens a full-screen emergency dashboard. Raising SOS is silent to the driver — she is never told, because if the driver herself is the threat, alerting her escalates the danger. The trip itself is not affected: it keeps running, and settles and is rated exactly as it would without an SOS. No account is suspended automatically; that decision is made later by an admin.

### Acceptance Criteria

**Scenario 1 — SOS is reachable for the whole active trip**
- Given the rider is on an active trip
- When she is at any stage from the driver heading to pickup, through waiting at pickup, to drop-off
- Then the SOS control remains visible and available

**Scenario 2 — SOS cannot be raised outside an active trip**
- Given the rider is not currently on an active trip
- When she opens the app
- Then no SOS control is available to her

**Scenario 3 — A single confirmation guards against accidental presses**
- Given the rider taps SOS
- When the confirmation step appears
- Then the alert is raised only if she explicitly confirms; dismissing it raises nothing

**Scenario 4 — The emergency screen confirms contacts notified and location shared**
- Given the rider taps SOS
- When she confirms it
- Then she is taken to a full-screen emergency dashboard
- And the screen states that her emergency contacts have been notified and that her live location is being shared

**Scenario 5 — Per-contact delivery status is shown**
- Given the emergency screen is open
- When she looks at her emergency contacts on it
- Then each contact is listed with its own delivery status of sent, delivered or failed
- And this replaces any single, unconditional "your contacts have been notified" message, which reassures her even when delivery in fact failed

**Scenario 6 — Police and Ambulance are one tap away**
- Given the emergency screen is open
- When she needs to reach the public emergency services
- Then tap-to-call buttons are offered for Police (122) and Ambulance (123) only
- And no fire brigade number is offered

**Scenario 7 — Trip recap on the emergency screen**
- Given the emergency screen is open
- When she looks at the trip recap
- Then it shows the driver's name, the vehicle and its plate, and her current coordinates

**Scenario 8 — Stop sharing revokes the live link immediately**
- Given the emergency screen is open and the live location link is active
- When the rider chooses to stop sharing
- Then the live location link is revoked immediately and no longer shows her location to anyone who opens it

**Scenario 9 — Return to trip leaves the alert active**
- Given the emergency screen is open
- When the rider chooses to return to the trip
- Then she is taken back to the active-trip screen and the alert stays active — contacts stay notified and the live link stays live — until she stops sharing or stands the alert down

**Scenario 10 — False alarm stands the alert down**
- Given the emergency screen is open
- When the rider cancels the alert and confirms it was a false alarm
- Then location sharing stops immediately
- And the incident is recorded as stood down by her as a false alarm
- And the case stays open for an admin to review and close

**Scenario 11 — The driver is never notified**
- Given the rider is on an active trip
- When she raises SOS
- Then the driver receives no notification, indication or visible change on her own screen as a result

**Scenario 12 — The trip is not interrupted**
- Given the rider is on an active trip
- When she raises SOS
- Then the trip continues unaffected, and later settles and is rated exactly as a trip without an SOS would be

**Scenario 13 — No automatic suspension**
- Given the rider is on an active trip
- When she raises SOS
- Then neither her account nor the driver's is suspended automatically as a result

### Out of Scope
- Notifying the driver that SOS was raised (deliberate — see Background)
- Control room or staffed operations desk (post-Phase 1)
- Fire brigade as a third emergency number
- Raising SOS outside an active trip
- Automatic account suspension on any pattern
- Admin review and case actions — see #3945 and #3946

### Dependencies
- #3970 — SOS incident is recorded with a full trip snapshot (API — must be live)
- #3971 — Live location link is issued, scoped, and expires (API — must be live)
- #1787 — the rider's emergency contacts must exist to be alerted

---

### Feature 22 — Payments & Outstanding Fees (Rider)

---

## [Mobile] #3992 — Rider views her payment method and outstanding fees 🆕
**Feature:** Feature 22 — Payments & Outstanding Fees (Rider) | **Sprint:** Phase 1

**Description:** As a rider, I want to see my active payment method and any outstanding fees I owe so that I understand how I pay for rides and know exactly what will be added to my next trip.

### Background

Riders pay in cash. This story rewrites the payments screen, which today is a coming-soon stub, into a working one. It shows "Cash" as her payment method — the only one — and states plainly that rides are paid to the driver in cash at the end of the trip.

Below the payment method, an outstanding-fees section lists every fee she currently owes: the amount, which trip it came from, and the date it was charged. Each fee carries the line "This will be added to your next ride" — it is not charged immediately, because there is no way to collect from her between rides; instead it rides as a surcharge on a future trip, collected by the driver in cash (#3995). Tapping a fee opens its detail: the trip date and addresses, the reason the fee was charged, and the amount. When she owes nothing, a zero state confirms she has no outstanding fees.

This is the first time a rider is shown a debt she did not immediately pay off. The copy has to carry that weight: it states plainly that the fee is not being charged right now and names exactly when it will be — her next ride — rather than leaving an amount sitting against her name with no explanation of how or when it is settled.

All strings — the payment-method label, the fee list items, the zero state, and the fee-detail screen — flow through `data-i18n` keys with Arabic fallback text in the HTML.

### Acceptance Criteria

**Scenario 1 — Cash shown as the payment method**
- Given the rider opens the payments screen
- Then "Cash" is shown as her payment method
- And the screen states that she pays the driver in cash at the end of the ride

**Scenario 2 — Outstanding fees are listed with trip, date, and amount**
- Given the rider has an outstanding fee of 20.00 EGP from a trip she cancelled late on 5 September
- When she views the outstanding-fees section
- Then the fee shows its amount, the trip it came from, and the date it was charged
- And it shows the line "This will be added to your next ride"

**Scenario 3 — Fee detail**
- Given the rider taps an outstanding fee
- Then a detail view shows the trip date and addresses, the reason the fee was charged, and the amount

**Scenario 4 — Zero state when nothing is owed**
- Given the rider has no outstanding fees
- When she opens the payments screen
- Then the outstanding-fees section shows a zero state confirming she owes nothing
- And no fee rows are rendered

**Scenario 5 — Multiple outstanding fees are ordered oldest first**
- Given the rider has more than one outstanding fee
- When she views the list
- Then the fees are ordered oldest first, matching the order in which they will be recovered (#3995)

**Scenario 6 — Network error loading fees**
- Given the payments screen cannot reach the platform for her outstanding-fee status
- When the screen loads
- Then a retry option is shown in place of the outstanding-fees section
- And her payment method (Cash) still displays normally

### Out of Scope
- Paying an outstanding fee directly from this screen
- Disputing a fee (Phase 2)
- Receipts or invoices as PDFs

### Dependencies
- `#4004` — Rider retrieves her outstanding fees and statement (API — must be live)

---

