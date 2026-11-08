# SheDrive — Mobile Driver Stories
> Canonical backlog for all [Mobile] Driver stories. Organized by sprint and feature.
> Last updated: 2026-11-08
> Stories with changes from original are marked ✏️ | New stories marked 🆕

---

## Sprint 1

### Feature 3 — Driver Authentication

---

## [Mobile] #1569 — Driver registers and is directed to onboarding
**Feature:** Feature 3 — Driver Authentication | **Sprint:** 1

**Description:** As a driver, I want to register an account using my phone number, a one-time passcode, my basic identity details (full name, date of birth, and National ID), and my consent to a background check so that I can begin the onboarding process to become a verified SheDrive driver.

### Background

The driver registration flow mirrors rider registration (two screens: phone entry then OTP + full name, date of birth, and National ID) but diverges at success: instead of landing on a home screen, the driver is taken directly to the onboarding flow. A driver with no completed or approved onboarding cannot reach the driver home/availability screen. She must also accept a background-check consent before the account is created. The OTP rules (5-minute expiry, 3-attempt limit, 60-second resend cooldown) are identical to rider registration.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| رقم الهاتف | Yes | 11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped | 11 digits | 11 digits | Digits only (after prefix stripping) | أدخل رقم هاتفك | رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً | رقم الهاتف يجب أن يكون 11 رقماً |
| OTP | Yes | 6 digits, numeric keyboard | 6 digits | 6 digits | Digits only | أدخل رمز التحقق | رمز التحقق غير صحيح | رمز التحقق يجب أن يكون 6 أرقام |
| الاسم الكامل | Yes | Arabic and/or Latin letters and spaces only; no digits or symbols | 2 chars | 50 chars | Arabic letters, Latin letters, spaces | أدخل اسمك الكامل | الاسم يجب أن يحتوي على حروف فقط | الاسم يجب أن يكون بين 2 و 50 حرفاً |
| تاريخ الميلاد | Yes | DD/MM/YYYY; age ≥ 18 | — | — | Digits and "/" separator | أدخلي تاريخ ميلادك | صيغة التاريخ غير صحيحة | يجب أن يكون عمرك 18 عامًا على الأقل |
| الرقم القومي (NID) | Yes | 14-digit numeric | 14 digits | 14 digits | Digits only | أدخلي رقم الهوية الوطنية | رقم الهوية يجب أن يكون 14 رقمًا | رقم الهوية يجب أن يكون 14 رقمًا |
| الموافقة على فحص الخلفية | Yes | Checkbox (must be checked) | — | — | — | يجب الموافقة على إجراء فحص الخلفية | — | — |

### Acceptance Criteria

**Scenario 1 — Successful registration redirects to onboarding**
- Given a new driver opens the driver app and taps "إنشاء حساب"
- When she enters a valid Egyptian mobile number, receives and enters the correct 6-digit OTP, and enters a valid full name, date of birth (age ≥ 18), and 14-digit National ID, and accepts the background-check consent
- Then her account is created and she is taken to the onboarding flow
- And she cannot navigate to the driver home screen until onboarding is approved

**Scenario 2 — Phone number already registered auto-logs the driver in**
- Given a driver enters a phone number already linked to an existing account
- When she proceeds through OTP + identity entry and submits, #1621 detects the existing account and auto-logs her in
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

**Scenario 7 — Driver is underage**
- Given the driver enters a date of birth that makes her younger than 18 years old
- When she taps "إنشاء حساب"
- Then the app displays "يجب أن يكون عمرك 18 عامًا على الأقل" and the account is not created

**Scenario 8 — National ID is not 14 digits**
- Given the driver enters a National ID that is not exactly 14 digits or contains non-digit characters
- When she taps "إنشاء حساب"
- Then the app displays "رقم الهوية يجب أن يكون 14 رقمًا" and the account is not created

**Scenario 9 — Background-check consent is required**
- Given the driver has entered valid details but has not ticked the background-check consent checkbox
- When she taps "إنشاء حساب"
- Then the account is not created and the error "يجب الموافقة على إجراء فحص الخلفية" is shown
- And when she ticks the checkbox and taps "إنشاء حساب", the account is created

**Scenario 10 — Network error during OTP request**
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

