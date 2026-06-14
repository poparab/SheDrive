# SheDrive — Admin Portal Stories
> Canonical backlog for all [Admin] stories. Organized by sprint and feature.
> Last updated: 2026-06-14
> Stories with changes from original are marked ✏️ | New stories marked 🆕

> **Role model (this phase):** A single admin role — **super admin** — with full
> privileges on every screen. Finer-grained roles (Operations Supervisor, Customer
> Support, Finance, Compliance) are a planned future addition.
> **Portal UI:** English only. **Safety/SOS:** the SOS queue + escalation workflow
> is deferred to a later phase; the women-only gender-mismatch report triage is in scope.

---

## Sprint 1

### Feature 1 — Platform & Integration Foundation (ADO Feature #1611)

---

## [Admin] #1656 — Admin portal shell and login screen are in place ✏️
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want a working admin web portal with a login screen and shell layout so that I can securely access SheDrive operations dashboards.

### Background
The admin portal is a web application accessible to SheDrive operations staff. It presents a login screen (email + password) as its unauthenticated entry point. Successful authentication lands the admin on the main dashboard, which sits within a persistent shell consisting of a navigation sidebar or top bar and a content area. The portal is distinct from the rider/driver mobile app and serves as the operations team's command centre for approving drivers, monitoring trips, and managing the platform. The portal UI is English only. In this phase there is a single admin role — **super admin** — and every admin account has full privileges; finer-grained roles are a planned future addition. Two-factor authentication (#1806) is required at login, password reset (#1805) is self-service, and admin accounts are managed via #1807.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email | Yes | Email | local@domain.tld; letters, digits, `. _ % + - @` | — | 254 chars | — | Enter your email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |
| Password | Yes | Password (masked) | Any printable character | 8 chars | 128 chars | — | Enter your password / أدخل كلمة المرور | — | Password must be at least 8 characters / يجب ألا تقل كلمة المرور عن 8 أحرف |

### Acceptance Criteria

