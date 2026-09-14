# SheDrive — API Stories
> Canonical backlog for all [API] stories. Organized by sprint and feature.
> Last updated: 2026-08-16
> Stories with changes from original are marked ✏️ | New stories marked 🆕

---

## Sprint 1

### Feature 4 — Authentication API (Shared — Rider & Driver)

---

## [API] #1621 — User registers with OTP verification ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want the registration endpoint to verify the submitted OTP and create a new user account with the submitted identity details so that riders and drivers can register securely without a password, receiving a session token and their role on success so the mobile app can route each user type to the correct starting screen.

This registration endpoint is shared by the rider and driver apps. Rider registrations (#1545) submit phone, OTP, and full name only. Driver registrations (#1569) additionally submit a date of birth (age ≥ 18), a 14-digit National ID, and a background-check consent flag, all stored on the driver's profile. Identity fields beyond full name are required for driver registrations and are not expected for rider registrations.

**Scenario 1 — Successful registration creates account and returns session token**
- Given a valid phone, a correct and unexpired OTP, and a valid full name are submitted
- When the endpoint processes the request
- Then a new user account is created with the provided phone and name
- And a session token is returned that is accepted by #1619
- And the response includes the user’s role (rider or driver)
- And the OTP record is consumed and cannot be reused

**Scenario 2 — Phone number already registered auto-logs the user in**
- Given a phone number that is already linked to an existing account is submitted
- When the endpoint processes the request
- Then a user_registered status is returned indicating the number is already registered
- And no duplicate account is created
- And the user is auto logged in with a session token for the existing account

**Scenario 3 — Expired OTP is rejected**
- Given a valid phone and a correct OTP that has passed its 5-minute expiry window
- When the endpoint processes the request
- Then a validation error is returned: OTP has expired, a new code must be requested via #1620
- And no account is created

**Scenario 4 — Wrong OTP increments attempt counter**
- Given a valid phone and an incorrect OTP are submitted
- When the endpoint processes the request
- Then a validation error is returned: OTP is incorrect
- And the wrong-attempt counter for that OTP is incremented by 1

**Scenario 5 — OTP exhausted after 3 wrong attempts**
- Given a phone’s OTP has already accumulated 3 consecutive wrong attempts
- When another registration attempt is made for that phone
- Then an error is returned indicating the code is invalidated and a new one must be requested via #1620
- And no account is created
- And when the user requests a new OTP via #1620 (resend), the new OTP starts with a fresh wrong-attempt counter of 0

**Scenario 6 — Full name validation rules are enforced**
- Given a name containing fewer than 2 characters, more than 50 characters, or containing digits or special characters (e.g. "Fatma2" or "Nadia@")
- When the endpoint processes the request
- Then a validation error is returned identifying the name field and the rule violated
- And the account is not created

**Scenario 7 — Missing or malformed payload fields are rejected**
- Given a request with a missing phone, an OTP that is not 6 digits, or an absent name field
- When the endpoint processes the request
- Then a validation error is returned listing each failing field
- And no account is created

**Scenario 8 — Driver registration response signals onboarding routing**
- Given a driver successfully registers via this endpoint
- When the response is returned
- Then the role field in the response is "driver"
- And the mobile app uses this to route the driver to the onboarding flow rather than the rider home screen

**Scenario 9 — Public endpoint processes unauthenticated requests normally**
- Given no Authorization header is present (this endpoint is public)
- When the endpoint receives the request
- Then the request is processed normally without an authentication check

**Scenario 10 — OTP resend resets the wrong-attempt counter**
- Given a user has made one or more wrong OTP attempts (including reaching the 3-attempt limit)
- When she requests a new OTP via #1620 (resend)
- Then the old OTP is invalidated and can no longer be submitted
- And a new OTP is issued with a wrong-attempt counter of 0
- And the user has a full 3 fresh attempts on the new code

**Scenario 11 — Driver registration stores date of birth, National ID, and consent**
- Given a driver registration with a valid phone, a correct OTP, a valid full name, a date of birth (age ≥ 18), a 14-digit National ID, and background-check consent = true
- When the endpoint processes the request
- Then a new account is created and the date of birth, National ID, and consent are stored on the driver's profile
- And a session token and role "driver" are returned

**Scenario 12 — Driver registration missing an identity field is rejected**
- Given a driver registration missing the date of birth, the National ID, or the consent flag
- When the endpoint processes the request
- Then a validation error is returned identifying each missing field
- And no account is created

**Scenario 13 — Date of birth must be 18 or older**
- Given a driver registration whose date of birth corresponds to an age under 18
- When the endpoint processes the request
- Then a validation error is returned indicating the minimum age is 18
- And no account is created

**Scenario 14 — National ID must be exactly 14 digits**
- Given a driver registration with a National ID that is not exactly 14 digits or contains non-digit characters
- When the endpoint processes the request
- Then a validation error is returned identifying the National ID field
- And no account is created

**Scenario 15 — Rider registration does not require identity fields**
- Given a rider registration with a valid phone, a correct OTP, and a valid full name only
- When the endpoint processes the request
- Then the account is created without requiring a date of birth, National ID, or consent

---

## [API] #1622 — User logs in with OTP verification ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want the login endpoint to verify the submitted OTP for a registered phone number and return a session token so that returning riders and drivers are authenticated, with the response including role and — for drivers — onboarding status so the mobile app can route each user to the correct screen.

**Scenario 1 — Successful login returns session token and role**
- Given a registered phone number and a correct, unexpired OTP are submitted
- When the endpoint processes the request
- Then a session token is returned that is accepted by #1619
- And the response includes the user’s role (rider or driver)

**Scenario 2 — Driver login response includes onboarding status for routing**
- Given a registered driver submits a valid phone and correct OTP
- When authentication succeeds
- Then the response includes the driver’s onboarding status: pending, approved, or rejected
- And an approved status allows the mobile app to route the driver to the home screen
- And a pending or rejected status routes the driver to the status screen (#1576)

**Scenario 3 — Phone number not registered returns not-found**
- Given a phone number that has no registered account is submitted
- When the endpoint processes the request
- Then a not-found error is returned
- And no session token is issued

**Scenario 4 — Expired OTP is rejected**
- Given a registered phone and an OTP that has passed its 5-minute expiry
- When the endpoint processes the request
- Then a validation error is returned: OTP has expired, a new code must be requested
- And no session token is issued

**Scenario 5 — Wrong OTP increments attempt counter**
- Given a registered phone and an incorrect OTP are submitted
- When the endpoint processes the request
- Then a validation error is returned: OTP is incorrect
- And the wrong-attempt counter for that OTP is incremented by 1

**Scenario 6 — OTP exhausted after 3 wrong attempts**
- Given a phone’s OTP has accumulated 3 consecutive wrong attempts
- When another login attempt is made for that phone
- Then an error is returned indicating the code is invalidated and a new one must be requested via #1620
- And when the user requests a new OTP via #1620 (resend), the new OTP starts with a fresh wrong-attempt counter of 0

**Scenario 7 — Missing or malformed fields are rejected**
- Given a request with a missing or empty phone field, or a missing or non-6-digit OTP
- When the endpoint processes the request
- Then a validation error is returned identifying each failing field

**Scenario 8 — Public endpoint processes unauthenticated requests normally**
- Given no Authorization header is present (this endpoint is public)
- When the endpoint receives the request
- Then the request is processed normally without an authentication check

**Scenario 9 — OTP resend resets the wrong-attempt counter**
- Given a user has made one or more wrong OTP attempts (including reaching the 3-attempt limit)
- When she requests a new OTP via #1620 (resend)
- Then the old OTP is invalidated and can no longer be submitted
- And a new OTP is issued with a wrong-attempt counter of 0
- And the user has a full 3 fresh attempts on the new code

---

## [API] #1623 — User retrieves own profile
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

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
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want the logout endpoint to invalidate the caller's session token and deregister the device push token so that the user's account is secured after logout, with online drivers automatically set to offline before the session is invalidated.

**Scenario 1 — Session is invalidated and push token is deregistered**
- Given a valid session token is present in the Authorization header
- When the logout endpoint is called
- Then the session token is marked as invalidated in the session store
- And the push notification device token associated with this session is removed
- And a success response is returned

**Scenario 2 — Online driver is automatically set offline before session invalidation**
- Given the authenticated user is a driver whose availability status is online
- When the logout endpoint is called
- Then the platform first sets the driver's availability status to offline via the same logic as #1645
- And only after the status update succeeds is the session token invalidated
- And a success response is returned

**Scenario 3 — Already-offline driver logs out cleanly**
- Given the authenticated user is a driver whose availability status is already offline
- When the logout endpoint is called
- Then no availability change is made
- And the session is invalidated and push token deregistered normally

**Scenario 4 — Subsequent requests with the invalidated token are rejected**
- Given a session has been invalidated by this endpoint
- When any subsequent request to a protected endpoint is made using the same token
- Then #1619 auth middleware rejects the request



**Scenario 5 — Unauthenticated request is rejected**
- Given no Authorization header or an invalid token is present
- When the endpoint receives the request
- Then the request is rejected by #1619 auth middleware before any logout action is taken

---

## [API] #1728 — User changes language preference from profile screen 🆕
**Feature:** Feature 4 — Authentication API | **Sprint:** 2

**Description:** As the rider app and driver app, I want to store and retrieve the authenticated user's language preference so that the correct language is applied consistently across sessions and devices.

### Background

This endpoint serves both the rider and driver apps. It supports GET (retrieve current preference) and PUT (update preference). Accepted values are 'ar' (Arabic, default) and 'en' (English). The preference is stored on the user's account record and returned on login so the app can apply the correct locale immediately on launch.

### Acceptance Criteria

**Scenario 1 — GET: Preference is returned for authenticated user**
- Given an authenticated user sends a GET request
- When the endpoint is called
- Then the response includes the current language preference: 'ar' or 'en'

**Scenario 2 — PUT: Preference updated to English**
- Given an authenticated user sends PUT with language: 'en'
- When the endpoint is called
- Then the preference is saved and the response confirms the update

**Scenario 3 — PUT: Preference updated to Arabic**
- Given an authenticated user sends PUT with language: 'ar'
- When the endpoint is called
- Then the preference is saved and the response confirms the update

**Scenario 4 — PUT: Invalid language value is rejected**
- Given an authenticated user sends PUT with an unsupported language code
- When the endpoint is called
- Then the platform returns a validation error

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

### Out of Scope
- Languages other than 'ar' and 'en'
- Per-notification language overrides

### Dependencies
- #1619 — Authentication service (must be live)

---

## [API] #1800 — Driver retrieves her profile 🆕
**Feature:** Feature 4 — Authentication API | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the authenticated driver's verified profile so that the driver can view her personal, vehicle, and account details.

### Background

This is a read-only GET on the driver profile endpoint. It returns the driver's profile photo URL, full name, phone number, date of birth, masked National ID (last 4 digits only), vehicle details (make, model, year, color, plate number, vehicle type), onboarding/account status, aggregate rating summary, and language preference. There is no update operation in this phase: profile and vehicle data are verified during onboarding and are immutable from the app; corrections are handled operationally. The endpoint requires a valid driver session (#1744). The National ID is always returned masked; the full value is never exposed to the app.

### Acceptance Criteria

**Scenario 1 — GET: driver retrieves her profile**
- Given an authenticated driver sends a GET request to the driver profile endpoint
- When the endpoint is called
- Then the response includes profile photo, full name, phone number, date of birth, National ID, and vehicle details (make, model, year, color, plate, type)
- And the onboarding/account status and aggregate rating summary are included



**Scenario 2 — No update operation is exposed**
- Given a PATCH or PUT request is sent to the driver profile endpoint
- When the endpoint processes it
- Then the request is rejected as unsupported in this phase
- And no profile or vehicle field is changed

**Scenario 3 — Language preference is included**
- Given the driver has a stored language preference
- When she retrieves her profile
- Then the response includes her language preference (defaulting to "ar" when unset)

**Scenario 4 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- When it targets this endpoint
- Then the platform rejects the request via #1744

### Out of Scope
- Profile or vehicle field updates
- Document re-upload
- Phone number change
- Returning the full unmasked National ID to the app

### Dependencies
- #1744 — Auth middleware validates session tokens (must be live)
- #1786 — Driver retrieves her aggregate rating summary (rating data, related)

---

### Feature 7 — Rider Home, Address Search & Fare Estimate

---

## [API] #1628 — Fare calculation engine (zone rate card + base/per-km/per-min + minimum fare)
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the SheDrive fare service, I want a single fare-calculation engine that resolves a pickup location to its zone rate card, applies the base + per-km + per-minute formula, and enforces the zone minimum fare, so that every fare estimate and confirmed trip is priced consistently and correctly.

### Background

This is the internal fare-calculation engine used by the fare estimate (#1627) and the trip-completion fare finalization (#1636). Pricing is zone-based: the engine first resolves the pickup coordinates to a service zone and its rate card, then applies the formula **fare = base_fare + (distance_km × per_km_rate) + (duration_min × per_min_rate)**, then enforces the zone minimum fare as a floor. If coordinates fall outside all zones, the trip is blocked (no fallback zone); resolution when coordinates fall inside overlapping zones is handled separately by #1829. All rate-card values (base fare, per-km, per-min, minimum fare, cancellation fee) are VAT-inclusive and admin-configurable without a code deployment. The engine returns a VAT-inclusive total in EGP rounded to 2 decimal places.

### Acceptance Criteria

**Scenario 1 — Coordinates match a single zone**
- Given pickup coordinates that fall within exactly one defined zone
- When the engine resolves the zone
- Then it uses that zone's rate card (base fare, per-km, per-min, minimum fare, cancellation fee)

**Scenario 2 — Coordinates outside all zones**
- Given pickup coordinates outside every defined zone
- Then the request is rejected with HTTP 422 and error code PICKUP_OUTSIDE_SERVICE_AREA

**Scenario 3 — Zone exists but has no rate card**
- Given coordinates that match a zone with no rate card configured
- Then the request is rejected with HTTP 422 and error code ZONE_RATE_CARD_MISSING

**Scenario 4 — Coordinates missing or malformed**
- Given a request with missing or non-numeric lat/lng values
- Then the request is rejected with HTTP 400 and a validation error

**Scenario 5 — Fare computed from the rate card**
- Given a resolved rate card and a trip distance and duration
- When the fare is calculated as base_fare + (distance_km × per_km_rate) + (duration_min × per_min_rate)
- Then the formula result is produced before the minimum-fare floor is applied

**Scenario 6 — Zero distance or duration (edge case)**
- Given distance = 0 km and duration = 0 minutes
- Then the formula result equals the base fare only and no error occurs

**Scenario 7 — Formula result is below the minimum fare**
- Given a short trip whose formula result is less than the zone minimum fare
- Then the minimum fare is charged instead and minimum_fare_applied = true

**Scenario 8 — Formula result at or above the minimum fare**
- Given a trip whose formula result is greater than or equal to the minimum fare
- Then the formula result is returned and minimum_fare_applied = false

**Scenario 9 — Fare is VAT-inclusive**
- Given any calculated fare
- Then the returned amount is the total the rider pays with no VAT added on top, labelled VAT-inclusive

**Scenario 10 — Rates are configurable without code change**
- Given an admin updates a rate-card value (#1757)
- When the next fare calculation runs
- Then the new value is used without a code deployment

**Scenario 11 — Identical fare in estimate and completion**
- Given the same zone, distance, and duration are passed during fare estimate (#1627) and trip completion (#1636)
- Then the calculated fare is identical in both contexts

**Scenario 12 — Fare response format**
- The response includes: total_fare (EGP, 2 decimal places), zone_id, zone_name, distance_km, duration_min, minimum_fare_applied (boolean)

### Out of Scope
- Overlapping-zone resolution — smallest-zone selection (see #1829)
- Surge pricing or dynamic rate multipliers
- Time-of-day multipliers
- Discount codes or promotions
- Per-vehicle-type rate differentiation (future sprint)
- Itemised fare breakdown shown to the rider (total only per design decision)
- Adding VAT on top of rate-card values

### Dependencies
- #1756 — Super admin manages service zones (must be live)
- #1757 — Super admin configures zone rate card (must be live)
- #1829 — Fare engine resolves overlapping service zones to the smallest zone

---

### Feature 5 — Driver Onboarding API

---

## [API] #1642 — Driver submits onboarding application ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a developer, I want the onboarding submission endpoint to accept the driver's complete application payload — personal details, vehicle details, background-check consent, four document files, the driving licence number, the driving licence expiry date, the vehicle registration expiry date, vehicle photo, and profile photo — and create a pending application record so that the admin can review and approve or reject the driver before she can go online.

**Scenario 1 — Valid application creates a pending record**
- Given an authenticated driver with no existing application submits a complete, valid multipart payload including all required fields and files
- When the endpoint processes the request
- Then an application record is created with status = pending
- And the response includes the application ID and status

**Scenario 2 — Personal details validation — name rules enforced**
- Given the driver submits a name shorter than 2 characters, longer than 50 characters, or containing digits or special characters
- When the endpoint processes the request
- Then a validation error is returned identifying the name field and the rule violated
- And no application record is created

**Scenario 3 — Personal details validation — driver must be at least 18 years old**
- Given the driver submits a date of birth that makes her younger than 18 years old at the time of submission
- When the endpoint processes the request
- Then a validation error is returned: driver must be at least 18 years old

**Scenario 4 — Personal details validation — National ID must be exactly 14 digits**
- Given the driver submits a National ID that is not exactly 14 numeric digits
- When the endpoint processes the request
- Then a validation error is returned identifying the NID field

**Scenario 5 — Vehicle details validation — required fields enforced**
- Given the driver submits a payload missing vehicle make, model, plate number, color, or vehicle type
- When the endpoint processes the request
- Then a validation error is returned identifying each missing field

**Scenario 6 — Vehicle year must be between 2010 and the current year**
- Given the driver submits a vehicle year before 2010 or after the current calendar year
- When the endpoint processes the request
- Then a validation error is returned: vehicle year is out of the accepted range

**Scenario 7 — Vehicle type must be one of the accepted values**
- Given the driver submits a vehicle type other than Sedan, SUV, or Minivan
- When the endpoint processes the request
- Then a validation error is returned listing the accepted vehicle types

**Scenario 8 — File too large returns error identifying the offending field**
- Given the driver submits any file (document, vehicle photo, or profile photo) exceeding 10 MB
- When the endpoint processes the request
- Then a validation error is returned naming the offending file field
- And no application record is created

**Scenario 9 — Invalid file type returns error for the specific field**
- Given the driver submits a document file that is not JPEG, PNG, or PDF, or a photo that is not JPEG, PNG, or HEIC
- When the endpoint processes the request
- Then a validation error is returned naming the invalid-type field

**Scenario 10 — Profile photo is required for gender verification**
- Given the driver submits the application payload without a profile photo
- When the endpoint processes the request
- Then a validation error is returned: profile photo is required
- And no application record is created

**Scenario 11 — Duplicate submission returns conflict**
- Given a driver who has already submitted an application attempts to submit again
- When the endpoint processes the request
- Then a conflict error is returned: an application already exists for this account
- And no second application record is created

**Scenario 12 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- Then the request is rejected and no application record is created

**Scenario 13 — Background-check consent must be accepted**
- Given the driver submits the application payload without the background-check consent flag set to accepted
- When the endpoint processes the request
- Then a validation error is returned: background-check consent is required
- And no application record is created

**Scenario 14 — Driving licence number is required and length-checked**
- Given the driver submits a payload with a missing driving licence number, or one shorter than 6 or longer than 20 characters
- When the endpoint processes the request
- Then a validation error is returned identifying the driving licence number field
- And no application record is created

**Scenario 15 — Driving licence expiry is required and must be a future date**
- Given the driver submits a payload with a missing driving licence expiry date, or an expiry date that is today or in the past
- When the endpoint processes the request
- Then a validation error is returned: the driving licence is missing an expiry date or has expired
- And no application record is created

**Scenario 16 — Vehicle registration expiry is required and must be a future date**
- Given the driver submits a payload with a missing vehicle registration expiry date, or an expiry date that is today or in the past
- When the endpoint processes the request
- Then a validation error is returned: the vehicle registration is missing an expiry date or has expired
- And no application record is created

---

## [API] #1643 — Driver queries onboarding status
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a developer, I want the onboarding status endpoint to return the driver's current application status so that the mobile app can route the driver to the correct screen on every app open — onboarding flow, pending screen, home screen, or rejection notice.

**Scenario 1 — Status is pending**
- Given an authenticated driver whose application status is pending
- When the app calls this endpoint
- Then the server returns status = "pending"
- And the mobile app routes the driver to the "Application under review" screen
- And no driver home, map, or trip UI is accessible

**Scenario 2 — Status is approved**
- Given an authenticated driver whose application has been approved
- When the app calls this endpoint
- Then the server returns status = "approved"
- And the mobile app routes the driver to the driver home screen

**Scenario 3 — Status is rejected**
- Given an authenticated driver whose application has been rejected
- When the app calls this endpoint
- Then the server returns status = "rejected" and the rejection reason text
- And the mobile app routes the driver to the rejection notice screen where the reason is visible

**Scenario 4 — No application exists**
- Given an authenticated driver who has not yet submitted an application
- When the app calls this endpoint
- Then a not-found response is returned
- And the mobile app keeps the driver in the onboarding wizard

**Scenario 5 — Pending driver cannot bypass status check to reach home screen**
- Given a driver with application status = pending navigates to the home screen
- When the app checks status via this endpoint on every open
- Then she is routed to the pending screen regardless of her navigation attempt

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- Then the request is rejected

---

## [API] #1644 — Driver onboarding decision — go-online gate + approval/rejection push
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a developer, I want the availability endpoint to reject any attempt by a non-approved driver to set her status to online so that only verified, approved drivers can receive trip requests and unverified drivers cannot bypass the onboarding gate.

**Scenario 1 — Pending driver cannot go online**
- Given an authenticated driver whose application status is pending
- When she sends a request to set status = "online" (#1645)
- Then the server returns a forbidden error: application not yet approved
- And her availability remains offline
- And the mobile app shows a message explaining she must wait for approval

**Scenario 2 — Rejected driver cannot go online**
- Given an authenticated driver whose application status is rejected
- When she sends a request to set status = "online"
- Then the server returns a forbidden error: application was not approved
- And the mobile app shows the rejection notice with the admin's reason

**Scenario 3 — Approved driver can go online without obstruction**
- Given an authenticated driver whose application status is approved
- When she sends a request to set status = "online"
- Then this guard does not block the request
- And the availability endpoint (#1645) processes it normally

**Scenario 4 — No application — driver cannot go online**
- Given an authenticated driver who has submitted no application at all
- When she attempts to go online
- Then the server returns a forbidden error

**Scenario 5 — Suspended driver cannot go online**
- Given an authenticated driver whose account status is suspended
- When she sends a request to set status = "online" (#1645)
- Then the server returns a forbidden error: account suspended
- And her availability remains offline
- And the mobile app shows a message that her account is suspended, including the admin's reason when available

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- Then the request is rejected

**Scenario 7 — Going offline is never blocked by the onboarding gate**
- Given an authenticated driver whose application status is pending, rejected, approved, or not yet submitted
- When she sends a request to set status = "offline" (#1645)
- Then this guard does not block the request
- And the availability endpoint (#1645) processes the offline request normally

**Scenario 8 — Suspended driver can still go offline**
- Given an authenticated driver whose account status is suspended
- When she sends a request to set status = "offline"
- Then this guard does not block the request
- And her availability is set to offline



### Dependencies
- #1618 — Push notification service
- #1645 — Driver sets availability status (the gate protects this)
- #1643 — Driver queries onboarding status (fallback when push is missed)

---

### Feature 6 — Driver Home & Availability API

---

## [API] #1646 — Driver updates GPS location
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a developer, I want the GPS location update endpoint to accept the driver's current coordinates every 5 seconds while she is online so that the platform can use her live position for matching and the rider can track her approach in real time.

**Scenario 1 — Valid coordinates update the driver's live position**
- Given an authenticated, online driver
- When she sends valid latitude (−90 to 90) and longitude (−180 to 180)
- Then the server updates her live position record
- And returns a success response
- And the position is immediately available to the matching engine and to the rider's live trip screen

**Scenario 2 — Location updates every 5 seconds while online**
- Given the driver is online with GPS signal available
- When the mobile app sends a location update
- Then the server stores the new coordinates against the driver's live position record
- And the rider app polling via #1633 reflects the new position within 5 seconds

**Scenario 3 — Missing latitude or longitude returns validation error**
- Given the driver sends a request with latitude or longitude absent
- Then the server returns a validation error identifying the missing field

**Scenario 4 — Out-of-range coordinate is rejected**
- Given the driver sends a latitude greater than 90 or less than −90, or a longitude outside −180 to 180
- Then the server returns a validation error

**Scenario 5 — GPS signal lost — mobile app pauses updates**
- Given the driver is online but GPS signal is lost or accuracy falls below the acceptable threshold
- When the mobile app detects signal loss
- Then it pauses sending updates to this endpoint
- And displays a warning to the driver
- And resumes sending updates automatically when the signal is restored

**Scenario 6 — Driver goes offline — updates stop**
- Given the driver is online and sending GPS updates
- When she goes offline (#1645)
- Then the mobile app stops calling this endpoint immediately
- And no further position updates are stored against that driver session

**Scenario 7 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

---

## [API] #3996 — Driver go-online is blocked while her outstanding balance is over the limit 🆕
**Feature:** Feature 6 — Driver Home & Availability API | **Sprint:** Phase 1

**Description:** As the availability service, I want to refuse to put a driver online while she owes the platform more than the configured limit so that the platform's uncollected cash exposure per driver is capped and settlement actually happens.

### Background

On cash trips the driver keeps the fare and owes the platform its commission (#3991). Without a ceiling that debt grows indefinitely and the platform's only recourse is chasing the driver. This story adds a **balance gate** to the existing go-online check.

The gate compares the driver's **outstanding** balance against the outstanding balance limit configured in #3994. When the outstanding amount is **at or above** the limit, the availability service refuses to set her online and returns the amount owed and the limit so the app can explain the block and tell her what to settle (#3988). Setting the limit to zero disables the gate entirely.

**This gate is additive.** It runs after the existing approval gate (#1644) — an unapproved driver is still blocked for that reason first, and the response names only one blocking reason, approval taking precedence.

**A driver already online is never knocked offline mid-trip.** The gate is evaluated when she asks to go online, not continuously. If her balance crosses the limit while she is online, she completes the trip in hand and is refused the next time she goes online.

**Settling unblocks immediately.** The gate reads the live balance, so the moment a settlement is recorded (#1813) and brings her below the limit, her next go-online attempt succeeds with no admin action.

### Acceptance Criteria

**Scenario 1 — Driver below the limit goes online normally**
- Given the outstanding balance limit is 500 EGP and the driver owes 120 EGP
- When she requests to go online (#1645)
- Then she is set online and no balance warning is returned

**Scenario 2 — Driver at or above the limit is blocked**
- Given the limit is 500 EGP and the driver owes 500 EGP
- When she requests to go online
- Then the request is refused, her status stays offline, and the response returns the amount owed, the limit, and a balance-limit-reached reason

**Scenario 3 — Limit of zero disables the gate**
- Given the outstanding balance limit is configured as 0
- When any driver requests to go online regardless of what she owes
- Then the balance gate does not block her

**Scenario 4 — A positive balance never blocks**
- Given the platform owes the driver 400 EGP
- When she requests to go online
- Then the balance gate does not block her — only an outstanding amount can

**Scenario 5 — Approval gate takes precedence**
- Given a driver who is not yet approved and also over the balance limit
- When she requests to go online
- Then she is refused for the approval reason (#1644) and only that reason is returned

**Scenario 6 — Driver already online is not knocked offline**
- Given an online driver whose outstanding balance crosses the limit mid-shift
- Then she is not forced offline and any trip in progress continues to completion
- And her next go-online request is refused by the gate

**Scenario 7 — Settlement unblocks the driver immediately**
- Given a blocked driver owes 500 EGP against a 500 EGP limit
- When Finance records a 200 EGP settlement (#1813)
- Then her next go-online request succeeds with no further admin action

**Scenario 8 — Blocked driver receives no trip offers**
- Given a driver was refused go-online by the balance gate
- Then she remains offline and the matching engine does not dispatch trips to her (#1630)

**Scenario 9 — Limit change applies to the next attempt**
- Given the super admin lowers the limit (#3994) while a driver is offline and below the old limit
- When she next requests to go online
- Then the new limit is applied

**Scenario 10 — Unauthenticated request is rejected**
- Given a request without a valid driver session token
- Then it is rejected

### Out of Scope
- The driver-facing blocked screen and its copy (#3988)
- Forcing an online driver offline when she crosses the limit
- Automatic suspension of a driver who stays over the limit (Phase 2)
- In-app settlement payment by the driver
- Per-driver or per-zone balance limits — the limit is a single global value (#3994)

### Dependencies
- #3991 — Party balance ledger records every balance movement (must be live — supplies the outstanding amount)
- #3994 — Super admin configures balance and fee policy (must be live — supplies the limit)
- #1645 — Driver availability status (the go-online request this gate runs inside)
- #1644 — Driver onboarding decision — go-online gate (approval gate, evaluated first)

---

## Sprint 2

### Feature 8 — Trip Request & Matching API

---

## [API] #1629 — Rider creates trip request
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As a developer, I want the trip request creation endpoint to accept the rider's confirmed pickup and destination and create a searchable trip record so that the matching engine can begin finding a nearby available driver immediately.

**Scenario 1 — Valid request creates a trip record in searching state**
- Given an authenticated rider submits a valid pickup coordinate, destination coordinate, estimated fare, and distance
- When the endpoint processes the request
- Then a trip record is created with status = searching
- And the response includes the trip ID so the rider app can begin polling via #1633
- And the matching engine begins searching for a nearby available driver

**Scenario 2 — Missing pickup or destination returns validation error**
- Given the rider submits a request without a pickup coordinate or without a destination coordinate
- When the endpoint processes the request
- Then a validation error is returned identifying the missing field
- And no trip record is created



**Scenario 3 — Rider already has an active trip**
- Given the rider already has a trip in searching, matched, or in-progress state
- When she attempts to create another trip
- Then a conflict error is returned: an active trip already exists for this account
- And no second trip record is created



**Scenario 4 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected and no trip record is created

**Trip-request validation guards — merged from #1763**

Two pre-acceptance guards protect the trip-request flow. **Service-area guard:** there is no fallback zone — if pickup coordinates fall outside every configured zone the request is blocked at both the fare-estimate and confirmation steps using the same error code. **Operating-hours guard:** SheDrive operates daytime-only in Phase 1 (open decision OD-001); requests outside the configured window are rejected with a localizable service-closed reason and the next opening time. Both windows are configuration-driven. A trip already in progress is never interrupted; only new requests are blocked.

**Scenario 5 — Out-of-zone pickup blocked at fare estimate**
- Given a rider submits a pickup outside all service zones
- When the fare estimate endpoint is called
- Then the response is HTTP 422 with error code PICKUP_OUTSIDE_SERVICE_AREA and the app shows an out-of-area message

**Scenario 6 — Out-of-zone pickup blocked at confirmation**
- Given a rider confirms a trip with a pickup outside all service zones
- When the trip creation endpoint is called
- Then the response is HTTP 422 with error code PICKUP_OUTSIDE_SERVICE_AREA and the trip is not created

**Scenario 7 — In-zone pickup proceeds**
- Given a pickup inside a valid, configured zone
- Then the fare estimate or trip creation proceeds normally with no zone error

**Scenario 8 — Zone deleted while rider is on the booking screen**
- Given a rider has a valid estimate for a zone that is then deleted by an admin
- When the rider confirms the trip
- Then trip creation returns HTTP 422 PICKUP_OUTSIDE_SERVICE_AREA and the app handles it with a user-visible message

**Scenario 9 — Request inside operating hours is accepted**
- Given the current time is inside the operating window
- When a rider submits a trip request
- Then the request proceeds normally

**Scenario 10 — Request outside operating hours is rejected**
- Given the current time is outside the operating window
- When a rider submits a trip request
- Then the request is rejected with a service-closed reason and the next opening time, and no trip is created

**Scenario 11 — In-progress trip not affected by window close**
- Given a trip is already in progress when the operating window closes
- Then the trip continues uninterrupted and only new requests are blocked

**Scenario 12 — Operating window is configuration-driven**
- Given operations updates the operating-hours configuration
- Then the new window is applied without a code change

**Scenario 13 — Boundary at open and close is deterministic**
- Given a request arrives exactly at the opening or closing minute
- Then the accept/reject decision is applied deterministically per the configured boundary rule

### Out of Scope
- Destination-based zone blocking (origin zone only)
- Per-zone operating hours (all zones share one window at MVP)
- Scheduled rides (handled by #1738)
- 24/7 operation

### Dependencies
- #1628 — Fare calculation engine / zone resolution (must be live)
- #1756 — Super admin manages service zones (must be live)
- #1630 — Driver-matching engine (triggered on creation)
- Open decision OD-001 — operating hours

---

## [API] #1630 — Driver-matching engine (nearest-by-ETA dispatch + reassignment on reject/timeout) ✏️
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically match a trip request to the available driver with the shortest ETA to the pickup point and, when she rejects or times out, reassign it to the next driver in ETA order, so that the rider is connected as quickly as possible and no request is abandoned silently.

### Background

This is the internal matching/dispatch engine, triggered immediately after a trip request is created (#1629). It is not called directly by any client app.

**Candidate pool.** For each searching trip the engine builds a candidate pool: drivers who are online, approved, and not currently assigned to a trip, whose estimated driving time (ETA) to the pickup point is 15 minutes or less. Candidates are ranked ascending by ETA (shortest first) and the pool is capped at the 20 lowest-ETA drivers. ETA is computed once at pool construction and is not recomputed mid-search.

**Proximity is measured in time, never in distance.** Both the eligibility filter and the ranking use estimated driving time (ETA) to the pickup point — the traffic-aware duration from the routing service (#1747 / #1617). Straight-line or road distance in km is never used to decide who gets offered a trip, and "nearest driver" throughout this backlog always means *lowest ETA to pickup*, not *fewest kilometres away*.

**Dispatch loop.** The engine walks the ranked list from the top, dispatching the trip to one driver at a time via #1648 with an acceptance window equal to the value configured by the super admin (#1759, default 30 seconds). On rejection (#1650) or expiry of that window, the engine advances to the next driver in the list. There is no separate "tried" list — the engine simply moves down the ranked list in order; a driver who rejects or times out is passed over and stays online and eligible for other trips.

**A driver may be on multiple pools at once.** While a driver has no assigned trip she can appear in the candidate pools of several pending trips at the same time, and more than one trip may be attempting her concurrently. The first trip she accepts wins: the moment she accepts (#1649) and is assigned, she is removed from the candidate pool of every other pending trip, and any in-flight dispatch to her on another trip is cancelled so that trip advances to its next candidate.

**Expiry is list-driven, not time-driven.** A trip is marked expired only when the engine reaches the end of its candidate list with no acceptance, or the pool was empty at construction. There is no overall search timer. Once expired, the rider sees status "expired" on her next poll (#1631) and the matching screen shows the no-driver state.

**Rider transparency.** While searching, the engine publishes the driver currently being attempted so the rider app can show "trying with [driver]" via #1631 / #1554.

### Acceptance Criteria

**Scenario 1 — Candidate pool is built by ETA to pickup (cap 20)**
- Given a trip request enters "searching" status
- When the engine builds the candidate pool
- Then only online, approved drivers not currently assigned to a trip are considered
- And each candidate's ETA to the pickup point is computed
- And any driver whose ETA to pickup is greater than 15 minutes is excluded
- And the remaining drivers are ranked ascending by ETA (shortest first) and the pool is capped at the 20 lowest-ETA drivers
- And distance in kilometres is not used for either the filter or the ranking

**Scenario 2 — Nearest-by-ETA driver is dispatched first**
- Given a candidate pool exists
- When the engine begins dispatching
- Then the trip is dispatched to the driver at the top of the ranked list (#1648) with an acceptance window equal to the configured value (#1759, default 30 seconds)

**Scenario 2a — A closer-in-km driver with a worse ETA is not preferred**
- Given driver A is 2 km from the pickup with an ETA of 12 minutes and driver B is 6 km away with an ETA of 7 minutes
- When the engine ranks the candidate pool
- Then driver B is ranked above driver A and is dispatched first, because ranking is by ETA and not by distance

**Scenario 3 — Each attempted driver is published to the rider's app**
- Given the engine dispatches the trip to a driver
- Then the driver currently being attempted is made available to the rider app (via #1631) and can be shown on the matching screen (#1554)
- And when the engine moves to the next driver, the updated driver-being-attempted is published

**Scenario 4 — Driver rejects — engine advances to the next driver**
- Given the dispatched driver rejects the trip (#1650)
- Then the engine immediately dispatches to the next driver in the ranked list (#1648)

**Scenario 5 — Acceptance window elapses — engine advances to the next driver**
- Given the configured acceptance window (default 30 seconds) elapses with no Accept or Reject
- When the server-side timer expires
- Then the engine dispatches to the next driver in the ranked list (#1648)

**Scenario 6 — Rejecting or timed-out driver stays online**
- Given a driver rejected or timed out on a trip
- Then her availability remains online and she stays eligible for other trips and pools

**Scenario 7 — A driver may appear on multiple trips' pools at once**
- Given a driver is online, approved, and has no assigned trip
- When more than one pending trip is searching and she is within 15 minutes ETA of each pickup
- Then she may be included in the candidate pool of each of those trips
- And more than one trip may attempt her at the same time

**Scenario 8 — Driver accepts one trip — removed from all other pools**
- Given a driver is a candidate (or is being attempted) on more than one pending trip
- When she accepts one trip (#1649) and is assigned to it
- Then she is removed from the candidate pool of every other pending trip
- And any in-flight dispatch to her on another trip is cancelled and that trip advances to its next candidate

**Scenario 9 — Assigned driver is not eligible for new pools**
- Given a driver is assigned to or on an active trip
- When the engine builds a candidate pool for any new trip
- Then she is not included

**Scenario 10 — Empty candidate pool — trip expired immediately**
- Given no online, approved, unassigned driver has an ETA to pickup within 15 minutes (the pool is empty at construction)
- Then the trip is marked expired immediately
- And the rider sees status "expired" on her next poll (#1631)

**Scenario 11 — End of candidate list reached — trip expired (list-driven)**
- Given the engine has dispatched to the last driver in the ranked list and none accepted (all rejected or timed out)
- Then the trip is marked expired
- And the rider sees status "expired" on her next poll (#1631)
- And no time-based ceiling is applied — expiry occurs only on list exhaustion

**Scenario 12 — Pool capped at 20 drivers**
- Given more than 20 eligible drivers have an ETA to pickup within 15 minutes
- Then only the 20 drivers with the lowest ETA are included in the pool
- And drivers beyond the top 20 are not attempted for that trip

**Scenario 13 — Acceptance window change applies to new dispatches only**
- Given the super admin changes the acceptance window from 30 to 45 seconds (#1759)
- When the change is saved while a dispatch is already in flight
- Then the in-flight dispatch keeps the window it was issued with
- And every dispatch issued after the change uses the new window

### Out of Scope
- Driver preference filters (gender, vehicle type)
- Surge pricing
- Batch matching for multiple simultaneous requests
- SOS trip prioritization
- Real-time ETA recomputation mid-search (ETA is computed once at pool construction)
- Any time-based trip expiry or stuck-trip watchdog (expiry is purely list-driven)
- Distance-based (km) candidate filtering or ranking — proximity is always measured as ETA
- Per-zone or per-driver acceptance windows (the window is a single global setting)

### Dependencies
- #1629 — Rider creates trip request (triggers the engine)
- #1645 — Driver online status and location tracking — supplies driver location/ETA inputs (must be live)
- #1747 — Platform selects fastest traffic-aware route (supplies the ETA used for filtering and ranking)
- #1759 — Super admin configures the driver acceptance window (supplies the dispatch window duration)
- #1648 — Driver retrieves pending trip request / dispatch to driver (must be live)
- #1649 — Driver accepts trip — assignment removes her from all other pools (must be live)
- #1650 — Driver rejects trip (must be live)
- #1631 — Rider polls for match status — surfaces the driver being attempted and the expired result

---

### Feature 9 — Driver Trip Acceptance API

---

## [API] #1649 — Driver accepts trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a developer, I want the trip acceptance endpoint to confirm the driver's acceptance within the configured acceptance window so that the trip status advances to accepted, the rider is notified, and the driver is directed to the active trip flow.

**Scenario 1 — Successful acceptance within window**
- Given the driver taps Accept and the request reaches the server within the acceptance window (#1759, default 30 seconds)
- When the endpoint processes the acceptance
- Then the trip status is updated to accepted
- And a match-confirmation push notification is sent to the rider via #1634
- And the response directs the driver app to the active trip / navigation-to-pickup screen

**Scenario 2 — Acceptance after server-side window expiry**
- Given the driver taps Accept but the server has already expired the window due to elapsed time or network delay
- When the endpoint processes the request
- Then a conflict error is returned: the acceptance window has expired
- And the driver app shows "This request has expired" and returns the driver to her home screen

**Scenario 3 — Trip already accepted by another driver**
- Given the trip was reassigned and accepted by a different driver before this acceptance arrived
- When the endpoint processes this request
- Then a conflict error is returned
- And the driver app shows the expired message and returns the driver to her home screen

**Scenario 4 — Double-tap prevention**
- Given the driver taps Accept and the request is already in flight
- When a duplicate acceptance request arrives for the same trip and driver
- Then the server is idempotent: a second acceptance for the same trip-driver pair does not create duplicate records or send duplicate notifications

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

**Retrieve dispatched trip request details — merged from #1648**

Before accepting or rejecting, the driver app fetches the dispatched trip's details with the remaining acceptance-window seconds.

**Scenario 6 — Trip request details returned in full**
- Given an authenticated driver has been dispatched a trip and the acceptance window has not yet expired
- When the driver app requests the trip details by ID
- Then the response includes the pickup address, destination summary, estimated distance, estimated fare, and the remaining seconds in the acceptance window
- And the driver app displays all fields with the countdown timer visible

**Scenario 7 — Trip request has already expired**
- Given the acceptance window (default 30 seconds) has already elapsed
- When the driver app requests the details
- Then the server returns a not-found or expired response
- And the driver app shows "Request expired" and returns the driver to her home screen

**Scenario 8 — Trip not dispatched to this driver**
- Given the driver requests details for a trip dispatched to a different driver
- Then the server returns a forbidden or not-found response

**Scenario 9 — Both Accept and Reject actionable while window is open**
- Given the trip details are returned and the window has not expired
- Then both the Accept and Reject (#1650) endpoints are valid targets
- And the app renders both buttons in an active, tappable state

### Dependencies
- #1630 — Driver-matching engine (dispatches the request)
- #1650 — Driver rejects trip
- #1634 — Match-confirmation push to rider
- #1759 — Super admin configures the driver acceptance window (defines the window this endpoint enforces)

---

## [API] #1650 — Driver rejects trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a developer, I want the trip rejection endpoint to record the driver's rejection within the acceptance window so that the trip is returned to the platform for reassignment and the driver's availability is immediately restored.

**Scenario 1 — Successful rejection within window**
- Given the driver taps Reject and the request reaches the server within the acceptance window (#1759, default 30 seconds)
- When the endpoint processes the rejection
- Then the trip is returned to the platform for reassignment via #1651
- And the driver's availability status is set back to online
- And the response directs the driver app to her home screen immediately

**Scenario 2 — Rejection after server-side window expiry**
- Given the driver taps Reject but the server has already expired the window
- When the endpoint processes the request
- Then a conflict error is returned: the acceptance window has already expired
- And the driver app shows a brief "Request already expired" message and returns the driver to her home screen

**Scenario 3 — No penalty applied**
- Given the driver has successfully rejected the trip
- When the platform records the rejection
- Then her online status is preserved
- And no rejection penalty, strike, or negative notification is generated
- And she remains eligible for the next dispatched trip

**Scenario 4 — Double-tap prevention**
- Given the driver taps Reject and the request is already in flight
- When a duplicate rejection arrives for the same trip and driver
- Then the server is idempotent and does not create duplicate records or trigger duplicate reassignments

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

---

### Feature 10 — Active Trip API

---

## [API] #1633 — Rider tracks her active trip: on the way → arrived → in trip → ended ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a rider, I want my active trip screen to follow the driver's real progress on its own — showing her coming, telling me when she has arrived, tracking us to the destination, and taking me to my fare at the end — so that I always know what is happening without refreshing anything or asking the driver.

### Background

This is the single endpoint the rider app polls for the whole active trip. Every screen the rider sees between "driver accepted" and "trip finished" is driven by its response — the app never decides the step on its own, it renders whatever step this endpoint reports.

**Where it starts.** #1631 owns the search: it runs from request until a driver accepts. The moment a driver accepts (#1649), the rider app stops polling #1631 and starts polling this endpoint, whose first status is `en_route_pickup`.

**Each status is a driver action, and each status is a rider screen.** Nothing here is abstract — every status in the table below is written into the trip by a driver tapping a button, and every status has exactly one rider screen that must appear when it does:

| Trip status | The driver step that sets it | What this endpoint returns | The rider screen it drives |
|---|---|---|---|
| `en_route_pickup` | Driver accepted and is driving to the pickup (#1649, #1586) | status, driver coordinates, ETA to pickup | "Your driver is on the way" — her dot moves toward the pickup pin (#1555, #1561) |
| `arrived_pickup` | Driver taps **"I've Arrived"** (#1587) | status + `arrived_at` timestamp, driver coordinates | "Your driver has arrived" — waiting counter running from `arrived_at` (#1559) |
| `trip_started` | Driver confirms the rider has boarded and starts the trip (#1589) | status + `started_at`, driver coordinates | In-trip screen — her dot moves toward the destination, waiting counter stopped (#1561) |
| `trip_ended` | Driver taps **"End Trip"** at the destination (#1591) | status + `ended_at`, final fare ready | Trip summary with the cash fare (#1564) |
| `cancelled` | Rider (#1715) or driver (#1720) cancels | status + `cancelled_by` + reason | Cancellation notice, then back to home (#1719) |

**Every transition is automatic.** The rider never taps anything to move between these screens. When the status in the response changes, the screen changes — no manual refresh, no pull-to-refresh, no rider action of any kind.

**Timestamps, not local timers.** The waiting counter is computed from `arrived_at`, not from when the rider's screen happened to load. If she force-quits and reopens the app while the driver is waiting, the counter resumes at the true elapsed time instead of restarting at 0:00.

**Driver position stays live throughout.** The driver streams GPS every 5 seconds from acceptance to completion (#1646, #1653); this endpoint always returns her most recent fix, so her dot on the rider's map is never more than 5 seconds stale in any status.

### Acceptance Criteria

**Scenario 1 — Polling starts at acceptance and reports en_route_pickup**
- Given a driver has just accepted the rider's trip request
- When the rider app switches from #1631 to this endpoint and polls
- Then the response returns status `en_route_pickup` with the driver's latest coordinates and her ETA to the pickup point
- And the rider app shows the "driver on the way" screen with the driver's dot moving toward the pickup pin

**Scenario 2 — Driver taps "I've Arrived" — rider screen switches itself to the arrived state**
- Given the rider is on the "driver on the way" screen
- When the driver taps "I've Arrived" (#1587) and the rider app next polls
- Then the response returns status `arrived_pickup` together with the `arrived_at` timestamp
- And the rider app transitions to the "Your driver has arrived" screen with no rider action and no manual refresh

**Scenario 3 — Waiting counter runs from arrived_at, not from screen load**
- Given the trip is in `arrived_pickup` and the driver has been waiting for 4 minutes
- When the rider force-quits the app and reopens it, then polls
- Then the response still carries the original `arrived_at` timestamp
- And the waiting counter resumes at 4:00 rather than restarting at 0:00

**Scenario 4 — Driver starts the trip — rider moves to the in-trip screen and the counter stops**
- Given the trip is in `arrived_pickup` with the waiting counter running
- When the driver confirms the rider has boarded and starts the trip (#1589) and the rider app next polls
- Then the response returns status `trip_started` with the `started_at` timestamp and the driver's latest coordinates
- And the rider app switches to the in-trip screen, stops the waiting counter, and shows the driver's dot moving toward the destination

**Scenario 5 — Driver ends the trip — rider is taken to her fare**
- Given the trip is in `trip_started`
- When the driver taps "End Trip" at the destination (#1591) and the rider app next polls
- Then the response returns status `trip_ended` with the `ended_at` timestamp
- And the rider app navigates automatically to the trip summary screen showing the cash fare (#1564)

**Scenario 6 — Trip is cancelled mid-flight — the rider finds out on her next poll**
- Given the trip is in `en_route_pickup` or `arrived_pickup`
- When the driver cancels (#1720) and the rider app next polls
- Then the response returns status `cancelled` with `cancelled_by` and the recorded reason
- And the rider app leaves the active trip screen and shows the cancellation outcome

**Scenario 7 — Driver's position is never more than 5 seconds stale**
- Given the driver is streaming GPS every 5 seconds (#1646, #1653)
- When the rider app polls in any active status
- Then the coordinates returned are the driver's most recent fix
- And their age does not exceed 5 seconds from her last update

**Scenario 8 — Status is reported in order and never goes backwards**
- Given the trip has advanced to a later status
- When the rider app polls
- Then the response never returns an earlier status than one it has already reported for that trip
- And the rider app is never sent back to a screen the trip has already moved past

**Scenario 9 — Driver's GPS is temporarily unavailable**
- Given the driver's device has lost its GPS fix
- When the rider app polls
- Then the current status is still returned so the screen stays correct
- And the driver's last known coordinates are returned with their timestamp so the rider app can show the position as stale rather than blank

**Scenario 10 — Trip not found or not belonging to this rider**
- Given the rider polls with a trip ID that does not exist or belongs to another account
- Then the server returns a not-found or forbidden response

**Scenario 11 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

### Out of Scope
- Writing the trip status — this endpoint only reports it; the driver's actions set it
- The search/matching phase before acceptance (#1631)
- Fare calculation at trip end (#1636) — this endpoint reports that the trip ended, not what it cost
- Cancellation fee logic (#1764) — the reason and `cancelled_by` are reported, the money is not
- Push notifications for these transitions (#1634) — polling and push are separate paths to the same state

### Dependencies
- #1649 — Driver accepts trip (hands the rider app over from #1631 to this endpoint)
- #1587 / #1589 / #1591 — Driver arrival, trip start, and trip end (the driver actions that set each status)
- #1646 — Driver updates GPS location (supplies the live driver coordinates)
- #1653 — Driver streams GPS from acceptance to completion (continuous coordinates through every trip phase)
- #1715 / #1720 — Rider and driver cancellation (set the `cancelled` status this endpoint reports)

> **Open dependency:** the API story that *writes* the `arrived_pickup` and `trip_started` transitions was #1652, which is now **Removed** in ADO with no replacement. This endpoint reads statuses that currently have no owning write story — see the trip-state-transition gap.

---

## [API] #1653 — Driver streams GPS from acceptance to completion
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a developer, I want the driver GPS update endpoint to accept coordinates continuously from the moment the driver accepts a trip through trip completion so that the rider can see the driver's real-time position at every stage of the journey via the live trip polling endpoint (#1633).

**Scenario 1 — GPS updates accepted during en_route_pickup**
- Given the trip is in en_route_pickup state and the driver is streaming GPS every 5 seconds
- When the driver's app sends valid coordinates
- Then the server updates the driver's live position record
- And those coordinates are immediately available to the rider app via #1633
- And the rider sees the driver's dot moving toward the pickup location

**Scenario 2 — GPS updates accepted during trip_started**
- Given the trip is in trip_started state
- When the driver's app sends valid coordinates
- Then the server updates the driver's live position record
- And the rider sees the driver's dot moving toward the destination via #1633

**Scenario 3 — GPS updates stop after trip_ended**
- Given the trip has advanced to trip_ended
- When the driver's app attempts to send further GPS updates for that trip
- Then the server does not store new coordinates against the closed trip
- And no error is returned to the driver app (silent discard)

**Scenario 4 — Valid coordinate ranges enforced**
- Given the driver sends a latitude outside −90 to 90 or a longitude outside −180 to 180
- Then the server returns a validation error
- And the driver's stored position is not updated

**Scenario 5 — GPS signal lost during active trip — app pauses updates**
- Given the driver is on an active trip but GPS signal is lost or accuracy falls below threshold
- When the mobile app detects signal loss
- Then it pauses sending updates to this endpoint
- And displays a warning to the driver
- And resumes sending updates automatically when the signal is restored

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

---

### Feature 11 — Trip Completion & Cash Payment API

---

## [API] #1636 — Trip settlement (final fare + platform commission on completion)
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the trip-completion service, I want to calculate the final fare from the actual route and duration and deduct the platform commission when the driver ends the trip, so that a single settled fare is recorded for the trip and driver net earnings and platform revenue are accurate.

### Background

When the driver advances the trip to *trip_ended* (#1652), the platform settles the trip: the final fare is computed by the fare-calculation engine (#1628) from the actual trip distance and duration, the platform commission is deducted, and the driver's net earnings are recorded. Gross fare, the three fare line items, commission rate, commission amount, and driver net earnings are all stored on the trip record.

**This story ends at storage.** It computes and persists the settlement figures; it does not serve them to any app. Returning the fare to the rider's trip summary and to the driver's cash-collection screen, and recording the driver's cash-collected confirmation, are covered by #3058.

**Commission is a single global percentage** (configured via #1759), and the rate snapshot taken at acceptance time applies — not the rate in force at completion.

**The fare is settled once.** After the settlement figures are stored they are immutable, which is what guarantees that the rider and the driver are later served the same amount.

### Acceptance Criteria

**Scenario 1 — Final fare calculated on trip end**
- Given the driver advances the trip to trip_ended (#1652)
- When the platform processes the state change
- Then the final fare is calculated immediately by the fare engine (#1628) from the actual distance and duration
- And the total fare and its three line items (base fee, distance charge, time charge) are stored on the trip record

**Scenario 2 — Fare is immutable after settlement**
- Given the fare has been calculated and stored
- When any later request attempts to recalculate or overwrite it
- Then the server rejects the modification and the stored fare stands

**Scenario 3 — Fare never falls below the floor**
- Given a trip with zero or near-zero distance and duration
- Then the fare is at least the minimum fare (per #1628) and never zero or negative

**Scenario 4 — Commission calculated and stored on completion**
- Given a trip completes with total fare 100 EGP and commission rate 20%
- Then the trip record stores total_fare=100, commission_rate=20, commission_amount=20, driver_net_earnings=80

**Scenario 5 — Commission rate snapshot taken at acceptance time**
- Given the commission rate is 20% when the driver accepts the trip
- And the super admin changes it to 25% before completion (#1759)
- When the trip completes
- Then commission is calculated at 20% — the rate at acceptance

**Scenario 6 — Commission is not deducted from a cancellation fee**
- Given a trip cancelled with a fee charged
- Then commission is NOT deducted from the cancellation fee — the driver receives her full configured share

**Scenario 7 — Settlement runs only from trip_ended**
- Given a trip that has not reached trip_ended
- When settlement is invoked for it
- Then no fare or commission is calculated or stored, and a conflict or not-ready error is returned

**Scenario 8 — Unauthenticated request is rejected**
- Given a request without a valid session token
- Then it is rejected

### Out of Scope
- Serving the fare and trip summary to the rider (#3058)
- Serving the cash-collection amount to the driver and recording her cash-collected confirmation, including the reset of her availability (#3058)
- Payout disbursement to drivers (wallet/bank integration)
- Commission reporting dashboard (separate admin story)
- Trip-completion push notification
- Receipt generation for the driver
- Fare dispute workflow

### Dependencies
- #1628 — Fare calculation engine (must be live)
- #1652 — Driver advances trip state machine (must be live — supplies the trip_ended trigger)
- #1759 — Super admin configures platform commission (must be live — supplies the commission rate)

---

## [API] #3058 — Completed-trip fare is served to rider and driver (trip summary + cash collection)
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve the stored final fare and trip details to the rider's trip summary and to the driver's cash-collection screen, and to record the driver's cash-collected confirmation, so that both sides see exactly the same amount and the driver is returned to available for her next trip.

### Background

Once a trip reaches *trip_ended* and settlement has run (#1636), the final fare, its line items, and the driver's net earnings are already stored on the trip record. This story covers the two read endpoints that expose those stored values — the rider's completed-trip summary and the driver's cash-collection amount — plus the driver's confirmation that cash was collected.

**No calculation happens here.** Both endpoints return the amount exactly as stored; nothing is recalculated at retrieval time, so the rider and the driver always see the same figure.

**The rider sees the total, never the commission.** Her summary returns the total fare, its three line items (base fee, distance charge, time charge), the trip metadata, and any rating she already submitted. Commission amount, commission rate, and driver net earnings are never included in the rider response.

**The driver's confirmation closes the trip.** When the driver confirms she collected the cash, her availability is reset to available (#1645) and she becomes eligible for the next trip request.

### Acceptance Criteria

**Rider trip summary**

**Scenario 1 — Total fare and three line items returned**
- Given a trip is in trip_ended state with a settled fare
- When the rider app calls the completed-trip endpoint
- Then the response includes the total fare in EGP
- And three fare line items are included: base fee, distance charge (per-km), and time charge (per-minute)
- And the three line items sum to the total fare
- And the amount is the value stored by settlement, with no recalculation at retrieval time

**Scenario 2 — Full trip metadata included**
- Given the trip is complete and the rider requests the summary
- Then the response includes: total distance (km), trip duration (minutes), pickup address, destination address, driver full name, and vehicle make, model, colour, and plate number

**Scenario 3 — Previously submitted rating is included**
- Given the rider has submitted a star rating for this trip (#1639)
- Then the star value (1–5) and any selected tags are included in the response

**Scenario 4 — No rating submitted — rating field is absent or null**
- Given the rider has not submitted a rating (skipped or not yet rated)
- Then the rating field is null or absent and the rider app shows a placeholder

**Scenario 5 — Commission is never exposed to the rider**
- Given a settled trip where a commission was deducted
- When the rider retrieves her summary
- Then the response contains no commission rate, no commission amount, and no driver net earnings — only the total fare and its three line items

**Scenario 6 — Trip not found or not belonging to this rider**
- Given the rider requests a trip ID that does not exist or does not belong to her account
- Then the server returns a not-found or forbidden response

**Scenario 7 — Unauthenticated rider request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

**Driver cash collection**

**Scenario 8 — Driver retrieves the fare for a completed trip**
- Given an authenticated driver has a trip in trip_ended state
- When she calls the driver fare endpoint
- Then the response includes the final fare amount in EGP exactly as stored on the trip record, with no recalculation at retrieval time
- And the amount populates the cash-collection screen

**Scenario 9 — Rider and driver are served the same amount**
- Given the same settled trip
- When the rider retrieves her trip summary and the driver retrieves her cash-collection amount
- Then both are served exactly the same total fare

**Scenario 10 — Driver confirms cash collected and returns to available**
- Given the driver has viewed the cash-collection screen and confirms the cash was collected
- When the confirmation is submitted
- Then the collection is recorded against the trip
- And the driver's availability status is reset to available (#1645)
- And she is eligible to receive the next trip request

**Scenario 11 — Trip is not in trip_ended state**
- Given the driver calls the fare endpoint for a trip that has not reached trip_ended
- Then a conflict or not-ready error is returned and no fare data is returned

**Scenario 12 — Trip not found or belongs to a different driver**
- Given the driver requests a trip ID that does not exist or belongs to a different driver
- Then a not-found or forbidden error is returned

**Scenario 13 — Unauthenticated driver request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

### Out of Scope
- Calculating the final fare or applying the minimum-fare floor (#1636)
- Calculating or storing commission, the acceptance-time rate snapshot, and driver net earnings (#1636)
- Rating submission itself (#1639)
- Trip-completion push notification
- Receipt generation or PDF export for either side
- Payout disbursement to drivers (wallet/bank integration)
- Fare dispute workflow

### Dependencies
- #1636 — Trip settlement stores the final fare, line items, and net earnings (must be live — it is the only source of the amounts served here)
- #1652 — Driver advances trip state machine (supplies the trip_ended state these endpoints require)
- #1645 — Driver availability status (reset to available on cash-collected confirmation)
- #1639 — Rider submits driver rating (supplies the rating shown in the summary)

---

## [API] #3997 — Trip completion posts to the ledger according to fare custody 🆕
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** Phase 1

**Description:** As the trip-completion service, I want to post the correct ledger entry for a completed trip based on its custody value — which records who is holding the fare — so that a driver's balance always reflects who actually has the money, and the ledger never has to assume how a fare was collected.

### Background

Every completed trip settles to the same three numbers (#1636): fare F, platform commission C, and driver net earnings N, where F = C + N. What those numbers do not say is **who physically holds F**. That fact is captured on the trip as its **custody** value, `driver` or `platform`, set when the trip is created. In Phase 1 it is always `driver`, because the rider hands the fare to the driver at the end of the ride.

**Custody decides the ledger entry.** When `custody = driver`, she holds the fare, so she owes the platform its commission — a `trip_commission` debit of C is posted against her (#3991). When `custody = platform`, the platform holds the fare, so it owes her the net — a `trip_earnings` credit of N is posted for her. Both land on the same economic position: she is entitled to N. This story is the **one and only place** in the platform that reads custody and branches on it to choose a ledger entry — no other code decides what a trip owes.

**Why the branch exists at all.** A ledger that assumes the driver always holds the fare is correct only for as long as that assumption holds, and it fails silently the day it stops. Reading custody instead makes the entry correct by construction. No Phase 1 flow produces `custody = platform`; the branch is defined and tested so that the ledger, the balance and every downstream report stay right without being rewritten.

**No calculation happens here.** The fare, commission, and net earnings are read exactly as stored by settlement (#1636); this story never recomputes them, it only decides which of the two entries carries them onto the ledger.

### Acceptance Criteria

**Scenario 1 — Cash trip (custody = driver) posts a commission debit**
- Given a trip completes with custody = driver, total fare 100 EGP and commission 20 EGP (#1636)
- Then a `trip_commission` entry of −20.00 EGP is posted to the driver's ledger (#3991), referencing the trip id
- And no `trip_earnings` entry is posted for that trip

**Scenario 2 — A platform-custody trip posts an earnings credit**
- Given a trip completes with custody = platform, total fare 100 EGP and driver net earnings 80 EGP (#1636)
- Then a `trip_earnings` entry of +80.00 EGP is posted to the driver's ledger (#3991)
- And no `trip_commission` entry is posted for that trip

**Scenario 3 — The branch reads custody, never the payment method**
- Given a trip record whose custody value is platform
- When settlement completes
- Then a `trip_earnings` entry is posted, exactly as it would be for any other custody = platform trip
- And nothing other than the custody value plays any part in choosing which entry is posted

**Scenario 4 — Phase 1 always writes custody = driver**
- Given a Phase 1 trip, where the rider hands the fare to the driver
- When any trip is created
- Then its custody value is driver
- And every completed trip in Phase 1 therefore posts a `trip_commission` debit, never a `trip_earnings` credit

**Scenario 5 — A mixed-custody driver nets to one correct balance**
- Given a driver completes a driver-custody trip (fare 100 EGP, commission 20 EGP) and, on a later date, a platform-custody trip (fare 100 EGP, net earnings 80 EGP)
- Then her ledger holds a −20.00 EGP `trip_commission` entry and a +80.00 EGP `trip_earnings` entry
- And her balance is the sum of both, +60.00 EGP, with no special-case handling for the mix — what she owes is cancelled by what she is owed automatically

**Scenario 6 — Entitlement is identical under both custody values**
- Given the same trip figures — fare 100 EGP, commission 20 EGP, net earnings 80 EGP — settled once under custody = driver and, hypothetically, once more under custody = platform
- Then the driver is entitled to the same 80 EGP net earnings under both paths — as a positive earnings credit under platform custody, or as an 80 EGP reduction in what she must hand back under driver custody
- And no screen, report, or downstream story treats the two paths differently

**Scenario 7 — Posting happens once, at settlement**
- Given a trip has not yet reached trip_ended and settlement (#1636)
- When any request asks this story to post a ledger entry for it
- Then nothing is posted and a not-ready error is returned

**Scenario 8 — Posting is idempotent**
- Given a trip's settlement is retried or replayed
- Then at most one `trip_commission` or `trip_earnings` entry exists for that trip, keyed by trip id and party id (#3991)

**Scenario 9 — Fare, commission and net earnings are read, not recalculated**
- Given the fare, commission and net earnings already stored by settlement (#1636)
- When this story posts the ledger entry
- Then it uses those stored figures exactly — it performs no fare or commission calculation of its own

**Scenario 10 — Exactly one of the two entries is posted per trip**
- Given a completed trip
- Then exactly one of `trip_commission` or `trip_earnings` is posted for it — never both, and never neither

**Scenario 11 — Cancelled trips post nothing here**
- Given a trip ends in cancelled rather than completed status
- Then this story posts no `trip_commission` or `trip_earnings` entry — a cancellation's own fee logic belongs to #1764

### Out of Scope
- Calculating the fare, commission, or net earnings themselves (#1636)
- The ledger itself, its entry types, and its posting guarantees (#3991)
- Cancellation-fee ledger entries (#1764)
- Recovering a rider's outstanding fee as a surcharge on this trip (#4000) — a separate, additional posting layered onto the same trip-completion event when a surcharge applies
- Producing `custody = platform` from any live flow — no Phase 1 flow does; this story only makes the branch exist and default correctly
- Serving the fare or earnings to the rider or driver apps (#3058)
- Surge and dynamic pricing, promo codes, referral credits, tips, driver bonuses and incentives

### Dependencies
- #1636 — Trip settlement (must be live — supplies the settled fare, commission, net earnings, and the trip's custody value)
- #3991 — Party balance ledger records every balance movement (must be live — the ledger this story posts into)
- #1652 — Driver advances trip state machine (supplies the trip_ended trigger)

---

## [API] #1639 — Rider submits driver rating
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a developer, I want the rating submission endpoint to accept a star value between 1 and 5 and an optional set of predefined tags for a completed trip so that the driver's average star rating is updated and the feedback is stored permanently on the trip record.

**Scenario 1 — Valid rating submitted — stored on trip and driver average updated**
- Given an authenticated rider submits a star value between 1 and 5 for a completed trip
- When the endpoint processes the request
- Then the rating is stored on the trip record
- And the driver's overall average star rating is recalculated to include this submission
- And a success response is returned

**Scenario 2 — Star rating is required — missing value returns validation error**
- Given the rider submits a rating request without a star value
- When the endpoint processes the request
- Then a validation error is returned: star rating is required
- And no rating is stored

**Scenario 3 — Star value must be an integer from 1 to 5**
- Given the rider submits a star value of 0, 6, or a non-integer
- When the endpoint processes the request
- Then a validation error is returned: star value must be between 1 and 5

**Scenario 4 — Tags are optional — submission without tags accepted**
- Given the rider submits a star value with no tags
- When the endpoint processes the request
- Then the rating is stored with an empty tags list
- And a success response is returned

**Scenario 5 — Only predefined tags are accepted**
- Given the rider submits a tag key not in the predefined set ("سائق آمن", "سيارة نظيفة", "وديةٌ/ودود")
- When the endpoint processes the request
- Then a validation error is returned naming the unknown tag

**Scenario 6 — Rating already submitted — conflict returned**
- Given the rider has already submitted a rating for this trip
- When she attempts to submit another rating for the same trip
- Then a conflict error is returned: a rating has already been submitted for this trip
- And the original rating is not overwritten

**Scenario 7 — Trip not found or not belonging to this rider**
- Given the rider submits a rating for a trip ID that does not exist or does not belong to her
- Then the server returns a not-found or forbidden response

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

**Scenario 9 — Rider skips rating — trip finalized as rating-skipped**
- Given a completed trip is awaiting a rating
- When the rider leaves the rating flow without submitting (skip)
- Then the trip is marked rating_skipped and finalized
- And the rider cannot return to rate this trip later
- And a later rating submission for the same trip is rejected because the trip is already finalized

---

## [API] #1654 — Driver aggregate rating is updated
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to recalculate the driver's average rating after each new rating is submitted so that the driver's profile always reflects her current standing.

### Background

This is an internal platform process triggered after a rating is successfully stored by #1639. The platform recalculates the driver's average star rating across all rated trips (excluding skipped trips). The updated average is written to the driver's profile record. All driver-detail endpoints reflect the new average immediately on their next call. No app-to-platform call initiates this — it is triggered internally by the rating submission flow.

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

## [API] #2978 — Driver submits rider rating 🆕
**Feature:** Feature 11 — Trip Completion & Rating | **Sprint:** 2

**Description:** As a developer, I want the rider-rating endpoint to accept a star value between 1 and 5 from the driver for a completed trip so that the rating is stored on the trip record and the rider's average star rating is kept up to date.

### Background

This is the driver-side mirror of #1639 (rider submits driver rating). It accepts a star value from 1 to 5 submitted by the authenticated driver against a completed trip she drove, stores it on the trip record, and recalculates the rider's average star rating — the same way #1654 maintains the driver's aggregate. Rating is optional: a trip that the driver never rates is simply left unrated and is never held open waiting for one, and the driver's availability is never gated on it.

The rider's aggregate rating is maintained here rather than in a separate story, mirroring what #1654 does for drivers. It is consumed by the admin rider profile (#1662) and by the driver's Rate Passenger screen (#2977), which shows the passenger's current rating before the driver rates her.

### Acceptance Criteria

**Scenario 1 — Valid rating stored and rider average updated**
- Given an authenticated driver submits a star value between 1 and 5 for a trip she completed
- When the endpoint processes the request
- Then the rating is stored on the trip record as the driver's rating of the rider
- And the rider's overall average star rating is recalculated to include this submission
- And a success response is returned

**Scenario 2 — Star value is required**
- Given the request arrives with no star value
- Then a validation error is returned: star rating is required
- And no rating is stored

**Scenario 3 — Star value must be an integer from 1 to 5**
- Given the driver submits 0, 6, or a non-integer
- Then a validation error is returned: star value must be between 1 and 5
- And no rating is stored

**Scenario 4 — Rating already submitted for this trip**
- Given the driver has already rated the rider for this trip
- When she submits another rating for the same trip
- Then a conflict error is returned and the original rating is not overwritten

**Scenario 5 — Trip must be completed**
- Given the driver submits a rating for a trip that is not yet in trip_ended
- Then the request is rejected — a rider can only be rated once the trip is complete

**Scenario 6 — Trip not found or not driven by this driver**
- Given the driver submits a rating for a trip ID that does not exist, or for a trip she did not drive
- Then the server returns a not-found or forbidden response

**Scenario 7 — Cancelled trips cannot be rated**
- Given the trip was cancelled by either party (#1715 / #1720)
- When a rating is submitted for it
- Then the request is rejected

**Scenario 8 — Skipping is not an error**
- Given a completed trip that the driver never rates
- Then the trip remains valid and finalized with no rider rating recorded
- And the rider's average is unaffected
- And nothing about the driver's availability or next dispatch depends on it

**Scenario 9 — Rider with no ratings yet**
- Given a rider who has never been rated
- When her rating is requested (e.g. by #2977 or the admin rider profile)
- Then a clear no-rating-yet value is returned rather than a zero or a null that reads as 0 stars

**Scenario 10 — Rating average is computed the same way as the driver aggregate**
- Given a rider with several ratings
- Then her average is the mean of all submitted star values, exposed to one decimal place, with the total count of ratings — consistent with #1654

**Scenario 11 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

**Scenario 12 — The rider is never shown who rated her or how**
- Given a driver has rated a rider
- Then no endpoint exposes that individual rating to the rider, only her own aggregate where applicable

### Out of Scope
- Predefined feedback tags or free-text comments on the rider
- Suspending or blocking a rider on the basis of a low rating (suspension is #1740 / #1687)
- Using the rider rating in matching or dispatch decisions
- Surfacing the rider's rating in the rider's own app
- Editing or deleting a submitted rating

### Dependencies
- #2977 — Driver rates the rider after trip completion (Mobile counterpart)
- #1636 — Trip settlement (the trip must be completed before it can be rated)
- #1654 — Driver aggregate rating is updated (the pattern this mirrors for riders)
- #1662 — Admin views rider profile (consumer of the rider aggregate rating)

---

### Feature 12 — Trip History API

---

## [API] #1641 — Rider retrieves trip history
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a developer, I want the rider trip history endpoints to return a paginated list of the rider's completed trips and the full detail of any individual trip so that the rider app can display history summaries in a list and allow the rider to drill into the full fare breakdown and driver details for any past trip.

**Scenario 1 — Rider has completed trips — paginated list returned most recent first**
- Given an authenticated rider has at least one completed trip
- When the rider app calls the history list endpoint
- Then the response returns a paginated list of trips sorted most recent first
- And each entry includes: trip date, destination name or address, total fare paid (EGP), and status = "Completed"

**Scenario 2 — Rider has no trips — empty list returned**
- Given an authenticated rider has never completed a trip
- When the rider app calls the history list endpoint
- Then the response returns an empty list
- And the rider app shows an empty state message

**Scenario 3 — Pagination works correctly**
- Given the rider has more trips than fit on one page
- When the rider app requests subsequent pages using the pagination cursor or page number
- Then the next page of trips is returned in the correct order
- And no trips are duplicated or skipped across pages

**Scenario 4 — Individual trip detail returns full fare breakdown**
- Given an authenticated rider requests the detail endpoint for a specific trip ID
- When the endpoint processes the request
- Then the response includes: date and time, pickup address, destination address, total fare (EGP), fare breakdown (base fee + distance charge + time charge), trip duration (minutes), distance (km), driver full name, and vehicle make, model, color, and plate number

**Scenario 5 — Rating included if submitted**
- Given the rider submitted a star rating for the trip
- When the detail endpoint returns the response
- Then the star value (1–5) and any selected tags are included

**Scenario 6 — Rating absent if not submitted**
- Given the rider skipped the rating for the trip
- When the detail endpoint returns the response
- Then the rating field is null or absent

**Scenario 7 — Trip not belonging to this rider returns forbidden**
- Given the rider requests a trip ID that belongs to a different account
- Then the server returns a forbidden or not-found response

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

---

## [API] #1655 — Driver retrieves trip history
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a developer, I want the driver trip history endpoints to return a paginated list of the driver's completed trips and the full detail of any individual trip so that the driver app can display earnings activity and allow the driver to review the route details and rider rating for any past trip.

**Scenario 1 — Driver has completed trips — paginated list returned most recent first**
- Given an authenticated driver has at least one completed trip
- When the driver app calls the history list endpoint
- Then the response returns a paginated list of trips sorted most recent first
- And each entry includes: trip date, destination area, and cash fare collected (EGP) and commission

**Scenario 2 — Driver has no trips — empty list returned**
- Given an authenticated driver has not completed any trips
- When the driver app calls the history list endpoint
- Then the response returns an empty list
- And the driver app shows an empty state message

**Scenario 3 — Pagination works correctly**
- Given the driver has more trips than fit on one page
- When the driver app requests subsequent pages
- Then the next page of trips is returned in the correct order
- And no trips are duplicated or skipped across pages



**Scenario 4 — Rider rating included if submitted**
- Given the rider submitted a star rating for the trip
- When the driver requests the trip detail
- Then the star value (1–5) is included in the response

**Scenario 5 — Rider did not rate — rating field indicates no rating given**
- Given the rider skipped or did not submit a rating for the trip
- When the driver requests the trip detail
- Then the rating field is null or absent
- And the driver app displays "لم يتم التقييم" (No rating given)

**Scenario 6 — Trip not belonging to this driver returns forbidden**
- Given the driver requests a trip ID that belongs to a different driver's account
- Then the server returns a forbidden or not-found response

**Scenario 7 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

---

## [API] #1718 — Driver retrieves past trip detail 🆕
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the full details of a single past completed trip so that the trip detail screen can display the route, duration, fare collected, and the rating the rider gave.

### Background

Called when a driver taps a row in her trip history list (#1593). The endpoint returns the full detail record for a single completed trip driven by the authenticated driver. The response includes all fields needed to populate the driver's trip detail screen: trip date and time, pickup address, destination address, cash fare collected (EGP), trip duration (minutes), distance (km), and the rider's rating if one was submitted. If the rider skipped the rating, the response indicates this with a null rating or the localised "لم يتم التقييم" value.

### Acceptance Criteria

**Scenario 1 — Driver retrieves detail of a rated completed trip**
- Given the authenticated driver requests the detail for a past trip that the rider rated
- When the endpoint processes the request
- Then the response includes: trip date and time, pickup address, destination address, cash fare collected (EGP), trip duration (minutes), distance (km), and the star rating the rider submitted

**Scenario 2 — Driver retrieves detail of an unrated trip**
- Given the authenticated driver requests the detail for a past trip the rider did not rate or skipped
- When the endpoint processes the request
- Then all trip detail fields are returned as in Scenario 1
- And the rating field is null or shows "لم يتم التقييم" (No rating given)

**Scenario 3 — Trip ID not found or belongs to a different driver**
- Given the driver requests a trip ID that does not exist or belongs to a different driver
- When the endpoint processes the request
- Then a not-found or forbidden error is returned
- And no trip data is disclosed

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid driver session token is provided
- Then the request is rejected with an authentication error

### Out of Scope
- Responding to or disputing a rider rating
- Contacting the rider
- SOS history

### Dependencies
- #1619 — Session validation (must be live)
- #1636 — Final fare calculation (fare data source)
- #1639 — Rider submits driver rating (rating data source)

---

## [API] #4022 — Driver trip history returns all trip outcomes with today, week and month filters 🆕
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As the driver app, I want the trip history list endpoint to return both completed and cancelled trips, scoped to a period of today, this week or this month, so that a driver can review her activity for a chosen period, including the trips that ended in cancellation.

### Background

#1655 defined the driver trip history list as **completed trips only**. That is not the whole of a driver's activity: trips that she or the rider cancelled belong to the same record, and a driver who cannot see them reads her own history as incomplete — and raises support tickets about "missing" trips. This story widens the same list endpoint to return both completed and cancelled trips, and scopes it to a period of today, this week or this month.

The Trip History screen shows three period tabs — **Today**, **This Week**, **This Month** — with **Today** selected when the screen opens. There is no "All" tab, so the endpoint no longer offers an unbounded history: `today` is the default when the parameter is omitted. Each row is a summary card only; the full record lives on the trip detail screen (#1718) behind the row's chevron.

#### What a list row carries

| Field | Shown on the card as | Notes |
|---|---|---|
| Trip date | Card header, e.g. "Mon, June 8" | Date only on the card. The time of day is a trip detail field (#1718), not a list field. |
| Pickup area | First line, labelled "Pickup" | Area name, e.g. "Sheikh Zayed City, Giza" — not a full street address. |
| Destination area | Second line, labelled "Destination" | Area name, same shape as pickup. |
| Outcome | Status badge — "Completed" or "Cancelled" | **Two values only.** The badge is the entire difference between a completed and a cancelled card — see Outcomes returned below. |
| Trip fare (EGP) | Amount + "Trip Fare" | Present on a **completed** row only. A cancelled row returns no fare value at all and the card renders a dash. **Commission is not a list field** — see Out of Scope. |
| Rider name | Avatar initial + first name | The rider the driver carried, so she can recognise the trip. Display name and avatar image reference; the avatar initial is derived by the app. |
| Trip identifier | Not rendered — backs the chevron | Lets the app open the trip detail record (#1718). |

#### Outcomes returned

The list returns **completed and cancelled** trips. A cancelled card differs from a completed one in exactly two ways: **the status badge reads "Cancelled"**, and **the fare shows a dash instead of an amount**. Nothing else changes. The list does *not* say who cancelled, does *not* carry a cancellation reason, and shows no extra label, icon or line of any kind on a cancelled card.

| Badge on the card | Which trips it covers | Trip fare on the row |
|---|---|---|
| Completed | Driver tapped "End Trip" (#1591, status `trip_ended`) | The cash fare collected from the rider. |
| Cancelled | Rider cancelled (#1715) **or** driver cancelled (#1720) — status `cancelled`, either value of `cancelled_by`. Both render identically. | **None.** No amount is returned and the card renders a dash — not 0.00, and not a cancellation fee, even where one was credited (#1764). |

Trips that never reached this driver — still searching, or expired with no match — never appear in any driver's history. Who cancelled and why are trip detail fields (#1718); a driver who needs that opens the trip.

#### Period filter

| Filter value | Screen tab | Period covered (Africa/Cairo) | Notes |
|---|---|---|---|
| `today` (default) | Today | 00:00:00 today until now | Applied when the parameter is omitted. This is the tab selected when the screen opens. |
| `this_week` | This Week | 00:00:00 on the Saturday of the current week until now | The Egyptian week starts on Saturday. |
| `this_month` | This Month | 00:00:00 on the 1st of the current month until now | — |

There is no unbounded "all history" value. The `all` value described in the earlier revision of this story is **removed**: every request is scoped to one of the three periods above. This narrows the #1655 behaviour, so any caller that relied on an unfiltered response must now choose a period.

The filter is evaluated against the moment the trip reached its final outcome — the end time for a completed trip, the cancellation time for a cancelled one — not the time the trip was requested. All period boundaries are computed in **Africa/Cairo** local time, not UTC and not the device timezone.

### Acceptance Criteria

**Scenario 1 — Today is the default period**
- Given an authenticated driver has trips that ended today and trips that ended on earlier days
- When the driver app calls the history list endpoint with no filter parameter
- Then only the trips that reached their final outcome from 00:00:00 today (Africa/Cairo) onwards are returned
- And the response is identical to an explicit `today` request

**Scenario 2 — Completed and cancelled trips both appear**
- Given the selected period contains completed trips and cancelled trips
- When the driver app calls the endpoint with that filter
- Then both are returned in one list, sorted most recent first
- And each entry carries its outcome as either completed or cancelled

**Scenario 3 — A row carries the fields the card renders**
- Given the list contains any trip
- When the response is returned
- Then each entry includes the trip date, the pickup area, the destination area, the outcome, the trip fare in EGP, the rider's display name and avatar reference, and a trip identifier
- And a cancelled entry carries no additional field beyond this set, and no fare value

**Scenario 4 — A completed row carries the fare collected**
- Given the list contains a completed trip
- When the response is returned
- Then that entry is marked completed and its fare is the cash fare collected from the rider in EGP

**Scenario 5 — A cancelled row differs only by its status**
- Given the list contains a cancelled trip
- When the response is returned
- Then that entry is marked cancelled
- And it carries no cancellation reason
- And it does not identify who cancelled the trip
- And it carries no fare value, so the card renders a dash rather than an amount
- And this holds whether or not a cancellation fee was credited to the driver (#1764)

**Scenario 6 — Rider-cancelled and driver-cancelled rows are indistinguishable on the list**
- Given the list contains a trip the rider cancelled and a trip the driver cancelled
- When the response is returned
- Then both entries carry the same cancelled outcome value
- And neither entry carries a fare value
- And nothing in either entry reveals which party cancelled
- And the party who cancelled remains available on the trip detail record (#1718)

**Scenario 7 — Commission is not returned on the list**
- Given the list contains completed and cancelled trips
- When the response is returned
- Then no entry carries a commission figure
- And commission remains available on the trip detail record (#1718), where it is deducted from completed trips only and is zero on cancelled trips

**Scenario 8 — Filter this week**
- Given the driver has trips from the current week and from the previous week
- When the driver app calls the endpoint with the filter set to `this_week`
- Then only the trips that reached their final outcome from 00:00:00 on the Saturday of the current week (Africa/Cairo) onwards are returned
- And no trip from the previous week appears in the response

**Scenario 9 — Filter this month**
- Given the driver has trips from the current calendar month and from the previous month
- When the driver app calls the endpoint with the filter set to `this_month`
- Then only the trips that reached their final outcome from 00:00:00 on the 1st of the current month (Africa/Cairo) onwards are returned
- And no trip from the previous month appears in the response

**Scenario 10 — Period boundary is evaluated in Cairo local time**
- Given a trip ended at 23:50 Africa/Cairo yesterday and another ended at 00:10 Africa/Cairo today
- When the driver app calls the endpoint with the filter set to `today`
- Then only the 00:10 trip is returned
- And the result is identical regardless of the device timezone the request originates from

**Scenario 11 — The filter is applied before pagination**
- Given the selected period contains more trips than fit on one page
- When the driver app requests subsequent pages with the same filter
- Then paging walks only the trips inside the selected period
- And no trip is duplicated or skipped across pages
- And any total count in the response reflects the filtered set, not the driver's whole history

**Scenario 12 — No trips in the selected period**
- Given the driver has history but no trip reached its final outcome inside the selected period
- When the endpoint is called with that filter
- Then an empty list is returned with a success response, not an error
- And the driver app shows a period-specific empty state

**Scenario 13 — Unrecognised filter value is rejected**
- Given the request carries a filter value that is not one of `today`, `this_week` or `this_month`
- When the endpoint processes the request
- Then a validation error is returned
- And no trip data is returned
- And this includes the value `all`, which is no longer accepted

**Scenario 14 — Only this driver's trips are returned**
- Given other drivers have trips inside the same period
- When the authenticated driver calls the endpoint with any filter
- Then only trips driven by the authenticated driver are returned

**Scenario 15 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected with an authentication error

### Out of Scope
- An "All" period tab or a custom "from / to" date range picker — only the three fixed periods
- Who cancelled the trip, and the cancellation reason, on the list row — both owned by trip detail (#1718)
- Commission on the list row, and any cancellation fee amount on a cancelled list row — both owned by trip detail (#1718)
- The time of day on the list row — the card shows the date only
- Separate badges for rider-cancelled and driver-cancelled — one "Cancelled" badge covers both
- Filtering by outcome type (completed only, cancelled only)
- Period earnings totals or summary figures on the list — owned by Earnings (#1776)
- Exporting, sharing or printing the history
- The content of a single trip detail record — owned by #1718
- Disputing a cancellation or a cancellation fee

### Dependencies
- #1655 — Driver retrieves trip history (this story widens and re-scopes the same list endpoint)
- #1718 — Driver retrieves past trip detail (the row tap target, and the home of commission, trip time, who cancelled and the cancellation reason)
- #1715 — Rider cancels a trip (source of cancelled rows)
- #1720 — Rider and driver cancellation (source of cancelled rows)
- #1764 — Cancellation fees are charged after grace period (deliberately *not* surfaced on the list row)
- #1619 — Auth middleware validates session tokens (must be live)

---

### Feature 13 — Admin Rider Management API

---

## [API] #1739 — Account suspension status is updated by admin 🆕
**Feature:** Feature 13 — Admin Rider Management API | **Sprint:** 2

**Description:** As the admin portal, I want to update a rider's or driver's account suspension status so that the platform can enforce the admin's decision across all active sessions — immediately, or automatically when the user's active trip ends.

### Background

This endpoint accepts PATCH requests from authenticated admin sessions. It updates the account_status field on a user record (rider or driver) to either 'suspended' or 'active'. The user_type parameter (rider or driver) determines which record is updated. On suspension, all active sessions for that user are invalidated and the user cannot log in. If the user is a driver, her online status is forced to offline. On reinstatement, no sessions are created — the user must log in again. A reason and optional note are stored on the suspension record for audit purposes. If the target user has an active (in-progress) trip when a suspend request arrives, the account is placed in a 'pending_suspension' state instead of being suspended immediately: the current trip is allowed to finish, the user cannot start or request a new trip while pending, and the full suspension (account_status 'suspended', session invalidation, and — for drivers — forced offline) is applied automatically as soon as that trip ends. Reinstatement always takes effect immediately.

### Acceptance Criteria

**Scenario 1 — Admin suspends a rider account**
- Given an authenticated admin sends PATCH with user_type: 'rider', user_id, action: 'suspend', and a reason
- When the endpoint is called
- Then the rider's account_status is updated to 'suspended'
- And all active sessions for that rider are invalidated
- And the suspension record is created with the reason and admin ID

**Scenario 2 — Admin reinstates a rider account**
- Given an authenticated admin sends PATCH with user_type: 'rider', user_id, action: 'reinstate'
- When the endpoint is called
- Then the rider's account_status is updated to 'active'

**Scenario 3 — Admin suspends a driver account**
- Given an authenticated admin sends PATCH with user_type: 'driver', user_id, action: 'suspend', and a reason
- When the endpoint is called
- Then the driver's account_status is updated to 'suspended'
- And the driver's online status is forced to offline
- And all active sessions are invalidated
- And the suspension record is created

**Scenario 4 — Admin reinstates a driver account**
- Given an authenticated admin sends PATCH with user_type: 'driver', user_id, action: 'reinstate'
- Then the driver's account_status is updated to 'active'

**Scenario 5 — Suspension is deferred when the user has an active trip**
- Given a suspend request for a user (rider or driver) who has an active (in-progress) trip
- When the endpoint is called
- Then the account_status is set to 'pending_suspension' and the suspension record is created with the reason and admin ID
- And the user's current sessions are not yet invalidated and the active trip continues
- And the user cannot start or request a new trip while in 'pending_suspension'

**Scenario 6 — Pending suspension is applied automatically when the trip ends**
- Given a user whose account is in 'pending_suspension'
- When that user's active trip reaches a terminal state (completed, cancelled, or expired)
- Then the platform automatically sets account_status to 'suspended', invalidates all sessions, and — for a driver — forces online status to offline
- And no further admin action is required

**Scenario 7 — Reason is required for suspension**
- Given a suspension request arrives without a reason field
- Then the platform returns a validation error

**Scenario 8 — Non-admin request is rejected**
- Given a request arrives from a non-admin session
- Then the platform returns an authorisation error

**Scenario 9 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1744

### Out of Scope
- Automated suspension rules
- Suspension history audit log UI

### Dependencies
- #1744 — Session validation (must be live)
- #1687 — Rider account is placed under review after a gender mismatch report

---

### Feature 18 — Driver Earnings API

---

## [API] #1735 — Driver views earnings dashboard 🆕
**Feature:** Feature 18 — Driver Earnings API | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the authenticated driver's earnings summary so that the earnings dashboard can display accurate income figures.

### Background

This endpoint returns aggregated earnings data for the authenticated driver, broken into three time windows: today (from midnight local time), this week (from Monday midnight), and this month (from the 1st of the month). Each window returns total_earnings_egp and trip_count. The response also includes a paginated list of recent completed trips with date, pickup_area, destination_area, and fare_egp. Only completed trips are counted. Cancelled trips are excluded.

### Acceptance Criteria

**Scenario 1 — Earnings returned for driver with completed trips**
- Given an authenticated driver with at least one completed trip sends a GET request
- When the endpoint is called
- Then the response includes today, this_week, and this_month summaries
- And each summary includes total_earnings_egp and trip_count
- And a paginated list of recent trips is included

**Scenario 2 — Zero earnings returned for driver with no trips**
- Given an authenticated driver with no completed trips sends a GET request
- Then the response returns 0 for all earnings and trip counts
- And the recent trips list is empty

**Scenario 3 — Cancelled trips are excluded from earnings**
- Given a driver has trips in cancelled state
- When the earnings endpoint is called
- Then cancelled trips do not appear in earnings totals or the recent trips list

**Scenario 4 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

### Out of Scope
- Custom date range filtering
- Earnings export
- Tip amounts

### Dependencies
- #1619 — Authentication service (must be live)

---

## [API] #1781 — Driver retrieves her balance and statement ♻️
**Feature:** Feature 18 — Driver Earnings API | **Sprint:** Phase 1

**Description:** As the driver app, I want to retrieve the driver's current balance and the transactions behind it so that she can see exactly what she owes the platform, what the platform owes her, and how every movement arose.

### Background

This is the driver-facing read over the balance ledger (#3991). It returns one signed balance in EGP plus a paginated statement of the entries that produced it — it never calculates anything itself.

**The sign carries the meaning.** A negative balance is money the driver owes the platform (the normal Phase 1 cash case: she keeps the fare, the commission is a debt). A positive balance is money the platform owes her, reduced only by a payout Finance records against it (#3993). The response exposes both readings explicitly — outstanding (what she owes, zero when the balance is positive) and available (what SheDrive owes her, zero when the balance is negative) — so the app never has to interpret a sign.

**Every entry is explained.** Each statement row returns the entry type, the signed amount, the timestamp (UTC+2), a human-readable description, and the id of the source record so the app can deep-link to the trip, settlement, or payout behind it.

**The commission percentage is still never exposed.** A trip-commission row returns the EGP amount owed on that trip and the trip reference — not the rate, and not the gross fare. This preserves the rule established in #1766.

The response also carries the last settlement (amount and date) and the configured outstanding balance limit (#3994) so the app can warn the driver before she is blocked from going online (#3996).

### Acceptance Criteria

**Scenario 1 — Returns the current balance**
- Given an authenticated approved driver requests her balance
- Then the response includes her signed balance in EGP, the outstanding amount, the available amount, and an as-of timestamp

**Scenario 2 — Cash trip appears as an amount owed**
- Given the driver completes a cash trip with a 20 EGP commission (custody = driver, #3997)
- When she retrieves her balance
- Then the outstanding amount has increased by 20.00
- And a trip-commission statement row of −20.00 EGP referencing that trip is returned

**Scenario 3 — Commission rate and gross fare are never returned**
- Given a trip-commission row is returned
- Then the response contains no commission rate and no gross fare for that trip — only the EGP amount owed and the trip reference

**Scenario 4 — Driver cancellation fee appears as a debit**
- Given a driver cancellation fee of 10 EGP was charged (#1764)
- When she retrieves her statement
- Then a driver-cancellation-fee row of −10.00 EGP is returned with the cancelled trip as its source
- And the outstanding amount includes it

**Scenario 5 — Rider cancellation fee share appears as a credit**
- Given the driver was awarded a 15 EGP share of a rider's cancellation fee (#1764)
- Then a rider-cancellation-fee-share row of +15.00 EGP is returned and the balance moves in her favour by that amount

**Scenario 6 — A recovered rider fee appears as a debit**
- Given the driver collected a rider's 20 EGP outstanding fee in cash on a trip (#4000)
- When she retrieves her statement
- Then a rider-fee-recovery row of −20.00 EGP is returned, referencing that trip, alongside that same trip's own trip-commission row
- And the description makes clear this is cash she collected on the platform's behalf, not a fee charged to her

**Scenario 7 — Settlement reduces what she owes**
- Given Finance records a cash settlement against the driver (#1813)
- When she retrieves her balance
- Then the outstanding amount is reduced by the settled amount
- And the last-settlement amount and date are returned
- And a settlement statement row is present

**Scenario 8 — Payout appears once Finance records it**
- Given Finance has recorded a 200 EGP payout to the driver (#3993, #4001)
- Then a payout row of −200.00 EGP is returned, with its reference and date, and the available amount is reduced by 200.00

**Scenario 9 — Statement is paginated, newest first**
- Given the driver has more entries than one page
- Then the statement is returned newest-first with a page size and a continuation marker
- And requesting the next page returns the next set with no duplicates and no gaps

**Scenario 10 — Statement can be filtered by date range**
- Given the driver requests a from/to date range
- Then only entries within that range are returned, and the balance still reflects her full history — not just the filtered window

**Scenario 11 — New driver with no activity**
- Given a driver who has completed no trips and has no entries
- Then the balance is 0.00, the outstanding amount is 0.00, the available amount is 0.00, and the statement is empty

**Scenario 12 — Balance limit is returned for the app's warning**
- Given an outstanding balance limit is configured (#3994)
- Then the response includes that limit so the driver app can warn her before she reaches it (#3988)

**Scenario 13 — Balance always equals the ledger**
- Given any driver at any time
- Then the balance returned equals the sum of her ledger entries exactly, with no recalculation from trip records

**Scenario 14 — A mixed-custody driver sees one balance, both entry types**
- Given a driver's statement holds both trip-commission rows (driver-custody trips) and trip-earnings rows (platform-custody trips) (#3997)
- Then her balance is the sum of all of them, and both row types are returned in the same statement with no separation into two views

**Scenario 15 — Unauthenticated request is rejected**
- Given a request without a valid driver session token
- Then it is rejected

### Out of Scope
- Posting entries to the ledger (#3991)
- Recording a payout (#3993) — a driver never requests or triggers one
- Recording a settlement (#1813)
- In-app settlement payment by the driver
- Receipt or statement PDF export
- Bank or wallet integration

### Dependencies
- #3991 — Party balance ledger records every balance movement (must be live — the only source of these figures)
- #3994 — Super admin configures balance and fee policy (supplies the balance limit returned here)
- #3997 — Trip completion posts to the ledger according to fare custody (supplies both trip-commission and trip-earnings rows)
- #1636 — Trip settlement (supplies commission and net earnings)
- #1619 — Authentication service (must be live)

---

## [API] #3991 — Party balance ledger records every balance movement 🆕
**Feature:** Feature 18 — Driver Earnings API | **Sprint:** Phase 1

**Description:** As the SheDrive platform, I want every event that changes a rider's or a driver's financial position to be posted as an immutable ledger entry so that each party's balance is always the verifiable sum of a transaction history rather than a figure recalculated from trip or cancellation records.

### Background

Today a driver's and a rider's financial position exist only as numbers scattered across trip and cancellation records. That is enough to *report* a figure but not to *change* one: nothing can debit a cancellation fee, credit a settlement, recover a rider's fee in cash, or record a payout. This story introduces **two ledgers** — one per driver, one per rider — and the posting rules that every other financial story in this change set writes through.

**One signed balance per party, in EGP.** For the driver, negative means she owes the platform (her *outstanding* balance, cleared by a settlement) and positive means the platform owes her (her *available* balance, reduced by a payout). For the rider, negative means she owes an unpaid fee; a fee opens negative and is closed by an equal credit the moment it is recovered or waived. Either party's balance is the arithmetic sum of her ledger entries. It is never computed from trip records and never written directly. A new party starts at zero.

**Driver ledger entry types:**

| Entry type | Sign | Posted when |
|---|---|---|
| `trip_commission` | debit (−) | A trip completes with `custody = driver` — she holds the fare, so the platform's commission becomes a debt she owes (#3997) |
| `trip_earnings` | credit (+) | A trip completes with `custody = platform` — the platform holds the fare, so her net earnings become a debt it owes (#3997) |
| `driver_cancellation_fee` | debit (−) | She cancels late without a qualifying no-show waiver (#1764) |
| `rider_cancellation_fee_share` | credit (+) | A rider cancels late; the driver is awarded her configured share (#1764) |
| `rider_fee_recovery` | debit (−) | She collected a rider's outstanding fee in cash on the platform's behalf (#4000) — the cash stays in her hand, so the recovered amount is a debt she owes back |
| `settlement` | credit (+) | Finance records cash received from the driver (#1813) |
| `payout` | debit (−) | Finance sends the driver a payout on its own cycle and it is recorded against her balance afterward (#3993, #4001) |

**Rider ledger entry types:**

| Entry type | Sign | Posted when |
|---|---|---|
| `cancellation_fee` | debit (−) | She cancels after the grace period (#1764) |
| `fee_collected` | credit (+) | The fee is recovered — in Phase 1, as a cash surcharge on her next trip (#4000) |
| `fee_waived` | credit (+) | An admin writes it off with a reason |

**Entries are immutable.** Nothing edits an entry and nothing deletes one — ever. Phase 1 ships with **no correction mechanism at all**: a settlement recorded for the wrong driver, an amount keyed wrong, or a duplicate payout has no fix path in this story. A rider fee can still be written off with `fee_waived` — the driver ledger has no equivalent. This gap is a known open item for the team building on this ledger.

**Posting is idempotent.** Every entry carries an idempotency key shaped `{event_type}:{trip_id|request_id}:{party_id}`. The same event never posts twice against the same party — a retried trip completion, a retried cancellation, or a replayed payout produces one entry, not two.

**Every entry names its cause.** Each entry carries its type, its signed EGP amount, a timestamp (UTC+2), and the id of the source record (a trip, a cancellation, a settlement, or a payout) — and, for a waived fee, the admin user id and a mandatory reason.

### Acceptance Criteria

**Scenario 1 — New party starts at zero**
- Given an approved driver, or a rider, with no ledger entries
- Then her balance is 0.00 EGP and her ledger is empty

**Scenario 2 — Cash trip debits the driver's commission**
- Given a trip completes with `custody = driver`, total fare 100 EGP and commission 20 EGP (#1636, #3997)
- Then a `trip_commission` entry of −20.00 EGP is posted against the driver, referencing the trip id
- And her balance decreases by 20.00 EGP

**Scenario 3 — A platform-custody trip credits the driver's net earnings**
- Given a trip completes with `custody = platform`, total fare 100 EGP and driver net earnings 80 EGP (#3997)
- Then a `trip_earnings` entry of +80.00 EGP is posted and no `trip_commission` entry is posted for that trip

**Scenario 4 — Driver cancellation fee debits her balance**
- Given a driver cancellation fee of 10 EGP is charged (#1764)
- Then a `driver_cancellation_fee` entry of −10.00 EGP is posted, referencing the cancelled trip

**Scenario 5 — Rider cancellation fee share credits the driver's balance**
- Given a rider cancels late, the fee is 20 EGP and the configured driver share is 75%
- Then a `rider_cancellation_fee_share` entry of +15.00 EGP is posted to the assigned driver (#1764)
- And no commission is deducted from that amount

**Scenario 6 — Rider fee recovery moves both ledgers together**
- Given a driver collects a rider's outstanding 20 EGP fee in cash on her next trip (#4000)
- Then a `fee_collected` entry of +20.00 EGP is posted to the rider and a `rider_fee_recovery` entry of −20.00 EGP is posted to the driver, in the same posting operation
- And the rider's balance and the driver's balance both move by exactly 20.00 EGP

**Scenario 7 — Rider cancellation fee debits her balance**
- Given a rider cancels after the grace period and the zone's cancellation fee is 20 EGP (#1764)
- Then a `cancellation_fee` entry of −20.00 EGP is posted against the rider

**Scenario 8 — Waived fee credits the rider's balance**
- Given an admin waives a rider's outstanding 20 EGP fee with a reason
- Then a `fee_waived` entry of +20.00 EGP is posted and her balance returns to 0.00

**Scenario 9 — Settlement credits the driver's balance**
- Given a driver's balance is −300.00 EGP and Finance records a 300 EGP settlement (#1813)
- Then a `settlement` entry of +300.00 EGP is posted and her balance becomes 0.00

**Scenario 10 — Payout debits the driver's balance when recorded**
- Given a driver's balance is +500.00 EGP and Finance records a 200 EGP payout (#3993, #4001)
- Then a `payout` entry of −200.00 EGP is posted and her balance becomes +300.00

**Scenario 11 — Balance is the sum of the ledger**
- Given a driver with entries of −20.00, −10.00, +15.00 and +300.00
- When her balance is read
- Then it is +285.00 EGP and matches the sum of her entries exactly

**Scenario 12 — A mixed-custody driver nets to one balance**
- Given a driver has one driver-custody trip (`trip_commission` −20.00) and one platform-custody trip (`trip_earnings` +80.00)
- Then her balance is the sum of both entries, +60.00 EGP, with no special handling for the mix of custody values

**Scenario 13 — Entries are immutable**
- Given a posted ledger entry
- When any request attempts to edit or delete it
- Then the request is rejected and the entry stands unchanged, with no correction mechanism offered in its place

**Scenario 14 — The same event never posts twice**
- Given a trip completion, cancellation, fee recovery, settlement, or payout is submitted or retried more than once for the same idempotency key
- Then exactly one ledger entry is posted per party for that key, and the balance is unaffected by the repeat

**Scenario 15 — Concurrent postings are serialised**
- Given two entries are posted for the same party at the same moment
- Then both are recorded and the resulting balance reflects both, with no lost update

**Scenario 16 — Amounts are stored to two decimals**
- Given any posted amount
- Then it is stored to two decimal places in EGP, VAT-inclusive, and the balance never accumulates rounding drift

**Scenario 17 — A suspended driver's ledger is preserved**
- Given a driver is suspended (#1742)
- Then her balance and ledger are retained unchanged and remain visible to the super admin

### Out of Scope
- Deciding which entry a completed trip posts — the custody branch belongs to #3997; this story defines the entry types it posts into
- Deciding whether a cancellation fee applies, its amount, or its split (#1764)
- Deciding whether and when a rider's fee is recovered (#4000)
- The driver-facing and rider-facing statement endpoints (#1781, #4004)
- Recording a settlement in the admin portal (#1813)
- Recording a payout (#3993, #4001) — a driver never requests one; there is no request, review, or approval step
- A free-form correction/adjustment entry type or a reverse-this-entry action — cut deliberately on 2026-09-13; see the open item above
- Surge and dynamic pricing, promo codes, referral credits, tips, driver bonuses and incentives
- Payment-provider integration, VAT and tax reporting, receipts and invoices as PDFs
- Accounting exports beyond CSV
- Rider or driver dispute of a ledger entry (Phase 2)
- Automated dunning

### Dependencies
- #1636 — Trip settlement (supplies the commission and net earnings figures a trip entry posts)
- #1759 — Super admin configures global platform policies (commission rate, driver share)
- #1816 — Super admin views the admin activity audit log (records fee waivers)

---

## [API] #3993 — Finance records a payout sent to a driver 🆕
**Feature:** Feature 18 — Driver Earnings API | **Sprint:** Phase 1

**Description:** As the admin portal, I want to record a payout that Finance has already sent to a driver against her balance so that the ledger reflects the transfer and her available balance is reduced by exactly what was sent.

### Background

A driver never requests a payout. There is no request, no approval queue, no reservation against her balance, no minimum or maximum amount, and no cooling-off period. Finance transfers the money to her on its own cycle, outside the system, and this endpoint is where that transfer is recorded **after the fact** — the same act as recording a settlement (#1813), in the opposite direction.

**Recording posts, it does not pay.** Calling this endpoint posts a `payout` debit to the driver ledger (#3991) for the amount that was actually sent. The money has already moved; this call only writes it down.

**A payout destination is required.** A payout cannot be recorded for a driver with no payout destination on file (#4003) — Finance cannot write down a transfer to nowhere.

**The amount can never exceed what is owed.** A payout is refused if it is more than the driver's current available balance.

**Posting is idempotent on the payout reference.** Every payout carries a reference (the bank or wallet transaction id, or a receipt number) and a date. Retrying the same reference never posts a second entry.

### Acceptance Criteria

**Scenario 1 — Successful payout recorded**
- Given an authenticated approved driver with an available balance of 500 EGP and a payout destination on file (#4003)
- When a payout of 200 EGP is recorded with a reference and a date
- Then a `payout` entry of −200.00 EGP is posted (#3991) and her available balance becomes 300.00
- And the payout reference and date are stored and returned

**Scenario 2 — Payout cannot exceed the available balance**
- Given an available balance of 100 EGP
- When a payout of 150 EGP is submitted
- Then it is rejected with a validation error and no entry is posted

**Scenario 3 — Payout is refused without a payout destination on file**
- Given a driver with no payout destination on file (#4003)
- When a payout is submitted for her
- Then it is rejected, naming the missing destination, and no entry is posted

**Scenario 4 — Payout succeeds once a destination is on file**
- Given the driver adds a payout destination
- When the payout is retried
- Then it succeeds and the `payout` entry is posted

**Scenario 5 — Idempotent on the payout reference**
- Given a payout is recorded with reference "PMT-1042"
- When the same reference is submitted again
- Then no second entry is posted and the original entry is returned unchanged

**Scenario 6 — Driver with a negative balance cannot receive a payout**
- Given the driver owes the platform 300 EGP
- When a payout is submitted for her
- Then it is rejected because she has no available balance

**Scenario 7 — Only approved drivers may receive a recorded payout**
- Given a driver whose account is pending approval, rejected, or suspended
- When a payout is submitted for her
- Then it is rejected

**Scenario 8 — Reference and date are required**
- Given a payout submission missing a reference or a date
- Then a validation error is returned and nothing is posted

**Scenario 9 — Driver retrieves the payout in her statement**
- Given a payout of 200 EGP has been recorded
- When she retrieves her balance (#1781)
- Then a payout row of −200.00 EGP is returned in her statement with its reference and date

**Scenario 10 — Unauthenticated request is rejected**
- Given a request without a valid admin session token
- Then it is rejected

### Out of Scope
- A driver requesting, tracking, or cancelling a payout — there is no such action anywhere in the system
- An approval queue, pending/approved/rejected states, or any reservation against her balance
- A minimum or maximum payout amount, or a cooling-off period between payouts
- A platform-wide payout enabled/disabled switch
- Bank transfer, wallet, or payment-provider integration — the transfer itself happens outside the system
- Reversing a recorded payout — Phase 1 ships with no correction mechanism for a mis-recorded entry (#3991)
- Tips, bonuses, incentives, and referral credits

### Dependencies
- #3991 — Party balance ledger records every balance movement (must be live)
- #4003 — Driver payout destination is captured and required before a payout can be recorded (supplies the destination this endpoint checks)
- #1781 — Driver retrieves her balance and statement (the payout appears there once recorded)
- #1619 — Authentication service (must be live)

---

## [API] #4003 — Driver payout destination is captured and required before payout 🆕
**Feature:** Feature 18 — Driver Earnings API | **Sprint:** Phase 1

**Description:** As the driver app, I want to capture, update, and retrieve the driver's payout destination so that a payout can never be recorded without somewhere for Finance to actually send the money.

### Background

A payout (#3993) is money leaving the platform to a real destination — a bank account or a mobile wallet, held under the driver's name. Today the driver profile carries no such destination, so nothing stops Finance recording a payout with nowhere to send it.

This story adds a **payout destination** to the driver profile: the destination type, the account or wallet number, and the holder name. A driver may add, update, or replace her destination at any time; she is never asked for it before Finance needs to pay her, since most drivers in Phase 1 run a negative balance and never receive a payout at all.

**The gate lives at recording, not before.** A driver never requests a payout — there is no request to gate. The check happens when a payout is recorded against her balance (#3993, #4001): without a destination captured, recording is refused and the admin is told why.

**The holder name is not silently assumed.** It is captured as its own field, separate from the driver's account name, because a payout destination is sometimes held jointly or under a slightly different legal name.

**The number is sensitive.** Once captured it is returned to the driver in full so she can verify it, but only ever in part (masked) anywhere else it might appear, unless the admin surface explicitly needs the full value to action a payout.

### Acceptance Criteria

**Scenario 1 — Driver captures a payout destination for the first time**
- Given an authenticated driver with no payout destination on file
- When she submits a destination type, number, and holder name
- Then the destination is saved to her profile and returned to her in full for verification

**Scenario 2 — Driver updates her existing destination**
- Given a driver already has a payout destination on file
- When she submits a new one
- Then the stored destination is replaced, not appended — she has exactly one destination at a time

**Scenario 3 — Required fields are validated**
- Given a submission missing the destination type, the number, or the holder name
- Then a validation error is returned identifying the missing field and nothing is saved

**Scenario 4 — Driver retrieves her own destination**
- Given a driver with a saved destination
- When she requests her profile
- Then her destination type, number, and holder name are returned in full

**Scenario 5 — No destination on file returns an empty state, not an error**
- Given a driver with no destination captured
- When she requests her profile
- Then the destination field is null or absent, and no error is raised

**Scenario 6 — A payout cannot be recorded without a destination on file**
- Given a driver with no payout destination on file
- When Finance attempts to record a payout for her (#3993, #4001)
- Then the recording is refused with a reason naming the missing destination

**Scenario 7 — Recording succeeds once a destination is on file**
- Given the same driver adds a payout destination
- When the payout is retried
- Then it succeeds and the `payout` entry is posted

**Scenario 8 — The destination number is masked outside the driver's own view**
- Given a payout destination is captured
- Then any surface other than the driver's own retrieval of her profile shows the number masked, except the admin surface that must action the payout, which shows it in full

**Scenario 9 — The destination in force at the moment of recording is used**
- Given a driver updates her destination
- When a payout is later recorded for her
- Then Finance is shown the destination in force at the moment of recording, never a stale cached copy

**Scenario 10 — Unauthenticated request is rejected**
- Given a request without a valid driver session token
- Then it is rejected

### Out of Scope
- Validating the destination number against a real bank or wallet provider — Phase 1 stores it as given, unverified
- Bank transfer, wallet, or payment-provider integration — payout itself remains operational, outside this system
- Multiple simultaneous destinations per driver
- Payout destination for the rider side (not applicable — riders never receive payouts)
- Driver identity verification beyond onboarding (#1642)

### Dependencies
- #1800 — Driver retrieves her profile (the destination is served alongside the rest of her profile)
- #3993 — Finance records a payout sent to a driver (the payout this destination gates at recording)
- #4001 — Super admin records a payout sent to a driver (enforces the gate at recording)
- #1619 — Authentication service (must be live)

---

### Feature 19 — Payments — Rider API

---

## [API] #4004 — Rider retrieves her outstanding fees and statement 🆕
**Feature:** Feature 19 — Payments — Rider API | **Sprint:** Phase 1

**Description:** As the rider app, I want to retrieve the rider's outstanding fees and the statement behind them so that she can see exactly what she owes, which trip it came from, and that it will be recovered automatically on her next ride.

### Background

This is the rider-facing read over the rider ledger (#3991). It returns her current outstanding balance plus a list of the individual fees behind it, and a paginated statement of every entry that has moved her balance — it never calculates anything itself.

**Almost always zero.** For the overwhelming majority of riders this balance is 0.00 and the fee list is empty; the endpoint exists for the minority carrying an open fee.

**Each open fee names its cause.** A fee entry returns its amount, the trip it came from, the date it was charged, and a note that it will be added automatically to her next completed trip (#4000) — never an instruction to pay separately, because there is no way to collect from her between rides.

**A recovered or waived fee still appears in history.** Once a fee is recovered (#4000) or waived by an admin, it is closed — no longer counted in the outstanding balance — but the original entry and the entry that closed it both remain visible in her statement, exactly as with the driver's ledger (#3991).

The response also carries the configured rider fee recovery threshold (#3994) so the app can tell her, before she confirms a ride, whether her oldest fee alone or her whole balance will be added to it (#4002). She is never refused a booking on account of what she owes.

### Acceptance Criteria

**Scenario 1 — Returns the current outstanding balance**
- Given an authenticated rider requests her fees
- Then the response includes her outstanding balance in EGP and an as-of timestamp

**Scenario 2 — Open fee lists its trip, date, and recovery note**
- Given the rider has an open 20.00 EGP fee from a late cancellation (#1764)
- When she retrieves her fees
- Then the response includes the fee amount, the trip it originated from, the date it was charged, and a note that it will be recovered on her next trip

**Scenario 3 — No outstanding fee — empty state**
- Given a rider with no outstanding fees
- When she retrieves her fees
- Then her outstanding balance is 0.00 and the open-fees list is empty

**Scenario 4 — Recovered fee moves out of the outstanding list**
- Given an open fee was recovered on a later trip (#4000)
- When she retrieves her fees
- Then it no longer appears in the open-fees list and no longer counts toward her outstanding balance
- But it still appears in her statement, alongside the entry that closed it

**Scenario 5 — Waived fee moves out of the outstanding list**
- Given an admin waived an open fee with a reason
- When she retrieves her fees
- Then it no longer appears in the open-fees list, and her statement shows both the original charge and the waiver

**Scenario 6 — Statement is paginated, newest first**
- Given the rider has more entries than one page
- Then the statement is returned newest-first with a page size and a continuation marker
- And requesting the next page returns the next set with no duplicates and no gaps

**Scenario 7 — Balance always equals the ledger**
- Given any rider at any time
- Then the outstanding balance returned equals the sum of her open ledger entries exactly, with no recalculation from trip records

**Scenario 8 — Fee limit is returned for the app's warning**
- Given a rider fee recovery threshold is configured (#3994)
- Then the response includes that threshold so the rider app can tell her whether her next ride recovers one fee or all of them (#4002)

**Scenario 9 — Two open fees are both listed, oldest first**
- Given a rider has two open fees from two separate cancellations
- Then both appear in the open-fees list, ordered oldest first, matching the order they will be recovered (#4000)

**Scenario 10 — Unauthenticated request is rejected**
- Given a request without a valid rider session token
- Then it is rejected

### Out of Scope
- Posting entries to the ledger (#3991)
- Deciding whether a fee applies or its amount (#1764)
- Recovering a fee (#4000)
- Waiving a fee (admin-side, #4005)
- Blocking booking while over the limit (#4002)
- Paying a fee through this endpoint — it is read-only
- Receipt or statement PDF export

### Dependencies
- #3991 — Party balance ledger records every balance movement (must be live — the only source of these figures)
- #3994 — Super admin configures balance and fee policy (supplies the fee limit returned here)
- #1764 — Cancellation fees are charged after the grace period (supplies the fee itself)
- #4000 — Rider outstanding fee is recovered on her next trip (closes the fee this story reports as recovered)
- #1619 — Authentication service (must be live)

---

### Feature 20 — Trip Cancellation API

---

## [API] #1715 — Rider cancels a trip 🆕
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** 2

**Description:** As the rider app, I want to send a trip cancellation request so that the platform can cancel the trip, notify the driver, and record any applicable cancellation fee.

### Background

This endpoint is called when an authenticated rider confirms a trip cancellation on the mobile app. The platform validates the trip belongs to the requesting rider, checks the current trip state to determine whether a cancellation fee applies (fee applies only in arrived_pickup state), updates the trip status to cancelled, and returns the final trip record including the fee amount (zero or non-zero). The assigned driver sees the cancellation on her next trip-state poll. Cancellation is not permitted once the trip is in trip_started or trip_ended state.

### Acceptance Criteria

**Scenario 1 — Successful cancellation in searching state (no fee)**
- Given an authenticated rider sends a cancellation request for a trip in searching state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And the response includes cancellation_fee: 0

**Scenario 2 — Successful cancellation in en_route_pickup state (no fee)**
- Given an authenticated rider sends a cancellation request for a trip in en_route_pickup state
- And the cancellation opening window didn't pass
- When the endpoint is called
- Then the trip status is updated to cancelled
- And the response includes cancellation_fee: 0

**Scenario 3 — Successful cancellation in arrived_pickup state (fee applies)**
- Given an authenticated rider sends a cancellation request for a trip in arrived_pickup state
- When the endpoint is called
- Then the trip status is updated to cancelled
- And a cancellation fee is recorded against the rider's account
- And the response includes the cancellation_fee amount in EGP

**Scenario 4 — Cancellation rejected in trip_started state**
- Given the trip is in trip_started state
- When the endpoint is called
- Then the platform returns an error: trip cannot be cancelled after it has started

**Scenario 5 — Cancellation rejected for wrong rider**
- Given an authenticated rider attempts to cancel a trip that does not belong to her
- When the endpoint is called
- Then the platform returns an authorisation error

**Scenario 6 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets the cancellation endpoint
- Then the platform rejects the request via #1619

### Out of Scope
- Cancellation fee payment processing or collection
- Refund processing
- Admin-initiated cancellation

### Dependencies
- #1619 — Authentication service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1720 — Driver cancels an accepted trip 🆕
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** 2

**Description:** As the driver app, I want to send a trip cancellation request with a reason so that the platform can cancel the trip, record why it was cancelled, apply or waive the driver cancellation fee according to policy, notify the rider, flag the cancellation on the driver's record when appropriate, and return the driver to available status.

### Background

This endpoint is called when an authenticated driver confirms a trip cancellation. The request must include a cancellation reason from a fixed list (rider_no_show, rider_unreachable, vehicle_issue, safety_concern, wrong_pickup_location, other). The platform validates the trip belongs to the requesting driver and that the current state permits cancellation (only en_route_pickup or arrived_pickup). It updates the trip to cancelled with cancelled_by=driver and the supplied reason, then determines the driver cancellation fee via #1764: no fee within the driver cancellation grace period; the driver cancellation fee after the grace period, waived only when the reason is rider_no_show and the driver had marked arrived and waited at least the configured rider no-show wait time. The platform flags the cancellation on the driver's performance record when a fee is charged, sets the driver's status to online/available, and returns the updated trip record. The rider sees the cancellation on her next trip-state poll.

**Scenario 1 — Cancellation within the driver grace period — no fee, no flag**
- Given an authenticated driver cancels a trip in en_route_pickup within the driver cancellation grace period
- When the endpoint is called with a valid reason
- Then the trip status is updated to cancelled with cancelled_by=driver and the reason recorded
- And no driver cancellation fee is charged and no performance flag is added
- And the driver's status is set to online/available

**Scenario 2 — Cancellation after the grace period — fee charged and flagged**
- Given an authenticated driver cancels after the driver cancellation grace period for a reason other than a qualifying rider no-show
- When the endpoint is called
- Then the trip is cancelled, the driver cancellation fee is applied, and the cancellation is flagged on the driver's performance record
- And the driver's status is set to online/available

**Scenario 3 — Rider no-show after the wait time — fee waived**
- Given the driver is in arrived_pickup and has waited at least the rider no-show wait time
- When the endpoint is called with reason rider_no_show
- Then the trip is cancelled with no_show=true and no driver cancellation fee is charged
- And no performance flag is added against the driver
- And the driver's status is set to online/available

**Scenario 4 — No-show claimed before the wait time — fee charged**
- Given the driver sends reason rider_no_show but has not marked arrived or has waited less than the rider no-show wait time
- When the endpoint is called
- Then the no-show waiver does not apply and the driver cancellation fee is charged

**Scenario 5 — Cancellation requires a valid reason**
- Given a cancellation request with no reason or a reason outside the allowed list
- When the endpoint is called
- Then a validation error is returned and the trip is not cancelled

**Scenario 6 — Cancellation rejected in trip_started state**
- Given the trip is in trip_started state
- When the endpoint is called
- Then the platform returns an error: trip cannot be cancelled after it has started

**Scenario 7 — Cancellation rejected for wrong driver**
- Given an authenticated driver attempts to cancel a trip that does not belong to her
- When the endpoint is called
- Then the platform returns an authorisation error

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- When it targets this endpoint
- Then the platform rejects the request

### Out of Scope
- Rider compensation for driver cancellation
- Driver appeal/dispute of the cancellation fee (Phase 2)
- Payout/deduction mechanics from the driver's wallet or earnings balance

### Dependencies
- #1652 — Driver advances trip state machine (must be live)
- #1764 — Cancellation fees are charged after grace period (driver fee logic)
- #1759 — Super admin configures global pricing policies (driver grace period, fee, no-show wait time)

---

## [API] #1764 — Cancellation fees are charged after the grace period (rider and driver) ♻️
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** Phase 1

**Description:** As the trip service, I want to apply the correct cancellation fee when either a rider or a driver cancels after the applicable grace period and post the result to both parties' balance ledgers so that a rider who cancels late is held to what she owes, the driver who was left waiting is compensated, a driver who cancels late is held accountable, and genuine rider no-shows are never penalised.

### Background

#1715 and #1720 decide *that* a trip is cancelled and record who cancelled and why. This story is the money: it decides **whether** a fee applies, **how much**, **how it is split**, and **posts the movement to both parties' balance ledgers** (#3991). Without it a cancellation fee is a number on a trip record that never reaches anyone's balance — and a rider who cancels late walks away owing nothing to anyone.

**Rider cancellation fee.** The amount is the fixed EGP value on the zone's rate card (#1757). The rider grace period is the global setting (#1759) and the clock starts when the driver accepts. Cancelling inside the grace period costs nothing. Cancelling after it **opens a `cancellation_fee` debit on the rider's own ledger** (#3991) for the full fee amount, and the fee is split between the driver and the platform using the configured driver share percentage — the driver's share is **credited to her balance** as a `rider_cancellation_fee_share` entry. Opening the fee does not collect it: there is no way to collect from a rider between rides, so the debit sits on her ledger until it is recovered as a surcharge on her next completed trip (#4000).

**Driver cancellation fee.** A fixed EGP amount (#1759) is charged to a driver who cancels an accepted trip after the driver cancellation grace period, measured from her acceptance. Cancelling inside the grace period costs nothing. The fee is waived only when the reason is rider no-show *and* she had marked arrived and waited at least the configured rider no-show wait time. In every other late driver cancellation the fee applies and is **debited from her balance** as a `driver_cancellation_fee` entry.

**Commission is never taken from a cancellation fee.** The driver receives her full configured share, consistent with #1636.

**Values are snapshotted at driver acceptance.** The fee, grace periods, split, and wait time used are those active when the driver accepted — not those in force at the moment of cancellation.

**Posting is idempotent.** A cancellation posts at most one ledger entry per party per ledger. A retried or replayed cancellation never charges twice (#3991).

### Acceptance Criteria

**Scenario 1 — Rider cancels within the grace period**
- Given a driver has accepted and the rider grace period has not expired
- When the rider cancels
- Then no cancellation fee is charged
- And the trip record is marked cancelled by rider with no fee
- And no ledger entry is posted for either party

**Scenario 2 — Rider cancels after the grace period — fee opened on her ledger**
- Given a driver has accepted and the rider grace period has expired
- When the rider cancels
- Then the zone's cancellation fee is charged to the rider
- And a `cancellation_fee` entry for the full amount is debited from the rider's balance (#3991)
- And it is split using the driver share percentage active at driver acceptance
- And the trip record stores the fee amount, the driver share, and the platform share

**Scenario 3 — Driver's share of a rider cancellation fee reaches her balance**
- Given a rider cancels late, the fee is 20 EGP and the driver share is 75%
- Then a `rider_cancellation_fee_share` entry of +15.00 EGP is posted to the assigned driver (#3991)
- And her balance moves in her favour by 15.00 EGP
- And no commission is deducted from that amount

**Scenario 4 — The rider's fee is opened, not collected, at cancellation**
- Given a rider cancels late and her fee is charged (Scenario 2)
- Then her balance goes negative by the fee amount immediately
- And no cash or payment is taken from her at this point — collection happens on her next completed trip (#4000)

**Scenario 5 — Driver cancels within the driver grace period — no fee**
- Given a driver cancels within the driver cancellation grace period after accepting
- Then no driver cancellation fee is charged
- And the trip record is marked cancelled by driver with the reason and no fee
- And no ledger entry is posted

**Scenario 6 — Driver cancels after the grace period — fee charged and debited**
- Given a driver cancels after the driver cancellation grace period for a reason other than a qualifying rider no-show
- Then the driver cancellation fee is charged
- And a `driver_cancellation_fee` entry for that amount is debited from her balance (#3991)
- And the trip record stores the reason and the fee amount

**Scenario 7 — Driver cancels a rider no-show after the wait time — fee waived**
- Given the driver has marked arrived and waited at least the rider no-show wait time
- When she cancels with reason rider no-show
- Then no driver cancellation fee is charged, the trip is flagged as a no-show, and no ledger entry is posted

**Scenario 8 — No-show claimed before the wait time — fee charged**
- Given the driver cancels with reason rider no-show but has not marked arrived or has waited less than the wait time
- Then the waiver does not apply, the fee is charged, and it is debited from her balance

**Scenario 9 — A driver fee can push her balance further into arrears**
- Given a driver already owes the platform 480 EGP and a 20 EGP cancellation fee is charged
- Then her outstanding balance becomes 500 EGP
- And the go-online balance gate applies from her next attempt (#3996)

**Scenario 10 — A rider fee can push her over the recovery threshold**
- Given a rider already owes 40 EGP and a 20 EGP cancellation fee is charged, against a 60 EGP recovery threshold
- Then her outstanding balance becomes 60 EGP
- And her next completed trip recovers the whole 60 EGP in one payment rather than her oldest fee alone (#4002)
- And she is not prevented from booking

**Scenario 11 — Policy changes during an active trip**
- Given any grace period, fee, split, or wait-time value is changed by an admin after the driver accepted
- Then the trip uses the values active at the time of driver acceptance

**Scenario 12 — Cancellation before driver acceptance**
- Given a cancellation occurs while the trip is still in the matching phase with no driver accepted
- Then no fee is charged to either party regardless of elapsed time, and no ledger entry is posted

**Scenario 13 — Gender-mismatch cancellation is always fee-free**
- Given a trip is cancelled through the gender-mismatch report (#1687)
- Then no fee is charged to either party and no ledger entry is posted

**Scenario 14 — A cancellation never charges twice**
- Given the same cancellation is processed or retried more than once
- Then at most one fee is charged per party and at most one ledger entry is posted per party

### Out of Scope
- Recovering the rider's fee as a surcharge on a later trip — this story opens the debt on her ledger; #4000 is the collection
- Rider compensation when a driver cancels (Phase 2)
- Rider or driver dispute of a cancellation fee (Phase 2)
- Deciding cancellation eligibility and trip state transitions (#1715, #1720)
- The ledger itself and its posting guarantees (#3991)
- Blocking booking or going online while over a balance limit (#3996, #4002)

### Dependencies
- #3991 — Party balance ledger records every balance movement (must be live — receives every fee movement, on both ledgers)
- #1757 — Super admin configures zone rate card (rider cancellation fee amount)
- #1759 — Super admin configures global platform policies (grace periods, driver share, driver fee, no-show wait time)
- #1715 — Rider cancels a trip (supplies the rider cancellation event)
- #1720 — Driver cancels an accepted trip (supplies the reason and no-show status)

---

## [API] #4000 — Rider outstanding fee is recovered on her next trip 🆕
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** Phase 1

**Description:** As the trip-completion service, I want to add a rider's oldest outstanding fee as a surcharge on her next completed trip and post the recovery to both the rider's and the driver's ledgers so that a fee she has no way to pay between rides is still collected, in cash, without the platform absorbing the loss.

### Background

#1764 opens a rider's outstanding fee — it debits her ledger (#3991) but collects nothing, because there is no way to collect from a rider between rides. This story is the collection: it recovers the fee as a **surcharge on her very next completed trip**, added to the fare and collected by the driver in cash alongside it.

**The surcharge is shown up front, not folded in.** It appears on the fare estimate before she confirms the ride and again on the trip's fare summary as its own line, distinct from the fare itself — never silently added to the total she is quoted.

**Commission is never taken from a recovered fee.** The platform already holds its share of the fee from #1764's split; charging commission again on the surcharge would double-collect it. The trip's fare, commission and net earnings (#1636, #3997) are computed on the fare alone — the surcharge rides alongside, untouched by commission.

**One fee at a time, oldest first.** If a rider has more than one outstanding fee, only the oldest is recovered on her next trip; the rest wait for the trips after that. A single trip never recovers more than one fee.

**What actually gets posted depends on custody (#3997), not on how the fee arose.** Under `custody = driver` (Phase 1 cash), the surcharge is cash the driver now holds on the platform's behalf, so a `rider_fee_recovery` debit is posted against her — she owes it back exactly as she owes trip commission. Under `custody = platform`, the platform collects the surcharge itself as part of the digital payment, so nothing beyond the normal `trip_earnings` credit is posted to the driver — she was never holding the cash. On both paths the rider's ledger receives the same `fee_collected` credit and the driver ends up entitled to the same amount; only the mechanics of how the driver's ledger reaches that amount differ.

**Worked example** — outstanding fee 20.00, driver's earlier cancellation-fee share 15.00, next trip fare 100.00, commission 20.00:

| Custody | Rider ledger | Driver ledger this trip | Driver position |
|---|---|---|---|
| `driver` (cash) | `fee_collected` +20.00 → balance 0.00 | `trip_commission` −20.00, `rider_fee_recovery` −20.00 | Holds 120.00 cash, owes 25.00 → entitled to 95.00 ✓ |
| `platform` (online) | `fee_collected` +20.00 → balance 0.00 | `trip_earnings` +80.00 | Holds 0.00, platform owes 95.00 → entitled to 95.00 ✓ |

The driver is entitled to the same 95.00 EGP (80.00 net earnings plus her 15.00 cancellation-fee share) under both paths.

### Acceptance Criteria

**Scenario 1 — Outstanding fee is recovered on the next completed trip (cash custody)**
- Given a rider owes an outstanding fee of 20.00 EGP (#1764) and completes her next trip with custody = driver, fare 100.00 EGP, commission 20.00 EGP
- When the trip settles
- Then a `fee_collected` entry of +20.00 EGP is posted to the rider's ledger and her balance returns to 0.00
- And a `rider_fee_recovery` entry of −20.00 EGP is posted to the driver's ledger, in addition to the trip's own `trip_commission` entry (#3997)
- And the driver's total cash held for the trip is 120.00 EGP (100.00 fare + 20.00 surcharge)

**Scenario 2 — Outstanding fee is recovered without a driver-side recovery debit (platform custody)**
- Given the same outstanding 20.00 EGP fee, but the next trip completes with custody = platform, fare 100.00 EGP, net earnings 80.00 EGP
- When the trip settles
- Then a `fee_collected` entry of +20.00 EGP is posted to the rider's ledger and her balance returns to 0.00
- And no `rider_fee_recovery` entry is posted to the driver — only the trip's normal `trip_earnings` entry of +80.00 EGP (#3997), because the driver never held the surcharge in cash

**Scenario 3 — The driver is entitled to the same amount under both custody values**
- Given the worked example above (fee 20.00, driver's cancellation-fee share 15.00, trip fare 100.00, commission 20.00)
- Then under custody = driver the driver's net position across the two events is −25.00 (she owes 25.00 against 120.00 held), and under custody = platform it is +95.00 (the platform owes her 95.00)
- And 95.00 EGP is what she is entitled to on both paths

**Scenario 4 — Commission is not charged again on the surcharge**
- Given a trip's fare is 100.00 EGP and a 20.00 EGP fee is recovered alongside it
- Then commission is calculated on the 100.00 EGP fare only — never on 120.00 — and no separate commission entry is posted against the surcharge

**Scenario 5 — Only the oldest of several outstanding fees is recovered**
- Given a rider has two outstanding fees, 20.00 EGP dated earlier and 20.00 EGP dated later
- When she completes her next trip
- Then only the earlier (oldest) fee is recovered as this trip's surcharge
- And the later fee remains outstanding for a subsequent trip

**Scenario 6 — At most one fee is recovered per trip**
- Given a rider has two outstanding fees
- When a single trip completes
- Then exactly one `fee_collected` entry is posted for that trip, never two

**Scenario 7 — The surcharge is included in the fare estimate before she confirms**
- Given a rider with an outstanding fee requests a fare estimate (#1627)
- Then the estimate includes the surcharge as a distinct line, separate from the fare, so she sees the full amount before she books

**Scenario 8 — The surcharge appears as its own line on the completed-trip summary**
- Given a trip recovered an outstanding fee
- Then the rider's completed-trip summary (#3058) shows the surcharge as a line item distinct from the fare, and the total is fare plus surcharge

**Scenario 9 — No outstanding fee — trip completes with no surcharge**
- Given a rider has no outstanding fee
- When her trip completes
- Then no `fee_collected` or `rider_fee_recovery` entry is posted, and the fare summary carries no surcharge line

**Scenario 10 — Recovery is idempotent**
- Given a trip's settlement is retried or replayed
- Then at most one `fee_collected` entry and at most one `rider_fee_recovery` entry (when custody = driver) are posted for that trip

**Scenario 11 — Recovery runs only on a completed trip**
- Given a trip that is cancelled rather than completed
- Then no fee recovery is attempted on it, and the rider's outstanding fee remains open for the trip after

### Out of Scope
- Opening the outstanding fee in the first place — deciding it applies and its amount (#1764)
- The ledger itself and its entry types (#3991)
- Escalating to full-balance recovery above the threshold (#4002)
- Choosing which ledger entry a trip's own fare posts — trip_commission vs trip_earnings (#3997)
- The rider-facing screens that display the outstanding fee and the surcharge (mobile rider stories)
- Recovering a fee by any means other than a cash surcharge on a ride
- Rider or driver dispute of a recovered fee (Phase 2)
- Partial recovery — a fee is recovered in full or not at all

### Dependencies
- #1764 — Cancellation fees are charged after the grace period (must be live — supplies the outstanding fee this story recovers)
- #3991 — Party balance ledger records every balance movement (must be live — the ledger this story posts into)
- #3997 — Trip completion posts to the ledger according to fare custody (must be live — supplies the trip's custody value and its own entry)
- #1627 — Rider fare estimate (extended with the surcharge line)
- #3058 — Completed-trip fare is served to rider and driver (extended with the surcharge line)

---

## [API] #4002 — Rider fees above the recovery threshold are recovered in a single payment 🆕
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** Phase 1

**Description:** As the trip service, I want to recover a rider's entire outstanding fee balance on one trip once it reaches the configured threshold, instead of one fee at a time, so that a growing unrecovered balance is cleared quickly without ever refusing her a ride.

### Background

`#4000` recovers a rider's fees gently — the oldest fee only, one per trip. That is right for a rider carrying a single fee. It is too slow for a rider who has cancelled late several times: her balance can grow faster than the drip clears it.

This story is the escalation. When her outstanding balance is **at or above the rider fee recovery threshold** configured in `#3994` (default 60.00 EGP), the surcharge applied to her next completed trip is her **whole** outstanding balance in a single `fee_collected` entry, not just the oldest fee. Setting the threshold to zero disables the escalation entirely and recovery always stays at one fee per trip.

**There is deliberately no booking block.** An earlier draft of this design refused trip requests above the threshold. That deadlocks: a rider pays in cash on the ride and cannot be charged between rides, so the *only* mechanism that can ever clear her fee is completing a trip. Refusing the booking would make the balance permanent, recover nothing, and lose the rider. Escalating the recovery instead is self-clearing — she books, she pays it all, she is square.

**Persistent abuse is a human decision, not an automatic one.** A rider who repeatedly runs the balance up is suspended through the existing rider-suspension flow (#1740), actioned by an admin from the rider outstanding-fees screen. The trip-request service applies no fee-based guard of its own.

**The driver side is unchanged in shape, only in amount.** Under `custody = driver` the whole recovered amount posts as a single `rider_fee_recovery` debit on the collecting driver, exactly as in `#4000`. Under `custody = platform` no such entry is posted. Commission is never taken from any recovered amount.

**The amount is fixed when the trip completes**, not when it is requested, so a fee incurred mid-trip is not swept into that same trip's recovery.

### Acceptance Criteria

**Scenario 1 — Whole balance is recovered above the threshold**
- Given the recovery threshold is 60.00 EGP and a rider owes 65.00 EGP across three fees
- When her next trip completes at a fare of 100.00 EGP with custody driver
- Then a single `fee_collected` entry of +65.00 EGP is posted to her ledger and her balance becomes 0.00 EGP
- And the total she is asked to pay is 165.00 EGP

**Scenario 2 — The collecting driver is debited the full recovered amount**
- Given the same trip
- Then a `rider_fee_recovery` entry of −65.00 EGP is posted to the driver's ledger (#3991)
- And her `trip_commission` entry is calculated on the 100.00 EGP fare only

**Scenario 3 — Below the threshold the drip still applies**
- Given the threshold is 60.00 EGP and a rider owes 40.00 EGP across two fees
- When her next trip completes
- Then only her oldest fee is recovered, per #4000

**Scenario 4 — Exactly at the threshold escalates**
- Given the threshold is 60.00 EGP and a rider owes exactly 60.00 EGP
- Then the whole balance is recovered, not the oldest fee alone

**Scenario 5 — A threshold of zero disables the escalation**
- Given the recovery threshold is configured at 0
- When a rider owes 500.00 EGP
- Then recovery remains one fee per trip and no escalation ever applies

**Scenario 6 — Booking is never refused on account of fees**
- Given a rider owes any amount at all
- When she requests a trip
- Then the request is evaluated by the existing service-area and operating-hours guards only
- And her outstanding balance never causes a refusal

**Scenario 7 — Custody platform posts no driver recovery entry**
- Given the same 65.00 EGP recovery on a trip with custody platform
- Then the rider is credited +65.00 EGP and no `rider_fee_recovery` entry is posted to the driver
- And the driver's `trip_earnings` entry is her net on the fare only

**Scenario 8 — A waiver drops her back to the drip**
- Given an admin waives a fee bringing her below the threshold before her next trip
- Then her next completed trip recovers only her oldest remaining fee

**Scenario 9 — A fee incurred mid-trip is not swept in**
- Given a rider is on a trip and a fee from an earlier cancellation is posted while it runs
- Then the recovery amount applied at completion is the balance as at trip start

**Scenario 10 — Recovery is idempotent**
- Given the same trip completion is retried
- Then at most one `fee_collected` entry and one `rider_fee_recovery` entry are posted (#3991)

### Out of Scope
- Any booking or request refusal based on outstanding fees — suspension (#1740) is the only block on a rider
- The gentle one-fee-per-trip recovery itself (#4000)
- Collecting the balance by any means other than the surcharge on her next ride
- Waiving or adjusting a fee (#4005)
- The rider-facing copy that warns her (mobile rider backlog)

### Dependencies
- `#4000` — Rider outstanding fee is recovered on her next trip (this story escalates it)
- `#3991` — Party balance ledger records every balance movement (must be live)
- `#3994` — Super admin configures balance and fee policy (supplies the threshold)
- `#1764` — Cancellation fees are charged after the grace period (creates the fees)
- `#1740` — Operations admin suspends a rider account (the only block on a rider)

---

## [API] #1687 — Rider account is placed under review after a gender mismatch report ✏️
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 4

**Description:** As a developer, I want the gender mismatch report endpoint to cancel the active trip and flag the rider's account for admin review so that SheDrive's women-only service guarantee is enforced and the incident is investigated before the rider can book another trip.

### Background

This endpoint is called by the driver app when she confirms "Cancel — Rider Not Female" at pickup verification (#1588). It does three things in one transaction: ends the trip with no fare, creates a **gender-mismatch report record**, and moves the reported rider's account to `pending_review`. It never suspends anyone — a human admin decides that later (#1811).

**First-trip verification is mandatory.** On every rider's first trip the driver must **always** verify at pickup that the rider is female before the trip can start (#1588). The step cannot be skipped, dismissed or switched off, and there is no exception for any passenger. A gender-mismatch report can only be raised from that step, so every report relates to a rider's first trip; returning riders are not re-checked.

**Terminology.** The driver-facing button and dialog say "Cancel", but on the platform the trip is **ended as Expired** with reason `gender_mismatch_report`. It is never recorded as a rider or driver cancellation, so no cancellation fee or cancellation count applies to either party. Likewise this endpoint **places the rider under review**; it never suspends her.

There is no per-passenger exception. _(The declared child-passenger carve-out was removed from Phase 1 on 2026-09-09 — #1783 and #1790 are Removed and recorded in docs/backlog/phase-1.5-stories.md.)_

#### The report record

The record this endpoint creates is what the admin queue lists and the admin case detail reads (#1810 / #1811). It holds:

| Field | Notes |
|---|---|
| Report id | Stable, human-quotable identifier |
| Trip id | The trip that was ended |
| Reported rider | Id, name, phone — captured at report time |
| Reporting driver | Id, name — taken from the authenticated session, never from the request body |
| Report time | UTC+2 |
| Statement | The driver's optional free text, ≤ 500 characters; may be empty |
| Report status | `open` on creation; `resolved` once an admin acts (#1811) |
| Resolution | Empty until resolved, then `suspended` or `dismissed` (#1811) |
| Rider account status at report time | Snapshot, so the queue can show it even after the account moves on |

#### The pending_review account state

This is a **fourth** rider account state, distinct from the `active` / `suspended` / `pending_suspension` set that #1739 owns. It is entered only by this endpoint and left only by an admin decision (#1811): upheld → `suspended`, dismissed → `active`. It blocks new trip requests but is not a suspension — sessions stay valid and the rider is not told she has been suspended, because nothing has been adjudicated yet.

### Acceptance Criteria

**Scenario 1 — Gender mismatch report submitted — trip ended and rider flagged**
- Given the driver has tapped "Cancel — Rider Not Female" and confirmed the dialog
- When the driver app calls this endpoint
- Then the active trip is ended immediately with expiry reason `gender_mismatch_report`, so it appears under Expired in the admin trip list with that reason (#1670 / #1671)
- And a report record is created with status `open`
- And the reported rider's account status becomes `pending_review`
- And the driver is returned to her home screen in the online/available state

**Scenario 2 — No fare charged**
- Given a trip is ended via this endpoint
- Then no fare is calculated or stored for that trip
- And no cancellation fee is charged to either party
- And the rider's app shows the trip as ended with no fare charged, rather than a trip summary

**Scenario 3 — Driver's availability is restored**
- Given the report has been processed
- Then her online status is preserved
- And she is eligible to receive the next dispatched trip without re-toggling availability

**Scenario 4 — Flagged rider cannot request a new trip**
- Given the rider's account is in `pending_review`
- When she attempts to submit a new trip request via #1629
- Then the server returns a forbidden error: account is under review
- And the response carries the report reference and the date it was raised, so the app can show them (screen owned by #3768)

**Scenario 5 — Existing sessions are not invalidated**
- Given the rider's account has moved to `pending_review`
- Then her existing sessions remain valid and she can still open the app and view her history
- And only new trip requests are refused — this is a review, not a suspension

**Scenario 6 — Only applicable to first trips, where verification is always required**
- Given is_first_trip = true, the driver app always presents the verification step and a mismatch can only be acted on through this endpoint
- Given is_first_trip = false for the trip
- Then this endpoint is not applicable and the "Cancel — Rider Not Female" button is not shown
- And a report submitted for a returning rider's trip is rejected

**Scenario 7 — Report only valid while the trip is in arrived_pickup**
- Given the trip is in any state other than arrived_pickup
- Then the server returns a validation error: mismatch report can only be submitted at pickup verification

**Scenario 8 — Only the assigned driver may report**
- Given a driver who is not the one assigned to that trip calls this endpoint
- Then the request is rejected
- And the reporting driver recorded on the report is always taken from the authenticated session

**Scenario 9 — One report per trip**
- Given a report already exists for a trip
- When the endpoint is called again for the same trip
- Then no second report is created and the request is rejected

**Scenario 10 — Report carries the driver's optional statement**
- Given the driver entered a statement in the confirmation dialog (#1588 Scenario 3)
- Then the statement is stored on the report record, up to 500 characters
- And it is returned with the report detail served to the admin (#1810 / #1811)

**Scenario 11 — Statement is optional, and an over-length one is rejected**
- Given the driver submits the report with no statement
- Then the report is accepted and stored with an empty statement
- And the empty statement is served to the admin as empty rather than omitted, so the case can show a recorded absence rather than a blank panel
- And given a statement longer than 500 characters is submitted
- Then the server returns a validation error and no report is created

**Scenario 12 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

### Out of Scope
- Resolving the report — suspend or dismiss (#1811)
- Listing or filtering reports for the admin queue (#1810)
- Suspending the rider automatically — the platform never suspends anyone on this path
- Notifying the rider that a report was raised, beyond the refusal she meets at her next booking
- Any per-passenger exception to the women-only rule (removed from Phase 1)
- Penalısing drivers for reports later dismissed

### Dependencies
- #1588 — Driver verifies rider is female on first trip — mandatory on every first trip (calls this endpoint)
- #1635 — Trip detail includes first-trip flag (gates when the button is shown)
- #1629 — Rider creates trip request (the call refused in Scenario 4)
- #3768 — Rider is told her account is under review (consumes the forbidden response)
- #1810 / #1811 — Admin gender-mismatch report queue and resolution (read and resolve these records)
- #1739 — Account suspension status is updated by admin (the mechanism #1811 reuses to uphold a report)
- #1816 — Admin activity audit log

> **Removed 2026-09-09:** #4012 (admin retrieves the gender-mismatch report queue and a single report) and #4013 (admin resolves a gender-mismatch report) are Removed in ADO. The admin-side backend for the queue and the resolution is tracked as [BE] tasks under the Admin stories #1810 and #1811, so the admin contract lives in those stories. #1687 remains the only [API] story in this chain.

---

## [API] #1780 — Rider's emergency contacts are notified with a live location link on SOS 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the rider app, I want to store a rider's emergency contacts and, when she triggers SOS during an active trip, notify those contacts with a live trip-tracking link so that the people she trusts can follow her location in real time during an emergency.

### Acceptance Criteria

**Scenario 1 — Emergency contacts can be stored and managed**
- Given a signed-in rider
- When the app creates, retrieves, updates or deletes an emergency contact (name, phone number, relationship)
- Then the change is stored against her account and is returned on the next retrieval

**Scenario 2 — At most five contacts are accepted**
- Given a rider already has 5 emergency contacts stored
- When the app attempts to store a sixth
- Then the request is rejected and the sixth contact is not stored

**Scenario 3 — Every contact is alerted on SOS**
- Given a rider with at least one stored emergency contact
- When she triggers SOS during an active trip
- Then each of her emergency contacts is sent an alert
- And that alert contains a live trip-tracking link to her current location

**Scenario 4 — Each alert reports its own delivery result**
- Given alerts have been sent for an SOS
- When the app asks for their status
- Then the delivery result of each individual alert is returned as sent, delivered or failed, per contact

**Scenario 5 — One failed alert does not stop the others**
- Given the alert to one contact fails
- When the remaining contacts are processed
- Then they are still alerted
- And the failure is reported against that one contact only

**Scenario 6 — The link follows the live location link rules**
- Given alerts have been sent for an SOS
- When a contact opens the live location link in her alert
- Then it is the case's single link issued under #3971 and behaves exactly as that story defines: live while the trip runs, stopping 60 minutes after the trip ends, and stopping immediately if she stops sharing or stands the alert down
- And this story does not issue, expire or revoke the link itself

**Scenario 7 — Only her own contacts are notified**
- Given a rider triggers SOS
- When the alerts are sent
- Then only the emergency contacts stored against her own account are alerted, and no one else

**Scenario 8 — SOS with no contacts stored**
- Given a rider with no emergency contacts stored
- When she triggers SOS during an active trip
- Then no alert is sent
- And the app is told there are no contacts, so that it can prompt her to add them

**Dependencies:** Consumed by [Mobile] #1787 (rider contacts) and #3968 (rider emergency screen). The live link it sends is the one issued, scoped and expired by #3971. Needs an SMS supplier able to deliver to Egyptian mobile numbers and report delivery results — none is contracted yet, and the per-contact delivery status depends on it.

---

## [API] #1952 — Driver's emergency contacts are notified with a live location link on SOS 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the driver app, I want to store a driver's emergency contacts and, when she triggers SOS during an active trip, notify those contacts with a live trip-tracking link so that the people she trusts can follow her location in real time during an emergency.

### Acceptance Criteria

**Scenario 1 — Emergency contacts can be stored and managed**
- Given a signed-in driver
- When the app creates, retrieves, updates or deletes an emergency contact (name, phone number, relationship)
- Then the change is stored against her account and is returned on the next retrieval

**Scenario 2 — At most five contacts are accepted**
- Given a driver already has 5 emergency contacts stored
- When the app attempts to store a sixth
- Then the request is rejected and the sixth contact is not stored

**Scenario 3 — Every contact is alerted on SOS**
- Given a driver with at least one stored emergency contact
- When she triggers SOS during an active trip
- Then each of her emergency contacts is sent an alert
- And that alert contains a live trip-tracking link to her current location

**Scenario 4 — Each alert reports its own delivery result**
- Given alerts have been sent for an SOS
- When the app asks for their status
- Then the delivery result of each individual alert is returned as sent, delivered or failed, per contact

**Scenario 5 — One failed alert does not stop the others**
- Given the alert to one contact fails
- When the remaining contacts are processed
- Then they are still alerted
- And the failure is reported against that one contact only

**Scenario 6 — The link follows the live location link rules**
- Given alerts have been sent for an SOS
- When a contact opens the live location link in her alert
- Then it is the case's single link issued under #3971 and behaves exactly as that story defines: live while the trip runs, stopping 60 minutes after the trip ends, and stopping immediately if she stops sharing or stands the alert down
- And this story does not issue, expire or revoke the link itself

**Scenario 7 — Only her own contacts are notified**
- Given a driver triggers SOS
- When the alerts are sent
- Then only the emergency contacts stored against her own account are alerted, and no one else

**Scenario 8 — SOS with no contacts stored**
- Given a driver with no emergency contacts stored
- When she triggers SOS during an active trip
- Then no alert is sent
- And the app is told there are no contacts, so that it can prompt her to add them

**Dependencies:** Consumed by [Mobile] #1951 (driver contacts) and #3969 (driver emergency screen). The live link it sends is the one issued, scoped and expired by #3971. Needs an SMS supplier able to deliver to Egyptian mobile numbers and report delivery results — none is contracted yet, and the per-contact delivery status depends on it.

---

## [API] #3970 — SOS incident is recorded with a full trip snapshot 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the SheDrive platform, I want to create a permanent SOS case with a full snapshot of the trip the instant an SOS is confirmed, so that operations can review, investigate and report on every incident afterwards.

### Background

An SOS case is a first-class, permanent record — one confirmed tap creates exactly one case. The case captures everything known about the incident at the moment it happened, because the trip continues and the car keeps moving afterwards; the case must still show where she was and what was happening when she pressed the button. Creating a case never interrupts the trip and never suspends anyone automatically — those remain separate, later decisions for an admin.

### Acceptance Criteria

**Scenario 1 — A case is created on confirmation**
- Given a rider or a driver is on an active trip
- When she confirms an SOS
- Then exactly one SOS case is created for that confirmation

**Scenario 2 — The snapshot records who raised it**
- Given an SOS has been confirmed
- When the case is created
- Then it records whether the rider or the driver raised it and which person that was, together with the rider's name and phone number and the driver's name and phone number

**Scenario 3 — The snapshot records the trip context**
- Given an SOS has been confirmed
- When the case is created
- Then it records the trip it belongs to, the state that trip was in at the moment of the trigger (on the way to pickup, waiting at pickup, or trip under way), and the vehicle's make, model, colour and plate

**Scenario 4 — The snapshot records where it happened**
- Given an SOS has been confirmed
- When the case is created
- Then it records her position at the moment of the trigger together with the matching street address, the trip's pickup address, the trip's destination address, and how far along the route she was

**Scenario 5 — The snapshot records when it happened**
- Given an SOS has been confirmed
- When the case is created
- Then it records the date and time of the trigger in local Egyptian time

**Scenario 6 — The case records the alert outcome and keeps it current**
- Given an SOS has been confirmed
- When her emergency contacts have been alerted
- Then the case records which contacts were alerted and the delivery result for each one
- And each delivery result is updated as the SMS supplier reports it, moving from sent to delivered or failed

**Scenario 7 — The snapshot cannot change afterwards**
- Given a case has been created
- When the trip continues, the car moves, or any other trip detail changes later
- Then none of the snapshot recorded in Scenarios 2 to 5 changes
- And the only details that may change later are each contact's delivery result (Scenario 6), the stand-down by the person who raised it (Scenario 8), and the case's status, outcome, resolution note, who closed it and when, which only an admin action sets

**Scenario 8 — The person who raised it can stand the alert down as a false alarm**
- Given an open case
- When the person who raised the SOS cancels the alert as a false alarm from her emergency screen
- Then the case's live location link is revoked immediately (#3971)
- And the case records that she stood it down as a false alarm, and when
- And the case stays open until an admin closes it; standing down never closes a case
- And a stand-down from anyone other than the person who raised it, or on a case that is already closed, is refused and changes nothing

**Scenario 9 — The trip is unaffected**
- Given a case has been created
- When the trip runs on to completion
- Then it settles and is rated exactly as it would have without an SOS

**Scenario 10 — Nobody is suspended automatically**
- Given a case has been created
- When no admin has yet actioned it
- Then no account is suspended as an automatic consequence of the case existing

**Scenario 11 — An admin can retrieve the case**
- Given a case exists
- When a signed-in admin opens it
- Then the full case, including the whole snapshot, is returned

**Scenario 12 — Requests without a valid session are refused**
- Given a request to create or read a case
- When it arrives without a valid session
- Then it is refused and no case detail is returned

### Out of Scope
- Any admin action on the case — suspending someone, or closing it as resolved or a false alarm (see #3946)
- Live, continuously updating location tracking for the admin — the case holds a snapshot at the trigger, not a live feed
- Real-time alerting in the portal (sound, popup)
- Sending contacts an "all clear" message after a stand-down
- Automatic account suspension on any pattern

### Dependencies
- Consumed by #3968 (rider emergency screen) and #3969 (driver emergency screen)
- Feeds #3945 (SOS queue) and #3946 (SOS case detail)
- #1780 and #1952 supply the contact-alert results recorded in Scenario 6

---

## [API] #3971 — Live location link is issued, scoped, and expires 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the SheDrive platform, I want to issue one narrowly scoped live location link per SOS case and enforce its expiry and revocation, so that the people she trusts can find her without her location being exposed indefinitely or to anyone else.

### Background

Each SOS case gets exactly one live location link. The link is deliberately narrow: it shows only where she is and the trip it belongs to, nothing else about her account. It does not last forever — it covers the walk from the car to safety and then stops, and she can shut it off herself at any moment.

### Acceptance Criteria

**Scenario 1 — One link per case**
- Given an SOS has been confirmed
- When the case is created
- Then exactly one live location link is issued for it
- And the link cannot be guessed from another one

**Scenario 2 — The link shows her location and the trip, and nothing else**
- Given a valid live location link
- When a contact opens it
- Then it shows where she is now and the details of that trip
- And it exposes nothing else about her account

**Scenario 3 — The link expires 60 minutes after the trip ends**
- Given a case's live location link was issued during a trip
- When the trip ends
- Then the link keeps working for 60 more minutes and then stops working on its own

**Scenario 4 — She can revoke it early**
- Given a case has an active live location link
- When the person who raised the SOS stops sharing, or stands the alert down as a false alarm, from her emergency screen
- Then the link stops working immediately, however much of the 60 minutes was left

**Scenario 5 — A revoked or expired link shows nothing**
- Given a live location link has been revoked or has expired
- When anyone opens it
- Then no location and no trip detail is shown

**Scenario 6 — Invalid links are refused**
- Given a link that does not correspond to any case, or is malformed
- When anyone opens it
- Then it is refused and no location data is returned

### Out of Scope
- Live, continuously updating location tracking for the admin — the case detail shows a snapshot at the trigger, not this link
- Issuing more than one live link per case
- Sharing anything about her account beyond her live location and the trip

### Dependencies
- #3970 — a case must exist before its link can be issued
- Consumed by #3968 (rider emergency screen) and #3969 (driver emergency screen)
- #1780 and #1952 — the link is what the alerted contacts receive

---
