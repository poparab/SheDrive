# SheDrive MVP — All 110 Stories

Generated Wed Jun  3 04:55:41 EDT 2026. Sprint 1 (Features 1–7) + Sprint 2 (Features 8–15). 50 Mobile · 47 API · 13 Admin.

---

# SheDrive — User Stories Part 1: Features 1–4

Sprint assignments: Feature 1 (Sprint 1), Feature 2 (Sprint 1), Feature 3 (Sprint 1), Feature 4 (Sprint 1–2).

---

## [API] #1616 — SMS gateway delivers OTP to Egyptian mobile numbers
**Feature:** Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want an SMS gateway integrated and verified for Egyptian mobile numbers so that all OTP flows can reliably deliver codes to riders and drivers.

### Background
The SMS gateway (e.g., Unifonic or Vonage) is configured as the delivery channel for all one-time passcodes issued by the SheDrive platform. It is invoked internally whenever #1620 receives a valid OTP request. The integration must support Egyptian mobile numbers across all four carrier prefixes (010 Vodafone, 011 Etisalat/e&, 012 Orange, 015 WE). The gateway is considered live when a test OTP is successfully received on a real Egyptian SIM within 15 seconds.

### Acceptance Criteria
**Scenario 1 — OTP is delivered to a valid Egyptian number within the SLA**
- Given a valid 11-digit Egyptian mobile number (01[0125]XXXXXXXX) has been submitted to the OTP request endpoint
- When the platform dispatches an OTP via the SMS gateway
- Then the SMS is delivered to the handset within 15 seconds
- And the message body contains exactly the 6-digit OTP code and no other sensitive data

**Scenario 2 — All four Egyptian carrier prefixes are supported**
- Given a valid Egyptian mobile number with prefix 010, 011, 012, or 015
- When the platform sends an OTP to that number
- Then the SMS gateway accepts the number and delivers the message without error

**Scenario 3 — Gateway delivery failure is surfaced**
- Given the SMS gateway returns a delivery failure response (e.g., invalid number at carrier level, gateway timeout)
- When the platform processes the failure
- Then the failure is logged internally with the gateway error code
- And the OTP request endpoint returns a service-unavailable error so the client can prompt the user to retry

**Scenario 4 — Message does not expose internal metadata**
- Given an OTP SMS is dispatched
- When the rider or driver receives the message
- Then the message contains only the OTP code and a short app-attribution string (e.g., "SheDrive رمز التحقق: 123456")
- And no session IDs, user IDs, or internal tokens appear in the message body

### Out of Scope
- WhatsApp or email OTP delivery
- OTP delivery to non-Egyptian international numbers
- SMS delivery reports or read receipts beyond gateway acknowledgement
- SOS/emergency features

### Dependencies
- None (foundational integration story)

---

## [API] #1617 — Google Maps returns route distance and duration
**Feature:** Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want the Google Maps Distance Matrix / Directions API integrated and returning route data for Cairo/Giza coordinates so that fare estimation and active-trip screens can display accurate distances and durations.

### Background
The Google Maps Distance Matrix and/or Directions API is the platform's sole source of route distance and estimated travel duration. It is called server-side when a rider submits a trip request from the home screen and again when the active-trip screen needs a live ETA. The integration must operate correctly for origin/destination pairs within Cairo and Giza governorates. The integration is considered live when a test query for a Cairo–Giza pair returns a valid distance in metres and duration in seconds.

### Acceptance Criteria
**Scenario 1 — Valid Cairo/Giza coordinates return distance and duration**
- Given a valid origin coordinate and a valid destination coordinate both within Cairo or Giza
- When the platform queries the Google Maps Distance Matrix API
- Then the response includes a route distance in metres and a travel duration in seconds
- And the values are used as inputs to fare estimation and trip display

**Scenario 2 — Response is available within an acceptable latency**
- Given a route query is dispatched to Google Maps
- When the API responds
- Then the round-trip response is received within 3 seconds under normal network conditions

**Scenario 3 — API error is handled gracefully**
- Given the Google Maps API returns an error (e.g., quota exceeded, invalid key, network timeout)
- When the platform processes the failure
- Then the error is logged internally
- And the caller receives a service-unavailable response so the client can inform the user

**Scenario 4 — Coordinates outside supported area are rejected**
- Given origin or destination coordinates that fall outside Egypt
- When the platform receives such a route query
- Then the request is rejected with a validation error before the external API is called

### Out of Scope
- Real-time traffic rerouting during an active trip
- Walking or transit routing modes
- Street-name display or turn-by-turn navigation
- SOS/emergency features

### Dependencies
- None (foundational integration story)

---

## [API] #1618 — Push notification service delivers to iOS and Android
**Feature:** Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want FCM (Android) and APNs (iOS) integrations configured and verified so that all push notifications for driver decisions, trip state changes, and OTP edge cases are reliably delivered to rider and driver devices.

### Background
The push notification service acts as the real-time channel from the platform to rider and driver apps. FCM is used for Android devices and APNs for iOS devices. Device tokens are registered via #1625 immediately after login or registration. The service is invoked whenever the platform needs to notify a driver of a new trip request, notify a rider of driver acceptance or arrival, or deliver any other in-app alert. The integration is considered live when a test notification is received on both an Android and an iOS device within 10 seconds.

