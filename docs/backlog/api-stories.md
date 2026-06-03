# SheDrive — API Stories
> Canonical backlog for all [API] stories. Organized by sprint and feature.
> Last updated: 2026-06-03
> Stories with changes from original are marked ✏️ | New stories marked 🆕

---

## Sprint 1

### Feature 1 — Platform & Integration Foundation

---

## [API] #1616 — SMS gateway delivers OTP to Egyptian mobile numbers
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want an SMS gateway integrated and verified for Egyptian mobile numbers so that all OTP flows can reliably deliver codes to riders and drivers.

### Background
The SMS gateway (e.g., Unifonic or Vonage) is configured as the delivery channel for all one-time passcodes. It is invoked internally whenever #1620 receives a valid OTP request. The integration must support Egyptian mobile numbers across all four carrier prefixes (010 Vodafone, 011 Etisalat/e&, 012 Orange, 015 WE). The gateway is considered live when a test OTP is successfully received on a real Egyptian SIM within 15 seconds.

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
- Given the SMS gateway returns a delivery failure response
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

### Dependencies
- None (foundational integration story)

---

## [API] #1617 — Google Maps returns route distance and duration
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want the Google Maps Distance Matrix / Directions API integrated and returning route data for Cairo/Giza coordinates so that fare estimation and active-trip screens can display accurate distances and durations.

### Background
The Google Maps Distance Matrix and/or Directions API is the platform's sole source of route distance and estimated travel duration. It is called server-side when a rider submits a trip request and for fare estimation. ETA computation for the rider app is handled client-side via the Maps SDK on the mobile device. The integration must operate correctly for origin/destination pairs within Cairo and Giza governorates.

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

### Dependencies
- None (foundational integration story)

---

## [API] #1618 — Push notification service delivers to iOS and Android ✏️
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want FCM (Android) and APNs (iOS) integrations configured and verified so that all push notifications are reliably delivered to rider and driver devices.

### Background
The push notification service acts as the real-time channel from the platform to rider and driver apps. FCM is used for Android devices and APNs for iOS devices. Device tokens are registered via #1625 immediately after login or registration. The service is invoked whenever the platform needs to notify a driver of a new trip request, notify a rider of driver acceptance or arrival, or deliver any other in-app alert.

**Bilingual delivery requirement:** All push notification text dispatched by the platform must be rendered in the recipient user's preferred language (`shedrive.lang` = "ar" or "en"). Arabic is used as the default when no preference is stored. The platform must maintain Arabic and English versions of all notification templates.

### Acceptance Criteria