**Scenario 1 — Admin logs in with valid credentials**
- Given a super admin navigates to the admin portal login screen
- When she enters a valid registered email and the correct password and submits the form
- Then she is prompted for her second factor (#1806) and, on success, is redirected to the admin dashboard
- And the shell navigation (sidebar or top bar) is visible

**Scenario 2 — Login fails with wrong credentials**
- Given an admin enters a registered email with an incorrect password
- When she submits the form
- Then she remains on the login screen
- And the error message "البريد الإلكتروني أو كلمة المرور غير صحيحة" is displayed

**Scenario 3 — Login form validates empty fields**
- Given an admin submits the login form with the email field empty
- Then the error "أدخل البريد الإلكتروني" is displayed inline
- And if the password field is also empty, "أدخل كلمة المرور" is displayed inline

**Scenario 4 — Login form validates email format**
- Given an admin enters a value that does not conform to email format (e.g., missing @)
- Then the error "بريد إلكتروني غير صحيح" is displayed inline

**Scenario 5 — Admin portal shell is accessible after login**
- Given an authenticated admin is on any portal page
- Then the shared navigation shell (links to Dashboard, Driver Management, Trip Monitor, and Settings at minimum) is always visible
- And the active page is indicated in the navigation

**Scenario 6 — Unauthenticated access to protected portal pages is redirected**
- Given a user attempts to navigate directly to a protected admin portal URL without a valid session
- Then the user is redirected to the login screen

### Out of Scope
- SOS/emergency features

### Dependencies
- None (foundational portal shell story)
- Related: #1805 password reset, #1806 two-factor authentication, #1807 admin user management

---

## [Admin] #1805 — Super admin resets her password 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want to reset my password through a secure self-service flow so that I can regain portal access without help from engineering.

### Background
The login screen (#1656) exposes a "Forgot password?" link. The super admin enters her registered email; if it matches an active admin account a single-use, time-limited reset link is emailed. Following the link lets her set a new password that meets the password policy (minimum 8 characters). On success all of her existing sessions are invalidated and she must sign in again. To avoid account enumeration, the same neutral confirmation is shown whether or not the email exists.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| New password | Yes | Password (masked) | Any printable character | 8 chars | 128 chars | — | Enter a new password / أدخل كلمة المرور الجديدة | — | Password must be at least 8 characters / يجب ألا تقل كلمة المرور عن 8 أحرف |
| Confirm password | Yes | Password (masked) | Must exactly match the new password | — | — | — | Confirm your password / أكد كلمة المرور | Passwords do not match / كلمتا المرور غير متطابقتين | — |

### Acceptance Criteria

**Scenario 1 — Reset requested for a registered email**
- Given a super admin enters her registered email on the forgot-password screen
- When she submits
- Then a neutral confirmation is shown and a single-use reset link is emailed to her

**Scenario 2 — Reset requested for an unknown email (no enumeration)**
- Given an email that is not registered is submitted
- Then the same neutral confirmation is shown and no email is sent

**Scenario 3 — Reset link is single-use and time-limited**
- Given a reset link that has expired or already been used
- When the admin opens it
- Then an error is shown with an option to request a new link

**Scenario 4 — New password must meet policy**
- Given the admin enters a new password under 8 characters
- Then an inline error is shown and the password is not changed

**Scenario 5 — Confirmation must match**
- Given the confirm-password value differs from the new password
- Then an inline error is shown

**Scenario 6 — Successful reset invalidates existing sessions**
- Given the admin completes a valid reset
- Then all of her existing sessions are invalidated and she signs in with the new password

### Out of Scope
- SMS-based reset and security questions
- An admin resetting another admin's password (handled operationally via #1807)

### Dependencies
- #1656 — Admin portal shell and login
- Email notification channel

---

## [Admin] #1806 — Admin login is protected by two-factor authentication 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want my login to require a second authentication factor so that the portal — which controls pricing, payouts, and account suspension — is protected against credential theft.

### Background
After a successful email and password check on #1656, the portal requires a second factor — a time-based one-time code from an authenticator app (TOTP) — before granting access. On first login the admin enrols an authenticator (QR code plus secret) and is issued one-time recovery codes. 2FA is then required on every subsequent login. Repeated invalid codes temporarily lock the login attempt. The portal controls pricing, payouts, and account suspension, so 2FA is mandatory for every admin.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Authentication code (TOTP) | Yes | Numeric (one-time code) | Exactly 6 digits (0–9) | 6 digits | 6 digits | empty | Enter the authentication code / أدخل رمز المصادقة | Invalid or expired code / رمز غير صحيح أو منتهي الصلاحية | Code must be exactly 6 digits / يجب أن يتكون الرمز من 6 أرقام |
| Recovery code | Conditional — when using a recovery code instead of the authenticator | Alphanumeric code | Letters and digits as issued | — | — | empty | Enter a recovery code / أدخل رمز الاسترداد | Invalid or already-used recovery code / رمز استرداد غير صالح أو مستخدم بالفعل | — |

### Acceptance Criteria

**Scenario 1 — First-time enrolment**
- Given an admin logs in for the first time after 2FA is enabled
- When she scans the QR code and confirms a generated code
- Then 2FA is enabled for her account and one-time recovery codes are shown once

**Scenario 2 — Valid second factor grants access**
- Given an enrolled admin has passed email and password
- When she enters the current valid code
- Then she is authenticated and lands on the dashboard

**Scenario 3 — Invalid code is rejected**
- Given an enrolled admin enters a wrong or expired code
- Then she remains on the 2FA step and an error is shown

**Scenario 4 — Lockout after repeated failures**
- Given several consecutive invalid codes are entered
- Then the login attempt is locked for a cool-down period

**Scenario 5 — Recovery code on a lost device**
- Given an admin no longer has her authenticator
- When she enters a valid unused recovery code
- Then she is granted access and that recovery code is consumed

### Out of Scope
- SMS-based 2FA and hardware security keys
- Per-action step-up authentication
- "Remember this device" trusted-device skipping

### Dependencies
- #1656 — Admin portal shell and login

---

## [Admin] #1807 — Super admin manages admin user accounts 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want to create, disable, and re-enable admin user accounts so that I control who can access the operations portal.

### Background
In this phase a single role — **super admin** — exists, and every admin account has full portal privileges; finer-grained roles are a planned future addition. This screen lists admin accounts (email, status, created date, last login) and lets a super admin invite a new admin by email, disable an account (immediately invalidating its sessions), and re-enable a disabled account. The system prevents disabling the last remaining active admin so the portal can never be locked out.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email | Yes | Email | local@domain.tld; letters, digits, `. _ % + - @`; must be unique among admin accounts | — | 254 chars | — | Enter an email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح · An admin with this email already exists / يوجد مشرف بهذا البريد الإلكتروني بالفعل | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |

### Acceptance Criteria

**Scenario 1 — Super admin creates an admin account**
- Given the super admin is on the admin-users screen
- When she enters a valid new email and confirms
- Then invite or temporary credentials are issued and the account appears with status Active

**Scenario 2 — Duplicate email is rejected**
- Given an account already exists with a given email
- When the super admin tries to create another with the same email
- Then a validation error is shown and no account is created

**Scenario 3 — Super admin disables an admin**
- Given an active admin account
- When the super admin disables it
- Then its status changes to Disabled, its sessions are invalidated, and that admin can no longer log in

**Scenario 4 — Super admin re-enables an admin**
- Given a disabled admin account
- When the super admin re-enables it
- Then its status changes to Active and the admin can log in again

**Scenario 5 — Last active admin cannot be disabled**
- Given only one active admin account remains
- When the super admin tries to disable it
- Then the action is blocked with an explanatory error

**Scenario 6 — Account list shows status and last login**
- Given the admin-users screen is open
- Then each row shows email, status, created date, and last login

### Out of Scope
- Granular roles and per-feature permissions (future RBAC)
- Editing another admin's profile details
- Resetting another admin's password (admin self-serves via #1805)

### Dependencies
- #1656 — Admin portal shell and login
- Future RBAC expansion (more roles)

---

### Feature 5 — Driver Onboarding & Admin Approval (ADO Feature #1612)

---

## [Admin] #1657 — Admin views pending applications queue
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to see a list of all driver applications with status = pending so that I can efficiently review and process them in order.

### Background
The pending applications queue is a screen in the admin portal listing all driver applications awaiting review. Each row shows the driver's full name, phone number, submission date, and a link to view the full application. The list is sorted by submission date (oldest first) by default. Admins can search by driver name or phone and filter by submission date range. The screen is accessible only to authenticated admins.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | Any character (name or phone digits) | — | 100 chars | empty | — | — | Search must be ≤ 100 characters / يجب ألا يتجاوز البحث 100 حرف |
| Date range — from | No | Date (DD/MM/YYYY) | Valid calendar date; digits and `/` | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date range — to | No | Date (DD/MM/YYYY) | Valid calendar date; must not be before from-date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

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
The full application detail screen is accessed by clicking a row in the pending queue (#1657) or from a driver's profile. It displays personal details (name, date of birth, NID), vehicle details (make, model, year, plate, color, type), all four uploaded documents (viewable inline as images or PDF previews), the vehicle photo, and the driver's **profile photo** (#1686). Approve and Reject action buttons are shown at the bottom. The admin uses the profile photo and ID documents to verify the applicant is female (#1659 Scenario 4) before approving. The screen is accessible only to authenticated admins.

### Acceptance Criteria

**Scenario 1 — Happy path: full application displayed**
- Given the admin clicks on a pending application from the queue
- When the detail screen loads
- Then all personal details (name, DOB, NID) are displayed
- And all vehicle details (make, model, year, plate, color, type) are displayed
- And all four documents are viewable inline (images rendered, PDFs shown as previews)
- And the vehicle photo is rendered inline
- And the driver's profile photo (#1686) is rendered inline
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
- #1686 — Driver profile photo (displayed inline for gender verification)

---

## [Admin] #1659 — Admin approves driver application ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to approve a driver application so that the driver is immediately notified and can begin going online to receive trips.

### Background
The Approve action is triggered from the full application detail screen (#1658). The admin clicks "Approve," a confirmation dialog is shown, and upon confirmation the system changes the application status to approved. A push notification is sent to the driver via the push service (#1618). Once approved, the driver's account is eligible to go online, and her record appears in the active drivers list.

**Important:** SheDrive is a **women-only service**. Before approving, the admin must verify from the driver's profile photo (#1686) and submitted ID documents that the applicant is female. Applications from male applicants must be rejected.

### Acceptance Criteria

**Scenario 1 — Happy path: application approved**
- Given the admin is viewing a pending application (#1658)
- When she clicks "Approve" and confirms in the dialog
- Then the application status changes to "approved"
- And a push notification is dispatched to the driver in the driver's preferred language: "مبروك! تم قبول طلبك. يمكنك الآن تسجيل الدخول والعمل." / "Congratulations! Your application has been approved. You can now go online."
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

**Scenario 4 — Admin verifies driver is female before approving**
- Given the admin is reviewing the application
- When she views the driver's profile photo (#1686) and ID documents
- Then she must visually confirm the applicant is female before tapping "Approve"
- And the Approve dialog includes a confirmation checkbox: "I confirm this applicant is female"
- And if the applicant appears to be male, the admin must reject the application with an appropriate reason

### Out of Scope
- Reversing an approval decision
- Re-approval after a previous rejection
- Automated gender detection

### Dependencies
- #1618 — Push notification service integration
- #1658 — Admin views full driver application
- #1686 — Driver profile photo (used for gender verification)

---

## [Admin] #1660 — Admin rejects driver application with reason
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to reject a driver application with a mandatory written reason so that the driver is clearly informed of why her application was declined.

### Background
The Reject action is triggered from the full application detail screen (#1658). The admin clicks "Reject," enters a mandatory rejection reason in a text area, and confirms. The application status changes to rejected and the reason text is stored. A push notification including the reason is sent to the driver in the driver's preferred language. Rejected drivers cannot go online and cannot resubmit in these sprints.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Rejection reason | Yes | Free text (textarea) | Any character | 10 chars | 500 chars | empty | Please enter a rejection reason / يرجى إدخال سبب الرفض | — | Too short — please explain in more detail / الرجاء توضيح سبب الرفض بشكل أكثر تفصيلاً · Too long — must be ≤ 500 characters / يجب ألا يتجاوز سبب الرفض 500 حرف |

### Acceptance Criteria

**Scenario 1 — Happy path: application rejected with reason**
- Given the admin is viewing a pending application (#1658)
- When she clicks "Reject," enters a valid reason (10–500 chars), and confirms
- Then the application status changes to "rejected"
- And the rejection reason is stored against the application record
- And a push notification is dispatched in the driver's preferred language: "لم يتم قبول طلبك. السبب: [reason text]." / "Your application was not approved. Reason: [reason text]."
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

## Sprint 2

### Feature 13 — Admin — Rider Management (ADO Feature #1613)

---

## [Admin] #1661 — Admin views rider list ✏️
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As a super admin, I want to view a searchable, filterable, paginated list of all registered riders so that I can find and review any rider account quickly.

### Background
The rider list is the primary entry point for rider management in the admin portal. It loads automatically when the admin navigates to the Riders section. The table shows all registered riders with key identifiers, including each rider's account status (Active or Suspended). The admin can type a name or phone number into the search box to narrow results in real time, and can filter by account status. Clicking any row opens the rider profile screen (#1662). The default page size is 20 rows.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | Any character (name or phone digits) | — | 100 chars | empty | — | — | Search must be ≤ 100 characters / يجب ألا يتجاوز البحث 100 حرف |
| Status filter | No | Dropdown (single-select) | Enum: All / Active / Suspended | — | — | All | — | — | — |

### Acceptance Criteria

**Scenario 1 — Admin opens the rider list**
- Given the admin is authenticated and navigates to the Riders section
- When the page loads
- Then a table of all registered riders is displayed, 20 per page by default
- And columns shown are: name, phone number, account status, registration date, total trips completed
- And results are ordered by registration date descending

**Scenario 2 — Admin searches by rider name**
- Given the rider list is loaded
- When the admin types a partial name into the search box
- Then the list filters to show only riders whose name contains the search text

**Scenario 3 — Admin searches by phone number**
- Given the rider list is loaded
- When the admin types a partial phone number
- Then the list filters to riders whose phone number contains that substring

**Scenario 4 — Admin filters by account status**
- Given the rider list is loaded
- When the admin selects the "Suspended" status filter
- Then only suspended riders are shown; selecting "Active" shows only active riders, and "All" shows every rider

**Scenario 5 — Search returns no results**
- Given the admin has entered a search term or filter that matches no rider
- Then an empty state message is displayed and no table rows are shown

**Scenario 6 — Admin clicks a rider row**
- Given the rider list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the rider profile screen (#1662) for that rider

**Scenario 7 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 riders are displayed in the same column order

**Scenario 8 — Admin exports the list**
- Given the rider list is displayed with the current search and filter applied
- When the admin chooses Export
- Then the current result set is exported to CSV/Excel

### Out of Scope
- Editing rider account details
- Suspending a rider from this screen (done from the profile, #1740)
- Audit logs (see #1816)

### Dependencies
- #1663 — Rider list with search and filters is served (must be live)
- #1740 — Rider account suspension (account status source)

---

## [Admin] #1662 — Admin views rider profile ✏️
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As a super admin, I want to view a rider's full profile and their trip history so that I can understand their account activity and take account actions when needed.

### Background
The rider profile screen is opened by clicking any row in the rider list (#1661). It presents the rider's personal information at the top — including an account status badge (Active, Pending Review, or Suspended) — followed by a paginated list of the rider's past trips. A rider enters **Pending Review** automatically when a driver raises a gender-mismatch report (API #1687); such cases are triaged from the gender-mismatch queue (#1810/#1811). From this screen the super admin can also **suspend** an active rider or **reinstate** a suspended one (#1740/#1741). Trip history is read-only.

### Acceptance Criteria

**Scenario 1 — Admin opens a rider profile**
- Given the admin has clicked a rider row in the rider list
- When the profile screen loads
- Then the following is shown: full name, phone number, account status badge (Active, Pending Review, or Suspended), registration date, total trips completed, and date of last trip
- And below the profile, a paginated list of the rider's past trips is displayed

**Scenario 2 — Trip history section displays correct columns**
- Given the rider profile is loaded
- Then each trip row shows: trip date, destination address, fare (EGP), and trip status

**Scenario 3 — Rider is suspended or pending review**
- Given the rider's account is Suspended or Pending Review
- When the profile loads
- Then the status badge and the recorded reason are shown
- And for a Pending Review rider a link to the related gender-mismatch report (#1810) is shown

**Scenario 4 — Admin takes an account action**
- Given the admin is viewing a rider profile
- Then a Suspend action (#1740) is available for an active rider, and a Reinstate action (#1741) is available for a suspended rider

**Scenario 5 — Rider has no past trips**
- Given the admin opens the profile of a rider who has never completed a trip
- Then an empty state message is shown in place of the trip table

**Scenario 6 — Admin paginates the trip history**
- Given the rider has more than one page of past trips
- When the admin navigates to the next page
- Then the next page of trips loads within the profile screen

**Scenario 7 — Admin navigates back to the rider list**
- Given the admin is on the rider profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the rider list

### Out of Scope
- Editing rider details
- Viewing trip details from within the profile (trip row is not clickable in this phase)
- Exporting rider data

### Dependencies
- #1664 — Rider profile with trip history is served (must be live)
- #1740 / #1741 — Rider suspend / reinstate
- #1810 — Gender-mismatch report queue (Pending Review source)

---

## [Admin] #1740 — Operations admin suspends a rider account 🆕
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to suspend a rider's account so that I can enforce safety policies or investigate account violations.

### Background
Accessible from the rider profile screen (#1662), this action allows the admin to immediately suspend a rider's account. The rider's existing sessions are invalidated and she cannot log in again until reinstated. A reason for suspension must be recorded.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspension reason | Yes | Free text (textarea) | Any character | 10 chars | 500 chars | empty | Please explain the suspension reason / يرجى توضيح سبب التعليق | — | Too short — please explain in more detail / السبب قصير جدًا، يرجى التوضيح بشكل أكثر تفصيلاً · Too long — must be ≤ 500 characters / يجب ألا يتجاوز السبب 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin suspends a rider account**
- Given the admin is viewing a rider's profile (#1662)
- When she clicks "Suspend Account" and enters a valid reason (10–500 chars)
- Then the rider's account status changes to suspended
- And all of the rider's active sessions are invalidated
- And a confirmation message is shown to the admin

**Scenario 2 — Rider cannot log in after suspension**
- Given a rider's account has been suspended
- When she attempts to log in
- Then the login is rejected with an account-suspended error
- And she is directed to contact support

**Scenario 3 — Empty reason field**
- Given the admin clicks "Suspend Account" but leaves the reason blank
- When she clicks "Confirm"
- Then the error "يرجى توضيح سبب التعليق" is shown
- And the account is not suspended

**Scenario 4 — Suspension is recorded with timestamp**
- Given the admin has suspended an account
- When the admin views the account later
- Then the suspension reason and timestamp are visible

### Out of Scope
- Automatic account suspension
- Suspension appeal workflow

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)

---

## [Admin] #1741 — Operations admin reinstates a suspended rider account 🆕
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to reinstate a suspended rider account so that the rider can resume using the service.

### Background
Accessible from a suspended rider's profile screen, this action allows the admin to lift the suspension immediately. The rider can then log in again. An optional note explaining the reinstatement may be recorded.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Reinstatement note | No | Free text (textarea) | Any character | — | 500 chars | empty | — | — | Note must be ≤ 500 characters / الملاحظة طويلة جدًا، يجب ألا تتجاوز 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin reinstates a suspended rider**
- Given the admin is viewing a suspended rider's profile
- When she clicks "Reinstate Account" and optionally enters a note
- Then the rider's account status changes to active
- And the rider can log in immediately
- And a confirmation message is shown to the admin

**Scenario 2 — Reinstated rider can log in immediately**
- Given a rider has just been reinstated
- When she attempts to log in with her credentials
- Then the login succeeds and she accesses the app

**Scenario 3 — Reinstatement is recorded**
- Given the admin has reinstated an account
- When the account history is viewed
- Then the reinstatement timestamp and optional note are recorded

### Out of Scope
- Conditional reinstatement (e.g., temporary reinstatement)
- Email notification to rider upon reinstatement

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)

---

### Feature 14 — Admin — Driver Management (ADO Feature #1614)

---

## [Admin] #1665 — Admin views driver list across all statuses ✏️
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As a super admin, I want to view a searchable, filterable list of all driver accounts grouped by status so that I can monitor the driver pipeline and locate any driver quickly.

### Background
The driver list is the primary entry point for driver management in the admin portal. It shows all driver accounts regardless of onboarding status. A status filter lets the admin narrow results to a single group: Pending, Approved, Rejected, or Suspended. A search box allows free-text lookup by name or phone. The default page size is 20 rows. Clicking any row opens the driver profile (#1666).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | Any character (name or phone digits) | — | 100 chars | empty | — | — | Search must be ≤ 100 characters / يجب ألا يتجاوز البحث 100 حرف |
| Status filter | No | Dropdown (single-select) | Enum: All / Pending / Approved / Rejected / Suspended | — | — | All | — | — | — |

### Acceptance Criteria

**Scenario 1 — Admin opens the driver list**
- Given the admin is authenticated and navigates to the Drivers section
- When the page loads
- Then a table of all driver accounts is displayed with default filter "All"
- And columns shown are: name, phone number, status, onboarding submission date, total trips completed (for approved drivers)
- And the list is ordered by submission date descending

**Scenario 2 — Admin filters by status**
- Given the driver list is loaded
- When the admin selects a status filter (Pending, Approved, Rejected, or Suspended)
- Then only drivers in that status group are shown; "All" shows every driver regardless of status

**Scenario 3 — Admin searches by driver name**
- Given the driver list is loaded
- When the admin types a partial name into the search box
- Then the list filters to drivers whose name contains that text

**Scenario 4 — Admin searches by phone number**
- Given the driver list is loaded
- When the admin types a partial phone number
- Then the list filters to drivers whose phone contains that substring

**Scenario 5 — Search and filter produce no results**
- Given the admin has applied a search or filter with no matching drivers
- Then an empty state message is displayed

**Scenario 6 — Admin clicks a driver row**
- Given the driver list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the driver profile screen (#1666) for that driver

**Scenario 7 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 drivers are displayed

**Scenario 8 — Admin exports the list**
- Given the driver list is displayed with the current search and filter applied
- When the admin chooses Export
- Then the current result set is exported to CSV/Excel

### Out of Scope
- Approving or rejecting a driver from this screen
- Suspending a driver from this screen (done from the profile, #1742)
- Audit logs (see #1816)

### Dependencies
- #1667 — Driver list with status filter and search is served (must be live)
- #1742 — Driver account suspension (Suspended status source)

---

## [Admin] #1666 — Admin views driver profile ✏️
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As a super admin, I want to view a driver's full profile including their documents, vehicle details, and trip history so that I can assess their account comprehensively and take account actions when needed.

### Background
The driver profile screen is opened by clicking any row in the driver list (#1665). It presents personal details, vehicle information, uploaded document images (viewable inline), the profile photo, current status badge, aggregate statistics, and — for pending, rejected, or suspended drivers — the decision history. Below the profile, a paginated list of the driver's completed trips is shown. Approve/reject actions remain on the pending queue screens (#1657–#1660); from this screen the super admin can **suspend** an approved driver or **reinstate** a suspended one (#1742/#1743).

### Acceptance Criteria

**Scenario 1 — Admin opens an approved driver profile**
- Given the admin has clicked an approved driver row
- When the profile screen loads
- Then the following sections are displayed: personal details (name, phone, date of birth, masked national ID), vehicle details (make, model, plate number, colour), document images (viewable inline), vehicle photo, profile photo, status badge "Approved", total trips completed, and average rider rating

**Scenario 2 — Admin opens a pending or rejected driver profile**
- Given the admin has clicked a pending or rejected driver row
- When the profile screen loads
- Then all sections from Scenario 1 are shown with the corresponding status badge ("Pending" or "Rejected")
- And a decision history section shows the timeline of status changes with timestamps (and, for rejected, the reason)

**Scenario 3 — Admin opens a suspended driver profile**
- Given the admin has clicked a suspended driver row
- When the profile screen loads
- Then the status badge "Suspended" and the recorded suspension reason are shown
- And a Reinstate action (#1743) is available

**Scenario 4 — Admin takes an account action**
- Given the admin is viewing an approved driver profile
- Then a Suspend action (#1742) is available; for a suspended driver a Reinstate action (#1743) is available instead

**Scenario 5 — Admin views the driver's trip history**
- Given the driver profile is loaded for an approved driver with completed trips
- When the admin scrolls to the trip history section
- Then a paginated list of completed trips is shown with: trip date, destination area, fare collected, and rider rating received

**Scenario 6 — Driver has no completed trips**
- Given the admin opens the profile of a driver with no completed trips
- Then an empty state message is shown

**Scenario 7 — Admin navigates back to the driver list**
- Given the admin is on the driver profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the driver list at the same filter state

### Out of Scope
- Approving or rejecting a driver from this screen
- Editing driver details
- Exporting profile data

### Dependencies
- #1668 — Driver profile with trip history is served (must be live)
- #1742 / #1743 — Driver suspend / reinstate

---

## [Admin] #1742 — Operations admin suspends a driver account 🆕
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to suspend a driver's account so that I can enforce safety policies or manage driver violations.

### Background
Accessible from the driver profile screen (#1666), this action allows the admin to immediately suspend a driver's account. The driver is set offline, all sessions are invalidated, and she cannot log in or go online again until reinstated. A reason for suspension must be recorded.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspension reason | Yes | Free text (textarea) | Any character | 10 chars | 500 chars | empty | Please explain the suspension reason / يرجى توضيح سبب التعليق | — | Too short — please explain in more detail / السبب قصير جدًا، يرجى التوضيح بشكل أكثر تفصيلاً · Too long — must be ≤ 500 characters / يجب ألا يتجاوز السبب 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin suspends a driver account**
- Given the admin is viewing a driver's profile (#1666)
- When she clicks "Suspend Account" and enters a valid reason (10–500 chars)
- Then the driver's account status changes to suspended
- And all of the driver's active sessions are invalidated
- And the driver's availability is set to offline
- And a confirmation message is shown to the admin

**Scenario 2 — Driver cannot go online after suspension**
- Given a driver's account has been suspended
- When she logs in (if previously cached sessions allow) or attempts to go online
- Then the platform returns HTTP 403 and the message "Account suspended"
- And the driver remains offline

**Scenario 3 — Empty reason field**
- Given the admin clicks "Suspend Account" but leaves the reason blank
- When she clicks "Confirm"
- Then the error "يرجى توضيح سبب التعليق" is shown
- And the account is not suspended

**Scenario 4 — Suspension reason is visible on profile**
- Given a driver's account has been suspended
- When the admin views the account on the driver list or profile
- Then a "Suspended" status badge is shown
- And the suspension reason is visible in the account details

### Out of Scope
- Automatic suspension
- Driver appeal workflow
- Suspension appeal investigation

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)

---

## [Admin] #1743 — Operations admin reinstates a suspended driver account 🆕
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to reinstate a suspended driver's account so that a driver who has been cleared can go online and accept trips again.

### Background
The reinstate action is accessible from the driver detail screen for accounts in suspended state. The admin confirms reinstatement and optionally adds a note. On confirmation, the account status is updated to active via #1739. The driver must log in again before she can go online — her online status is not automatically restored.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Reinstatement note | No | Free text (textarea) | Any character | — | 500 chars | empty | — | — | Note must be ≤ 500 characters / الملاحظة طويلة جدًا، يجب ألا تتجاوز 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin reinstates a suspended driver**
- Given an admin is viewing a suspended driver's detail screen
- When the admin taps "Reinstate Account" and confirms
- Then the account status changes to active via #1739
- And the admin sees the updated status on the detail screen
- And the driver must log in again to go online

**Scenario 2 — Reinstate button is only shown for suspended accounts**
- Given an admin views a driver account that is in active state
- Then no "Reinstate Account" button is shown

### Out of Scope
- Automated reinstatement
- Driver notification on reinstatement (future sprint)

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)
- #1666 — Operations admin views driver detail (must be built)

---

### Feature 15 — Admin Operations Dashboard (ADO Feature #1615)

---

## [Admin] #1669 — Admin sees live summary dashboard ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see a live summary of key platform metrics on the dashboard so that I can monitor the health of the service at a glance.

### Background
The dashboard is the landing page of the admin portal after login. It presents **four** live key metrics in summary cards: Active Trips, Online Drivers, Total Trips Today, and Total Registered Riders. The metrics refresh automatically every 30 seconds without requiring a page reload. Each card shows a label, a numeric value, and a last-refreshed timestamp.

### Acceptance Criteria

**Scenario 1 — Admin lands on the dashboard after login**
- Given the admin has successfully logged in to the portal
- When the dashboard loads
- Then four metric cards are displayed: Active Trips, Online Drivers, Total Trips Today, Total Registered Riders
- And each card shows a numeric value retrieved from the platform (#1673)

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

## [Admin] #1670 — Admin views trip list ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As a super admin, I want to view a searchable, filterable list of all trips on the platform so that I can monitor trip activity and investigate specific trips.

### Background
The trip list screen shows all trips across all statuses. The admin can filter by trip status, apply a date range, and search by rider or driver name or phone. Columns provide enough information to identify a trip at a glance. Clicking any row opens the trip detail screen (#1671). The default page size is 20 rows ordered by creation date descending.

**Status filter → state machine mapping:**
| UI Filter | Underlying trip states |
|---|---|
| Searching | `searching` |
| Active | `matched`, `accepted`, `en_route_pickup`, `arrived_pickup`, `trip_started` |
| Completed | `trip_ended` |
| Expired | `expired` (all sub-reasons: no_driver, system_timeout, gender_mismatch_report) |

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | Any character (rider/driver name or phone) | — | 100 chars | empty | — | — | Search must be ≤ 100 characters / يجب ألا يتجاوز البحث 100 حرف |
| Status filter | No | Dropdown (single-select) | Enum: All / Searching / Active / Completed / Expired | — | — | All | — | — | — |
| Date from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before Date from | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — Admin opens the trip list**
- Given the admin navigates to the Trips section
- When the page loads
- Then a table of all trips is displayed ordered by creation date descending
- And columns shown are: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, for completed trips), and date

**Scenario 2 — Admin filters by status**
- Given the trip list is loaded
- When the admin selects a status filter (e.g., "Active")
- Then only trips whose underlying state matches that filter bucket are shown (see mapping above)

**Scenario 3 — Admin applies a date range**
- Given the trip list is loaded
- When the admin sets a from-date and a to-date
- Then only trips created within that date range are shown

**Scenario 4 — Admin sets an invalid date range (to before from)**
- Given the admin sets a to-date earlier than the from-date
- Then an inline error "End date must be after start date" is displayed and the filter is not applied

**Scenario 5 — Admin searches by rider or driver name**
- Given the trip list is loaded
- When the admin types a partial name
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
- Then the portal navigates to the trip detail screen (#1671)

**Scenario 9 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 trips are displayed

**Scenario 10 — Admin exports the list**
- Given the trip list is displayed with the current search and filters applied
- When the admin chooses Export
- Then the current result set is exported to CSV/Excel

### Out of Scope
- Cancelling or reassigning a trip from this screen (done from the trip detail, #1808 / #1809)
- Contacting the rider or driver from this screen

### Dependencies
- #1674 — Trip list with pagination and filters is served (must be live)

---

## [Admin] #1671 — Admin views trip detail with state history ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a trip's full detail and state transition timeline so that I can understand exactly how that trip progressed.

### Background
The trip detail screen is opened by clicking any row in the trip list (#1670). It shows rider and driver information, the pickup and destination addresses, and a chronological timeline of every state the trip passed through with timestamps. The timeline makes it possible to identify where a trip stalled or what sequence of events occurred. The screen is read-only for completed and expired trips; for trips that are still in progress it additionally exposes admin intervention actions — cancel the trip (#1808) or reassign it to another driver (#1809).

### Acceptance Criteria

**Scenario 1 — Admin opens a trip that is in progress**
- Given the admin has clicked an active trip row
- When the detail screen loads
- Then rider information (name, phone) and driver information (name, phone, vehicle) are shown
- And pickup and destination addresses are displayed
- And the state timeline shows all transitions up to the current state with timestamps (e.g., Created → Searching → Matched → En route pickup → Arrived → Trip started)

**Scenario 2 — Admin opens a completed trip**
- Given the admin has clicked a completed trip row
- Then all information from Scenario 1 is shown
- And the timeline includes the "Trip ended" transition with its timestamp
- And the completed trip's additional fare and rating details are shown as per #1672

**Scenario 3 — Admin opens a trip that expired (no driver found)**
- Given the admin has clicked an expired trip row
- Then the timeline shows the transitions up to "Expired" with its timestamp
- And a note indicates the reason for expiry (no driver matched, system timeout, or gender mismatch report)

**Scenario 4 — In-progress trip exposes intervention actions**
- Given the admin opens a trip that is still in progress
- Then a Cancel trip action (#1808) and a Reassign to another driver action (#1809) are available
- And these actions are not shown for completed, cancelled, or expired trips

**Scenario 5 — Admin navigates back to the trip list**
- Given the admin is on the trip detail screen
- When she clicks the back button or breadcrumb
- Then she is returned to the trip list at the same filter state

### Out of Scope
- Editing trip fields or arbitrary status changes (only Cancel #1808 and Reassign #1809 are supported)
- Contacting rider or driver from this screen
- Refund processing (see #1815 from the completed trip detail)
- SOS event logs

### Dependencies
- #1675 — Trip detail with state history is served (must be live)
- #1808 — Super admin cancels an in-progress trip
- #1809 — Super admin reassigns a trip to another driver

---

## [Admin] #1672 — Admin views completed trip with fare and rating ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see the fare breakdown and rider rating on a completed trip's detail screen so that I can verify charges and understand the rider's experience.

### Background
The completed trip detail screen extends the general trip detail screen (#1671) with two additional sections visible only for completed trips: a fare breakdown table and the rider's rating. The fare breakdown shows how the total charge was composed. The rating section shows stars and any tags the rider selected; if the rider skipped rating, it shows "No rating given". The screen remains read-only.

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

**Scenario 4 — Screen remains read-only (refunds via #1815)**
- Given the admin is viewing any completed trip detail
- When she views the fare and rating sections
- Then no edit controls are available in these sections
- And the only money action available is Manual refund (#1815)

### Out of Scope
- Editing or removing a rating
- Contacting rider or driver

### Dependencies
- #1675 — Trip detail with state history is served (must be live)
- #1637 — Completed trip is served with fare breakdown (fare data source)
- #1639 — Rider submits driver rating (rating data source)
- #1815 — Super admin processes a manual refund

---

## [Admin] #1808 — Super admin cancels an in-progress trip 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As a super admin, I want to cancel an in-progress trip so that I can resolve stuck, unsafe, or erroneous trips that the rider and driver cannot resolve themselves.

### Background
From the trip detail screen (#1671), for trips in a non-terminal state (searching, matched, accepted, en_route_pickup, arrived_pickup, trip_started), the super admin can force-cancel the trip. She selects a cancellation reason and confirms. The trip transitions to a cancelled state, the rider and driver apps are notified, any assigned driver is released to receive new trips, and no cancellation fee is charged to the rider for an admin cancellation. The action is recorded in the admin activity audit log (#1816) and on the trip state history.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Cancellation reason | Yes | Dropdown (single-select) | Enum (predefined list): Rider unreachable / Driver unresponsive / Safety concern / Duplicate or erroneous trip / Other | — | — | none | Please select a cancellation reason / يرجى اختيار سبب الإلغاء | — | — |

### Acceptance Criteria

**Scenario 1 — Cancel a searching trip**
- Given a trip is still searching for a driver
- When the super admin cancels it with a reason
- Then the trip ends as cancelled and the rider is notified; no driver was assigned

**Scenario 2 — Cancel an active (driver-assigned) trip**
- Given a trip has an assigned driver and has not ended
- When the super admin cancels it
- Then the driver is released and notified, the rider is notified, and the trip status becomes cancelled

**Scenario 3 — Reason is required**
- Given the cancel dialog is open
- When no reason is selected
- Then confirm is blocked

**Scenario 4 — No cancellation fee for an admin cancellation**
- Given the super admin cancels any in-progress trip
- Then the rider is not charged a cancellation fee

**Scenario 5 — Terminal trips cannot be cancelled**
- Given a trip that has ended or is already cancelled
- Then no cancel control is shown

**Scenario 6 — Action is audited**
- Given the super admin cancels a trip
- Then an entry is written to the audit log (#1816) with actor, trip id, reason, and timestamp

### Out of Scope
- Partial refunds (use #1815)
- Contacting the rider or driver
- Reassigning instead of cancelling (use #1809)

### Dependencies
- #1671 — Admin views trip detail with state history
- #1816 — Admin activity audit log

---

## [Admin] #1809 — Super admin reassigns a trip to another driver 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As a super admin, I want to reassign an active trip to another available driver so that a rider whose driver became unresponsive or cancelled is not left stranded.

### Background
From the trip detail screen (#1671), for a trip where a driver was assigned but the trip has not ended, the super admin can reassign it. The current driver is released and notified, the trip re-enters matching/broadcast to eligible drivers, and the rider is informed that a new driver is being found. The reassignment is written to the trip state history and the admin activity audit log (#1816).

### Acceptance Criteria

**Scenario 1 — Reassign an active trip**
- Given a trip with an assigned driver that has not ended
- When the super admin reassigns it
- Then the current driver is released and notified and the trip re-enters searching/broadcast to eligible drivers

**Scenario 2 — Rider is informed**
- Given a trip is reassigned
- Then the rider is notified that a new driver is being found

**Scenario 3 — No eligible driver available**
- Given no eligible driver can be matched after reassignment
- Then the trip remains in searching with the standard no-driver rider messaging

**Scenario 4 — Reassignment is recorded**
- Given a trip is reassigned
- Then the change is written to the trip state history and to the audit log (#1816)

**Scenario 5 — Control visibility**
- Given a trip that has ended, is cancelled, or has not yet been matched
- Then the reassign control is not shown

### Out of Scope
- Manually choosing a specific named driver (auto re-match only this phase)
- Reassignment after the trip has ended
- Contacting the rider or driver

### Dependencies
- #1671 — Admin views trip detail with state history
- #1670 — Admin views trip list
- #1816 — Admin activity audit log

---

### Feature 16 — Pricing & Rate Management (ADO Feature #1755)

---

## [Admin] #1756 — Super admin manages service zones 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to create, edit, and delete named service zones drawn as polygons on a map so that the platform knows which rate card to apply to any trip origin.

### Background
Zones are the foundation of the pricing system. Every zone has a name and a polygon boundary. The platform uses the rider's pickup coordinates to identify which zone she is in and applies that zone's rate card. There is no fallback zone — if a pickup falls outside all defined zones the trip is blocked. All of Cairo and Giza must be covered by zones before the platform goes live.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Zone name | Yes | Free text | Letters, digits and spaces; must be unique | 2 chars | 60 chars | empty | Enter a zone name / أدخل اسم المنطقة | A zone with this name already exists / يوجد منطقة بهذا الاسم بالفعل | Zone name must be 2–60 characters / يجب أن يكون اسم المنطقة بين 2 و60 حرفًا |
| Zone boundary (polygon) | Yes | Map polygon | A closed polygon of ≥ 3 points drawn on the map; no self-intersections | 3 points | — | empty | Draw the zone boundary on the map / ارسم حدود المنطقة على الخريطة | Boundary must not self-intersect / يجب ألا تتقاطع حدود المنطقة | — |

### Acceptance Criteria

**Scenario 1 — Super admin creates a new zone**
- Given the super admin is on the Zones management screen
- When she enters a zone name, draws a polygon on the map, and saves
- Then the zone is created and immediately active
- And any future trip with a pickup inside that polygon uses this zone's rate card

**Scenario 2 — Super admin edits a zone boundary**
- Given an existing zone is displayed on the map
- When the super admin adjusts the polygon boundary and saves
- Then the updated boundary takes effect immediately for new trips
- And trips already in progress are not affected

**Scenario 3 — Super admin renames a zone**
- Given an existing zone
- When the super admin changes the zone name and saves
- Then the name is updated in all rate card screens and audit logs

**Scenario 4 — Super admin deletes a zone**
- Given an existing zone with no trips currently in progress within it
- When the super admin deletes it
- Then the zone is removed and its rate card is no longer accessible
- And a confirmation dialog warns that rides in that area will be blocked until a new zone is created

**Scenario 5 — Zone names must be unique**
- Given a zone already exists with a given name
- When the super admin tries to save a new zone with the same name
- Then a validation error is returned: zone name must be unique

**Scenario 6 — Zones visible on map overview**
- Given the super admin is on the Zones screen
- Then all defined zones are rendered as coloured polygons on a Cairo/Giza map with name labels

### Out of Scope
- Zone-specific time multipliers (Phase 2)
- Importing zone polygons from a file

### Dependencies
- None — foundational

---

## [Admin] #1757 — Super admin configures zone rate card 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to set and update the pricing rates for each service zone so that fares are calculated correctly for every trip originating in that zone.

### Background
Each zone has its own rate card containing: base fare, per-km rate, per-min rate, minimum fare, and cancellation fee. Changes take effect immediately on save. Every change is recorded in the audit log. Minimum fare must be greater than or equal to the base fare. A zone with no rate card blocks trips as if the zone does not exist.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Base fare | Yes | Decimal (EGP) | Positive number, up to 2 decimals | 0.01 | — | empty | Base fare is required / الأجرة الأساسية مطلوبة | Enter a valid amount / أدخل مبلغًا صحيحًا | Base fare must be at least 0.01 EGP / يجب ألا تقل الأجرة الأساسية عن 0.01 جنيه |
| Per-km rate | Yes | Decimal (EGP) | Positive number, up to 2 decimals | 0.01 | — | empty | Per-km rate is required / سعر الكيلومتر مطلوب | Enter a valid amount / أدخل مبلغًا صحيحًا | Per-km rate must be at least 0.01 EGP / يجب ألا يقل سعر الكيلومتر عن 0.01 جنيه |
| Per-min rate | Yes | Decimal (EGP) | Positive number, up to 2 decimals | 0.01 | — | empty | Per-min rate is required / سعر الدقيقة مطلوب | Enter a valid amount / أدخل مبلغًا صحيحًا | Per-min rate must be at least 0.01 EGP / يجب ألا يقل سعر الدقيقة عن 0.01 جنيه |
| Minimum fare | Yes | Decimal (EGP) | Positive number ≥ base fare | base fare | — | empty | Minimum fare is required / الحد الأدنى للأجرة مطلوب | Enter a valid amount / أدخل مبلغًا صحيحًا | Minimum fare cannot be less than base fare / لا يمكن أن يقل الحد الأدنى للأجرة عن الأجرة الأساسية |
| Cancellation fee | Yes | Decimal (EGP) | Zero or positive, up to 2 decimals | 0 | — | empty | Cancellation fee is required / رسوم الإلغاء مطلوبة | Enter a valid amount / أدخل مبلغًا صحيحًا | Cancellation fee cannot be negative / لا يمكن أن تكون رسوم الإلغاء سالبة |

### Acceptance Criteria

**Scenario 1 — Super admin sets a rate card for a zone**
- Given a zone exists with no rate card yet
- When the super admin enters all required fields and saves
- Then the rate card is active immediately for all new trips in that zone

**Scenario 2 — Super admin updates a rate**
- Given a zone has an existing rate card
- When the super admin changes one or more values and saves
- Then the new values are active immediately for new trips
- And the previous values are preserved in the audit log

**Scenario 3 — Minimum fare must be at least equal to base fare**
- Given the super admin sets minimum fare lower than base fare
- When she tries to save
- Then a validation error is returned: minimum fare cannot be less than base fare

**Scenario 4 — All fields are required**
- Given the super admin tries to save with any field empty
- Then a validation error identifies the missing field and save is blocked

**Scenario 5 — Zone with no rate card blocks trips**
- Given a zone exists but has no rate card configured
- When a rider's pickup falls in that zone
- Then the trip is blocked and the admin panel shows a warning on that zone: "No rate card — trips will be blocked"

### Out of Scope
- Time-based rate multipliers (Phase 2)
- Per-vehicle-tier rate cards (Phase 2)
- Scheduled future rate changes

### Dependencies
- #1756 — Super admin manages service zones (zones must exist first)

---

## [Admin] #1758 — Super admin configures cancellation policy 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to configure the rider grace period, the driver/platform fee split, the driver cancellation fee, the driver cancellation grace period, and the rider no-show wait time so that both rider and driver cancellation policies are consistent and adjustable without a code deployment.

### Background
The per-zone cancellation fee amount charged to a rider lives in the zone rate card (#1757). This story covers the global cancellation-policy settings that apply across all zones:
- **Rider grace period** — minutes after driver acceptance before a rider cancellation incurs the zone cancellation fee.
- **Driver share percentage** — the share of the rider cancellation fee paid to the driver; the platform keeps the remainder.
- **Driver cancellation fee** — a fixed EGP amount charged to a driver who cancels an accepted trip after the driver cancellation grace period.
- **Driver cancellation grace period** — minutes after driver acceptance during which a driver may cancel with no fee.
- **Rider no-show wait time** — minutes a driver must wait at the pickup after marking arrived before she may cancel a rider no-show without incurring the driver cancellation fee.

All five settings are global — they do not vary per zone. Changes apply to new trips only; trips already in progress use the policy active at the time of driver acceptance. Every change is recorded in the pricing audit log (#1760).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Rider grace period | Yes | Integer (minutes) | Whole number ≥ 0 | 0 | — | empty | Enter the rider grace period / أدخل مهلة سماح الراكب | Enter a whole number of minutes / أدخل عدد دقائق صحيح | Cannot be negative / لا يمكن أن تكون القيمة سالبة |
| Driver share percentage | Yes | Percentage (%) | Whole number 1–99 | 1 | 99 | empty | Enter the driver share / أدخل نسبة السائق | Enter a whole number / أدخل رقمًا صحيحًا | Driver share must be between 1% and 99% / يجب أن تكون نسبة السائق بين 1% و99% |
| Driver cancellation fee | Yes | Decimal (EGP) | Zero or positive, up to 2 decimals | 0 | — | empty | Enter the driver cancellation fee / أدخل رسوم إلغاء السائق | Enter a valid amount / أدخل مبلغًا صحيحًا | Cannot be negative / لا يمكن أن تكون القيمة سالبة |
| Driver cancellation grace period | Yes | Integer (minutes) | Whole number ≥ 0 | 0 | — | empty | Enter the driver cancellation grace period / أدخل مهلة إلغاء السائق | Enter a whole number of minutes / أدخل عدد دقائق صحيح | Cannot be negative / لا يمكن أن تكون القيمة سالبة |
| Rider no-show wait time | Yes | Integer (minutes) | Whole number ≥ 0 | 0 | — | empty | Enter the rider no-show wait time / أدخل مدة انتظار عدم حضور الراكب | Enter a whole number of minutes / أدخل عدد دقائق صحيح | Cannot be negative / لا يمكن أن تكون القيمة سالبة |

### Acceptance Criteria

**Scenario 1 — Super admin sets the rider grace period**
- Given the super admin enters a rider grace period in minutes (e.g. 3) and saves
- Then all future rider cancellations use this grace period to determine whether the fee applies

**Scenario 2 — Super admin sets the driver/platform split**
- Given the super admin enters a driver share percentage (e.g. 70)
- When she saves
- Then the platform share is automatically shown as 100 minus the driver share
- And both percentages are displayed for confirmation before saving

**Scenario 3 — Super admin sets the driver cancellation fee**
- Given the super admin enters a fixed driver cancellation fee in EGP (e.g. 20) and saves
- Then a driver who cancels after the driver cancellation grace period is charged this amount, unless the cancellation is a waived rider no-show
- And setting the fee to 0 effectively disables the driver cancellation fee

**Scenario 4 — Super admin sets the driver cancellation grace period**
- Given the super admin enters a driver cancellation grace period in minutes (e.g. 2) and saves
- Then a driver who cancels within this window after accepting is not charged a fee
- And a driver who cancels after this window is subject to the driver cancellation fee

**Scenario 5 — Super admin sets the rider no-show wait time**
- Given the super admin enters a rider no-show wait time in minutes (e.g. 5) and saves
- Then a driver's cancellation fee is waived only when she cancels a rider no-show after having waited at least this long at the pickup

**Scenario 6 — Policy change applies to new trips only**
- Given a policy change is saved while a trip is in progress
- Then that trip uses the policy active at the time of driver acceptance
- And new trips use the updated policy

**Scenario 7 — Driver share must be between 1 and 99**
- Given the super admin enters 0 or 100 as the driver share
- Then a validation error is returned: driver share must be between 1% and 99%

**Scenario 8 — Fee and time values must be non-negative**
- Given the super admin enters a negative driver cancellation fee, grace period, or no-show wait time
- Then a validation error is returned and the change is not saved

### Out of Scope
- Per-zone grace periods or per-zone driver cancellation fees
- Different splits per vehicle tier
- Driver appeal/dispute of the cancellation fee

### Dependencies
- #1757 — Super admin configures zone rate card (rider cancellation fee amount lives there)
- #1764 — Cancellation fees are charged after grace period (consumes these settings)
- #1760 — Super admin views pricing audit log (records changes)

---

## [Admin] #1759 — Super admin configures platform commission 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to set a single global commission percentage so that the platform's share is automatically deducted from every completed trip fare.

### Background
Commission is a single global percentage applied to the total fare of every completed trip. The driver's net earnings equal the total fare minus the commission amount. The commission percentage is set by the super admin only and takes effect immediately on save. Every change is logged in the audit log. In-progress trips are not affected by a commission change.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Commission percentage | Yes | Percentage (%) | Number greater than 0 and at most 50, up to 2 decimals | 0.01 | 50 | empty | Enter the commission percentage / أدخل نسبة العمولة | Enter a valid percentage / أدخل نسبة صحيحة | Commission must be greater than 0% and at most 50% / يجب أن تكون العمولة أكبر من 0% وألا تتجاوز 50% |

### Acceptance Criteria

**Scenario 1 — Super admin sets commission percentage**
- Given the super admin enters a commission percentage (e.g. 20%) and saves
- Then all trips completed after this point use the new commission rate
- And the previous rate is preserved in the audit log

**Scenario 2 — Commission is applied to total fare**
- Given a completed trip with a total fare of 100 EGP and commission of 20%
- Then the platform retains 20 EGP and the driver's net earnings are 80 EGP
- And both amounts are stored on the trip record

**Scenario 3 — Commission cannot be 0% or above 50%**
- Given the super admin tries to save 0 or a value above 50
- Then a validation error is returned

**Scenario 4 — In-progress trips are not affected by a commission change**
- Given a trip is in progress when the commission rate is changed
- Then that trip completes using the commission rate active at the time of booking

### Out of Scope
- Per-zone commission rates
- Driver-specific commission tiers
- Commission on cancellation fees

### Dependencies
- None

---

## [Admin] #1760 — Super admin views pricing audit log 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to see a full history of every pricing change so that I can audit who changed what and when, and recover previous values if needed.

### Background
Every change to any pricing field (zone rate cards, cancellation policy, commission) is automatically recorded with: the field changed, old value, new value, who made the change, and the UTC+2 timestamp. The audit log is read-only — entries cannot be deleted or modified. The broader admin activity audit log (#1816) cross-links these pricing entries.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Zone filter | No | Dropdown (single-select) | Enum: All zones, or any defined zone name | — | — | All zones | — | — | — |
| Date range — from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date range — to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before from-date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — All pricing changes appear in the log**
- Given any super admin has saved a change to a rate card, cancellation policy, or commission setting
- Then an entry appears with: field name, zone name (if applicable), old value, new value, changed by (user name), changed at (timestamp UTC+2)

**Scenario 2 — Log is read-only**
- Given the super admin views the audit log
- Then no entry can be edited or deleted

**Scenario 3 — Log is filterable by zone and date range**
- Given the audit log contains many entries
- When the super admin filters by zone or date range
- Then only matching entries are shown

**Scenario 4 — Log is paginated**
- Given the log has more than 50 entries
- Then results are paginated with 50 entries per page

### Out of Scope
- Restoring a previous rate from the log (must be done manually)
- Exporting the log to CSV (Phase 2)

### Dependencies
- #1756 — Super admin manages service zones
- #1757 — Super admin configures zone rate card
- #1758 — Super admin configures cancellation policy
- #1759 — Super admin configures platform commission

---

### Feature 17 — Admin Safety & Incident Review (ADO Feature #1802)

> Gender-mismatch report triage is in scope now. The SOS queue, escalation workflow,
> and SLA tracker are deferred to a later phase and will be added to this feature.

---

## [Admin] #1810 — Super admin reviews the gender-mismatch report queue 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 2

**Description:** As a super admin, I want a queue of all gender-mismatch reports raised by drivers so that I can promptly review potential women-only policy violations.

### Background
SheDrive is a women-only service. When a driver reports that the rider who showed up is not female, the trip is expired with reason gender_mismatch_report and a report record is created; the reported rider's account is automatically set to pending_review on the API side (#1687). This queue lists all open gender-mismatch reports, oldest first, so the super admin can review them promptly. Each row shows the reported rider's name and phone, the reporting driver, the trip id, the report time, and the rider's current account status.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Date range — from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date range — to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before from-date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |
| Status filter | No | Dropdown (single-select) | Enum: Open / Resolved / All | — | — | Open | — | — | — |

### Acceptance Criteria

**Scenario 1 — Queue lists open reports**
- Given one or more open gender-mismatch reports exist
- When the super admin opens the queue
- Then reports are listed oldest first with reported rider, reporting driver, trip id, report time, and rider status

**Scenario 2 — Empty state**
- Given there are no open reports
- Then a clear empty-state message is shown

**Scenario 3 — Open a report**
- Given the super admin clicks a report row
- Then the detail shows the trip snapshot, the reporting driver's statement, and the rider's current account state

**Scenario 4 — Filter the queue**
- Given the queue has many entries
- When the super admin filters by date range or status (open / resolved)
- Then only matching reports are shown

**Scenario 5 — Proceed to action**
- Given a report is open
- When the super admin chooses to resolve it
- Then she is taken to the action screen (#1811)

**Scenario 6 — Export**
- Given the queue is displayed
- Then the super admin can export the current view to CSV/Excel

### Out of Scope
- SOS/emergency incident handling (later phase)
- Automated gender detection
- Penalising drivers for false reports

### Dependencies
- #1687 — Rider account is suspended after gender mismatch report (API auto pending_review)
- #1662 — Admin views rider profile
- #1811 — Super admin actions a gender-mismatch report

---

## [Admin] #1811 — Super admin actions a gender-mismatch report 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 2

**Description:** As a super admin, I want to resolve a gender-mismatch report by either suspending the reported rider or dismissing the report so that flagged accounts do not stay in limbo.

### Background
From a report in the queue (#1810), the super admin reviews the evidence and resolves it one of two ways: **Suspend** the reported rider (records a reason and applies the same suspension used by #1740 via API #1739) or **Dismiss** the report (the rider returns from pending_review to active). The decision is recorded in the audit log (#1816) and the report leaves the open queue.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspension reason | Conditional — required when Suspend is chosen | Free text (textarea) | Any character | 10 chars | 500 chars | empty | Please explain the suspension reason / يرجى توضيح سبب التعليق | — | Too short — please explain in more detail / السبب قصير جدًا، يرجى التوضيح بشكل أكثر تفصيلاً · Too long — must be ≤ 500 characters / يجب ألا يتجاوز السبب 500 حرف |

### Acceptance Criteria

**Scenario 1 — Suspend the reported rider**
- Given the super admin is reviewing a report
- When she chooses Suspend and enters a valid reason
- Then the rider's status changes to suspended, her sessions are invalidated, and the report is marked resolved-suspended

**Scenario 2 — Dismiss the report**
- Given the super admin determines the report is unfounded
- When she chooses Dismiss
- Then the rider returns from pending_review to active and the report is marked resolved-dismissed

**Scenario 3 — Reason required to suspend**
- Given the super admin chooses Suspend without a reason
- Then confirm is blocked

**Scenario 4 — Decision is audited**
- Given a report is resolved
- Then an entry is written to the audit log (#1816) with actor, rider, trip id, decision, and timestamp

**Scenario 5 — A resolved report cannot be actioned again**
- Given a report already resolved
- Then no further action controls are available

### Out of Scope
- Contacting the rider
- Driver-side penalties for false reports (later phase)
- Automated resolution

### Dependencies
- #1687 — Rider account is suspended after gender mismatch report
- #1740 / #1739 — Account suspension
- #1810 — Gender-mismatch report queue
- #1816 — Admin activity audit log

---

### Feature 18 — Admin Financial Reporting & Reconciliation (ADO Feature #1803)

---

## [Admin] #1812 — Super admin views the revenue & commission summary 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As a super admin, I want a summary of platform revenue and commission over a selected period so that I can monitor the platform's financial performance.

### Background
A financial dashboard that, for a selected date range and optional zone, summarises platform performance: total completed trips, gross fares (EGP), total platform commission (#1759), total cancellation fees collected, and net driver earnings. Figures derive from completed-trip records carrying the commission rate and fare breakdown (#1637).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Date from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before Date from | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |
| Zone filter | No | Dropdown (single-select) | Enum: All zones, or any defined zone name | — | — | All zones | — | — | — |

### Acceptance Criteria

**Scenario 1 — Summary for a date range**
- Given the super admin selects a date range
- Then total completed trips, gross fares, platform commission, cancellation fees, and net driver earnings are shown for the period

**Scenario 2 — Filter by zone**
- Given a summary is displayed
- When the super admin selects a zone
- Then the totals recompute for that zone

**Scenario 3 — Idle/empty period**
- Given no completed trips fall in the selected period
- Then all totals display zero with no error

**Scenario 4 — Totals reconcile**
- Given a non-empty period
- Then gross fares equal platform commission plus net driver earnings (plus fees per the agreed definition)

**Scenario 5 — Export**
- Given a summary is displayed
- Then the super admin can export it to CSV/Excel

### Out of Scope
- Charts and trend lines (Phase 2)
- Per-driver drill-down (see #1814)
- Tax reporting

### Dependencies
- #1759 — Super admin configures platform commission
- #1637 — Completed trip served with fare breakdown
- #1757 — Zone rate card

---

## [Admin] #1813 — Super admin reconciles driver cash balances 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As a super admin, I want to view and settle each driver's outstanding cash balance owed to the platform so that cash trips are reconciled accurately.

### Background
On cash trips the driver collects the full fare and therefore owes the platform its commission. This screen lists drivers with an outstanding cash balance (driver, total cash collected, commission owed, last settlement date) and lets the super admin record a settlement (amount received, date, optional note) which reduces the balance. Every settlement is recorded in the audit log (#1816) and reflected on the driver's earnings report (#1814). Automated payouts and bank transfers are explicitly out of MVP — settlement is an operational process.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Settlement amount | Yes | Decimal (EGP) | Positive number, up to 2 decimals; not more than the outstanding balance | 0.01 | outstanding balance | empty | Enter a settlement amount / أدخل مبلغ التسوية | Enter a valid amount / أدخل مبلغًا صحيحًا | Amount must be greater than 0 and not exceed the outstanding balance / يجب أن يكون المبلغ أكبر من 0 وألا يتجاوز الرصيد المستحق |

### Acceptance Criteria

**Scenario 1 — List drivers with an outstanding balance**
- Given drivers owe cash commission to the platform
- Then they are listed with total cash collected, commission owed, and last settlement date

**Scenario 2 — Open a driver's cash ledger**
- Given the super admin opens a driver's row
- Then a trip-by-trip ledger of cash collected and commission owed is shown

**Scenario 3 — Record a full settlement**
- Given a driver has an outstanding balance
- When the super admin records a settlement equal to the balance
- Then the balance is zeroed and the last settlement date updates

**Scenario 4 — Record a partial settlement**
- Given a driver has an outstanding balance
- When the super admin records a smaller amount
- Then the balance is reduced accordingly

**Scenario 5 — Amount validation**
- Given a settlement amount of zero, negative, or greater than the outstanding balance
- Then it is rejected with a validation error

**Scenario 6 — Settlement is audited**
- Given a settlement is recorded
- Then it appears in the audit log (#1816) and on the driver's earnings report (#1814)

**Scenario 7 — Export**
- Given the balances list is displayed
- Then the super admin can export it to CSV/Excel

### Out of Scope
- Automated payouts or bank transfers
- Digital-trip settlement (handled by the PSP)
- Driver-facing settlement notifications

### Dependencies
- #1759 — Platform commission
- Driver cash balance ledger
- #1814 — Driver earnings and settlement report
- #1816 — Admin activity audit log

---

## [Admin] #1814 — Super admin views the driver earnings & settlement report 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As a super admin, I want a per-driver earnings report for a selected period so that I can answer driver payment queries and verify settlements.

### Background
For a chosen driver and date range, this report shows completed-trips count, gross fares, commission deducted (#1759), net earnings, the cash-vs-digital split, and the current outstanding cash balance (#1813). Rows list the driver's trips with fare, commission, and net.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Driver | Yes | Dropdown / search-select | Any approved or suspended driver account | — | — | empty | Select a driver / اختر سائقًا | — | — |
| Date from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before Date from | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — Report for a driver and date range**
- Given the super admin selects a driver and a date range
- Then the totals and per-trip rows are shown for that driver and period

**Scenario 2 — Cash vs digital breakdown**
- Given a report is displayed
- Then earnings are split into cash and digital portions

**Scenario 3 — Driver with no trips**
- Given the driver completed no trips in the period
- Then an empty-state message is shown

**Scenario 4 — Figures reconcile**
- Given a report is displayed
- Then totals equal the sum of the per-trip rows and match the underlying trip records

**Scenario 5 — Export**
- Given a report is displayed
- Then the super admin can export it to CSV/Excel

### Out of Scope
- Cross-driver leaderboards and performance analytics
- Payout execution

### Dependencies
- #1637 — Completed trip served with fare breakdown
- #1759 — Platform commission
- #1813 — Cash reconciliation

---

## [Admin] #1815 — Super admin processes a manual refund 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As a super admin, I want to issue a manual refund against a completed trip so that I can resolve billing disputes and overcharges.

### Background
From a completed trip's detail (#1672) the super admin can issue a refund. For digital-paid trips she enters a refund amount (full or partial, not exceeding the amount charged) and a mandatory reason, then confirms; the refund is submitted to the PSP, the trip record is annotated, and the action is recorded in the audit log (#1816). Cash trips are refunded operationally (recorded as an offline refund, not PSP-processed).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Refund amount | Yes | Decimal (EGP) | Positive number, up to 2 decimals; not more than the amount charged | 0.01 | amount charged | empty | Enter a refund amount / أدخل مبلغ الاسترداد | Enter a valid amount / أدخل مبلغًا صحيحًا | Amount must be greater than 0 and not exceed the amount charged / يجب أن يكون المبلغ أكبر من 0 وألا يتجاوز المبلغ المدفوع |
| Reason | Yes | Free text (textarea) | Any character | 10 chars | 500 chars | empty | Please enter a refund reason / يرجى إدخال سبب الاسترداد | — | Too short — please explain in more detail / السبب قصير جدًا، يرجى التوضيح بشكل أكثر تفصيلاً · Too long — must be ≤ 500 characters / يجب ألا يتجاوز السبب 500 حرف |

### Acceptance Criteria

**Scenario 1 — Full refund of a digital trip**
- Given a completed digital-paid trip
- When the super admin refunds the full amount with a reason
- Then the PSP refund is submitted and the trip is annotated with the refund

**Scenario 2 — Partial refund**
- Given a completed digital-paid trip
- When the super admin refunds part of the amount
- Then only that amount is refunded

**Scenario 3 — Amount cannot exceed amount charged**
- Given a refund amount greater than the amount charged
- Then a validation error is shown

**Scenario 4 — Reason is required**
- Given no reason is entered
- Then confirm is blocked

**Scenario 5 — PSP failure**
- Given the PSP is unavailable
- When the refund is submitted
- Then an error is shown, no refund is recorded, and the admin can retry

**Scenario 6 — Refund is visible and audited**
- Given a refund succeeds
- Then it is shown on the trip detail and recorded in the audit log (#1816)

**Scenario 7 — Cash trip**
- Given a completed cash trip
- When the super admin records a refund
- Then it is recorded as a manual/offline refund with no PSP call

### Out of Scope
- Automated or rule-based refunds
- Commission reversal logic (defined later)
- Full dispute case management

### Dependencies
- #1672 — Admin views completed trip with fare and rating
- #1759 — Platform commission
- Payments / PSP integration
- #1816 — Admin activity audit log

---

### Feature 19 — Admin Audit & Compliance (ADO Feature #1804)

---

## [Admin] #1816 — Super admin views the admin activity audit log 🆕
**Feature:** Feature 19 — Admin Audit & Compliance | **Sprint:** 2

**Description:** As a super admin, I want a chronological, searchable log of every consequential admin action so that I can hold the team accountable and investigate decisions.

### Background
Every consequential, state-changing admin action is recorded immutably: driver approve/reject (#1659/#1660), rider and driver suspend/reinstate (#1740–#1743), gender-mismatch resolutions (#1811), trip cancel/reassign (#1808/#1809), manual refunds (#1815), cash settlements (#1813), and admin-account changes (#1807). Pricing changes keep their dedicated log (#1760) and are surfaced and cross-linked here. Each entry records the actor, action type, target entity and id, before/after values where applicable, and the timestamp (UTC+2). The log is read-only.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Actor filter | No | Dropdown (single-select) | Enum: All actors, or any admin account | — | — | All actors | — | — | — |
| Action type filter | No | Dropdown (single-select) | Enum: All, approve, reject, suspend, reinstate, cancel, reassign, refund, settlement, gender-mismatch resolution, admin-account change | — | — | All | — | — | — |
| Target entity filter | No | Free text | Any character (entity id or name) | — | 100 chars | empty | — | — | Must be ≤ 100 characters / يجب ألا يتجاوز 100 حرف |
| Date range — from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date range — to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before from-date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — Actions appear in the log**
- Given an admin performs any consequential action
- Then a corresponding entry is written to the audit log

**Scenario 2 — Entry fields are complete**
- Given an entry exists
- Then it shows actor, action type, target entity and id, before/after values where applicable, and the timestamp (UTC+2)

**Scenario 3 — Filtering**
- Given the log has many entries
- When the super admin filters by actor, action type, date range, or target entity
- Then only matching entries are shown

**Scenario 4 — Read-only**
- Given the super admin views the log
- Then no entry can be edited or deleted

**Scenario 5 — Pagination**
- Given more than 50 entries exist
- Then results are paginated 50 per page

**Scenario 6 — Export**
- Given a filtered view is displayed
- Then the super admin can export it to CSV/Excel

### Out of Scope
- Logging read-only views or navigation
- Configurable retention policy
- SIEM/export streaming integration

### Dependencies
- #1659, #1660 — Driver approve/reject
- #1740–#1743 — Suspend/reinstate
- #1807 — Manage admin users
- #1808, #1809 — Trip cancel/reassign
- #1811 — Gender-mismatch resolution
- #1813 — Cash settlement
- #1815 — Manual refund
- #1760 — Pricing audit log
