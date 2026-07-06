# SheDrive — API Stories
> Canonical backlog for all [API] stories. Organized by sprint and feature.
> Last updated: 2026-06-22
> Stories with changes from original are marked ✏️ | New stories marked 🆕

---

## Sprint 1

### Feature 4 — Authentication API (Shared — Rider & Driver)

---

## [API] #1620 — User requests OTP via SMS ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want the OTP request endpoint to validate Egyptian mobile numbers and dispatch 6-digit OTP codes via SMS so that all rider and driver registration and login flows can begin reliably across all four Egyptian carrier prefixes.

**Scenario 1 — Valid phone number triggers OTP dispatch**
- Given a valid Egyptian mobile number (01[0125]XXXXXXXX) is submitted to the endpoint
- When the endpoint processes the request
- Then a 6-digit OTP is generated, stored with a 5-minute expiry, and dispatched via SMS (#1616)
- And a success response is returned without disclosing the phone’s registration status
- And the wrong-attempt counter for that OTP is initialised to 0

**Scenario 2 — +20 country prefix is stripped before validation**
- Given a phone number submitted with the +20 prefix (e.g. +201012345678)
- When the endpoint processes the request
- Then the prefix is stripped, the resulting 11-digit number is validated, and the OTP is dispatched if valid

**Scenario 3 — Invalid phone number format is rejected**
- Given a phone number that does not match 01[0125]XXXXXXXX after prefix stripping (e.g. starts with 013, 019, or has fewer/more than 11 digits)
- When the endpoint processes the request
- Then a validation error is returned: phone must be a valid Egyptian mobile number
- And no OTP is generated or dispatched
- And the SMS gateway is never called

**Scenario 4 — Empty or missing phone field is rejected**
- Given a request body with a missing or empty phone field
- When the endpoint processes the request
- Then a validation error is returned: phone is required
- And no OTP is generated

**Scenario 5 — Rate limiting enforces 60-second resend cooldown**
- Given a phone number has already received an OTP within the last 60 seconds
- When another OTP request is made for the same number before the cooldown expires
- Then the endpoint rejects the request with a rate-limit error
- And the response indicates the remaining cooldown time in seconds
- And no new OTP is generated or dispatched

**Scenario 6 — Resend after cooldown issues fresh OTP and resets wrong-attempt counter**
- Given a phone number’s last OTP was dispatched more than 60 seconds ago
- When a new OTP request is made for the same number
- Then a new 6-digit OTP is generated with a fresh 5-minute expiry
- And the previous OTP (if still unexpired) is invalidated and can no longer be submitted
- And the wrong-attempt counter for the new OTP is reset to 0
- And the new OTP is dispatched via SMS

**Scenario 7 — SMS gateway delivery failure is logged and surfaced**
- Given the SMS gateway (#1616) returns a delivery failure for any reason
- When the endpoint processes the failure
- Then the failure is logged internally with the gateway error code
- And a service-unavailable error is returned so the mobile app can prompt the user to retry
- And the generated OTP record is discarded

**Scenario 8 — All four Egyptian carrier prefixes are accepted**
- Given a valid mobile number starting with 010, 011, 012, or 015
- When the endpoint processes the request
- Then the number is accepted and the OTP is dispatched without error

---

## [API] #1621 — User registers with OTP verification ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want the registration endpoint to verify the submitted OTP and create a new user account so that riders and drivers can register securely without a password, receiving a session token and their role on success so the mobile app can route each user type to the correct starting screen.

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

## [API] #1747 — Platform selects fastest traffic-aware route for fare estimation 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the SheDrive platform, I want to query Google Maps for route alternatives with live traffic and select the fastest route so that fare estimates and ETAs are based on the most realistic path a driver would actually take.

### Background ( Fastest Route )

When a rider submits a pickup and destination, the platform queries the Google Maps **Directions API** with alternatives=true and departure_time=now. This returns up to 3 candidate routes, each carrying a distance (metres), a base duration (seconds), and a traffic-adjusted duration_in_traffic (seconds). The platform selects the route with the **lowest duration_in_traffic** ( Fastest Route ) and extracts two values from it: distance in km and duration_in_traffic in minutes. These two values are passed to the fare calculation module (#1628) and also returned to the client as the estimated route data. The other candidate routes are discarded. If Google Maps returns only one route, that route is used without comparison.

**Scenario 1 — Multiple routes returned: fastest in traffic is selected**
- Given Google Maps returns 2 or more route alternatives for a valid pickup and destination
- When the platform processes the response
- Then the route with the lowest duration_in_traffic is selected
- And the other candidate routes are discarded
- And the selected route’s distance (km) and duration_in_traffic (minutes) are passed to #1628

**Scenario 2 — Single route returned: that route is used**
- Given Google Maps returns exactly one route for a valid pickup and destination
- When the platform processes the response
- Then that route is selected without comparison
- And its distance and duration_in_traffic are passed to #1628

**Scenario 3 — Live traffic is always factored in**
- Given the platform queries Google Maps for any fare estimation request
- When the API call is constructed
- Then departure_time=now is always included in the request
- And duration_in_traffic is always used for the duration value (never the base duration)

**Scenario 4 — Two routes with equal duration_in_traffic: shorter distance wins**
- Given Google Maps returns two routes with identical duration_in_traffic
- When the platform selects a route
- Then the route with the shorter distance is chosen as a tiebreaker

**Scenario 5 — Google Maps returns no valid routes**
- Given Google Maps returns a response with zero valid routes (e.g., ZERO_RESULTS)
- When the platform processes the response
- Then the error is logged internally
- And a service-unavailable response is returned so the client can inform the rider to check her pickup and destination

**Scenario 6 — Rider sees estimate, not a locked fare**
- Given the platform has calculated a fare estimate from the selected route
- When the response is returned to the rider app
- Then the fare is labelled as an estimate in the response payload
- And the final fare at trip completion is calculated from actual GPS data (#1636), not this estimate

### Out of Scope
- Showing the rider the route on a map (separate mobile story)
- Real-time rerouting during an active trip
- Selecting a route based on driver preference or history
- Surge pricing or dynamic rate adjustments

### Dependencies
- #1617 — Google Maps returns route distance and duration (integration must be live)
- #1628 — Fare applies base, per-km, and per-minute rates (consumes this story’s output)

---

## [API] #1627 — Fare estimate uses Google Maps route data
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As a developer, I want the fare estimate endpoint to call Google Maps Distance Matrix for route data and apply the configured rate formula so that the rider sees an informed price and trip duration before confirming the booking, and the CTA on the home screen activates only after a successful estimate.

**Scenario 1 — Valid pickup and destination return fare, distance, and duration**
- Given an authenticated rider sends valid and distinct pickup and destination coordinates or place IDs
- When the Google Distance Matrix API returns a distance and duration
- Then #1628 calculates the fare from those values
- And the endpoint returns the estimated fare number, distance in km, and duration in minutes
- And the mobile app uses this to activate the "Request Ride" button

**Scenario 2 — Missing pickup field returns validation error**
- Given the request is missing the pickup field
- When the endpoint processes the request
- Then a validation error is returned: pickup location is required
- And the mobile app keeps the "Request Ride" button inactive

**Scenario 3 — Missing destination field returns validation error**
- Given the request is missing the destination field
- When the endpoint processes the request
- Then a validation error is returned: destination is required



**Scenario 4 — Google Distance Matrix error is surfaced as upstream failure**
- Given the Google Distance Matrix API is unavailable or returns an error
- When the endpoint attempts the upstream call
- Then an upstream-failure error is returned
- And the mobile app shows a retry option and keeps the "Request Ride" button inactive



**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives with no session token or an invalid/expired token
- Then the request is rejected by #1619 auth middleware

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

**Description:** As a developer, I want the onboarding submission endpoint to accept the driver's complete application payload — personal details, vehicle details, background-check consent, four document files, vehicle photo, and profile photo — and create a pending application record so that the admin can review and approve or reject the driver before she can go online.

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

**Scenario 3 — Personal details validation — driver must be at least 21 years old**
- Given the driver submits a date of birth that makes her younger than 21 years old at the time of submission
- When the endpoint processes the request
- Then a validation error is returned: driver must be at least 21 years old

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



### Dependencies
- #1618 — Push notification service
- #1645 — Driver sets availability status (the gate protects this)
- #1643 — Driver queries onboarding status (fallback when push is missed)

---

### Feature 6 — Driver Home & Availability API

---

## [API] #1645 — Driver sets availability status
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a developer, I want the availability status endpoint to let an approved driver toggle between online and offline so that the platform knows whether to dispatch trip requests to her, with the status change confirmed server-side before the mobile UI reflects it.

**Scenario 1 — Approved driver goes online successfully**
- Given an authenticated driver with application status = approved
- When she sends status = "online"
- Then the server updates her availability to online
- And returns a success response with the new status
- And the mobile app changes the toggle to the online state only after receiving this confirmation
- And GPS location streaming begins (#1646)

**Scenario 2 — Driver goes offline successfully**
- Given an authenticated driver who is currently online
- When she sends status = "offline"
- Then the server updates her availability to offline
- And returns a success response with the new status
- And the mobile app changes the toggle to offline only after receiving the confirmation
- And GPS location streaming stops

**Scenario 3 — Non-approved driver attempting to go online is rejected**
- Given an authenticated driver whose application status is pending or rejected
- When she sends status = "online"
- Then the server returns a forbidden error per #1644
- And the mobile toggle reverts to its previous offline state

**Scenario 4 — GPS permission denied prevents going online on the mobile side**
- Given the driver's device has not granted GPS permission
- When she attempts to go online
- Then the mobile app does not call this endpoint
- And the toggle remains in the offline state
- And the app prompts the driver to grant GPS permission in device settings

**Scenario 5 — Network error during status change reverts toggle**
- Given the driver taps the availability toggle
- When the network request to this endpoint fails
- Then an error is surfaced to the mobile app
- And the toggle reverts to its previous state
- And the driver's server-side availability is not changed

**Scenario 6 — Invalid status value is rejected**
- Given an authenticated driver submits a status value other than "online" or "offline"
- Then the server returns a validation error listing accepted values

**Scenario 7 — Unauthenticated request is rejected**
- Given a request arrives without a valid session token
- Then the request is rejected

**Scenario 8 — Driver goes offline while in an active trip**
- Given an authenticated driver who is currently assigned to an active trip
- When she sends status = "offline"
- Then the server reject the request
- And the driver remains assigned to the current trip until it is completed

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

## [API] #1630 — Driver-matching engine (nearest-driver dispatch + reassignment on reject/timeout)
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically match a trip request to the nearest available driver and, when she rejects or times out, reassign it to the next nearest driver, so that the rider is connected as quickly as possible and no request is abandoned silently.

### Background

This is the internal matching/dispatch engine, triggered immediately after a trip request is created (#1629). It is not called directly by any client app.

**Candidate pool.** For each searching trip the engine builds a candidate pool: drivers who are online, approved, and not currently assigned to a trip, whose estimated driving time (ETA) to the pickup point is 15 minutes or less. Candidates are ranked ascending by ETA (shortest first) and the pool is capped at the 20 lowest-ETA drivers. ETA is computed once at pool construction and is not recomputed mid-search.

**Dispatch loop.** The engine walks the ranked list from the top, dispatching the trip to one driver at a time via #1648 with a 10-second acceptance window. On rejection (#1650) or expiry of that window, the engine advances to the next driver in the list. There is no separate "tried" list — the engine simply moves down the ranked list in order; a driver who rejects or times out is passed over and stays online and eligible for other trips.

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

**Scenario 2 — Nearest-by-ETA driver is dispatched first**
- Given a candidate pool exists
- When the engine begins dispatching
- Then the trip is dispatched to the driver at the top of the ranked list (#1648) with a 10-second acceptance window

**Scenario 3 — Each attempted driver is published to the rider's app**
- Given the engine dispatches the trip to a driver
- Then the driver currently being attempted is made available to the rider app (via #1631) and can be shown on the matching screen (#1554)
- And when the engine moves to the next driver, the updated driver-being-attempted is published

**Scenario 4 — Driver rejects — engine advances to the next driver**
- Given the dispatched driver rejects the trip (#1650)
- Then the engine immediately dispatches to the next driver in the ranked list (#1648)

**Scenario 5 — Acceptance window elapses — engine advances to the next driver**
- Given the 10-second acceptance window elapses with no Accept or Reject
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

### Out of Scope
- Driver preference filters (gender, vehicle type)
- Surge pricing
- Batch matching for multiple simultaneous requests
- SOS trip prioritization
- Real-time ETA recomputation mid-search (ETA is computed once at pool construction)
- Any time-based trip expiry or stuck-trip watchdog (expiry is purely list-driven)

### Dependencies
- #1629 — Rider creates trip request (triggers the engine)
- #1645 — Driver online status and location tracking — supplies driver location/ETA inputs (must be live)
- #1648 — Driver retrieves pending trip request / dispatch to driver (must be live)
- #1649 — Driver accepts trip — assignment removes her from all other pools (must be live)
- #1650 — Driver rejects trip (must be live)
- #1631 — Rider polls for match status — surfaces the driver being attempted and the expired result

---

## [API] #1764 — Cancellation fees are charged after grace period (rider and driver) 🆕
**Feature:** Feature 8 — Trip Request & Matching API | **Sprint:** 2

**Description:** As the trip service, I want to apply the correct cancellation fee when either a rider or a driver cancels after the applicable grace period so that drivers are compensated for a rider's late cancellation, drivers are held accountable for their own late cancellations, and genuine rider no-shows are not penalised.

### Background

**Rider cancellation fee.** The fee is the fixed EGP amount set in the zone's rate card (#1757). The rider grace period is the global setting configured by the super admin (#1759). The clock starts when the driver accepts the trip. If the rider cancels before the grace period expires, no fee is charged. If she cancels after, the fee is charged to the rider and split between the driver and the platform using the configured driver share percentage.

**Driver cancellation fee.** A fixed EGP amount (#1759) is charged to a driver who cancels an accepted trip after the driver cancellation grace period (#1759, measured from driver acceptance). A driver who cancels within the grace period is not charged. The fee is waived only when the cancellation reason is rider no-show and the driver had marked arrived at the pickup and waited at least the configured rider no-show wait time (#1759). In every other late driver cancellation the fee applies.

Every cancellation records who cancelled and the cancellation reason (captured by #1720). The fee, grace period, split, and wait-time values used are those active at the time of driver acceptance — not at the time of cancellation.

**Scenario 1 — Rider cancels within grace period**
- Given a driver has accepted and the rider grace period has not yet expired
- When the rider cancels
- Then no cancellation fee is charged
- And the trip record is marked: cancelled_by=rider, fee_charged=false

**Scenario 2 — Rider cancels after grace period expires**
- Given a driver has accepted and the rider grace period has expired
- When the rider cancels
- Then the cancellation fee for that zone is charged to the rider
- And the fee is split using the driver share percentage active at driver acceptance time
- And the trip record is marked: cancelled_by=rider, fee_charged=true, fee_amount, driver_share_amount, platform_share_amount

**Scenario 3 — Driver cancels within the driver grace period — no fee**
- Given a driver cancels within the driver cancellation grace period after accepting
- Then no driver cancellation fee is charged
- And the trip record is marked: cancelled_by=driver, cancellation_reason, fee_charged=false

**Scenario 4 — Driver cancels after the driver grace period — fee charged**
- Given a driver cancels after the driver cancellation grace period for a reason other than a qualifying rider no-show
- Then the driver cancellation fee is charged to the driver
- And the trip record is marked: cancelled_by=driver, cancellation_reason, fee_charged=true, driver_fee_amount

**Scenario 5 — Driver cancels a rider no-show after the wait time — fee waived**
- Given the driver has marked arrived at the pickup and waited at least the rider no-show wait time
- When the driver cancels with reason rider no-show
- Then no driver cancellation fee is charged
- And the trip record is marked: cancelled_by=driver, cancellation_reason=rider_no_show, no_show=true, fee_charged=false

**Scenario 6 — Driver claims a no-show before the wait time — fee charged**
- Given the driver cancels with reason rider no-show but has not marked arrived or has waited less than the rider no-show wait time
- Then the no-show waiver does not apply and the driver cancellation fee is charged

**Scenario 7 — Policy changes during an active trip**
- Given any grace period, fee, split, or wait-time value is updated by an admin after a driver has accepted
- Then the trip uses the values that were active at the time of driver acceptance

**Scenario 8 — Cancellation before driver acceptance**
- Given a cancellation occurs while the trip is still in the matching phase (no driver accepted yet)
- Then no cancellation fee is charged to either party regardless of elapsed time

### Out of Scope
- Rider compensation when a driver cancels (Phase 2)
- Rider or driver dispute flow for cancellation fees (Phase 2)
- Payout/deduction mechanics from the driver's wallet or earnings balance

### Dependencies
- #1757 — Super admin configures zone rate card (rider cancellation fee amount)
- #1759 — Super admin configures global pricing policies (grace periods, split, driver fee, no-show wait time)
- #1720 — Driver cancels an accepted trip (captures cancellation reason and no-show status)

---

### Feature 9 — Driver Trip Acceptance API

---

## [API] #1649 — Driver accepts trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a developer, I want the trip acceptance endpoint to confirm the driver's acceptance within the 10-second window so that the trip status advances to accepted, the rider is notified, and the driver is directed to the active trip flow.

**Scenario 1 — Successful acceptance within window**
- Given the driver taps Accept and the request reaches the server within the 10-second window
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
- Given the 10-second acceptance window has already elapsed
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

---

## [API] #1650 — Driver rejects trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a developer, I want the trip rejection endpoint to record the driver's rejection within the acceptance window so that the trip is returned to the platform for reassignment and the driver's availability is immediately restored.

**Scenario 1 — Successful rejection within window**
- Given the driver taps Reject and the request reaches the server within the 10-second window
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

## [API] #1633 — Rider retrieves live trip state and driver location
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a developer, I want the active trip state endpoint to return the current trip state and the driver's live GPS coordinates so that the rider app can keep the trip state and the driver's position on the map up to date throughout the en_route_pickup, arrived_pickup, trip_started, and trip_ended phases.

**Scenario 1 — Trip in en_route_pickup — state and driver location returned**
- Given the rider's trip is in en_route_pickup state
- When the rider app polls this endpoint
- Then the response includes the current trip state and the driver's latest latitude and longitude
- And the rider app updates the driver's dot on the map

**Scenario 2 — Trip advances to arrived_pickup — screen transitions automatically**
- Given the driver has tapped "I've Arrived" and the trip state is arrived_pickup
- When the rider app polls this endpoint
- Then the response returns state = "arrived_pickup"
- And the rider app automatically transitions the active trip screen to the arrived state without requiring any rider action

**Scenario 3 — arrived_at timestamp included when driver has arrived**
- Given the trip is in arrived_pickup state
- When the rider app polls this endpoint
- Then the response includes an arrived_at field containing the timestamp of when the state transitioned to arrived_pickup
- And the rider app uses this timestamp to compute the correct elapsed waiting time
- And if the rider app is restarted while the driver is waiting, the counter resumes from the correct elapsed time rather than resetting to 0:00

**Scenario 4 — Trip in trip_started — driver location continues updating**
- Given the trip state is trip_started
- When the rider app polls this endpoint
- Then the response returns state = "trip_started" with the driver's latest coordinates
- And the rider app shows the driver's dot moving toward the destination

**Scenario 5 — Trip transitions to trip_ended — rider screen transitions to summary**
- Given the driver has tapped "End Trip" and the state is trip_ended
- When the rider app polls this endpoint
- Then the response returns state = "trip_ended"
- And the rider app automatically navigates to the trip summary screen

**Scenario 6 — Driver coordinates refresh within 5 seconds**
- Given the driver is streaming GPS updates via #1646 every 5 seconds
- When the rider app polls this endpoint
- Then the driver coordinates in the response reflect the most recent GPS update
- And the position age does not exceed 5 seconds from the last driver update

**Scenario 7 — Trip not found or not belonging to this rider**
- Given the rider polls with a trip ID that does not exist or does not belong to her account
- Then the server returns a not-found or forbidden response

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

### Dependencies
- #1652 — Driver advances trip state machine (drives the active-trip state transitions)
- #1646 — Driver updates GPS location (supplies the live driver coordinates)
- #1653 — Driver streams GPS from acceptance to completion (continuous coordinates through every trip phase)

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

**Description:** As the trip-completion service, I want to calculate the final fare from the actual route and duration and deduct the platform commission when the driver ends the trip, so that the rider and driver see the same fare while driver net earnings and platform revenue are recorded accurately.

### Background

When the driver advances the trip to *trip_ended* (#1652), the platform finalizes the fare and settles the trip. The final fare is computed by the fare-calculation engine (#1628) from the actual trip distance and duration, then the platform commission is deducted and the driver's net earnings are recorded. The same fare figure is shown to both rider (trip summary) and driver (cash collection). Commission is a single global percentage (configured via #1759); the rate snapshot taken at acceptance time applies, not the rate at completion. Gross fare, commission amount, and driver net earnings are stored on the trip record. The rider never sees commission — she sees the total only; the driver sees her net earnings.

### Acceptance Criteria

**Scenario 1 — Final fare calculated on trip end**
- Given the driver advances the trip to trip_ended via #1652
- When the platform processes the state change
- Then the final fare is calculated immediately by the fare engine (#1628) from the actual distance and duration and stored on the trip record

**Scenario 2 — Fare is consistent between rider and driver**
- Given the final fare has been calculated
- When the rider retrieves the trip summary and the driver views the cash collection screen
- Then both receive exactly the same fare amount

**Scenario 3 — Fare is immutable after calculation**
- Given the fare has been calculated and stored
- When any later request attempts to recalculate or overwrite it
- Then the server rejects the modification and returns the stored fare

**Scenario 4 — Driver cash collection shows the correct amount**
- Given the trip is trip_ended and the fare is calculated
- Then the amount on the driver's cash collection screen matches the stored fare

**Scenario 5 — Fare never falls below the floor**
- Given a trip with zero or near-zero distance and duration
- Then the fare is at least the minimum fare (per #1628) and never zero or negative

**Scenario 6 — Commission calculated and stored on completion**
- Given a trip completes with total fare 100 EGP and commission rate 20%
- Then the trip record stores total_fare=100, commission_rate=20, commission_amount=20, driver_net_earnings=80

**Scenario 7 — Commission rate snapshot taken at acceptance time**
- Given the commission rate is 20% when the driver accepts the trip
- And the super admin changes it to 25% before completion
- When the trip completes
- Then commission is calculated at 20% (the rate at acceptance)

**Scenario 8 — Commission is not shown to the rider**
- Given a completed trip
- When the rider views her receipt
- Then she sees only the total fare — no commission breakdown

**Scenario 9 — Commission is not deducted from a cancellation fee**
- Given a trip cancelled with a fee charged
- Then commission is NOT deducted from the cancellation fee — the driver receives her full configured share

**Scenario 10 — Unauthenticated request is rejected**
- Given a request without a valid session token
- Then it is rejected

**Rider trip-summary fare breakdown — merged from #1637**

**Scenario 11 — Total fare and three line items returned**
- Given a trip is in trip_ended state with a calculated fare
- When the rider app calls the completed-trip endpoint
- Then the response includes the total fare in EGP
- And three fare line items are included: base fee, distance charge (per-km), and time charge (per-minute)
- And the three line items sum to the total fare

**Scenario 12 — Full trip metadata included**
- Given the trip is complete and the rider requests the summary
- Then the response includes: total distance (km), trip duration (minutes), pickup address, destination address, driver full name, and vehicle make, model, color, and plate number

**Scenario 13 — Previously submitted rating is included**
- Given the rider has submitted a star rating for this trip
- Then the star value (1–5) and any selected tags are included in the response

**Scenario 14 — No rating submitted — rating field is absent or null**
- Given the rider has not submitted a rating (skipped or not yet rated)
- Then the rating field is null or absent and the rider app shows a placeholder

**Scenario 15 — Trip not found or not belonging to this rider**
- Given the rider requests a trip ID that does not exist or does not belong to her account
- Then the server returns a not-found or forbidden response

**Scenario 16 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

**Driver cash-collection fare read — merged from #1717**

**Scenario 17 — Driver retrieves fare for a completed trip**
- Given an authenticated driver has a trip in trip_ended state
- When she calls the driver fare endpoint
- Then the response includes the final fare amount in EGP exactly as stored on the trip record, with no recalculation at retrieval time
- And the amount populates the cash collection screen

**Scenario 18 — Driver confirms fare collected and returns to available**
- Given the driver has viewed the cash collection screen and taps "Done"
- When the confirmation is submitted
- Then the driver's availability status is reset to "available"
- And the driver is ready to receive the next trip request

**Scenario 19 — Trip is not in trip_ended state**
- Given the driver calls the fare endpoint for a trip that has not reached trip_ended
- Then a conflict or not-ready error is returned and no fare data is returned

**Scenario 20 — Trip not found or belongs to a different driver**
- Given the driver requests a trip ID that does not exist or belongs to a different driver
- Then a not-found or forbidden error is returned

### Out of Scope
- Payout disbursement to drivers (wallet/bank integration)
- Commission reporting dashboard (separate admin story)
- Trip-completion push notification (not included in this story)
- Receipt generation for the driver
- Fare dispute workflow

### Dependencies
- #1628 — Fare calculation engine (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1759 — Super admin configures platform commission (must be live)
- #1645 — Driver sets availability status (must be live)

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
- #1687 — Rider account is suspended after gender mismatch report

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

### Feature 21 — Emergency & Safety API

---

## [API] #1687 — Rider account is suspended after gender mismatch report 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As a developer, I want the gender mismatch report endpoint to cancel the active trip and flag the rider's account for admin review so that SheDrive's women-only service guarantee is enforced and the incident is investigated before the rider can book another trip.

**Scenario 1 — Gender mismatch report submitted — trip cancelled and rider flagged**
- Given the driver has tapped "Cancel — Rider Not Female" and confirmed the dialog
- When the driver app calls this endpoint
- Then the active trip is cancelled immediately
- And the rider's account is flagged for admin review
- And the driver is returned to her home screen in the online/available state

**Scenario 2 — No fare charged on gender mismatch cancellation**
- Given a trip is cancelled via this endpoint
- When the platform processes the cancellation
- Then no fare is calculated or stored for the cancelled trip
- And the rider's app shows a cancelled state rather than a trip summary

**Scenario 3 — Driver's availability is restored after cancellation**
- Given the gender mismatch report has been processed
- When the driver is returned to her home screen
- Then her online status is preserved
- And she is eligible to receive the next dispatched trip without re-toggling availability

**Scenario 4 — Flagged rider cannot request a new trip until admin clears the flag**
- Given the rider's account has been flagged via this endpoint
- When she attempts to submit a new trip request via #1629
- Then the server returns a forbidden error: account is under review
- And the rider app shows a message indicating the account is suspended pending review

**Scenario 5 — Verification step is only shown for first-trip riders**
- Given is_first_trip = false for the trip
- When the driver is in arrived_pickup state
- Then this endpoint is not applicable and the "Cancel — Rider Not Female" button is not shown
- And no verification or mismatch report flow exists for returning riders

**Scenario 6 — Report only valid while trip is in arrived_pickup state**
- Given the trip is in any state other than arrived_pickup
- When the driver attempts to call this endpoint
- Then the server returns a validation error: mismatch report can only be submitted at pickup verification

**Scenario 7 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

---

## [API] #1780 — Rider's emergency contacts are notified with a live location link on SOS 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the rider app, I want to store a rider's emergency contacts and, when she triggers SOS during an active trip, notify those contacts with a live trip-tracking link so that the people she trusts can follow her location in real time during an emergency.

**Scenario 1 — Manage emergency contacts**
- Given an authenticated rider
- When she creates, updates, retrieves, or deletes an emergency contact (name, phone, relationship)
- Then the change is persisted and returned on subsequent reads

**Scenario 2 — Contacts notified with a live link on SOS**
- Given the rider has one or more emergency contacts and an active trip
- When she triggers SOS
- Then each contact is sent an alert containing a live trip-tracking link to her current location

**Scenario 3 — Live link reflects location for the trip duration**
- Given an SOS alert has been sent
- When a contact opens the live link
- Then it shows the rider's location, updating for the duration of the trip / emergency

**Scenario 4 — Only the rider's own contacts are notified**
- Given an SOS is triggered
- Then only the rider's saved emergency contacts are notified; no control room, operations team, or Ministry of Interior is contacted

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider session token
- Then the request is rejected

**Dependencies:** Consumed by [Mobile] #1787 (rider) and #1951 (driver).

---

## [API] #1952 — Driver's emergency contacts are notified with a live location link on SOS 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the driver app, I want to store a driver's emergency contacts and, when she triggers SOS during an active trip, notify those contacts with a live trip-tracking link so that the people she trusts can follow her location in real time during an emergency.

**Scenario 1 — Manage emergency contacts**
- Given an authenticated driver
- When she creates, updates, retrieves, or deletes an emergency contact (name, phone, relationship)
- Then the change is persisted and returned on subsequent reads

**Scenario 2 — Contacts notified with a live link on SOS**
- Given the driver has one or more emergency contacts and an active trip
- When she triggers SOS
- Then each contact is sent an alert containing a live trip-tracking link to her current location

**Scenario 3 — Live link reflects location for the trip duration**
- Given an SOS alert has been sent
- When a contact opens the live link
- Then it shows the driver's location, updating for the duration of the trip / emergency

**Scenario 4 — Only the driver's own contacts are notified**
- Given an SOS is triggered
- Then only the driver's saved emergency contacts are notified; no control room, operations team, or Ministry of Interior is contacted

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid driver session token
- Then the request is rejected

**Dependencies:** Consumed by [Mobile] #1951 (driver).

---

