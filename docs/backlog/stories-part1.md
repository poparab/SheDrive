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
