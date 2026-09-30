# SheDrive — Mobile Rider Stories
> Canonical backlog for all [Mobile] Rider stories. Organized by sprint and feature.
> Last updated: 2026-09-30
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

## [Mobile] #5038 — Rider deletes her account 🆕
**Feature:** Feature 2 — Rider Authentication (#1532) | **Sprint:** Backlog (not scheduled)

**Description:** As a rider, I want to delete my SheDrive account from inside the app, so that I can leave SheDrive and have my personal data removed without having to contact anyone.

### Background

The App Store and Google Play both refuse an app that lets people sign up without letting them delete their account from inside the app, so this story must ship before the rider app is submitted.

She opens the Delete Account screen from a **Delete account** link at the bottom of her profile, under Log out (#1724). The screen is one short confirmation, not a list: her account closes at once and is deleted after 30 days, she can get it back by signing in before then, and **her number can never sign up again**. She re-confirms her phone number with a one-time code, and the request is made (#5036). She is signed out at once. If she signs in again within 30 days she is offered her account back; after that the deletion is final.

**A trip in progress blocks the request; an outstanding fee does not.** A fee can only be paid by taking a ride, so it is shown as information and never stands in her way. An account under review or suspended does not block it either: she still signs in (only a ride request is refused), so she deletes like anyone else.

All strings flow through `data-i18n` keys with Arabic fallback text in the HTML, and every step lays out correctly in LTR and RTL.

### Screen layout

| Step | Shows | Behaviour |
|---|---|---|
| Review | Title, one sentence on the 30-day window, an amber warning that she can't sign up again with this number, and a one-line note that trip, payment and safety records are kept only as long as the law requires | Continue opens Confirm it's you. Keep my account goes back |
| Outstanding-fee note | A blue note on Review with the amount, saying it doesn't stop her deleting | Information only — never disables Continue |
| Blocked — trip in progress | Finish your trip first, with Back to my trip | Replaces Review. Nothing is requested |
| Confirm it's you | Six-box code input, the masked number, resend with countdown | Delete my account submits the code. Keep my account goes back |
| Request received | The exact deletion date and that signing in before it keeps the account | Done opens the sign-in screen. She is already signed out |
| Restore at sign-in | After the sign-in code: the deletion date, Restore my account, Continue with deletion | Restore continues exactly as a normal sign-in would; Continue with deletion leaves her signed out |

### Field Validation

| Field | Required | Format | Min | Max | Error — empty | Error — invalid |
|---|---|---|---|---|---|---|
| Deletion code | Yes | 6 digits | 6 | 6 | أدخلي الأرقام الستة للرمز / Enter all 6 digits of the code | Same messages as sign-in (#1546) |

### Acceptance Criteria

**Scenario 1 — Rider opens Delete Account from her profile**
- Given an authenticated rider on her profile
- When she taps Delete account under Log out
- Then the Review step opens

**Scenario 2 — Review is one short confirmation**
- Given the Review step is open
- Then it says her account closes straight away and is deleted after 30 days, unless she signs in before then
- And an amber warning says she won't be able to sign up again with this number
- And one line says trip, payment and safety records are kept only as long as the law requires
- And Continue is enabled straight away; there is no list, no reason to choose and no checkbox

**Scenario 3 — A trip in progress blocks the request**
- Given the rider has a trip that is not yet completed or cancelled, including a request still searching for a driver
- When she opens Delete Account
- Then Finish your trip first is shown instead of Review, with Back to my trip
- And no code is requested

**Scenario 4 — An outstanding fee is shown but does not block**
- Given the rider owes a 25 EGP cancellation fee
- When she opens Delete Account
- Then a blue note shows the 25 EGP and says it doesn't stop her deleting her account
- And she can continue exactly as a rider with no fee

**Scenario 5 — She confirms it is her**
- Given she taps Continue on Review
- Then a code is sent to her registered number (#5036) and Confirm it's you shows the masked number
- And resend is available after the same countdown as sign-in

**Scenario 6 — Wrong, expired or incomplete code**
- Given the Confirm it's you step is open
- When she submits fewer than six digits, a wrong code or an expired code
- Then the matching message is shown under the code and nothing is deleted
- And after the last allowed attempt she must resend a code

**Scenario 7 — The request is received and she is signed out**
- Given she submits the correct code
- Then Request received shows the exact date her account will be deleted
- And says she can sign in before that date to keep it
- And she is signed out on this phone and every other device
- And Done opens the sign-in screen

**Scenario 8 — She changes her mind before confirming**
- Given she is on Review or Confirm it's you
- When she taps Keep my account or the back arrow
- Then she returns to her profile and nothing about her account has changed

**Scenario 9 — Signing in during the window offers her account back**
- Given her account is waiting to be deleted
- When she signs in with her number and code (#1546)
- Then instead of the home screen she sees that the account is due to be deleted on its date, with Restore my account and Continue with deletion
- And the new-rider name step is never shown for this number

**Scenario 10 — Restoring brings everything back**
- Given the restore step is shown
- When she taps Restore my account
- Then she goes wherever a normal sign-in would take her: the home screen
- And her account keeps its current status, so a rider under review or suspended still sees the account-under-review message when she requests a ride
- And her profile, saved places, emergency contacts and trip history are all as they were

**Scenario 11 — Continuing with the deletion changes nothing**
- Given the restore step is shown
- When she taps Continue with deletion
- Then she stays signed out and the deletion keeps its date

**Scenario 12 — A deleted number can't sign up again**
- Given her deletion has completed
- When the same number enters a correct sign-in code
- Then she stays on the phone step with "This number belonged to a deleted SheDrive account and can't be used to sign up again"
- And the new-rider name step is not shown and no account is created

**Scenario 13 — Network error while requesting**
- Given the app cannot reach the platform
- When she asks for a code or submits one
- Then an error toast is shown, she stays on the same step, and nothing about her account changes

**Scenario 14 — Arabic and English**
- Given the rider switches language
- Then every label, note, button and error on every step, including the deletion date, is shown in the selected language
- And the screens lay out correctly in RTL

**Scenario 15 — A rider under review or suspended can still delete**
- Given her account is under review (#1687) or suspended (#1740)
- When she taps Delete account on her profile
- Then the Review step opens and she can delete exactly as any other rider

### Out of Scope
- A public web page for people without the app — removed from scope
- Downloading a copy of her data
- Deleting an account from the sign-in screen without signing in
- Paying an outstanding fee before deleting — a fee never blocks

### Dependencies
- #5036 — Rider account deletion is requested, restored and completed (API — must be live)
- #1724 — Rider views and manages her profile (the Delete account link)
- #1546 — Rider logs in (the restore step follows its code step)
- #3995 — Rider sees an outstanding fee before she requests a ride (the same fee, shown here as information)
- #5014 — [Rider] Delete Account (design)

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

---

## [Mobile] #1549 — Rider searches address with autocomplete ✏️
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 2

**Description:** As a rider, I want a full-screen search that shows my saved places and recent places and suggests addresses as I type, so that I can find my pickup or destination quickly without typing the full address.

### Background

Tapping the pickup or the destination field on the home screen (#1548) opens a full-screen search screen for that field. It replaces the home screen until she picks a place or goes back. The search field is focused with the keyboard open, and the title names the field she is choosing — pickup or destination.

Before she types, the screen offers two shortcuts. Saved Places shows her saved places — Home and Work first, then her other places — with View All opening the Saved Places screen in her profile (#1724). Recent Places lists the last five addresses she picked on this device, newest first, each with its name, its address, and its distance and driving time from where she is now.

Once she has typed two characters, address suggestions from the maps provider replace both shortcuts: up to five, biased to Cairo and Giza. Picking a saved place, a recent place or a suggestion fills the field and returns her to the home screen; what happens next belongs to #1550 (pickup) and #1551 (destination). The pickup-only “Use my current location” and the “Pick on map” actions on this screen are owned by those two stories as well.

Saved places are read-only here — adding, editing and deleting them is the Saved Places screen in her profile (#1724, delivered in Sprint 1). All strings are available in Arabic and English, and the screen lays out correctly in RTL and LTR.

### Screen layout

| Section | Shows | Behaviour |
|---|---|---|
| Header | Back arrow and a title naming the field being chosen | Back returns to the home screen with the field unchanged |
| Search field | Pickup or Destination, focused, keyboard open | Typing two or more characters shows suggestions |
| Saved Places | Home and Work first, then her other places, each with its name and address; View All | Tapping a place fills the field. View All opens the Saved Places screen (#1724). Left out when she has none or they cannot be loaded |
| Recent Places | Up to five places she picked on this device, newest first: name, address, distance and driving time | Tapping one fills the field. Left out when she has none |
| Suggestions | Up to five addresses, Cairo and Giza first | Replace Saved and Recent while she types; tapping one fills the field |
| No results / error | A short message, with Retry for the error | Saved and Recent return when the search text is cleared |

### Field Validation

| Field | Required | Format | Min | Max | Accepted | Error message |
|---|---|---|---|---|---|---|
| Search text | No | Free text | 2 characters to show suggestions | 200 characters | Arabic and Latin text | — (below 2 characters, Saved and Recent are shown) |

### Acceptance Criteria

**Scenario 1 — Tapping a field opens the full-screen search**
- Given the rider is on the home screen
- When she taps the pickup or the destination field
- Then the full-screen search opens for that field, with the search field focused and the keyboard open
- And the title names the field she is choosing

**Scenario 2 — Saved places are offered before she types**
- Given a rider with Home, Work and one other saved place
- When the search screen opens
- Then the Saved Places section shows Home and Work first, then the other place, each with its name and address

**Scenario 3 — Tapping a saved place fills the field**
- Given the Saved Places section is shown
- When she taps Work
- Then the field is set to her Work address and she is returned to the home screen

**Scenario 4 — View All opens her saved places**
- Given the Saved Places section is shown
- When she taps View All
- Then the Saved Places screen in her profile opens (#1724)

**Scenario 5 — No saved places, or they cannot be loaded**
- Given the rider has no saved places, or they fail to load
- When the search screen opens
- Then the Saved Places section is left out and the rest of the screen works as usual

**Scenario 6 — Recent places are offered before she types**
- Given the rider has picked places before on this device
- When the search screen opens
- Then up to five of them are listed under Recent Places, newest first
- And each shows its name, its address, and its distance and driving time from her current location
- And when her location is unavailable, the distance and time are left out

**Scenario 7 — A new rider sees no recent places**
- Given the rider has never picked a place on this device
- When the search screen opens
- Then the Recent Places section is left out

**Scenario 8 — Suggestions appear after two characters**
- Given the search screen is open
- When she types two or more characters
- Then up to five address suggestions replace the Saved and Recent sections, Cairo and Giza results first
- And the suggestions update as she keeps typing

**Scenario 9 — Fewer than two characters**
- Given she has typed one character or cleared the field
- Then no suggestions are shown and the Saved and Recent sections are shown again

**Scenario 10 — Picking a suggestion**
- Given suggestions are shown
- When she taps one
- Then the field is set to that address and she is returned to the home screen
- And the address becomes the newest of her recent places

**Scenario 11 — No results**
- Given she has typed two or more characters
- When the search finds nothing
- Then “لم نجد أماكن تطابق بحثك” / “No places match your search” is shown in place of the suggestions

**Scenario 12 — Search fails**
- Given she has typed two or more characters
- When the search request fails
- Then “تعذّر البحث. تحقق من اتصالك وحاول مجدداً” / “Search failed. Check your connection and try again.” is shown with a Retry action
- And Retry repeats the search for what she has typed

**Scenario 13 — Going back changes nothing**
- Given the search screen is open
- When she taps the back arrow without picking a place
- Then she returns to the home screen and the field keeps its previous value

**Scenario 14 — Arabic and English**
- Given the rider switches language
- Then every title, section heading, message and action on the search screen is shown in the selected language
- And the screen lays out correctly in RTL and LTR

### Out of Scope

- Adding, editing or deleting saved places — the Saved Places screen in her profile (#1724)
- Saving a place from the search or the booking screen
- Clearing or editing the recent places list
- Suggesting places from her trip history
- Addresses outside Egypt

### Dependencies

- #1548 — Rider sees home screen with map (the fields that open this screen)
- #1550 — Rider sets pickup point (what happens after a pickup is picked; “Use my current location” and “Pick on map”)
- #1551 — Rider sets destination (what happens after a destination is picked; “Pick on map”)
- #1724 — Rider views and manages her profile (the Saved Places screen View All opens)
- #4475 — Rider profile is served in one call and its editable parts are saved (API — supplies her saved places)
- Address suggestions come from the maps provider directly; there is no SheDrive API for search
- #4779 — [Rider] Restructure Pickup & Destination search (design)

---

## [Mobile] #1550 — Rider sets pickup point ✏️
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 2

**Description:** As a rider, I want to set my pickup from a search result, a saved or recent place, my current location, or a pin on the map, so that the driver knows exactly where to pick me up.

### Background

When location permission is granted, the pickup field on the home screen starts at her current location (#1548). To change it, she taps the pickup field, which opens the full-screen search for pickup (#1549).

On that screen she can set her pickup five ways: a suggestion, a saved place or a recent place (all from #1549), “Use my current location”, or “Pick on map”. Pick on map opens a full-screen map with a pin fixed in the centre; she moves the map under the pin, the address under the pin is shown, and she confirms or cancels.

Whichever way she chooses, she returns to the home screen with the pickup field showing the address and a pickup marker on the map. If a destination is already set, the fare estimate is recalculated (#1552). Whether the pickup is inside the service area is checked by the fare estimate (#1552), not here.

All strings are available in Arabic and English, and every step lays out correctly in RTL and LTR.

### Field Validation

| Field | Required | Format | Min | Max | Accepted | Error message |
|---|---|---|---|---|---|---|
| Pickup location | Yes (before the fare estimate or a ride request) | Address and coordinates | — | — | — | “اختاري موقع الانطلاق” / “Choose a pickup point” |

### Acceptance Criteria

**Scenario 1 — Tapping pickup opens the search for pickup**
- Given the rider is on the home screen
- When she taps the pickup field
- Then the full-screen search opens for pickup (#1549)
- And “Use my current location” and “Pick on map” are offered

**Scenario 2 — Pickup set from a suggestion, a saved place or a recent place**
- Given the search screen for pickup is open
- When she picks a suggestion, a saved place or a recent place
- Then she returns to the home screen with the pickup field showing that address
- And a pickup marker is shown on the map at that location

**Scenario 3 — Pickup set from her current location**
- Given location permission is granted
- When she taps “Use my current location”
- Then her pickup is set to her current location, shown as its address, and she returns to the home screen

**Scenario 4 — Location permission not granted**
- Given location permission has not been granted
- When she taps “Use my current location”
- Then the system permission prompt is shown
- And if she refuses, “فعّلي خدمة الموقع لاستخدام موقعك الحالي” / “Turn on location to use your current location” is shown and she stays on the search screen to choose another way

**Scenario 5 — Her location cannot be found**
- Given location permission is granted but her position cannot be determined
- When she taps “Use my current location”
- Then “تعذّر تحديد موقعك. ابحثي عن العنوان أو اختاريه على الخريطة” / “We couldn’t find your location. Search for the address or pick it on the map.” is shown
- And her pickup is unchanged

**Scenario 6 — Pickup set on the map**
- Given the search screen for pickup is open
- When she taps “Pick on map”, moves the map so the pin sits on her pickup and confirms
- Then her pickup is set to the pin’s location, shown as its address, and she returns to the home screen
- And tapping cancel instead returns her to the search screen with the pickup unchanged

**Scenario 7 — Changing the pickup**
- Given a pickup and a destination are set and a fare estimate is shown
- When she sets a different pickup
- Then the pickup field and marker update
- And the fare estimate is recalculated (#1552)

**Scenario 8 — Going back changes nothing**
- Given the search screen for pickup is open
- When she goes back without picking a place
- Then her pickup is unchanged

**Scenario 9 — Arabic and English**
- Given the rider switches language
- Then the pickup field, the map picker and every message are shown in the selected language, laid out correctly in RTL and LTR

### Out of Scope

- The service-area check — done by the fare estimate (#1552)
- Saving the pickup as a saved place
- Notes or instructions for the driver about the pickup
- More than one stop

### Dependencies

- #1548 — Rider sees home screen with map (the pickup field and its default)
- #1549 — Rider searches address with autocomplete (the full-screen search)
- #1552 — Rider sees fare estimate before requesting (recalculated when the pickup changes)
- Current location and the address under the map pin come from the device and the maps provider; there is no SheDrive API
- #4779 — [Rider] Restructure Pickup & Destination search (design)

---

## [Mobile] #1551 — Rider sets destination ✏️
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 2

**Description:** As a rider, I want to set my destination from a search result, a saved or recent place, or a pin on the map, so that the driver and the platform know where I want to go.

### Background

She taps the destination field on the home screen (#1548), which opens the full-screen search for destination (#1549). She can pick a suggestion, a saved place or a recent place, or use “Pick on map”, which works exactly as it does for pickup (#1550). “Use my current location” is not offered for the destination.

She returns to the home screen with the destination field showing the address and a destination marker on the map. The destination must differ from the pickup; the app checks this before asking for a fare. Once both are set, the fare estimate is triggered automatically (#1552).

The swap button between the two fields exchanges the pickup and the destination.

All strings are available in Arabic and English, and every step lays out correctly in RTL and LTR.

### Field Validation

| Field | Required | Format | Min | Max | Accepted | Error message |
|---|---|---|---|---|---|---|
| Destination | Yes (before the fare estimate or a ride request) | Address and coordinates | — | — | Must differ from the pickup | “اختاري وجهتك” / “Choose your destination”; same as pickup: “يرجى اختيار وجهة مختلفة عن موقع الانطلاق” / “Choose a destination different from your pickup” |

### Acceptance Criteria

**Scenario 1 — Tapping destination opens the search for destination**
- Given the rider is on the home screen
- When she taps the destination field
- Then the full-screen search opens for destination (#1549)
- And “Pick on map” is offered, and “Use my current location” is not

**Scenario 2 — Destination set from a suggestion, a saved place or a recent place**
- Given the search screen for destination is open
- When she picks a suggestion, a saved place or a recent place
- Then she returns to the home screen with the destination field showing that address
- And a destination marker is shown on the map
- And if a pickup is set, the fare estimate is triggered (#1552)

**Scenario 3 — Destination set on the map**
- Given the search screen for destination is open
- When she taps “Pick on map”, moves the map so the pin sits on her destination and confirms
- Then her destination is set to the pin’s location, shown as its address, and she returns to the home screen

**Scenario 4 — Destination the same as the pickup**
- Given her pickup is set
- When she picks the same place as her destination
- Then the inline error “يرجى اختيار وجهة مختلفة عن موقع الانطلاق” / “Choose a destination different from your pickup” is shown under the destination
- And no fare estimate is requested and “Request Ride” stays inactive

**Scenario 5 — Swapping pickup and destination**
- Given a pickup and a destination are set
- When she taps the swap button
- Then the pickup and the destination exchange places, and so do their markers
- And the fare estimate is recalculated (#1552)

**Scenario 6 — Changing the destination**
- Given a destination is set and a fare estimate is shown
- When she sets a different destination
- Then the destination field and marker update and the fare estimate is recalculated (#1552)

**Scenario 7 — Going back changes nothing**
- Given the search screen for destination is open
- When she goes back without picking a place
- Then her destination is unchanged

**Scenario 8 — Arabic and English**
- Given the rider switches language
- Then the destination field, the map picker and every message are shown in the selected language, laid out correctly in RTL and LTR

### Out of Scope

- “Use my current location” for the destination
- Saving the destination as a saved place
- More than one stop

### Dependencies

- #1548 — Rider sees home screen with map (the destination field and the swap button)
- #1549 — Rider searches address with autocomplete (the full-screen search)
- #1550 — Rider sets pickup point (“Pick on map” works the same way)
- #1552 — Rider sees fare estimate before requesting (triggered once both are set)
- #4779 — [Rider] Restructure Pickup & Destination search (design)

---

## [Mobile] #1552 — Rider sees fare estimate before requesting ✏️
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 2

**Description:** As a rider, I want to see an estimated fare, trip duration and distance before I request a ride so that I can make an informed decision about booking.

### Background

Once both pickup and destination are set on the home screen (#1548), the app asks the platform for a fare estimate. The Fare Estimate card shows one fare amount in EGP — a single figure, never a range — with the estimated trip duration in minutes and the distance in km. The route between pickup and destination is drawn on the map.

The fare comes from the fare engine (#1628), using the zone of the pickup. The final fare is calculated from the actual trip when it ends (#1636), so it can differ from this estimate.

“Request Ride” becomes active only after a successful estimate. While the estimate is loading, or if it fails, it stays inactive. If she changes either address the estimate is cleared and recalculated. If the pickup is outside every service zone, the platform refuses the estimate (#1629) and she is told the service is not available there.

All strings are available in Arabic and English, and the card lays out correctly in RTL and LTR.

### Acceptance Criteria

**Scenario 1 — Fare, duration and distance are shown**
- Given both pickup and destination are set
- When the fare estimate returns
- Then the Fare Estimate card shows one fare amount in EGP (for example EGP 340.00)
- And the estimated trip duration in minutes and the distance in km are shown
- And “Request Ride” becomes active

**Scenario 2 — The fare is never a range**
- Given a fare estimate is shown
- Then exactly one amount is shown — never a range or a minimum and a maximum

**Scenario 3 — The route is drawn on the map**
- Given a fare estimate is shown
- Then the route from the pickup to the destination is drawn on the map between the two markers

**Scenario 4 — While the estimate is loading**
- Given both pickup and destination have just been set
- While the estimate is being fetched
- Then the card shows a loading state and “Request Ride” stays inactive

**Scenario 5 — The estimate fails**
- Given both pickup and destination are set
- When the fare estimate request fails
- Then “تعذّر حساب الأجرة. حاول مجدداً” / “We couldn’t estimate the fare. Please try again.” is shown with a Retry action
- And “Request Ride” stays inactive
- And Retry requests the estimate again

**Scenario 6 — An address changes**
- Given a fare estimate is shown
- When she changes the pickup or the destination
- Then the estimate is cleared and a new one is requested automatically
- And “Request Ride” is inactive until the new estimate arrives

**Scenario 7 — Pickup outside the service area**
- Given the pickup is outside every service zone
- When the fare estimate is requested
- Then no fare is shown and “الخدمة غير متاحة في موقع الانطلاق هذا بعد” / “SheDrive isn’t available at this pickup yet” is shown
- And “Request Ride” stays inactive

**Scenario 8 — Arabic and English**
- Given the rider switches language
- Then the card’s labels, amount, units and messages are shown in the selected language, laid out correctly in RTL and LTR

### Out of Scope

- A fare range or a minimum and maximum
- Surge pricing
- The fare breakdown (base, per-km, per-minute) — shown after the trip (#1564)
- Choosing a payment method — online card payment is a separate story (#1732), awaiting the payment integration
- The outstanding-fee line — added later by #3995
- The same-as-pickup check — done by the app before the estimate (#1551)

### Dependencies

- #1628 — Fare calculation engine (API — prices the estimate)
- #1629 — Rider creates trip request (API — the service-area guard that refuses an out-of-zone estimate)
- #1548 — Rider sees home screen with map
- #1550 — Rider sets pickup point
- #1551 — Rider sets destination
- The route, duration and distance come from the maps provider’s routing
- #1518 — Rider Home (design)

---

## [Mobile] #3995 — Rider sees an outstanding fee before she requests a ride 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** Phase 1

**Description:** As a rider with an outstanding fee, I want to see that fee as its own amount before I confirm a ride so that I know it is being added to this trip and never discover it hidden inside the fare.

### Background

When a rider has an outstanding balance (financial core design §3) and both pickup and destination are set on the home screen (#1548), her **entire** outstanding balance is shown as its own line, separate from the fare estimate (#1552) — for example: fare estimate 100.00 EGP, outstanding balance 20.00 EGP, next-ride total 120.00 EGP. The amount is never folded silently into the displayed fare estimate; the fare estimate itself is unchanged from what a rider with no outstanding balance would see.

**Her entire outstanding balance is always recovered on this next completed trip, in one payment.** There is no drip, no oldest-fee-first ordering and no threshold — whatever she owes, however many late cancellations it came from, is the single amount shown here.

**The notice is dismissible.** She can dismiss it and still book — there is no booking block of any kind, at any balance. It is informational: she sees the same total again on the fare summary (#3999) before she actually pays, so nothing about this notice gates her ride; it only makes sure the amount is never a surprise.

This is the moment a rider first sees, concretely, that today's ride is paying for something that happened on an earlier one. The copy names the reason plainly — a late cancellation, or more than one — rather than presenting the charge as an unexplained addition to today's fare, so she understands why it is there before she commits to the ride.

All strings — the banner, its amount, its explanation and its dismiss control — flow through `data-i18n` keys with Arabic fallback text in the HTML.

### Acceptance Criteria

**Scenario 1 — Outstanding balance shown as its own amount before confirming**
- Given the rider has an outstanding balance of 20.00 EGP and sets pickup and destination
- When the fare estimate is displayed
- Then the outstanding balance is shown as its own line of 20.00 EGP, separate from the fare estimate
- And the combined total she will pay this trip is also shown

**Scenario 2 — Balance is never folded into the fare estimate silently**
- Given the rider has an outstanding balance
- When she views the fare estimate
- Then the fare estimate itself is unchanged from what a rider with no outstanding balance would see
- And the balance appears only as its own separate, clearly labelled line

**Scenario 3 — Notice names the reason**
- Given the rider has an outstanding balance
- When she views the notice before requesting
- Then it states that the amount is from one or more earlier late cancellations

**Scenario 4 — The whole balance is shown as one amount, not just one fee**
- Given the rider has more than one outstanding fee totalling 65.00 EGP
- When she views the notice before requesting
- Then the full 65.00 EGP is shown as a single amount being added to this trip — never just the oldest fee

**Scenario 5 — Notice is dismissible**
- Given the notice is shown
- When she dismisses it
- Then it disappears for this session and she can still proceed to request a ride

**Scenario 6 — She is never blocked from booking**
- Given the rider has an outstanding balance of any size
- Then the "Request Ride" action is available exactly as it is for any other rider

**Scenario 7 — No outstanding balance**
- Given the rider owes nothing
- When she sets pickup and destination
- Then no notice is shown and the fare estimate is displayed as it is today

**Scenario 8 — Amount persists through to the request**
- Given an outstanding balance is shown before she requests
- When she taps "Request Ride"
- Then the same amount is carried through with the trip request so it can be recovered in full when the trip completes (#4000)

**Scenario 9 — Network error checking her balance**
- Given the app cannot reach the platform to check her outstanding balance
- When the home screen loads
- Then it retries silently and shows the ordinary booking state rather than a wrong amount from a stale read

### Out of Scope
- Paying the balance directly from this screen instead of it being added to the next trip
- Any automatic booking block — abuse is handled by rider suspension (#1740)
- Disputing the balance from this screen (Phase 2)

### Dependencies
- `#4000` — Rider outstanding fee is recovered on her next trip (API — must be live; supplies the full-balance amount)
- #1552 — Rider sees fare estimate before requesting (extended by this story)
- `#3992` — Rider views her payment method (Cash; the balance is not shown there)
- `#3999` — Rider sees the recovered fee on her fare summary (she sees the same total again there before she pays)
- `#1740` — Operations admin suspends a rider account (the only block on a rider, for persistent abuse)

---

> **Removed 2026-09-17 — [Mobile] #3998 (rider is told when her full outstanding balance will be added to her next ride):** the recovery threshold is gone, so there is only one notice. A rider always has her full outstanding balance added to her next trip, and #3995 above now states that amount and is dismissible.

---

> **Removed 2026-09-29 — [Mobile] #4916 (rider manages her saved places) and [Mobile] #4917 (rider books from a saved place and saves a new one while booking):** saved places were delivered in Sprint 1 under #1724 (profile). Using a saved place when choosing a pickup or destination is now part of the full-screen search (#1549, #1550, #1551). Saving a place from the booking screen is not in scope.

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

> **Removed 2026-09-24 — [Mobile] #1791 (rider cannot book outside operating hours):** operating-hours logic is dropped from the Mobile backlog; the app no longer has a service-closed state.

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

When a rider's outstanding balance is recovered on a trip (#3995 shows it to her before she confirms; the platform posts the recovery when the trip completes, #4000), the fare summary screen (#1564) gains an explicit "recovered fee" line above the total — for example: fare 100.00 EGP, recovered fee 20.00 EGP, total 120.00 EGP. The total shown is what she actually paid the driver in cash, matching what she was told before she confirmed the ride (#3995). The same recovered-fee line appears later whenever she opens that trip's detail in her trip history (#1568), so the record does not quietly change once she has already paid it.

When she owed more than one fee before this trip, they are combined and shown as a single recovered-fee line for their total — never itemised fee by fee — because the whole balance is always recovered together, in one payment.

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
- Given the rider saw a 20.00 EGP balance added before she requested the ride (#3995)
- When the trip completes
- Then the recovered-fee line on the summary shows the same 20.00 EGP

**Scenario 5 — Several outstanding fees are shown as one combined amount**
- Given the rider had two outstanding fees, 20.00 EGP and 15.00 EGP, before this trip
- When the trip completes
- Then a single recovered-fee line of 35.00 EGP is shown on this summary
- And no fee remains outstanding afterward

### Out of Scope
- Itemising the recovered fee further (it is shown as a single combined line, not broken down by originating trip)
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

## [Mobile] #1724 — Rider views and manages her profile ♻️
**Feature:** Feature 1 — Rider Authentication (#1532) | **Sprint:** Backlog (not scheduled)

**Description:** As a rider, I want one profile screen that shows who I am on SheDrive — my photo, my name, how many trips I have taken, how I am rated and how long I have been riding — and lets me keep my photo and my saved places up to date, so that my account reflects me and booking a ride to a place I go to often takes one tap.

### Background

The rider profile screen is reached from the app's drawer menu and is the one place she sees her account as a whole. Her header, her stats and her saved places come from a single call (#4475). The emergency contacts count comes from the contacts' own endpoint (#1787), and her language preference is stored on the device, so neither goes through the profile call.

**Two things are editable, the rest are read-only or links.** She can set or change her profile photo, and manage her saved places. Her name, her phone number, her trip count, her rating and her joining date are shown and cannot be edited. Her payment method and her emergency contacts appear as rows that open the screens that own them — this screen never edits either.

**Her photo is optional and decorative.** Unlike the driver photo, which exists for gender verification (#1686), a rider photo is never checked against anything and is visible only to her. Until she sets one, the screen shows a placeholder, and she can remove it at any time and go back to that placeholder.

**Saved places are shortcuts.** At most one Home and one Work, plus custom labels, to a total of ten. Addresses are chosen through the same address search the booking screen already uses (#1548), so anything she saves can be picked as a pickup or a destination.

**A new rider sees an honest empty screen.** No photo, no trips, no rating and no saved places is the normal first state — it reads as a profile waiting to be filled in, not as a broken or zeroed-out one. In particular an unrated rider shows a dash, never 0.0, which would read as the worst possible score.

All strings flow through `data-i18n` keys with Arabic fallback text in the HTML, and the screen lays out correctly in both LTR and RTL.

### Screen layout

| Section | Shows | Behaviour |
|---|---|---|
| Header | Profile photo with the account-status badge, full name, phone number, Edit Profile | Tapping the photo or Edit Profile opens the photo actions — her name and phone are not editable |
| Stats row | Trips, Rating, Since | Read-only. Completed trips, her aggregate rating to one decimal, and the year she joined |
| Account — Payment Method | Cash | Opens the payments screen (#3992). Never shows her outstanding balance here |
| Account — Emergency Contacts | The number of trusted contacts she has saved, read from the contacts endpoint (#1787) | Opens the emergency contacts screen (#1787), which owns them |
| Saved Places | Home and Work first, then her custom places; a Manage action | Tapping one opens it for editing; Manage opens the full list to add, edit and delete |
| Log Out | — | The existing logout flow (#1547), unchanged |

### Field Validation

| Field | Required | Format | Min | Max | Error — empty | Error — invalid |
|---|---|---|---|---|---|---|
| Profile photo | No | JPEG or PNG, from camera or gallery | — | 10 MB | — | اختاري صورة JPEG أو PNG أقل من 10 ميجا / Choose a JPEG or PNG under 10 MB |
| Saved place label | Yes | `Home`, `Work`, or a custom label | 1 char | 30 chars | سمي هذا المكان / Name this place | — |
| Saved place address | Yes | Chosen through the existing address search (#1548) | — | — | اختاري عنوانًا / Choose an address | This address is outside our service area |

### Acceptance Criteria

**Scenario 1 — Rider views her profile**
- Given an authenticated rider with a photo, 128 completed trips, a 4.9 rating, three emergency contacts and two saved places opens the profile screen
- Then her photo, full name and phone number are displayed in the header, with her phone number read-only
- And the stats row shows 128 trips, a 4.9 rating and the year she joined
- And the account section shows Cash as her payment method and a count of 3 emergency contacts
- And her saved places are listed with Home and Work first
- And her current language preference, stored on this device, is shown (#1729)

**Scenario 2 — A brand-new rider sees empty states, not zeros**
- Given a rider who registered today, has taken no trips, has never been rated, has no photo and no saved places
- When she opens the profile screen
- Then the photo placeholder is shown in place of a photo
- And the trips figure reads 0, the rating reads a dash rather than 0.0, and the year she joined is this year
- And the emergency contacts row reads that she has none, and the saved places section invites her to add one

**Scenario 3 — Name and phone number cannot be changed**
- Given the rider views her profile
- When she taps her name or her phone number
- Then neither enters edit mode
- And tapping the phone number shows the note "رقم الهاتف لا يمكن تغييره" / "Phone number cannot be changed"

**Scenario 4 — Rider adds a profile photo**
- Given a rider with no profile photo
- When she taps the placeholder and chooses a photo from her camera or her gallery
- Then a preview is shown before she confirms
- And on confirming, the photo is uploaded (#4475) and the header shows it in place of the placeholder

**Scenario 5 — Rider replaces or removes her photo**
- Given a rider who already has a profile photo
- When she taps it, the actions offered are to change it or remove it
- And choosing change and confirming a new image replaces it in the header
- And choosing remove returns the header to the placeholder, exactly as for a rider who never set one

**Scenario 6 — An unsupported or oversized photo is refused**
- Given the rider picks a file that is not a JPEG or PNG, or is larger than 10 MB
- When she confirms it
- Then the error "اختاري صورة JPEG أو PNG أقل من 10 ميجا" / "Choose a JPEG or PNG under 10 MB" is shown
- And her existing photo, if any, is unchanged

**Scenario 7 — Rider saves a place**
- Given the rider opens Manage from the saved places section
- When she adds a place, labels it Home and picks an address through the address search (#1548)
- Then it is saved (#4475) and appears in the saved places section
- And it can then be chosen as a pickup or a destination when she books

**Scenario 8 — One Home and one Work**
- Given the rider already has a place saved as Home
- When she saves a different address as Home
- Then she is told the existing Home will be replaced, and on confirming exactly one Home remains
- And the same applies to Work, while custom labels may repeat

**Scenario 9 — Rider edits and deletes a saved place**
- Given the rider taps a saved place
- When she changes its label or address and saves, the list shows the updated place
- And when she deletes it, she is asked to confirm first, and afterwards it is gone and her other saved places are untouched

**Scenario 10 — Saved places are capped at ten**
- Given the rider already has ten saved places
- When she tries to add another
- Then she is told she must delete one first, and the add action does not proceed

**Scenario 11 — The account rows open the screens that own them**
- Given the rider views her profile
- When she taps the payment method row, the payments screen opens (#3992)
- And when she taps the emergency contacts row, the emergency contacts screen opens (#1787)
- And the contacts count on the row is the one the contacts endpoint returns (#1787)
- And her outstanding balance is not shown anywhere on the profile screen

**Scenario 12 — Account status is reflected on her photo**
- Given a rider whose account has been placed under review (#1687) or suspended (#1740)
- When she opens the profile screen
- Then the badge on her photo reflects that status rather than the active state

**Scenario 13 — Network error loading the profile**
- Given the profile screen cannot reach the platform
- When it loads
- Then a retry option is shown in place of the profile content, and retrying re-issues the request

**Scenario 14 — Network error during a save**
- Given the rider saves a photo or a saved place
- When the request fails
- Then the toast "فشل الحفظ. حاول مجدداً" / "Save failed. Please try again." is shown
- And she stays on the screen with her entry intact so she can retry

**Scenario 15 — Logging out is unchanged**
- Given the rider taps Log Out
- Then the existing logout flow runs exactly as it does today (#1547)

**Scenario 16 — Arabic and English**
- Given the rider switches language
- Then every label, stat caption, section heading, action, empty state and error on the screen is displayed in the selected language
- And the screen lays out correctly in RTL

### Out of Scope
- Editing her name — it stays as registered (#1545)
- Changing her phone number — it is her sign-in identity
- Managing the emergency contacts themselves — this screen shows the count and links out (#1787)
- Choosing or adding a payment method — online card payment is a separate story (#1732), awaiting the payment integration
- Showing her outstanding balance on this screen — she is told by the home-screen banner (#3995)
- The trip history list behind the trip count (#1568)
- Account deletion (Phase 2)
- Password management — authentication is OTP-based
- Any use of the rider photo for verification — it is decorative and is never checked against anything

### Dependencies
- #4475 — Rider profile is served in one call and its editable parts are saved (API — must be live; replaces the removed #1721)
- #1729 — Rider changes language preference from profile screen (the language row on this screen; the preference is stored on the device, with no API)
- #1787 — Rider sets up emergency contacts (supplies the contacts count, and is the screen the contacts row opens)
- #3992 — Rider views her payment method (the screen the payment method row opens)
- #1547 — Rider logs out (the Log Out action)
- #1548 — Rider address search (the picker used when saving a place)
- #1853 — [Rider] Profile & Account (design)
- #4492 — [Rider] Saved Places (design)

---

## [Mobile] #1729 — Rider changes language preference from profile screen 🆕
**Feature:** Feature 2 — Rider Authentication | **Sprint:** 2

**Description:** As a rider, I want to change my app language from my profile screen so that I can use the app in my preferred language.

### Background

The language preference toggle is available on the rider profile screen. The rider can switch between Arabic (default, RTL) and English (LTR). When she switches, the UI updates immediately without requiring a restart. The preference is stored on the device itself — there is no server copy and no API behind it, so switching language never needs a connection and never fails for lack of one. It survives closing the app and logging out and back in on the same device; a new device starts in Arabic, the default.

### Acceptance Criteria

**Scenario 1 — Rider switches from Arabic to English**
- Given the rider is using the app in Arabic
- When she selects English on the language toggle on the profile screen
- Then the UI language switches with app restart
- And the layout direction changes from RTL to LTR
- And the preference is saved on the device

**Scenario 2 — Rider switches from English to Arabic**
- Given the rider is using the app in English
- When she selects Arabic on the language toggle
- Then the UI language switches to Arabic with app restart
- And the layout direction changes to RTL
- And the preference is saved on the device

**Scenario 3 — Language preference is restored after app restart**
- Given the rider has selected English
- When she closes and reopens the app
- Then the app launches in English

**Scenario 4 — Language preference survives logging out and back in**
- Given the rider has selected English on this device
- When she logs out and logs back in on the same device
- Then the app is still in English
- And logging out does not clear her language preference

**Scenario 5 — Changing the language needs no connection**
- Given the rider has no network connection
- When she switches language on the profile screen
- Then the language changes exactly as it does online
- And the preference is saved on the device, with no request sent to the platform

### Out of Scope
- Languages other than Arabic and English
- Per-notification language settings
- Carrying the preference to another device — it is stored on the device only
- Any server-side copy of the preference, or an API for it

### Dependencies
- None — the preference is stored on the device; no API is involved

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

## [Mobile] #3992 — Rider views her payment method ✏️
**Feature:** Feature 22 — Payments & Outstanding Fees (Rider) | **Sprint:** 2

**Description:** As a rider, I want to see how I pay for my rides so that I know what to expect at the end of a trip.

### Background

Riders pay in cash today. This story rewrites the payments screen, which today is a coming-soon stub, into a working one, and builds its first section: the payment method. It shows "Cash" as her payment method and states plainly that rides are paid to the driver in cash at the end of the trip.

Online card payment is in scope for the rider app but waits for the payment integration. It has its own stories — choosing a payment method (#1732) and paying by card at the end of the trip (#1734) — and adds Card to this section when it ships. Until then Cash is the only method shown.

Further sections are added to this screen by later stories: the outstanding fees she owes, her fee history, a "No Fees Due" state and a load-error state, as shown in the design. This story does not build them.

The payment-method section is static — it is not fetched, so it has no loading or error state of its own. All strings flow through `data-i18n` keys with Arabic fallback text in the HTML.

### Acceptance Criteria

**Scenario 1 — Cash shown as the payment method**
- Given the rider opens the payments screen
- Then "Cash" is shown as her payment method
- And the screen states that she pays the driver in cash at the end of the ride
- And no other payment method is offered until online card payment ships (#1732)

**Scenario 2 — The coming-soon stub is gone**
- Given the rider opens the payments screen
- Then no coming-soon or placeholder content is shown

**Scenario 3 — Arabic and English**
- Given the rider switches language
- Then the payment-method label and its explanation are displayed in the selected language

### Out of Scope

- The outstanding fees, fee history, "No Fees Due" and load-error sections of this screen — later stories
- Online card payment: choosing a payment method (#1732) and paying by card at the end of the trip (#1734) — separate stories, awaiting the payment integration
- Paying an outstanding balance from the app — the only way it clears is the surcharge on her next completed trip (#4000)
- Disputing a fee (Phase 2)
- Receipts or invoices as PDFs

### Dependencies

- None — the payment method is static.

---

### Online card payment — awaiting the payment integration

> In scope for the rider app, but waiting for the payment-gateway integration. Kept as separate stories outside the sprint plan (ADO tag `Awaiting payment integration`).

---

## [Mobile] #1732 — Rider selects a payment method ♻️
**Feature:** Feature 22 — Payments & Outstanding Fees (Rider) | **Sprint:** Awaiting payment integration (not scheduled)

**Description:** As a rider, I want to select my preferred payment method before booking a ride so that I and the driver both know how the fare will be settled at the end of the trip.

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

## [Mobile] #1734 — Rider completes online card payment at trip end ♻️
**Feature:** Feature 22 — Payments & Outstanding Fees (Rider) | **Sprint:** Awaiting payment integration (not scheduled)

**Description:** As a rider, I want to be charged automatically via my card at the end of a trip so that I do not need to carry cash.

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

