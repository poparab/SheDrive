# SheDrive — Mobile Driver Stories
> Canonical backlog for all [Mobile] Driver stories. Organized by sprint and feature.
> Last updated: 2026-06-21
> Stories with changes from original are marked ✏️ | New stories marked 🆕

---

## Sprint 1

### Feature 3 — Driver Authentication

---

## [Mobile] #1569 — Driver registers and is directed to onboarding
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 1

**Description:** As a driver, I want to register an account using my phone number and a one-time passcode so that I can begin the onboarding process to become a verified SheDrive driver.

### Background

The driver registration flow mirrors rider registration (two screens: phone entry then OTP + full name) but diverges at success: instead of landing on a home screen, the driver is taken directly to the onboarding flow (personal details screen). A driver with no completed or approved onboarding cannot reach the driver home/availability screen. The OTP rules (5-minute expiry, 3-attempt limit, 60-second resend cooldown) are identical to rider registration.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| رقم الهاتف | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |
| الاسم الكامل | Yes | Arabic and/or Latin letters and spaces only; no digits or symbols | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخل اسمك الكامل | الاسم يجب أن يحتوي على حروف فقط | الاسم يجب أن يكون بين 2 و 50 حرفاً |

### Acceptance Criteria

**Scenario 1 — Successful registration redirects to onboarding**
- Given a new driver opens the driver app and taps "إنشاء حساب"
- When she enters a valid Egyptian mobile number, receives and enters the correct 6-digit OTP, and enters a valid full name
- Then her account is created and she is taken to the onboarding flow (personal details screen)
- And she cannot navigate to the driver home screen until onboarding is approved

**Scenario 2 — Phone number already registered auto-logs the driver in**
- Given a driver enters a phone number already linked to an existing account
- When she proceeds through OTP + name entry and submits, #1621 detects the existing account and auto-logs her in
- Then the app receives a session token and routes the driver based on her onboarding status

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
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 1

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
- Then the app displays "هذا الرقم غير مسجل. أنشئي حساباً جديداً" with a link to the registration screen

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
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 1

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

## [Mobile] #1746 — Driver session persists across app restarts
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 1

**Description:** As a driver, I want the app to keep me logged in between sessions so that I don't have to go through OTP verification every time I open the app.

### Background

After a successful login or registration the session token is stored in the device's secure storage (iOS Keychain / Android Keystore — never in plain SharedPreferences or AsyncStorage). On every app launch and on each foreground resume event the app reads the stored token and validates it silently against the backend. If the token is valid the app routes the driver to the correct screen based on her current onboarding status: approved drivers go to the driver home/availability screen; pending or rejected drivers go to the onboarding status screen (#1576). If no token is found or the server rejects it the local session is cleared and the driver is shown the splash/login screen. Any 401 response from a protected endpoint during an active session also clears the stored token and redirects the driver to the login screen.

**Scenario 1 — Valid token and approved onboarding → driver home on launch**
- Given a driver has a valid stored token and her onboarding status is approved
- When she relaunches the app
- Then the app validates the token silently
- And she is taken to the driver home/availability screen with no OTP prompt

