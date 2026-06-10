# SheDrive — API Stories
> Canonical backlog for all [API] stories. Organized by sprint and feature.
> Last updated: 2026-06-10
> Stories with changes from original are marked ✏️ | New stories marked 🆕

---

## Sprint 1

### Feature 4 — Authentication API (Shared — Rider & Driver)

---

## [API] #1744 — Auth middleware validates session tokens 🆕
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want all protected endpoints to validate the session token in the Authorization header so that only authenticated users with valid, non-expired, non-revoked tokens can access protected resources.

### Background
Every request to a protected endpoint passes through the auth middleware. The middleware extracts the Bearer token from the Authorization header, verifies its cryptographic signature, confirms it has not passed its 30-day absolute lifetime, and checks it has not been revoked via the session store (e.g. after logout via #1624). If any check fails the middleware returns 401 Unauthorized immediately without executing the downstream handler. If all checks pass the authenticated user's identity (user ID, phone, and role) is attached to the request context for downstream use.

### Scenario 1 — Valid unexpired non-revoked token grants access
- Given a request carries a well-formed Bearer token within its 30-day lifetime that has not been revoked
- When the middleware processes the request
- Then the request proceeds to the downstream handler
- And the user's ID, phone, and role are available in the request context

### Scenario 2 — Expired token is rejected with 401
- Given a token whose issuance timestamp is more than 30 days ago
- When the middleware validates the token
- Then 401 Unauthorized is returned
- And the response body indicates the session has expired
- And the downstream handler is not executed

### Scenario 3 — Revoked token is rejected with 401
- Given a token that was invalidated via the logout endpoint (#1624)
- When the middleware validates the token
- Then 401 Unauthorized is returned
- And the response body indicates the session is no longer valid

### Scenario 4 — Missing Authorization header returns 401
- Given a request to a protected endpoint with no Authorization header
- When the middleware processes the request
- Then 401 Unauthorized is returned before the handler executes

### Scenario 5 — Malformed or tampered token returns 401
- Given a request carries a token with an invalid signature, wrong format, or modified payload
- When the middleware validates the token
- Then 401 Unauthorized is returned
- And no details about why the token failed are leaked in the response

### Scenario 6 — Token lifetime is 30 days from issuance
- Given a token was issued at time T
- When a request is made at T + 30 days or later
- Then the token is expired and the request is rejected with 401
- And a token used before T + 30 days is accepted

### Scenario 7 — Token payload is accessible to downstream handlers
- Given the middleware successfully validates a token
- When the downstream handler processes the request
- Then the user's ID, phone number, and role (rider or driver) are accessible from the request context without re-parsing the token

### Out of Scope
- Token refresh or silent renewal
- Multi-device session management
- Per-endpoint role-based access control

### Dependencies
- #1621 — User registers with OTP verification (token issuer)
- #1622 — User logs in with OTP verification (token issuer)
- #1624 — User session is invalidated on logout (revocation source)

---

## [API] #1620 — User requests OTP via SMS ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an unauthenticated endpoint with a phone number so that a 6-digit OTP is sent to that number via SMS.

### Background
This is an unauthenticated public endpoint called as the first step of both registration and login flows. It accepts an Egyptian mobile number, validates the format, generates a 6-digit OTP, stores it with a 5-minute expiry, and dispatches it via the SMS gateway (#1616). Rate limiting is applied per phone number to prevent OTP spam.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits (after stripping) | 11 digits (after stripping) | Digits only (after stripping) | Return validation error: phone is required | Return validation error: must be a valid Egyptian mobile number | Return validation error: must be exactly 11 digits |

### Acceptance Criteria

**Scenario 1 — Valid phone number triggers OTP dispatch**
- Given a valid Egyptian mobile number is submitted
- When the endpoint processes the request
- Then a 6-digit OTP is generated, stored with a 5-minute expiry, and dispatched via SMS (#1616)
- And a success response is returned (the phone's registration status is not disclosed)
- And the wrong-attempt counter for that OTP is initialised to 0

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

**Scenario 6 — Resend after cooldown issues fresh OTP and resets wrong-attempt counter**
- Given a phone number's last OTP was dispatched more than 60 seconds ago
- When a new OTP request is made for the same number
- Then a new 6-digit OTP is generated with a fresh 5-minute expiry
- And the previous OTP (if still unexpired) is invalidated and can no longer be submitted
- And the wrong-attempt counter for the new OTP is reset to 0
- And the new OTP is dispatched via SMS

### Out of Scope
- WhatsApp or email OTP delivery
- Disclosing whether the phone number is registered
- SOS/emergency features

### Dependencies
- #1616 — SMS gateway delivers OTP to Egyptian mobile numbers (must be live)

---

## [API] #1621 — User registers with OTP verification ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As a developer, I want the registration endpoint to verify the submitted OTP and create a new user account so that riders and drivers can register securely without a password, receiving a session token and their role on success so the mobile app can route each user type to the correct starting screen.

### Background
This unauthenticated endpoint is called after the user has received her OTP via #1620. It accepts the phone number, the 6-digit OTP, and the user's full name. The endpoint verifies that the OTP matches, is not expired, and has not been exhausted by too many wrong attempts. If all checks pass, a new user account is created and a session token plus the user's role are returned. If the phone number is already registered, the user is auto logged in rather than receiving a conflict error — a session token for the existing account is returned.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile; +20 prefix stripped | 11 digits | 11 digits | Digits only | Return validation error: phone is required | Return validation error: invalid Egyptian mobile format | Return validation error: must be 11 digits |
| otp | Yes | 6-digit numeric string | 6 chars | 6 chars | Digits only | Return validation error: OTP is required | Return validation error: OTP must be 6 digits | Return validation error: OTP must be 6 digits |
| name | Yes | Arabic and/or Latin letters and spaces only | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | Return validation error: name is required | Return validation error: name may only contain letters and spaces | Return validation error: name must be between 2 and 50 characters |

### Acceptance Criteria

**Scenario 1 — Successful registration creates account and returns session token**
- Given a valid phone, a correct and unexpired OTP, and a valid full name are submitted
- When the endpoint processes the request
- Then a new user account is created with the provided phone and name
- And a session token is returned that is accepted by #1744
- And the response includes the user's role (rider or driver)
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
- Then a validation error is returned indicating the OTP has expired
- And no account is created

**Scenario 4 — Wrong OTP increments attempt counter**
- Given a valid phone and an incorrect OTP are submitted
- When the endpoint processes the request
- Then a validation error is returned indicating the OTP is incorrect
- And the wrong-attempt counter for that OTP is incremented by 1

**Scenario 5 — OTP exhausted after 3 wrong attempts**
- Given a phone's OTP has already had 3 consecutive wrong attempts
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

### Out of Scope
- Email registration
- Social sign-in
- Driver-specific onboarding initiation (handled client-side after token receipt)

### Dependencies
- #1620 — User requests OTP via SMS (OTP must have been issued first)
- #1616 — SMS gateway delivers OTP to Egyptian mobile numbers (must be live)

---

## [API] #1622 — User logs in with OTP verification ✏️
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an unauthenticated endpoint with a phone number and OTP so that a returning user is authenticated and a session token is returned.

### Background
This unauthenticated endpoint is the second step of the login flow. It accepts the phone number and 6-digit OTP, verifies the OTP is correct and not expired, checks that the phone number belongs to a registered account, and returns a session token and the user's role. OTP expiry, wrong-attempt limits, and cooldown rules are enforced identically to #1621.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile; +20 prefix stripped | 11 digits | 11 digits | Digits only | Return validation error: phone is required | Return validation error: invalid Egyptian mobile format | Return validation error: must be 11 digits |
| otp | Yes | 6-digit numeric string | 6 chars | 6 chars | Digits only | Return validation error: OTP is required | Return validation error: OTP must be 6 digits | Return validation error: OTP must be 6 digits |

### Acceptance Criteria

**Scenario 1 — Successful login returns session token**
- Given a registered phone number and a correct, unexpired OTP are submitted
- When the endpoint processes the request
- Then a session token is returned that is accepted by #1744
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

**Scenario 4 — Wrong OTP increments attempt counter**
- Given a registered phone and an incorrect OTP are submitted
- When the endpoint processes the request
- Then a validation error is returned indicating the OTP is incorrect
- And the wrong-attempt counter for that OTP is incremented by 1

**Scenario 5 — OTP exhausted after 3 wrong attempts**
- Given a phone's OTP has had 3 consecutive wrong attempts
- When another login attempt is made
- Then an error is returned indicating the code is invalidated and a new one must be requested via #1620
- And when the user requests a new OTP via #1620 (resend), the new OTP starts with a fresh wrong-attempt counter of 0

**Scenario 6 — Unauthenticated request is processed correctly**
- Given no Authorization header is present (this is a public endpoint)
- When the endpoint receives the request
- Then the request is processed normally

**Scenario 7 — OTP resend resets the wrong-attempt counter**
- Given a user has made one or more wrong OTP attempts (including reaching the 3-attempt limit)
- When she requests a new OTP via #1620 (resend)
- Then the old OTP is invalidated and can no longer be submitted
- And a new OTP is issued with a wrong-attempt counter of 0
- And the user has a full 3 fresh attempts on the new code

### Out of Scope
- Password-based authentication
- Social sign-in

### Dependencies
- #1620 — User requests OTP via SMS (OTP must have been issued first)

---

## [API] #1623 — User retrieves own profile
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to retrieve the current user's profile so that the app can display the user's name, phone, and role.

### Background
This authenticated endpoint returns the profile data of the user identified by the session token in the Authorization header. The response includes the user's full name, phone number, role (rider or driver), and registration date.

### Acceptance Criteria

**Scenario 1 — Authenticated user retrieves profile**
- Given a valid session token is present in the Authorization header
- When the endpoint is called with no request body
- Then the response includes the authenticated user's full name, phone number, role (rider or driver), and account registration date

**Scenario 2 — Unauthenticated request is rejected**
- Given no Authorization header or an invalid token is present
- When the endpoint receives the request
- Then the request is rejected by #1744 auth middleware before the profile is accessed

### Out of Scope
- Profile editing (name or phone update)
- Profile photo upload
- Driver-specific profile fields (covered by onboarding stories)

### Dependencies
- #1744 — Auth middleware validates session tokens (must be live)

---

## [API] #1624 — User session is invalidated on logout
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to invalidate my current session so that my token can no longer be used and my device's push token is deregistered.

### Background
This authenticated endpoint is called when a rider or driver taps logout. It identifies the session via the Authorization header, marks the session token as invalidated in the session store (so #1744 rejects it on future requests), and removes any stored push notification device token associated with this session. The call is idempotent — calling it twice with an already-invalidated token is safe and returns a success response.

### Acceptance Criteria

**Scenario 1 — Session is invalidated and push token is deregistered**
- Given a valid session token is present in the Authorization header
- When the endpoint is called
- Then the session token is marked as invalidated in the session store
- And the push notification device token associated with this session is removed
- And a success response is returned

**Scenario 2 — Online driver is automatically set offline before session invalidation**
- Given the authenticated user is a driver whose availability status is online
- When the logout endpoint is called
- Then the driver's availability status is set to offline first
- And only after the status update succeeds is the session token invalidated

**Scenario 3 — Already-offline driver logs out cleanly**
- Given the authenticated user is a driver whose availability status is already offline
- When the logout endpoint is called
- Then no availability change is made
- And the session is invalidated and push token deregistered normally

**Scenario 4 — Subsequent requests with the invalidated token are rejected**
- Given a session has been invalidated by this endpoint
- When any subsequent request is made to a protected endpoint using the same token
- Then #1744 rejects the request

**Scenario 5 — Unauthenticated request is rejected**
- Given no Authorization header or an invalid token is present
- When the endpoint receives the request
- Then the request is rejected by #1744 auth middleware

### Out of Scope
- Remote logout from all devices
- Account deletion
- Logging the logout event for audit trail

### Dependencies
- #1744 — Auth middleware validates session tokens (must be live)

---


### Feature 7 — Rider Home, Address Search & Fare Estimate

---

## [API] #1626 — Address autocomplete returns suggestions
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the rider app, I want to retrieve address autocomplete suggestions as the rider types so that she can quickly find and select a pickup or destination without typing full addresses.

### Background
This authenticated endpoint is called by the rider app as the user types in the pickup or destination field, once 2 or more characters have been entered. It proxies the query to the Google Maps Places Autocomplete API with results biased to the Cairo/Giza area. The response contains a list of up to 5 address suggestions, each with a primary place name, secondary text (area/city), and a place ID for downstream use in fare estimation.

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
- Address validation beyond what Google provides
- Saving addresses to rider history

### Dependencies
- #1744 — Session token validation
- #1617 — Google Maps API key configuration

---

## [API] #1747 — Platform selects fastest traffic-aware route for fare estimation 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the SheDrive platform, I want to query Google Maps for route alternatives with live traffic and select the fastest route so that fare estimates and ETAs are based on the most realistic path a driver would actually take.

### Background
When a rider submits a pickup and destination, the platform queries the Google Maps **Directions API** with `alternatives=true` and `departure_time=now`. This returns up to 3 candidate routes, each carrying a `distance` (metres), a base `duration` (seconds), and a traffic-adjusted `duration_in_traffic` (seconds). The platform selects the route with the **lowest `duration_in_traffic`** and extracts two values from it: distance in km and duration_in_traffic in minutes. These two values are passed to the fare calculation module (#1628) and also returned to the client as the estimated route data. The other candidate routes are discarded. If Google Maps returns only one route, that route is used without comparison.

### Scenario 1 — Multiple routes returned: fastest in traffic is selected
- Given Google Maps returns 2 or more route alternatives for a valid pickup and destination
- When the platform processes the response
- Then the route with the lowest `duration_in_traffic` is selected
- And the other candidate routes are discarded
- And the selected route's distance (km) and duration_in_traffic (minutes) are passed to #1628

### Scenario 2 — Single route returned: that route is used
- Given Google Maps returns exactly one route for a valid pickup and destination
- When the platform processes the response
- Then that route is selected without comparison
- And its distance and duration_in_traffic are passed to #1628

### Scenario 3 — Live traffic is always factored in
- Given the platform queries Google Maps for any fare estimation request
- When the API call is constructed
- Then `departure_time=now` is always included in the request
- And `duration_in_traffic` is always used for the duration value (never the base `duration`)

### Scenario 4 — Two routes with equal duration_in_traffic: shorter distance wins
- Given Google Maps returns two routes with identical `duration_in_traffic`
- When the platform selects a route
- Then the route with the shorter distance is chosen as a tiebreaker

### Scenario 5 — Google Maps returns no valid routes
- Given Google Maps returns a response with zero valid routes (e.g., ZERO_RESULTS)
- When the platform processes the response
- Then the error is logged internally
- And a service-unavailable response is returned so the client can inform the rider to check her pickup and destination

### Scenario 6 — Rider sees estimate, not a locked fare
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
- #1628 — Fare applies base, per-km, and per-minute rates (consumes this story's output)

---

## [API] #1627 — Fare estimate uses Google Maps route data
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the rider app, I want to retrieve a fare estimate for a given pickup and destination so that the rider sees an informed price before confirming her booking.

### Background
This authenticated endpoint is called by the rider app once both pickup and destination are set. It calls the Google Maps Distance Matrix API to obtain the route distance (in km) and estimated duration (in minutes) between the two points. It then passes these values to the internal fare calculation logic (#1628) and returns the calculated fare, distance, and duration to the client.

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
- #1744 — Session token validation
- #1617 — Google Maps API key configuration
- #1628 — Fare applies base, per-km, and per-minute rates

---

## [API] #1628 — Fare applies base, per-km, and per-minute rates
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 1

**Description:** As the SheDrive platform, I want a configurable fare calculation function so that trip fares are computed consistently from distance and duration data across all fare-related flows.

### Background
This is an internal fare calculation module (not a directly callable external endpoint) used by #1627 (fare estimate) and the trip completion fare finalization (#1636). The formula is: **Fare = base_fare + (distance_km × rate_per_km) + (duration_min × rate_per_min)**. All three rates are stored in a configurable settings table and can be updated by an admin without a code deployment. Output is in Egyptian Pounds (EGP).

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

### Feature 5 — Driver Onboarding API

---

## [API] #1642 — Driver submits onboarding application ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the driver app, I want to submit a complete onboarding application so that SheDrive can review the driver's details and make an approval decision.

### Background
This authenticated endpoint accepts the full onboarding payload as a multipart form submission, including personal details, vehicle details, four document files, vehicle photo, and the driver's **profile photo** (#1686). It creates a new application record with status = pending and associates it with the authenticated driver account. Only one application per driver is supported; a second submission returns a conflict error.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error |
|---|---|---|---|---|---|---|
| name | Yes | Free text | 2 chars | 50 chars | Arabic, Latin, spaces | Return validation error |
| dob | Yes | DD/MM/YYYY, age ≥ 21 | — | — | Digits and "/" | Return validation error |
| nid | Yes | 14-digit numeric | 14 digits | 14 digits | Digits only | Return validation error |
| vehicle_make | Yes | Free text | 2 chars | 30 chars | Letters, spaces | Return validation error |
| vehicle_model | Yes | Free text | 2 chars | 30 chars | Letters, spaces, digits | Return validation error |
| vehicle_year | Yes | 4-digit year 2010–current | — | — | Digits only | Return validation error |
| vehicle_plate | Yes | Egyptian plate format | 2 chars | 8 chars | Letters, digits | Return validation error |
| vehicle_color | Yes | Non-empty string from allowed list | — | — | — | Return validation error |
| vehicle_type | Yes | One of: Sedan, SUV, Minivan | — | — | — | Return validation error |
| vehicle_photo | Yes | JPEG, PNG, or HEIC | — | 10 MB | — | Return validation error |
| licence_front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error |
| licence_back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error |
| registration_front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error |
| registration_back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | Return validation error |
| profile_photo | Yes | JPEG, PNG, or HEIC portrait | — | 10 MB | — | Return validation error |

### Acceptance Criteria

**Scenario 1 — Happy path: valid application created**
- Given an authenticated driver with no existing application
- When she submits a complete, valid multipart payload including all document files and profile photo
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
- Given the driver submits a file exceeding 10 MB for any document or photo field
- Then the server returns HTTP 422 with an error identifying the offending field

### Out of Scope
- Application re-submission after rejection
- Admin actions (handled in #1659, #1660)
- Push notification dispatch (handled in #1618)

### Dependencies
- #1744 — Session token validation

---

## [API] #1643 — Driver queries onboarding status
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the driver app, I want to query my onboarding application status so that I can route the driver to the correct screen (pending, approved, or rejected) on every app open.

### Acceptance Criteria

**Scenario 1 — Status is pending**
- Given an authenticated driver whose application status is pending
- When the app calls this endpoint
- Then the server returns HTTP 200 with status = "pending"

**Scenario 2 — Status is approved**
- Given an authenticated driver whose application has been approved
- When the app calls this endpoint
- Then the server returns HTTP 200 with status = "approved"

**Scenario 3 — Status is rejected**
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
- #1744 — Session token validation

---

## [API] #1716 — System pushes application decision to driver 🆕
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the SheDrive platform, I want to send a push notification to a driver when an admin approves or rejects her onboarding application so that she is immediately informed of the decision without having to poll or reopen the app.

### Background
Internal platform process triggered when an admin updates the driver's application status to *approved* or *rejected*. The notification payload and deep-link destination differ based on the decision: approved drivers are directed to the driver home screen; rejected drivers are directed to the rejection notice screen where the reason is visible. The rejection reason text written by the admin is included in the push body.

**Bilingual delivery:** All push text must be in the driver's preferred language (`shedrive.lang`). Arabic is used as the default. Both AR and EN templates must be maintained:
- Approved — AR: "تهانينا! تمت الموافقة على طلبك. يمكنك الآن بدء العمل."
- Approved — EN: "Congratulations! Your application has been approved. You can now go online."
- Rejected — AR: "لم يتم قبول طلبك. السبب: [سبب الرفض]."
- Rejected — EN: "Your application was not approved. Reason: [rejection reason]."

### Acceptance Criteria

**Scenario 1 — Approval push sent when admin approves application**
- Given an admin has approved a driver's application
- When the platform processes the approval
- Then a push notification is dispatched to the driver's registered device automatically
- And the notification body contains the approval message in the driver's preferred language
- And the notification deep-links to the driver home screen

**Scenario 2 — Rejection push sent when admin rejects application**
- Given an admin has rejected a driver's application with a written reason
- When the platform processes the rejection
- Then a push notification is dispatched to the driver's registered device automatically
- And the notification body includes the rejection reason text in the driver's preferred language
- And the notification deep-links to the rejection notice screen

**Scenario 3 — Driver push token not registered — silent fail**
- Given the driver has no registered push device token at the time of the decision
- When the platform attempts to dispatch the push
- Then the push silently fails
- And the application decision is still saved and will be reflected when the driver opens the app and calls #1643

**Scenario 4 — Push failure does not block the admin decision**
- Given the push provider returns an error
- When the platform processes the failure
- Then the driver's application status is not rolled back
- And the push failure is logged internally

**Scenario 5 — Notification delivered in driver's preferred language**
- Given the driver's `shedrive.lang` is "ar" or "en"
- When the decision push is dispatched
- Then the notification title and body are rendered in the driver's preferred language
- And Arabic is used as the default when no preference is stored

### Out of Scope
- Email or SMS fallback for push delivery failures
- Driver appeal or re-submission flow
- Admin notification of push delivery status

### Dependencies
- #1618 — Push notification service (must be live)
- #1643 — Driver queries onboarding status (fallback for when push is missed)

---

## [API] #1644 — Driver is blocked from going online until approved
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As the SheDrive platform, I want to reject any attempt by a non-approved driver to set her status to online so that only verified drivers can receive trip requests.

### Acceptance Criteria

**Scenario 1 — Pending driver attempts to go online**
- Given an authenticated driver whose application status is pending
- When she sends a request to go online (#1645)
- Then the server returns HTTP 403
- And the response body indicates: application not yet approved

**Scenario 2 — Rejected driver attempts to go online**
- Given an authenticated driver whose application status is rejected
- When she sends a request to go online (#1645)
- Then the server returns HTTP 403
- And the response body indicates: application was not approved

**Scenario 3 — Approved driver can go online**
- Given an authenticated driver whose application status is approved
- When she sends a request to go online (#1645)
- Then the request is not blocked by this guard
- And the availability endpoint processes it normally

**Scenario 4 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- Then the server returns HTTP 401

### Out of Scope
- Re-submission flow after rejection
- Application review workflow

### Dependencies
- #1744 — Session token validation
- #1643 — Driver queries onboarding status

---

### Feature 6 — Driver Home & Availability API

---

## [API] #1645 — Driver sets availability status
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As the driver app, I want to set the driver's availability status to online or offline so that the platform knows whether to dispatch trip requests to her.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| status | Yes | Enum | — | — | "online" or "offline" | Return validation error | Return validation error | — |

### Acceptance Criteria

**Scenario 1 — Approved driver goes online**
- Given an authenticated driver with application status = approved
- When she sends status = "online"
- Then the server updates her availability to online
- And returns HTTP 200 with the new status

**Scenario 2 — Driver goes offline**
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
- Then the server returns HTTP 401

### Out of Scope
- Automatic offline on app close (future sprint)
- Status history or audit log

### Dependencies
- #1744 — Session token validation
- #1644 — Driver is blocked from going online until approved

---

## [API] #1646 — Driver updates GPS location
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As the driver app, I want to push the driver's current GPS coordinates to the server every 5 seconds while online so that the platform can use live location for matching and map display.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| latitude | Yes | Decimal number | −90 | 90 | Digits, ".", "-" | Return validation error | Return validation error | — |
| longitude | Yes | Decimal number | −180 | 180 | Digits, ".", "-" | Return validation error | Return validation error | — |

### Acceptance Criteria

**Scenario 1 — Valid coordinates accepted**
- Given an authenticated, online driver
- When she sends valid latitude (−90 to 90) and longitude (−180 to 180)
- Then the server updates her live position record
- And returns HTTP 200

**Scenario 2 — Missing latitude or longitude**
- Given the driver sends a request missing latitude or longitude
- Then the server returns HTTP 422 with a validation error

**Scenario 3 — Out-of-range coordinate**
- Given the driver sends a latitude > 90 or < −90, or a longitude > 180 or < −180
- Then the server returns HTTP 422 with a validation error

**Scenario 4 — Unauthenticated request is rejected**
- Given a request with no session token or an invalid/expired token
- Then the server returns HTTP 401

### Out of Scope
- Location history storage beyond the current live position
- Geofencing or zone-based alerts

### Dependencies
- #1744 — Session token validation

---

## Sprint 2

### Feature 8 — Trip Request & Matching API

---

## [API] #1629 — Rider creates trip request
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the rider app, I want to submit a trip request with pickup and destination coordinates so that the platform can create a trip record and begin the matching process.

### Background
Called when a rider taps "Request Ride." The platform validates that the pickup and destination are distinct, creates a trip record with status = "searching," and immediately triggers the internal matching process (#1630). Returns the trip ID for subsequent status polling. Only riders with an active session may call this endpoint. A rider with an existing active trip is blocked from creating another.

### Acceptance Criteria

**Scenario 1 — Successful trip request creation**
- Given an authenticated rider submits a valid pickup and destination that are distinct locations
- When the endpoint is called
- Then a trip record is created with status = "searching"
- And the matching process (#1630) is triggered
- And the response includes the new trip ID

**Scenario 2 — Pickup equals destination**
- Given an authenticated rider submits a pickup location identical to the destination
- Then a validation error is returned: "Pickup and destination must be different locations"
- And no trip record is created

**Scenario 3 — Pickup field is missing**
- Given an authenticated rider submits a request with no pickup location
- Then a validation error is returned: "Pickup location is required"

**Scenario 4 — Destination field is missing**
- Given an authenticated rider submits a request with no destination
- Then a validation error is returned: "Destination is required"

**Scenario 5 — Invalid coordinate format**
- Given an authenticated rider submits coordinates outside the valid range
- Then a validation error is returned indicating the invalid field and its constraint

**Scenario 6 — Unauthenticated request**
- Given a request is made without a valid session token
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
- #1744 — Session validation (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1630 — System matches request to nearest available driver
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically match a new trip request to the nearest online, available driver so that the rider is connected to a driver as quickly as possible.

### Background
Internal platform orchestration process triggered immediately after a trip request is created (#1629). It queries for online, approved drivers who do not have an active trip AND are not currently in a pending dispatch window, ranks them by distance to the rider's pickup location, and dispatches the trip to the nearest driver via #1647. If no eligible drivers are found, the trip is immediately marked as expired and the rider is notified (#1632). If a driver rejects or times out, the process continues to the next nearest driver via #1651.

### Acceptance Criteria

**Scenario 1 — Nearest driver found and dispatched**
- Given a trip request enters "searching" status
- When the matching process runs
- Then the nearest online, approved driver without an active trip or pending dispatch is identified
- And the trip request is dispatched to that driver (#1647)

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

### Dependencies
- #1744 — Session validation (must be live)
- #1645 — Driver online status and location tracking (must be live)
- #1647 — System pushes trip request to matched driver (must be live)
- #1632 — Trip expires and rider is notified via push (must be live)

---

## [API] #1631 — Rider polls for match status
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the rider app, I want to poll the platform for the current match status of my trip request so that the UI can transition from "searching" to the driver card when a match is confirmed.

### Background
After creating a trip request, the rider app polls this endpoint every 2–3 seconds. Returns the current trip status: searching, matched, or no_driver. When matched, the response includes driver details, vehicle details, star rating, ETA, and driver's live location. When no_driver, the app navigates the rider to the error screen.

### Acceptance Criteria

**Scenario 1 — Trip is still searching**
- Given an authenticated rider polls for match status
- When the trip is still in "searching" status
- Then the response returns status = searching and no driver details are included

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
- Then a not-found error is returned

**Scenario 5 — Unauthenticated request**
- Given a request is made without a valid session token
- Then the request is rejected with an authentication error

### Out of Scope
- WebSocket or server-sent event streaming (polling only this sprint)
- Polling rate limiting (handled client-side)

### Dependencies
- #1744 — Session validation (must be live)
- #1629 — Rider creates trip request (must be live)

---

## [API] #1632 — Trip expires and rider is notified via push ✏️
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to mark a trip as expired and send a push notification to the rider when no driver accepts so that the rider is promptly informed and can choose to try again.

### Background
Internal platform process triggered by #1630 when the matching pool is exhausted. The platform marks the trip record status as expired and sends a push notification to the rider's registered device.

**Bilingual delivery:** The notification text must be delivered in the rider's preferred language (`shedrive.lang`). Arabic is the default. Both AR and EN copies of this template must be maintained:
- AR: "لم نتمكن من إيجاد سائقة. يرجى المحاولة مرة أخرى."
- EN: "We couldn't find a driver. Please try again."

### Acceptance Criteria

**Scenario 1 — Trip marked as expired and push sent**
- Given the matching process has exhausted all eligible drivers
- When this process is triggered
- Then the trip record status is updated to expired
- And a push notification is sent to the rider's registered device in her preferred language

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

**Scenario 4 — Notification in user's preferred language**
- Given the rider's `shedrive.lang` is "ar" or "en"
- When the expiry push is dispatched
- Then the notification text is in the rider's preferred language
- And Arabic is used as the default when no preference is stored

### Out of Scope
- Automatic re-queuing of the expired trip
- Rider compensation or credits for no-driver situations
- SMS fallback for push failures

### Dependencies
- #1744 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1713 — System pushes match confirmation to rider 🆕
**Feature:** Feature 8 — Trip Request & Matching | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when a driver accepts her trip so that she is immediately informed the match is confirmed, even if the app is backgrounded.

### Background
Internal platform process triggered automatically when a driver calls the accept endpoint (#1649) and the trip transitions to *accepted* status. The platform immediately dispatches a push notification to the rider's registered device containing the driver's name. The push enables the rider to navigate directly to the active trip screen from a backgrounded or closed app state.

**Bilingual delivery:** The notification must be delivered in the rider's preferred language (`shedrive.lang`):
- AR: "تم إيجاد سائقة! [اسم السائقة] في طريقها إليك."
- EN: "Driver found! [Driver name] is on the way."

Arabic is used as the default when no preference is stored.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on trip acceptance**
- Given a driver has called the accept endpoint and the trip has transitioned to *accepted* status
- When the platform processes the acceptance
- Then a push notification is sent to the rider's registered device automatically
- And no separate API call from any client is required to trigger it

**Scenario 2 — Notification payload includes driver name in correct language**
- Given the rider's `shedrive.lang` is "ar" or "en"
- When the match confirmation push is dispatched
- Then the notification title and body are rendered in the rider's preferred language
- And the driver's name is correctly interpolated into the notification body
- And Arabic is used as the default when no preference is stored

**Scenario 3 — Rider's push token not registered — silent fail**
- Given the rider has no registered push device token
- When the platform attempts to dispatch the match confirmation push
- Then the push silently fails with no error surfaced to the driver or rider
- And the trip state remains accepted
- And the rider will see the matched driver details on her next poll via #1631

**Scenario 4 — Push provider failure does not block trip state transition**
- Given the push provider returns an error when the platform attempts delivery
- When the platform processes the push failure
- Then the trip state is not rolled back — it remains accepted
- And the push failure is logged internally for retry or investigation

**Scenario 5 — Duplicate acceptance call does not dispatch a second push**
- Given the match confirmation push has already been dispatched for this trip
- When a duplicate acceptance call arrives (handled by #1649 idempotency)
- Then no second push notification is dispatched to the rider

### Out of Scope
- SMS fallback for push delivery failures
- Rider acknowledgement of the push
- In-app notification inbox

### Dependencies
- #1618 — Push notification service (must be live)
- #1649 — Driver accepts trip (triggers this process)

---

### Feature 9 — Driver Trip Acceptance API

---

## [API] #1647 — System pushes trip request to matched driver ✏️
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As the SheDrive platform, I want to push a trip request notification and pending record to the matched driver so that she can review the details and respond within the acceptance window.

### Background
Internal platform process triggered by the matching engine (#1630) after selecting the nearest eligible driver. The process creates a pending trip record for the driver (so she can retrieve details via #1648) and sends a push notification to her registered device with the pickup area and estimated fare. The 10-second server-side acceptance clock starts from the moment this notification is dispatched.

**Bilingual delivery:** The notification must be delivered in the driver's preferred language (`shedrive.lang`). Arabic is the default. Both AR and EN copies must be maintained:
- AR: "طلب رحلة جديدة! [المنطقة] - [المبلغ المقدر] جنيه"
- EN: "New trip request! [Area] - [Fare] EGP"

### Acceptance Criteria

**Scenario 1 — Pending trip record created and push sent**
- Given the matching engine has selected a driver
- When this process is triggered
- Then a pending trip record is created associating the driver with the trip
- And a push notification is sent to the driver's registered device in her preferred language
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

**Scenario 4 — Notification in driver's preferred language**
- Given the driver's `shedrive.lang` is "ar" or "en"
- When the push is dispatched
- Then the notification text is in the driver's preferred language
- And Arabic is used as the default

### Out of Scope
- Driver in-app messaging
- Multiple simultaneous dispatch to several drivers

### Dependencies
- #1744 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

---

## [API] #1648 — Driver retrieves pending trip request
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the details of my pending trip request so that I can display the pickup address, destination, distance, and fare on the acceptance screen.

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

**Scenario 3 — Unauthenticated request**
- Given a request is made without a valid driver session token
- Then the request is rejected with an authentication error

**Scenario 4 — Trip was reassigned before retrieval**
- Given the 10-second window expired and the trip was reassigned before the driver's app called this endpoint
- Then an expired or not-found response is returned
- And no trip details are shown to the driver

### Out of Scope
- Rider profile details visible to driver before acceptance
- Destination full address (summary only)
- Historical pending trips

### Dependencies
- #1744 — Session validation (must be live)
- #1647 — System pushes trip request to matched driver (must be live)

---

## [API] #1649 — Driver accepts trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to submit an acceptance for a pending trip request so that the trip is confirmed and the rider is notified that her driver is on the way.

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
- Then a conflict error is returned: "Acceptance window has expired"
- And the trip status is not changed

**Scenario 3 — No pending trip for this driver**
- Given an authenticated driver calls the accept endpoint when she has no pending trip
- Then a not-found error is returned

**Scenario 4 — Unauthenticated request**
- Given a request is made without a valid driver session token
- Then the request is rejected with an authentication error

**Scenario 5 — Duplicate acceptance call**
- Given a driver's acceptance has already been recorded
- When the same accept endpoint is called again (e.g., double-tap)
- Then the endpoint returns a conflict or idempotent success
- And no duplicate state changes occur

### Dependencies
- #1744 — Session validation (must be live)
- #1648 — Driver retrieves pending trip request (must be live)

---

## [API] #1650 — Driver rejects trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As the driver app, I want to submit a rejection for a pending trip request so that I can decline the trip and the platform can reassign it to another driver.

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
- Then a conflict error is returned
- And no duplicate reassignment is triggered

**Scenario 3 — No pending trip for this driver**
- Given an authenticated driver calls the reject endpoint when she has no pending trip
- Then a not-found error is returned

**Scenario 4 — Unauthenticated request**
- Given a request is made without a valid driver session token
- Then the request is rejected

**Scenario 5 — Driver status remains available after rejection**
- Given the driver has successfully rejected the trip
- Then her status is confirmed as available
- And no penalty or flag is recorded against the driver in this sprint

### Dependencies
- #1744 — Session validation (must be live)
- #1648 — Driver retrieves pending trip request (must be live)
- #1651 — Trip is reassigned on rejection or timeout (must be live)

---

## [API] #1651 — Trip is reassigned on rejection or timeout
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically reassign a trip when a driver rejects it or the acceptance window times out so that the rider is matched to another driver without manual intervention.

### Background
Internal platform process triggered when (1) a driver explicitly rejects via #1650, or (2) the server-side 10-second acceptance timer elapses with no acceptance recorded. When triggered, the process marks the current driver dispatch as rejected/timed-out, finds the next nearest eligible driver, and repeats the dispatch (#1647). If no further eligible drivers are available, the trip is expired and the rider is notified (#1632).

### Acceptance Criteria

**Scenario 1 — Reassignment to next nearest driver**
- Given a driver has rejected a trip or the 10-second window has expired
- When this process is triggered
- Then the current driver dispatch record is marked as rejected or timed-out
- And the next nearest online, approved, available driver is identified
- And the trip is dispatched to that driver (#1647)

**Scenario 2 — No further eligible drivers**
- Given the reassignment process finds no remaining eligible drivers
- Then the trip is marked as expired
- And the rider is notified via push (#1632)

**Scenario 3 — Race condition — driver accepted just before timeout**
- Given a driver's acceptance and the server-side timeout arrive nearly simultaneously
- When the acceptance is recorded first
- Then the trip is marked as accepted and this reassignment process is not triggered
- And if the timeout fires first, the acceptance call returns a conflict (#1649)

**Scenario 4 — Repeated reassignment chain**
- Given multiple drivers are tried in sequence
- When each rejects or times out
- Then the process continues until either a driver accepts or the pool is exhausted

### Dependencies
- #1744 — Session validation (must be live)
- #1630 — System matches request to nearest available driver (must be live)
- #1632 — Trip expires and rider is notified via push (must be live)

---

### Feature 10 — Active Trip API

---

## [API] #1633 — Rider retrieves live trip state and driver location
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the rider app, I want to poll the platform for the current trip state and driver location so that the rider's screen always reflects reality.

### Background
The rider app polls this endpoint approximately every 5 seconds while the trip is active. The response includes the current trip state, the driver's last known GPS coordinates, ETA to pickup (in en_route_pickup state only), and driver card details.

### Acceptance Criteria

**Scenario 1 — Response includes trip state and driver location**
- Given an authenticated rider has an active trip
- When the rider app calls this endpoint
- Then the response includes the current trip state and the driver's last known latitude and longitude

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
- Then the platform rejects the request

**Scenario 6 — arrived_at timestamp included when driver has arrived**
- Given the trip is in arrived_pickup state
- When the rider app polls this endpoint
- Then the response includes an arrived_at field containing the UTC timestamp of when the state transitioned to arrived_pickup
- And the rider app uses this timestamp to compute the correct elapsed waiting time
- And if the rider app is restarted while the driver is waiting, the counter resumes from the correct elapsed time rather than resetting to 0:00

### Out of Scope
- WebSocket or server-sent event push (polling model only for MVP)
- Trip history retrieval

### Dependencies
- #1744 — Authentication service (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [API] #1634 — System pushes driver-arrived to rider ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when the driver marks arrival so that the rider is alerted even if the app is backgrounded.

### Background
Internal platform process. When the driver advances the trip state to arrived_pickup via #1652, the state machine immediately triggers a push notification to the rider's registered device.

**Bilingual delivery:** The notification must be delivered in the rider's preferred language (`shedrive.lang`):
- AR: "سائقتك وصلت! توجهي إلى موقع الانطلاق."
- EN: "Your driver has arrived! Please head to the pickup point."

Arabic is used as the default.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on arrived_pickup transition**
- Given a driver has advanced a trip to arrived_pickup state
- When the platform processes the state transition
- Then a push notification is sent to the rider's device automatically
- And no separate API call from any app is required to trigger it

**Scenario 2 — Push text is in rider's preferred language**
- Given the rider's `shedrive.lang` is "ar" or "en"
- When the arrived_pickup push is triggered
- Then the notification text is in the rider's preferred language
- And Arabic is used as the default when no preference is stored

**Scenario 3 — Push failure does not block the state transition**
- Given the push delivery service is temporarily unavailable
- When the driver advances to arrived_pickup
- Then the trip state is still saved as arrived_pickup
- And the platform logs the push delivery failure for retry

### Out of Scope
- SMS fallback for push delivery failures
- Rider acknowledgement of the push

### Dependencies
- #1744 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1635 — Trip detail includes first-trip flag ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the driver app, I want the trip detail response to include a first-trip flag so that I know whether to show the gender verification step (#1588) before starting the trip.

### Background
When the driver app fetches the active trip details, the response includes a boolean field `is_first_trip`. This field is `true` if the trip belongs to a rider who has never previously completed a trip on SheDrive. It is derived from the rider's trip history at the time the trip is created and stored on the trip record. The driver app reads this flag to conditionally display the rider gender verification step (#1588) for first-trip riders, which includes a bilingual confirmation dialog for the gender verification process (#1588).

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
- Then the platform rejects the request

### Out of Scope
- Recalculating first-trip status after trip creation
- Exposing this flag to the rider app

### Dependencies
- #1744 — Authentication service (must be live)
- #1641 — Rider retrieves trip history (used internally to compute is_first_trip at trip creation time)
- #1588 — Driver verifies rider is female on first trip (gender verification step that uses this flag)

---

## [API] #1652 — Driver advances trip state machine ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the driver app, I want to advance the trip state through each stage so that all downstream screens and notifications are triggered correctly.

### Background
Core state-transition endpoint consumed by the driver app. Validates the sequence (accepted → en_route_pickup → arrived_pickup → trip_started → trip_ended) and rejects any attempt to skip a state.

**State history logging (required):** Every accepted state transition MUST also write an immutable record to a `trip_state_history` table containing: `trip_id`, `from_state`, `to_state`, `transitioned_at` (UTC timestamp), and `actor_id` (driver ID or "system" for automated transitions). This history is consumed by the admin trip detail screen (#1675) to display the full trip timeline.

### Acceptance Criteria

**Scenario 1 — Valid state transition is accepted**
- Given an authenticated driver has an active trip in state S
- When the driver app sends the next valid state S+1
- Then the platform updates the trip record to the new state
- And the appropriate side effects are triggered

**Scenario 2 — Skipping a state is rejected**
- Given an active trip is in en_route_pickup state
- When the driver app sends trip_started (skipping arrived_pickup)
- Then the platform rejects the request and the trip remains in en_route_pickup state

**Scenario 3 — arrived_pickup triggers rider push**
- Given an active trip is in en_route_pickup state
- When the driver advances state to arrived_pickup
- Then the platform sends a push notification to the rider via #1634

**Scenario 4 — trip_ended triggers fare calculation**
- Given an active trip is in trip_started state
- When the driver advances state to trip_ended
- Then the platform triggers final fare calculation via #1636
- And the rider is notified via #1638

**Scenario 5 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects the request and the trip state is unchanged

**Scenario 6 — Every state transition is logged to history**
- Given a valid state transition is processed
- When the new state is saved to the trip record
- Then a `trip_state_history` record is created with: trip_id, from_state, to_state, transitioned_at (UTC), actor_id
- And the history record is immutable (cannot be deleted or modified)
- And subsequent reads of the trip detail return the full ordered history

### Out of Scope
- Reverse state transitions
- Admin-initiated state changes
- SOS state handling

### Dependencies
- #1744 — Authentication service (must be live)
- #1634 — System pushes driver-arrived to rider (must be live)
- #1636 — Final fare calculation (must be live)
- #1638 — System pushes trip completion to rider (must be live)

---

## [API] #1653 — Driver streams GPS from acceptance to completion
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the driver app, I want to send my GPS coordinates to the platform throughout the trip so that the rider can track my live location.

### Background
From the moment a driver accepts a trip until trip_ended, the driver app calls the location update endpoint (#1646) every 5 seconds. This endpoint associates the incoming coordinates with the active trip record, making them immediately available to the rider app through #1633.

### Acceptance Criteria

**Scenario 1 — Driver coordinates are associated with the active trip**
- Given the driver has an active trip and is sending GPS updates
- When the platform receives a location update
- Then the coordinates are stored against the active trip record
- And the rider app can retrieve the updated location via #1633

**Scenario 2 — Location updates are available in near real time**
- Given the driver sends a GPS update
- When the rider app polls via #1633
- Then the driver's position reflects the most recent coordinate within 5 seconds

**Scenario 3 — Streaming stops after trip_ended**
- Given the trip has advanced to trip_ended
- When the driver app sends a GPS update
- Then the update is not associated with a completed trip
- And no live location data is served to the rider for this trip

**Scenario 4 — Unauthenticated GPS updates are rejected**
- Given a GPS update arrives without a valid driver auth token
- Then the platform rejects the update

### Out of Scope
- Historical route replay
- GPS accuracy validation

### Dependencies
- #1744 — Authentication service (must be live)
- #1646 — Driver location update endpoint (must be live)

---

## [API] #1688 — Trip auto-expires when stuck in an active state 🆕
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the SheDrive platform, I want to automatically expire trips stuck in an active state beyond 60 minutes so that riders are not permanently locked out of booking and drivers are not indefinitely marked "on trip."

### Background
A server-side scheduled process runs every 5 minutes and checks for trips in any active state (matched, accepted, en_route_pickup, arrived_pickup, trip_started) with no state transition AND no GPS update for more than 60 minutes. Such trips are auto-expired with reason "system_timeout". Driver availability resets to "offline". Rider is notified in her preferred language and freed to book again. Fare = 0.

### Acceptance Criteria

**Scenario 1 — Stuck trip auto-expired**
- Given a trip in an active state with no update for more than 60 minutes
- When the scheduled process runs
- Then the trip is marked expired with reason "system_timeout"
- And driver availability is set to "offline"
- And rider receives push in her preferred language

**Scenario 2 — No fare charged**
- Given a trip has been auto-expired
- Then fare = EGP 0 and no cash collection screen is shown

**Scenario 3 — Active trip with recent activity is not expired**
- Given a trip had a state or GPS update within the past 60 minutes
- When the process runs
- Then the trip is skipped

**Scenario 4 — Expiry is idempotent**
- Given a trip is already in a terminal state
- When the process evaluates it
- Then no modification or duplicate notification occurs

**Scenario 5 — Notification in user's preferred language**
- Given the rider's shedrive.lang is "ar" or "en"
- Then notification is delivered in that language (Arabic default)

### Out of Scope
- Configurable timeout via admin UI (60 min hardcoded for MVP)
- Partial fare for incomplete trips
- Driver penalty for abandoned sessions (future sprint)

### Dependencies
- #1744 — Session validation
- #1618 — Push notification service
- #1652 — Trip state machine

---

### Feature 11 — Trip Completion & Cash Payment API

---

## [API] #1636 — Final fare is calculated from actual route and duration
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to calculate the final trip fare from the actual GPS distance and duration when the trip ends so that the rider and driver see the correct amount to exchange.

### Background
Platform process triggered automatically when the driver advances the trip state to trip_ended via #1652. Uses the rate formula from #1628: base fee + (per-km rate × actual GPS distance in km) + (per-minute rate × actual trip duration in minutes). The resulting final fare is stored on the trip record and made available to downstream consumers.

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
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to retrieve a completed trip's full details including the fare breakdown so that the rider sees exactly what she owes.

### Background
Called by the rider app to populate the trip summary screen after a trip reaches trip_ended state. The response includes the total fare in EGP, a breakdown of the three fare components (base fee, distance charge, time charge), total distance in km, trip duration in minutes, pickup address, destination address, driver name, vehicle details, and the rider's rating if one has been submitted.

### Acceptance Criteria

**Scenario 1 — Response includes fare total and breakdown**
- Given a trip is in trip_ended state
- When the rider app calls this endpoint
- Then the response includes the total fare in EGP
- And separate line items for base fee, distance charge, and time charge

**Scenario 2 — Response includes trip metadata**
- Given the endpoint is called for a completed trip
- Then it includes total distance in km, trip duration in minutes, pickup address, and destination address

**Scenario 3 — Response includes driver details**
- Given the endpoint is called for a completed trip
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
- Then the platform rejects the request

### Out of Scope
- Full trip history listing
- Fare dispute submission

### Dependencies
- #1744 — Authentication service (must be live)
- #1636 — Final fare calculation (must be live)

---

## [API] #1638 — System pushes trip completion to rider ✏️
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to send a push notification to the rider when the trip ends so that she is alerted to the final fare even if the app is backgrounded.

### Background
Internal platform process triggered when the trip state advances to trip_ended via #1652. Once the fare is calculated, the platform sends a push notification to the rider's registered device.

**Bilingual delivery:** The notification must be delivered in the rider's preferred language (`shedrive.lang`):
- AR: "رحلتك اكتملت! المبلغ المستحق: [X] جنيه."
- EN: "Your trip is complete! Amount due: [X] EGP."

Arabic is used as the default.

### Acceptance Criteria

**Scenario 1 — Push is sent automatically on trip_ended**
- Given the driver has advanced the trip to trip_ended and the fare has been calculated
- When the platform processes the state transition
- Then a push notification is sent to the rider's device automatically in her preferred language
- And the notification includes the final fare amount

**Scenario 2 — Push failure does not block state transition**
- Given the push delivery service is temporarily unavailable
- When the driver advances to trip_ended
- Then the trip state is still saved as trip_ended
- And the fare is still calculated and stored
- And the platform logs the push delivery failure for retry

**Scenario 3 — Notification in user's preferred language**
- Given the rider's `shedrive.lang` is "ar" or "en"
- When the completion push is triggered
- Then the notification text is in the rider's preferred language
- And Arabic is used as the default

### Out of Scope
- SMS or email fallback for push delivery failures

### Dependencies
- #1744 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1639 — Rider submits driver rating
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to submit a star rating and optional tags for a completed trip so that the driver's performance is recorded.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| trip_id | Yes | String / UUID | — | — | Alphanumeric, hyphens | Return validation error | Return not-found or forbidden if trip not found or not this rider's; return conflict error if rating already exists for this trip | — |
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
- Then a validation error is returned and no rating is stored

**Scenario 3 — Stars out of range returns validation error**
- Given the rider submits a stars value of 0 or 6
- Then a validation error is returned

**Scenario 4 — Trip not found or not rider's trip**
- Given the rider submits a trip ID that does not exist or belongs to a different rider
- Then a not-found or forbidden error is returned

**Scenario 5 — Invalid tag value returns validation error**
- Given the rider submits a tag string not in the predefined list
- Then a validation error is returned

**Scenario 6 — More than 3 tags returns validation error**
- Given the rider submits 4 or more tag values
- Then a validation error is returned

**Scenario 7 — Tags are optional**
- Given the rider submits a valid trip ID and stars but no tags
- Then the rating is stored successfully without tags

**Scenario 8 — Unauthenticated request is rejected**
- Given a request arrives without a valid rider auth token
- Then the platform rejects the request

**Scenario 9 — Rating already submitted returns conflict error**
- Given an authenticated rider submits a rating for a trip that already has a rating recorded
- Then the platform returns a conflict error
- And no new rating is stored

### Out of Scope
- Free-text comment submission
- Rating edit or deletion after submission

### Dependencies
- #1744 — Authentication service (must be live)
- #1654 — Driver aggregate rating update (must be live)

---

## [API] #1640 — Trip closes without rating on skip
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to mark a trip as completed without a rating when the rider skips so that the trip history remains accurate and the driver's rating is unaffected.

### Acceptance Criteria

**Scenario 1 — Trip is marked skipped when rider skips rating**
- Given the rider has tapped "Skip" on the rating or summary screen
- When the platform processes the skip action
- Then the trip record is updated with rating_status = skipped
- And no rating record is created

**Scenario 2 — Driver aggregate rating is unchanged after skip**
- Given a trip has been marked rating_status = skipped
- Then the driver's aggregate star rating is not recalculated

**Scenario 3 — Trip is visible in history for rider and driver**
- Given a trip has rating_status = skipped
- When either the rider or driver views their trip history
- Then the trip record is present with all trip details
- And no rating is shown for that trip

**Scenario 4 — Skipped status is final**
- Given a trip has been marked rating_status = skipped
- When any subsequent request attempts to submit a rating for that trip
- Then the platform rejects the request

**Scenario 5 — Unauthenticated skip request is rejected**
- Given a skip request arrives without a valid auth token
- Then the platform rejects the request

### Dependencies
- #1744 — Authentication service (must be live)

---

## [API] #1717 — Driver retrieves completed trip fare 🆕
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the driver app, I want to retrieve the final fare for a completed trip and confirm fare collection so that the cash collection screen displays the exact amount to collect and the driver is returned to available status on confirmation.

### Background
Called immediately after the driver advances the trip to *trip_ended* state via #1652. The endpoint returns the final fare (in EGP) as calculated and stored by #1636. When the driver taps "Done" to confirm collection, this endpoint (or a paired confirmation call) resets the driver's availability status to *available* so she is ready to receive the next trip. The fare amount returned must exactly match the value stored on the trip record — no recalculation occurs at retrieval time.

### Acceptance Criteria

**Scenario 1 — Driver retrieves fare for a completed trip**
- Given an authenticated driver has a trip in trip_ended state
- When she calls this endpoint
- Then the response includes the final fare amount in EGP as calculated by #1636
- And the amount is sufficient to populate the cash collection screen

**Scenario 2 — Fare amount matches the stored calculated fare**
- Given the platform has calculated and stored the final fare via #1636
- When the driver retrieves the fare
- Then the value returned is identical to the value stored on the trip record
- And no recalculation occurs at retrieval time

**Scenario 3 — Driver confirms fare collected and returns to available**
- Given the driver has viewed the cash collection screen and taps "Done"
- When the confirmation is submitted
- Then the driver's availability status is reset to "available"
- And the driver is ready to receive the next trip request

**Scenario 4 — Trip is not in trip_ended state**
- Given the driver calls this endpoint for a trip that has not yet reached trip_ended state
- When the endpoint processes the request
- Then a conflict or not-ready error is returned
- And no fare data is returned

**Scenario 5 — Trip not found or belongs to a different driver**
- Given the driver requests a trip ID that does not exist or belongs to a different driver
- Then a not-found or forbidden error is returned

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid driver session token is provided
- Then the request is rejected with an authentication error

### Out of Scope
- Digital payment confirmation or processing
- Receipt generation for the driver
- Fare dispute workflow

### Dependencies
- #1744 — Session validation (must be live)
- #1636 — Final fare calculation (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1645 — Driver sets availability status (must be live)

---

## [API] #1654 — Driver aggregate rating is updated
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the SheDrive platform, I want to recalculate the driver's average rating after each new rating is submitted so that the driver's profile always reflects her current standing.

### Background
Internal platform process triggered after a rating is successfully stored by #1639. The platform recalculates the driver's average star rating across all rated trips (excluding skipped trips). The updated average is written to the driver's profile record immediately.

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
- Given a trip was completed with rating_status = skipped
- When the driver's aggregate is calculated
- Then that trip is excluded from the average calculation

**Scenario 4 — First rating sets the aggregate correctly**
- Given a driver has no prior ratings
- When the first rating (e.g., 4 stars) is submitted
- Then the driver's aggregate rating is set to 4.0

### Dependencies
- #1639 — Rider submits driver rating (must be live)

---

### Feature 12 — Trip History API

---

## [API] #1641 — Rider retrieves trip history
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As the rider app, I want to retrieve a paginated list of the authenticated rider's past trips so that the trip history screen can display accurate trip data.

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
- Then the response contains an empty list with pagination metadata reflecting zero records

**Scenario 3 — Rider requests a subsequent page**
- Given the rider has trips spanning multiple pages
- When the rider app requests page two
- Then the response contains the correct slice of trips in date descending order

**Scenario 4 — Rider retrieves individual trip detail**
- Given the rider requests a specific completed trip by ID
- When the endpoint processes the request
- Then the response includes the full fare breakdown (base fee, distance charge, time charge, total), trip date, pickup address, destination address, distance (km), and duration (minutes)
- And the data is sufficient to populate the trip history detail screen

**Scenario 5 — Rating is included in trip detail if submitted**
- Given the rider has submitted a rating for the trip
- When the rider retrieves that trip's detail
- Then the response includes the star rating and any selected tags

**Scenario 6 — Rating field is null if not submitted**
- Given the rider has not submitted a rating for the trip (or skipped)
- When the rider retrieves that trip's detail
- Then the rating field is null or absent in the response

**Scenario 7 — Trip detail not found or wrong owner**
- Given the rider requests a trip ID that does not exist or belongs to a different rider
- When the endpoint processes the request
- Then a not-found or forbidden error is returned

**Scenario 8 — Unauthenticated request is rejected**
- Given no valid session token is provided
- Then the request is rejected with an authentication error

### Dependencies
- #1744 — Session validation (must be live)

---

## [API] #1714 — Rider retrieves past trip detail 🆕
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As the rider app, I want to retrieve the full details of a single past trip so that the trip detail screen can display the complete fare breakdown, addresses, driver information, and rating.

### Background
Called when a rider taps a row in her trip history list (#1567). The endpoint returns the full detail record for a single completed trip owned by the authenticated rider. The response includes all fields needed to populate the trip detail screen: date and time, pickup and destination addresses, fare breakdown (base fee + distance charge + time charge + total in EGP), trip duration (minutes), distance (km), driver name, vehicle details, and the rider's submitted rating if one exists. If the rider skipped the rating, the rating field is null or absent.

### Acceptance Criteria

**Scenario 1 — Rider retrieves detail of a rated completed trip**
- Given the authenticated rider requests the detail for a past trip she rated
- When the endpoint processes the request
- Then the response includes: trip date and time, pickup address, destination address, total fare (EGP), fare breakdown (base fee, distance charge, time charge), trip duration (minutes), distance (km), driver name, vehicle make, model, color, plate number, star rating submitted, and any tags selected

**Scenario 2 — Rider retrieves detail of an unrated or skipped trip**
- Given the authenticated rider requests the detail for a past trip she did not rate or skipped
- When the endpoint processes the request
- Then all trip detail fields are returned as in Scenario 1
- And the rating field is null or absent in the response

**Scenario 3 — Trip ID not found or belongs to a different rider**
- Given the rider requests a trip ID that does not exist or belongs to a different rider
- When the endpoint processes the request
- Then a not-found or forbidden error is returned
- And no trip data is disclosed

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- Then the request is rejected with an authentication error

### Out of Scope
- Submitting or editing a rating from this endpoint
- Fare dispute submission
- Contacting the driver

### Dependencies
- #1744 — Session validation (must be live)
- #1636 — Final fare calculation (fare breakdown source)
- #1639 — Rider submits driver rating (rating data source)

---

## [API] #1655 — Driver retrieves trip history
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As the driver app, I want to retrieve a paginated list of the authenticated driver's completed trips so that the trip history screen can display accurate trip data.

### Acceptance Criteria

**Scenario 1 — Driver with completed trips retrieves page one**
- Given the driver is authenticated and has completed trips
- When the driver app requests page one of trip history
- Then the response contains a list of completed trips ordered by date descending
- And each item includes: trip ID, date, destination area, and cash fare collected (EGP)
- And pagination metadata is included

**Scenario 2 — Driver with no completed trips retrieves history**
- Given the driver is authenticated and has no completed trips
- Then the response contains an empty list with pagination metadata reflecting zero records

**Scenario 3 — Driver requests a subsequent page**
- Given the driver has trips spanning multiple pages
- When the driver app requests page two
- Then the response contains the correct slice of trips

**Scenario 4 — Driver retrieves individual trip detail**
- Given the driver requests a specific completed trip by ID
- When the endpoint processes the request
- Then the response includes: trip date, pickup address, destination address, fare collected (EGP), trip duration (minutes), distance (km), and rider rating if submitted

**Scenario 5 — Rider rating is included in detail if submitted**
- Given the rider submitted a rating for the trip
- When the driver retrieves that trip's detail
- Then the star rating and any selected tags are included in the response

**Scenario 6 — Trip shows unrated when rider did not rate**
- Given the rider skipped or did not submit a rating for the trip
- When the driver retrieves that trip's detail
- Then the rating field shows "لم يتم التقييم" (Not Rated) or equivalent null/unrated value

**Scenario 7 — Trip detail not found or wrong owner**
- Given the driver requests a trip ID that does not exist or belongs to a different driver
- When the endpoint processes the request
- Then a not-found or forbidden error is returned

**Scenario 8 — Unauthenticated request is rejected**
- Given no valid session token is provided
- Then the request is rejected with an authentication error

### Dependencies
- #1744 — Session validation (must be live)

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
- #1744 — Session validation (must be live)
- #1636 — Final fare calculation (fare data source)
- #1639 — Rider submits driver rating (rating data source)

---

### Feature 13 — Admin Rider Management API

---

## [API] #1663 — Rider list with search and filters is served
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, searchable list of riders to the admin portal so that operations admins can browse and locate rider accounts.

### Acceptance Criteria

**Scenario 1 — Admin requests the full rider list**
- Given the admin is authenticated and sends no search parameter
- When the rider list endpoint is called
- Then a paginated list of all riders is returned ordered by registration date descending
- And each record includes: rider ID, full name, phone number, registration date, and completed trip count
- And pagination metadata (page, total pages, total count) is included

**Scenario 2 — Admin requests the list with a name search**
- Given the admin sends a search parameter containing a name substring
- Then only riders whose name contains that substring (case-insensitive) are returned

**Scenario 3 — Admin requests the list with a phone search**
- Given the admin sends a search parameter containing a phone substring
- Then only riders whose phone number contains that substring are returned

**Scenario 4 — Search returns no matching riders**
- Given the admin sends a search parameter that matches no rider
- Then an empty list is returned with total count zero

**Scenario 5 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected with an authentication error

**Scenario 6 — Admin requests a subsequent page**
- Given there are more riders than fit on one page
- When the admin requests page two
- Then the correct slice of rider records for that page is returned

### Dependencies
- #1744 — Session validation (must be live)

---

## [API] #1664 — Rider profile with trip history is served
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single rider's profile and paginated trip history to the admin portal so that operations admins can review full account details.

### Acceptance Criteria

**Scenario 1 — Admin requests a valid rider profile**
- Given the admin is authenticated and provides a valid rider ID
- When the rider profile endpoint is called
- Then the response includes: full name, phone number, registration date, total trips completed, last trip date, account status
- And a paginated list of the rider's past trips is included

**Scenario 2 — Rider has no past trips**
- Given the admin requests the profile of a rider with no completed trips
- Then the profile fields are returned normally and the trip history list is empty

**Scenario 3 — Admin requests a non-existent rider ID**
- Given the admin provides a rider ID that does not exist
- Then a not-found response is returned

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected

**Scenario 5 — Admin requests a subsequent page of trip history**
- Given the rider has more trips than fit on one page
- When the admin requests page two
- Then the correct page of trip records is returned in date descending order

### Dependencies
- #1744 — Session validation (must be live)
- #1641 — Rider retrieves trip history (must be live)

---

### Feature 14 — Admin Driver Management API

---

## [API] #1667 — Driver list with status filter and search is served
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, filterable list of driver accounts to the admin portal so that operations admins can browse the full driver pipeline by status.

### Acceptance Criteria

**Scenario 1 — Admin requests the full driver list**
- Given the admin is authenticated and sends no filter or search parameter
- When the driver list endpoint is called
- Then a paginated list of all driver accounts is returned ordered by submission date descending
- And each record includes: driver ID, name, phone, status, submission date, and completed trip count

**Scenario 2 — Admin filters by status**
- Given the admin sends a status parameter of "pending", "approved", or "rejected"
- Then only drivers matching that status are returned

**Scenario 3 — Admin searches by name**
- Given the admin sends a search parameter containing a name substring
- Then only drivers whose name contains that substring (case-insensitive) are returned

**Scenario 4 — Admin searches by phone**
- Given the admin sends a search parameter containing a phone substring
- Then only drivers whose phone contains that substring are returned

**Scenario 5 — Filter and search return no results**
- Given the admin sends parameters that match no driver
- Then an empty list is returned with total count zero

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected

**Scenario 7 — Admin requests a subsequent page**
- Given there are more drivers than fit on one page
- When the admin requests page two
- Then the correct slice of driver records is returned

### Dependencies
- #1744 — Session validation (must be live)

---

## [API] #1668 — Driver profile with trip history is served
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single driver's full profile and paginated trip history to the admin portal so that operations admins can review complete driver account details.

### Background
Returns personal details, vehicle information, document URLs (for inline display), profile photo URL (#1686), current status, average rating, decision history, and a paginated slice of the driver's completed trip history.

### Acceptance Criteria

**Scenario 1 — Admin requests a valid driver profile**
- Given the admin is authenticated and provides a valid driver ID
- When the driver profile endpoint is called
- Then the response includes: personal details (name, phone, date of birth, masked national ID), vehicle details, document image URLs, vehicle photo URL, profile photo URL, current status, total trips completed, average rider rating, and decision history records
- And a paginated list of completed trips is included

**Scenario 2 — Driver has no completed trips**
- Given the admin requests the profile of a driver with no completed trips
- Then the profile fields are returned normally and the trip history list is empty

**Scenario 3 — Admin requests a non-existent driver ID**
- Given the admin provides a driver ID that does not exist
- Then a not-found response is returned

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected

### Dependencies
- #1744 — Session validation (must be live)

---

### Feature 15 — Admin Operations Dashboard API

---

## [API] #1673 — Dashboard summary is served ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve live platform metric counts to the admin portal so that the dashboard can display accurate, up-to-date operational summaries.

### Background
Called by the admin portal on initial load and every 30 seconds thereafter. Computes and returns **four** live counts at request time: active trips, online drivers, trips created today, and total registered riders. No caching is required — data is computed fresh on each call.

### Acceptance Criteria

**Scenario 1 — Admin portal requests the dashboard summary**
- Given the admin is authenticated
- When the dashboard summary endpoint is called
- Then the response includes:
  - `active_trips` — count of trips in any active state (matched, accepted, en_route_pickup, arrived_pickup, trip_started)
  - `online_drivers` — count of drivers currently available (status = online)
  - `trips_today` — count of trips created since midnight local time
  - `total_riders` — count of all registered riders
- And all counts are integers ≥ 0

**Scenario 2 — All metrics are zero on an idle day**
- Given no trips are active, no drivers are online, and no trips created today
- When the endpoint is called
- Then all counts return as zero

**Scenario 3 — Counts reflect the current state**
- Given a trip transitions to active status between two calls to the endpoint
- When the endpoint is called after the transition
- Then the active_trips count is incremented accordingly

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected with an authentication error

### Out of Scope
- Historical time-series data
- Per-city or per-zone breakdowns
- Caching or pre-computation
- Total approved drivers metric (deferred)

### Dependencies
- #1744 — Session validation (must be live)

---

## [API] #1674 — Trip list with pagination and filters is served ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, filterable list of all trips to the admin portal so that operations admins can monitor platform activity and find specific trips.

### Background
Called when the admin opens the Trips section and on each filter change, search input, or page change. Optional parameters: status filter, date range, and search string. Default order is creation date descending with a page size of 20.

**Status filter → state machine mapping:**
| UI Filter | Underlying trip states |
|---|---|
| Searching | `searching` |
| Active | `matched`, `accepted`, `en_route_pickup`, `arrived_pickup`, `trip_started` |
| Completed | `trip_ended` |
| Expired | `expired` (all sub-reasons: no_driver, system_timeout, gender_mismatch_report) |

### Acceptance Criteria

**Scenario 1 — Admin requests the full trip list**
- Given the admin is authenticated and sends no filter parameters
- When the trip list endpoint is called
- Then a paginated list of all trips is returned ordered by creation date descending
- And each record includes: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, null for non-completed trips), and creation date
- And pagination metadata (page, total pages, total count) is included

**Scenario 2 — Admin filters by status**
- Given the admin sends a status parameter (e.g., "active")
- Then only trips whose underlying state(s) match that filter bucket are returned (see mapping above)

**Scenario 3 — Admin filters by date range**
- Given the admin sends a from-date and a to-date
- Then only trips created within that date range (inclusive) are returned

**Scenario 4 — Admin searches by rider or driver name**
- Given the admin sends a search parameter
- Then trips where the rider name, driver name, rider phone, or driver phone contains that substring are returned

**Scenario 5 — Filters return no results**
- Given the admin sends parameters that match no trip
- Then an empty list is returned with total count zero

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected with an authentication error

**Scenario 7 — Admin requests a subsequent page**
- Given there are more trips than fit on one page
- When the admin requests page two
- Then the correct slice of trip records is returned maintaining the applied filters and sort order

### Dependencies
- #1744 — Session validation (must be live)

---

## [API] #1675 — Trip detail with state history is served ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single trip's full details and state transition history to the admin portal so that operations admins can investigate the full lifecycle of any trip.

### Background
Called when the admin clicks a trip row in the trip list. Returns all information needed to render the trip detail screen: rider and driver information, addresses, all state transition records with timestamps (sourced from the `trip_state_history` table written by #1652 Scenario 6), and — if the trip is completed — the fare breakdown and rider rating.

**Note on state history:** The `trip_state_history` table (required by #1652 Scenario 6) records every state transition with timestamp and actor. This endpoint reads from that table to build the timeline. Without it, the timeline cannot be served.

### Acceptance Criteria

**Scenario 1 — Admin requests details of an in-progress trip**
- Given the admin is authenticated and provides a valid trip ID for an active trip
- When the trip detail endpoint is called
- Then the response includes: rider info (name, phone), driver info (name, phone, vehicle), pickup address, destination address, and a list of all state transitions with timestamps up to the current state

**Scenario 2 — Admin requests details of a completed trip**
- Given the admin provides a valid trip ID for a completed trip
- Then all fields from Scenario 1 are returned plus: fare breakdown (base, distance, time, total, cash collected) and rider rating (stars and tags if rated, null if not rated)

**Scenario 3 — Admin requests details of an expired trip**
- Given the admin provides a valid trip ID for an expired trip
- Then rider info, addresses, and the state transitions up to "Expired" with timestamps are returned
- And driver info is null if no driver was matched
- And the expiry reason (no_driver, system_timeout, or gender_mismatch_report) is indicated

**Scenario 4 — Admin requests a non-existent trip ID**
- Given the admin provides a trip ID that does not exist
- Then a not-found response is returned

**Scenario 5 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- Then the request is rejected with an authentication error

### Out of Scope
- Modifying trip status via this endpoint
- Real-time streaming of state changes
- SOS event records

### Dependencies
- #1744 — Session validation (must be live)
- #1652 — Driver advances trip state machine (all transitions must be logged to trip_state_history — must be live)

---

## [API] #1721 — Rider views and edits her profile 🆕
**Feature:** Feature 4 — Authentication API | **Sprint:** 2

**Description:** As the rider app, I want to retrieve and update the rider's profile information so that she can manage her account details.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error |
|---|---|---|---|---|---|---|
| name | No (on update) | Free text | 2 chars | 50 chars | Arabic, Latin, spaces | Return validation error |

### Acceptance Criteria

**Scenario 1 — Rider retrieves her profile**
- Given an authenticated rider calls this endpoint with no request body
- When the endpoint processes the request
- Then the response includes: full name, phone number, email (if set), language preference, and registration date

**Scenario 2 — Rider updates her name**
- Given an authenticated rider submits a valid name (2–50 chars, letters and spaces only)
- When the endpoint processes the request
- Then the name is updated on the user record
- And the response confirms the update

**Scenario 3 — Invalid name format**
- Given an authenticated rider submits a name with digits or special characters
- When the endpoint processes the request
- Then a validation error is returned

**Scenario 4 — Unauthenticated request**
- Given no valid session token is provided
- Then the request is rejected

### Out of Scope
- Phone number change
- Email change or verification
- Photo upload

### Dependencies
- #1744 — Session validation

---

## [API] #1728 — User changes language preference from profile screen 🆕
**Feature:** Feature 4 — Authentication API | **Sprint:** 2

**Description:** As the platform, I want to store and retrieve a user's language preference so that the app displays content in the user's chosen language across sessions.

### Field Validation

| Field | Required | Format | Error |
|---|---|---|---|
| language | Yes | Enum: "ar" or "en" | Return validation error if not "ar" or "en" |

### Acceptance Criteria

**Scenario 1 — User sets language preference**
- Given an authenticated user submits a language value ("ar" or "en")
- When the endpoint processes the request
- Then the language preference is stored on the user record
- And the response confirms the update

**Scenario 2 — User retrieves language preference**
- Given an authenticated user calls this endpoint (GET)
- When the endpoint processes the request
- Then the response includes the user's language preference
- And defaults to "ar" if no preference is set

**Scenario 3 — Invalid language value**
- Given an authenticated user submits a language value other than "ar" or "en"
- When the endpoint processes the request
- Then a validation error is returned

**Scenario 4 — Preference persists across sessions**
- Given a user has set a language preference
- When the user closes and reopens the app and logs in again
- Then the app retrieves the stored preference and displays content in that language

**Scenario 5 — Unauthenticated request**
- Given no valid session token is provided
- Then the request is rejected

### Out of Scope
- Device language auto-detection
- Regional language variants
- Automatic language switching based on device settings

### Dependencies
- #1744 — Session validation

---

## [API] #1739 — Account suspension status is updated by admin 🆕
**Feature:** Feature 13 — Admin Rider Management API | **Sprint:** 2

**Description:** As the admin, I want to update a rider's or driver's account suspension status so that I can manage account sanctions.

### Background
Called by the admin portal to update user suspension status. Can suspend or reinstate (lift suspension). When a user is suspended, their sessions are invalidated and they cannot authenticate. When reinstated, they can log in again.

### Field Validation

| Field | Required | Format | Error |
|---|---|---|---|
| status | Yes | Enum: "pending_review", "active", "suspended" | Return validation error |
| user_id | Yes | Valid UUID | Return not-found error if user doesn't exist |

### Acceptance Criteria

**Scenario 1 — Admin suspends a rider**
- Given an admin submits status = "suspended" for a rider user_id
- When the endpoint processes the request
- Then the user record is updated to suspended status
- And all sessions for that user are invalidated
- And the rider cannot log in

**Scenario 2 — Admin reinstates a rider**
- Given an admin submits status = "active" for a suspended rider
- When the endpoint processes the request
- Then the user record is updated to active status
- And the rider can log in again

**Scenario 3 — User not found**
- Given an admin submits a user_id that does not exist
- When the endpoint processes the request
- Then a not-found error is returned

**Scenario 4 — Admin authentication required**
- Given the request does not include valid admin credentials
- Then the request is rejected

### Out of Scope
- Batch suspension/reinstatement
- Suspension reason collection
- User notification of suspension

### Dependencies
- #1744 — Session validation
- #1687 — Rider account is suspended after gender mismatch report

---

## [API] #1761 — System resolves pickup coordinates to zone and rate card 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 2

**Description:** As the fare calculation service, I need to resolve any pickup latitude/longitude to the correct service zone and return the associated rate card so that every fare estimate and confirmed trip uses the right pricing.

### Background
The pricing system is zone-based. When a fare estimate or trip confirmation is requested, the first step is to identify which zone the pickup coordinates fall in. The origin zone's rate card applies for the entire trip. If the coordinates fall inside multiple overlapping zones, the smallest (most specific) zone applies. If the coordinates fall outside all defined zones, the trip is blocked — there is no fallback zone.

### Acceptance Criteria

**Scenario 1 — Coordinates match a single zone**
- Given a set of pickup coordinates that fall within exactly one defined zone
- When the zone-lookup endpoint is called with those coordinates
- Then the response includes: zone ID, zone name, and the full rate card (base fare, per-km rate, per-min rate, minimum fare, cancellation fee)

**Scenario 2 — Coordinates fall in overlapping zones**
- Given pickup coordinates that fall within two or more overlapping zones
- When the zone-lookup endpoint is called
- Then the smallest-area zone is selected and its rate card is returned

**Scenario 3 — Coordinates outside all zones**
- Given pickup coordinates that fall outside every defined zone
- When the zone-lookup endpoint is called
- Then the response is HTTP 422 with error code `PICKUP_OUTSIDE_SERVICE_AREA`

**Scenario 4 — Zone exists but has no rate card**
- Given pickup coordinates that match a zone with no rate card configured
- When the zone-lookup endpoint is called
- Then the response is HTTP 422 with error code `ZONE_RATE_CARD_MISSING`

**Scenario 5 — Coordinates are missing or malformed**
- Given a request with missing or non-numeric lat/lng values
- Then the response is HTTP 400 with a validation error message

### Out of Scope
- Time-of-day multipliers
- Surge pricing

### Dependencies
- #1756 — Super admin manages service zones
- #1757 — Super admin configures zone rate card

---

## [API] #1762 — Fare calculation enforces minimum fare 🆕
**Feature:** Feature 7 — Rider Home, Address Search & Fare Estimate | **Sprint:** 2

**Description:** As the fare calculation service, I need to ensure that the computed trip fare never falls below the zone's minimum fare so that drivers are always guaranteed a floor income and short trips are priced correctly.

### Background
The base fare formula is: total = base_fare + (distance_km × per_km_rate) + (duration_min × per_min_rate). VAT is included in all rate card values — no VAT is added on top. The minimum fare is a floor: if the formula result is less than the zone's minimum fare, the minimum fare is charged instead. The fare returned is always VAT-inclusive and rounded to 2 decimal places.

### Acceptance Criteria

**Scenario 1 — Formula result exceeds minimum fare**
- Given a 10 km, 20 min trip in a zone with base fare 15 EGP, per-km rate 3 EGP, per-min rate 0.5 EGP, minimum fare 20 EGP
- When the fare is calculated: 15 + (10×3) + (20×0.5) = 15 + 30 + 10 = 55 EGP
- Then the returned fare is 55 EGP

**Scenario 2 — Formula result is below minimum fare**
- Given a 1 km, 3 min trip in the same zone (formula: 15 + 3 + 1.5 = 19.5 EGP)
- When the fare is calculated
- Then the returned fare is 20 EGP (minimum fare applies)

**Scenario 3 — Formula result exactly equals minimum fare**
- Given a trip where the formula result equals the minimum fare exactly
- Then the returned fare equals the minimum fare

**Scenario 4 — Fare is VAT-inclusive**
- Given any calculated fare
- Then the fare returned in the API response is the total amount the rider pays — no additional VAT is added
- And the fare field in the response is labelled as VAT-inclusive

**Scenario 5 — Fare response format**
- The fare response includes: total_fare (EGP, 2 decimal places), zone_id, zone_name, distance_km, duration_min, minimum_fare_applied (boolean)

### Out of Scope
- Itemised fare breakdown shown to the rider (total only per design decision)
- Surge pricing

### Dependencies
- #1761 — System resolves pickup coordinates to zone and rate card

---

## [API] #1763 — Trip request is blocked if pickup is outside all service zones 🆕
**Feature:** Feature 8 — Trip Request & Matching API | **Sprint:** 2

**Description:** As the trip request service, I need to reject trip requests whose pickup location falls outside all defined service zones so that the platform never accepts a booking it cannot price or dispatch.

### Background
There is no fallback zone. If a rider's pickup coordinates do not fall inside any defined and configured zone, the trip must be blocked at the request stage — not silently re-routed or accepted with an error later. This check happens at both the fare estimate step and the trip confirmation step so the rider receives early feedback. The same error code is used in both places for consistency.

### Acceptance Criteria

**Scenario 1 — Trip request blocked at fare estimate**
- Given a rider submits a pickup location outside all service zones
- When the fare estimate endpoint is called
- Then the response is HTTP 422 with error code `PICKUP_OUTSIDE_SERVICE_AREA`
- And the rider app shows a message that pickup is outside the available service area

**Scenario 2 — Trip request blocked at confirmation**
- Given a rider proceeds to confirm a trip with a pickup location outside all service zones
- When the trip creation endpoint is called
- Then the response is HTTP 422 with error code `PICKUP_OUTSIDE_SERVICE_AREA`
- And the trip is not created

**Scenario 3 — Trip request proceeds for in-zone pickup**
- Given a rider submits a pickup location inside a valid, configured zone
- When the fare estimate or trip creation endpoint is called
- Then the request proceeds normally and no zone error is returned

**Scenario 4 — Zone deleted while rider is on booking screen**
- Given a rider has a valid fare estimate for a zone that is subsequently deleted by an admin
- When the rider confirms the trip
- Then the trip creation endpoint returns HTTP 422 with error code `PICKUP_OUTSIDE_SERVICE_AREA`
- And the rider app handles this error gracefully with a user-visible message

### Out of Scope
- Destination-based zone blocking (origin zone only)
- Waiting lists or service-area expansion notifications

### Dependencies
- #1761 — System resolves pickup coordinates to zone and rate card
- #1756 — Super admin manages service zones

---

## [API] #1764 — Cancellation fee is charged after grace period 🆕
**Feature:** Feature 8 — Trip Request & Matching API | **Sprint:** 2

**Description:** As the trip service, I need to apply a cancellation fee when a rider cancels after the grace period expires so that drivers are compensated for lost time and riders are discouraged from late cancellations.

### Background
The cancellation fee is the fixed EGP amount set in the zone's rate card. The grace period is the global setting (e.g. 3 minutes) configured by the super admin. The clock starts when the driver accepts the trip. If the rider cancels before the grace period expires, no fee is charged. If she cancels after, the fee is charged and split between the driver and the platform using the globally configured driver share percentage. The fee and split percentages used are those active at the time of driver acceptance — not at the time of cancellation. Cancellation by the driver never triggers a fee to the rider.

### Acceptance Criteria

**Scenario 1 — Rider cancels within grace period**
- Given a driver has accepted and the grace period has not yet expired
- When the rider cancels
- Then no cancellation fee is charged
- And the trip record is marked: cancelled_by=rider, fee_charged=false

**Scenario 2 — Rider cancels after grace period expires**
- Given a driver has accepted and the grace period has expired
- When the rider cancels
- Then the cancellation fee for that zone is charged to the rider
- And the fee is split using the driver share percentage active at driver acceptance time
- And the trip record is marked: cancelled_by=rider, fee_charged=true, fee_amount, driver_share_amount, platform_share_amount

**Scenario 3 — Driver cancels — no fee to rider**
- Given a driver cancels at any time
- Then no cancellation fee is charged to the rider

**Scenario 4 — Policy changes during active trip**
- Given the grace period or driver share is updated by an admin after a driver has accepted
- Then the trip uses the policy values that were active at the time of driver acceptance

**Scenario 5 — Cancellation before driver acceptance**
- Given a rider cancels while the trip is still in the matching phase (no driver accepted yet)
- Then no cancellation fee is charged regardless of how long the rider waited

### Out of Scope
- Driver cancellation compensation (Phase 2)
- Rider dispute flow for cancellation fees (Phase 2)

### Dependencies
- #1757 — Super admin configures zone rate card (cancellation fee amount lives here)
- #1758 — Super admin configures cancellation policy (grace period and split live here)

---

## [API] #1765 — Platform commission is deducted on trip completion 🆕
**Feature:** Feature 11 — Trip Completion & Cash Payment API | **Sprint:** 2

**Description:** As the trip completion service, I need to calculate and record the platform commission deduction so that driver net earnings are accurate and the platform's revenue is tracked for every completed trip.

### Background
Commission is a single global percentage set by the super admin. It is applied to the total trip fare at trip completion. The commission rate used is the one active at the time the trip was booked (matching accepted), not the rate at completion time. Both the gross fare, commission amount, and driver net earnings are stored on the trip record. Commission is never shown as a line item to the rider — she sees the total only. The driver sees her net earnings (not the commission percentage).

### Acceptance Criteria

**Scenario 1 — Commission is calculated and stored on completion**
- Given a trip completes with a total fare of 100 EGP and a commission rate of 20%
- Then the trip record stores: total_fare=100, commission_rate=20, commission_amount=20, driver_net_earnings=80

**Scenario 2 — Commission rate snapshot is taken at booking time**
- Given the commission rate is 20% when a driver accepts a trip
- And the super admin changes the commission rate to 25% before the trip completes
- When the trip completes
- Then commission is calculated at 20% (the rate at acceptance time)

**Scenario 3 — Commission is not shown to the rider**
- Given a completed trip
- When the rider views her trip receipt
- Then she sees only the total fare — no commission breakdown

**Scenario 4 — Net earnings are correctly computed on cancellation fee trips**
- Given a trip that was cancelled with a fee charged
- Then commission is NOT deducted from the cancellation fee — the driver receives her full driver-share of the cancellation fee as configured

### Out of Scope
- Payout disbursement to drivers (wallet/bank integration)
- Commission reporting dashboard (separate admin story)

### Dependencies
- #1759 — Super admin configures platform commission
- #1762 — Fare calculation enforces minimum fare

---

### Feature 17 — Payments API

---

## [API] #1730 — Rider selects a payment method 🆕
**Feature:** Feature 17 — Payments API | **Sprint:** 2

**Description:** As the rider app, I want to store the rider's preferred payment method so that it is used as the default for future trips.

### Field Validation

| Field | Required | Format | Error |
|---|---|---|---|
| payment_method | Yes | Enum: "cash" or "card" | Return validation error |

### Acceptance Criteria

**Scenario 1 — Rider selects cash**
- Given an authenticated rider submits payment_method = "cash"
- When the endpoint processes the request
- Then the payment method is stored as the user's default
- And the response confirms the update

**Scenario 2 — Rider selects card**
- Given an authenticated rider submits payment_method = "card"
- When the endpoint processes the request
- Then the payment method is stored as the user's default

**Scenario 3 — Preference is retrieved**
- Given an authenticated rider calls this endpoint (GET)
- When the endpoint processes the request
- Then the response includes the user's stored payment method
- And defaults to "cash" if no preference is set

**Scenario 4 — Invalid payment method**
- Given an authenticated rider submits a value other than "cash" or "card"
- When the endpoint processes the request
- Then a validation error is returned

**Scenario 5 — Unauthenticated request**
- Given no valid session token is provided
- Then the request is rejected

### Out of Scope
- Card tokenization or payment processing
- Multiple payment method management

### Dependencies
- #1744 — Session validation

---

## [API] #1733 — Rider completes online card payment at trip end 🆕
**Feature:** Feature 17 — Payments API | **Sprint:** 2

**Description:** As the platform, I want to charge the rider's card for the trip fare at completion so that the rider can pay without cash.

### Background
Called internally when a trip with card payment method reaches trip_ended state and the fare has been calculated via #1636. The payment processor gateway is called to charge the rider's card. Success or failure is recorded on the trip.

### Acceptance Criteria

**Scenario 1 — Card payment succeeds**
- Given a trip with card payment method has reached trip_ended state
- When the platform processes the charge via the payment gateway
- Then the card is charged the final fare amount
- And the trip record is marked payment_status = succeeded

**Scenario 2 — Card payment fails**
- Given the payment gateway returns a decline or error
- When the platform processes the failure
- Then the trip record is marked with the failure reason
- And the rider is notified via push

**Scenario 3 — Charge amount matches calculated fare**
- Given the fare has been calculated via #1636
- When the charge is processed
- Then the amount charged exactly matches the stored fare

### Out of Scope
- Partial refunds
- Payment receipt generation
- Retry logic (configured in payment processor)

### Dependencies
- #1636 — Final fare calculation
- #1652 — Driver advances trip state machine

---

### Feature 18 — Driver Earnings API

---

## [API] #1735 — Driver views earnings dashboard 🆕
**Feature:** Feature 18 — Driver Earnings API | **Sprint:** 2

**Description:** As the driver app, I want to retrieve a summary of the driver's earnings for different time periods so that she can track her income.

### Background
Returns aggregated earnings data for the driver including total earnings for today, this week, this month; trip count for each period; average rating; and acceptance/rejection rate for available trip requests.

### Acceptance Criteria

**Scenario 1 — Earnings summary retrieved**
- Given an authenticated driver calls this endpoint
- When the endpoint processes the request
- Then the response includes: today's earnings (EGP), week's earnings (EGP), month's earnings (EGP), trips completed today/week/month, average rating, and acceptance rate

**Scenario 2 — No trips completed**
- Given a driver has no completed trips in the requested period
- When the endpoint processes the request
- Then all earnings and trip counts show 0
- And average rating shows N/A or 0

**Scenario 3 — Unauthenticated request**
- Given no valid driver session token is provided
- Then the request is rejected

### Out of Scope
- Historical earnings export
- Detailed earnings breakdown by trip type
- Earnings predictions

### Dependencies
- #1744 — Session validation
- #1655 — Driver retrieves trip history (data source for aggregations)

---

### Feature 19 — Scheduled Rides API

---

## [API] #1738 — Rider schedules a ride in advance 🆕
**Feature:** Feature 19 — Scheduled Rides API | **Sprint:** 2

**Description:** [TBD - Placeholder for future scheduled trip functionality.]

### Background
[TBD]

### Acceptance Criteria

**Scenario 1 — [TBD]**
- [TBD]

### Out of Scope
- [TBD]

### Dependencies
- [TBD]

---

### Feature 20 — Trip Cancellation API

---

## [API] #1715 — Rider cancels a trip 🆕
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** 2

**Description:** As the rider app, I want to submit a cancellation request for an active trip so that the rider can cancel before a driver accepts or arrives.

### Background
Called when the rider taps "Cancel" and confirms on the matching screen or active trip screen (while in matched or accepted states). The endpoint cancels the trip, sets fare to 0, and immediately returns the trip to available status.

### Acceptance Criteria

**Scenario 1 — Trip cancellation is accepted**
- Given an authenticated rider submits a cancellation for a trip in searching, matched, or accepted state
- When the endpoint processes the request
- Then the trip status is updated to cancelled
- And fare is set to 0
- And the response indicates success

**Scenario 2 — Trip already completed**
- Given a rider attempts to cancel a trip that is already in trip_started, trip_ended, or expired state
- When the endpoint processes the request
- Then a conflict error is returned

**Scenario 3 — Unauthenticated request**
- Given no valid rider session token is provided
- Then the request is rejected with authentication error

### Out of Scope
- Cancellation penalties or fees
- Cancellation reason collection
- Driver notification of cancellation

### Dependencies
- #1744 — Session validation

---

## [API] #1720 — Driver cancels an accepted trip 🆕
**Feature:** Feature 20 — Trip Cancellation API | **Sprint:** 2

**Description:** As the driver app, I want to submit a cancellation request for an accepted trip so that I can cancel before the rider is boarded.

### Background
Called when the driver taps "Cancel" and confirms on the active trip screen while the trip is in accepted, en_route_pickup, or arrived_pickup state. The endpoint cancels the trip, sets the driver's availability back to available, and sets fare to 0.

### Acceptance Criteria

**Scenario 1 — Trip cancellation is accepted**
- Given an authenticated driver submits a cancellation for a trip in accepted, en_route_pickup, or arrived_pickup state
- When the endpoint processes the request
- Then the trip status is updated to cancelled
- And driver availability is reset to available
- And fare is set to 0

**Scenario 2 — Trip already started**
- Given a driver attempts to cancel a trip that is already in trip_started or trip_ended state
- When the endpoint processes the request
- Then a conflict error is returned

**Scenario 3 — Unauthenticated request**
- Given no valid driver session token is provided
- Then the request is rejected

### Out of Scope
- Cancellation penalties for drivers
- Reason collection
- Rider notification

### Dependencies
- #1744 — Session validation

---

### Feature 21 — Emergency & Safety API

---

## [API] #1687 — Rider account is suspended after gender mismatch report 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** As the SheDrive platform, I want to suspend a rider's account and cancel the active trip when a driver reports the rider does not appear to be female so that the women-only service guarantee and platform safety are maintained.

### Background
Called by the driver app when the driver taps "Cancel — Rider Not Female" during the first-trip verification step (#1588). The platform immediately: (1) cancels the active trip with reason "gender_mismatch_report" and fare = 0, (2) suspends the rider's account with status "pending_review", (3) sets the driver availability back to "available", (4) creates an internal operations alert for manual review. The operations team can lift the suspension after investigation.

### Acceptance Criteria

**Scenario 1 — Driver reports non-female rider**
- Given a driver has an active trip in arrived_pickup state and submits a gender mismatch report
- Then the trip is cancelled with reason "gender_mismatch_report" and fare = EGP 0
- And rider account status is set to "pending_review" (suspended)
- And driver availability is set to "available"
- And an internal operations alert is created

**Scenario 2 — Rider session rejected while suspended**
- Given the rider's account is pending_review
- When the rider makes any authenticated request
- Then an account-suspended error is returned

**Scenario 3 — No fare charged**
- Given the trip was cancelled by this endpoint
- Then fare = EGP 0 and no cash collection screen appears

**Scenario 4 — Unauthenticated request rejected**
- Given no valid driver auth token
- Then HTTP 401 is returned

**Scenario 5 — Trip not in arrived_pickup state**
- Given the trip is in any state other than arrived_pickup
- Then a conflict error is returned

### Out of Scope
- Admin review UI for suspensions (future sprint)
- Rider appeal or reinstatement flow
- Driver penalty for false reports

### Dependencies
- #1744 — Session validation
- #1652 — Driver advances trip state machine

---

## [API] #1725 — Rider triggers SOS during active trip 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** [TBD - Placeholder for future SOS submission functionality.]

### Background
[TBD]

### Acceptance Criteria

**Scenario 1 — [TBD]**
- [TBD]

### Out of Scope
- [TBD]

### Dependencies
- [TBD]

---

## [API] #1727 — Driver is notified when a rider triggers SOS during active trip 🆕
**Feature:** Feature 21 — Emergency & Safety API | **Sprint:** 2

**Description:** [TBD - Placeholder for future SOS notification functionality.]

### Background
[TBD]

### Acceptance Criteria

**Scenario 1 — [TBD]**
- [TBD]

### Out of Scope
- [TBD]

### Dependencies
- [TBD]