## [Mobile] #5039 — Driver deletes her account 🆕
**Feature:** Feature 3 — Driver Authentication (#1538) | **Sprint:** Backlog (not scheduled)

**Description:** As a driver, I want to delete my SheDrive account from inside the app, so that I can stop driving with SheDrive and have my personal data removed without having to contact anyone.

### Background

The App Store and Google Play both require in-app account deletion, so this story must ship before the driver app is submitted. It follows the rider flow (#5038) step for step, with what a driver additionally needs to know: she is taken offline, and money between her and SheDrive is handled first.

She opens the Delete Account screen from a **Delete account** link at the bottom of her profile (#1801). The screen is one short confirmation, not a list. She re-confirms her number with a one-time code, and the request is made (#5037). She is taken offline and signed out at once, and has **30 days to change her mind** by signing in again. After that her **number can never sign up again**.

**Two things block the request: a trip in progress, and money she owes SheDrive.** The second has a way through — she settles (#3989), and can ask again as soon as the settlement is recorded. Money SheDrive owes her never blocks her.

All strings flow through `data-i18n` keys with Arabic fallback text in the HTML, and every step lays out correctly in LTR and RTL.

### Screen layout

| Step | Shows | Behaviour |
|---|---|---|
| Review | Title, one sentence that she goes offline and the account closes at once and is deleted after 30 days, an amber warning that she can't sign up again with this number, and a one-line note on the records SheDrive keeps | Continue opens Confirm it's you |
| Owed-to-her note | A blue note with the amount SheDrive owes her and that finance will contact her on this number to transfer it, even after the account is deleted | Information only |
| Blocked — balance owed | Settle your balance first, with the amount and How to settle | Replaces Review. How to settle opens the settle screen (#3989) |
| Blocked — trip in progress | Finish your trip first, with Back to my trip | Replaces Review |
| Confirm it's you | Six-box code input, her full number, resend with countdown | Delete my account submits the code |
| Request received | The exact deletion date and that signing in before it keeps the account | Done opens the sign-in screen |
| Restore at sign-in | After the sign-in code: the deletion date, Restore my account, Continue with deletion | The Login / Register switch and the terms line are hidden on this step |

### Field Validation

Same as the rider flow (#5038): a six-digit code with the sign-in error messages (#1570).

### Acceptance Criteria

**Scenario 1 — Driver opens Delete Account from her profile**
- Given an authenticated driver on her profile
- When she taps Delete account at the bottom of her profile
- Then the Review step opens with a note that confirming takes her offline straight away

**Scenario 2 — Review is one short confirmation**
- Given the Review step is open
- Then it says she goes offline and the account closes straight away, and it is deleted after 30 days unless she signs in before then
- And an amber warning says she won't be able to sign up again with this number
- And one line says trip, earnings and safety records are kept only as long as the law requires
- And Continue is enabled straight away; there is no list, no reason to choose and no checkbox

**Scenario 3 — Money she owes blocks the request**
- Given she owes SheDrive 245 EGP
- When she opens Delete Account
- Then Settle your balance first is shown with the 245 EGP instead of Review
- And How to settle opens the settle screen (#3989)

**Scenario 4 — She can delete once she has settled**
- Given she was blocked by a balance and her settlement has since been recorded
- When she opens Delete Account again
- Then the Review step opens as normal

**Scenario 5 — A trip in progress blocks the request**
- Given she has accepted a trip that is not yet completed or cancelled
- When she opens Delete Account
- Then Finish your trip first is shown with Back to my trip

**Scenario 6 — Money SheDrive owes her is shown but does not block**
- Given SheDrive owes her 320 EGP
- When she opens Delete Account
- Then a blue note shows the 320 EGP and says the finance team will contact her on this number to transfer it, even after the account is deleted
- And she can continue as normal

**Scenario 7 — She confirms it is her**
- Given she taps Continue on Review
- Then a code is sent to her registered number and Confirm it's you shows her full number
- And a wrong, expired or incomplete code shows the same messages as sign-in and deletes nothing

**Scenario 8 — The request is received and she is taken offline**
- Given she submits the correct code while online
- Then she is taken offline and receives no further trip requests
- And Request received shows the exact deletion date and how to restore
- And she is signed out on every device, and Done opens the sign-in screen

**Scenario 9 — She changes her mind before confirming**
- Given she is on Review or Confirm it's you
- When she taps Keep my account or the back arrow
- Then she returns to her profile, her online status is unchanged, and nothing about her account has changed

**Scenario 10 — Signing in during the window offers her account back**
- Given her account is waiting to be deleted
- When she signs in or registers with her number and code (#1570)
- Then she sees that the account is due to be deleted on its date, with Restore my account and Continue with deletion

**Scenario 11 — Restoring does not put her online**
- Given the restore step is shown
- When she taps Restore my account
- Then she is routed exactly as after a normal sign-in (#1570)
- And she is offline until she goes online herself

**Scenario 12 — Continuing with the deletion changes nothing**
- Given the restore step is shown
- When she taps Continue with deletion
- Then she stays signed out and the deletion keeps its date

**Scenario 13 — A deleted number can't sign up again**
- Given her deletion has completed
- When the same number enters a correct code, in Login or Register
- Then she stays on the phone step with "This number belonged to a deleted SheDrive Driver account and can't be used to sign up again"
- And no account or application is created

**Scenario 14 — Network error while requesting**
- Given the app cannot reach the platform
- When she asks for a code or submits one
- Then an error toast is shown, she stays on the same step, and her account and online status are unchanged

**Scenario 15 — Arabic and English**
- Given the driver switches language
- Then every label, note, amount, button and error on every step, including the deletion date, is shown in the selected language
- And the screens lay out correctly in RTL

**Scenario 16 — A blocked national ID can't start a new application**
- Given an earlier account with her national ID was deleted while suspended or reported (#5037)
- When she submits an onboarding application with that national ID from a new number
- Then the application is not submitted and she sees "This national ID can't be used for a new application. Please contact support."

### Out of Scope
- A public web page for people without the app — removed from scope
- Settling inside this flow — the existing settle screen (#3989) is linked, not duplicated
- Choosing how the money SheDrive owes her is paid — finance handles it as today
- Downloading a copy of her data
- Deleting an account while the onboarding application is in review or rejected — she is not a driver yet and has no profile, so there is no Delete account link to reach (#1576)
- A suspended driver deleting her account — she cannot sign in (#1742), so she can delete only once reinstated; accepted gap for now

### Dependencies
- #5037 — Driver account deletion is requested, restored and completed (API — must be live)
- #1801 — Driver views her profile (the Delete account link)
- #1570 — Driver logs in (the restore step follows its code step)
- #1579 — Driver toggles online and offline (she is taken offline on confirming)
- #3989 — Driver settles what she owes and sees her settlement history (How to settle)
- #5015 — [Driver] Delete Account (design)

---

## [Mobile] #5721 — Driver sees her notifications and opens what each one is about 🆕
**Feature:** #1538 Driver Authentication | **Sprint:** — | **Tag:** Notification inbox

**Description:** As a driver, I want one list of everything SheDrive has told me about my earnings, balance, documents and trips, where tapping a notification opens what it is about, so that I never miss a settlement, a limit warning or an expiring document.

### Rules
- The inbox works as in #5720; only the differences are listed here.
- Entry points: a bell with an unread badge in the home bottom bar next to her avatar, Notifications on her profile menu, any push.
- Categories: trips, safety, earnings, documents & account, announcements.

| Notification | Opens |
|---|---|
| Settlement or payout sent | Balance |
| Failed payout | Payout method |
| Nearing the balance limit | Settle |
| Expiring licence or registration | My Profile |
| Rating, cancelled trip, cancellation fee | That trip in Trip history |
| Approval message, announcements | Home |

- Empty state hint: "Updates on your earnings, documents and SheDrive announcements will show up here."

### Acceptance Criteria
**Scenario 1 — Settlement while she was offline**
- Given the office recorded her 250 EGP settlement at 10:05 while her app was closed
- When she opens the inbox
- Then "Settlement received — We received 250 EGP. You don't owe anything now." is unread under New, and tapping it opens Balance

**Scenario 2 — Close to the limit**
- Given she owes 2,650 of a 3,000 EGP limit
- When she taps "You're close to your balance limit"
- Then Settle opens

**Scenario 3 — A trip request is not kept**
- Given she received a trip request at 14:00 and let it expire
- When she opens the inbox
- Then there is no item for that request

### Out of Scope
- As in #5720
- Trip requests in the inbox

### Dependencies
- #5723 [API] Driver notification inbox is listed and marked read
- #5720 [Mobile] Rider sees her notifications and opens what each one is about — the shared inbox rules
- #4915 [Driver] Notification Inbox — design

### Mockup (ADO comment)
- Inbox: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/notifications.html
- All unread: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/notifications.html?state=unread
- Empty: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/notifications.html?state=empty
- Bell on home: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html
- Figma — Notifications: https://www.figma.com/design/KKPU4knlJ3AnrCfwjapyg9/SheDrive-App?node-id=2585-3358
- Figma — Unread: https://www.figma.com/design/KKPU4knlJ3AnrCfwjapyg9/SheDrive-App?node-id=2588-4277
- Figma — Caught up: https://www.figma.com/design/KKPU4knlJ3AnrCfwjapyg9/SheDrive-App?node-id=2590-4609

---

### Feature 5 — Driver Onboarding & Admin Approval

---

## [Mobile] #1854 — Driver captures her National ID photo 🆕
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to upload clear photos of the front and back of my National ID during onboarding so that SheDrive can verify my identity document.

### Background

The National ID capture screen is a step of the onboarding wizard, before the vehicle-details step. The driver uploads two photos — the front and back of her National ID card — using the device camera or gallery. Both photos are required before she can advance. Files must be JPEG, PNG or HEIC, max 10 MB each. This complements the typed 14-digit National ID number captured at registration (#1569).

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
- #1569 — Driver registers (typed National ID number captured at registration)

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

## [Mobile] #1575 — Driver uploads licence and vehicle registration documents ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As a driver, I want to upload my driving licence and vehicle registration documents in Step 4 of the onboarding wizard so that SheDrive can verify my eligibility to drive.

### Background

The documents screen is Step 4 of the multi-step onboarding wizard. The driver uploads four documents — driving licence front, driving licence back, vehicle registration front, and vehicle registration back — and enters three typed fields: her **driving licence number**, her **driving licence expiry date**, and her **vehicle registration expiry date**. Each document is a separate file upload; both expiry dates must be in the future (the document must not be expired). When all four documents and the three typed fields are provided and valid, the driver taps "Submit" to send the full application. On success, she is navigated to the pending state screen (#1576).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Driving licence — front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Driving licence — back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Vehicle registration — front | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Vehicle registration — back | Yes | JPEG, PNG, or PDF | — | 10 MB | — | يرجى رفع هذه الوثيقة | يرجى رفع صورة أو ملف PDF | حجم الملف كبير جداً، الحد الأقصى 10 ميجابايت |
| Driving licence number | Yes | Alphanumeric | 6 | 20 | Letters and digits | أدخلي رقم رخصة القيادة | رقم الرخصة غير صحيح | يجب أن يكون رقم الرخصة بين 6 و20 خانة |
| Driving licence expiry date | Yes | DD/MM/YYYY, future date | — | — | Digits and "/" separator | أدخلي تاريخ انتهاء رخصة القيادة | صيغة التاريخ غير صحيحة | رخصة القيادة منتهية الصلاحية |
| Vehicle registration expiry date | Yes | DD/MM/YYYY, future date | — | — | Digits and "/" separator | أدخلي تاريخ انتهاء رخصة تسيير السيارة | صيغة التاريخ غير صحيحة | رخصة تسيير السيارة منتهية الصلاحية |

### Acceptance Criteria

**Scenario 1 — Happy path: all four documents uploaded, application submitted**
- Given the driver has uploaded all four valid documents and entered a valid licence number and non-expired licence and vehicle-registration expiry dates
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

**Scenario 6 — Licence number required and validated**
- Given the driver leaves the driving licence number empty or enters fewer than 6 or more than 20 characters
- When she taps "Submit"
- Then the licence number field shows "أدخلي رقم رخصة القيادة" (empty) or "يجب أن يكون رقم الرخصة بين 6 و20 خانة" (length)
- And the submission is blocked until a valid licence number is entered

**Scenario 7 — Driving licence must not be expired**
- Given the driver leaves the licence expiry date empty or enters a date that is today or in the past
- When she taps "Submit"
- Then the licence expiry field shows "أدخلي تاريخ انتهاء رخصة القيادة" (empty) or "رخصة القيادة منتهية الصلاحية" (expired)
- And the submission is blocked until a future expiry date is entered

**Scenario 8 — Vehicle registration must not be expired**
- Given the driver leaves the registration expiry date empty or enters a date that is today or in the past
- When she taps "Submit"
- Then the registration expiry field shows "أدخلي تاريخ انتهاء رخصة تسيير السيارة" (empty) or "رخصة تسيير السيارة منتهية الصلاحية" (expired)
- And the submission is blocked until a future expiry date is entered

### Out of Scope
- Document authenticity verification against government databases
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

## [Mobile] #3988 — Driver is blocked from going online while her balance is over the limit 🆕
**Feature:** Feature 6 — Driver Home & Availability | **Sprint:** Phase 1

**Description:** As a driver, I want to be told clearly why I cannot go online and exactly what I owe when my balance is over the limit so that I can settle up and get back to work instead of guessing why the toggle will not turn on.

### Background

When the driver taps the online toggle on her home screen and the availability service refuses her because her outstanding balance is at or above the configured limit (#3996), the app must explain the block rather than silently snapping the toggle back.

The toggle returns to offline and a sheet explains that she owes more than the limit, states the amount owed and the limit, and offers a direct "Settle now" action that opens her settlement screen (#3989) with the channels, office address and hours she needs — after Finance records the settlement, her balance clears and she can go online again. Settle now is the sheet's only action; she dismisses the sheet by swiping it down.

**Warned before she is blocked.** From the configured warning threshold (default 80% of the limit, set via #3994), her home screen carries a persistent warning band so the block never arrives as a surprise. The band states what she owes and the limit.

**She is never cut off mid-trip.** The block applies only when she asks to go online. A driver already online — and certainly one on a trip — is left alone, consistent with #3996.

All strings flow through data-i18n keys with Arabic fallback, and all amounts are in EGP.

### Acceptance Criteria

**Scenario 1 — Blocked when she tries to go online**
- Given the driver owes 500 EGP against a 500 EGP limit
- When she taps the online toggle
- Then the toggle returns to offline
- And a sheet reads "لا يمكنكِ الاتصال حتى تسدّدي رصيدك" / "You cannot go online until you settle your balance"
- And the amount owed and the limit are both shown

**Scenario 2 — Sheet offers a direct path to settle**
- Given the blocked sheet is displayed
- Then a "سدّدي الآن" / "Settle now" action opens the settlement screen (#3989) with the channels, office address and hours
- And it is the sheet's only action — there is no View balance or Close button; she dismisses the sheet by swiping it down

**Scenario 3 — Warning band before the limit**
- Given the limit is 500 EGP and she owes 400 EGP
- When her home screen loads
- Then a warning band reads "اقتربتِ من حد الرصيد ([owed] من [limit] جنيه). سدّدي لتفادي إيقاف العمل." / "You are close to the balance limit ([owed] of [limit] EGP). Settle up to keep working."
- And she can still go online normally

**Scenario 4 — No band below the warning threshold**
- Given she owes 100 EGP against a 500 EGP limit
- Then no warning band is shown and the toggle behaves normally

**Scenario 5 — Settling unblocks her immediately**
- Given she was blocked and Finance records a settlement (#1813) that brings her outstanding amount below the limit
- When she taps the online toggle again
- Then she goes online normally with no further action, no waiting period and no need to close and reopen the app

**Scenario 6 — Already online is never interrupted**
- Given the driver is online and her balance crosses the limit
- Then she is not forced offline, any trip in progress continues
- And the block applies only the next time she tries to go online

**Scenario 7 — Approval block takes precedence**
- Given a driver who is not yet approved and also over the limit
- When she taps the toggle
- Then the existing approval message (#1644) is shown and the balance sheet is not

**Scenario 8 — Limit disabled**
- Given the outstanding balance limit is configured as 0 (#3994)
- Then no warning band and no balance block are ever shown

**Scenario 9 — Network error on the toggle**
- Given the go-online request fails for a network reason
- Then the existing connection-error toast is shown rather than the balance sheet

**Scenario 10 — Arabic and English**
- Given the driver switches language
- Then the warning band, sheet copy, amounts, and actions are displayed in the selected language

### Out of Scope
- Paying the balance inside the app
- Forcing an online driver offline when she crosses the limit
- Automatic suspension of a persistently over-limit driver (Phase 2)
- The balance statement itself (#1788)
- The settlement screen itself (#3989) — this story only launches it

### Dependencies
- #3996 — Driver go-online is blocked while her outstanding balance is over the limit (API — must be live)
- #3994 — Super admin configures balance and fee policy (supplies the limit and the warning threshold)
- #3989 — Driver settles what she owes and sees her settlement history (opened from the sheet's "Settle now" action)
- #1578 — Driver sees home screen with map (hosts the toggle and the warning band)

---

### Feature 9 — Driver Trip Acceptance

---

## [Mobile] #1581 — Driver receives push for incoming trip request ✏️
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to receive a push notification when a new trip request is assigned to me so that I can respond within the acceptance window even if the app is in the background.

### Background

When the platform dispatches a trip to a matched driver (#1647), a push notification is sent to the driver's registered device. The notification displays the pickup area and estimated fare so the driver can make an informed decision before opening the app. Tapping the notification opens the trip request details screen (#1582) with the 30-second countdown already running. The acceptance window duration is the value configured by the super admin (#1759, default 30 seconds) — it is never hardcoded in the app. If the driver does not tap the notification in time, the countdown expires on the server side regardless, and the screen auto-dismisses if the driver opens the app late.

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
- And if the 30-second window has already expired by the time the screen loads, the screen shows "Request expired" and the driver returns to her home screen

**Scenario 4 — Driver's device token is not registered**
- Given the driver's push notification token is not on file
- When the platform dispatches a trip to her
- Then the push silently fails
- And after the 30-second window elapses with no response, the system treats it as a timeout and reassigns the trip (#1651)

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

**Description:** As a driver, I want to see full trip request details with a countdown timer so that I can decide to accept or reject within the 30-second window.

### Background

When a driver receives a trip request (via push notification or app foreground transition), she is shown a full-screen or modal trip request details screen. The screen displays the pickup address, destination summary, estimated distance, and estimated fare. A 30-second countdown timer is prominently visible and begins immediately when the screen loads. The countdown length is not hardcoded — it is seeded from the acceptance window configured by the super admin (#1759, default 30 seconds) and delivered with the dispatch payload (#1648). Two action buttons are shown: "Accept" and "Reject." If the timer reaches zero without action, the screen auto-dismisses, a brief "Request expired" message is shown, and the driver returns to her home/available screen. The system treats the non-response as a rejection and reassigns the trip.

### Acceptance Criteria

**Scenario 1 — Trip request details screen displays correctly**
- Given a trip has been dispatched to the driver
- When the trip request details screen loads
- Then the pickup address is displayed
- And the destination summary is displayed
- And the estimated distance is displayed
- And the estimated fare is displayed
- And a 30-second countdown timer is prominently shown, seeded from the configured acceptance window (#1759)
- And "Accept" and "Reject" buttons are both visible and tappable

**Scenario 2 — Countdown timer counts down visibly**
- Given the trip request details screen is open
- When time passes
- Then the countdown timer decrements visibly second by second
- And the timer urgency is communicated clearly (e.g., color change at the last 5 seconds)

**Scenario 3 — Timer expires without driver action**
- Given the driver does not tap Accept or Reject within 30 seconds
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
- #1649 — Driver accepts trip (API — must be live; the merged trip-details scenarios supply the remaining seconds in the window)
- #1759 — Super admin configures the driver acceptance window (default 30 seconds)

---

## [Mobile] #1583 — Driver accepts trip
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want to tap "Accept" on the trip request screen so that the trip is confirmed and I can begin navigating to the rider's pickup location.

### Background

When the driver taps "Accept" within the 30-second window (the configured acceptance window, #1759), the app calls the accept endpoint (#1649). On success, the trip status is updated to accepted, and the driver is taken to the navigation-to-pickup screen (active trip feature). Simultaneously, the rider receives a push confirmation that her driver is on the way (#1634). If the acceptance window has already expired server-side (e.g., due to network lag), the endpoint returns a conflict and the driver sees an expired message and returns to her home screen.

### Acceptance Criteria

**Scenario 1 — Successful acceptance within window**
- Given the driver taps "Accept" while the countdown is still running
- When the acceptance request reaches the server within the 30-second window
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

A driver may choose to reject a trip request within the 30-second window (the configured acceptance window, #1759). Tapping "Reject" calls the rejection endpoint (#1650), which marks the driver as available again and triggers reassignment of the trip to the next nearest driver by ETA to pickup (#1651). The driver returns to her home/available screen immediately. No penalty or strike is applied in this sprint. If the window has already expired server-side, the rejection call returns a conflict (the rejection is effectively a no-op since the system has already treated it as a timeout).

### Acceptance Criteria

**Scenario 1 — Successful rejection within window**
- Given the driver taps "Reject" while the countdown is still running
- When the rejection request reaches the server within the 30-second window
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

## [Mobile] #1585 — Driver acceptance screen expires after the acceptance window (30 seconds) ✏️
**Feature:** Feature 9 — Driver Trip Acceptance | **Sprint:** 2

**Description:** As a driver, I want the acceptance screen to automatically dismiss after 30 seconds if I do not respond so that I am not left on a stale screen and the system can reassign the trip promptly.

### Background

If the driver neither accepts nor rejects within the 30-second window, the platform server-side timer expires and triggers reassignment (#1651). The window length is the acceptance window configured by the super admin (#1759, default 30 seconds); the app renders whatever duration the dispatch payload carries rather than a hardcoded value. On the client side, the countdown UI reaches zero and automatically dismisses the screen. A brief "Request expired" toast or message is displayed so the driver understands what happened. The driver is returned to her home/available screen and remains online. This behavior mirrors a rejection from the platform's perspective.

### Acceptance Criteria

**Scenario 1 — Screen auto-dismisses at countdown zero**
- Given the driver is on the trip request details screen and does not tap either button
- When the 30-second countdown reaches zero
- Then the screen automatically dismisses without requiring any driver action
- And a brief message is shown: "Request expired"
- And the driver is returned to her home/available screen

**Scenario 2 — Driver remains online after expiry**
- Given the acceptance screen has expired
- When the driver is back on her home/available screen
- Then her online status is preserved
- And she remains eligible for the next dispatched trip

**Scenario 3 — System reassigns the trip**
- Given the driver's 30-second window has expired
- When the server processes the timeout
- Then the trip is passed to the next available driver in the ETA-ranked candidate list (#1651)
- And the current driver is not double-dispatched for the same trip

**Scenario 4 — App in background during countdown**
- Given the driver received the push notification but did not open the app
- When 30 seconds elapse from dispatch
- Then the server-side timer expires and reassigns the trip
- And if the driver later opens the app, no acceptance screen is shown for the expired request
- And a brief "Request expired" message is shown if the screen was mid-open

### Out of Scope
- Any driver-side control over the acceptance window duration (it is set by the super admin in #1759)
- Penalty or strike for timeout (future sprint)
- Notification to driver that she missed a request (beyond the brief toast)

### Dependencies
- #1651 — Trip is reassigned on rejection or timeout (API — must be live)
- #1759 — Super admin configures the driver acceptance window (supplies the window duration)

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

## [Mobile] #4093 — Driver app gates "I've Arrived" on the pickup geofence 🆕
**Feature:** Feature 10 — Active Trip | **Sprint:** TBD

**Description:** As a driver, I want the app to confirm that I am actually at the rider's pickup point before it lets me tap "I've Arrived", so that I do not mark arrival from the wrong street and start the rider's waiting counter unfairly.

### Background

Story #1587 lets the driver advance the trip from *en_route_pickup* to *arrived_pickup* by tapping "I've Arrived". That tap starts the rider waiting counter (#1767) and opens the fee-free rider no-show path (#1720), so an arrival marked from far away costs the rider money and time. This story adds the pickup geofence check that gates that button in the driver app.

The check is a **driver-app guardrail**: the app compares the driver's current GPS position with the trip's pickup coordinates and enables or disables the "I've Arrived" button accordingly. It is deliberately scoped to the driver app only — server-side enforcement of the same rule is not part of this story (see Out of Scope).

The driver is never left stuck: whenever the button is disabled the app states the reason and the live distance to the pickup point, and re-evaluates on every GPS sample so the button enables by itself as she gets closer.

### Geofence Parameters

| Parameter | Value | Notes |
|---|---|---|
| Pickup geofence radius | 150 m | Measured from the trip's pickup coordinates. Delivered with the trip payload so it can be tuned without an app release; the app falls back to 150 m if the value is absent. |
| Distance measure | Straight-line distance | Device position to pickup point. Driving distance and ETA are not used for this check. |
| GPS accuracy threshold | 100 m | A reported horizontal accuracy worse than this is treated as a weak signal. |
| Weak-signal effective radius | Radius + reported accuracy, capped at 300 m | Keeps the driver moving in dense Cairo/Giza streets where accuracy degrades. |
| Maximum position age | 10 seconds | An older sample is treated as no position. |
| Re-evaluation | On every GPS sample | Uses the existing driver GPS stream (#1653); no separate polling loop. |

### Acceptance Criteria

**Scenario 1 — Driver inside the geofence can confirm arrival**
- Given the trip is in en_route_pickup state
- And the driver's current position is within the pickup geofence radius
- When the driver views the active trip screen
- Then the "I've Arrived" button is enabled
- And tapping it advances the trip to arrived_pickup exactly as described in #1587

**Scenario 2 — Driver outside the geofence is blocked with the distance shown**
- Given the trip is in en_route_pickup state
- And the driver's current position is outside the pickup geofence radius
- When the driver views the active trip screen
- Then the "I've Arrived" button is disabled
- And the screen shows the reason together with the current straight-line distance to the pickup point (for example "You are 480 m away — get closer to confirm arrival")
- And the trip state does not change

**Scenario 3 — Button enables by itself as the driver approaches**
- Given the driver is outside the geofence and the "I've Arrived" button is disabled
- When a new GPS sample places her inside the radius
- Then the button becomes enabled without any manual refresh, retry, or screen re-entry
- And the displayed distance updates as she moves

**Scenario 4 — Weak GPS accuracy widens the radius instead of blocking**
- Given the driver's latest position reports a horizontal accuracy worse than the accuracy threshold
- When the app evaluates the geofence
- Then it compares the distance against the weak-signal effective radius
- And the screen indicates that GPS accuracy is low
- And the driver can confirm arrival if she is within that widened radius

**Scenario 5 — No usable position blocks arrival and tells the driver how to fix it**
- Given location permission is denied, location services are off, or no position newer than the maximum age is available
- When the driver views the active trip screen in en_route_pickup state
- Then the "I've Arrived" button is disabled
- And the screen explains that the app needs her location to confirm arrival and offers a shortcut to the device location settings
- And there is no way to confirm arrival while no position is available

**Scenario 6 — All geofence messages are bilingual**
- Given the driver has selected Arabic or English
- When any geofence state is shown (blocked, distance hint, low accuracy, location disabled)
- Then every string is displayed in the selected language with correct RTL layout in Arabic
- And no message mixes Arabic and English

### Out of Scope
- Server-side enforcement of the geofence — this story adds the driver-app check only. There is currently no API story that owns the arrived_pickup write (#1652 is Removed in ADO), so the rule cannot be enforced on the server yet.
- Automatic arrival detection without a driver tap — the driver still taps "I've Arrived", as stated in #1587.
- Any geofence at the destination or on trip end (#1589 / #1591).
- Admin visibility, telemetry, or reporting of blocked arrival attempts.
- Rider-side geofence detection on the rider's device.
- Changing the rider waiting counter or the no-show fee rules.

### Dependencies
- #1587 — Driver confirms arrival at pickup (this story gates that button; #1587's Out of Scope line about geofence-based *automatic* arrival detection still stands)
- #1653 — Driver streams GPS from acceptance to completion (supplies the position samples)
- #1649 — Trip acceptance flow (supplies the pickup coordinates and the geofence radius on the trip payload)

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
- #1633 — Rider tracks her active trip (supplies the arrived_at timestamp the waiting counter runs from)

---

## [Mobile] #1588 — Driver verifies rider is female on first trip ✏️
**Feature:** Feature 10 — Active Trip | **Sprint:** 2

**Description:** As a driver, I want to check that the rider is female on her first trip, and cancel and report the trip if she is not, so that SheDrive stays a women-only service.

### Rules
- Runs on the waiting-at-pickup screen, only on the rider's first trip. Returning riders skip it and the driver sees "Start Trip" straight away.
- The check is mandatory: no skip or close, and the trip can't start until she taps "الراكبة مؤكدة — ابدئي" / "Rider Verified — Board".
- The screen shows the rider's registered full name.
- "إلغاء — الراكبة ليست أنثى" / "Cancel — Rider Not Female" opens the report sheet: "سيتم إلغاء الرحلة وإرسال تقرير أمان" / "This will cancel the trip and submit a safety report."
- The sheet has one optional field and "تأكيد وإرسال البلاغ" / "Confirm and submit report". Submitting ends the trip as Expired (reason gender_mismatch_report), puts the rider's account under review and sends the statement to the safety team (#1687).
- No fare is charged and the driver gets no penalty. After "تم إرسال البلاغ" / "Report submitted" → Done, she is back on home, still online.

### Field Validation
| Field | Required | Format | Max | Error |
|---|---|---|---|---|
| What happened? / ماذا حدث؟ | No | Free text, multi-line | 500 characters | يجب ألا يتجاوز النص 500 حرف / Must be 500 characters or fewer |

### Acceptance Criteria
**Scenario 1 — First trip, rider is female**
- Given Sara arrives for Nour Ahmed's first trip
- When she taps "Rider Verified — Board"
- Then "Start Trip" appears

**Scenario 2 — First trip, rider is not female**
- Given the person at the car is not female
- When Sara taps "Cancel — Rider Not Female", types "A man came to the car" and confirms
- Then the report is sent with her statement, the trip ends with no fare, and she is back on home and online

**Scenario 3 — Report with no statement**
- Given the report sheet is open and the field is empty
- When she confirms
- Then the report is sent with no error

**Scenario 4 — She leaves before verifying**
- Given a first trip she hasn't verified yet
- When she leaves the trip screen and comes back
- Then the verification step is shown again

**Scenario 5 — Returning rider**
- Given the rider has completed trips before
- When the driver arrives
- Then no verification step is shown

### Out of Scope
- The report option on later trips
- Camera or document identity checks
- Any exception to the women-only rule

### Dependencies
- #1687 [API] Rider account is placed under review after a gender mismatch report — Closed
- #3768 [Mobile] Rider is told her account is under review after a gender-mismatch report
- #1810 / #1811 [Admin] Gender-mismatch report queue and resolution — read the statement
- #4011 [Driver] First-trip rider verification and gender-mismatch report — design

### Mockup (ADO comment)

- Verify the rider (first trip): https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/trip.html?state=verify-rider
- Report sheet: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/trip.html?report=form
- Report submitted: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/trip.html?report=sent

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
- And a "استقبلي رحلة جديدة" / "Get a New Ride" button is available to dismiss the screen

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

Immediately after the driver taps "End Trip" and the trip state advances to trip_ended, the driver's screen shows a full-screen prompt displaying the cash amount to collect from the rider in EGP. A single "استقبلي رحلة جديدة" / "Get a New Ride" button is shown. When the driver taps "Get a New Ride", this screen is dismissed and the driver is returned to her home screen in the online/available state, ready to receive the next trip request.

### Acceptance Criteria

**Scenario 1 — Cash collection screen appears after ending trip**
- Given the driver has tapped "End Trip" and the trip is in trip_ended state
- When the driver's screen updates
- Then a full-screen cash collection prompt is displayed
- And the final fare amount in EGP is shown prominently

**Scenario 2 — "Get a New Ride" dismisses the screen and returns driver to available**
- Given the driver is viewing the cash collection screen
- When she taps "Get a New Ride"
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
- #3058 — Cash-collection amount is served to the driver and her confirmation is recorded (must be live)

---

## [Mobile] #3990 — Driver collects a recovered rider fee alongside the fare ✏️
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** Phase 1

**Description:** As a driver, I want the cash-collection screen to show a rider's unpaid fee as its own line next to the fare, so that I can tell her exactly what she owes and why.

### Rules
- Extends the cash-collection screen (#1592). It changes only when the rider has an unpaid fee from trips she cancelled late.
- Lines: "الأجرة" / "Fare", "رسوم مستحقة من رحلة سابقة" / "Outstanding fee from a previous trip", then "الإجمالي المطلوب تحصيله" / "Total to collect".
- The rider's whole unpaid amount is collected on this trip, as one line, even if it comes from several cancellations.
- The total always equals what the rider sees on her fare summary (#3999).
- Commission and her net earnings are worked out on the fare only, never on the fee (#1766).

### Acceptance Criteria
**Scenario 1 — Fare with a fee**
- Given an 83.60 EGP fare and a rider who owes 20.00 EGP
- When the trip ends
- Then the screen shows Fare 83.60, Outstanding fee 20.00 and Total to collect 103.60 EGP

**Scenario 2 — Two unpaid fees**
- Given the rider owes 20.00 and 15.00 EGP from two cancelled trips and the fare is 100.00 EGP
- Then one fee line shows 35.00 EGP, the total is 135.00 EGP, and she owes nothing afterwards

**Scenario 3 — No fee**
- Given the rider owes nothing
- Then only Total to collect is shown, as in #1592

**Scenario 4 — Earnings are not affected**
- Given a 100.00 EGP fare, a 20.00 EGP fee and 20% commission
- Then her net earnings for the trip are 80.00 EGP

### Out of Scope
- Waiving or changing the fee from the driver app
- The rider disputing the fee
- Receipts for the fee

### Dependencies
- #1592 [Mobile] Driver sees cash fare to collect and returns to available — the screen this extends
- #3058 [API] Completed-trip fare is served to rider and driver — Closed
- #3997 [API] Trip completion posts to the ledger according to fare custody
- #3999 [Mobile] Rider sees the recovered fee on her fare summary — same total
- #3981 [Driver] Cash Collection with a Recovered Fee — design

### Mockup (ADO comment)

- Cash collection with a 20 EGP fee: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/cash-collection.html?riderfee=20
- Without a fee: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/cash-collection.html

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

## [Mobile] #2977 — Driver rates the rider after trip completion 🆕
**Feature:** Feature 11 — Trip Completion & Cash Payment | **Sprint:** 2

**Description:** As a driver, I want to rate my passenger with stars after the trip ends so that the platform builds a picture of rider behaviour and I can flag a passenger who made the trip difficult.

### Background

After the driver has ended the trip and collected the cash fare (#1592), she is shown a "Rate Passenger" screen. The screen shows the passenger's name, avatar and current rider rating, and a 5-star selector under the prompt "How was your experience with this passenger?". The driver taps a star value from 1 to 5 and submits, which sends the rating via #2978 and returns her to the home/available screen. Rating is **optional**: the driver may skip it and go straight back to available, exactly as the rider may skip rating her driver (#1799) — a driver must never be blocked from taking her next trip because she has not rated the previous passenger. All strings flow through data-i18n keys with Arabic fallback.

This mirrors the rider side of the same flow (#1565 rider rates driver / #1639 API), and completes the two-way rating loop — today only the rider can rate.

### Field Validation

| Field | Required | Format | Min | Max | Accepted values | Error — empty |
|---|---|---|---|---|---|---|
| Stars | Yes, to submit (the whole screen may be skipped) | Integer | 1 | 5 | Numeric (tap selection) | يرجى اختيار عدد النجوم قبل الإرسال / Please select a star rating before submitting |

### Acceptance Criteria

**Scenario 1 — Rate Passenger screen appears after the trip is closed out**
- Given the driver has ended the trip and dismissed the cash collection screen (#1592)
- When the Rate Passenger screen loads
- Then the passenger's name, avatar and current rider rating are displayed
- And a 5-star selector is shown under the prompt "How was your experience with this passenger?"
- And both a submit action and a skip action are available

**Scenario 2 — Driver submits a valid rating**
- Given the driver has selected a star value between 1 and 5
- When she submits
- Then the rating is sent to the platform via #2978
- And she is returned to her home screen in the online/available state

**Scenario 3 — Submitting with no stars selected shows an error**
- Given the driver has not selected any stars
- When she taps submit
- Then the bilingual error "يرجى اختيار عدد النجوم قبل الإرسال" / "Please select a star rating before submitting" is shown
- And no rating is submitted

**Scenario 4 — Driver skips rating and is not blocked**
- Given the Rate Passenger screen is displayed
- When the driver skips it without selecting a rating
- Then no rating is submitted for that trip
- And she is returned to her home screen in the online/available state and can immediately receive the next trip request

**Scenario 5 — Rating cannot be submitted twice for the same trip**
- Given the driver has already rated this passenger for this trip
- When the app attempts a second submission for the same trip
- Then the server rejects it (#2978) and the driver is informed the trip has already been rated

**Scenario 6 — Network error on submission**
- Given the driver submits a rating
- When the network request fails
- Then a bilingual toast is shown and the rating is not recorded
- And the driver may retry or skip and continue to her home screen

**Scenario 7 — All strings are bilingual**
- Given the app language is Arabic or English
- Then every label, prompt, button and error on this screen renders through a data-i18n key with an Arabic fallback in the markup

### Out of Scope
- Free-text comment on the passenger
- Predefined feedback tags — the rider-side equivalent (#1565) has three tags, but no tag row is confirmed in the closed design (#1753); add a follow-up story if design confirms tags
- Reporting or blocking a passenger (gender-mismatch reporting is #1687)
- Showing the driver's submitted rating back to the rider
- Editing a submitted rating
- Whether a low rider rating affects future matching

### Dependencies
- #2978 — Driver submits rider rating (API — must be live)
- #1592 — Driver sees cash fare to collect and returns to available (this screen follows it)
- #1753 — Driver App - Rating Passenger (closed design; mockup "11_Rate Passenger.jpg" on task #1754)

---

## [Mobile] #5679 — Driver chats with her rider during the trip 🆕
**Feature:** #1542 Active Trip — Driver | **Sprint:** — | **Tag:** Trip chat

**Description:** As a driver, I want to message my rider from accepting her trip until it ends so that I can find her at pickup without calling her or sharing my number.

### Rules
- Same chat as the rider's (#5678).
- A **Message** button with the unread count: En Route and Arrived cards, in-ride action row.

| When | Quick replies |
|---|---|
| Before the rider boards | I'm on my way, Running 5 minutes late, I've arrived at the pickup point, Where are you exactly?, OK |
| During the ride | OK, Thank you, We're almost there |

- After the trip starts, quick replies only; the text box is replaced by "While you drive, you can send quick replies only." Messages stay readable.
- The push shows the rider's name, also over Google Maps or Waze.

### Acceptance Criteria
**Scenario 1 — Driving mode**
- Given she has started the trip
- When she opens the chat
- Then tapping We're almost there sends it

**Scenario 2 — Typing before boarding**
- Given she is waiting at pickup
- When she types "I'm at the side gate, white Corolla" and sends it
- Then the rider receives it as written

**Scenario 3 — A message while she navigates**
- Given she is following Waze to the pickup
- When the rider sends "Please wait 2 minutes"
- Then she gets a push from Nour, and tapping it opens the chat

**Scenario 4 — The rider cancels**
- Given the chat has 3 messages
- When the rider cancels the trip
- Then the chat closes with the trip and the messages are gone

### Out of Scope
- As in #5678
- Changes to the Call button

### Dependencies
- #5683 [API] Driver sends and receives trip chat messages
- #5678 [Mobile] Rider chats with her driver during the trip — shared rules
- #5677 [Driver] Trip Chat — design

### Mockup (ADO comment)
- Before boarding: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/chat.html?state=en-route&thread=sample
- Driving mode: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/chat.html?state=in-ride&thread=sample
- Trip ended: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/chat.html?state=ended&thread=sample
- Message button + push: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/trip.html?state=en-route&push=chat

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

The driver profile screen opens when she taps her name at the top of the driver app's menu. It displays, in read-only form, the details captured and verified during onboarding: profile photo, full name, phone number, date of birth, masked National ID (last 4 digits only), and vehicle details (make, model, year, color, plate number, vehicle type). It also shows her account/onboarding status (Approved), her aggregate star rating (linking to #1792), and her current language preference (with a link to change it via #1731). Because all profile and vehicle data is verified during onboarding, none of it can be edited in the app in this phase; a bilingual note explains that to correct any detail she should contact support. In-app editing and document re-submission will be introduced later alongside the onboarding-maturity and resubmission work. A red **Delete account** link at the bottom of the screen opens account deletion (#5039). Profile data is retrieved via #1800. All strings flow through data-i18n keys with Arabic fallback.

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

**Scenario 5 — Delete account entry point**
- Given the driver is on her profile screen
- Then a red "حذف الحساب" / "Delete account" link is shown at the bottom of the screen
- When she taps it
- Then the Delete account screen opens (#5039)

### Out of Scope
- Editing any profile or vehicle field (deferred to onboarding-maturity work)
- Profile photo change / document re-upload (deferred with resubmission)
- Phone number change
- SOS functionality

### Dependencies
- #1800 — Driver retrieves her profile (API — must be live)
- #1792 — Driver views her overall rating (rating display)
- #1731 — Driver changes language preference from profile screen
- #5039 — Driver deletes her account (the screen the Delete account link opens)

---

### Feature 18 — Driver Earnings

---

## [Mobile] #1736 — Driver views earnings dashboard 🆕
**Feature:** Feature 18 — Driver Earnings | **Sprint:** 2

**Description:** As a driver, I want to view a summary of my earnings so that I can track my income and performance over time.

### Background

The earnings dashboard is accessible from the driver home screen menu or profile screen. Period tabs — “اليوم” / “Today” (the default), “هذا الأسبوع” / “This week” and “هذا الشهر” / “This month” — sit above one summary card. The card's label names the selected period: “أرباح اليوم” / “Today's earnings”, “أرباح هذا الأسبوع” / “This week's earnings” or “أرباح هذا الشهر” / “This month's earnings”, and it shows total earnings in EGP and the number of trips completed in that period. Below the card, the trips of the same period are listed with each trip's date, route summary, and fare. Data is fetched from #1735 on screen load. Pull-to-refresh updates all figures.

### Acceptance Criteria

**Scenario 1 — Driver sees earnings summary on load**
- Given an authenticated driver navigates to the earnings dashboard
- When the screen loads
- Then the “Today” tab is selected and the card is labelled “أرباح اليوم” / “Today's earnings” with today's total in EGP and trip count
- And figures are fetched from #1735

**Scenario 2 — Zero earnings displayed correctly**
- Given the driver has completed no trips in the current period
- When the earnings dashboard loads
- Then the relevant summary card shows "0 جنيه" / "0 EGP" and "0 رحلات" / "0 trips"
- And no error state is shown

**Scenario 3 — Recent trip list is shown below summary**
- Given the driver has completed at least one trip
- When the earnings dashboard loads
- Then the trips of the selected period are listed below the summary card
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

**Scenario 6 — Switching the period**
- Given the driver is on the earnings dashboard
- When she selects “This week”
- Then the card label reads “أرباح هذا الأسبوع” / “This week's earnings”
- And the total, the trip count and the trip list show this week's figures

### Out of Scope
- Earnings breakdown by individual day within a week
- Export or download of earnings report
- Tip amounts

### Dependencies
- #1735 — Driver retrieves earnings summary (API — must be live)

---

## [Mobile] #1788 — Driver views her balance and statement ✏️
**Feature:** Feature 18 — Driver Earnings | **Sprint:** Phase 1

**Description:** As a driver, I want to see my balance and every transaction behind it, so that I know what I owe SheDrive, what SheDrive owes me, and why.

### Rules
- Reached from the earnings screen and the profile menu.
- The card shows her balance in EGP with its sign: minus = she owes SheDrive (badge "Amount Due"), plus = SheDrive owes her. Under it: settlement limit and last settlement date.
- "Settle Now" and "Settlement History" open the settlement screen (#3989).
- Limit band: at 80% of the limit "اقتربتِ من حد الرصيد ({{owed}} من {{limit}} جنيه). سدّدي لتفادي إيقاف العمل." / "You are close to the balance limit ({{owed}} of {{limit}} EGP). Settle up to keep working."; at the limit "لا يمكنكِ الاتصال حتى تسدّدي رصيدك." / "You cannot go online until you settle your balance."
- She can't ask for a payout. A payout Finance sends shows up as a statement row.
- The screen is read-only.

### Statement
| Item | Rule |
|---|---|
| Row types | Trip commission, Cancellation fee, Cancellation fee credit, Rider fee recovery, Settlement received, Payout sent |
| Row | Type, date and time, amount in EGP; credits green, debits red |
| Period filter | Today (default), This week, This month; grouped under Today, Yesterday, then the date, newest first |
| Filter effect | Narrows the list only; the balance and the limit band don't change |
| Tap | A trip row opens that trip's detail (#1594) |
| Paging | Next page loads at the end of the list, no repeated rows |
| Never shown | The commission percentage or the gross fare |

### Acceptance Criteria
**Scenario 1 — She owes**
- Given she owes 2,650 EGP against a 3,000 EGP limit
- Then the card shows −2,650.00 EGP with "Amount Due" and the limit band warns her

**Scenario 2 — SheDrive owes her**
- Given SheDrive owes her 2,850.50 EGP
- Then the card shows +2,850.50 EGP and no warning band

**Scenario 3 — At the limit**
- Given she owes 3,000 EGP against a 3,000 EGP limit
- Then the band says she cannot go online until she settles

**Scenario 4 — Switch period**
- Given rows today, yesterday and on 23 Sep
- When she picks This week
- Then rows show under Today and Yesterday, and 23 Sep rows are not listed

**Scenario 5 — Nothing in the period**
- Given no transactions today
- Then "No transactions in this period" is shown and the card still shows her balance

**Scenario 6 — Zero balance**
- Given her balance is 0
- Then "No Fees Due — Your balance is clear" is shown with Settlement History

**Scenario 7 — Can't load**
- Given the request fails
- Then "تعذّر تحميل الرصيد. تحقّقي من اتصالك." / "Unable to load balance. Check your connection." is shown with Retry

### Out of Scope
- Asking for a payout
- Paying from inside the app
- Payout status of each earning — #5627
- Export, PDF receipts, disputes

### Dependencies
- #1781 [API] Driver retrieves her balance and statement — Closed
- #3989 [Mobile] Driver settles what she owes and sees her settlement history
- #1594 [Mobile] Driver views past trip detail
- #3977 [Driver] Balance & Statement — design

### Mockup (ADO comment)

- She owes: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?owed=2650
- SheDrive owes her: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?available=2850
- Near the limit: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?warn
- At the limit: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?blocked
- Zero: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?zero
- Error: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?error

---

> **Removed 2026-09-13:** drivers do not request payouts. Finance transfers the funds and records the transfer afterwards — see #4001 (which absorbed #3993 on 2026-09-17). There is no driver-initiated request in the system.

---

## [Mobile] #3989 — Driver settles what she owes and sees her settlement history ✏️
**Feature:** Feature 18 — Driver Earnings | **Sprint:** Phase 1

**Description:** As a driver, I want to see what I owe, the ways to pay it back and every settlement already recorded, so that I can clear my balance and know each payment reached SheDrive.

### Rules
- Reached from the balance screen (#1788), the blocked go-online sheet (#3988) and the profile menu.
- Top card: "Amount You Owe" as −EGP, or "Amount to Receive" as +EGP when SheDrive owes her.
- Ways to settle: Cash Office, Bank Deposit, Mobile Wallet, Field Agent. Each opens a sheet with its details and a copy button on each value:
| Way | Details |
|---|---|
| Cash Office | Office address, working hours; bring your national ID |
| Bank Deposit | Bank name, account number, account holder; put your driver ID in the transfer note |
| Mobile Wallet | Wallet number, provider |
| Field Agent | Agent name, phone number, area; call or WhatsApp before you meet |

- The details are set in the app, not by an admin.
- Under the ways: "يطابق فريق المالية دفعتكِ باستخدام رقمكِ القومي. احتفظي برقم مرجع التحويل." / "Finance matches your payment to you by your national ID. Keep the reference of your transfer."
- She never pays inside the app. Finance records the settlement after she hands the money over; then her balance updates and, if she is under the limit, she can go online at once with no restart.
- Settlement history: newest first, each with amount, date, way and receipt number (S-nnnn — the same number Finance sees). Next page loads at the end of the list.

### Acceptance Criteria
**Scenario 1 — Settlement recorded**
- Given she owes 1,650 EGP and pays it at the office, recorded as S-1042
- When she opens the screen
- Then she owes 0 and a row shows +1,650 EGP, today, Cash Office, S-1042

**Scenario 2 — Part payment**
- Given she owes 1,650 EGP and pays 1,000 EGP
- Then she still owes 650 EGP and the 1,000 EGP row is in her history

**Scenario 3 — Unblocked**
- Given she was blocked from going online and the settlement brings her under the limit
- When she goes back to home
- Then she can go online

**Scenario 4 — Nothing owed, no history**
- Given she owes nothing and has never settled
- Then "لا يوجد عليكِ أي مبلغ لتسويته حالياً." / "You have nothing to settle right now." and "لا توجد تسويات مسجّلة بعد." / "No settlements recorded yet." are shown

**Scenario 5 — Can't load**
- Given the request fails
- Then "تعذّر تحميل بيانات التسوية. تحقّقي من اتصالك." / "Unable to load settlement details. Check your connection." is shown with Retry

### Out of Scope
- Paying from inside the app
- Choosing the way for a settlement already recorded
- PDF receipts, disputes
- Her payout method — #5626

### Dependencies
- #1781 [API] Driver retrieves her balance and statement — Closed; settlements are in the same ledger
- #5620 [Admin] Financial officer imports Finance's settlement sheet — where a settlement is recorded
- #1788 [Mobile] Driver views her balance and statement
- #3988 [Mobile] Driver is blocked from going online while her balance is over the limit
- #3979 [Driver] Settle What You Owe — design

### Mockup (ADO comment)

- She owes: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?owed=1650
- Nothing owed: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?zero
- Error: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?error

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

### Feature 21 — Emergency & Safety (Driver)

---

## [Mobile] #1951 — Driver sets up emergency contacts who receive a live location link on SOS ✏️
**Feature:** Feature 21 — Emergency & Safety (Driver) | **Sprint:** 2

**Description:** As a driver, I want to save emergency contacts who get a live link to my location when I raise SOS during a trip, so that the people I trust can follow me in an emergency.

### Rules
- Reached from the side menu (Safety & Emergency).
- She can add, edit and remove contacts. Removing asks for confirmation.
- Up to 5 contacts. At 5, Add is disabled with "لقد حفظتِ الحد الأقصى وهو ٥ جهات اتصال. احذفي واحدة لإضافة أخرى." / "You have saved the maximum of 5 contacts. Remove one to add another."
- When she raises SOS during a trip, every saved contact gets an alert with a live link to her location (#3969).
- Police (122) and Ambulance (123) are always shown as one-tap calls.
- Empty state: "أضيفي شخصاً تثقين به ليتم إخطاره ومشاركة موقعك معه عند الطوارئ." / "Add someone you trust to be alerted with your live location in an emergency."

### Field Validation
| Field | Required | Format | Error |
|---|---|---|---|
| Name | Yes | Text | يرجى إدخال الاسم / Please enter a name |
| Phone number | Yes | Egyptian mobile, 11 digits starting 01 | يرجى إدخال رقم هاتف صحيح / Please enter a valid phone number |
| Relationship | No | List: mother, father, sister, brother, husband, daughter, son, friend, relative, colleague, other | — |
| How are they related? | Yes when Relationship is Other | Text | من فضلكِ اكتبي صلتَكِ بهذا الشخص / Please say how this person is related to you |

### Acceptance Criteria
**Scenario 1 — Add a contact**
- Given she has no contacts
- When she adds Mona, 01012345678, Sister and saves
- Then Mona is in her list and is still there after the app restarts

**Scenario 2 — At the limit**
- Given she has 5 contacts
- When she removes one
- Then Add is available again

**Scenario 3 — SOS with no contacts**
- Given she has no contacts
- When she raises SOS during a trip
- Then she is told "لم تُضيفي جهات اتصال للطوارئ بعد. يمكنك إضافتها من شاشة جهات اتصال الطوارئ." / "You have no emergency contacts yet. Add them from the Emergency Contacts screen." and Police and Ambulance are still one tap away

### Out of Scope
- A control room or operations team
- In-car cameras
- The SOS screen itself — #3969

### Dependencies
- #3970 [API] SOS incident is recorded with a full trip snapshot — alerts the contacts
- #1787 [Mobile] Rider sets up emergency contacts — the same rules for riders
- #1953 [Driver] Emergency Contacts & SOS — design (its "up to 3" counter is a design error; the limit is 5)

### Mockup (ADO comment)

- Emergency contacts: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/sos.html

---

## [Mobile] #3969 — Driver raises SOS and reaches the emergency screen ✏️
**Feature:** Feature 21 — Emergency & Safety (Driver) | **Sprint:** 2

**Description:** As a driver on an active trip, I want to raise SOS and land on an emergency screen that shows my contacts were alerted and my location is shared, so that I get help fast without the rider knowing.

### Rules
- SOS is on the trip screen from heading to pickup until the trip ends, and nowhere else.
- One confirmation guards against accidental taps: "هل تريدين إرسال تنبيه طوارئ؟ سيتم إخطار جهات اتصالك ومشاركة موقعك المباشر معهم." / "Send an emergency alert? Your contacts will be notified and your live location shared with them." Dismissing it sends nothing.
- Confirming opens a full emergency screen (not an overlay) with:
| Part | Shows |
|---|---|
| Status | "Safety Alert Active", contacts notified, live sharing active, time started |
| Contacts | Each contact with her own delivery status: Sending, Delivered or "تعذّر التسليم" / "Could not deliver" |
| Emergency numbers | Police (122) and Ambulance (123), one tap to call |
| Trip recap | Rider name, vehicle, plate and her current location |
| Actions | "العودة إلى الرحلة" / "Return to trip", Stop live sharing, "إلغاء التنبيه (إنذار كاذب)" / "Cancel alert (false alarm)" |

- The rider gets no notification and sees no change.
- The trip goes on as normal and is settled and rated as usual. Nobody is suspended automatically.

### Acceptance Criteria
**Scenario 1 — Raise SOS**
- Given Sara is driving Nour to her destination and has 2 contacts
- When she taps SOS and confirms
- Then the emergency screen opens, both contacts show Sending, and Nour's app shows nothing

**Scenario 2 — One contact can't be reached**
- Given the SMS to her second contact fails
- Then that contact shows "Could not deliver" and the first shows Delivered

**Scenario 3 — Back to the trip**
- When she taps Return to trip
- Then the trip screen opens and the alert stays active: contacts still have the live link

**Scenario 4 — Stop sharing**
- When she taps Stop live sharing and confirms "Stop sharing"
- Then the live link stops showing her location at once; "Keep sharing" changes nothing

**Scenario 5 — False alarm**
- When she taps Cancel alert (false alarm) and confirms
- Then "ستتوقف مشاركة موقعك فوراً وسيُسجَّل التنبيه كإنذار كاذب." / "Location sharing stops immediately and the alert is recorded as a false alarm." happens, and the case stays open for the safety team

### Out of Scope
- A control room or staffed desk
- A fire brigade number
- SOS outside an active trip
- Reviewing and closing the case — #3945 / #3946

### Dependencies
- #3970 [API] SOS incident is recorded with a full trip snapshot — contacts, delivery status and false alarm
- #1951 [Mobile] Driver sets up emergency contacts
- #3973 [Driver] SOS emergency screen — design; delivery status, the trip recap and false alarm still need to be drawn

### Mockup (ADO comment)

- Emergency screen: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/emergency.html
- Stop sharing confirmation: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/emergency.html?sheet=stop

---


# Payouts, settlement import and maker-checker (2026-10-14)

> Spec: `docs/superpowers/specs/2026-10-14-driver-payouts-settlement-design.md`. Created in ADO 2026-10-14 with tag "Payouts & settlement".

---

## [Mobile] #5625 — Driver adds a payout method during onboarding 🆕
**Feature:** #1539 Driver Onboarding | **Sprint:** — | **Tag:** Payout

**Description:** As a driver applicant, I want to choose how SheDrive pays me while I apply so that my earnings can be sent to me from my first payout.

### Rules
- A new last onboarding step, **Payout method**, is required to submit the application.
- She picks one: **Mobile wallet**, **Bank account** or **Prepaid card**, then enters its details. Only the format is checked; the name doesn't have to match her national ID.
- The step explains that earnings are paid 7 days after each trip.

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Payout method | Yes | Single choice | Mobile wallet, Bank account, Prepaid card | — | — | none | Choose how you want to get paid / اختاري طريقة استلام أرباحك | — | — |
| Wallet provider | Yes (wallet) | Dropdown | Vodafone Cash, Orange Cash, e& money, WE Pay | — | — | none | Choose your wallet provider / اختاري مزوّد المحفظة | — | — |
| Wallet number | Yes (wallet) | Egyptian mobile | `01` + 9 digits | 11 | 11 | empty | Enter your wallet number / أدخلي رقم المحفظة | Enter a valid Egyptian mobile number / أدخلي رقم موبايل مصري صحيح | — |
| Bank | Yes (bank) | Dropdown | CIB, National Bank of Egypt, Banque Misr, QNB Al Ahli, AAIB, Banque du Caire, HSBC Egypt | — | — | none | Choose your bank / اختاري البنك | — | — |
| Account holder / name on card | Yes (bank, card) | Free text | Letters and spaces | 3 | 100 | empty | Enter the name / أدخلي الاسم | — | Name must be 3–100 characters / يجب أن يكون الاسم بين 3 و100 حرف |
| Account number / IBAN | Yes (bank) | Digits or IBAN | 10–20 digits, or `EG` + 27 digits | 10 | 29 | empty | Enter your account number / أدخلي رقم الحساب | Enter a valid account number or IBAN / أدخلي رقم حساب أو IBAN صحيح | — |
| Card number | Yes (card) | Digits | 16 digits, any prepaid card | 16 | 16 | empty | Enter your card number / أدخلي رقم الكارت | Enter the 16-digit card number / أدخلي رقم الكارت المكوّن من 16 رقمًا | — |

### Acceptance Criteria
**Scenario 1 — Mobile wallet**
- Given she chooses Mobile wallet, Vodafone Cash, 01012345678
- When she submits the application
- Then the application is submitted with that payout method

**Scenario 2 — Fields follow the choice**
- When she switches from Mobile wallet to Bank account
- Then only the bank fields show and the wallet fields are cleared

**Scenario 3 — Can't skip**
- Given she hasn't completed this step
- Then Submit stays disabled and the missing fields are named

### Out of Scope
- Verifying the account with the bank or wallet provider

### Dependencies
- #5629 [API] Driver payout method is captured at onboarding
- #1572, #1575 — earlier onboarding steps

### Mockup (ADO comment)
- Onboarding — payout method step: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/onboarding.html?step=7

---

## [Mobile] #5626 — Driver views and changes her payout method ✏️
**Feature:** #1769 Earnings — Driver | **Sprint:** — | **Tag:** Payout

**Description:** As a driver, I want to see and change where SheDrive sends my earnings, so that my payouts keep reaching me when my account changes.

### Rules
- Reached from the "Payout method" row on My Profile, which shows the type and the full number.
- The screen shows her current method in full: type, provider or bank, holder name and number. No masking.
- "تغيير وسيلة الاستلام" / "Change payout method" opens the same form as onboarding (#5625): one of Mobile wallet, Bank account or Prepaid card, with the same fields and validation.
- Saving applies at once, with no approval: "يُطبَّق التغيير فوراً، ويُرسل التحويل القادم إلى الوسيلة الجديدة." / "The change applies right away. Your next payout goes to the new method."
- She has one method at a time. The new one replaces the old.
- If her last payout failed, a banner shows: "فشل تحويل آخر مبلغ لكِ ({{amount}} جنيه): {{reason}}. راجعي وسيلة استلام الأرباح." / "Your last payout of {{amount}} EGP failed: {{reason}}. Check your payout method." It stays until she changes the method or a payout succeeds.

### Acceptance Criteria
**Scenario 1 — Change from wallet to bank**
- Given her method is Vodafone Cash 01012345678
- When she changes it to CIB, account 1002003004005 and saves
- Then "تم تحديث وسيلة الاستلام. سيُرسل تحويلكِ القادم إليها." / "Payout method updated. Your next payout goes here." shows, and the screen shows the CIB account in full

**Scenario 2 — Invalid number**
- Given she picks Mobile wallet
- When she enters 0101234 and saves
- Then "رقم المحفظة يجب أن يبدأ بـ 01 ويليه 9 أرقام" / "Wallet number must be 01 followed by 9 digits" shows and nothing is saved

**Scenario 3 — After a failed payout**
- Given her last payout of 245.50 EGP failed because the account number was not found
- When she opens the screen
- Then the failed banner shows; after she saves a new method it is gone

**Scenario 4 — Cancel**
- When she opens the form and taps Cancel
- Then her method is unchanged

### Out of Scope
- More than one payout method
- Approval of her own change (an admin's change to her method needs approval — #6564)
- Checking that the account really exists — format only

### Dependencies
- #5630 [API] Driver views and changes her payout method
- #5625 [Mobile] Driver adds a payout method during onboarding — the form and its validation
- #1801 [Mobile] Driver views her profile — the Payout method row
- #5642 [Driver] Payout method — design

### Mockup (ADO comment)

- Payout method: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/payout-method.html
- Last payout failed: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/payout-method.html?state=failed
- My Profile (Payout method row): https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/my-profile.html

---

## [Mobile] #5627 — Driver sees the payout status of her earnings ✏️
**Feature:** #1769 Earnings — Driver | **Sprint:** — | **Tag:** Payout

**Description:** As a driver, I want to see when each earning will be paid and whether it was paid, so that I know what money is coming to me.

### Rules
- Each earning row in her statement (#1788) — trip earnings and cancellation fee credits — shows one status:
| Status | Shown as |
|---|---|
| On hold | "محجوز حتى {{date}}" / "On hold until {{date}}" — 7 calendar days after the trip |
| Due | "مستحق للصرف · {{date}}" / "Due for payout · {{date}}" |
| Being transferred | "جارٍ التحويل · مستحق {{date}}" / "Being transferred · due {{date}}" — in a payout batch |
| Paid | "تم الصرف · مرجع {{ref}}" / "Paid · Ref. {{ref}}" |
| Failed | "فشل التحويل · مستحق مجدداً" / "Payout failed · due again", with the reason; it goes back to Due |

- The balance card adds a summary line: "On hold: X EGP · Due for payout: Y EGP · Being transferred: Z EGP".
- Due earnings are paid only once her due total reaches the minimum payout; below it the row adds "Paid once your due amount reaches {{minimum}} EGP".
- A paid payout shows the amount; when she pays the transfer fee it also shows the fee and the amount sent.
- A failed payout shows a banner on the balance screen that opens her payout method (#5626).
- The "Payout sent" and "Payout failed" notifications are in the inbox (#5721).

### Acceptance Criteria
**Scenario 1 — On hold**
- Given she earned 60.00 EGP on a trip on 14 Oct
- Then the row reads "On hold until 21 Oct"

**Scenario 2 — Below the minimum**
- Given the minimum payout is 100.00 EGP and she is due 60.00 EGP
- Then the row stays Due with "Paid once your due amount reaches 100.00 EGP"

**Scenario 3 — She pays the transfer fee**
- Given a 250.50 EGP payout with a 1.5% fee that she pays
- Then it reads 250.50 EGP, transfer fee 3.76 EGP, 246.74 EGP sent

**Scenario 4 — Failed**
- Given her 245.50 EGP payout failed because the account number was not found
- Then those rows read "Payout failed · due again" with the reason, and the banner opens her payout method

### Out of Scope
- Choosing when to be paid or asking for a payout
- Changing the minimum or the fee — Financial lead, #6486

### Dependencies
- #5631 [API] Driver retrieves the payout status of her earnings
- #1788 [Mobile] Driver views her balance and statement — the screen this extends
- #5626 [Mobile] Driver views and changes her payout method
- #5721 [Mobile] Driver sees her notifications and opens what each one is about
- #5643 [Driver] Balance — payout status of earnings — design

### Mockup (ADO comment)

- Balance with payout status: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?available=2850
- Failed payout banner: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?state=payout-failed

---


# No masking of phone numbers or national IDs (2026-10-14)

> Phone numbers and national IDs are shown in full everywhere; payout account and card numbers stay masked. Built stories are left as they are — these new stories carry the change.

---

## [Mobile] #5653 — Driver sees her full national ID on her profile 🆕
**Feature:** #1538 Driver Authentication | **Sprint:** —

**Description:** As a driver, I want to see my full national ID on my profile so that I can check it is the one SheDrive verified.

### Rules
- My profile (#1801) shows her full 14-digit national ID instead of the last 4 digits. It stays read-only.

### Acceptance Criteria
**Scenario 1 — Full national ID**
- Given her national ID is 29805120104821
- When she opens My profile
- Then Personal details shows 29805120104821

### Dependencies
- #1801 — Driver views her profile
- #5654 [API] Driver profile returns her full national ID

### Mockup (ADO comment)
- My profile: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/my-profile.html

---

## [Mobile] #5656 — Driver sees her full phone number when confirming account deletion 🆕
**Feature:** #1538 Driver Authentication | **Sprint:** —

**Description:** As a driver, I want to see my full phone number on the deletion code step so that I know exactly which number the code went to.

### Rules
- The code step of Delete account (#5039) shows her full number, e.g. +20 10 1234 5678, instead of +20 10 •••• 5678.

### Acceptance Criteria
**Scenario 1 — Full number**
- Given her number is 01012345678
- When she reaches the code step
- Then it says the code was sent to +20 10 1234 5678

### Dependencies
- #5039 — Driver deletes her account
- #5658 [API] Driver account deletion returns the full phone number for the code step

### Mockup (ADO comment)
- Delete account: https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/delete-account.html

---