**Scenario 2 — Valid token and pending/rejected onboarding → status screen on launch**
- Given a driver has a valid stored token but her onboarding status is pending or rejected
- When the app validates the token on launch
- Then she is taken to the onboarding status screen (#1576) rather than the driver home screen

**Scenario 3 — No stored token → login screen**
- Given the device has no stored session token
- When the app launches
- Then the driver is shown the splash/login screen
- And no background validation request is made

**Scenario 4 — Expired token on launch → login screen**
- Given a driver's stored token has passed its 30-day lifetime
- When the app validates it on launch and the server returns 401
- Then the local token is cleared from secure storage
- And the driver is shown the login screen

**Scenario 5 — Mid-session 401 → clear session and redirect to login**
- Given a driver is actively using the app and any API call returns 401
- When the app intercepts the 401 response
- Then the stored session token is cleared from secure storage
- And the driver is navigated to the login screen with a session-expired message

**Scenario 6 — Token is stored in secure storage only**
- Given a session token is issued after login or registration
- When it is persisted on the device
- Then it is stored exclusively in iOS Keychain (iOS) or Android Keystore (Android)
- And it is never written to any unencrypted store

**Scenario 7 — Token is cleared on explicit logout**
- Given a driver taps logout
- When logout completes
- Then the session token is removed from secure storage
- And the next app launch shows the login screen with no auto-login attempt

**Scenario 8 — Network unavailable on launch → offline grace period**
- Given a driver has a valid stored token but no internet on launch
- When background validation times out
- Then the driver is shown her last-known screen using the cached session
- And the next 401 response triggers Scenario 5

### Out of Scope
- Biometric re-authentication
- Token refresh or silent renewal
- Multi-device session management
- Session timeout on inactivity

### Dependencies
- #1619 — Auth middleware validates session tokens (must be live)
- #1570 — Driver logs in (session issued here)

---

### Feature 5 — Driver Onboarding & Admin Approval

---

## [Mobile] #1572 — Driver submits personal details
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to enter my personal details in the first step of the onboarding wizard so that SheDrive can verify my identity before approving my application.

### Background

The personal details screen is Step 1 of a multi-step onboarding wizard. It is shown only to drivers who have completed phone OTP login but have not yet submitted an application. The driver enters her full name, date of birth, and Egyptian National ID number. She must also accept a background-check consent checkbox before she can advance. On successful save, she advances to Step 2 (vehicle details). All fields must pass validation before the wizard can advance.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |  |
| Date of birth | Yes | DD/MM/YYYY | — | — | Digits and "/" separator | أدخلي تاريخ ميلادك | صيغة التاريخ غير صحيحة | — |
| National ID (NID) | Yes | 14-digit numeric | 14 digits | 14 digits | Digits only | أدخلي رقم الهوية الوطنية | رقم الهوية يجب أن يكون 14 رقمًا | رقم الهوية يجب أن يكون 14 رقمًا |
| Background-check consent | Yes | Checkbox (must be checked) | — | — | — | يجب الموافقة على إجراء فحص الخلفية | — | — |

### Acceptance Criteria

**Scenario 1 — Happy path: all fields valid, wizard advances**
- Given the driver is on Step 1 of the onboarding wizard
- When she enters a valid full name, date of birth (age ≥ 21), and a 14-digit NID, and accepts the background-check consent
- Then all inline errors are absent
- And tapping "Next" submits the step and navigates to Step 2 (vehicle details)



**Scenario 2 — Invalid date of birth format**
- Given the driver enters a date in a non-DD/MM/YYYY format (e.g., "1996-04-15")
- When she taps "Next"
- Then the field shows "صيغة التاريخ غير صحيحة"

**Scenario 3 — Driver is underage**
- Given the driver enters a date of birth that makes her younger than 21 years old
- When she taps "Next"
- Then the field shows "يجب أن يكون عمرك 21 عامًا على الأقل"

**Scenario 4 — NID not 14 digits**
- Given the driver enters fewer or more than 14 digits in the NID field
- When she taps "Next"
- Then the field shows "رقم الهوية يجب أن يكون 14 رقمًا"

**Scenario 5 — NID contains non-digit characters**
- Given the driver types letters or symbols in the NID field
- When she taps "Next"
- Then the field shows "رقم الهوية يجب أن يكون 14 رقمًا"

**Scenario 6 — Background-check consent is required**
- Given the driver has entered valid personal details but has not ticked the background-check consent checkbox
- When she taps "Next"
- Then the wizard does not advance and the error "يجب الموافقة على إجراء فحص الخلفية" / "You must agree to the background check to continue" is shown
- And when she ticks the checkbox and taps "Next", the step submits

### Out of Scope
- NID authenticity verification against government databases
- Re-submission flow after admin rejection
- Editing personal details after the application has been submitted

### Dependencies
- #1642 — Driver submits onboarding application (must be live)

---

## [Mobile] #1854 — Driver captures her National ID photo 🆕
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to upload clear photos of the front and back of my National ID during onboarding so that SheDrive can verify my identity document.

### Background

The National ID capture screen is Step 2 of the onboarding wizard, shown after Step 1 (personal details) and before the vehicle-details step. The driver uploads two photos — the front and back of her National ID card — using the device camera or gallery. Both photos are required before she can advance. Files must be JPEG, PNG or HEIC, max 10 MB each. This complements the typed 14-digit National ID number captured in personal details (#1572).

### Field Validation

| Field | Required | Format | Max | Error — empty | Error — size |
|---|---|---|---|---|---|
| National ID — front | Yes | JPEG, PNG, or HEIC | 10 MB | يرجى رفع الوجه الأمامي لبطاقة الهوية | حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت |
| National ID — back | Yes | JPEG, PNG, or HEIC | 10 MB | يرجى رفع الوجه الخلفي لبطاقة الهوية | حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت |

### Acceptance Criteria

**Scenario 1 — Both sides uploaded, wizard advances**
- Given the driver is on the National ID capture step
- When she uploads a valid front photo and a valid back photo
- Then both slots show a thumbnail preview
- And tapping "Next" advances to the vehicle-details step

**Scenario 2 — A side is missing**
- Given the driver has uploaded only one side
- When she taps "Next"
- Then a bilingual error is shown and the wizard does not advance

**Scenario 3 — File too large**
- Given the driver selects a photo exceeding 10 MB
- Then a bilingual size error toast is shown and the slot is not marked complete

**Scenario 4 — Invalid file type**
- Given the driver selects a non-JPEG/PNG/HEIC file
- Then a bilingual invalid-format toast is shown

### Out of Scope
- OCR / automatic extraction of ID data
- ID authenticity verification against government databases
- Re-submission flow after admin rejection

### Dependencies
- #1642 — Driver submits onboarding application (photos included in the multipart payload)
- #1572 — Driver submits personal details (typed National ID number)

---

## [Mobile] #1573 — Driver submits vehicle details
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to enter my vehicle details in Step 3 of the onboarding wizard so that SheDrive can verify that my vehicle meets service requirements.

### Background

The vehicle details screen is Step 3 of the multi-step onboarding wizard, reached after completing the National ID capture step (Step 2). The driver enters information about the vehicle she will use to provide rides. Make and model are chosen from dropdowns, each with an "Other" option that reveals a free-text field; Model options depend on the selected Make. Supported vehicle types are Sedan, SUV, and Minivan. On successful save, she advances to Step 4 (documents). All fields must pass validation before advancing.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Make (brand) | Yes | Dropdown + Other → free text | — | 30 chars | Brand from list, or free text via Other | اختاري ماركة السيارة | — | — |
| Model | Yes | Dependent dropdown + Other → free text | — | 30 chars | Model from list, or free text via Other | اختاري موديل السيارة | — | — |
| Year | Yes | 4-digit year | 2010 | Current year | Digits only | أدخلي سنة الصنع | سنة الصنع غير صحيحة | سنة الصنع غير صحيحة |
| Plate number | Yes | Egyptian plate format | 4 chars | 6 chars | Letters, digits | أدخلي رقم اللوحة | رقم اللوحة غير صحيح | رقم اللوحة غير صحيح |
| Color | Yes | Selection from predefined list | — | — | — | اختاري لون السيارة | — | — |
| Vehicle type | Yes | One of: Sedan, SUV, Minivan | — | — | — | اختاري نوع السيارة | — | — |

### Acceptance Criteria

**Scenario 1 — Happy path: all fields valid, wizard advances**
- Given the driver is on Step 3 of the onboarding wizard
- When she selects a make and model from the dropdowns (or chooses "Other" and types them), enters a valid year (2010–current) and plate number, and selects a colour and vehicle type
- Then no inline errors are shown
- And tapping "Next" navigates to Step 4 (documents)

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
- Given the driver enters a plate number with invalid characters or a length outside 4–6 characters
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
- #1642 — Driver submits onboarding application (must be live)

---

## [Mobile] #1574 — Driver photographs her vehicle
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to photograph my vehicle from five required angles in Step 5 of the onboarding wizard so that the admin can fully verify the vehicle matches the details I provided and riders can identify it on arrival.

### Background

The vehicle photo screen is Step 5 of the multi-step onboarding wizard, reached after completing the Documents step (Step 4). The driver must capture exactly **5 photos**, one per required angle, using the device camera. The screen presents each angle slot in order with a labelled guide frame and an illustrative icon showing the expected shot. All five slots must be filled before the driver can advance. On successful upload of all five photos, the wizard advances to Step 6 (profile selfie).

### Required Angles (in order)

| # | Angle | What must be visible |
|---|---|---|
| 1 | Front | Full front of vehicle, headlights visible |
| 2 | Rear | Full rear of vehicle, plate number clearly visible |
| 3 | Driver side | Full left/driver-side profile |
| 4 | Passenger side | Full right/passenger-side profile |
| 5 | Interior | Front cabin from driver's door, dashboard and seats visible |

### Field Validation

| Field | Required | Format | Max | Error — empty | Error — size |
|---|---|---|---|---|---|
| Each of the 5 angle photos | Yes | JPEG, PNG, or HEIC | 10 MB per photo | يرجى التقاط الصورة المطلوبة | حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت |

### Acceptance Criteria

**Scenario 1 — Happy path: all 5 photos captured via camera**
- Given the driver is on Step 5 and camera permission has been granted
- When she taps a slot and the camera opens
- And she captures a photo for each of the 5 angle slots
- Then each completed slot shows a thumbnail preview with a checkmark
- And the "Next" button becomes active only after all 5 slots are filled
- And tapping "Next" uploads all 5 photos and navigates to Step 6

**Scenario 2 — Gallery option is not available**
- Given the driver is on Step 5
- Then no "Choose from gallery" or photo library option is shown for any slot
- And the only capture method available is the device camera

**Scenario 3 — Attempting to advance with incomplete slots**
- Given the driver has filled fewer than 5 slots
- When she taps "Next"
- Then the incomplete slots are highlighted in red
- And the wizard does not advance

**Scenario 4 — Replacing a photo**
- Given the driver has already filled a slot
- When she taps that slot's thumbnail
- Then she is prompted to retake the photo using the camera
- And confirming a new capture replaces the previous photo in that slot

**Scenario 5 — Camera permission denied**
- Given the driver taps a slot but camera permission is denied
- Then the slot shows an explanation that camera access is required
- And a link to device settings is shown so she can grant permission
- And the slot cannot be filled until camera permission is granted
- And the wizard does not advance until all slots are filled

**Scenario 6 — Captured image too large**
- Given the camera produces an image exceeding 10 MB
- Then that slot shows "حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت"
- And the slot is not marked complete

### Out of Scope
- Automatic plate-number recognition or image quality scoring
- Video capture
- Gallery / photo library upload
- Re-submission flow after admin rejection

### Dependencies
- #1642 — Driver submits onboarding application (API endpoint that receives the submitted data)

---

## [Mobile] #1686 — Driver captures her profile photo 🆕
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to capture a clear portrait photo of myself in Step 6 of the onboarding wizard so that riders can visually identify me when I arrive and the admin can verify my gender before approving my application.

### Background

The profile photo screen is Step 6 (the final step) of the multi-step onboarding wizard, reached after completing the vehicle photo step (Step 5). The driver takes a selfie using the front camera or selects a portrait photo from her gallery. The photo must clearly show her face. A gallery fallback is available if the front camera is unavailable or permission is denied. On successful capture, the driver taps "Submit Application" to send the full application including this photo via #1642. This image is displayed to riders on the matched driver card and active trip screen, and is used by admins to verify the driver's gender during application review.

### Field Validation

| Field | Required | Format | Max | Error — empty | Error — invalid format | Error — size |
|---|---|---|---|---|---|---|
| Profile photo | Yes | JPEG, PNG, or HEIC | 10 MB | يرجى التقاط صورة شخصية | يرجى رفع صورة صالحة (JPEG أو PNG) | حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت |

### Acceptance Criteria

**Scenario 1 — Selfie captured via front camera**
- Given the driver is on Step 5 and front camera permission has been granted
- When she taps the camera button
- Then the front camera opens, a preview is shown after capture, and tapping "Submit Application" includes the photo in #1642

**Scenario 2 — Photo selected from gallery**
- Given the driver selects a valid portrait from gallery
- Then a preview is shown and the photo is included in the submission

**Scenario 3 — Front camera permission denied**
- Given camera permission is denied
- Then the app explains why the camera is needed, shows a link to device settings, and the gallery fallback remains available

**Scenario 4 — File too large**
- Given the driver selects a photo exceeding 10 MB
- Then "حجم الصورة كبير جداً، الحد الأقصى 10 ميجابايت" is shown and the wizard does not advance

**Scenario 5 — No photo provided**
- Given the driver taps "Submit Application" without a photo
- Then "يرجى التقاط صورة شخصية" is shown and submission is blocked

**Scenario 6 — Invalid file type**
- Given the driver selects a non-JPEG/PNG/HEIC file
- Then "يرجى رفع صورة صالحة (JPEG أو PNG)" is shown

### Out of Scope
- Automatic face-detection or quality scoring
- Re-submission after admin rejection
- Photo editing or cropping
- Liveness detection

### Dependencies
- #1642 — Driver submits onboarding application (profile photo included in multipart payload)

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
- Then an error toast is shown
- And the driver remains on the documents screen with her uploads intact

### Out of Scope
- Document authenticity or expiry verification
- Re-submission after admin rejection
- Uploading more than four document files

### Dependencies
- #1642 — Driver submits onboarding application (must be live)

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
- Given a driver’s application has been approved
- When she opens the app
- Then she is routed to the driver home screen (#1578), not the pending screen

**Scenario 4 — Rejected driver sees rejection notice**
- Given a driver’s application has been rejected
- When she opens the app and the status check returns "rejected"
- Then the pending screen updates to display a rejection notice including the admin’s stated reason
- And no driver home or trip UI is accessible

### Out of Scope
- Re-submission flow after rejection
- SOS functionality
- In-app support chat

### Dependencies
- #1643 — Driver queries onboarding status (must be live)
- #1644 — Driver is blocked from going online until approved (must be live)

---

## [Mobile] #1577 — Driver receives push on application decision ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to receive a push notification when my application is approved or rejected so that I am immediately informed of the decision without having to open the app repeatedly.

### Background

When an admin approves or rejects a driver’s application in the admin portal, the platform dispatches a push notification to that driver’s device. The notification payload and deep link differ based on the decision. Approved drivers are taken to the driver home screen on tap; rejected drivers are taken to the pending/rejection screen where the reason is visible. Push delivery depends on the driver having granted notification permission.

### Acceptance Criteria

**Scenario 1 — Approved: notification received and tapped**
- Given the admin has approved the driver’s application (#1659)
- Then the driver receives a push notification: "Congratulations! Your application has been approved. You can now go online."
- When the driver taps the notification
- Then the app opens and routes her to the driver home screen (#1578)

**Scenario 2 — Rejected: notification received and tapped**
- Given the admin has rejected the driver’s application with a reason (#1660)
- Then the driver receives a push notification: "Your application was not approved. Reason: [admin reason]."
- When the driver taps the notification
- Then the app opens and routes her to the rejection notice screen, where the full reason is visible

**Scenario 3 — Notification permission not granted**
- Given the driver has not granted push notification permission
- When an application decision is made
- Then no push notification is delivered to the device
- But the decision is still reflected when the driver opens the app and the status check (#1643) runs

**Scenario 4 — App is foregrounded when notification arrives**
- Given the driver’s app is open in the foreground
- When a decision push arrives
- Then the app displays an in-app banner or toast with the decision message
- And updates the current screen to reflect the new status without requiring a tap

### Out of Scope
- Email or SMS notification of application decision
- SOS push notifications
- Notification preference settings

### Dependencies
- #1618 — Push notification service integration (must be live)
- #1659 — Admin approves driver application (must be live)
- #1660 — Admin rejects driver application with reason (must be live)

---

### Feature 6 — Driver Home & Availability

---

## [Mobile] #1578 — Driver sees home screen with map
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a driver, I want to see a map centered on my current GPS location on my home screen so that I can orient myself and manage my availability.

### Background

The driver home screen is the main screen for approved drivers after login. It displays a full-screen map (Cairo/Giza area) centered on the driver’s current GPS location. An online/offline toggle button is prominently displayed. While offline, the driver’s location is not streamed and no trip requests are received. GPS permission is required to center the map; if denied, the map defaults to a central Cairo view with a prompt to enable location. The screen is accessible only to drivers with application status = approved.

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
- #1645 — Driver sets availability status (must be live)
- #1646 — Driver updates GPS location (must be live)

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
- And the driver’s availability on the server is not changed

### Out of Scope
- Automatic offline when app is backgrounded (future sprint)
- SOS functionality
- Trip cancellation

### Dependencies
- #1645 — Driver sets availability status (must be live)
- #1646 — Driver updates GPS location (must be live)

---

## [Mobile] #1580 — Driver location updates while online
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** 1

**Description:** As a driver, I want my GPS location to be sent to the server automatically every 5 seconds while I am online so that riders and the platform can see my real-time position.

### Background

While the driver is online, the app runs a background location polling loop that reads the device GPS and calls #1646 every 5 seconds with the latest latitude and longitude. The driver’s position dot on the map moves in real time. If the GPS signal is lost (accuracy too low or no fix), a warning is shown and the location update loop pauses. When the signal is restored, the loop resumes automatically without driver action. When the driver goes offline, the loop stops.

### Acceptance Criteria

**Scenario 1 — Happy path: location streaming while online**
- Given the driver is online with GPS signal available
- When 5 seconds have elapsed since the last update
- Then the app reads the current GPS coordinates and calls #1646
- And the driver’s position dot on the map moves to the new location

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
- #1646 — Driver updates GPS location (must be live)

---

## [Mobile] #1792 — Driver views her overall rating 🆕
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** Phase 1

**Description:** As a driver, I want to see my overall star rating so that I know how riders rate me.

### Background

The driver's home/profile shows her aggregate star rating to one decimal and her total ratings count, retrieved via #1786. A new driver who has not been rated yet sees a clear no-rating-yet state. The display is read-only. All strings flow through data-i18n keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Driver sees her average rating and count**
- Given an authenticated approved driver with at least one rating
- When she opens her home/profile
- Then her average star rating (one decimal) and total ratings count are shown

**Scenario 2 — New driver with no ratings**
- Given a driver who has not been rated
- When she opens her home/profile
- Then a bilingual no-rating-yet state is shown

**Scenario 3 — Rating updates after new ratings**
- Given new rider ratings have been recorded
- When the driver reopens her home/profile
- Then the displayed average and count reflect the latest data

**Scenario 4 — Network error**
- Given the rating-summary request fails
- Then a bilingual toast error is shown

### Out of Scope
- Per-trip rating list (driver trip history)
- Responding to or disputing ratings

### Dependencies
- #1786 — Driver retrieves her aggregate rating summary (API — must be live)

---

## Sprint 2

### Feature 9 — Driver Trip Acceptance

---

## [Mobile] #1581 — Driver receives push for incoming trip request ✏️
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to receive a push notification when a new trip request is assigned to me so that I can respond within the acceptance window even if the app is in the background.

### Background

When the platform dispatches a trip to a matched driver (#1647), a push notification is sent to the driver's registered device. The notification displays the pickup area and estimated fare so the driver can make an informed decision before opening the app. Tapping the notification opens the trip request details screen (#1582) with the 10-second countdown already running. If the driver does not tap the notification in time, the countdown expires on the server side regardless, and the screen auto-dismisses if the driver opens the app late.

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
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to see full trip request details with a countdown timer so that I can decide to accept or reject within the 10-second window.

### Background

When a driver receives a trip request (via push notification or app foreground transition), she is shown a full-screen or modal trip request details screen. The screen displays the pickup address, destination summary, estimated distance, and estimated fare. A 10-second countdown timer is prominently visible and begins immediately when the screen loads. Two action buttons are shown: "Accept" and "Reject." If the timer reaches zero without action, the screen auto-dismisses, a brief "Request expired" message is shown, and the driver returns to her home/available screen. The system treats the non-response as a rejection and reassigns the trip.

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
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Accept" on the trip request screen so that the trip is confirmed and I can begin navigating to the rider's pickup location.

### Background

When the driver taps "Accept" within the 10-second window, the app calls the accept endpoint (#1649). On success, the trip status is updated to accepted, and the driver is taken to the navigation-to-pickup screen (active trip feature). Simultaneously, the rider receives a push confirmation that her driver is on the way (#1634). If the acceptance window has already expired server-side (e.g., due to network lag), the endpoint returns a conflict and the driver sees an expired message and returns to her home screen.

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
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Reject" on the trip request screen so that I can decline the trip and remain available for other requests.

### Background

A driver may choose to reject a trip request within the 10-second window. Tapping "Reject" calls the rejection endpoint (#1650), which marks the driver as available again and triggers reassignment of the trip to the next nearest driver (#1651). The driver returns to her home/available screen immediately. No penalty or strike is applied in this sprint. If the window has already expired server-side, the rejection call returns a conflict (the rejection is effectively a no-op since the system has already treated it as a timeout).

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
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want the acceptance screen to automatically dismiss after 10 seconds if I do not respond so that I am not left on a stale screen and the system can reassign the trip promptly.

### Background

If the driver neither accepts nor rejects within the 10-second window, the platform server-side timer expires and triggers reassignment (#1651). On the client side, the countdown UI reaches zero and automatically dismisses the screen. A brief "Request expired" toast or message is displayed so the driver understands what happened. The driver is returned to her home/available screen and remains online. This behavior mirrors a rejection from the platform's perspective.

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

### Feature 10 — Active Trip (Driver)

---

## [Mobile] #1586 — Driver navigates to pickup
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to navigate to the rider's pickup location with in-app turn-by-turn navigation and the option to open an external maps app, so that I can reach the pickup point efficiently using my preferred tool.

### Background

After accepting a trip request, the driver's active trip screen shows in-app turn-by-turn navigation to the rider's pickup location by default — the route, the pickup pin, and step-by-step guidance are rendered inside SheDrive. A secondary "Open in external app" button lets the driver hand off to Google Maps or Waze with the pickup coordinates pre-filled. An "I've Arrived" button is visible at all times. The driver's GPS position is streamed every 5 seconds so the rider can track progress in real time. Route and turn-by-turn directions data are served by #1817.

### Acceptance Criteria

**Scenario 1 — In-app navigation is shown by default after acceptance**
- Given the driver has accepted a trip request
- When the active trip screen loads
- Then in-app turn-by-turn navigation to the pickup is displayed by default, showing the route, the pickup pin, and step-by-step guidance
- And an "I've Arrived" button is visible on screen

**Scenario 2 — Driver opts to use an external app**
- Given the driver is on the active trip screen in en_route_pickup state
- When the driver taps the "Open in external app" button
- Then the app opens Google Maps (or Waze if installed) with the pickup coordinates pre-filled as the destination
- And the driver returns to the SheDrive in-app navigation when she exits the external app

**Scenario 3 — In-app guidance updates as the driver moves**
- Given in-app navigation to the pickup is active
- When the driver's position changes along the route
- Then the in-app turn-by-turn guidance and map advance to reflect her current position

**Scenario 4 — Driver location streams to the platform**
- Given the driver is en route to the pickup location
- When the driver's device has an active GPS signal
- Then the app sends the driver's current latitude and longitude to the platform every 5 seconds
- And those coordinates are available for the rider to see in real time

### Out of Scope
- Offline / cached-map navigation
- SOS functionality
- Trip cancellation from this screen

### Dependencies
- #1817 — Platform serves active-trip route and turn-by-turn directions to the driver (must be live)
- #1649 — Trip acceptance flow (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1587 — Driver confirms arrival at pickup ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "I've Arrived" when I reach the pickup location so that the rider is notified and I can proceed to board her.

### Background

When the driver reaches the rider's pickup location, she taps the "I've Arrived" button on the active trip screen. This advances the trip state from en_route_pickup to arrived_pickup. The platform immediately sends a push notification to the rider. The driver's screen transitions to show either a "Confirm Rider Identity" button (if it is the rider's first trip) or a "Rider Has Boarded" button (for returning riders).

### Acceptance Criteria

**Scenario 1 — Driver taps "I've Arrived" and state advances**
- Given the driver is on the active trip screen in en_route_pickup state
- When the driver taps "I've Arrived"
- And we confirm the the driver is in the rider Geofence zone of the rider.
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

## [Mobile] #1767 — Driver sees waiting counter during arrived_pickup state
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to see a waiting counter after I tap "I've Arrived" so that I know how long the rider has taken to board.

### Background

After the driver taps "I've Arrived" and the trip state advances to arrived_pickup, a waiting counter starts from 0:00 and increments each second. The counter is displayed on the driver's screen alongside the "Start Trip" (or "Verify Rider") button. It stops when the driver taps "Start Trip" and the state advances to trip_started.

### Acceptance Criteria

**Scenario 1 — Waiting counter starts when driver arrives**
- Given the driver has tapped "I've Arrived" and the trip state is arrived_pickup
- When the driver views the arrived_pickup screen
- Then a waiting counter is displayed starting from 0:00
- And the counter increments each second

**Scenario 2 — Counter is visible alongside the action button**
- Given the trip is in arrived_pickup state
- When the driver views the screen
- Then the counter is visible alongside the "Start Trip" or "Verify Rider" button
- And the counter does not obscure or replace the action button

**Scenario 3 — Counter stops when trip starts**
- Given the waiting counter is running on the driver's screen
- When the driver taps "Start Trip" and the state advances to trip_started
- Then the counter stops
- And the screen transitions to the active trip navigation view

**Scenario 4 — Counter resumes correctly after app restart**
- Given the trip is in arrived_pickup state and the waiting counter is running
- When the driver backgrounds and reopens the app
- Then the counter resumes from the correct elapsed time using the arrived_at timestamp returned by the trip state API
- And the counter does not reset to 0:00

### Out of Scope
- Automatic cancellation after a waiting timeout (separate story if needed)
- Waiting fee visibility on the driver's screen (separate story if needed)

### Dependencies
- #1587 — Driver confirms arrival at pickup (must be complete)
- #1633 — Rider retrieves live trip state and driver location (arrived_at timestamp required)

---

## [Mobile] #1588 — Driver verifies rider is female on first trip ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to visually verify that the rider is female on her first trip so that SheDrive's women-only service guarantee is upheld, with the option to cancel and report if the rider does not appear to be female.

### Background

When is_first_trip is true, the driver sees the rider's registered full name on the arrived_pickup screen and visually checks that the person approaching the vehicle is female. If satisfied, she taps "Rider Verified — Board". If the approaching person does not appear to be female, she taps "Cancel — Rider Not Female," which triggers a confirmation dialog and then calls #1687 to cancel the trip and suspend the rider's account for review. **Exception:** if the trip is flagged as a declared child passenger (flag carried by #1783, declared by the rider in #1790), a child of any gender is permitted to ride — this is the only exception to the women-only rule. In that case the driver verifies that a child is boarding and must not cancel for a gender mismatch. For all returning riders (is_first_trip = false) this step is skipped entirely and the driver proceeds directly to the "Start Trip" button.

### Acceptance Criteria

**Scenario 1 — Verification screen is shown for first-trip adult riders**
- Given the driver has arrived at the pickup location
- And the trip's is_first_trip flag is true and the passenger is not a declared child
- When the arrived_pickup screen loads
- Then the driver sees the rider's registered full name
- And a "Rider Verified — Board" button is displayed
- And a "Cancel — Rider Not Female" button is also displayed

**Scenario 2 — Declared child passenger is permitted regardless of gender**
- Given the trip's is_first_trip flag is true and the trip is flagged as a declared child passenger (#1783)
- When the arrived_pickup screen loads
- Then the driver sees a notice that the passenger is a declared child who may ride as the only exception to the women-only policy
- And the driver may board the child without a gender-mismatch cancellation

**Scenario 3 — Driver confirms rider is female and proceeds**
- Given the verification screen is visible
- When the driver taps "Rider Verified — Board"
- Then the screen transitions to show the "Start Trip" button
- And the driver can proceed to board the rider

**Scenario 4 — Driver cancels due to gender mismatch (adult passenger)**
- Given the verification screen is visible and the passenger is not a declared child
- When the driver taps "Cancel — Rider Not Female"
- Then a confirmation dialog is shown: "هل أنتِ متأكدة؟ سيتم إلغاء الرحلة وإرسال تقرير أمني." / "Are you sure? This will cancel the trip and submit a safety report."
- And on confirmation, the platform calls #1687 to cancel the trip and suspend the rider's account for review
- And the driver is returned to her home/available screen
- And no fare is charged

**Scenario 5 — Verification step is skipped for returning riders**
- Given the trip's is_first_trip flag is false
- When the driver arrives and the arrived_pickup screen loads
- Then no verification step is shown
- And the "Start Trip" button is immediately accessible

**Scenario 6 — Driver remains available after gender mismatch cancellation**
- Given the driver has cancelled due to gender mismatch
- When she is returned to her home screen
- Then her online status is preserved
- And she remains eligible for the next dispatched trip

### Out of Scope
- Biometric or document scanning
- Automatic identity verification via camera
- SOS functionality
- Penalty for drivers who cancel

### Dependencies
- #1635 — Trip detail includes first-trip flag (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1687 — Rider account is suspended after gender mismatch report (must be live)
- #1783 — Trip request captures a per-trip child-passenger flag and exposes it to the driver (must be live)

---

## [Mobile] #1589 — Driver confirms rider has boarded
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "Start Trip" after the rider boards so that the trip officially begins and in-app navigation switches to the destination.

### Background

After the driver has arrived (and confirmed the rider's gender if it is a first trip via #1588), she taps the "Start Trip" button. This advances the trip state from arrived_pickup to trip_started. The in-app navigation re-routes from the pickup to the destination, and the map shows the destination pin instead of the pickup pin. The "Open in external app" button now targets the destination coordinates. GPS streaming continues throughout.

### Acceptance Criteria

**Scenario 1 — Driver taps "Start Trip" and state advances**
- Given the driver is on the arrived_pickup screen
- And gender verification has been completed (if required)
- When the driver taps "Start Trip"
- Then the trip state advances to trip_started
- And the map updates to show the destination pin

**Scenario 2 — In-app navigation and external option point to the destination after boarding**
- Given the trip state is trip_started
- When the active trip screen is displayed
- Then in-app turn-by-turn navigation re-routes to the destination
- And tapping "Open in external app" opens Google Maps or Waze with the destination coordinates pre-filled, returning to SheDrive on exit

**Scenario 3 — "Start Trip" is not accessible before verification on first trip**
- Given is_first_trip is true and the driver has not yet completed the verification step (#1588)
- When the arrived_pickup screen is displayed
- Then the "Start Trip" button is not accessible
- And only the "Rider Verified — Board" and "Cancel — Rider Not Female" buttons are shown

### Out of Scope
- Automatic boarding detection
- SOS functionality

### Dependencies
- #1817 — Platform serves active-trip route and turn-by-turn directions to the driver (must be live)
- #1652 — Driver advances trip state machine (must be live)

---

## [Mobile] #1590 — Driver navigates to destination
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to navigate to the destination with in-app turn-by-turn navigation and the option to open an external maps app, so that I can bring the rider to her destination safely using my preferred tool.

### Background

Once the trip is started, the driver's active trip screen shows in-app turn-by-turn navigation to the destination by default — the route, the destination pin, and step-by-step guidance are rendered inside SheDrive. A secondary "Open in external app" button lets the driver hand off to Google Maps or Waze with the destination coordinates pre-filled. An "End Trip" button is visible so the driver can mark completion. GPS streaming continues every 5 seconds so the rider can follow progress on her screen.

### Acceptance Criteria

**Scenario 1 — Destination route appears after trip starts**
- Given the trip state has advanced to trip_started
- When the active trip screen is displayed
- Then in-app turn-by-turn navigation to the destination is shown, with the destination pin on the map
- And the pickup pin and pickup route are no longer shown

**Scenario 2 — Driver opts to use an external app**
- Given the trip is in trip_started state
- When the driver taps "Open in external app"
- Then the app opens Google Maps or Waze with the destination coordinates pre-filled
- And the driver can return to the SheDrive in-app navigation on exit

**Scenario 3 — "End Trip" button is visible during navigation**
- Given the trip is in trip_started state
- When the active trip screen is displayed
- Then an "End Trip" button is visible on screen

**Scenario 4 — GPS continues streaming during destination navigation**
- Given the trip is in trip_started state
- When the driver's device has an active GPS signal
- Then the app continues sending the driver's coordinates to the platform every 5 seconds

### Out of Scope
- Offline / cached-map navigation
- Geofence-based automatic trip ending
- SOS functionality

### Dependencies
- #1817 — Platform serves active-trip route and turn-by-turn directions to the driver (must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1653 — Driver streams GPS from acceptance to completion (must be live)

---

## [Mobile] #1591 — Driver ends trip at destination
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to tap "End Trip" when I reach the destination so that the fare is calculated and the rider is notified of completion.

### Background

When the driver arrives at the destination, she taps "End Trip" on the active trip screen. This advances the trip state from trip_started to trip_ended. The platform calculates the final fare from the actual distance and duration. The rider receives a push notification with the fare amount and sees the trip summary. The driver is shown the cash collection screen.

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

## [Mobile] #1592 — Driver sees cash fare to collect and returns to available
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a driver, I want to see how much cash to collect from the rider after ending the trip so that I collect the correct amount before becoming available again.

### Background

Immediately after the driver taps "End Trip" and the trip state advances to trip_ended, the driver's screen shows a full-screen prompt displaying the cash amount to collect from the rider in EGP. A single "Done" button is shown. When the driver taps "Done", this screen is dismissed and the driver is returned to her home screen in the online/available state, ready to receive the next trip request.

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

## [Mobile] #1766 — Driver sees net earnings after commission on trip completion 🆕
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a driver, I want to see my net earnings (after platform commission) on the trip completion screen so that I know exactly how much I earned from each trip without needing to calculate it myself.

### Background

The driver is always shown her net earnings — the amount after the platform commission has been deducted. The commission percentage itself is never shown to the driver; only the net amount matters. The gross fare is also not shown. On the trip completion screen, net earnings are displayed prominently so the driver has immediate clarity on what she earned.

**Scenario 1 — Net earnings displayed on trip completion**
- Given a trip completes with a total fare of 100 EGP and a 20% commission
- When the driver views the trip completion screen
- Then the screen shows net earnings of 80 EGP prominently
- And the commission percentage or gross fare is not displayed

**Scenario 2 — Net earnings displayed in trip history**
- Given the driver views a past trip in her history
- Then the net earnings for that trip are shown (not the gross fare)

**Scenario 3 — Cancellation fee share shown separately**
- Given a trip that was cancelled with a fee charged and the driver's share paid
- When the driver views that trip
- Then the cancellation fee driver share is shown as a separate line item from regular trip earnings
- And a label indicates it is a cancellation fee

**Scenario 4 — Earnings labelled in Arabic and English**
- Given the driver's language preference is Arabic or English
- Then the earnings label is displayed in the selected language

### Out of Scope
- Total earnings summary or weekly/monthly dashboard (separate story)
- In-app wallet balance or payout requests

### Dependencies
- [API] Platform commission is deducted on trip completion
- [Admin] Super admin configures platform commission (#1759)

---

### Feature 12 — Trip History (Driver)

---

## [Mobile] #1593 — Driver views trip history
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a driver, I want to view a list of my completed trips so that I can track my earnings and activity over time.

### Background

Drivers access trip history from the menu or profile section of the app. The list shows completed trips only, sorted most recent first, with a summary of each trip's destination area and cash fare collected. Tapping a row opens the full trip detail screen (#1594). If the driver has not yet completed any trips, an empty state is displayed.

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

## [Mobile] #1594 — Driver views past trip detail ✏️
**Feature:** Feature 12 — Trip History | **Sprint:** 2

**Description:** As a driver, I want to view the full details of a past trip so that I can review the route, duration, and the rating I received.

### Background

When a driver taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the full picture of that trip from the driver's perspective: timing, pickup and destination addresses, cash fare collected, trip duration, distance, and the star rating the rider gave (if submitted). If the rider skipped rating, the screen shows a localised placeholder. The screen is read-only.

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

## [Mobile] #1731 — Driver changes language preference from profile screen 🆕
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 2

**Description:** As a driver, I want to change my app language from my profile screen so that I can use the app in my preferred language.

### Background

The language preference toggle is available on the driver profile screen. The driver can switch between Arabic (default, RTL) and English (LTR). When she switches, the UI updates immediately. The new preference is persisted via #1728. If the preference cannot be saved due to connectivity loss, it is saved locally and synced when connectivity is restored.

### Acceptance Criteria

**Scenario 1 — Driver switches from Arabic to English**
- Given the driver is using the app in Arabic
- When she selects English on the language toggle on her profile screen
- Then the UI language switches to English immediately
- And the layout direction changes from RTL to LTR
- And the preference is saved via #1728

**Scenario 2 — Driver switches from English to Arabic**
- Given the driver is using the app in English
- When she selects Arabic on the language toggle
- Then the UI language switches to Arabic immediately
- And the layout direction changes to RTL
- And the preference is saved via #1728

**Scenario 3 — Language preference is restored after app restart**
- Given the driver has selected English
- When she closes and reopens the app
- Then the app launches in English

**Scenario 4 — Language preference is restored after re-login**
- Given the driver has selected English, logged out, and logs back in
- Then the app restores the English preference from the server

**Scenario 5 — Network error during preference save**
- Given the driver switches language while offline
- Then the language updates immediately in the UI
- And the preference is saved locally
- And it is synced to the server when connectivity is restored

### Out of Scope
- Languages other than Arabic and English
- Per-notification language settings

### Dependencies
- #1728 — User language preference is stored and retrieved (API — must be live)

---

## [Mobile] #1801 — Driver views her profile 🆕
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 2

**Description:** As a driver, I want to view my profile information so that I can confirm the personal, vehicle, and account details SheDrive has verified for me.

### Background

The driver profile screen is accessible from the driver app's drawer/menu. It displays, in read-only form, the details captured and verified during onboarding: profile photo, full name, phone number, date of birth, masked National ID (last 4 digits only), and vehicle details (make, model, year, color, plate number, vehicle type). It also shows her account/onboarding status (Approved), her aggregate star rating (linking to #1792), and her current language preference (with a link to change it via #1731). Because all profile and vehicle data is verified during onboarding, none of it can be edited in the app in this phase; a bilingual note explains that to correct any detail she should contact support. In-app editing and document re-submission will be introduced later alongside the onboarding-maturity and resubmission work. Profile data is retrieved via #1800. All strings flow through data-i18n keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Driver opens her profile**
- Given an authenticated approved driver opens the profile screen from the menu/drawer
- When the screen loads (data via #1800)
- Then her profile photo, full name, phone number, date of birth, National ID, and vehicle details (make, model, year, color, plate, type) are displayed
- And her account status and aggregate rating are shown

**Scenario 2 — All fields are read-only**
- Given the driver views any profile or vehicle field
- When she taps it
- Then the field does not enter edit mode
- And a bilingual note explains the data was verified during onboarding and to contact support to change it



**Scenario 3 — Rating and language sections**
- Given the driver is on her profile screen
- Then her aggregate rating is shown with number of rating.
- And her current language preference is shown with a toggle to change it

**Scenario 4 — Network error**
- Given the profile request fails
- Then a bilingual toast error is shown
- And a retry option is available

### Out of Scope
- Editing any profile or vehicle field (deferred to onboarding-maturity work)
- Profile photo change / document re-upload (deferred with resubmission)
- Phone number change
- Account deletion
- SOS functionality

### Dependencies
- #1800 — Driver retrieves her profile (API — must be live)
- #1792 — Driver views her overall rating (rating display)
- #1731 — Driver changes language preference from profile screen

---

### Feature 18 — Driver Earnings

---

## [Mobile] #1736 — Driver views earnings dashboard 🆕
**Feature:** Feature 18 — Driver Earnings | **Sprint:** 2

**Description:** As a driver, I want to view a summary of my earnings so that I can track my income and performance over time.

### Background

The earnings dashboard is accessible from the driver home screen menu or profile screen. It shows earnings summary cards for today, this week, and this month. Each card shows total earnings in EGP and number of trips completed. Below the summary cards, a list of recent trips shows each trip's date, route summary, and fare. Data is fetched from #1735 on screen load. Pull-to-refresh updates all figures.

### Acceptance Criteria

**Scenario 1 — Driver sees earnings summary on load**
- Given an authenticated driver navigates to the earnings dashboard
- When the screen loads
- Then summary cards show total EGP and trip count for today, this week, and this month
- And figures are fetched from #1735

**Scenario 2 — Zero earnings displayed correctly**
- Given the driver has completed no trips in the current period
- When the earnings dashboard loads
- Then the relevant summary card shows "0 جنيه" / "0 EGP" and "0 رحلات" / "0 trips"
- And no error state is shown

**Scenario 3 — Recent trip list is shown below summary**
- Given the driver has completed at least one trip
- When the earnings dashboard loads
- Then a list of recent trips is shown below the summary cards
- And each item shows the trip date, pickup area to destination area, and fare in EGP

**Scenario 4 — Pull-to-refresh updates figures**
- Given the driver is on the earnings dashboard
- When she pulls down to refresh
- Then a loading indicator is shown
- And updated figures are fetched from #1735

**Scenario 5 — Network error on load**
- Given the device has no connectivity when the screen loads
- Then an error state is shown: "تعذر تحميل الأرباح. تحقق من اتصالك" / "Unable to load earnings. Check your connection."
- And a retry button is visible

### Out of Scope
- Earnings breakdown by individual day within a week
- Export or download of earnings report
- Tip amounts

### Dependencies
- #1735 — Driver retrieves earnings summary (API — must be live)

---

## [Mobile] #1788 — Driver views cash balance owed to the platform 🆕
**Feature:** Feature 18 — Driver Earnings | **Sprint:** Phase 1

**Description:** As a driver, I want to see how much cash I owe the platform so that I know what I need to settle.

### Background

A balance view reachable from the earnings/home area shows the driver's outstanding cash owed to the platform in EGP, retrieved via #1781. It explains that for cash trips she keeps the fare and owes the platform its commission, and it lists the contributing trips and the last settlement. The view is read-only — settlement itself is an operational process handled by Finance. All strings flow through data-i18n keys with Arabic fallback.

### Acceptance Criteria

**Scenario 1 — Driver opens her balance**
- Given an authenticated approved driver opens the balance view
- When it loads
- Then her outstanding cash owed to the platform is shown in EGP

**Scenario 2 — Balance reflects a completed cash trip**
- Given the driver completes a cash trip
- When she opens her balance
- Then the trip's commission portion is included in the outstanding total

**Scenario 3 — Card trips do not change the cash-owed total**
- Given the driver completes a card-paid trip
- When she opens her balance
- Then the outstanding total is unchanged by that trip

**Scenario 4 — Last settlement is shown**
- Given a settlement was recorded against the driver
- When she opens her balance
- Then the last settlement amount and date are shown

**Scenario 5 — New driver with no cash trips**
- Given a driver with no cash trips
- When she opens her balance
- Then a zero-balance state is shown

**Scenario 6 — Network error**
- Given the balance request fails
- Then a bilingual toast error is shown

### Out of Scope
- In-app settlement payment by the driver
- Automated payouts
- In-app driver wallet

### Dependencies
- #1781 — Driver retrieves cash balance owed to the platform (API — must be live)

---

### Feature 20 — Trip Cancellation (Driver)

---

## [Mobile] #1722 — Driver cancels an accepted trip 🆕
**Feature:** Feature 20 — Trip Cancellation | **Sprint:** 2

**Description:** As a driver, I want to cancel an accepted trip and choose a reason so that I can handle unexpected situations, and I am only charged a cancellation fee when I cancel late for reasons within my control.

### Background

The driver can cancel at two points: while navigating to the pickup (en_route_pickup) or after confirming arrival (arrived_pickup). Cancellation is not available once the trip has started (trip_started). When the driver taps Cancel Trip she must select a cancellation reason from a list (rider no-show, rider unreachable, vehicle issue, safety concern, wrong pickup location, other). Before she confirms, the dialog tells her whether a fee will apply: no fee within the driver cancellation grace period; the driver cancellation fee amount after it; and no fee for a rider no-show once she has marked arrived and the rider no-show wait time has elapsed. The Rider no-show fee-free option only becomes available after arrival once that wait time has passed — a countdown shows the remaining time. The cancellation request (with the reason) calls #1720. On success the driver's status returns to online/available and the rider receives a push notification.

**Scenario 1 — Driver cancels while en route within the grace period — no fee**
- Given the trip is in en_route_pickup and the driver cancellation grace period has not expired
- When the driver taps Cancel Trip, selects a reason, and confirms
- Then the trip is cancelled with no fee
- And the rider receives a push notification: "Your driver has cancelled. We are finding you a new driver."
- And the driver's status returns to online/available

**Scenario 2 — Driver cancels after the grace period — fee warning shown**
- Given the trip is past the driver cancellation grace period
- When the driver taps Cancel Trip and selects a reason that is not a qualifying rider no-show
- Then the confirmation dialog shows the driver cancellation fee amount that will apply
- And on confirm the trip is cancelled, the fee is recorded, and the rider is notified

**Scenario 3 — Driver cancels a rider no-show after the wait time — no fee**
- Given the trip is in arrived_pickup and the rider no-show wait time has elapsed
- When the driver selects Rider no-show and confirms
- Then the trip is cancelled with no fee
- And the rider is notified and the driver's status returns to online/available

**Scenario 4 — No-show wait time not yet elapsed**
- Given the trip is in arrived_pickup but the rider no-show wait time is still counting down
- Then the fee-free Rider no-show option is disabled and shows the remaining wait time
- And cancelling now under any other reason shows that the driver cancellation fee will apply

**Scenario 5 — Reason is required**
- Given the driver taps Cancel Trip
- When no reason is selected
- Then the confirm action is disabled until a reason is chosen

**Scenario 6 — Driver dismisses the cancellation dialog**
- Given the driver taps Cancel Trip
- When the confirmation dialog appears and the driver taps Go Back
- Then the dialog is dismissed, the driver remains on the current screen, and the trip is not cancelled

**Scenario 7 — Cancel button is not shown after the trip starts**
- Given the trip is in trip_started state
- Then no cancel trip button is visible on the active trip screen

**Scenario 8 — Network error during cancellation**
- Given the driver confirms cancellation
- When the network request fails
- Then a toast message is shown: "Unable to cancel. Please try again."
- And the driver remains on the current screen

### Out of Scope
- Driver cancellation after the trip starts
- Driver appeal/dispute of the cancellation fee (Phase 2)
- Rider-initiated cancellation (separate story)

### Dependencies
- #1720 — Driver cancels an accepted trip (API — must be live)
- #1652 — Driver advances trip state machine (must be live)
- #1758 — Super admin configures cancellation policy (drives the fee, grace period, and wait time shown)

---

