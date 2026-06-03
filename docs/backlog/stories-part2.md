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