### Acceptance Criteria
**Scenario 1 — Push notification is delivered to an Android device**
- Given a driver or rider has a registered FCM device token (via #1625)
- When the platform dispatches a push notification to that device token
- Then the notification appears on the Android device within 10 seconds
- And the notification payload includes the intended title and body text

**Scenario 2 — Push notification is delivered to an iOS device**
- Given a driver or rider has a registered APNs device token (via #1625)
- When the platform dispatches a push notification to that device token
- Then the notification appears on the iOS device within 10 seconds
- And the notification payload includes the intended title and body text

**Scenario 3 — Stale or invalid device token is handled**
- Given a device token that is no longer valid (device uninstalled the app or token rotated)
- When the platform attempts delivery and the push provider returns a token-invalid error
- Then the platform marks that token as inactive in its records
- And no further notifications are dispatched to that token until a new one is registered

**Scenario 4 — Push provider error is logged**
- Given the push provider returns a non-token-related error (e.g., quota exceeded, server error)
- When the platform processes the failure
- Then the error is logged internally with the provider error code
- And the notification is queued for one retry

### Out of Scope
- In-app banners or toasts (handled client-side)
- Silent/background push for location updates
- Notification grouping or badging
- SOS/emergency push alerts (separate story)

### Dependencies
- #1625 — User registers device token for push notifications (must be live)

---

## [API] #1619 — Auth middleware validates session tokens on all protected endpoints
**Feature:** Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want every protected endpoint to verify the Authorization header for a valid session token so that only authenticated users can access protected resources.

### Background
Auth middleware is a cross-cutting concern applied to every endpoint that is not explicitly public (i.e., every endpoint except #1620 and #1621/#1622). The middleware reads the session token from the Authorization header (Bearer scheme), looks it up in the session store, and either allows the request to proceed with the authenticated user's context or rejects it immediately. A session token is issued upon successful login (#1622) or registration (#1621) and is invalidated upon logout (#1624). This story defines the validation contract that all downstream API stories depend on.

### Acceptance Criteria
**Scenario 1 — Valid session token allows request to proceed**
- Given a request to a protected endpoint includes a well-formed Authorization: Bearer [token] header
- When the middleware looks up the token in the session store
- Then the token is found, is not expired, and has not been invalidated by logout
- And the request is passed to the endpoint handler with the authenticated user's ID and role in context

**Scenario 2 — Missing Authorization header is rejected**
- Given a request to a protected endpoint has no Authorization header
- When the middleware processes the request
- Then the request is rejected with an authentication-required error before reaching the endpoint handler

**Scenario 3 — Malformed token is rejected**
- Given a request includes an Authorization header with a value that is not a valid token format (e.g., empty string, random text, missing Bearer prefix)
- When the middleware processes the request
- Then the request is rejected with an authentication error

**Scenario 4 — Expired session token is rejected**
- Given a session token that has passed its expiry time
- When a request is made to any protected endpoint using that token
- Then the middleware rejects the request with a session-expired error

**Scenario 5 — Invalidated (logged-out) token is rejected**
- Given a session token that was previously valid but was invalidated via #1624 (logout)
- When a request is made using that token
- Then the middleware rejects the request even if the token has not yet reached its expiry time

### Out of Scope
- Role-based access control beyond rider/driver/admin distinction
- OAuth or third-party SSO
- Token refresh or sliding session windows
- SOS/emergency features

### Dependencies
- #1621 — User registers with OTP verification (issues tokens)
- #1622 — User logs in with OTP verification (issues tokens)
- #1624 — User session is invalidated on logout (revokes tokens)

---

## [Admin] #1656 — Admin portal shell and login screen are in place
**Feature:** Platform & Integration Foundation | **Sprint:** 1

**Description:** As an operations admin, I want a working admin web portal with a login screen and shell layout so that I can securely access SheDrive operations dashboards.

### Background
The admin portal is a web application accessible to SheDrive operations staff. It presents a login screen (email + password) as its unauthenticated entry point. Successful authentication lands the admin on the main dashboard, which sits within a persistent shell consisting of a navigation sidebar or top bar and a content area. The portal is distinct from the rider/driver mobile app and serves as the operations team's command centre for approving drivers, monitoring trips, and managing the platform.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Email | Yes | Valid email address (contains @, valid domain) | — | 254 chars | Standard email characters (letters, digits, @, ., -, _) | أدخل البريد الإلكتروني | بريد إلكتروني غير صحيح | بريد إلكتروني غير صحيح |
| Password | Yes | Any printable characters | 8 chars | — | Any printable characters | أدخل كلمة المرور | — | أدخل كلمة المرور (if under 8 chars) |

### Acceptance Criteria
**Scenario 1 — Admin logs in with valid credentials**
- Given an operations admin navigates to the admin portal login screen
- When she enters a valid registered email and the correct password and submits the form
- Then she is authenticated and redirected to the admin dashboard
- And the shell navigation (sidebar or top bar) is visible

**Scenario 2 — Login fails with wrong credentials**
- Given an admin enters a registered email with an incorrect password
- When she submits the form
- Then she remains on the login screen
- And the error message "البريد الإلكتروني أو كلمة المرور غير صحيحة" is displayed

**Scenario 3 — Login form validates empty fields**
- Given an admin submits the login form with the email field empty
- When the form validates
- Then the error "أدخل البريد الإلكتروني" is displayed inline
- And if the password field is also empty, "أدخل كلمة المرور" is displayed inline

**Scenario 4 — Login form validates email format**
- Given an admin enters a value that does not conform to email format (e.g., missing @)
- When she submits the form
- Then the error "بريد إلكتروني غير صحيح" is displayed inline

**Scenario 5 — Admin portal shell is accessible after login**
- Given an authenticated admin is on any portal page
- When she views the page
- Then the shared navigation shell (links to Dashboard, Driver Management, Trip Monitor, and Settings at minimum) is always visible
- And the active page is indicated in the navigation

**Scenario 6 — Unauthenticated access to protected portal pages is redirected**
- Given a user attempts to navigate directly to a protected admin portal URL without a valid session
- When the portal processes the request
- Then the user is redirected to the login screen

### Out of Scope
- Password reset or forgot-password flow
- Multi-factor authentication for admin login
- Admin user management (creating/deleting admin accounts)
- SOS/emergency features

### Dependencies
- None (foundational portal shell story)

---

## [Mobile] #1545 — Rider registers
**Feature:** Rider Authentication | **Sprint:** 1

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
**Feature:** Rider Authentication | **Sprint:** 1

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
**Feature:** Rider Authentication | **Sprint:** 1

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

## [Mobile] #1569 — Driver registers and is directed to onboarding
**Feature:** Driver Authentication | **Sprint:** 1

**Description:** As a driver, I want to register an account using my phone number and a one-time passcode so that I can begin the onboarding process to become a verified SheDrive driver.

### Background
The driver registration flow mirrors rider registration (two screens: phone entry then OTP + full name) but diverges at success: instead of landing on a home screen, the driver is taken directly to the onboarding flow (personal details screen). A driver with no completed or approved onboarding cannot reach the driver home/availability screen. The OTP rules (5-minute expiry, 3-attempt limit, 60-second resend cooldown) are identical to rider registration.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Phone number | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |
| Full name | Yes | Arabic and/or Latin letters and spaces only; no digits or symbols | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخل اسمك الكامل | الاسم يجب أن يحتوي على حروف فقط | الاسم يجب أن يكون بين 2 و50 حرفاً |

### Acceptance Criteria
**Scenario 1 — Successful registration redirects to onboarding**
- Given a new driver opens the driver app and taps "إنشاء حساب"
- When she enters a valid Egyptian mobile number, receives and enters the correct 6-digit OTP, and enters a valid full name
- Then her account is created and she is taken to the onboarding flow (personal details screen)
- And she cannot navigate to the driver home screen until onboarding is approved

**Scenario 2 — Phone number already registered**
- Given a driver enters a phone number already linked to an existing account
- When she proceeds through OTP entry, the server returns a conflict via #1621
- Then the app displays "هذا الرقم مسجل بالفعل. سجّل الدخول بدلاً من ذلك" with a link to the driver login screen

**Scenario 3 — OTP expires before entry**
- Given a driver received an OTP but did not enter it within 5 minutes
- When she submits the expired code
- Then the app displays "انتهت صلاحية رمز التحقق. اطلب رمزاً جديداً"

**Scenario 4 — Wrong OTP entered**
- Given a driver enters an incorrect OTP
- When she submits
- Then the app displays "رمز التحقق غير صحيح"
- And after 3 consecutive wrong attempts, the code is invalidated and she must request a new one

**Scenario 5 — OTP resend cooldown**
- Given a driver has just requested an OTP
- When she taps "إعادة إرسال الرمز" within 60 seconds
- Then the button is disabled showing a countdown
- And after 60 seconds, a new OTP is sent on tap

**Scenario 6 — Full name validation failure**
- Given a driver enters a name containing digits or special characters, or fewer than 2 characters
- When she taps "إنشاء حساب"
- Then the relevant inline validation error is displayed and the account is not created

**Scenario 7 — Network error during OTP request**
- Given the device has no internet connection when the driver taps "إرسال الرمز"
- When the request fails
- Then the app displays "تحقق من اتصالك بالإنترنت وحاول مرة أخرى"

### Out of Scope
- Driver document submission (covered by onboarding stories)
- Driver resubmission after rejection
- Social sign-in
- In-app masked calling
- Trusted contacts

### Dependencies
- #1620 — User requests OTP via SMS (must be live)
- #1621 — User registers with OTP verification (must be live)

---

## [Mobile] #1570 — Driver logs in
**Feature:** Driver Authentication | **Sprint:** 1

**Description:** As a driver, I want to log in to my existing account using my phone number and a one-time passcode so that I can access the driver app based on my onboarding approval status.

### Background
The driver login flow uses the same two-screen OTP structure as rider login. After successful OTP verification via #1622, the app checks the driver's onboarding status: if onboarding is approved, the driver lands on the driver home/availability screen; if onboarding is pending or rejected, the driver is taken to a pending/status screen (covered by #1576). No name field appears on the login screen. OTP rules are identical to other flows.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Phone number | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |

### Acceptance Criteria
**Scenario 1 — Approved driver lands on home screen**
- Given a driver with an approved onboarding status enters her phone number and the correct OTP
- When authentication succeeds via #1622
- Then she is taken to the driver home/availability screen with an active session

**Scenario 2 — Pending or rejected driver lands on status screen**
- Given a driver whose onboarding is pending review or has been rejected enters her phone number and the correct OTP
- When authentication succeeds
- Then she is taken to the pending/status screen (see #1576) instead of the driver home screen
- And the status screen explains her current onboarding state

**Scenario 3 — Phone number not registered**
- Given a driver enters a phone number that has no existing account
- When she taps "إرسال الرمز"
- Then the app displays "هذا الرقم غير مسجل. أنشئ حساباً جديداً" with a link to the registration screen

**Scenario 4 — OTP expires before entry**
- Given a driver received an OTP but did not enter it within 5 minutes
- When she submits the expired code
- Then the app displays "انتهت صلاحية رمز التحقق. اطلب رمزاً جديداً"

**Scenario 5 — Wrong OTP entered**
- Given a driver enters an incorrect OTP
- When she submits
- Then the app displays "رمز التحقق غير صحيح"
- And after 3 consecutive wrong attempts, the code is invalidated and she must request a new one

**Scenario 6 — Network error**
- Given the device has no internet connection
- When the driver taps "إرسال الرمز"
- Then the app displays "تحقق من اتصالك بالإنترنت وحاول مرة أخرى"

### Out of Scope
- Password-based login
- Driver resubmission after rejection
- In-app masked calling
- Trusted contacts

### Dependencies
- #1620 — User requests OTP via SMS (must be live)
- #1622 — User logs in with OTP verification (must be live)

---

## [Mobile] #1571 — Driver logs out
**Feature:** Driver Authentication | **Sprint:** 1

**Description:** As a driver, I want to log out of the app so that my session is secured and I am automatically set to offline before my device is released.

### Background
The logout action is accessible from the driver app's menu or profile screen. Before the session is invalidated, the platform automatically sets the driver's availability status to offline (if she was online). The app then calls #1624 to invalidate the session token and deregister the device push token. The driver is taken back to the splash/login screen. No confirmation dialog is required in this sprint.

### Acceptance Criteria
**Scenario 1 — Online driver is set offline before logout**
- Given a driver is authenticated and her availability status is online
- When she taps "تسجيل الخروج"
- Then the platform automatically sets her status to offline
- And then the session token is invalidated via #1624 and the push token is deregistered
- And she is taken to the splash/login screen

**Scenario 2 — Offline driver logs out cleanly**
- Given a driver is authenticated and her availability status is already offline
- When she taps "تسجيل الخروج"
- Then the session token is invalidated via #1624 and the push token is deregistered
- And she is taken to the splash/login screen

**Scenario 3 — Session is rejected after logout**
- Given a driver has successfully logged out
- When any subsequent request is made using the old session token
- Then the token is rejected by #1619 and she is shown the login screen

**Scenario 4 — Network error during logout**
- Given the device has no internet connection when the driver taps "تسجيل الخروج"
- When the logout request fails
- Then the app clears the local session and navigates to the login screen regardless
- And if the driver was online, her status is set offline on the server when connectivity is restored

### Out of Scope
- Logout confirmation dialog
- Remote logout from another device
- Account deletion
- In-app masked calling
- SOS/emergency features

### Dependencies
- #1624 — User session is invalidated on logout (must be live)

---

## [API] #1620 — User requests OTP via SMS
**Feature:** Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an unauthenticated endpoint with a phone number so that a 6-digit OTP is sent to that number via SMS.

### Background
This is an unauthenticated public endpoint called as the first step of both registration and login flows for riders and drivers. It accepts an Egyptian mobile number, validates the format, generates a 6-digit OTP, stores it with a 5-minute expiry, and dispatches it via the SMS gateway (#1616). Whether the number is already registered or new, the OTP is sent (the downstream register/login endpoint determines the flow). Rate limiting is applied per phone number to prevent OTP spam.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped before validation | 11 digits (after stripping) | 11 digits (after stripping) | Digits only (after stripping) | Return validation error: phone is required | Return validation error: must be a valid Egyptian mobile number (01[0125]XXXXXXXX) | Return validation error: must be exactly 11 digits |

### Acceptance Criteria
**Scenario 1 — Valid phone number triggers OTP dispatch**
- Given a valid Egyptian mobile number is submitted
- When the endpoint processes the request
- Then a 6-digit OTP is generated, stored with a 5-minute expiry, and dispatched via SMS (#1616)
- And a success response is returned (the phone's registration status is not disclosed)

**Scenario 2 — +20 prefix is stripped and validated**
- Given a phone number submitted with the +20 country prefix (e.g., +201012345678)
- When the endpoint processes the request
- Then the prefix is stripped, the resulting 11-digit number is validated, and the OTP is dispatched if valid

**Scenario 3 — Invalid phone number format is rejected**
- Given a phone number that does not match 01[0125]XXXXXXXX after stripping
- When the endpoint processes the request
- Then a validation error is returned describing the valid Egyptian mobile format
- And no OTP is generated or dispatched

**Scenario 4 — Empty phone number is rejected**
- Given a request body with a missing or empty phone field
- When the endpoint processes the request
- Then a validation error is returned indicating the phone field is required

**Scenario 5 — Rate limiting prevents OTP spam**
- Given a phone number has already received an OTP within the last 60 seconds
- When another OTP request is made for the same number
- Then the request is rejected with a rate-limit error indicating when the next request is permitted

### Out of Scope
- WhatsApp or email OTP delivery
- Disclosing whether the phone number is registered
- SOS/emergency features
- Trusted contacts

### Dependencies
- #1616 — SMS gateway delivers OTP to Egyptian mobile numbers (must be live)

---

## [API] #1621 — User registers with OTP verification
**Feature:** Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an unauthenticated endpoint with a phone number, OTP, and full name so that a new account is created and a session token is returned on success.

### Background
This unauthenticated endpoint is called after the user has received her OTP via #1620. It accepts the phone number, the 6-digit OTP, and the user's full name. The endpoint verifies that the OTP matches, is not expired, and has not been exhausted by too many wrong attempts. If the phone number is already registered, it returns a conflict error. If all checks pass, a new user account is created with the given name and phone, and a session token is returned.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only | Return validation error: phone is required | Return validation error: invalid Egyptian mobile format | Return validation error: must be 11 digits |
| otp | Yes | 6-digit numeric string | 6 chars | 6 chars | Digits only | Return validation error: OTP is required | Return validation error: OTP must be 6 digits | Return validation error: OTP must be 6 digits |
| name | Yes | Arabic and/or Latin letters and spaces only | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | Return validation error: name is required | Return validation error: name may only contain letters and spaces | Return validation error: name must be between 2 and 50 characters |

### Acceptance Criteria
**Scenario 1 — Successful registration returns session token**
- Given a valid phone, a correct and unexpired OTP, and a valid full name are submitted
- When the endpoint processes the request
- Then a new user account is created with the provided phone and name
- And a session token is returned that is accepted by #1619

**Scenario 2 — Phone number already registered returns conflict**
- Given a phone number that is already linked to an existing account is submitted
- When the endpoint processes the request
- Then a conflict error is returned indicating the number is already registered
- And no duplicate account is created

**Scenario 3 — Expired OTP is rejected**
- Given a valid phone and a correct OTP that has passed its 5-minute expiry window
- When the endpoint processes the request
- Then a validation error is returned indicating the OTP has expired
- And no account is created

**Scenario 4 — Wrong OTP is rejected**
- Given a valid phone and an incorrect OTP are submitted
- When the endpoint processes the request
- Then a validation error is returned indicating the OTP is incorrect
- And the wrong-attempt counter for that OTP is incremented

**Scenario 5 — OTP exhausted after 3 wrong attempts**
- Given a phone's OTP has already had 3 consecutive wrong attempts
- When another registration attempt is made for that phone (even with the correct OTP)
- Then an error is returned indicating the code is invalidated and a new one must be requested

**Scenario 6 — Invalid payload fields are rejected**
- Given a request with a missing phone, an OTP that is not 6 digits, or a name containing digits or symbols
- When the endpoint processes the request
- Then a validation error is returned describing the failing field(s)
- And no account is created

**Scenario 7 — Unauthenticated request is processed correctly**
- Given no Authorization header is present (this is a public endpoint)
- When the endpoint receives the request
- Then the request is processed normally (no auth check is applied)

### Out of Scope
- Email registration
- Social sign-in
- Driver-specific onboarding initiation (handled client-side after token receipt)
- SOS/emergency features

### Dependencies
- #1620 — User requests OTP via SMS (OTP must have been issued first)
- #1616 — SMS gateway delivers OTP to Egyptian mobile numbers (must be live)

---

## [API] #1622 — User logs in with OTP verification
**Feature:** Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an unauthenticated endpoint with a phone number and OTP so that a returning user is authenticated and a session token is returned.

### Background
This unauthenticated endpoint is the second step of the login flow. It accepts the phone number and 6-digit OTP, verifies the OTP is correct and not expired, checks that the phone number belongs to a registered account, and returns a session token. The endpoint does not accept or return a name field — name is only provided at registration. OTP expiry, wrong-attempt limits, and cooldown rules are enforced here identically to #1621.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only | Return validation error: phone is required | Return validation error: invalid Egyptian mobile format | Return validation error: must be 11 digits |
| otp | Yes | 6-digit numeric string | 6 chars | 6 chars | Digits only | Return validation error: OTP is required | Return validation error: OTP must be 6 digits | Return validation error: OTP must be 6 digits |

### Acceptance Criteria
**Scenario 1 — Successful login returns session token**
- Given a registered phone number and a correct, unexpired OTP are submitted
- When the endpoint processes the request
- Then a session token is returned that is accepted by #1619
- And the response includes the user's role (rider or driver) so the client can route accordingly

**Scenario 2 — Phone number not registered returns not-found error**
- Given a phone number that has no registered account is submitted
- When the endpoint processes the request
- Then a not-found error is returned
- And no session token is issued

**Scenario 3 — Expired OTP is rejected**
- Given a registered phone and an OTP that has passed its 5-minute expiry
- When the endpoint processes the request
- Then a validation error is returned indicating the OTP has expired

**Scenario 4 — Wrong OTP is rejected**
- Given a registered phone and an incorrect OTP
- When the endpoint processes the request
- Then a validation error is returned indicating the OTP is incorrect
- And the wrong-attempt counter is incremented

**Scenario 5 — OTP exhausted after 3 wrong attempts**
- Given a phone's OTP has had 3 consecutive wrong attempts
- When another login attempt is made
- Then an error is returned indicating the code is invalidated and a new one must be requested via #1620

**Scenario 6 — Unauthenticated request is processed correctly**
- Given no Authorization header is present (this is a public endpoint)
- When the endpoint receives the request
- Then the request is processed normally

### Out of Scope
- Password-based authentication
- Social sign-in
- Returning user's role routing (handled client-side based on the role in the response)
- SOS/emergency features

### Dependencies
- #1620 — User requests OTP via SMS (OTP must have been issued first)

---

## [API] #1623 — User retrieves own profile
**Feature:** Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to retrieve the current user's profile so that the app can display the user's name, phone, and role.

### Background
This authenticated endpoint returns the profile data of the user identified by the session token in the Authorization header. It requires no request body. The response includes the user's full name, phone number, role (rider or driver), and registration date. It is called on app launch or when the profile screen is opened to ensure displayed data is up to date.

### Acceptance Criteria
**Scenario 1 — Authenticated user retrieves profile**
- Given a valid session token is present in the Authorization header
- When the endpoint is called with no request body
- Then the response includes the authenticated user's full name, phone number, role (rider or driver), and account registration date

**Scenario 2 — Unauthenticated request is rejected**
- Given no Authorization header or an invalid token is present
- When the endpoint receives the request
- Then the request is rejected by #1619 auth middleware before the profile is accessed

### Out of Scope
- Profile editing (name or phone update)
- Profile photo upload
- Driver-specific profile fields (covered by onboarding stories)
- SOS/emergency features

### Dependencies
- #1619 — Auth middleware validates session tokens on all protected endpoints (must be live)

---

## [API] #1624 — User session is invalidated on logout
**Feature:** Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to invalidate my current session so that my token can no longer be used and my device's push token is deregistered.

### Background
This authenticated endpoint is called when a rider or driver taps logout. It identifies the session via the Authorization header, marks the session token as invalidated in the session store (so #1619 rejects it on future requests), and removes any stored push notification device token associated with this session. The call is idempotent — calling it a second time with an already-invalidated token is safe and returns a success response.

### Acceptance Criteria
**Scenario 1 — Session is invalidated and push token is deregistered**
- Given a valid session token is present in the Authorization header
- When the endpoint is called
- Then the session token is marked as invalidated in the session store
- And the push notification device token associated with this session is removed
- And a success response is returned

**Scenario 2 — Subsequent requests with the invalidated token are rejected**
- Given a session has been invalidated by this endpoint
- When any subsequent request is made to a protected endpoint using the same token
- Then #1619 rejects the request as if the token does not exist

**Scenario 3 — Calling logout twice is idempotent**
- Given a session has already been invalidated
- When the logout endpoint is called again with the same token
- Then a success response is returned (no error)

**Scenario 4 — Unauthenticated request is rejected**
- Given no Authorization header or an invalid token is present
- When the endpoint receives the request
- Then the request is rejected by #1619 auth middleware

### Out of Scope
- Remote logout from all devices
- Account deletion
- Logging the logout event for audit trail (separate concern)
- SOS/emergency features

### Dependencies
- #1619 — Auth middleware validates session tokens on all protected endpoints (must be live)

---

## [API] #1625 — User registers device token for push notifications
**Feature:** Authentication API | **Sprint:** 2

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to register my device's push notification token so that the platform can deliver real-time alerts to my device.

### Background
This authenticated endpoint is called immediately after a successful login or registration, and again whenever the operating system refreshes the device push token. It accepts the push token string and a platform identifier (ios or android) and associates them with the current session. The stored token is used by #1618 to deliver push notifications. If the same session already has a token stored, the new token replaces the old one (upsert behavior). This endpoint is a prerequisite for all push-notification-dependent features including driver trip request alerts and rider status updates.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| token | Yes | Non-empty string (FCM or APNs token format) | 1 char | 512 chars | Any printable characters | Return validation error: device token is required | — | Return validation error: token must not exceed 512 characters |
| platform | Yes | Enum: "ios" or "android" | — | — | Lowercase letters only | Return validation error: platform is required | Return validation error: platform must be "ios" or "android" | — |

### Acceptance Criteria
**Scenario 1 — Device token is registered successfully**
- Given a valid session token, a non-empty device push token string, and a valid platform value ("ios" or "android") are submitted
- When the endpoint processes the request
- Then the device token is stored and associated with the current session
- And a success response is returned

**Scenario 2 — Existing token for the session is replaced (upsert)**
- Given a session already has a registered device token
- When a new token is submitted for the same session (e.g., OS refreshed the token)
- Then the new token replaces the old one
- And only the latest token is used for subsequent push notifications

**Scenario 3 — Empty token is rejected**
- Given a request is submitted with an empty or missing token field
- When the endpoint processes the request
- Then a validation error is returned indicating the device token is required

**Scenario 4 — Invalid platform value is rejected**
- Given a platform value other than "ios" or "android" is submitted (e.g., "web", "huawei")
- When the endpoint processes the request
- Then a validation error is returned indicating the accepted platform values

**Scenario 5 — Unauthenticated request is rejected**
- Given no Authorization header or an invalid token is present
- When the endpoint receives the request
- Then the request is rejected by #1619 auth middleware

### Out of Scope
- Huawei Push Kit (HMS) support
- Web push notifications
- Multiple simultaneous device tokens per session
- SOS/emergency features

### Dependencies
- #1619 — Auth middleware validates session tokens on all protected endpoints (must be live)
- #1618 — Push notification service delivers to iOS and Android (must be live)

---

# SheDrive — User Stories: Features 5–7
**Sprint:** 1

---

## [Mobile] #1572 — Driver submits personal details
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to enter my personal details in the first step of the onboarding wizard so that SheDrive can verify my identity before approving my application.

### Background
The personal details screen is Step 1 of a multi-step onboarding wizard. It is shown only to drivers who have completed phone OTP login but have not yet submitted an application. The driver enters her full name, date of birth, and Egyptian National ID number. On successful save, she advances to Step 2 (vehicle details). All fields must pass validation before the wizard can advance.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Full name | Yes | Free text | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخلي اسمك الكامل | الاسم لا يحتوي على أرقام أو رموز | الاسم قصير جداً |
| Date of birth | Yes | DD/MM/YYYY | — | — | Digits and "/" separator | أدخلي تاريخ ميلادك | صيغة التاريخ غير صحيحة | — |
| National ID (NID) | Yes | 14-digit numeric | 14 digits | 14 digits | Digits only | أدخلي رقم الهوية الوطنية | رقم الهوية يجب أن يكون 14 رقمًا | رقم الهوية يجب أن يكون 14 رقمًا |

### Acceptance Criteria

**Scenario 1 — Happy path: all fields valid, wizard advances**
- Given the driver is on Step 1 of the onboarding wizard
- When she enters a valid full name, date of birth (age ≥ 21), and a 14-digit NID
- Then all inline errors are absent
- And tapping "Next" submits the step and navigates to Step 2 (vehicle details)

**Scenario 2 — Empty full name**
- Given the driver leaves the full name field blank
- When she taps "Next"
- Then the field is highlighted with the error "أدخلي اسمك الكامل"
- And the wizard does not advance

**Scenario 3 — Full name contains digits or symbols**
- Given the driver enters a name containing digits or special characters (e.g., "Fatma2" or "Fatma@")
- When she taps "Next"
- Then the field shows "الاسم لا يحتوي على أرقام أو رموز"

**Scenario 4 — Full name too short**
- Given the driver enters a single character name
- When she taps "Next"
- Then the field shows "الاسم قصير جداً"

**Scenario 5 — Invalid date of birth format**
- Given the driver enters a date in a non-DD/MM/YYYY format (e.g., "1996-04-15")
- When she taps "Next"
- Then the field shows "صيغة التاريخ غير صحيحة"

**Scenario 6 — Driver is underage**
- Given the driver enters a date of birth that makes her younger than 21 years old
- When she taps "Next"
- Then the field shows "يجب أن يكون عمرك 21 عامًا على الأقل"

**Scenario 7 — NID not 14 digits**
- Given the driver enters fewer or more than 14 digits in the NID field
- When she taps "Next"
- Then the field shows "رقم الهوية يجب أن يكون 14 رقمًا"

**Scenario 8 — NID contains non-digit characters**
- Given the driver types letters or symbols in the NID field
- When she taps "Next"
- Then the field shows "رقم الهوية يجب أن يكون 14 رقمًا"

### Out of Scope
- NID authenticity verification against government databases
- Re-submission flow after admin rejection
- Editing personal details after the application has been submitted

### Dependencies
- #1642 — Driver submits onboarding application (API endpoint that receives the submitted data)

---

## [Mobile] #1573 — Driver submits vehicle details
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to enter my vehicle details in Step 2 of the onboarding wizard so that SheDrive can verify that my vehicle meets service requirements.

### Background
The vehicle details screen is Step 2 of the multi-step onboarding wizard, reached after completing Step 1 (personal details). The driver enters information about the vehicle she will use to provide rides. Supported vehicle types are Sedan, SUV, and Minivan. On successful save, she advances to Step 3 (vehicle photo). All fields must pass validation before advancing.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Make (brand) | Yes | Free text | 2 chars | 30 chars | Letters, spaces | أدخلي ماركة السيارة | — | — |
| Model | Yes | Free text | 2 chars | 30 chars | Letters, spaces, digits | أدخلي موديل السيارة | — | — |
| Year | Yes | 4-digit year | 2010 | Current year | Digits only | أدخلي سنة الصنع | سنة الصنع غير صحيحة | سنة الصنع غير صحيحة |
| Plate number | Yes | Egyptian plate format | 2 chars | 8 chars | Letters, digits | أدخلي رقم اللوحة | رقم اللوحة غير صحيح | رقم اللوحة غير صحيح |
| Color | Yes | Selection from predefined list | — | — | — | اختاري لون السيارة | — | — |
| Vehicle type | Yes | One of: Sedan, SUV, Minivan | — | — | — | اختاري نوع السيارة | — | — |

### Acceptance Criteria

**Scenario 1 — Happy path: all fields valid, wizard advances**
- Given the driver is on Step 2 of the onboarding wizard
- When she enters a valid make, model, year (2010–current), plate number, and selects a color and vehicle type
- Then no inline errors are shown
- And tapping "Next" navigates to Step 3 (vehicle photo)

**Scenario 2 — Empty required field**
- Given the driver leaves any required field blank
- When she taps "Next"
- Then the empty field is highlighted with its respective empty-state error message
- And the wizard does not advance

**Scenario 3 — Year out of range**
- Given the driver enters a year before 2010 or after the current year
- When she taps "Next"
- Then the year field shows "سنة الصنع غير صحيحة"

**Scenario 4 — Invalid plate number**
- Given the driver enters a plate number with invalid characters or a length outside 2–8 characters
- When she taps "Next"
- Then the plate field shows "رقم اللوحة غير صحيح"

**Scenario 5 — No vehicle type selected**
- Given the driver does not select a vehicle type
- When she taps "Next"
- Then the vehicle type field shows "اختاري نوع السيارة"

### Out of Scope
- Vehicle registration validity check
- Support for vehicle types beyond Sedan, SUV, and Minivan
- Re-submission flow after admin rejection

### Dependencies
- #1642 — Driver submits onboarding application (API endpoint that receives the submitted data)

---

## [Mobile] #1574 — Driver photographs her vehicle
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to photograph my vehicle in Step 3 of the onboarding wizard so that the admin can visually verify the vehicle matches the details I provided.

### Background
The vehicle photo screen is Step 3 of the multi-step onboarding wizard, reached after completing Step 2 (vehicle details). The driver takes a photo using the device camera or selects one from the gallery. The photo must show the vehicle exterior with the plate number visible. The captured or selected image is uploaded and attached to the onboarding application. A gallery fallback is always available if the camera is unavailable or permission is denied. On successful upload, the wizard advances to Step 4 (documents).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Vehicle photo | Yes | JPEG, PNG, or HEIC image | — | 10 MB | — | يرجى التقاط صورة للسيارة | يرجى رفع صورة صالحة (JPEG أو PNG) | حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت |

### Acceptance Criteria

**Scenario 1 — Happy path: photo taken via camera**
- Given the driver is on Step 3 and camera permission has been granted
- When she taps the camera button and captures a photo
- Then a preview of the photo is displayed
- And tapping "Next" uploads the photo and navigates to Step 4

**Scenario 2 — Happy path: photo selected from gallery**
- Given the driver taps "Choose from gallery" and selects a valid image
- When the selection is confirmed
- Then a preview of the selected photo is displayed
- And tapping "Next" uploads the photo and navigates to Step 4

**Scenario 3 — Camera permission denied**
- Given the driver taps the camera button but camera permission is denied
- Then the app displays an explanation of why the camera is needed
- And shows a link to the device settings page so she can grant permission
- And the gallery fallback option remains visible and functional

**Scenario 4 — File too large**
- Given the driver selects or captures an image exceeding 10 MB
- Then the field shows "حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت"
- And the wizard does not advance

**Scenario 5 — Invalid file type**
- Given the driver selects a file that is not JPEG, PNG, or HEIC
- Then the field shows "يرجى رفع صورة صالحة (JPEG أو PNG)"

**Scenario 6 — No photo selected**
- Given the driver taps "Next" without providing a vehicle photo
- Then the field shows "يرجى التقاط صورة للسيارة"

### Out of Scope
- Automatic plate-number recognition or image quality scoring
- Video capture
- Re-submission flow after admin rejection

### Dependencies
- #1642 — Driver submits onboarding application (API endpoint that receives the submitted data)

---

## [Mobile] #1575 — Driver uploads licence and vehicle registration documents
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to upload my driving licence and vehicle registration documents in Step 4 of the onboarding wizard so that SheDrive can verify my eligibility to drive.

### Background
The documents screen is Step 4 (the final step) of the multi-step onboarding wizard, reached after completing Step 3 (vehicle photo). The driver uploads four documents: driving licence front, driving licence back, vehicle registration front, and vehicle registration back. Each is a separate file upload. When all four documents are provided and valid, the driver taps "Submit" to send the full application. On success, she is navigated to the pending state screen (#1576).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Driving licence — front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Driving licence — back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Vehicle registration — front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Vehicle registration — back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |

### Acceptance Criteria

**Scenario 1 — Happy path: all four documents uploaded, application submitted**
- Given the driver has uploaded all four valid documents
- When she taps "Submit"
- Then the full application is sent to the API (#1642)
- And she is navigated to the pending state screen (#1576)
- And a success confirmation message is briefly shown

**Scenario 2 — Missing document**
- Given the driver taps "Submit" without uploading one or more required documents
- Then each missing document slot shows "يرجى رفع هذه الوثيقة"
- And the submission is blocked until all four are provided

**Scenario 3 — File too large**
- Given the driver selects a document file exceeding 10 MB
- Then that slot immediately shows "حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت"

**Scenario 4 — Invalid file type**
- Given the driver selects a file that is not JPEG, PNG, or PDF
- Then that slot shows "يرجى رفع صورة أو ملف PDF"

**Scenario 5 — Network error during submission**
- Given all four documents are valid and the driver taps "Submit"
- When the network request to the API fails
- Then an error toast is shown (e.g., "حدث خطأ، يرجى المحاولة مرة أخرى")
- And the driver remains on the documents screen with her uploads intact

### Out of Scope
- Document authenticity or expiry verification
- Re-submission after admin rejection
- Uploading more than four document files

### Dependencies
- #1642 — Driver submits onboarding application (API endpoint that receives the submitted data)

---

## [Mobile] #1576 — Driver sees pending state until approved
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to see a clear "Application under review" screen after submitting my documents so that I know my application has been received and I understand I must wait for approval before driving.

### Background
The pending screen is displayed immediately after a successful application submission (#1642) and on every subsequent login while the application status is "pending". The driver has no access to the driver home screen or any trip-related functionality. The screen shows a clear visual indicator and message explaining the review process. When the driver is approved or rejected, the screen updates or navigates on next app open per the push notification flow (#1577).

### Acceptance Criteria

**Scenario 1 — Driver lands on pending screen after submission**
- Given the driver has just submitted her onboarding application
- When the submission succeeds
- Then she is navigated to the pending screen
- And the screen displays an "Application under review" message in Arabic and English
- And no driver home, map, or trip UI is accessible

**Scenario 2 — Pending driver returns to app and sees pending screen**
- Given a driver with application status = pending opens the app
- When the app checks status via #1643
- Then she is routed to the pending screen regardless of her navigation attempt
- And cannot reach the driver home screen

**Scenario 3 — Approved driver no longer sees pending screen**
- Given a driver's application has been approved
- When she opens the app
- Then she is routed to the driver home screen (#1578), not the pending screen

**Scenario 4 — Rejected driver sees rejection notice**
- Given a driver's application has been rejected
- When she opens the app and the status check returns "rejected"
- Then the pending screen updates to display a rejection notice including the admin's stated reason
- And no driver home or trip UI is accessible

### Out of Scope
- Re-submission flow after rejection
- SOS functionality
- In-app support chat

### Dependencies
- #1643 — Driver queries onboarding status
- #1644 — Driver is blocked from going online until approved

---

## [Mobile] #1577 — Driver receives push on application decision
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to receive a push notification when my application is approved or rejected so that I am immediately informed of the decision without having to open the app repeatedly.

### Background
When an admin approves or rejects a driver's application in the admin portal, the platform dispatches a push notification to that driver's device. The notification payload and deep link differ based on the decision. Approved drivers are taken to the driver home screen on tap; rejected drivers are taken to the pending/rejection screen where the reason is visible. Push delivery depends on the driver having granted notification permission.

### Acceptance Criteria

**Scenario 1 — Approved: notification received and tapped**
- Given the admin has approved the driver's application (#1659)
- Then the driver receives a push notification: "Congratulations! Your application has been approved. You can now go online."
- When the driver taps the notification
- Then the app opens and routes her to the driver home screen (#1578)

**Scenario 2 — Rejected: notification received and tapped**
- Given the admin has rejected the driver's application with a reason (#1660)
- Then the driver receives a push notification: "Your application was not approved. Reason: [admin reason]."
- When the driver taps the notification
- Then the app opens and routes her to the rejection notice screen, where the full reason is visible

**Scenario 3 — Notification permission not granted**
- Given the driver has not granted push notification permission
- When an application decision is made
- Then no push notification is delivered to the device
- But the decision is still reflected when the driver opens the app and the status check (#1643) runs

**Scenario 4 — App is foregrounded when notification arrives**
- Given the driver's app is open in the foreground
- When a decision push arrives
- Then the app displays an in-app banner or toast with the decision message
- And updates the current screen to reflect the new status without requiring a tap

### Out of Scope
- Email or SMS notification of application decision
- SOS push notifications
- Notification preference settings

### Dependencies
- #1618 — Push notification service integration
- #1659 — Admin approves driver application
- #1660 — Admin rejects driver application with reason

---

## [API] #1642 — Driver submits onboarding application
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the driver app, I want to submit a complete onboarding application so that SheDrive can review the driver's details and make an approval decision.

### Background
This authenticated endpoint accepts the full onboarding payload as a multipart form submission, including personal details, vehicle details, and four document files plus the vehicle photo. It creates a new application record with status = pending and associates it with the authenticated driver account. Only one application per driver is supported; a second submission returns a conflict error. The endpoint is the gateway for all downstream admin review flows.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| name | Yes | Free text | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | Return validation error | Return validation error | Return validation error |
| dob | Yes | DD/MM/YYYY, age ≥ 21 | — | — | Digits and "/" | Return validation error | Return validation error | — |
| nid | Yes | 14-digit numeric | 14 digits | 14 digits | Digits only | Return validation error | Return validation error | Return validation error |
| vehicle_make | Yes | Free text | 2 chars | 30 chars | Letters, spaces | Return validation error | — | Return validation error |
| vehicle_model | Yes | Free text | 2 chars | 30 chars | Letters, spaces, digits | Return validation error | — | Return validation error |
| vehicle_year | Yes | 4-digit year 2010–current | — | — | Digits only | Return validation error | Return validation error | — |
| vehicle_plate | Yes | Egyptian plate format | 2 chars | 8 chars | Letters, digits | Return validation error | Return validation error | Return validation error |
| vehicle_color | Yes | Non-empty string from allowed list | — | — | — | Return validation error | Return validation error | — |
| vehicle_type | Yes | One of: Sedan, SUV, Minivan | — | — | — | Return validation error | Return validation error | — |
| vehicle_photo | Yes | JPEG, PNG, or HEIC | — | 10 MB | — | Return validation error | Return validation error | Return validation error |
| licence_front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error | Return validation error | Return validation error |
| licence_back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error | Return validation error | Return validation error |
| registration_front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error | Return validation error | Return validation error |
| registration_back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error | Return validation error | Return validation error |

### Acceptance Criteria

**Scenario 1 — Happy path: valid application created**
- Given an authenticated driver with no existing application
- When she submits a complete, valid multipart payload
- Then the server creates an application record with status = pending
- And returns HTTP 201 with the application ID and status

**Scenario 2 — Validation error on one or more fields**
- Given an authenticated driver submits a payload with one or more invalid fields
- Then the server returns HTTP 422
- And the response body lists each failing field with a machine-readable error code

**Scenario 3 — Duplicate submission (application already exists)**
- Given a driver who has already submitted an application
- When she attempts to submit again
- Then the server returns HTTP 409 (Conflict)
- And the response indicates that an application already exists for this account

**Scenario 4 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401
- And no application record is created

**Scenario 5 — File too large**
- Given the driver submits a file exceeding 10 MB for any document field
- Then the server returns HTTP 422 with an error identifying the offending field

### Out of Scope
- Application re-submission after rejection
- Admin actions (handled in #1659, #1660)
- Push notification dispatch (handled in #1618)

### Dependencies
- #1619 — Session token validation

---

## [API] #1643 — Driver queries onboarding status
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the driver app, I want to query my onboarding application status so that I can route the driver to the correct screen (pending, approved, or rejected) on every app open.

### Background
This authenticated, read-only endpoint is called by the driver app on login and periodically while the driver is on the pending screen. It returns the current application status for the authenticated driver: pending, approved, or rejected. If the status is rejected, the response also includes the rejection reason text entered by the admin. No request body is required.

### Acceptance Criteria

**Scenario 1 — Happy path: status is pending**
- Given an authenticated driver whose application status is pending
- When the app calls this endpoint
- Then the server returns HTTP 200 with status = "pending"

**Scenario 2 — Happy path: status is approved**
- Given an authenticated driver whose application has been approved
- When the app calls this endpoint
- Then the server returns HTTP 200 with status = "approved"

**Scenario 3 — Happy path: status is rejected**
- Given an authenticated driver whose application has been rejected
- When the app calls this endpoint
- Then the server returns HTTP 200 with status = "rejected" and the rejection reason text

**Scenario 4 — No application exists**
- Given an authenticated driver who has not yet submitted an application
- When the app calls this endpoint
- Then the server returns HTTP 404 or an appropriate not-found status

**Scenario 5 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401

### Out of Scope
- Polling interval management (handled client-side)
- Application re-submission

### Dependencies
- #1619 — Session token validation

---

## [API] #1644 — Driver is blocked from going online until approved
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the SheDrive platform, I want to reject any attempt by a non-approved driver to set her status to online so that only verified drivers can receive trip requests.

### Background
This guard is enforced by the availability endpoint (#1645). When a driver attempts to set her availability to online, the platform first checks her application status via the data written by #1643. Drivers with status = pending or rejected are refused. Only drivers with status = approved may go online. This rule is enforced server-side and cannot be bypassed by the client.

### Acceptance Criteria

**Scenario 1 — Pending driver attempts to go online**
- Given an authenticated driver whose application status is pending
- When she sends a request to go online (#1645)
- Then the server returns HTTP 403
- And the response body indicates the reason: application not yet approved

**Scenario 2 — Rejected driver attempts to go online**
- Given an authenticated driver whose application status is rejected
- When she sends a request to go online (#1645)
- Then the server returns HTTP 403
- And the response body indicates the reason: application was not approved

**Scenario 3 — Approved driver can go online**
- Given an authenticated driver whose application status is approved
- When she sends a request to go online (#1645)
- Then the request is not blocked by this guard
- And the availability endpoint processes it normally

**Scenario 4 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401

### Out of Scope
- Re-submission flow after rejection
- Application review workflow

### Dependencies
- #1619 — Session token validation
- #1643 — Driver queries onboarding status

---

## [Admin] #1657 — Admin views pending applications queue
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to see a list of all driver applications with status = pending so that I can efficiently review and process them in order.

### Background
The pending applications queue is a screen in the admin portal listing all driver applications awaiting review. Each row shows the driver's full name, phone number, submission date, and a link to view the full application. The list is sorted by submission date (oldest first) by default. Admins can search by driver name or phone and filter by submission date range. The screen is accessible only to authenticated admins.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | — | 100 chars | Any | — | — | — |
| Date range — from | No | DD/MM/YYYY | — | — | Digits and "/" | — | Show inline error: "صيغة التاريخ غير صحيحة" | — |
| Date range — to | No | DD/MM/YYYY; must not be before from-date | — | — | Digits and "/" | — | Show inline error: "تاريخ النهاية يجب أن يكون بعد تاريخ البداية" | — |

### Acceptance Criteria

**Scenario 1 — Queue has pending applications**
- Given there are one or more driver applications with status = pending
- When the admin navigates to the pending queue
- Then each application row shows driver full name, phone number, and submission date
- And each row has a link to view the full application (#1658)
- And the list is sorted by submission date, oldest first

**Scenario 2 — Empty state**
- Given there are no pending applications
- When the admin navigates to the pending queue
- Then an empty-state message is displayed (e.g., "لا توجد طلبات قيد المراجعة")
- And no table rows are shown

**Scenario 3 — Search by name**
- Given the admin types a driver name in the search field
- When results update
- Then only applications whose driver name contains the search term are shown

**Scenario 4 — Search by phone**
- Given the admin types a phone number in the search field
- When results update
- Then only applications whose driver phone number matches are shown

**Scenario 5 — Date range filter applied**
- Given the admin sets a valid from-date and to-date
- When the filter is applied
- Then only applications submitted within that date range are shown

**Scenario 6 — Invalid to-date (before from-date)**
- Given the admin sets a to-date that is earlier than the from-date
- Then an inline error is shown: "تاريخ النهاية يجب أن يكون بعد تاريخ البداية"
- And the filter is not applied

### Out of Scope
- Bulk approval or rejection
- Approved or rejected application queues (separate screens)
- Exporting the list to CSV

### Dependencies
- #1642 — Driver submits onboarding application (source of pending records)

---

## [Admin] #1658 — Admin views full driver application
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to view all submitted details for a single driver application so that I can make an informed approval or rejection decision.

### Background
The full application detail screen is accessed by clicking a row in the pending queue (#1657) or from a driver's profile. It displays personal details (name, date of birth, NID), vehicle details (make, model, year, plate, color, type), all four uploaded documents (viewable inline as images or PDF previews), and the vehicle photo. Approve and Reject action buttons are shown at the bottom of the screen. The screen is accessible only to authenticated admins.

### Acceptance Criteria

**Scenario 1 — Happy path: full application displayed**
- Given the admin clicks on a pending application from the queue
- When the detail screen loads
- Then all personal details (name, DOB, NID) are displayed
- And all vehicle details (make, model, year, plate, color, type) are displayed
- And all four documents are viewable inline (images rendered, PDFs shown as previews)
- And the vehicle photo is rendered inline
- And Approve and Reject buttons are visible

**Scenario 2 — Inline document viewing**
- Given the admin is on the application detail screen
- When she clicks on a document thumbnail
- Then the document is displayed in a larger view or lightbox for easy reading

**Scenario 3 — Application not found**
- Given an admin navigates to a detail URL for an application that no longer exists or has been deleted
- Then the screen shows a not-found message and a back link to the queue

### Out of Scope
- Editing driver-submitted data on behalf of the driver
- Downloading documents to the local machine
- Application re-submission flow

### Dependencies
- #1642 — Driver submits onboarding application (source of application data)

---

## [Admin] #1659 — Admin approves driver application
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to approve a driver application so that the driver is immediately notified and can begin going online to receive trips.

### Background
The Approve action is triggered from the full application detail screen (#1658). The admin clicks "Approve," a confirmation dialog is shown, and upon confirmation the system changes the application status to approved. A push notification is sent to the driver via the push service (#1618). Once approved, the driver's account is eligible to go online, and her record appears in the active drivers list. The approval action is irreversible in these sprints.

### Acceptance Criteria

**Scenario 1 — Happy path: application approved**
- Given the admin is viewing a pending application (#1658)
- When she clicks "Approve" and confirms in the dialog
- Then the application status changes to "approved"
- And a push notification is dispatched to the driver: "Congratulations! Your application has been approved. You can now go online."
- And the application is removed from the pending queue (#1657)
- And the admin sees a success confirmation on screen

**Scenario 2 — Accidental click: admin cancels confirmation**
- Given the admin clicks "Approve"
- When the confirmation dialog appears and the admin clicks "Cancel"
- Then no status change occurs
- And the admin remains on the application detail screen

**Scenario 3 — Push notification fails to deliver**
- Given the admin approves an application but the push service is unavailable
- Then the application status is still changed to "approved"
- And the admin sees a warning that the push notification could not be sent
- And the driver will see the approval on next app open via the status check (#1643)

### Out of Scope
- Reversing an approval decision
- Re-approval after a previous rejection

### Dependencies
- #1618 — Push notification service integration
- #1658 — Admin views full driver application

---

## [Admin] #1660 — Admin rejects driver application with reason
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to reject a driver application with a mandatory written reason so that the driver is clearly informed of why her application was declined.

### Background
The Reject action is triggered from the full application detail screen (#1658). The admin clicks "Reject," enters a mandatory rejection reason in a text area, and confirms. The application status changes to rejected and the reason text is stored. A push notification including the reason is sent to the driver. Rejected drivers cannot go online and cannot resubmit in these sprints.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Rejection reason | Yes | Free text | 10 chars | 500 chars | Any | يرجى إدخال سبب الرفض | — | الرجاء توضيح سبب الرفض بشكل أكثر تفصيلاً |

### Acceptance Criteria

**Scenario 1 — Happy path: application rejected with reason**
- Given the admin is viewing a pending application (#1658)
- When she clicks "Reject," enters a valid reason (10–500 chars), and confirms
- Then the application status changes to "rejected"
- And the rejection reason is stored against the application record
- And a push notification is dispatched: "Your application was not approved. Reason: [reason text]."
- And the application is removed from the pending queue (#1657)
- And the admin sees a success confirmation on screen

**Scenario 2 — Empty rejection reason**
- Given the admin clicks "Reject" and leaves the reason field blank
- When she clicks "Confirm"
- Then the field shows "يرجى إدخال سبب الرفض"
- And no status change or push notification is sent

**Scenario 3 — Rejection reason too short**
- Given the admin enters fewer than 10 characters in the reason field
- When she clicks "Confirm"
- Then the field shows "الرجاء توضيح سبب الرفض بشكل أكثر تفصيلاً"

**Scenario 4 — Admin cancels the rejection dialog**
- Given the admin clicks "Reject" and opens the reason dialog
- When she clicks "Cancel" without confirming
- Then no status change occurs
- And the admin remains on the application detail screen

**Scenario 5 — Push notification fails to deliver**
- Given the admin rejects with a valid reason but the push service is unavailable
- Then the application status is still changed to "rejected" with the reason saved
- And the admin sees a warning that the push notification could not be sent

### Out of Scope
- Driver re-submission after rejection
- Admin editing a rejection reason after it has been submitted

### Dependencies
- #1618 — Push notification service integration
- #1658 — Admin views full driver application

---

## [Mobile] #1578 — Driver sees home screen with map
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a driver, I want to see a map centered on my current GPS location on my home screen so that I can orient myself and manage my availability.

### Background
The driver home screen is the main screen for approved drivers after login. It displays a full-screen map (Cairo/Giza area) centered on the driver's current GPS location. An online/offline toggle button is prominently displayed. While offline, the driver's location is not streamed and no trip requests are received. GPS permission is required to center the map; if denied, the map defaults to a central Cairo view with a prompt to enable location. The screen is accessible only to drivers with application status = approved.

### Acceptance Criteria

**Scenario 1 — Happy path: GPS available, map centered on driver**
- Given an approved driver opens the app and GPS permission is granted
- When the home screen loads
- Then a full-screen map is displayed centered on her current GPS coordinates
- And an online/offline toggle button is visible in a prominent position
- And the toggle defaults to the "offline" state

**Scenario 2 — GPS permission denied**
- Given the driver has not granted GPS permission
- When the home screen loads
- Then the map defaults to a central Cairo view
- And a prompt is shown asking the driver to enable location services
- And a link to device settings is provided

**Scenario 3 — Non-approved driver cannot reach home screen**
- Given a driver whose application status is pending or rejected
- When she attempts to navigate to the home screen
- Then she is redirected to the pending/rejection screen (#1576)

### Out of Scope
- Trip request handling (separate stories)
- SOS functionality
- In-app navigation or turn-by-turn directions

### Dependencies
- #1645 — Driver sets availability status
- #1646 — Driver updates GPS location

---

## [Mobile] #1579 — Driver toggles online and offline
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a driver, I want to toggle my availability between online and offline so that I can control when I receive trip requests.

### Background
The online/offline toggle is located on the driver home screen (#1578). When going online, the app requests GPS permission (if not already granted), starts streaming location to the server every 5 seconds (#1580), and calls the availability API (#1645) to register the driver as available. When going offline, location streaming stops and availability is set to offline. The toggle reflects the current confirmed server state, not just a local UI change.

### Acceptance Criteria

**Scenario 1 — Happy path: driver goes online**
- Given an approved driver is on the home screen with GPS permission granted
- When she taps the toggle to go online
- Then the app calls #1645 to set status = online
- And on success, the toggle visually changes to the "online" state
- And location streaming begins (every 5 seconds, #1580)

**Scenario 2 — Happy path: driver goes offline**
- Given the driver is currently online
- When she taps the toggle to go offline
- Then the app calls #1645 to set status = offline
- And on success, the toggle changes to the "offline" state
- And location streaming stops

**Scenario 3 — GPS permission denied when attempting to go online**
- Given the driver taps the toggle to go online but GPS permission is denied
- Then the app displays an explanation of why GPS is required
- And shows a link to device settings to grant permission
- And the toggle remains in the "offline" state

**Scenario 4 — Network error when setting status**
- Given the driver taps the toggle
- When the network request to #1645 fails
- Then an error toast is shown
- And the toggle reverts to its previous state
- And the driver's availability on the server is not changed

### Out of Scope
- Automatic offline when app is backgrounded (future sprint)
- SOS functionality
- Trip cancellation

### Dependencies
- #1645 — Driver sets availability status
- #1646 — Driver updates GPS location

---

## [Mobile] #1580 — Driver location updates while online
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a driver, I want my GPS location to be sent to the server automatically every 5 seconds while I am online so that riders and the platform can see my real-time position.

### Background
While the driver is online, the app runs a background location polling loop that reads the device GPS and calls #1646 every 5 seconds with the latest latitude and longitude. The driver's position dot on the map moves in real time. If the GPS signal is lost (accuracy too low or no fix), a warning is shown and the location update loop pauses. When the signal is restored, the loop resumes automatically without driver action. When the driver goes offline, the loop stops.

### Acceptance Criteria

**Scenario 1 — Happy path: location streaming while online**
- Given the driver is online with GPS signal available
- When 5 seconds have elapsed since the last update
- Then the app reads the current GPS coordinates and calls #1646
- And the driver's position dot on the map moves to the new location

**Scenario 2 — GPS signal lost**
- Given the driver is online and GPS signal is lost or accuracy degrades below threshold
- Then a warning is shown on screen (e.g., "تعذر تحديد موقعك")
- And the location update loop pauses (no calls to #1646)

**Scenario 3 — GPS signal restored**
- Given the location loop was paused due to signal loss
- When GPS signal is restored
- Then the warning is dismissed
- And the location update loop resumes automatically

**Scenario 4 — Driver goes offline, loop stops**
- Given the driver is online and streaming location
- When she goes offline (#1579)
- Then the location update loop stops immediately
- And no further calls to #1646 are made

### Out of Scope
- Location history storage or replay
- Surge pricing based on driver density
- SOS location tracking

### Dependencies
- #1646 — Driver updates GPS location

---

## [API] #1645 — Driver sets availability status
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As the driver app, I want to set the driver's availability status to online or offline so that the platform knows whether to dispatch trip requests to her.

### Background
This authenticated endpoint is called when the driver toggles her availability from the home screen (#1579). It accepts the new status value and updates the driver's availability record. Before accepting an "online" request, the platform enforces the approval guard (#1644): non-approved drivers are refused. When set to online, the driver becomes eligible for trip matching. When set to offline, the platform will not dispatch new trip requests to her.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| status | Yes | Enum | — | — | "online" or "offline" | Return validation error | Return validation error | — |

### Acceptance Criteria

**Scenario 1 — Happy path: approved driver goes online**
- Given an authenticated driver with application status = approved
- When she sends status = "online"
- Then the server updates her availability to online
- And returns HTTP 200 with the new status

**Scenario 2 — Happy path: driver goes offline**
- Given an authenticated driver who is currently online
- When she sends status = "offline"
- Then the server updates her availability to offline
- And returns HTTP 200 with the new status

**Scenario 3 — Non-approved driver attempts to go online**
- Given an authenticated driver whose application status is not approved
- When she sends status = "online"
- Then the server returns HTTP 403 (per #1644)

**Scenario 4 — Invalid status value**
- Given an authenticated driver sends a status value other than "online" or "offline"
- Then the server returns HTTP 422 with a validation error

**Scenario 5 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401

### Out of Scope
- Automatic offline on app close (future sprint)
- Status history or audit log

### Dependencies
- #1619 — Session token validation
- #1644 — Driver is blocked from going online until approved

---

## [API] #1646 — Driver updates GPS location
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As the driver app, I want to push the driver's current GPS coordinates to the server every 5 seconds while online so that the platform can use live location for matching and map display.

### Background
This authenticated endpoint is called by the driver app's location polling loop (#1580) every 5 seconds while the driver is online. It accepts latitude and longitude and updates the driver's live position record. This position is used by the matching engine to find nearby drivers and by the admin live map to display driver positions. The endpoint should be lightweight and respond quickly to support high-frequency calls.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| latitude | Yes | Decimal number | −90 | 90 | Digits, ".", "-" | Return validation error | Return validation error | — |
| longitude | Yes | Decimal number | −180 | 180 | Digits, ".", "-" | Return validation error | Return validation error | — |

### Acceptance Criteria

**Scenario 1 — Happy path: valid coordinates accepted**
- Given an authenticated, online driver
- When she sends valid latitude (−90 to 90) and longitude (−180 to 180)
- Then the server updates her live position record
- And returns HTTP 200

**Scenario 2 — Missing latitude or longitude**
- Given the driver sends a request missing latitude or longitude
- Then the server returns HTTP 422 with a validation error identifying the missing field

**Scenario 3 — Out-of-range coordinate**
- Given the driver sends a latitude > 90 or < −90, or a longitude > 180 or < −180
- Then the server returns HTTP 422 with a validation error

**Scenario 4 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401

### Out of Scope
- Location history storage beyond the current live position
- Geofencing or zone-based alerts

### Dependencies
- #1619 — Session token validation

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

## [API] #1626 — Address autocomplete returns suggestions
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the rider app, I want to retrieve address autocomplete suggestions as the rider types so that she can quickly find and select a pickup or destination without typing full addresses.

### Background
This authenticated endpoint is called by the rider app as the user types in the pickup or destination field, once 2 or more characters have been entered. It proxies the query to the Google Maps Places Autocomplete API with results biased to the Cairo/Giza area. The response contains a list of up to 5 address suggestions, each with a primary place name, secondary text (area/city), and a place ID for downstream use in fare estimation. Queries shorter than 2 characters return an empty list rather than an error.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| q (query) | Yes | Free text | 2 chars (return empty below this) | 200 chars | Arabic and Latin text | Return empty list | — | Return validation error if > 200 chars |

### Acceptance Criteria

**Scenario 1 — Happy path: query returns suggestions**
- Given an authenticated rider sends a query of 2 or more characters
- When Google Maps Places Autocomplete returns results
- Then the endpoint returns HTTP 200 with a list of up to 5 suggestions
- And each suggestion contains place name, secondary text, and place ID
- And results are geographically biased to Cairo/Giza

**Scenario 2 — Query shorter than 2 characters**
- Given an authenticated rider sends a query of fewer than 2 characters
- Then the endpoint returns HTTP 200 with an empty suggestions list
- And no Google Maps API call is made

**Scenario 3 — No matching results from Google**
- Given an authenticated rider sends a valid query but Google returns no matches
- Then the endpoint returns HTTP 200 with an empty suggestions list

**Scenario 4 — Google Maps API error**
- Given the Google Maps Places API is unavailable or returns an error
- Then the endpoint returns HTTP 502 or an appropriate upstream error code
- And the response body indicates a temporary upstream failure

**Scenario 5 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401

### Out of Scope
- Caching of autocomplete results
- Address validation or verification beyond what Google provides
- Saving addresses to rider history

### Dependencies
- #1619 — Session token validation
- #1617 — Google Maps API key configuration

---

## [API] #1627 — Fare estimate uses Google Maps route data
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the rider app, I want to retrieve a fare estimate for a given pickup and destination so that the rider sees an informed price before confirming her booking.

### Background
This authenticated endpoint is called by the rider app once both pickup and destination are set. It calls the Google Maps Distance Matrix API to obtain the route distance (in km) and estimated duration (in minutes) between the two points. It then passes these values to the internal fare calculation logic (#1628) and returns the calculated fare, distance, and duration to the client. The pickup and destination can be specified as lat/lng coordinates or as Google Places IDs from the autocomplete response (#1626). Identical pickup and destination is rejected with a validation error.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| pickup | Yes | Object with lat+lng or place_id | — | — | — | Return validation error | Return validation error | — |
| destination | Yes | Object with lat+lng or place_id | — | — | — | Return validation error | Return validation error | — |

### Acceptance Criteria

**Scenario 1 — Happy path: valid fare estimate returned**
- Given an authenticated rider sends valid pickup and destination
- When Google Distance Matrix returns distance and duration
- Then #1628 calculates the fare
- And the endpoint returns HTTP 200 with estimated fare, distance (km), and duration (minutes)

**Scenario 2 — Missing pickup or destination**
- Given either pickup or destination is absent from the request
- Then the server returns HTTP 422 with a validation error identifying the missing field

**Scenario 3 — Pickup and destination are the same location**
- Given the pickup and destination resolve to the same geographic point
- Then the server returns HTTP 422 with the error: same pickup and destination

**Scenario 4 — Google Distance Matrix API error**
- Given the Google Distance Matrix API is unavailable or returns an error
- Then the endpoint returns HTTP 502
- And the response body indicates a temporary upstream failure

**Scenario 5 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- When the endpoint is called
- Then the server returns HTTP 401

### Out of Scope
- Fare locking or guarantee after estimate is shown
- Surge pricing multipliers
- Multi-stop routing

### Dependencies
- #1619 — Session token validation
- #1617 — Google Maps API key configuration
- #1628 — Fare applies base, per-km, and per-minute rates

---

## [API] #1628 — Fare applies base, per-km, and per-minute rates
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the SheDrive platform, I want a configurable fare calculation function so that trip fares are computed consistently from distance and duration data across all fare-related flows.

### Background
This is an internal fare calculation module (not a directly callable external endpoint) used by #1627 (fare estimate) and the trip completion fare finalization (#1636). The formula is: Fare = base_fare + (distance_km × rate_per_km) + (duration_min × rate_per_min). All three rates (base fare, per-km rate, per-minute rate) are stored in a configurable settings table and can be updated by an admin without a code deployment. The function takes distance and duration as inputs and returns a numeric fare value. Output is in Egyptian Pounds (EGP).

### Acceptance Criteria

**Scenario 1 — Happy path: fare calculated correctly**
- Given base_fare = 10 EGP, rate_per_km = 5 EGP, rate_per_min = 0.5 EGP
- When a trip has distance = 8 km and duration = 20 minutes
- Then the calculated fare = 10 + (8 × 5) + (20 × 0.5) = 60 EGP
- And the function returns 60

**Scenario 2 — Rates are configurable without code change**
- Given an admin updates the rate_per_km value in the settings table
- When the next fare calculation runs
- Then the new rate is used without requiring a code deployment

**Scenario 3 — Zero distance or duration (edge case)**
- Given distance = 0 km and duration = 0 minutes
- Then the fare equals the base_fare only
- And no division-by-zero or error occurs

**Scenario 4 — Fare used consistently in estimate and completion**
- Given the same distance and duration values are passed during fare estimate (#1627) and trip completion (#1636)
- Then the calculated fare is identical in both contexts

### Out of Scope
- Surge pricing or dynamic rate multipliers
- Discount codes or promotions
- Per-vehicle-type rate differentiation (future sprint)
- VAT or tax calculation

### Dependencies
- None (internal calculation module)

---

# SheDrive — User Stories Part 3
## Features 8–9: Trip Request & Matching · Driver Trip Acceptance
**Sprint:** 2

---

## [Mobile] #1553 — Rider submits trip request
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to submit a trip request from the home screen so that I can be matched with a nearby driver.

### Background
The rider has already set her pickup location and destination on the home screen and has seen the fare estimate. When she taps "Request Ride," the app sends her trip request to the platform and navigates her to the matching screen. The home screen inputs are not re-validated here — all validation occurred before the estimate was shown. The rider should experience a near-instant transition with no loading friction.

### Field Validation
No input fields on this screen — pickup and destination were captured on the home screen.

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
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a "Finding your driver" screen after submitting my request so that I know the system is actively searching on my behalf.

### Background
After the trip request is created, the rider is taken to the matching screen where the platform searches for a nearby driver. The screen provides animated visual feedback to reassure the rider that the search is in progress. The app polls the match-status endpoint periodically. A cancel button is visible on screen but is non-functional in this sprint (marked as "coming soon" or disabled). When a match is found, the screen transitions to the driver card view (#1555). If no match is found within the matching window, the rider sees the no-driver error screen (#1557).

### Field Validation
No input fields on this screen.

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
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see my matched driver's details after a driver accepts my request so that I know who is coming to pick me up and when to expect them.

### Background
When a driver accepts the trip, the matching screen transitions to display a driver card. The rider sees the driver's name, photo or placeholder avatar, vehicle information (make, model, color, and plate number), star rating, and the estimated arrival time at the pickup location. A map view shows a pin at the driver's current location so the rider can track the driver approaching in real time. This screen marks the start of the active trip flow.

### Field Validation
No input fields on this screen.

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

## [Mobile] #1556 — Rider receives push on match confirmation
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when a driver is matched to my request so that I am informed even if the app is running in the background.

### Background
After a driver accepts the trip, the platform sends a push notification to the rider's device. The notification content is: "Driver found! [Driver name] is on the way." If the rider taps the notification while the app is in the background or closed, the app opens directly to the active trip screen. If the app is already in the foreground, the notification is handled silently and the UI transitions automatically without showing an OS-level banner.

### Field Validation
No input fields on this screen.

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

### Out of Scope
- Push notification settings management
- SMS fallback for push delivery failures
- In-app notification inbox

### Dependencies
- #1618 — Push notification service integration (must be live)
- #1634 — Match confirmation push trigger (API — must be live)

---

## [Mobile] #1557 — Rider sees no-driver error and returns home
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As a rider, I want to see a clear message when no driver is available so that I understand what happened and can easily try again.

### Background
If all dispatched drivers reject the trip or their acceptance windows expire, or if no online drivers are within range when the request is submitted, the platform marks the trip as expired and notifies the rider. The rider is shown a full-screen or prominent error state with a human-friendly message and a single call-to-action to return to the home screen and resubmit. The rider should not feel abandoned — the screen must convey that the situation is temporary.

### Field Validation
No input fields on this screen.

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

## [API] #1629 — Rider creates trip request
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the rider app, I want to submit a trip request with pickup and destination coordinates so that the platform can create a trip record and begin the matching process.

### Background
This is the authenticated endpoint called when a rider taps "Request Ride." The platform receives pickup and destination locations, validates that they are distinct and within the supported service area, creates a trip record with status = "searching," and immediately triggers the internal matching process (#1630). The endpoint returns a trip ID that the rider app uses to poll for match status (#1631). Only riders with an active session may call this endpoint.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| pickup | Yes | Object: lat/lng pair or place_id string | — | — | Numeric coordinates or alphanumeric place ID | "Pickup location is required" | "Invalid pickup location format" | — |
| pickup.lat | Conditional (if no place_id) | Decimal number | -90 | 90 | Digits, decimal point, optional leading minus | "Pickup latitude is required" | "Pickup latitude must be a number between -90 and 90" | — |
| pickup.lng | Conditional (if no place_id) | Decimal number | -180 | 180 | Digits, decimal point, optional leading minus | "Pickup longitude is required" | "Pickup longitude must be a number between -180 and 180" | — |
| destination | Yes | Object: lat/lng pair or place_id string | — | — | Numeric coordinates or alphanumeric place ID | "Destination is required" | "Invalid destination location format" | — |
| destination.lat | Conditional (if no place_id) | Decimal number | -90 | 90 | Digits, decimal point, optional leading minus | "Destination latitude is required" | "Destination latitude must be a number between -90 and 90" | — |
| destination.lng | Conditional (if no place_id) | Decimal number | -180 | 180 | Digits, decimal point, optional leading minus | "Destination longitude is required" | "Destination longitude must be a number between -180 and 180" | — |

### Acceptance Criteria

**Scenario 1 — Successful trip request creation**
- Given an authenticated rider submits a valid pickup and destination that are distinct locations
- When the endpoint is called
- Then a trip record is created with status = "searching"
- And the matching process (#1630) is triggered
- And the response includes the new trip ID

**Scenario 2 — Pickup equals destination**
- Given an authenticated rider submits a pickup location identical to the destination
- When the endpoint is called
- Then a validation error is returned: "Pickup and destination must be different locations"
- And no trip record is created

**Scenario 3 — Pickup field is missing**
- Given an authenticated rider submits a request with no pickup location
- When the endpoint is called
- Then a validation error is returned: "Pickup location is required"

**Scenario 4 — Destination field is missing**
- Given an authenticated rider submits a request with no destination
- When the endpoint is called
- Then a validation error is returned: "Destination is required"

**Scenario 5 — Invalid coordinate format**
- Given an authenticated rider submits coordinates outside the valid range (e.g., lat = 999)
- When the endpoint is called
- Then a validation error is returned indicating the invalid field and its constraint

**Scenario 6 — Unauthenticated request**
- Given a request is made without a valid session token
- When the endpoint is called
- Then the request is rejected with an authentication error
- And no trip record is created

**Scenario 7 — Rider already has an active trip**
- Given a rider already has a trip in "searching" or "matched" status
- When she attempts to create another trip request
- Then a conflict error is returned: "You already have an active trip request"

### Out of Scope
- Fare estimation (handled before request submission)
- Scheduled trips
- Multiple destinations
- Promo code processing

### Dependencies
- #1619 — Session validation (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1630 — System matches request to nearest available driver
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically match a new trip request to the nearest online, available driver so that the rider is connected to a driver as quickly as possible.

### Background
This is an internal platform orchestration process triggered immediately after a trip request is created (#1629). It is not called directly by any client app. The process queries for online, approved drivers who do not have an active trip, ranks them by distance to the rider's pickup location, and dispatches the trip to the nearest driver via #1647. If no eligible drivers are found, the trip is immediately marked as expired and the rider is notified (#1632). If a driver rejects or times out, the process continues to the next nearest driver via #1651.

### Field Validation
No direct input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Nearest driver found and dispatched**
- Given a trip request enters "searching" status
- When the matching process runs
- Then the nearest online, approved driver without an active trip is identified
- And the trip request is dispatched to that driver (#1647)
- And the trip record is updated to reflect the driver currently being evaluated

**Scenario 2 — No eligible drivers available**
- Given a trip request enters "searching" status
- When no online, approved, available drivers exist within the service area
- Then the trip is marked as expired immediately
- And the rider is notified via push that no driver was found (#1632)

**Scenario 3 — Driver rejects or times out — next driver tried**
- Given a trip has been dispatched to a driver
- When that driver rejects or the 10-second window expires (#1651)
- Then the matching process selects the next nearest eligible driver
- And dispatches the trip to that driver

**Scenario 4 — All drivers exhaust without acceptance**
- Given the trip has been dispatched to all eligible drivers in sequence
- When every driver has rejected or timed out
- Then the trip is marked as expired
- And the rider is notified via push (#1632)

### Out of Scope
- Driver preference filters (gender, vehicle type)
- Surge pricing
- Batch matching for multiple simultaneous requests
- SOS trip prioritization

### Dependencies
- #1619 — Session validation (must be live)
- #1645 — Driver online status and location tracking (must be live)
- #1647 — System pushes trip request to matched driver (must be live)
- #1632 — Trip expires and rider is notified via push (must be live)

---

## [API] #1631 — Rider polls for match status
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the rider app, I want to poll the platform for the current match status of my trip request so that the UI can transition from "searching" to the driver card when a match is confirmed.

### Background
After creating a trip request, the rider app calls this endpoint periodically (e.g., every 2–3 seconds) to check whether a driver has been matched. The endpoint returns the current trip status: searching, matched, or no_driver. When the status is matched, the response also includes the driver's name, vehicle details, star rating, and ETA to the pickup location, as well as the driver's live location for the map pin. When the status is no_driver, the app navigates the rider to the error screen. This endpoint is authenticated and scoped to the requesting rider's own trip.

### Field Validation
No input fields — the trip ID is derived from the rider's active session or passed as a path parameter.

### Acceptance Criteria

**Scenario 1 — Trip is still searching**
- Given an authenticated rider polls for match status
- When the trip is still in "searching" status
- Then the response returns status = searching
- And no driver details are included

**Scenario 2 — Trip is matched**
- Given an authenticated rider polls for match status
- When a driver has accepted the trip
- Then the response returns status = matched
- And the response includes: driver name, driver photo URL (or null), vehicle make, model, color, plate number, star rating, ETA to pickup, and driver's current lat/lng

**Scenario 3 — Trip has expired (no driver found)**
- Given an authenticated rider polls for match status
- When the trip has been marked as expired
- Then the response returns status = no_driver
- And the rider app navigates to the no-driver error screen

**Scenario 4 — Trip not found**
- Given an authenticated rider polls with a trip ID that does not exist or belongs to another rider
- When the endpoint is called
- Then a not-found error is returned

**Scenario 5 — Unauthenticated request**
- Given a request is made without a valid session token
- When the endpoint is called
- Then the request is rejected with an authentication error

### Out of Scope
- WebSocket or server-sent event streaming (polling only this sprint)
- Polling rate limiting (handled client-side)
- Historical trip status history

### Dependencies
- #1619 — Session validation (must be live)
- #1629 — Rider creates trip request (must be live)

---

## [API] #1632 — Trip expires and rider is notified via push
**Feature:** Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to mark a trip as expired and send a push notification to the rider when no driver accepts so that the rider is promptly informed and can choose to try again.

### Background
This is an internal platform process triggered by #1630 when the matching pool is exhausted — either no drivers were available at all, or all dispatched drivers rejected or timed out. The platform marks the trip record status as expired and sends a push notification to the rider's registered device: "We couldn't find a driver. Please try again." The rider app, on its next poll (#1631), will receive status = no_driver and display the error screen. The push notification provides immediate feedback even if the rider is not actively watching the app.

### Field Validation
No direct input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Trip marked as expired and push sent**
- Given the matching process has exhausted all eligible drivers
- When this process is triggered
- Then the trip record status is updated to expired
- And a push notification is sent to the rider's registered device
- And the push notification reads: "We couldn't find a driver. Please try again."

**Scenario 2 — Rider's device token is not registered**
- Given the rider's push notification token is not on file
- When the platform attempts to send the expiry push
- Then the push silently fails
- And the trip is still marked as expired
- And the rider will see the no-driver status on her next poll

**Scenario 3 — Trip already in a terminal status**
- Given a trip is already in matched or expired status
- When the expiry process is triggered (e.g., due to a race condition)
- Then the trip status is not overwritten
- And no duplicate push notification is sent

### Out of Scope
- Automatic re-queuing of the expired trip
- Rider compensation or credits for no-driver situations
- SMS fallback for push failures

### Dependencies
- #1619 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [Mobile] #1581 — Driver receives push for incoming trip request
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to receive a push notification when a new trip request is assigned to me so that I can respond within the acceptance window even if the app is in the background.

### Background
When the platform dispatches a trip to a matched driver (#1647), a push notification is sent to the driver's registered device. The notification displays the pickup area and estimated fare so the driver can make an informed decision before opening the app. Tapping the notification opens the trip request details screen (#1582) with the 10-second countdown already running. If the driver does not tap the notification in time, the countdown expires on the server side regardless, and the screen auto-dismisses if the driver opens the app late.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Push notification delivered while driver app is in background**
- Given the driver is online and her app is in the background
- When a trip is dispatched to her
- Then her device displays a push notification with the pickup area name and estimated fare
- And the notification title indicates an incoming trip request (e.g., "New trip request!")
- And tapping the notification opens the trip request details screen (#1582) with the countdown running

**Scenario 2 — Push notification delivered while driver app is in foreground**
- Given the driver's app is open and in the foreground
- When a trip is dispatched to her
- Then the app navigates automatically to the trip request details screen (#1582)
- And the countdown begins immediately
- And no duplicate OS banner is shown unnecessarily

**Scenario 3 — Driver app is fully closed**
- Given the driver's app is closed
- When a push notification arrives for an incoming trip
- Then the device displays the notification
- And tapping it launches the app and navigates to the trip request details screen (#1582)
- And if the 10-second window has already expired by the time the screen loads, the screen shows "Request expired" and the driver returns to her home screen

**Scenario 4 — Driver's device token is not registered**
- Given the driver's push notification token is not on file
- When the platform dispatches a trip to her
- Then the push silently fails
- And after the 10-second window elapses with no response, the system treats it as a timeout and reassigns the trip (#1651)

### Out of Scope
- In-app notification inbox
- SMS fallback for push failures
- Audio or vibration settings management

### Dependencies
- #1618 — Push notification service integration (must be live)
- #1647 — System pushes trip request to matched driver (API — must be live)

---

## [Mobile] #1582 — Driver sees trip request details
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to see full trip request details with a countdown timer so that I can decide to accept or reject within the 10-second window.

### Background
When a driver receives a trip request (via push notification or app foreground transition), she is shown a full-screen or modal trip request details screen. The screen displays the pickup address, destination summary, estimated distance, and estimated fare. A 10-second countdown timer is prominently visible and begins immediately when the screen loads. Two action buttons are shown: "Accept" and "Reject." If the timer reaches zero without action, the screen auto-dismisses, a brief "Request expired" message is shown, and the driver returns to her home/available screen. The system treats the non-response as a rejection and reassigns the trip.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Trip request details screen displays correctly**
- Given a trip has been dispatched to the driver
- When the trip request details screen loads
- Then the pickup address is displayed
- And the destination summary is displayed
- And the estimated distance is displayed
- And the estimated fare is displayed
- And a 10-second countdown timer is prominently shown
- And "Accept" and "Reject" buttons are both visible and tappable

**Scenario 2 — Countdown timer counts down visibly**
- Given the trip request details screen is open
- When time passes
- Then the countdown timer decrements visibly second by second
- And the timer urgency is communicated clearly (e.g., color change at 3 seconds)

**Scenario 3 — Timer expires without driver action**
- Given the driver does not tap Accept or Reject within 10 seconds
- When the countdown reaches zero
- Then the screen auto-dismisses
- And a brief "Request expired" toast or message is shown
- And the driver is returned to her home/available screen
- And the system treats the non-response as a rejection and reassigns (#1651)

**Scenario 4 — Driver is offline when screen loads**
- Given the driver's device loses connectivity while the request screen is open
- When the timer expires
- Then the screen dismisses locally
- And when connectivity is restored, the driver is on her home/available screen
- And the server has already reassigned the trip

### Out of Scope
- Driver chat or messaging before acceptance
- Viewing the rider's profile or rating before accepting
- Fare negotiation
- Trip cancellation after acceptance (separate feature)

### Dependencies
- #1648 — Driver retrieves pending trip request (API — must be live)

---

## [Mobile] #1583 — Driver accepts trip
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Accept" on the trip request screen so that the trip is confirmed and I can begin navigating to the rider's pickup location.

### Background
When the driver taps "Accept" within the 10-second window, the app calls the accept endpoint (#1649). On success, the trip status is updated to accepted, and the driver is taken to the navigation-to-pickup screen (active trip feature). Simultaneously, the rider receives a push confirmation that her driver is on the way (#1634). If the acceptance window has already expired server-side (e.g., due to network lag), the endpoint returns a conflict and the driver sees an expired message and returns to her home screen.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Successful acceptance within window**
- Given the driver taps "Accept" while the countdown is still running
- When the acceptance request reaches the server within the 10-second window
- Then the trip status is updated to accepted
- And the driver is navigated to the active trip / navigation-to-pickup screen
- And the rider receives a push notification confirming the match (#1634)

**Scenario 2 — Acceptance after server-side window expiry**
- Given the driver taps "Accept" but the server has already expired the window (network delay)
- When the endpoint returns a conflict error
- Then the driver sees a message: "This request has expired"
- And the driver is returned to her home/available screen
- And the system has already reassigned the trip

**Scenario 3 — Network error on acceptance**
- Given the driver taps "Accept"
- When the network request fails
- Then a toast is shown: "Network error. Your response was not recorded."
- And the driver remains on the request screen if time permits, or sees the expired message if the countdown has elapsed

**Scenario 4 — Accept button shows loading state**
- Given the driver taps "Accept"
- When the request is in flight
- Then the Accept button shows a loading indicator
- And both buttons are disabled to prevent double submission

### Out of Scope
- Driver navigation / GPS turn-by-turn (active trip feature)
- Calling the rider before pickup
- Rejecting after acceptance

### Dependencies
- #1649 — Driver accepts trip (API — must be live)

---

## [Mobile] #1584 — Driver rejects trip and returns to available
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Reject" on the trip request screen so that I can decline the trip and remain available for other requests.

### Background
A driver may choose to reject a trip request within the 10-second window. Tapping "Reject" calls the rejection endpoint (#1650), which marks the driver as available again and triggers reassignment of the trip to the next nearest driver (#1651). The driver returns to her home/available screen immediately. No penalty or strike is applied in this sprint. If the window has already expired server-side, the rejection call returns a conflict (the rejection is effectively a no-op since the system has already treated it as a timeout).

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Successful rejection within window**
- Given the driver taps "Reject" while the countdown is still running
- When the rejection request reaches the server within the 10-second window
- Then the trip is returned to the platform for reassignment
- And the driver's status is set back to available
- And the driver is returned to her home/available screen immediately

**Scenario 2 — Rejection after server-side window expiry**
- Given the driver taps "Reject" but the server has already expired the window
- When the endpoint returns a conflict error
- Then the driver sees a brief message: "This request has already expired"
- And the driver is returned to her home/available screen
- And no duplicate reassignment is triggered

**Scenario 3 — Network error on rejection**
- Given the driver taps "Reject"
- When the network request fails
- Then a toast is shown: "Network error. Please check your connection."
- And when the countdown expires, the system automatically treats the non-response as a rejection

**Scenario 4 — No penalty applied**
- Given the driver has rejected the trip
- When she is on her home/available screen
- Then her status remains "online" and available for future requests
- And no rejection penalty or notification is shown

### Out of Scope
- Rejection reason collection
- Rejection rate tracking or penalties (future sprint)
- Driver going offline after rejection

### Dependencies
- #1650 — Driver rejects trip (API — must be live)

---

## [Mobile] #1585 — Driver acceptance screen expires after 10 seconds
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want the acceptance screen to automatically dismiss after 10 seconds if I do not respond so that I am not left on a stale screen and the system can reassign the trip promptly.

### Background
If the driver neither accepts nor rejects within the 10-second window, the platform server-side timer expires and triggers reassignment (#1651). On the client side, the countdown UI reaches zero and automatically dismisses the screen. A brief "Request expired" toast or message is displayed so the driver understands what happened. The driver is returned to her home/available screen and remains online. This behavior mirrors a rejection from the platform's perspective.

### Field Validation
No input fields on this screen.

### Acceptance Criteria

**Scenario 1 — Screen auto-dismisses at countdown zero**
- Given the driver is on the trip request details screen and does not tap either button
- When the 10-second countdown reaches zero
- Then the screen automatically dismisses without requiring any driver action
- And a brief message is shown: "Request expired"
- And the driver is returned to her home/available screen

**Scenario 2 — Driver remains online after expiry**
- Given the acceptance screen has expired
- When the driver is back on her home/available screen
- Then her online status is preserved
- And she remains eligible for the next dispatched trip

**Scenario 3 — System reassigns the trip**
- Given the driver's 10-second window has expired
- When the server processes the timeout
- Then the trip is passed to the next nearest available driver (#1651)
- And the current driver is not double-dispatched for the same trip

**Scenario 4 — App in background during countdown**
- Given the driver received the push notification but did not open the app
- When 10 seconds elapse from dispatch
- Then the server-side timer expires and reassigns the trip
- And if the driver later opens the app, no acceptance screen is shown for the expired request
- And a brief "Request expired" message is shown if the screen was mid-open

### Out of Scope
- Configurable acceptance window duration
- Penalty or strike for timeout (future sprint)
- Notification to driver that she missed a request (beyond the brief toast)

### Dependencies
- #1651 — Trip is reassigned on rejection or timeout (API — must be live)

---

## [API] #1647 — System pushes trip request to matched driver
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the SheDrive platform, I want to push a trip request notification and pending record to the matched driver so that she can review the details and respond within the acceptance window.

### Background
This is an internal platform process triggered by the matching engine (#1630) after selecting the nearest eligible driver. The process creates a pending trip record for the driver (so she can retrieve details via #1648) and sends a push notification to her registered device with the pickup area and estimated fare. The 10-second server-side acceptance clock starts from the moment this notification is dispatched. The driver app uses the pending record to populate the trip request details screen (#1582).

### Field Validation
No direct client input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Pending trip record created and push sent**
- Given the matching engine has selected a driver
- When this process is triggered
- Then a pending trip record is created associating the driver with the trip
- And a push notification is sent to the driver's registered device
- And the notification includes the pickup area name and estimated fare
- And the server-side 10-second acceptance clock starts

**Scenario 2 — Driver's push token is not registered**
- Given the selected driver's push notification token is not on file
- When the process attempts to send the push
- Then the push silently fails
- And the pending trip record is still created
- And after 10 seconds with no acceptance, the trip is reassigned (#1651)

**Scenario 3 — Driver is no longer available at dispatch time**
- Given the selected driver went offline between matching selection and dispatch
- When this process checks her status at dispatch
- Then the dispatch is aborted for this driver
- And the matching engine is notified to select the next nearest driver

### Out of Scope
- Driver in-app messaging
- Driver acceptance confirmation (handled by #1649)
- Multiple simultaneous dispatch to several drivers

### Dependencies
- #1619 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1648 — Driver retrieves pending trip request
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the details of my pending trip request so that I can display the pickup address, destination, distance, and fare to the driver on the acceptance screen.

### Background
After the driver receives a push notification for an incoming trip, the driver app calls this endpoint to fetch the full trip request details. The endpoint returns the pickup address, destination summary, estimated distance, and estimated fare for the pending trip assigned to this driver. If the 10-second window has already expired (trip reassigned) before the driver's app calls this endpoint, a not-found or expired response is returned and the app shows the "Request expired" message. This endpoint is authenticated and returns only the trip pending for the calling driver.

### Field Validation
No input fields — the pending trip is identified by the authenticated driver's session.

### Acceptance Criteria

**Scenario 1 — Pending trip returned successfully**
- Given an authenticated driver has a pending trip dispatched to her
- When she calls this endpoint
- Then the response includes: pickup address, destination summary, estimated distance, estimated fare
- And the data is sufficient to populate the trip request details screen (#1582)

**Scenario 2 — No pending trip exists**
- Given an authenticated driver has no pending trip (none dispatched, or window already expired)
- When she calls this endpoint
- Then a not-found or "no pending trip" response is returned
- And the driver app shows the "Request expired" message and returns to the home screen

**Scenario 3 — Unauthenticated request**
- Given a request is made without a valid driver session token
- When the endpoint is called
- Then the request is rejected with an authentication error

**Scenario 4 — Trip was reassigned before retrieval**
- Given the 10-second window expired and the trip was reassigned before the driver's app called this endpoint
- When the endpoint is called
- Then an expired or not-found response is returned
- And no trip details are shown to the driver

### Out of Scope
- Rider profile details visible to driver before acceptance
- Destination full address (summary only for privacy at this stage)
- Historical pending trips

### Dependencies
- #1619 — Session validation (must be live)
- #1647 — System pushes trip request to matched driver (must be live)

---

## [API] #1649 — Driver accepts trip
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to submit an acceptance for a pending trip request so that the trip is confirmed and the rider is notified that her driver is on the way.

### Background
This endpoint is called when the driver taps "Accept" on the trip request details screen. The platform checks that the driver's pending trip record still exists and that the 10-second acceptance window has not expired. If valid, the trip status is updated to accepted, the driver's status changes to "on trip," and the rider receives a match-confirmation push (#1634). If the window has already expired (because the server timer elapsed or the trip was reassigned), a conflict error is returned and the acceptance is ignored.

### Field Validation
No input fields — the acceptance is tied to the authenticated driver's pending trip.

### Acceptance Criteria

**Scenario 1 — Successful acceptance within window**
- Given an authenticated driver has a pending trip and the 10-second window is still open
- When she calls the accept endpoint
- Then the trip status is updated to accepted
- And the driver's status is updated to "on trip"
- And the rider receives a push notification confirming the match
- And the response signals success to the driver app

**Scenario 2 — Acceptance window has expired**
- Given an authenticated driver calls the accept endpoint after the 10-second window has elapsed
- When the endpoint processes the request
- Then a conflict error is returned: "Acceptance window has expired"
- And the trip status is not changed (it has already been reassigned or expired)
- And the driver app shows "This request has expired" and returns to the home screen

**Scenario 3 — No pending trip for this driver**
- Given an authenticated driver calls the accept endpoint when she has no pending trip
- When the endpoint processes the request
- Then a not-found error is returned
- And no trip status change occurs

**Scenario 4 — Unauthenticated request**
- Given a request is made without a valid driver session token
- When the endpoint is called
- Then the request is rejected with an authentication error

**Scenario 5 — Duplicate acceptance call**
- Given a driver's acceptance has already been recorded
- When the same accept endpoint is called again (e.g., double-tap)
- Then the endpoint returns a conflict or idempotent success
- And no duplicate state changes occur

### Out of Scope
- Driver navigation / GPS (active trip feature)
- Rider rating or profile visible at acceptance
- Accepting on behalf of another driver

### Dependencies
- #1619 — Session validation (must be live)
- #1648 — Driver retrieves pending trip request (must be live)

---

## [API] #1650 — Driver rejects trip
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to submit a rejection for a pending trip request so that I can decline the trip and the platform can reassign it to another driver.

### Background
This endpoint is called when the driver taps "Reject" on the trip request details screen. The platform marks the driver's pending record as rejected, sets the driver's status back to available, and triggers the reassignment process (#1651). If the 10-second window has already expired server-side (the trip was already reassigned due to timeout), a conflict error is returned — the rejection is a no-op since the system has already handled it. No penalty is applied to the driver in this sprint.

### Field Validation
No input fields — the rejection is tied to the authenticated driver's pending trip.

### Acceptance Criteria

**Scenario 1 — Successful rejection within window**
- Given an authenticated driver has a pending trip and the 10-second window is still open
- When she calls the reject endpoint
- Then the pending trip record is marked as rejected
- And the driver's status is set to available
- And the reassignment process (#1651) is triggered
- And the response signals success to the driver app

**Scenario 2 — Rejection after server-side window expiry**
- Given an authenticated driver calls the reject endpoint after the 10-second window has elapsed
- When the endpoint processes the request
- Then a conflict error is returned: "Acceptance window has already expired"
- And no duplicate reassignment is triggered (the system already handled the timeout)
- And the driver app shows the expired message and returns to the home screen

**Scenario 3 — No pending trip for this driver**
- Given an authenticated driver calls the reject endpoint when she has no pending trip
- When the endpoint processes the request
- Then a not-found error is returned

**Scenario 4 — Unauthenticated request**
- Given a request is made without a valid driver session token
- When the endpoint is called
- Then the request is rejected with an authentication error

**Scenario 5 — Driver status remains available after rejection**
- Given the driver has successfully rejected the trip
- When the response is processed by the driver app
- Then the driver's status is confirmed as available
- And no penalty or flag is recorded against the driver in this sprint

### Out of Scope
- Rejection reason capture
- Rejection rate tracking or thresholds (future sprint)
- Driver going offline via rejection

### Dependencies
- #1619 — Session validation (must be live)
- #1648 — Driver retrieves pending trip request (must be live)
- #1651 — Trip is reassigned on rejection or timeout (must be live)

---

## [API] #1651 — Trip is reassigned on rejection or timeout
**Feature:** Driver Trip Acceptance | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically reassign a trip when a driver rejects it or the acceptance window times out so that the rider is matched to another driver without any manual intervention.

### Background
This internal platform process is triggered in two cases: (1) a driver explicitly rejects via #1650, or (2) the server-side 10-second acceptance timer for a dispatched trip elapses with no acceptance recorded. When triggered, the process marks the current driver dispatch as rejected/timed-out, finds the next nearest eligible driver, and repeats the dispatch (#1647). If no further eligible drivers are available, the trip is expired and the rider is notified (#1632). This process is entirely server-side and not directly callable by client apps.

### Field Validation
No direct client input — this is an internally triggered process.

### Acceptance Criteria

**Scenario 1 — Reassignment to next nearest driver**
- Given a driver has rejected a trip or the 10-second window has expired
- When this process is triggered
- Then the current driver dispatch record is marked as rejected or timed-out
- And the next nearest online, approved, available driver is identified
- And the trip is dispatched to that driver (#1647)

**Scenario 2 — No further eligible drivers**
- Given the reassignment process runs and finds no remaining eligible drivers
- When the process completes its search
- Then the trip is marked as expired
- And the rider is notified via push: "We couldn't find a driver. Please try again." (#1632)

**Scenario 3 — Race condition — driver accepted just before timeout**
- Given a driver's acceptance and the server-side timeout arrive nearly simultaneously
- When the acceptance is recorded first
- Then the trip is marked as accepted and this reassignment process is not triggered
- And if the timeout fires first, the acceptance call returns a conflict (#1649)

**Scenario 4 — Repeated reassignment chain**
- Given multiple drivers are tried in sequence
- When each rejects or times out
- Then each rejection triggers another reassignment iteration
- And the process continues until either a driver accepts or the pool is exhausted

### Out of Scope
- Driver penalty for rejection or timeout (future sprint)
- Rider notification of individual reassignment attempts (only final no-driver notification)
- Manual override or admin reassignment

### Dependencies
- #1619 — Session validation (must be live)
- #1630 — System matches request to nearest available driver (must be live)
- #1632 — Trip expires and rider is notified via push (must be live)

---

# SheDrive — Feature 10 & 11 User Stories
## Active Trip + Trip Completion & Cash Payment
**Sprint:** 2

---

## [Mobile] #1586 — Driver navigates to pickup
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to see the rider's pickup location on a map and open turn-by-turn navigation so that I can reach the pickup point efficiently.

### Background
After accepting a trip request, the driver's screen displays a map with a pin marking the rider's pickup location. A navigation button allows the driver to deep-link into Google Maps or Waze with the pickup coordinates pre-filled. An "I've Arrived" button is visible at all times so the driver can signal her arrival. The driver's GPS position is streamed every 5 seconds so the rider can track progress in real time.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Map and arrival button are shown after acceptance**
- Given the driver has accepted a trip request
- When the active trip screen loads
- Then the map displays a pin at the rider's pickup coordinates
- And an "I've Arrived" button is visible on screen

**Scenario 2 — Navigation deep-link opens external app**
- Given the driver is on the active trip screen in en_route_pickup state
- When the driver taps the navigation button
- Then the app opens Google Maps (or Waze if installed) with the pickup coordinates pre-filled as the destination
- And the driver returns to the SheDrive active trip screen when she exits the navigation app

**Scenario 3 — Driver location streams to the platform**
- Given the driver is navigating to the pickup location
- When the driver's device has an active GPS signal
- Then the app sends the driver's current latitude and longitude to the platform every 5 seconds
- And those coordinates are available for the rider to see in real time

### Out of Scope
- In-app turn-by-turn navigation
- Automatic ETA calculation in the driver app
- SOS functionality
- Trip cancellation from this screen

### Dependencies
- #1649 — Trip acceptance flow (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1587 — Driver confirms arrival at pickup
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "I've Arrived" when I reach the pickup location so that the rider is notified and I can proceed to board her.

### Background
When the driver reaches the rider's pickup location, she taps the "I've Arrived" button on the active trip screen. This advances the trip state from en_route_pickup to arrived_pickup. The platform immediately sends a push notification to the rider. The driver's screen transitions to show either a "Confirm Rider Identity" button (if it is the rider's first trip) or a "Rider Has Boarded" button (for returning riders).

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver taps "I've Arrived" and state advances**
- Given the driver is on the active trip screen in en_route_pickup state
- When the driver taps "I've Arrived"
- Then the trip state advances to arrived_pickup
- And the platform sends a push notification to the rider

**Scenario 2 — First-trip rider: identity confirmation button appears**
- Given the trip's is_first_trip flag is true
- When the driver taps "I've Arrived" and the state advances to arrived_pickup
- Then the screen shows a "Confirm Rider Identity" button
- And the "Rider Has Boarded" button is not yet accessible

**Scenario 3 — Returning rider: board button appears immediately**
- Given the trip's is_first_trip flag is false
- When the driver taps "I've Arrived" and the state advances to arrived_pickup
- Then the screen shows a "Rider Has Boarded" (Start Trip) button
- And no identity confirmation step is presented

### Out of Scope
- Geofence-based automatic arrival detection
- SOS functionality
- Trip cancellation from this screen

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)

---

## [Mobile] #1588 — Driver confirms rider identity on first trip
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to verify the rider's identity against her registered name on her first trip so that I board the correct passenger.

### Background
When is_first_trip is true, the driver sees the rider's registered full name displayed prominently on the arrived_pickup screen. The driver asks the rider to show a government-issued ID and compares the name. Once satisfied, the driver taps "Identity Confirmed" to proceed to the boarding step. For all returning riders this step is skipped entirely and the driver proceeds directly to the "Start Trip" button.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Identity confirmation screen is shown for first-trip riders**
- Given the driver has arrived at the pickup location
- And the trip's is_first_trip flag is true
- When the arrived_pickup screen loads
- Then the driver sees the rider's registered full name
- And a prominent "Identity Confirmed" button is displayed

**Scenario 2 — Driver confirms identity and proceeds**
- Given the identity confirmation screen is visible
- When the driver taps "Identity Confirmed"
- Then the screen transitions to show the "Start Trip" button
- And the driver can now board the rider

**Scenario 3 — Identity step is skipped for returning riders**
- Given the trip's is_first_trip flag is false
- When the driver arrives and the arrived_pickup screen loads
- Then no identity confirmation step is shown
- And the "Start Trip" button is immediately accessible

### Out of Scope
- Biometric or document scanning
- SOS functionality
- Automatic identity verification via camera

### Dependencies
- #1635 — Trip detail includes first-trip flag (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [Mobile] #1589 — Driver confirms rider has boarded
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "Start Trip" after the rider boards so that the trip officially begins and I can navigate to the destination.

### Background
After the driver has arrived (and confirmed the rider's identity if required), she taps the "Start Trip" button. This advances the trip state from arrived_pickup to trip_started. The map transitions to display the destination pin instead of the pickup pin. The navigation button now deep-links to the destination coordinates. GPS streaming continues throughout.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver taps "Start Trip" and state advances**
- Given the driver is on the arrived_pickup screen
- And identity confirmation has been completed (if required)
- When the driver taps "Start Trip"
- Then the trip state advances to trip_started
- And the map updates to show the destination pin

**Scenario 2 — Navigation button points to destination after boarding**
- Given the trip state is trip_started
- When the driver taps the navigation button
- Then the app opens Google Maps or Waze with the destination coordinates pre-filled
- And the driver returns to the SheDrive active trip screen on exit

**Scenario 3 — "Start Trip" is not accessible before identity confirmation on first trip**
- Given is_first_trip is true and the driver has not yet tapped "Identity Confirmed"
- When the arrived_pickup screen is displayed
- Then the "Start Trip" button is not accessible
- And only the "Identity Confirmed" button is shown

### Out of Scope
- Automatic boarding detection
- SOS functionality

### Dependencies
- #1652 — Driver advances trip state machine (must be live)

---

## [Mobile] #1590 — Driver navigates to destination
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to see the destination on the map and open navigation so that I can bring the rider to her destination safely.

### Background
Once the trip is started, the driver's active trip screen shows a pin at the destination. A navigation button allows the driver to deep-link to Google Maps or Waze with the destination coordinates. An "End Trip" button is visible so the driver can mark completion. GPS streaming continues every 5 seconds so the rider can follow progress on her screen.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Destination pin appears after trip starts**
- Given the trip state has advanced to trip_started
- When the active trip screen is displayed
- Then the map shows a pin at the destination coordinates
- And the pickup pin is no longer shown

**Scenario 2 — Navigation deep-link opens external app with destination**
- Given the trip is in trip_started state
- When the driver taps the navigation button
- Then the app opens Google Maps or Waze with the destination coordinates pre-filled
- And the driver can return to the SheDrive screen on exit

**Scenario 3 — "End Trip" button is visible during navigation**
- Given the trip is in trip_started state
- When the active trip screen is displayed
- Then an "End Trip" button is visible on screen

**Scenario 4 — GPS continues streaming during destination navigation**
- Given the trip is in trip_started state
- When the driver's device has an active GPS signal
- Then the app continues sending the driver's coordinates to the platform every 5 seconds

### Out of Scope
- In-app turn-by-turn navigation
- Geofence-based automatic trip ending
- SOS functionality

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1591 — Driver ends trip at destination
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "End Trip" when I reach the destination so that the fare is calculated and the rider is notified of completion.

### Background
When the driver arrives at the destination, she taps "End Trip" on the active trip screen. This advances the trip state from trip_started to trip_ended. The platform calculates the final fare from the actual distance and duration. The rider receives a push notification with the fare amount and sees the trip summary. The driver is shown the cash collection screen.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Driver taps "End Trip" and state advances**
- Given the driver is on the active trip screen in trip_started state
- When the driver taps "End Trip"
- Then the trip state advances to trip_ended
- And the platform calculates the final fare

**Scenario 2 — Rider receives push notification on trip end**
- Given the trip state has advanced to trip_ended
- When the fare calculation is complete
- Then the rider receives a push notification with the final fare amount
- And tapping the notification opens the rider's trip summary screen

**Scenario 3 — Driver sees cash collection screen after ending trip**
- Given the trip state has advanced to trip_ended
- When the driver's screen updates
- Then the driver sees the cash fare to collect from the rider
- And a "Done" button is available to dismiss the screen

### Out of Scope
- Automatic trip ending via geofence
- Digital payment processing
- SOS functionality

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1636 — Final fare is calculated from actual route and duration (must be live)

---

## [Mobile] #1558 — Rider sees driver live location while waiting
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location on the map while she heads to my pickup so that I know how close she is.

### Background
After a driver accepts the trip, the rider's active trip screen displays a map with two pins: the rider's pickup location and the driver's current position as a moving dot. The driver's ETA to the pickup is displayed and updated every 5 seconds as the platform receives new GPS coordinates. The rider remains on this screen until the driver marks arrival.

### Field Validation
None.

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
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want my screen to update when the driver arrives so that I know to head to the pickup point.

### Background
When the driver taps "I've Arrived" and the trip state advances to arrived_pickup, the rider's active trip screen automatically transitions to a "Your driver has arrived" state. The map continues to show the driver's pin at the pickup location. No action is required from the rider on this screen — she simply proceeds to board.

### Field Validation
None.

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

## [Mobile] #1560 — Rider receives push when driver arrives
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when my driver arrives so that I know to head to the pickup point even if the app is in the background.

### Background
When the driver taps "I've Arrived", the platform sends a push notification to the rider's device. The notification text is: "سائقتك وصلت! توجهي إلى موقع الانطلاق." Tapping the notification brings the app to the foreground and displays the active trip screen in the arrived_pickup state.

### Field Validation
None.

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

## [Mobile] #1561 — Rider sees driver live location during trip
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's moving location on the map while we travel to the destination so that I can follow our progress.

### Background
Once the driver taps "Start Trip" and the state advances to trip_started, the rider's map updates to show the driver's location moving toward the destination. The destination pin is visible on the map. GPS coordinates received from the driver every 5 seconds update the moving dot in near real time. The rider remains on this screen until the trip ends.

### Field Validation
None.

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
**Feature:** Active Trip | **Sprint:** 2

**Description:** As a rider, I want to see the driver's name, photo, and vehicle details throughout the trip so that I can confirm I am with the correct driver.

### Background
Throughout the active trip — from en_route_pickup through trip_ended — the rider sees a persistent driver card on the active trip screen. The card displays the driver's name, profile photo (or a placeholder avatar if no photo is set), vehicle make and model, vehicle color, and license plate number. This information is sourced from the trip details returned by the platform.

### Field Validation
None.

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

## [API] #1652 — Driver advances trip state machine
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the driver app, I want to advance the trip state through each stage so that all downstream screens and notifications are triggered correctly.

### Background
This is the core state-transition endpoint consumed by the driver app. An authenticated driver sends the desired next state for an active trip. The platform validates that the new state follows the required sequence (accepted → en_route_pickup → arrived_pickup → trip_started → trip_ended) and rejects any attempt to skip a state. Each successful transition triggers the appropriate side effects: pushing a notification to the rider on arrived_pickup, calculating the fare on trip_ended, and making the new state immediately visible to the rider app via #1633.

### Field Validation
State transitions are validated by the platform. Skipping states is rejected. No free-text input fields.

### Acceptance Criteria

**Scenario 1 — Valid state transition is accepted**
- Given an authenticated driver has an active trip in state S
- When the driver app sends the next valid state S+1
- Then the platform updates the trip record to the new state
- And the appropriate side effects are triggered

**Scenario 2 — Skipping a state is rejected**
- Given an active trip is in en_route_pickup state
- When the driver app sends trip_started (skipping arrived_pickup)
- Then the platform rejects the request
- And the trip remains in en_route_pickup state

**Scenario 3 — Arrived_pickup triggers rider push**
- Given an active trip is in en_route_pickup state
- When the driver advances state to arrived_pickup
- Then the platform sends a push notification to the rider via #1634

**Scenario 4 — Trip_ended triggers fare calculation**
- Given an active trip is in trip_started state
- When the driver advances state to trip_ended
- Then the platform triggers final fare calculation via #1636
- And the rider is notified via #1638

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets the state-advance endpoint
- Then the platform rejects the request
- And the trip state is unchanged

### Out of Scope
- Reverse state transitions
- Admin-initiated state changes
- SOS state handling

### Dependencies
- #1619 — Authentication service (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)
- #1636 — Final fare calculation (must be live)
- #1638 — System pushes trip completion to rider (must be live)

---

## [API] #1653 — Driver streams GPS from acceptance to completion
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the driver app, I want to send my GPS coordinates to the platform throughout the trip so that the rider can track my live location.

### Background
From the moment a driver accepts a trip until the trip reaches trip_ended, the driver app calls the location update endpoint every 5 seconds with the current latitude and longitude. This endpoint (the same contract as #1646 for driver availability) associates the incoming coordinates with the active trip record, making them immediately available to the rider app through #1633. The platform uses these coordinates to update the rider's map in near real time.

### Field Validation
Payload is the same lat/lng structure as #1646. No additional validation for this story.

### Acceptance Criteria

**Scenario 1 — Driver coordinates are associated with the active trip**
- Given the driver has an active trip and is sending GPS updates
- When the platform receives a location update
- Then the coordinates are stored against the active trip record
- And the rider app can retrieve the updated location via #1633

**Scenario 2 — Location updates are available in near real time**
- Given the driver sends a GPS update
- When the rider app polls or receives the update via #1633
- Then the driver's position reflects the most recent coordinate within 5 seconds

**Scenario 3 — Streaming stops after trip_ended**
- Given the trip has advanced to trip_ended
- When the driver app sends a GPS update
- Then the update is not associated with a completed trip
- And no live location data is served to the rider for this trip

**Scenario 4 — Unauthenticated GPS updates are rejected**
- Given a GPS update arrives without a valid driver auth token
- When it targets the location streaming endpoint
- Then the platform rejects the update

### Out of Scope
- Historical route replay
- GPS accuracy validation
- Battery optimization on the driver device

### Dependencies
- #1619 — Authentication service (must be live)
- #1646 — Driver location update endpoint (must be live)

---

## [API] #1633 — Rider retrieves live trip state and driver location
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the rider app, I want to poll the platform for the current trip state and driver location so that the rider's screen always reflects reality.

### Background
The rider app calls this endpoint periodically (approximately every 5 seconds) while the trip is active. The response includes the current trip state, the driver's last known GPS coordinates, the driver's ETA to the pickup point (included while in en_route_pickup state, omitted once the trip has started), and the driver card details (name, photo, vehicle, plate). The rider app uses this data to update the map dot, the ETA display, and the driver card without requiring a page reload.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Response includes trip state and driver location**
- Given an authenticated rider has an active trip
- When the rider app calls this endpoint
- Then the response includes the current trip state
- And the driver's last known latitude and longitude

**Scenario 2 — ETA is included while driver is en route to pickup**
- Given the trip is in en_route_pickup state
- When the rider app calls this endpoint
- Then the response includes the driver's estimated arrival time to the pickup location

**Scenario 3 — ETA is omitted once the trip has started**
- Given the trip is in trip_started state
- When the rider app calls this endpoint
- Then the response does not include an ETA field
- And the driver's GPS position continues to be returned

**Scenario 4 — Driver card details are included in the response**
- Given an active trip exists
- When the rider app calls this endpoint
- Then the response includes the driver's name, profile photo URL (or null), vehicle make, model, color, and plate number

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- WebSocket or server-sent event push (polling model only for MVP)
- Trip history retrieval
- Driver contact details

### Dependencies
- #1619 — Authentication service (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [API] #1634 — System pushes driver-arrived to rider
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when the driver marks arrival so that the rider is alerted even if the app is backgrounded.

### Background
This is an internal platform process, not a direct app call. When the driver advances the trip state to arrived_pickup via #1652, the state machine immediately triggers a push notification to the rider's registered device. The notification text is "سائقتك وصلت!" and is delivered via the push service established in #1618. No app-to-platform call initiates this — it is purely event-driven.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on arrived_pickup transition**
- Given a driver has advanced a trip to arrived_pickup state
- When the platform processes the state transition
- Then a push notification is sent to the rider's device automatically
- And no separate API call from any app is required to trigger it

**Scenario 2 — Push text is correct**
- Given the arrived_pickup push is triggered
- When the notification is delivered
- Then the notification text reads "سائقتك وصلت!"

**Scenario 3 — Push failure does not block the state transition**
- Given the push delivery service is temporarily unavailable
- When the driver advances to arrived_pickup
- Then the trip state is still saved as arrived_pickup
- And the platform logs the push delivery failure for retry

### Out of Scope
- SMS fallback for push delivery failures
- Rider acknowledgement of the push
- SOS notifications

### Dependencies
- #1619 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1635 — Trip detail includes first-trip flag
**Feature:** Active Trip | **Sprint:** 2

**Description:** As the driver app, I want the trip detail response to include a first-trip flag so that I know whether to show the identity verification step before starting the trip.

### Background
When the driver app fetches the active trip details, the response includes a boolean field is_first_trip. This field is true if the trip belongs to a rider who has never previously completed a trip on SheDrive. It is derived from the rider's trip history at the time the trip is created and stored on the trip record. The driver app reads this flag to conditionally display the identity confirmation step (#1588).

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — is_first_trip is true for a rider's very first trip**
- Given a rider has no prior completed trips on SheDrive
- When the driver app fetches the trip detail
- Then the response includes is_first_trip: true

**Scenario 2 — is_first_trip is false for returning riders**
- Given a rider has at least one previously completed trip on SheDrive
- When the driver app fetches the trip detail
- Then the response includes is_first_trip: false

**Scenario 3 — Flag is stable throughout the trip lifecycle**
- Given the trip was created with is_first_trip: true
- When the driver fetches trip details at any point during the trip
- Then the is_first_trip value remains true and does not change mid-trip

**Scenario 4 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets the trip detail endpoint
- Then the platform rejects the request

### Out of Scope
- Recalculating first-trip status after trip creation
- Exposing this flag to the rider app
- Historical trip count in the response

### Dependencies
- #1619 — Authentication service (must be live)
- #1629 — Rider profile with trip history (must be live)

---

## [Mobile] #1563 — Rider receives push on trip completion
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to receive a push notification when my trip ends so that I know the fare and can review my trip summary.

### Background
When the driver taps "End Trip" and the trip state advances to trip_ended, the platform sends a push notification to the rider. The notification text includes the final fare: "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." where [X] is the calculated fare in Egyptian Pounds. Tapping the notification brings the SheDrive app to the foreground and displays the trip summary screen.

### Field Validation
None.

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
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to see the full trip summary with the cash fare breakdown after my trip ends so that I know exactly what to pay.

### Background
After the trip ends, the rider's screen displays a trip summary. The total fare in EGP is shown in bold at the top. Below it is a fare breakdown with three line items: base fee, distance charge, and time charge. The summary also shows total trip distance (km), trip duration (minutes), pickup address, destination address, and the driver's name. Two actions are available: a "Rate Your Driver" button leading to the rating screen, and a "Skip" link leading directly to home.

### Field Validation
None.

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
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

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
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a rider, I want to skip rating so that I can go home quickly without being forced to provide feedback.

### Background
A "Skip" option is available on both the trip summary screen and the rating screen. When the rider taps "Skip", no rating is submitted and the rider is taken directly to the home screen. The skip action is final — the rider cannot return to rate the same trip. The trip is still recorded as complete and visible in trip history.

### Field Validation
None.

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

## [Mobile] #1592 — Driver sees cash fare to collect and returns to available
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a driver, I want to see how much cash to collect from the rider after ending the trip so that I collect the correct amount before becoming available again.

### Background
Immediately after the driver taps "End Trip" and the trip state advances to trip_ended, the driver's screen shows a full-screen prompt displaying the cash amount to collect from the rider in EGP. A single "Done" button is shown. When the driver taps "Done", this screen is dismissed and the driver is returned to her home screen in the online/available state, ready to receive the next trip request.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Cash collection screen appears after ending trip**
- Given the driver has tapped "End Trip" and the trip is in trip_ended state
- When the driver's screen updates
- Then a full-screen cash collection prompt is displayed
- And the final fare amount in EGP is shown prominently

**Scenario 2 — "Done" dismisses the screen and returns driver to available**
- Given the driver is viewing the cash collection screen
- When she taps "Done"
- Then the screen is dismissed
- And the driver is returned to her home screen in the available state

**Scenario 3 — Fare amount matches the calculated fare**
- Given the platform has calculated the final fare
- When the cash collection screen is displayed
- Then the amount shown to the driver matches the final fare stored on the trip record

### Out of Scope
- Digital payment confirmation
- Receipt generation for the driver
- Fare dispute workflow

### Dependencies
- #1636 — Final fare calculation (must be live)

---

## [API] #1636 — Final fare is calculated from actual route and duration
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to calculate the final trip fare from the actual GPS distance and duration when the trip ends so that the rider and driver see the correct amount to exchange.

### Background
This is a platform process triggered automatically when the driver advances the trip state to trip_ended via #1652. The platform calculates the fare using the rate formula defined in #1628: base fee + (per-km rate × actual GPS distance in km) + (per-minute rate × actual trip duration in minutes). The resulting final fare is stored on the trip record and made available to all downstream consumers: the rider's push notification (#1638), the trip summary (#1637), and the driver's cash collection screen (#1592).

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Fare is calculated automatically on trip_ended**
- Given a trip has advanced to trip_ended state
- When the platform processes the state transition
- Then the final fare is calculated immediately using actual GPS distance and duration
- And the fare is stored on the trip record

**Scenario 2 — Fare uses the correct rate formula**
- Given the rate formula from #1628 is: base fee + (per-km rate × km) + (per-minute rate × minutes)
- When the fare is calculated for a trip of D km and T minutes
- Then the stored fare equals base fee + (per-km rate × D) + (per-minute rate × T)

**Scenario 3 — Fare is immediately available to downstream consumers**
- Given the fare has been calculated and stored
- When the rider app requests trip details (#1637) or the push is sent (#1638)
- Then both receive the same final fare amount

**Scenario 4 — Fare is not recalculated after storage**
- Given the final fare has been stored on the trip record
- When any downstream endpoint reads the fare
- Then the stored value is returned without recalculation

### Out of Scope
- Surge pricing or dynamic multipliers
- Fare disputes or manual overrides
- Digital payment processing

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1628 — Rate formula configuration (must be live)

---

## [API] #1637 — Completed trip is served with fare breakdown
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to retrieve a completed trip's full details including the fare breakdown so that the rider sees exactly what she owes.

### Background
After a trip reaches trip_ended state, the rider app calls this endpoint to populate the trip summary screen. The response includes the total fare in EGP, a breakdown of the three fare components (base fee, distance charge, time charge), total distance in km, trip duration in minutes, pickup address, destination address, driver name, vehicle details, and the rider's rating if one has been submitted.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Response includes fare total and breakdown**
- Given a trip is in trip_ended state
- When the rider app calls this endpoint
- Then the response includes the total fare in EGP
- And separate line items for base fee, distance charge, and time charge

**Scenario 2 — Response includes trip metadata**
- Given the endpoint is called for a completed trip
- When the response is returned
- Then it includes total distance in km, trip duration in minutes, pickup address, and destination address

**Scenario 3 — Response includes driver details**
- Given the endpoint is called for a completed trip
- When the response is returned
- Then the driver's name and vehicle details are included

**Scenario 4 — Rating is included if submitted**
- Given the rider has submitted a rating for the trip
- When this endpoint is called
- Then the response includes the star rating and any selected tags

**Scenario 5 — Rating field is absent or null if not yet submitted**
- Given the rider has not yet rated the trip
- When this endpoint is called
- Then the rating field is absent or null in the response

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Full trip history listing
- Fare dispute submission
- Receipt PDF generation

### Dependencies
- #1619 — Authentication service (must be live)
- #1636 — Final fare calculation (must be live)

---

## [API] #1638 — System pushes trip completion to rider
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when the trip ends so that she is alerted to the final fare even if the app is backgrounded.

### Background
This is an internal platform process triggered when the trip state advances to trip_ended via #1652. Once the fare is calculated, the platform sends a push notification to the rider's registered device via the push service in #1618. The notification text includes the final fare: "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." No app-to-platform call initiates this — it is event-driven from the state machine.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on trip_ended**
- Given the driver has advanced the trip to trip_ended and the fare has been calculated
- When the platform processes the state transition
- Then a push notification is sent to the rider's device automatically
- And no separate app call is required to trigger it

**Scenario 2 — Push text includes the final fare**
- Given the completion push is triggered
- When the notification is delivered
- Then the text reads "رحلتك اكتملت! المبلغ المستحق: [X] جنيه." with the actual fare substituted

**Scenario 3 — Push failure does not block state transition**
- Given the push delivery service is temporarily unavailable
- When the driver advances to trip_ended
- Then the trip state is still saved as trip_ended
- And the fare is still calculated and stored
- And the platform logs the push delivery failure for retry

### Out of Scope
- SMS or email fallback for push delivery failures
- Rider acknowledgement of the push
- Digital payment confirmation push

### Dependencies
- #1619 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1639 — Rider submits driver rating
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to submit a star rating and optional tags for a completed trip so that the driver's performance is recorded.

### Background
After a trip ends, the rider may rate the driver through this authenticated endpoint. The request must include the trip ID, a star rating between 1 and 5, and optionally up to 3 predefined tags. The platform validates that the trip belongs to the requesting rider and that the trip is in completed state before storing the rating. On success, the platform triggers an update to the driver's aggregate rating via #1654.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| trip_id | Yes | String / UUID | — | — | Alphanumeric, hyphens | Return validation error | Return not-found or forbidden error if trip not found or not this rider's | — |
| stars | Yes | Integer | 1 | 5 | Numeric | Return validation error | — | Return validation error if out of range |
| tags | No | Array of predefined strings | 0 items | 3 items | Predefined tag strings only | — | Return validation error if tag not in predefined list | Return validation error if more than 3 tags |

### Acceptance Criteria

**Scenario 1 — Valid rating is accepted and stored**
- Given an authenticated rider submits a trip ID, a star rating between 1 and 5, and optional valid tags
- When the platform processes the request
- Then the rating is stored against the trip record
- And the driver's aggregate rating update is triggered via #1654

**Scenario 2 — Missing stars returns validation error**
- Given the rider submits a request without a stars value
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 3 — Stars out of range returns validation error**
- Given the rider submits a stars value of 0 or 6
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 4 — Trip not found or not rider's trip returns error**
- Given the rider submits a trip ID that does not exist or belongs to a different rider
- When the platform processes the request
- Then a not-found or forbidden error is returned
- And no rating is stored

**Scenario 5 — Invalid tag value returns validation error**
- Given the rider submits a tag string that is not in the predefined list
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 6 — More than 3 tags returns validation error**
- Given the rider submits 4 or more tag values
- When the platform processes the request
- Then a validation error is returned
- And no rating is stored

**Scenario 7 — Tags are optional**
- Given the rider submits a valid trip ID and stars but no tags
- When the platform processes the request
- Then the rating is stored successfully without tags

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Free-text comment submission
- Rating edit or deletion after submission
- Rider receiving confirmation of rating impact

### Dependencies
- #1619 — Authentication service (must be live)
- #1654 — Driver aggregate rating update (must be live)

---

## [API] #1654 — Driver aggregate rating is updated
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to recalculate the driver's average rating after each new rating is submitted so that the driver's profile always reflects her current standing.

### Background
This is an internal platform process triggered after a rating is successfully stored by #1639. The platform recalculates the driver's average star rating across all rated trips (excluding skipped trips). The updated average is written to the driver's profile record. All driver-detail endpoints reflect the new average immediately on their next call. No app-to-platform call initiates this — it is triggered internally by the rating submission flow.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Aggregate rating is recalculated after a new rating**
- Given a rider has successfully submitted a rating for a driver
- When #1654 is triggered by #1639
- Then the driver's average star rating is recalculated across all rated trips
- And the updated average is stored on the driver's profile record

**Scenario 2 — Updated average is reflected immediately**
- Given the driver's aggregate rating has been updated
- When any driver-detail endpoint is called
- Then the new average is returned in the response

**Scenario 3 — Skipped trips do not affect the aggregate**
- Given a trip was completed with a skipped rating (rating_status = skipped)
- When the driver's aggregate is calculated
- Then that trip is excluded from the average calculation
- And only trips with submitted ratings are counted

**Scenario 4 — First rating sets the aggregate correctly**
- Given a driver has no prior ratings
- When the first rating (e.g., 4 stars) is submitted
- Then the driver's aggregate rating is set to 4.0

### Out of Scope
- Weighted or time-decayed rating formulas
- Exposing individual rating breakdowns to the driver
- Minimum rating threshold enforcement

### Dependencies
- #1639 — Rider submits driver rating (must be live)

---

## [API] #1640 — Trip closes without rating on skip
**Feature:** Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to mark a trip as completed without a rating when the rider skips so that the trip history remains accurate and the driver's rating is unaffected.

### Background
When the rider taps "Skip" on the rating or summary screen, the platform marks the trip with rating_status = skipped. No rating record is created for this trip. The driver's aggregate rating is not recalculated. The trip remains fully visible in both the rider's and the driver's trip history with all trip details intact. The skipped status is final and cannot be changed to a rated status later.

### Field Validation
None.

### Acceptance Criteria

**Scenario 1 — Trip is marked skipped when rider skips rating**
- Given the rider has tapped "Skip" on the rating or summary screen
- When the platform processes the skip action
- Then the trip record is updated with rating_status = skipped
- And no rating record is created

**Scenario 2 — Driver aggregate rating is unchanged after skip**
- Given a trip has been marked rating_status = skipped
- When the platform processes the skip
- Then the driver's aggregate star rating is not recalculated
- And the driver's average remains the same as before the trip

**Scenario 3 — Trip is visible in history for rider and driver**
- Given a trip has rating_status = skipped
- When either the rider or driver views their trip history
- Then the trip record is present with all trip details
- And no rating is shown for that trip

**Scenario 4 — Skipped status is final**
- Given a trip has been marked rating_status = skipped
- When any subsequent request attempts to submit a rating for that trip
- Then the platform rejects the request
- And the trip remains in skipped status

**Scenario 5 — Unauthenticated skip request is rejected**
- Given a skip request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Prompting the rider to rate a skipped trip at a later time
- Displaying skip statistics to the driver
- Admin override of skipped status

### Dependencies
- #1619 — Authentication service (must be live)

---

# SheDrive — User Stories Part 5
## Features 12–15: Trip History, Admin Rider/Driver Management, Admin Operations Dashboard

---

## [Mobile] #1567 — Rider views trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a rider, I want to view a list of my past trips so that I can review where I have travelled and how much I have spent.

### Background
Riders access trip history from the menu or profile section of the app. The list is sorted most recent first and shows a summary row for each past trip. This screen gives riders a quick overview without surfacing every detail — tapping any row opens the full trip detail screen (#1568). If the rider has not yet completed any trips, an empty state message is displayed instead of the list.

### Field Validation
N/A

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

## [Mobile] #1568 — Rider views past trip detail
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a rider, I want to view the full details of a past trip so that I can understand the fare breakdown and confirm where I travelled.

### Background
When a rider taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the complete picture of that trip: timing, addresses, fare breakdown, and who drove her. If she previously submitted a star rating for this trip, that rating is also shown. The screen is read-only — no actions are available.

### Field Validation
N/A

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
- #1637 — Trip rating is stored (must be live)

---

## [Mobile] #1593 — Driver views trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a driver, I want to view a list of my completed trips so that I can track my earnings and activity over time.

### Background
Drivers access trip history from the menu or profile section of the app. The list shows completed trips only, sorted most recent first, with a summary of each trip's destination area and cash fare collected. Tapping a row opens the full trip detail screen (#1594). If the driver has not yet completed any trips, an empty state is displayed.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Driver opens trip history with completed trips**
- Given the driver is authenticated and has at least one completed trip
- When she opens the trip history screen from the menu
- Then a paginated list of her completed trips is displayed, most recent first
- And each row shows: trip date, destination area, and cash fare collected (EGP)

**Scenario 2 — Driver taps a trip row**
- Given the trip history list is visible with at least one row
- When the driver taps any trip row
- Then the app navigates to the trip detail screen (#1594) for that trip

**Scenario 3 — Driver has no completed trips**
- Given the driver is authenticated and has not completed any trips
- When she opens the trip history screen
- Then an empty state message is shown indicating no trips are available yet
- And no list rows are rendered

**Scenario 4 — Driver paginates the list**
- Given the driver has more than one page of completed trips
- When she scrolls to the bottom of the current page
- Then the next page loads and appends below
- And the order remains most recent first

### Out of Scope
- In-progress or cancelled trips
- Filtering or searching trip history
- Earnings summaries or totals
- SOS-related records

### Dependencies
- #1655 — Driver retrieves trip history (must be live)

---

## [Mobile] #1594 — Driver views past trip detail
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a driver, I want to view the full details of a past trip so that I can review the route, duration, and the rating I received.

### Background
When a driver taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the full picture of that trip from the driver's perspective: timing, pickup and destination addresses, cash fare collected, trip duration, distance, and the star rating the rider gave (if submitted). If the rider skipped rating, the screen shows a localised placeholder. The screen is read-only.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Driver views detail of a rated trip**
- Given the driver has navigated to the detail screen for a past trip that was rated
- When the screen loads
- Then it displays: date and time, pickup address, destination address, cash fare collected (EGP), trip duration, distance, and the star rating the rider gave

**Scenario 2 — Driver views detail of an unrated trip**
- Given the driver has navigated to the detail screen for a past trip the rider did not rate
- When the screen loads
- Then all trip details are shown as in Scenario 1
- And the rating section shows "لم يتم التقييم" (No rating given)

**Scenario 3 — Driver navigates back to the list**
- Given the driver is on the trip detail screen
- When she presses the back button
- Then she is returned to the trip history list at the same scroll position

### Out of Scope
- Responding to or disputing a rating
- Contacting the rider
- SOS history

### Dependencies
- #1655 — Driver retrieves trip history (must be live)
- #1637 — Trip rating is stored (must be live)

---

## [API] #1641 — Rider retrieves trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As the rider app, I want to retrieve a paginated list of the authenticated rider's past trips so that the trip history screen can display accurate trip data.

### Background
The rider trip history endpoint is called each time the rider opens the trip history screen or loads a new page of results. It returns trips belonging only to the authenticated rider, ordered by date descending. Each item in the response includes the fields needed to render a summary row. The endpoint supports page-number-based pagination. Unauthenticated requests are rejected before any data is accessed.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Rider with past trips retrieves page one**
- Given the rider is authenticated and has completed trips
- When the rider app requests page one of trip history
- Then the response contains a list of trips ordered by date descending
- And each item includes: trip ID, date, destination address, final fare (EGP), and status
- And pagination metadata (current page, total pages, total count) is included

**Scenario 2 — Rider with no past trips retrieves history**
- Given the rider is authenticated and has no completed trips
- When the rider app requests trip history
- Then the response contains an empty list
- And pagination metadata reflects zero records

**Scenario 3 — Rider requests a subsequent page**
- Given the rider has trips spanning multiple pages
- When the rider app requests page two
- Then the response contains the correct slice of trips for that page in date descending order

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- When a request is made to the rider trip history endpoint
- Then the request is rejected with an authentication error
- And no trip data is returned

### Out of Scope
- Filtering by date range or status
- Cancelled or in-progress trips in the response
- Driver-facing history

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1655 — Driver retrieves trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As the driver app, I want to retrieve a paginated list of the authenticated driver's completed trips so that the trip history screen can display accurate trip data.

### Background
The driver trip history endpoint is called each time the driver opens the trip history screen or loads a new page. It returns only completed trips belonging to the authenticated driver, ordered by date descending. Each item includes the fields needed to render a summary row on the driver's history screen. The endpoint supports page-number-based pagination. Unauthenticated requests are rejected before any data is accessed.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Driver with completed trips retrieves page one**
- Given the driver is authenticated and has completed trips
- When the driver app requests page one of trip history
- Then the response contains a list of completed trips ordered by date descending
- And each item includes: trip ID, date, destination area, and cash fare collected (EGP)
- And pagination metadata is included

**Scenario 2 — Driver with no completed trips retrieves history**
- Given the driver is authenticated and has no completed trips
- When the driver app requests trip history
- Then the response contains an empty list
- And pagination metadata reflects zero records

**Scenario 3 — Driver requests a subsequent page**
- Given the driver has trips spanning multiple pages
- When the driver app requests page two
- Then the response contains the correct slice of trips for that page

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- When a request is made to the driver trip history endpoint
- Then the request is rejected with an authentication error
- And no trip data is returned

### Out of Scope
- Filtering by date range
- Earnings totals or aggregates
- Rider-facing history

### Dependencies
- #1619 — Session validation (must be live)

---

## [Admin] #1661 — Admin views rider list
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a searchable, paginated list of all registered riders so that I can find and review any rider account quickly.

### Background
The rider list is the primary entry point for rider management in the admin portal. It loads automatically when the admin navigates to the Riders section. The table shows all registered riders with key identifiers. The admin can type a name or phone number into the search box to narrow results in real time. Clicking any row opens the rider profile screen (#1662). The default page size is 20 rows.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | 0 chars | 100 chars | Any | Show all riders (no error) | N/A | Clear input and reset to full list |

### Acceptance Criteria

**Scenario 1 — Admin opens the rider list**
- Given the admin is authenticated and navigates to the Riders section
- When the page loads
- Then a table of all registered riders is displayed, 20 per page by default
- And columns shown are: name, phone number, registration date, total trips completed
- And results are ordered by registration date descending

**Scenario 2 — Admin searches by rider name**
- Given the rider list is loaded
- When the admin types a partial name into the search box
- Then the list filters to show only riders whose name contains the search text
- And the result count updates accordingly

**Scenario 3 — Admin searches by phone number**
- Given the rider list is loaded
- When the admin types a partial phone number into the search box
- Then the list filters to show only riders whose phone number contains that substring

**Scenario 4 — Search returns no results**
- Given the admin has entered a search term that matches no rider
- When the results are rendered
- Then an empty state message is displayed indicating no riders match the search
- And no table rows are shown

**Scenario 5 — Admin clicks a rider row**
- Given the rider list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the rider profile screen (#1662) for that rider

**Scenario 6 — Admin paginates the list**
- Given the rider list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 riders are displayed in the same column order

### Out of Scope
- Editing rider account details
- Banning or suspending a rider account
- Exporting the rider list
- Audit logs

### Dependencies
- #1663 — Rider list with search and filters is served (must be live)

---

## [Admin] #1662 — Admin views rider profile
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a rider's full profile and their trip history so that I can understand their account activity.

### Background
The rider profile screen is opened by clicking any row in the rider list (#1661). It presents the rider's personal information at the top, followed by a paginated list of the rider's past trips below. All information is read-only in these sprints. The admin can paginate through the trip history without leaving the profile screen.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin opens a rider profile**
- Given the admin has clicked a rider row in the rider list
- When the profile screen loads
- Then the following information is shown: full name, phone number, registration date, total trips completed, and date of last trip
- And below the profile, a paginated list of the rider's past trips is displayed

**Scenario 2 — Trip history section displays correct columns**
- Given the rider profile is loaded
- When the admin views the trip history table
- Then each row shows: trip date, destination address, fare (EGP), and trip status

**Scenario 3 — Rider has no past trips**
- Given the admin opens the profile of a rider who has never completed a trip
- When the trip history section renders
- Then an empty state message is shown in place of the trip table

**Scenario 4 — Admin paginates the trip history**
- Given the rider has more than one page of past trips
- When the admin navigates to the next page of the trip history
- Then the next page of trips loads within the profile screen

**Scenario 5 — Admin navigates back to the rider list**
- Given the admin is on the rider profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the rider list

### Out of Scope
- Editing rider details
- Banning or suspending the rider
- Viewing trip details from within the profile (trip row is not clickable in this sprint)
- Exporting rider data

### Dependencies
- #1664 — Rider profile with trip history is served (must be live)

---

## [API] #1663 — Rider list with search and filters is served
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, searchable list of riders to the admin portal so that operations admins can browse and locate rider accounts.

### Background
The rider list endpoint is called by the admin portal when the Riders section is opened and on every search keystroke or page change. It requires a valid admin session token. The response includes a page of rider records with the fields needed to render the table. Optional search by name or phone narrows results. Default sort is registration date descending.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests the full rider list**
- Given the admin is authenticated and sends no search parameter
- When the rider list endpoint is called
- Then a paginated list of all riders is returned ordered by registration date descending
- And each record includes: rider ID, full name, phone number, registration date, and completed trip count
- And pagination metadata (page, total pages, total count) is included

**Scenario 2 — Admin requests the list with a name search**
- Given the admin sends a search parameter containing a name substring
- When the endpoint is called
- Then only riders whose name contains that substring (case-insensitive) are returned

**Scenario 3 — Admin requests the list with a phone search**
- Given the admin sends a search parameter containing a phone substring
- When the endpoint is called
- Then only riders whose phone number contains that substring are returned

**Scenario 4 — Search returns no matching riders**
- Given the admin sends a search parameter that matches no rider
- When the endpoint is called
- Then an empty list is returned with total count zero

**Scenario 5 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the rider list endpoint
- Then the request is rejected with an authentication error
- And no rider data is returned

**Scenario 6 — Admin requests a subsequent page**
- Given there are more riders than fit on one page
- When the admin requests page two
- Then the correct slice of rider records for that page is returned

### Out of Scope
- Filtering by registration date range
- Sorting by columns other than registration date
- Exporting results

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1664 — Rider profile with trip history is served
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single rider's profile and paginated trip history to the admin portal so that operations admins can review full account details.

### Background
The rider profile endpoint is called when the admin clicks a rider row in the list. It returns all profile fields needed for the profile screen header and a paginated subset of the rider's trip history. The endpoint requires a valid admin session token. If the requested rider ID does not exist, a not-found response is returned.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests a valid rider profile**
- Given the admin is authenticated and provides a valid rider ID
- When the rider profile endpoint is called
- Then the response includes: full name, phone number, registration date, total trips completed, and last trip date
- And a paginated list of the rider's past trips is included, each with: trip date, destination address, fare (EGP), and status

**Scenario 2 — Rider has no past trips**
- Given the admin requests the profile of a rider with no completed trips
- When the endpoint is called
- Then the profile fields are returned normally
- And the trip history list is empty with total count zero

**Scenario 3 — Admin requests a non-existent rider ID**
- Given the admin provides a rider ID that does not exist in the system
- When the endpoint is called
- Then a not-found response is returned
- And no data is included in the response body

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the rider profile endpoint
- Then the request is rejected with an authentication error

**Scenario 5 — Admin requests a subsequent page of trip history**
- Given the rider has more trips than fit on one page
- When the admin requests page two of the trip history
- Then the correct page of trip records is returned in date descending order

### Out of Scope
- Editing rider fields via this endpoint
- Trip detail fields beyond the list summary
- Exporting profile data

### Dependencies
- #1619 — Session validation (must be live)
- #1641 — Rider retrieves trip history (must be live)

---

## [Admin] #1665 — Admin views driver list across all statuses
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a searchable, filterable list of all driver accounts grouped by status so that I can monitor the driver pipeline and locate any driver quickly.

### Background
The driver list is the primary entry point for driver management in the admin portal. It shows all driver accounts regardless of onboarding status. Status filter tabs or a dropdown allow the admin to narrow results to a single status group (Pending, Approved, or Rejected). A search box allows free-text lookup by name or phone. The default page size is 20 rows. Clicking any row opens the driver profile (#1666).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | 0 chars | 100 chars | Any | Show all drivers (no error) | N/A | Clear input and reset to full list |
| Status filter | No | Enum | N/A | N/A | All, Pending, Approved, Rejected | Show all statuses (default = All) | N/A | N/A |

### Acceptance Criteria

**Scenario 1 — Admin opens the driver list**
- Given the admin is authenticated and navigates to the Drivers section
- When the page loads
- Then a table of all driver accounts is displayed with default filter "All"
- And columns shown are: name, phone number, status, onboarding submission date, total trips completed (for approved drivers)
- And the list is ordered by submission date descending

**Scenario 2 — Admin filters by status "Pending"**
- Given the driver list is loaded
- When the admin selects the "Pending" status filter
- Then only drivers with pending status are shown in the table

**Scenario 3 — Admin filters by status "Approved"**
- Given the driver list is loaded
- When the admin selects the "Approved" status filter
- Then only approved drivers are shown

**Scenario 4 — Admin filters by status "Rejected"**
- Given the driver list is loaded
- When the admin selects the "Rejected" status filter
- Then only rejected drivers are shown

**Scenario 5 — Admin searches by driver name**
- Given the driver list is loaded
- When the admin types a partial name into the search box
- Then the list filters to drivers whose name contains that text

**Scenario 6 — Admin searches by phone number**
- Given the driver list is loaded
- When the admin types a partial phone number
- Then the list filters to drivers whose phone contains that substring

**Scenario 7 — Search and filter produce no results**
- Given the admin has applied a search or filter with no matching drivers
- Then an empty state message is displayed

**Scenario 8 — Admin clicks a driver row**
- Given the driver list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the driver profile screen (#1666) for that driver

**Scenario 9 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 drivers are displayed

### Out of Scope
- Approving or rejecting a driver from this screen
- Suspending or banning a driver
- Exporting the driver list
- Audit logs

### Dependencies
- #1667 — Driver list with status filter and search is served (must be live)

---

## [Admin] #1666 — Admin views driver profile
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a driver's full profile including their documents, vehicle details, and trip history so that I can assess their account comprehensively.

### Background
The driver profile screen is opened by clicking any row in the driver list (#1665). It presents personal details, vehicle information, uploaded document images (viewable inline), current status, aggregate statistics, and — for pending or rejected drivers — the decision history. Below the profile information, a paginated list of the driver's completed trips is shown. All content is read-only on this screen in sprint 2; approve/reject actions remain on the pending queue screens (#1657–#1660).

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin opens an approved driver profile**
- Given the admin has clicked an approved driver row
- When the profile screen loads
- Then the following sections are displayed: personal details (name, phone, date of birth, masked national ID), vehicle details (make, model, plate number, colour), document images (viewable inline), vehicle photo, status badge "Approved", total trips completed, and average rider rating

**Scenario 2 — Admin opens a pending driver profile**
- Given the admin has clicked a pending driver row
- When the profile screen loads
- Then all sections from Scenario 1 are shown with status badge "Pending"
- And a decision history section shows the timeline of status changes with timestamps

**Scenario 3 — Admin opens a rejected driver profile**
- Given the admin has clicked a rejected driver row
- When the profile screen loads
- Then all sections from Scenario 1 are shown with status badge "Rejected"
- And the decision history section shows when and why the application was rejected

**Scenario 4 — Admin views the driver's trip history**
- Given the driver profile is loaded for an approved driver with completed trips
- When the admin scrolls to the trip history section
- Then a paginated list of completed trips is shown with: trip date, destination area, fare collected, and rider rating received

**Scenario 5 — Driver has no completed trips**
- Given the admin opens the profile of a driver with no completed trips
- When the trip history section renders
- Then an empty state message is shown

**Scenario 6 — Admin navigates back to the driver list**
- Given the admin is on the driver profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the driver list at the same filter state

### Out of Scope
- Approving or rejecting a driver from this screen
- Editing driver details
- Suspending or banning a driver
- Exporting profile data

### Dependencies
- #1668 — Driver profile with trip history is served (must be live)

---

## [API] #1667 — Driver list with status filter and search is served
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, filterable list of driver accounts to the admin portal so that operations admins can browse the full driver pipeline by status.

### Background
The driver list endpoint is called when the admin opens the Drivers section and on each filter change, search keystroke, or page change. It requires a valid admin session token. The response includes driver records with the fields needed to render the table. Optional status filter and name/phone search narrow the result set. Default order is submission date descending.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests the full driver list**
- Given the admin is authenticated and sends no filter or search parameter
- When the driver list endpoint is called
- Then a paginated list of all driver accounts is returned ordered by submission date descending
- And each record includes: driver ID, name, phone, status, submission date, and completed trip count
- And pagination metadata is included

**Scenario 2 — Admin filters by status**
- Given the admin sends a status parameter of "pending", "approved", or "rejected"
- When the endpoint is called
- Then only drivers matching that status are returned

**Scenario 3 — Admin searches by name**
- Given the admin sends a search parameter containing a name substring
- When the endpoint is called
- Then only drivers whose name contains that substring (case-insensitive) are returned

**Scenario 4 — Admin searches by phone**
- Given the admin sends a search parameter containing a phone substring
- When the endpoint is called
- Then only drivers whose phone contains that substring are returned

**Scenario 5 — Filter and search return no results**
- Given the admin sends parameters that match no driver
- When the endpoint is called
- Then an empty list is returned with total count zero

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the driver list endpoint
- Then the request is rejected with an authentication error
- And no driver data is returned

**Scenario 7 — Admin requests a subsequent page**
- Given there are more drivers than fit on one page
- When the admin requests page two
- Then the correct slice of driver records is returned

### Out of Scope
- Filtering by registration date range
- Sorting by columns other than submission date
- Exporting results

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1668 — Driver profile with trip history is served
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single driver's full profile and paginated trip history to the admin portal so that operations admins can review complete driver account details.

### Background
The driver profile endpoint is called when the admin clicks a driver row in the list. It returns personal details, vehicle information, document URLs (so the portal can display images inline), current status, average rating, decision history, and a paginated slice of the driver's completed trip history. The endpoint requires a valid admin session token. A not-found response is returned if the driver ID does not exist.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests a valid driver profile**
- Given the admin is authenticated and provides a valid driver ID
- When the driver profile endpoint is called
- Then the response includes: personal details (name, phone, date of birth, masked national ID), vehicle details, document image URLs, vehicle photo URL, current status, total trips completed, average rider rating, and decision history records
- And a paginated list of completed trips is included, each with: trip date, destination area, fare collected, and rider rating received

**Scenario 2 — Driver has no completed trips**
- Given the admin requests the profile of a driver with no completed trips
- When the endpoint is called
- Then the profile fields are returned normally
- And the trip history list is empty with total count zero

**Scenario 3 — Admin requests a non-existent driver ID**
- Given the admin provides a driver ID that does not exist in the system
- When the endpoint is called
- Then a not-found response is returned
- And no data is included in the response body

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the driver profile endpoint
- Then the request is rejected with an authentication error

**Scenario 5 — Admin requests a subsequent page of trip history**
- Given the driver has more trips than fit on one page
- When the admin requests page two
- Then the correct page of trip records is returned in date descending order

### Out of Scope
- Approve or reject actions via this endpoint
- Editing driver fields
- Exporting profile data

### Dependencies
- #1619 — Session validation (must be live)

---

## [Admin] #1669 — Admin sees live summary dashboard
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see a live summary of key platform metrics on the dashboard so that I can monitor the health of the service at a glance.

### Background
The dashboard is the landing page of the admin portal after login. It presents six live key metrics in summary cards: active trips, online drivers, total trips today, total registered riders, and total approved drivers. The metrics refresh automatically every 30 seconds without requiring a page reload. Each card shows a label, a numeric value, and a last-refreshed timestamp.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin lands on the dashboard after login**
- Given the admin has successfully logged in to the portal
- When the dashboard loads
- Then five metric cards are displayed: Active Trips, Online Drivers, Total Trips Today, Total Registered Riders, Total Approved Drivers
- And each card shows a numeric value retrieved from the platform

**Scenario 2 — Metrics refresh automatically**
- Given the admin is viewing the dashboard
- When 30 seconds have elapsed since the last data fetch
- Then each metric card updates to reflect the latest value from the API
- And the last-refreshed timestamp on each card updates accordingly

**Scenario 3 — Admin views zero values on an idle day**
- Given no trips are active and no drivers are online at the moment of load
- When the dashboard renders
- Then the Active Trips and Online Drivers cards display zero
- And other metric cards show their correct non-zero accumulated values

**Scenario 4 — Admin navigates away and returns**
- Given the admin navigates to another section of the portal and then returns to the dashboard
- When the dashboard reloads
- Then the auto-refresh cycle restarts and current metric values are fetched immediately

### Out of Scope
- Historical trend charts or graphs
- Per-city or per-zone breakdowns
- Alerts or thresholds
- Exporting metrics

### Dependencies
- #1673 — Dashboard summary is served (must be live)

---

## [Admin] #1670 — Admin views trip list
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a searchable, filterable list of all trips on the platform so that I can monitor trip activity and investigate specific trips.

### Background
The trip list screen shows all trips across all statuses. The admin can filter by trip status, apply a date range, and search by rider or driver name or phone. Columns provide enough information to identify a trip at a glance. Clicking any row opens the trip detail screen (#1671). The default page size is 20 rows ordered by creation date descending.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | 0 chars | 100 chars | Any | Show all trips (no error) | N/A | Clear input and reset to full list |
| Status filter | No | Enum | N/A | N/A | All, Searching, Active, Completed, Expired | Show all statuses (default = All) | N/A | N/A |
| Date from | No | Date (YYYY-MM-DD) | N/A | N/A | Digits and hyphens | Show no date constraint | Inline error: "Invalid date" | N/A |
| Date to | No | Date (YYYY-MM-DD) | N/A | N/A | Digits and hyphens | Show no date constraint | Inline error: "Invalid date" | N/A — but to-date must not be before from-date; inline error: "End date must be after start date" |

### Acceptance Criteria

**Scenario 1 — Admin opens the trip list**
- Given the admin navigates to the Trips section
- When the page loads
- Then a table of all trips is displayed ordered by creation date descending
- And columns shown are: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, for completed trips), and date

**Scenario 2 — Admin filters by status**
- Given the trip list is loaded
- When the admin selects a status filter (e.g., "Active")
- Then only trips with that status are shown

**Scenario 3 — Admin applies a date range**
- Given the trip list is loaded
- When the admin sets a from-date and a to-date
- Then only trips created within that date range are shown

**Scenario 4 — Admin sets an invalid date range (to before from)**
- Given the admin has set a from-date
- When the admin sets a to-date that is earlier than the from-date
- Then an inline error "End date must be after start date" is displayed
- And the trip list is not filtered until the date range is corrected

**Scenario 5 — Admin searches by rider or driver name**
- Given the trip list is loaded
- When the admin types a partial name into the search box
- Then the list filters to trips where the rider or driver name contains that text

**Scenario 6 — Admin searches by phone**
- Given the trip list is loaded
- When the admin types a partial phone number
- Then the list filters to trips where the rider or driver phone contains that substring

**Scenario 7 — Filters produce no results**
- Given the admin has applied filters that match no trip
- Then an empty state message is displayed

**Scenario 8 — Admin clicks a trip row**
- Given the trip list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the trip detail screen (#1671) for that trip

**Scenario 9 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 trips are displayed

### Out of Scope
- Cancelling a trip from this screen
- Contacting the rider or driver from this screen
- Exporting the trip list
- Surge pricing adjustments

### Dependencies
- #1674 — Trip list with pagination and filters is served (must be live)

---

## [Admin] #1671 — Admin views trip detail with state history
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a trip's full detail and state transition timeline so that I can understand exactly how that trip progressed.

### Background
The trip detail screen is opened by clicking any row in the trip list (#1670). It shows rider and driver information, the pickup and destination addresses, and a chronological timeline of every state the trip passed through with timestamps. The timeline makes it possible to identify where a trip stalled or what sequence of events occurred. The screen is read-only.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin opens a trip that is in progress**
- Given the admin has clicked an active trip row
- When the detail screen loads
- Then rider information (name, phone) and driver information (name, phone, vehicle) are shown
- And pickup and destination addresses are displayed
- And the state timeline shows all transitions up to the current state with timestamps (e.g., Created → Searching → Matched → En route pickup → Arrived → Trip started)

**Scenario 2 — Admin opens a completed trip**
- Given the admin has clicked a completed trip row
- When the detail screen loads
- Then all information from Scenario 1 is shown
- And the timeline includes the "Trip ended" transition with its timestamp
- And the completed trip's additional fare and rating details are shown as per #1672

**Scenario 3 — Admin opens a trip that expired (no driver found)**
- Given the admin has clicked an expired trip row
- When the detail screen loads
- Then the timeline shows the transitions up to "Expired" with its timestamp
- And a note is shown indicating no driver was matched

**Scenario 4 — Admin navigates back to the trip list**
- Given the admin is on the trip detail screen
- When she clicks the back button or breadcrumb
- Then she is returned to the trip list at the same filter state

### Out of Scope
- Manually changing a trip's status
- Contacting rider or driver from this screen
- Refund processing
- SOS event logs

### Dependencies
- #1675 — Trip detail with state history is served (must be live)

---

## [Admin] #1672 — Admin views completed trip with fare and rating
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see the fare breakdown and rider rating on a completed trip's detail screen so that I can verify charges and understand the rider's experience.

### Background
The completed trip detail screen extends the general trip detail screen (#1671) with two additional sections visible only for completed trips: a fare breakdown table and the rider's rating. The fare breakdown shows how the total charge was composed. The rating section shows stars and any tags the rider selected; if the rider skipped rating, it shows "No rating given". The screen remains read-only.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin views fare breakdown for a completed trip**
- Given the admin has opened the detail screen for a completed trip
- When the fare section renders
- Then the following fare line items are displayed: base fare, distance charge, time charge, and total fare (all in EGP)
- And the cash collected amount is shown

**Scenario 2 — Admin views a rated completed trip**
- Given the completed trip was rated by the rider
- When the rating section renders
- Then the star rating (1–5) is displayed
- And any tags the rider selected are shown alongside the stars

**Scenario 3 — Admin views an unrated completed trip**
- Given the completed trip was not rated by the rider
- When the rating section renders
- Then "No rating given" is displayed in place of the stars

**Scenario 4 — Screen remains read-only**
- Given the admin is viewing any completed trip detail
- When she views the fare and rating sections
- Then no edit controls or action buttons are available in these sections

### Out of Scope
- Adjusting or refunding a fare
- Editing or removing a rating
- Contacting rider or driver

### Dependencies
- #1675 — Trip detail with state history is served (must be live)
- #1637 — Trip rating is stored (must be live)

---

## [API] #1673 — Dashboard summary is served
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve live platform metric counts to the admin portal so that the dashboard can display accurate, up-to-date operational summaries.

### Background
The dashboard summary endpoint is called by the admin portal on initial load and every 30 seconds thereafter. It requires a valid admin session token. It computes and returns five live counts at request time: active trips, online drivers, trips created today, total registered riders, and total approved drivers. No caching is required in these sprints — the data is computed fresh on each call.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin portal requests the dashboard summary**
- Given the admin is authenticated
- When the dashboard summary endpoint is called
- Then the response includes: active_trips (count of trips currently in active status), online_drivers (count of drivers currently available), trips_today (count of trips created since midnight local time), total_riders (count of all registered riders), total_approved_drivers (count of all approved drivers)
- And all counts are integers greater than or equal to zero

**Scenario 2 — All metrics are zero on an idle day**
- Given no trips are active, no drivers are online, and no trips have been created today
- When the endpoint is called
- Then all counts return as zero

**Scenario 3 — Counts reflect the current state**
- Given a trip transitions to active status between two calls to the endpoint
- When the endpoint is called after the transition
- Then the active_trips count is incremented accordingly

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the dashboard summary endpoint
- Then the request is rejected with an authentication error
- And no metric data is returned

### Out of Scope
- Historical time-series data
- Per-city or per-zone breakdowns
- Caching or pre-computation
- Alert thresholds

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1674 — Trip list with pagination and filters is served
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, filterable list of all trips to the admin portal so that operations admins can monitor platform activity and find specific trips.

### Background
The trip list endpoint is called when the admin opens the Trips section and on each filter change, search input, or page change. It requires a valid admin session token. Optional parameters include: status filter, date range (from/to), and search string (matched against rider/driver name and phone). Default order is creation date descending with a page size of 20.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests the full trip list**
- Given the admin is authenticated and sends no filter parameters
- When the trip list endpoint is called
- Then a paginated list of all trips is returned ordered by creation date descending
- And each record includes: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, null for non-completed trips), and creation date
- And pagination metadata (page, total pages, total count) is included

**Scenario 2 — Admin filters by status**
- Given the admin sends a status parameter (e.g., "active")
- When the endpoint is called
- Then only trips with that status are returned

**Scenario 3 — Admin filters by date range**
- Given the admin sends a from-date and a to-date
- When the endpoint is called
- Then only trips created within that date range (inclusive) are returned

**Scenario 4 — Admin searches by rider or driver name**
- Given the admin sends a search parameter
- When the endpoint is called
- Then trips where the rider name, driver name, rider phone, or driver phone contains that substring are returned

**Scenario 5 — Filters return no results**
- Given the admin sends parameters that match no trip
- When the endpoint is called
- Then an empty list is returned with total count zero

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the trip list endpoint
- Then the request is rejected with an authentication error
- And no trip data is returned

**Scenario 7 — Admin requests a subsequent page**
- Given there are more trips than fit on one page
- When the admin requests page two
- Then the correct slice of trip records is returned maintaining the applied filters and sort order

### Out of Scope
- Sorting by columns other than creation date
- Exporting results
- Cancelling a trip via this endpoint

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1675 — Trip detail with state history is served
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single trip's full details and state transition history to the admin portal so that operations admins can investigate the full lifecycle of any trip.

### Background
The trip detail endpoint is called when the admin clicks a trip row in the trip list. It returns all information needed to render the trip detail screen: rider and driver information, addresses, all state transition records with timestamps, and — if the trip is completed — the fare breakdown and rider rating. A not-found response is returned if the trip ID does not exist.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests details of an in-progress trip**
- Given the admin is authenticated and provides a valid trip ID for an active trip
- When the trip detail endpoint is called
- Then the response includes: rider info (name, phone), driver info (name, phone, vehicle), pickup address, destination address, and a list of all state transitions with timestamps up to the current state

**Scenario 2 — Admin requests details of a completed trip**
- Given the admin provides a valid trip ID for a completed trip
- When the endpoint is called
- Then all fields from Scenario 1 are returned plus: fare breakdown (base, distance, time, total, cash collected) and rider rating (stars and tags if rated, null if not rated)

**Scenario 3 — Admin requests details of an expired trip**
- Given the admin provides a valid trip ID for an expired trip
- When the endpoint is called
- Then rider info, addresses, and the state transitions up to "Expired" with timestamps are returned
- And driver info is null as no driver was matched

**Scenario 4 — Admin requests a non-existent trip ID**
- Given the admin provides a trip ID that does not exist
- When the endpoint is called
- Then a not-found response is returned
- And no data is included in the response body

**Scenario 5 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the trip detail endpoint
- Then the request is rejected with an authentication error

### Out of Scope
- Modifying trip status via this endpoint
- Real-time streaming of state changes
- SOS event records

### Dependencies
- #1619 — Session validation (must be live)
- #1652 — Trip state transitions are recorded (must be live)