**Scenario 1 — Push notification is delivered to an Android device**
- Given a driver or rider has a registered FCM device token (via #1625)
- When the platform dispatches a push notification to that device token
- Then the notification appears on the Android device within 10 seconds
- And the notification payload includes the intended title and body text in the user's preferred language

**Scenario 2 — Push notification is delivered to an iOS device**
- Given a driver or rider has a registered APNs device token (via #1625)
- When the platform dispatches a push notification to that device token
- Then the notification appears on the iOS device within 10 seconds
- And the notification payload includes the intended title and body text in the user's preferred language

**Scenario 3 — Stale or invalid device token is handled**
- Given a device token that is no longer valid
- When the platform attempts delivery and the push provider returns a token-invalid error
- Then the platform marks that token as inactive in its records
- And no further notifications are dispatched to that token until a new one is registered

**Scenario 4 — Push provider error is logged**
- Given the push provider returns a non-token-related error
- When the platform processes the failure
- Then the error is logged internally with the provider error code
- And the notification is queued for one retry

**Scenario 5 — Notification text is in the user's preferred language**
- Given a notification is dispatched and the recipient's `shedrive.lang` is "ar" or "en"
- When the notification is delivered
- Then the title and body are in the recipient's preferred language
- And Arabic is used as the default when no preference is stored

### Out of Scope
- In-app banners or toasts (handled client-side)
- Silent/background push for location updates
- Notification grouping or badging
- SOS/emergency push alerts (separate story)

### Dependencies
- #1625 — User registers device token for push notifications (must be live)

---

## [API] #1619 — Auth middleware validates session tokens on all protected endpoints ✏️
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As the SheDrive platform, I want every protected endpoint to verify the Authorization header for a valid session token so that only authenticated users can access protected resources.

### Background
Auth middleware is a cross-cutting concern applied to every endpoint that is not explicitly public (i.e., every endpoint except #1620 and #1621/#1622). The middleware reads the session token from the Authorization header (Bearer scheme), looks it up in the session store, and either allows the request to proceed with the authenticated user's context or rejects it immediately. A session token is issued upon successful login (#1622) or registration (#1621) and is invalidated upon logout (#1624). **Session tokens expire after 30 days of issuance.** Token refresh is out of scope for MVP; users must re-authenticate via OTP after expiry.

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
- Given a request includes an Authorization header with a value that is not a valid token format
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

**Scenario 6 — Session token expires after 30 days**
- Given a session token that was issued more than 30 days ago
- When a request is made to any protected endpoint using that token
- Then the middleware rejects the request with a session-expired error
- And the client prompts the user to log in again via OTP
- And no token refresh mechanism is available (re-authentication required)

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

### Feature 4 — Authentication API (Shared — Rider & Driver)

---

## [API] #1620 — User requests OTP via SMS
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

### Dependencies
- #1616 — SMS gateway delivers OTP to Egyptian mobile numbers (must be live)

---

## [API] #1621 — User registers with OTP verification
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an unauthenticated endpoint with a phone number, OTP, and full name so that a new account is created and a session token is returned on success.

### Background
This unauthenticated endpoint is called after the user has received her OTP via #1620. It accepts the phone number, the 6-digit OTP, and the user's full name. The endpoint verifies that the OTP matches, is not expired, and has not been exhausted by too many wrong attempts. If the phone number is already registered, it returns a conflict error. If all checks pass, a new user account is created and a session token is returned.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| phone | Yes | 11-digit Egyptian mobile; +20 prefix stripped | 11 digits | 11 digits | Digits only | Return validation error: phone is required | Return validation error: invalid Egyptian mobile format | Return validation error: must be 11 digits |
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
- When another registration attempt is made for that phone
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

### Dependencies
- #1620 — User requests OTP via SMS (OTP must have been issued first)
- #1616 — SMS gateway delivers OTP to Egyptian mobile numbers (must be live)

---

## [API] #1622 — User logs in with OTP verification
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
- Then the request is rejected by #1619 auth middleware before the profile is accessed

### Out of Scope
- Profile editing (name or phone update)
- Profile photo upload
- Driver-specific profile fields (covered by onboarding stories)

### Dependencies
- #1619 — Auth middleware validates session tokens (must be live)

---

## [API] #1624 — User session is invalidated on logout
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to invalidate my current session so that my token can no longer be used and my device's push token is deregistered.

### Background
This authenticated endpoint is called when a rider or driver taps logout. It identifies the session via the Authorization header, marks the session token as invalidated in the session store (so #1619 rejects it on future requests), and removes any stored push notification device token associated with this session. The call is idempotent — calling it twice with an already-invalidated token is safe and returns a success response.

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
- Then #1619 rejects the request

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
- Logging the logout event for audit trail

### Dependencies
- #1619 — Auth middleware validates session tokens (must be live)

---

## [API] #1625 — User registers device token for push notifications
**Feature:** Feature 4 — Authentication API | **Sprint:** 1

**Description:** As the rider app or driver app, I want to call an authenticated endpoint to register my device's push notification token so that the platform can deliver real-time alerts to my device.

### Background
This authenticated endpoint is called immediately after a successful login or registration, and again whenever the operating system refreshes the device push token. It accepts the push token string and a platform identifier (ios or android) and associates them with the current session. If the same session already has a token stored, the new token replaces the old one (upsert behavior). This endpoint is a prerequisite for all push-notification-dependent features.

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
- When a new token is submitted for the same session
- Then the new token replaces the old one
- And only the latest token is used for subsequent push notifications

**Scenario 3 — Empty token is rejected**
- Given a request is submitted with an empty or missing token field
- When the endpoint processes the request
- Then a validation error is returned indicating the device token is required

**Scenario 4 — Invalid platform value is rejected**
- Given a platform value other than "ios" or "android" is submitted
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

### Dependencies
- #1619 — Auth middleware validates session tokens (must be live)
- #1618 — Push notification service delivers to iOS and Android (must be live)

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
- #1619 — Session token validation
- #1617 — Google Maps API key configuration

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
- #1619 — Session token validation
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
- #1619 — Session token validation

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
- #1619 — Session token validation

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
- #1619 — Session token validation
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
- #1619 — Session token validation
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
- #1619 — Session token validation

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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
- #1618 — Push notification service integration (must be live)
- #1630 — System matches request to nearest available driver (must be live)

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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)
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

### Out of Scope
- WebSocket or server-sent event push (polling model only for MVP)
- Trip history retrieval

### Dependencies
- #1619 — Authentication service (must be live)
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
- #1619 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1635 — Trip detail includes first-trip flag ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As the driver app, I want the trip detail response to include a first-trip flag so that I know whether to show the gender verification step (#1588) before starting the trip.

### Background
When the driver app fetches the active trip details, the response includes a boolean field `is_first_trip`. This field is `true` if the trip belongs to a rider who has never previously completed a trip on SheDrive. It is derived from the rider's trip history at the time the trip is created and stored on the trip record. The driver app reads this flag to conditionally display the rider gender verification step (#1588).

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
- #1619 — Authentication service (must be live)
- #1641 — Rider retrieves trip history (used internally to compute is_first_trip at trip creation time)

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
- #1619 — Authentication service (must be live)
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
- #1619 — Authentication service (must be live)
- #1646 — Driver location update endpoint (must be live)

---

## [API] #1687 — Rider account is suspended after gender mismatch report 🆕
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

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
- #1619 — Session validation
- #1652 — Driver advances trip state machine

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
- #1619 — Session validation
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
- #1619 — Authentication service (must be live)
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
- #1619 — Authentication service (must be live)
- #1618 — Push notification service (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [API] #1639 — Rider submits driver rating
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As the rider app, I want to submit a star rating and optional tags for a completed trip so that the driver's performance is recorded.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| trip_id | Yes | String / UUID | — | — | Alphanumeric, hyphens | Return validation error | Return not-found or forbidden if trip not found or not this rider's | — |
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

### Out of Scope
- Free-text comment submission
- Rating edit or deletion after submission

### Dependencies
- #1619 — Authentication service (must be live)
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
- #1619 — Authentication service (must be live)

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

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- Then the request is rejected with an authentication error

### Dependencies
- #1619 — Session validation (must be live)

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

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- Then the request is rejected with an authentication error

### Dependencies
- #1619 — Session validation (must be live)

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
- #1619 — Session validation (must be live)

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
- #1619 — Session validation (must be live)
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
- #1619 — Session validation (must be live)

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
- #1619 — Session validation (must be live)

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
- #1619 — Session validation (must be live)

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
- #1619 — Session validation (must be live)

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
- #1619 — Session validation (must be live)
- #1652 — Driver advances trip state machine (all transitions must be logged to trip_state_history — must be live)
