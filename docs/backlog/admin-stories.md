# SheDrive — Admin Portal Stories
> Canonical backlog for all [Admin] stories. Organized by sprint and feature.
> Last updated: 2026-06-21
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

The admin portal is a web application accessible to SheDrive operations staff. It presents a login screen (email + password) as its unauthenticated entry point. Successful authentication lands the admin on the main dashboard, which sits within a persistent shell consisting of a navigation sidebar or top bar and a content area. The portal is distinct from the rider/driver mobile app and serves as the operations team's command centre for approving drivers, monitoring trips, and managing the platform. The portal UI is English only. In this phase there is a single admin role — **super admin** — and every admin account has full privileges; finer-grained roles are a planned future addition. Two-factor authentication (#1806) is required at login, password reset (#1822) is self-service, and admin accounts are managed via #1807.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email | Yes | Email | local@domain.tld; letters, digits, . _ % + - @ | — | 254 chars | — | Enter your email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |
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
- Related: #1822 password reset, #1806 two-factor authentication, #1807 admin user management

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

## [Admin] #1807 — Super admin adds an admin user account 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want to invite/create a new admin user account by email so that I can grant a colleague access to the operations portal.

### Background

In this phase a single role — **super admin** — exists and every admin account has full portal privileges; finer-grained roles are a planned future addition. This story covers creating a new admin by email: on creation the system **generates a temporary password and emails it to the new admin's address**, and the account appears with status Active. The temporary password is single-use and the new admin must change it on her first login (#1822). Viewing the accounts list is #1820; enabling/disabling accounts is #1821.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email | Yes | Email | local@domain.tld; letters, digits, . _ % + - @; must be unique among admin accounts | — | 254 chars | — | Enter an email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح · An admin with this email already exists / يوجد مشرف بهذا البريد الإلكتروني بالفعل | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |

### Acceptance Criteria

**Scenario 1 — Super admin creates an admin account**
- Given the super admin is on the add-admin form
- When she enters a valid, unique email and confirms
- Then a temporary password is auto-generated and emailed to the new admin's address, and the account appears with status Active

**Scenario 2 — Temporary password is sent only to the new admin**
- Given the account has just been created
- Then the temporary password is delivered only to the new admin's email and is never displayed to the creating super admin
- And first login with it forces a password change (#1822)

**Scenario 3 — Duplicate email is rejected**
- Given an account already exists with a given email
- When the super admin tries to create another with the same email
- Then a validation error is shown and no account is created

**Scenario 4 — Invalid email format is rejected**
- Given the super admin enters a malformed email
- Then a validation error is shown and no account is created

**Scenario 5 — Email over the length limit is rejected**
- Given the super admin enters an email longer than 254 characters
- Then a length validation error is shown and no account is created

### Out of Scope
- Login, password reset, and first-time mandatory password change (see #1822)
- Viewing the accounts list (see #1820)
- Enabling or disabling accounts (see #1821)
- Granular roles and per-feature permissions (future RBAC)
- Editing another admin's profile details

### Dependencies
- #1656 — Admin portal shell and login
- #1822 — Admin password reset and first-login mandatory change (consumes the temporary password)
- Email delivery service (sends the temporary password)

---

## [Admin] #1820 — Super admin views the admin user accounts list 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want to view a searchable, filterable list of all admin user accounts so that I can see who has portal access and each account's status.

### Background

This screen lists all admin user accounts so the super admin ( only ) can see who has portal access. Each row shows email, status, created date, and last login. The list is searchable by email, filterable by status, and paginated. Creating accounts is #1807; enabling/disabling is #1821.

### Acceptance Criteria

**Scenario 1 — Account list shows status and last login**
- Given the admin-users screen is open
- Then each row shows email, status, created date, and last login
- And results are ordered by created date descending

**Scenario 2 — Search by email**
- Given the list is loaded
- When the super admin types part of an email
- Then the list filters to accounts whose email contains that text

**Scenario 3 — Filter by status**
- Given the list is loaded
- When the super admin selects All, Active, or Disabled
- Then only accounts in that status group are shown

**Scenario 4 — Pagination**
- Given there are more accounts than fit on one page
- When the super admin navigates to the next page
- Then the next page of accounts is displayed in the same order

**Scenario 5 — Empty state**
- Given a search or filter matches no account
- Then an empty-state message is shown

### Out of Scope
- Creating accounts (see #1807)
- Enabling or disabling accounts (see #1821)
- Editing another admin's profile details

### Dependencies
- #1656 — Admin portal shell and login

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Created date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Email | Yes | Yes | Free-text search (partial match) |
| Status | Yes | Yes | Dropdown (All / Active / Disabled) |
| Created date | Yes | No | — |
| Last login | Yes | No | — |

---

## [Admin] #1821 — Super admin enables and disables admin user accounts 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As a super admin, I want to disable and re-enable admin user accounts so that I can revoke or restore portal access without ever locking the portal out.

### Background

From the admin accounts list (#1820), the super admin can disable an active account — immediately invalidating its sessions and blocking login — or re-enable a disabled one. Creating accounts is #1807.

### Acceptance Criteria

**Scenario 1 — Super admin disables an admin**
- Given an active admin account
- When the super admin disables it
- Then its status changes to Disabled, its sessions are invalidated, and that admin can no longer log in

**Scenario 2 — Super admin re-enables an admin**
- Given a disabled admin account
- When the super admin re-enables it
- Then its status changes to Active and the admin can log in again

### Out of Scope
- Creating accounts (see #1807)
- Viewing the accounts list (see #1820)
- Granular roles and per-feature permissions (future RBAC)
- Resetting an admin's password (see #1822)

### Dependencies
- #1656 — Admin portal shell and login

---

## [Admin] #1822 — Admin password reset and first-login mandatory change 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As an admin, I want to reset my password via an emailed single-use temporary password and be required to set a new one — the same flow that applies on my first login — so that I can always regain secure access with a credential only I know.

### Background

One secure cycle covers two triggers: (1) a newly created admin's **first login** using the temporary password emailed by #1807, and (2) a **password reset** — either self-service “forgot password” or a super-admin-initiated reset for another admin. In every case the system emails a single-use temporary password; on the next login the admin is forced to set a new password before she can reach any portal screen, and the temporary password is invalidated once the new one is set. To avoid account enumeration, the forgot-password response does not reveal whether an email is registered.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email (reset request) | Yes | Email | Valid email format; only the format is validated (existence is never revealed) | — | 254 chars | — | Enter your email address / أدخل بريدك الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |
| New password | Yes | Password | At least one uppercase, one lowercase, and one digit; must differ from the temporary password | 8 chars | 128 chars | — | Enter a new password / أدخل كلمة مرور جديدة | Password must include an uppercase letter, a lowercase letter, and a number / يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير ورقم | Password must be 8–128 characters / يجب أن تتكون كلمة المرور من 8 إلى 128 حرفًا |
| Confirm password | Yes | Password | Must exactly match the new password | — | — | — | Confirm the new password / أكد كلمة المرور الجديدة | Passwords do not match / كلمتا المرور غير متطابقتين | — |

### Acceptance Criteria

**Scenario 1 — Admin requests a password reset (forgot password)**
- Given an admin enters her account email on the reset screen
- When she submits
- Then an email is sent to that address
- And the response does not reveal whether the email is registered



**Scenario 2 — First login after account creation forces a change**
- Given a newly created admin logs in for the first time with the temporary password from #1807
- Then she is routed to the mandatory change-password screen before any other portal screen

**Scenario 3 — Any temporary-password login forces a change**
- Given an admin logs in with an emailed temporary password (first login or reset)
- Then she must set a new password before reaching the portal

**Scenario 4 — Valid new password is accepted**
- Given she enters a new password meeting the policy and a matching confirmation
- When she submits
- Then the new password is saved, the temporary password is invalidated, and she lands in the portal

**Scenario 5 — Confirmation mismatch**
- Given the confirm field does not match the new password
- Then a validation error is shown and nothing is saved

**Scenario 6 — New password fails the policy**
- Given the new password is too short or missing a required character class
- Then a validation error is shown and nothing is saved

**Scenario 7 — New password must differ from the temporary password**
- Given she enters the same value as the temporary password
- Then it is rejected with an explanatory error

**Scenario 8 — Invalid or expired temporary password**
- Given the temporary password is wrong or has expired
- When she attempts to log in
- Then login is rejected and no change-password screen is shown



### Out of Scope
- Two-factor authentication or SSO
- Account lockout / rate-limiting policy details
- Changing the account email

### Dependencies
- #1807 — Adds an admin user account (emails the initial temporary password)
- #1656 — Admin portal shell and login
- Email delivery service (sends temporary passwords)

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
| Date range — from | No | Date (DD/MM/YYYY) | Valid calendar date; digits and / | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
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

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Submission date — oldest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Driver name | Yes | Yes | Free-text search (partial match) |
| Phone number | Yes | Yes | Free-text search (partial match) |
| Submission date | Yes | Yes | Date range (from / to) |
| View application | No | No | — (row action → #1658) |

---

## [Admin] #1658 — Admin views full driver application ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to view all submitted details for a single driver application so that I can make an informed approval or rejection decision.

### Background

The full application detail screen is accessed by clicking a row in the pending queue (#1657) or from a driver’s profile. It displays personal details (name, date of birth, NID), vehicle details (make, model, year, plate, color, type), the driving licence number, the driving licence expiry date and the vehicle registration expiry date, all four uploaded documents (viewable inline as images or PDF previews), and the vehicle photo. Approve and Reject action buttons are shown at the bottom of the screen. The screen is accessible only to authenticated admins.

### Acceptance Criteria

**Scenario 1 — Happy path: full application displayed**
- Given the admin clicks on a pending application from the queue
- When the detail screen loads
- Then all personal details (name, DOB, NID) are displayed
- And all vehicle details (make, model, year, plate, color, type) are displayed
- And the driving licence number, the driving licence expiry date, and the vehicle registration expiry date are displayed
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
- #1642 — Driver submits onboarding application (must be live; source of application data)

---

## [Admin] #1659 — Admin approves driver application ✏️
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to approve a driver application so that the driver is immediately notified and can begin going online to receive trips.

### Background

The Approve action is triggered from the full application detail screen (#1658). The admin clicks "Approve," a confirmation dialog is shown, and upon confirmation the system changes the application status to approved. A push notification is sent to the driver via the push service (#1618). Once approved, the driver’s account is eligible to go online, and her record appears in the active drivers list. The approval action is irreversible in these sprints.

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
- #1618 — Push notification service integration (must be live)
- #1658 — Admin views full driver application (must be live)

---

## [Admin] #1660 — Admin rejects driver application with reason
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** 1

**Description:** As an operations admin, I want to reject a driver application by selecting a reason from a predefined list (with optional notes) so that the driver is clearly informed of why her application was declined.

### Background

The Reject action is triggered from the full application detail screen (#1658). The admin clicks "Reject," selects a rejection reason from a predefined list, and may add optional free-text notes (notes are required when "Other" is selected), then confirms. The application status changes to rejected and the selected reason plus any notes are stored. A push notification including the reason is sent to the driver in the driver's preferred language. Rejected drivers cannot go online and cannot resubmit in these sprints.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Rejection reason | Yes | Dropdown (single-select) | Enum (predefined list): Applicant does not meet the women-only policy / Incomplete or unclear documents / Invalid or expired driver's license / Invalid or expired vehicle registration / Vehicle does not meet requirements / Identity could not be verified / Other | — | — | none | Please select a rejection reason / يرجى اختيار سبب الرفض | — | — |
| Additional notes | Conditional — required when "Other" is selected, otherwise optional | Free text (textarea) | Any character | 10 chars (when required) | 500 chars | empty | Please add a note explaining the reason / يرجى إضافة ملاحظة توضح السبب | — | Too long — must be ≤ 500 characters / يجب ألا تتجاوز الملاحظة 500 حرف |

### Acceptance Criteria

**Scenario 1 — Happy path: application rejected with a selected reason**
- Given the admin is viewing a pending application (#1658)
- When she clicks "Reject," selects a reason from the predefined list, optionally adds notes, and confirms
- Then the application status changes to "rejected"
- And the selected reason and any notes are stored against the application record
- And a push notification is dispatched in the driver's preferred language: "لم يتم قبول طلبك. السبب: [reason]." / "Your application was not approved. Reason: [reason]."
- And the application is removed from the pending queue (#1657)
- And the admin sees a success confirmation on screen

**Scenario 2 — No reason selected**
- Given the admin clicks "Reject" without selecting a reason from the list
- When she clicks "Confirm"
- Then the error "يرجى اختيار سبب الرفض" is shown
- And no status change or push notification is sent

**Scenario 3 — "Other" reason requires a note**
- Given the admin selects "Other" as the rejection reason and leaves the notes field blank
- When she clicks "Confirm"
- Then the error "يرجى إضافة ملاحظة توضح السبب" is shown
- And the application is not rejected

**Scenario 4 — Admin cancels the rejection dialog**
- Given the admin clicks "Reject" and opens the reason dialog
- When she clicks "Cancel" without confirming
- Then no status change occurs
- And the admin remains on the application detail screen

**Scenario 5 — Push notification fails to deliver**
- Given the admin rejects with a selected reason but the push service is unavailable
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
- #1740 — Rider account suspension (account status source)

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Registration date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Name | Yes | Yes | Free-text search (partial match) |
| Phone number | Yes | Yes | Free-text search (partial match) |
| Account status | Yes | Yes | Dropdown (All / Active / Suspended) |
| Registration date | Yes | No | — |
| Total trips completed | Yes | No | — |

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
- #1740 / #1741 — Rider suspend / reinstate
- #1810 — Gender-mismatch report queue (Pending Review source)

### List / Grid Specification

**Page size:** 10 rows/page (trip-history grid within the profile) · **Default sort:** Trip date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Trip date | Yes | No | — |
| Destination address | No | No | — |
| Fare (EGP) | Yes | No | — |
| Trip status | No | No | — |

---

## [Admin] #1740 — Operations admin suspends a rider account 🆕
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to suspend a rider's account so that a rider who has violated platform policies or is under review is immediately prevented from booking trips.

### Background

Accessible from the rider profile screen (#1662), this action allows the admin to suspend a rider's account. The admin selects a suspension reason from a predefined list; when "Other" is chosen an explanatory note is required. The selected reason (and any note) is recorded. The rider's existing sessions are invalidated and she cannot log in again until reinstated. If the rider has an active trip when the suspension is confirmed, the account is marked **Pending Suspension** and the suspension is applied automatically as soon as that trip ends; otherwise it takes effect immediately.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspension reason | Yes | Dropdown (single-select) | Enum (predefined list): Women-only policy violation (gender mismatch) / Abusive or inappropriate behaviour / Fraudulent activity / Safety concern / Repeated cancellations or no-shows / Violation of terms of service / Other | — | — | none | Please select a suspension reason / يرجى اختيار سبب التعليق | — | — |
| Additional notes | Conditional — required when "Other" is selected, otherwise optional | Free text (textarea) | Any character | 10 chars (when required) | 500 chars | empty | Please add a note explaining the reason / يرجى إضافة ملاحظة توضح السبب | — | Too long — must be ≤ 500 characters / يجب ألا تتجاوز الملاحظة 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin suspends a rider account**
- Given the admin is viewing a rider's profile (#1662)
- When she clicks "Suspend Account," selects a reason from the predefined list, optionally adds notes, and confirms
- Then the rider's account status changes to suspended
- And all of the rider's active sessions are invalidated
- And a confirmation message is shown to the admin

**Scenario 2 — Rider cannot log in after suspension**
- Given a rider's account has been suspended
- When she attempts to log in
- Then the login is rejected with an account-suspended error
- And she is directed to contact support

**Scenario 3 — No reason selected**
- Given the admin clicks "Suspend Account" without selecting a reason from the list
- When she clicks "Confirm"
- Then the error "يرجى اختيار سبب التعليق" is shown
- And the account is not suspended

**Scenario 4 — "Other" reason requires a note**
- Given the admin selects "Other" as the suspension reason and leaves the notes field blank
- When she clicks "Confirm"
- Then the error "يرجى إضافة ملاحظة توضح السبب" is shown
- And the account is not suspended

**Scenario 5 — Suspension is recorded with timestamp**
- Given the admin has suspended an account
- When the admin views the account later
- Then the selected reason, any note, and the timestamp are visible

**Scenario 6 — Suspension is deferred while a trip is in progress**
- Given the rider has an active (in-progress) trip
- When the admin confirms the suspension
- Then the account is marked "Pending Suspension" and the suspension does not take effect yet
- And the current trip continues uninterrupted to completion
- And as soon as the trip ends, the account is suspended and the rider's sessions are invalidated
- And the admin sees that the suspension will take effect when the active trip ends

### Out of Scope
- Automatic (rule-based) suspension without an admin decision
- Suspension appeal workflow

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)

---

## [Admin] #1741 — Operations admin reinstates a suspended rider account 🆕
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to reinstate a suspended rider's account so that a rider who has been cleared can resume using the service.

### Background

Accessible from a suspended rider's profile screen, this action allows the admin to lift the suspension immediately. The admin selects a reinstatement reason from a predefined list; when "Other" is chosen an explanatory note is required. The selected reason (and any note) is recorded. The rider can then log in again.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Reinstatement reason | Yes | Dropdown (single-select) | Enum (predefined list): Suspension was made in error / Issue resolved after review / Appeal approved / Policy violation remediated / Other | — | — | none | Please select a reinstatement reason / يرجى اختيار سبب إعادة التفعيل | — | — |
| Additional notes | Conditional — required when "Other" is selected, otherwise optional | Free text (textarea) | Any character | 10 chars (when required) | 500 chars | empty | Please add a note explaining the reason / يرجى إضافة ملاحظة توضح السبب | — | Too long — must be ≤ 500 characters / يجب ألا تتجاوز الملاحظة 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin reinstates a suspended rider**
- Given the admin is viewing a suspended rider's profile
- When she clicks "Reinstate Account," selects a reason from the predefined list, optionally adds notes, and confirms
- Then the rider's account status changes to active
- And the rider can log in immediately
- And a confirmation message is shown to the admin

**Scenario 2 — Reinstated rider can log in immediately**
- Given a rider has just been reinstated
- When she attempts to log in with her credentials
- Then the login succeeds and she accesses the app

**Scenario 3 — No reason selected**
- Given the admin clicks "Reinstate Account" without selecting a reason from the list
- When she clicks "Confirm"
- Then the error "يرجى اختيار سبب إعادة التفعيل" is shown
- And the account is not reinstated

**Scenario 4 — "Other" reason requires a note**
- Given the admin selects "Other" as the reinstatement reason and leaves the notes field blank
- When she clicks "Confirm"
- Then the error "يرجى إضافة ملاحظة توضح السبب" is shown
- And the account is not reinstated

**Scenario 5 — Reinstatement is recorded**
- Given the admin has reinstated an account
- When the account history is viewed
- Then the selected reason, any note, and the reinstatement timestamp are recorded

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
- #1742 — Driver account suspension (Suspended status source)

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Onboarding submission date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Name | Yes | Yes | Free-text search (partial match) |
| Phone number | Yes | Yes | Free-text search (partial match) |
| Status | Yes | Yes | Dropdown (All / Pending / Approved / Rejected / Suspended) |
| Onboarding submission date | Yes | No | — |
| Total trips completed | Yes | No | — |

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
- #1742 / #1743 — Driver suspend / reinstate

### List / Grid Specification

**Page size:** 10 rows/page (trip-history grid within the profile) · **Default sort:** Trip date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Trip date | No | No | — |
| Destination area | No | No | — |
| Fare collected | No | No | — |
| Rider rating received | No | No | — |

---

## [Admin] #1742 — Operations admin suspends a driver account 🆕
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to suspend a driver's account so that a driver who has violated platform policies is immediately prevented from going online and accepting trips.

### Background

Accessible from the driver profile screen (#1666), this action allows the admin to suspend a driver's account. The admin selects a suspension reason from a predefined list; when "Other" is chosen an explanatory note is required. The selected reason (and any note) is recorded. On suspension the driver is set offline, all sessions are invalidated, and she cannot log in or go online again until reinstated. If the driver has an active trip when the suspension is confirmed, the account is marked **Pending Suspension** and the suspension is applied automatically as soon as that trip ends; otherwise it takes effect immediately.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspension reason | Yes | Dropdown (single-select) | Enum (predefined list): Safety concern / Abusive or inappropriate behaviour / Fraudulent activity / Document or vehicle compliance issue / Repeated cancellations or no-shows / Violation of terms of service / Other | — | — | none | Please select a suspension reason / يرجى اختيار سبب التعليق | — | — |
| Additional notes | Conditional — required when "Other" is selected, otherwise optional | Free text (textarea) | Any character | 10 chars (when required) | 500 chars | empty | Please add a note explaining the reason / يرجى إضافة ملاحظة توضح السبب | — | Too long — must be ≤ 500 characters / يجب ألا تتجاوز الملاحظة 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin suspends a driver account**
- Given the admin is viewing a driver's profile (#1666)
- When she clicks "Suspend Account," selects a reason from the predefined list, optionally adds notes, and confirms
- Then the driver's account status changes to suspended
- And all of the driver's active sessions are invalidated
- And the driver's availability is set to offline
- And a confirmation message is shown to the admin

**Scenario 2 — Driver cannot go online after suspension**
- Given a driver's account has been suspended
- When she logs in (if previously cached sessions allow) or attempts to go online
- Then the platform returns HTTP 403 and the message "Account suspended"
- And the driver remains offline

**Scenario 3 — No reason selected**
- Given the admin clicks "Suspend Account" without selecting a reason from the list
- When she clicks "Confirm"
- Then the error "يرجى اختيار سبب التعليق" is shown
- And the account is not suspended

**Scenario 4 — "Other" reason requires a note**
- Given the admin selects "Other" as the suspension reason and leaves the notes field blank
- When she clicks "Confirm"
- Then the error "يرجى إضافة ملاحظة توضح السبب" is shown
- And the account is not suspended

**Scenario 5 — Suspension is deferred while a trip is in progress**
- Given the driver has an active (in-progress) trip
- When the admin confirms the suspension
- Then the account is marked "Pending Suspension" and the suspension does not take effect yet
- And the current trip continues uninterrupted to completion
- And as soon as the trip ends, the account is suspended, the driver is set offline, and her sessions are invalidated
- And the admin sees that the suspension will take effect when the active trip ends

**Scenario 6 — Suspension reason is visible on profile**
- Given a driver's account has been suspended
- When the admin views the account on the driver list or profile
- Then a "Suspended" status badge is shown
- And the suspension reason is visible in the account details

### Out of Scope
- Automatic (rule-based) suspension without an admin decision
- Driver appeal workflow
- Suspension appeal investigation

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)

---

## [Admin] #1743 — Operations admin reinstates a suspended driver account 🆕
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to reinstate a suspended driver's account so that a driver who has been cleared can go online and accept trips again.

### Background

The reinstate action is accessible from the driver detail screen for accounts in suspended state. The admin selects a reinstatement reason from a predefined list; when "Other" is chosen an explanatory note is required. The selected reason (and any note) is recorded. On confirmation, the account status is updated to active via #1739. The driver must log in again before she can go online — her online status is not automatically restored.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Reinstatement reason | Yes | Dropdown (single-select) | Enum (predefined list): Suspension was made in error / Issue resolved after review / Appeal approved / Compliance issue remediated / Other | — | — | none | Please select a reinstatement reason / يرجى اختيار سبب إعادة التفعيل | — | — |
| Additional notes | Conditional — required when "Other" is selected, otherwise optional | Free text (textarea) | Any character | 10 chars (when required) | 500 chars | empty | Please add a note explaining the reason / يرجى إضافة ملاحظة توضح السبب | — | Too long — must be ≤ 500 characters / يجب ألا تتجاوز الملاحظة 500 حرف |

### Acceptance Criteria

**Scenario 1 — Admin reinstates a suspended driver**
- Given an admin is viewing a suspended driver's detail screen
- When the admin taps "Reinstate Account," selects a reason from the predefined list, optionally adds notes, and confirms
- Then the account status changes to active via #1739
- And the admin sees the updated status on the detail screen
- And the driver must log in again to go online

**Scenario 2 — No reason selected**
- Given the admin taps "Reinstate Account" without selecting a reason from the list
- When she confirms
- Then the error "يرجى اختيار سبب إعادة التفعيل" is shown
- And the account is not reinstated

**Scenario 3 — "Other" reason requires a note**
- Given the admin selects "Other" as the reinstatement reason and leaves the notes field blank
- When she confirms
- Then the error "يرجى إضافة ملاحظة توضح السبب" is shown
- And the account is not reinstated

**Scenario 4 — Reinstate button is only shown for suspended accounts**
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

The dashboard is the landing page of the admin portal after login. It presents five live key metrics in summary cards: active trips, online drivers, total trips today, total registered riders, and total approved drivers. The metrics refresh automatically every 30 seconds without requiring a page reload. Each card shows a label, a numeric value, and a last-refreshed timestamp. A live operations map of active trips and online drivers also appears on this dashboard but is delivered as a separate story (#1823).

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



### Out of Scope
- Live operations map of active trips and online drivers (delivered separately by #1823)
- Historical trend charts or graphs
- Per-city or per-zone breakdowns
- Alerts or thresholds
- Exporting metrics

### Dependencies
- Related: #1823 — Admin live operations map

---

## [Admin] #1670 — Admin views trip list ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As a super admin, I want to view a searchable, filterable list of all trips on the platform so that I can monitor trip activity and investigate specific trips.

### Background

The trip list screen shows all trips across all statuses. The admin can filter by trip status, apply a date range, and search by rider or driver name or phone. Columns provide enough information to identify a trip at a glance. Clicking any row opens the trip detail screen (#1671). The default page size is 20 rows ordered by creation date descending.

**Status filter → state machine mapping:**

| UI Filter | Underlying trip states |
|---|---|
| Searching | searching |
| Active | matched, accepted, en_route_pickup, arrived_pickup, trip_started |
| Completed | trip_ended |
| Expired | expired (all sub-reasons: no_driver, system_timeout, gender_mismatch_report) |

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


### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Creation date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Trip ID | No | No | — |
| Rider name | Yes | Yes | Free-text search (partial match — name or phone) |
| Driver name | Yes | Yes | Free-text search (partial match — name or phone) |
| Pickup area | No | No | — |
| Destination area | No | No | — |
| Status | Yes | Yes | Dropdown (All / Searching / Active / Completed / Expired) |
| Fare (EGP) | Yes | No | — |
| Date | Yes | Yes | Date range (from / to) |

---

## [Admin] #1671 — Admin views trip detail with state history ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a trip's full detail and state transition timeline so that I can understand exactly how that trip progressed.

### Background

The trip detail screen is opened by clicking any row in the trip list (#1670). It shows rider and driver information, the pickup and destination addresses, and a chronological timeline of every state the trip passed through with timestamps. The timeline makes it possible to identify where a trip stalled or what sequence of events occurred. For any trip that has not yet completed (in progress, cancelled, or expired), the screen also shows the original fare estimate captured at booking — estimated trip time and estimated fare — so the admin can visualise what the trip was quoted before it ran. The final fare breakdown appears only once the trip completes (#1672). The screen is read-only for completed and expired trips; for trips that are still in progress it additionally exposes admin intervention actions — cancel the trip (#1808) or reassign it to another driver (#1809).

### Acceptance Criteria

**Scenario 1 — Admin opens a trip that is in progress**
- Given the admin has clicked an active trip row
- When the detail screen loads
- Then rider information (name, phone) and driver information (name, phone, vehicle) are shown
- And pickup and destination addresses are displayed
- And the state timeline shows all transitions up to the current state with timestamps (e.g., Created → Searching → Matched → En route pickup → Arrived → Trip started)

**Scenario 2 — Original fare estimate shown for an in-progress or incomplete trip**
- Given the admin opens a trip that has not completed (in progress, cancelled, or expired)
- When the detail screen loads
- Then the original fare estimate captured at booking is displayed: estimated trip time and estimated fare (EGP) and destination
- And the admin can compare the estimate against the trip's live progress
- And the final fare breakdown is shown only once the trip is completed (#1672)

**Scenario 3 — Admin opens a completed trip**
- Given the admin has clicked a completed trip row
- Then all information from Scenario 1 is shown
- And the timeline includes the "Trip ended" transition with its timestamp
- And the completed trip's additional fare and rating details are shown as per #1672

**Scenario 4 — Admin opens a trip that expired (no driver found)**
- Given the admin has clicked an expired trip row
- Then the timeline shows the transitions up to "Expired" with its timestamp
- And a note indicates the reason for expiry (no driver matched, system timeout, or gender mismatch report)

**Scenario 5 — In-progress trip exposes intervention actions**
- Given the admin opens a trip that is still in progress
- Then a Cancel trip action (#1808) and a Reassign to another driver action (#1809) are available
- And these actions are not shown for completed, cancelled, or expired trips

**Scenario 6 — Admin navigates back to the trip list**
- Given the admin is on the trip detail screen
- When she clicks the back button or breadcrumb
- Then she is returned to the trip list at the same filter state

### Out of Scope
- Editing trip fields or arbitrary status changes (only Cancel #1808 and Reassign #1809 are supported)
- Contacting rider or driver from this screen
- Refund processing (see #1815 from the completed trip detail)
- SOS event logs

### Dependencies
- #1808 — Super admin cancels an in-progress trip
- #1809 — Super admin reassigns a trip to another driver

---

## [Admin] #1672 — Admin views completed trip with fare and rating ✏️
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see the fare breakdown and rider rating on a completed trip's detail screen so that I can verify charges and understand the rider's experience.

### Background

The completed trip detail screen extends the general trip detail screen (#1671) with three additional sections visible only for completed trips: the actual route travelled on a map, a fare breakdown table, and the rider's rating. The route map shows the recorded GPS path the trip actually followed from pickup to drop-off, with the actual distance and duration. The fare breakdown shows how the total charge was composed. The rating section shows stars and any tags the rider selected; if the rider skipped rating, it shows "No rating given". The screen remains read-only.

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

**Scenario 4 — Admin views the actual route travelled**
- Given the admin has opened the detail screen for a completed trip
- When the route section renders
- Then a map displays the actual route the trip followed from pickup to drop-off (the recorded GPS path)
- And the pickup and drop-off points are marked on the map
- And the actual distance and duration travelled are shown

**Scenario 5 — Screen remains read-only (refunds via #1815)**
- Given the admin is viewing any completed trip detail
- When she views the route, fare, and rating sections
- Then no edit controls are available in these sections
- And the only money action available is Manual refund (#1815)

### Out of Scope
- Editing or removing a rating
- Contacting rider or driver

### Dependencies
- #1637 — Completed trip is served with fare breakdown (fare data source)
- #1639 — Rider submits driver rating (rating data source)
- #1815 — Super admin processes a manual refund

---

## [Admin] #1823 — Admin sees a live operations map of active trips and online drivers 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want a live map that plots all active trips and online drivers and updates in real time, so that I can monitor the fleet geographically and spot issues at a glance.

### Background

A real-time map in the admin operations area that plots every currently online driver and every rider request trip across the service area (Cairo/Giza). Markers refresh automatically on a short interval (target ~5 seconds) from the driver GPS stream (#1653) and the trip state machine (#1652) without a page reload. Marker types are visually distinct — an idle online driver, a driver on an active trip, and a trip's pickup/destination point. The default viewport is the Cairo/Giza service area; the UI is English only. Marker clustering (#1824), marker detail and drill-down (#1825), and the layer filter (#1826) are delivered as separate stories.

### Acceptance Criteria

**Scenario 1 — Map loads with the current fleet**
- Given the admin opens the live operations map
- When the map loads
- Then a map centered on the Cairo/Giza service area shows markers for all online drivers and rides requests.

**Scenario 2 — Markers update in near-real-time**
- Given drivers are moving and trips are progressing
- When the refresh interval elapses (target ~5 seconds)
- Then marker positions and statuses update automatically without a page reload

**Scenario 3 — Marker types are distinguishable**
- Given the map is displayed
- Then an idle online driver, a driver on an active trip, and a trip's pickup/destination are each shown with a visually distinct marker

**Scenario 4 — Idle state**
- Given no drivers are online and no trips are active
- Then the map renders with an empty-state message and no markers

**Scenario 5 — Viewport preserved on refresh**
- Given the admin has panned or zoomed the map
- When markers refresh
- Then her current viewport is preserved and the map does not recenter

### Out of Scope
- Marker clustering (see #1824)
- Marker detail and drill-down to trip detail (see #1825)
- Layer filter (see #1826)
- Historical route playback / replay
- Heatmaps and density analytics
- Geofencing or proximity alerts
- Rider-facing live tracking (see #1818)
- Dispatch actions from the map — cancel/reassign are done from the trip detail (#1808)

### Dependencies
- #1653 — Driver streams GPS from acceptance to completion (live driver positions)
- #1652 — Driver advances trip state machine (live trip status)
- #1656 — Admin portal shell and login
- Google Maps JavaScript API (maps provider)
- Related: #1824, #1825, #1826 — clustering, drill-down, and layer filter

---

## [Admin] #1824 — Operations map clusters markers at low zoom 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want nearby markers on the live operations map to cluster when I zoom out so that a busy map stays readable.

### Background

Extends the live operations map (#1823). When many driver and ride-request markers fall close together, they are grouped into clusters so the map stays readable; clusters carry a count and break apart as the admin zooms in. Uses the Google Maps marker-clustering capability.

### Acceptance Criteria

**Scenario 1 — Markers cluster at low zoom**
- Given many markers fall within a small area
- When the admin is zoomed out
- Then nearby markers are grouped into a cluster showing a count badge

**Scenario 2 — Cluster expands on zoom-in**
- Given a cluster is displayed
- When the admin zooms in (or clicks the cluster)
- Then the cluster breaks apart into its individual markers

**Scenario 3 — Individual markers at high zoom**
- Given the admin is zoomed in enough that markers no longer overlap
- Then each driver or ride request is shown as its own marker with no clustering

**Scenario 4 — Clusters stay accurate during refresh**
- Given markers move or are added/removed on the periodic refresh
- Then cluster groupings and counts update accordingly without a page reload

### Out of Scope
- Heatmaps / density shading
- Custom cluster styling beyond count badges

### Dependencies
- #1823 — Admin live operations map (base map and markers)
- Google Maps JavaScript API marker clustering

---

## [Admin] #1825 — Operations map marker shows detail and links to trip detail 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to click a map marker to see a quick summary and open the full trip detail so that I can investigate without leaving the map.

### Background

Extends the live operations map (#1823). Clicking a marker opens a quick summary popover. For an online-driver marker, the popover shows the driver's details, and if she is currently on an active trip it also shows that trip's details with a link to the full trip detail (#1671). For a ride-request marker, the popover shows the request summary.

### Acceptance Criteria

**Scenario 1 — Click an idle driver marker**
- Given the admin clicks an online driver who is not on a trip
- Then a popover shows the driver's name and vehicle.

**Scenario 2 — Click a driver marker with an active trip**
- Given the admin clicks an online driver who is currently on an active trip
- Then the popover shows the driver's details and the active trip's details (trip id, rider, pickup, destination, current status)
- And a link is shown to open the full trip detail (#1671)

**Scenario 3 — Click a ride-request marker**
- Given the admin clicks a ride-request marker
- Then a popover shows the request summary: rider, pickup, destination, estimated fare, and time since the request was made

**Scenario 4 — Open the full trip detail**
- Given a driver's active-trip popover is open
- When the admin clicks the trip detail link
- Then the full trip detail screen (#1671) opens for that trip

**Scenario 5 — Dismiss the popover**
- Given a popover is open
- When the admin clicks elsewhere on the map or closes it
- Then the popover is dismissed and the map remains in place

### Out of Scope
- Editing trip, driver, or request data from the popover
- Dispatch actions (cancel/reassign) — done from the trip detail (#1808)

### Dependencies
- #1823 — Admin live operations map (base map and markers)
- #1652 — Driver advances trip state machine (active-trip status source)
- #1671 — Admin views trip detail (drill-down target)

---

## [Admin] #1826 — Operations map layer filter (drivers / ride requests) 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to filter the live operations map by online drivers or ride requests so that I can focus on what I am monitoring.

### Background

Extends the live operations map (#1823) with a layer filter that limits which markers are shown — all, only online drivers, or only ride requests. The selection persists across the map's periodic refresh.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Map layer filter | No | Dropdown (single-select) | Enum: All / Online drivers / Ride requests | — | — | All | — | — | — |

### Acceptance Criteria

**Scenario 1 — Default shows all markers**
- Given the admin opens the map
- Then the filter defaults to All and both online drivers and ride requests are shown

**Scenario 2 — Filter to online drivers**
- Given the admin selects “Online drivers”
- Then only online-driver markers are shown and ride-request markers are hidden

**Scenario 3 — Filter to ride requests**
- Given the admin selects “Ride requests”
- Then only ride-request markers are shown and driver markers are hidden



### Out of Scope
- Filtering by zone, driver, or request sub-states
- Saving a default filter per admin

### Dependencies
- #1823 — Admin live operations map (base map and markers)

---

### Feature 16 — Pricing & Rate Management (ADO Feature #1755)

---

## [Admin] #1756 — Super admin creates a service zone 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to create a named service zone by drawing its boundary on a map so that the platform can recognise trips originating in that area.

### Background

Zones are the foundation of the pricing system. Every zone has a name and a polygon boundary. The platform uses the rider's pickup coordinates to identify which zone she is in and applies that zone's rate card. There is no fallback zone — if a pickup falls outside all defined zones the trip is blocked. All of Cairo and Giza must be covered by zones before the platform goes live. This story covers **creating** a zone. A newly created zone has no rate card yet, so it starts **Inactive** and does not accept trips until a rate card is configured (#1757). Viewing all zones (list + map) is #1831; editing or deleting a zone is #1830.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Zone name | Yes | Free text | Letters, digits and spaces; must be unique | 2 chars | 60 chars | empty | Enter a zone name / أدخل اسم المنطقة | A zone with this name already exists / يوجد منطقة بهذا الاسم بالفعل | Zone name must be 2–60 characters / يجب أن يكون اسم المنطقة بين 2 و60 حرفًا |
| Zone boundary (polygon) | Yes | Map polygon | A closed polygon of ≥ 3 points drawn on the map; no self-intersections | 3 points | — | empty | Draw the zone boundary on the map / ارسم حدود المنطقة على الخريطة | Boundary must not self-intersect / يجب ألا تتقاطع حدود المنطقة | — |

### Acceptance Criteria

**Scenario 1 — Super admin creates a new zone**
- Given the super admin is on the create-zone screen
- When she enters a zone name, draws a polygon on the map, and saves
- Then the zone is created and recognised by the platform for trips originating inside that polygon

**Scenario 2 — New zone starts Inactive until a rate card is configured**
- Given a zone has just been created with no rate card yet
- Then it is Inactive and does not accept trips
- And it becomes Active automatically once a valid rate card is saved for it (#1757)

**Scenario 3 — Zone names must be unique**
- Given a zone already exists with a given name
- When the super admin tries to save a new zone with the same name
- Then a validation error is returned: zone name must be unique

**Scenario 4 — New boundary must be valid**
- Given the super admin draws a boundary with fewer than 3 points or one that self-intersects
- Then a validation error is returned and the zone is not created

### Out of Scope
- Viewing the zone list and map overview (see #1831)
- Editing or deleting zones (see #1830)
- Configuring the zone rate card (see #1757)
- Zone-specific time multipliers (Phase 2)
- Importing zone polygons from a file

### Dependencies
- #1757 — Super admin configures zone rate card (activates the zone)
- #1831 — Super admin views the service-zone list and map

---

## [Admin] #1757 — Super admin configures zone rate card 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to set and update each service zone's rate card so that fares are computed from the correct per-zone pricing.

### Background

This is the super admin's **per-zone rate-card** configuration under Pricing & Rate Management. Each service zone has its own rate card: base fare, per-km rate, per-min rate, minimum fare, and cancellation fee. Saving a zone's first complete, valid rate card makes the zone **Active** — it begins accepting trips; a zone with no rate card is **Inactive** and blocks trips in its area (status is derived automatically from the rate card, never toggled by hand). Changes take effect immediately on save, and are recorded in the pricing audit log (#1760). Minimum fare must be ≥ base fare. The global cancellation policy and platform commission are configured separately in #1759.

### Field Validation — Zone rate card (per zone)

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Base fare | Yes | Decimal (EGP) | Positive number, up to 2 decimals | 0.01 | — | empty | Base fare is required / الأجرة الأساسية مطلوبة | Enter a valid amount / أدخل مبلغًا صحيحًا | Base fare must be at least 0.01 EGP / يجب ألا تقل الأجرة الأساسية عن 0.01 جنيه |
| Per-km rate | Yes | Decimal (EGP) | Positive number, up to 2 decimals | 0.01 | — | empty | Per-km rate is required / سعر الكيلومتر مطلوب | Enter a valid amount / أدخل مبلغًا صحيحًا | Per-km rate must be at least 0.01 EGP / يجب ألا يقل سعر الكيلومتر عن 0.01 جنيه |
| Per-min rate | Yes | Decimal (EGP) | Positive number, up to 2 decimals | 0.01 | — | empty | Per-min rate is required / سعر الدقيقة مطلوب | Enter a valid amount / أدخل مبلغًا صحيحًا | Per-min rate must be at least 0.01 EGP / يجب ألا يقل سعر الدقيقة عن 0.01 جنيه |
| Minimum fare | Yes | Decimal (EGP) | Positive number ≥ base fare | base fare | — | empty | Minimum fare is required / الحد الأدنى للأجرة مطلوب | Enter a valid amount / أدخل مبلغًا صحيحًا | Minimum fare cannot be less than base fare / لا يمكن أن يقل الحد الأدنى للأجرة عن الأجرة الأساسية |
| Cancellation fee | No | Decimal (EGP) | Zero or positive, up to 2 decimals | 0 | — | empty | Cancellation fee is required / رسوم الإلغاء مطلوبة | Enter a valid amount / أدخل مبلغًا صحيحًا | Cancellation fee cannot be negative / لا يمكن أن تكون رسوم الإلغاء سالبة |

### Acceptance Criteria

**Scenario 1 — Sets a rate card for a zone and activates it**
- Given a newly created zone that is Inactive with no rate card yet
- When the super admin enters all required fields and saves
- Then the rate card is active immediately and the zone status changes to Active and starts accepting new trips

**Scenario 2 — Updates a rate**
- Given a zone has an existing rate card
- When the super admin changes one or more values and saves
- Then the new values are active immediately for new trips and the previous values are preserved in the audit log

**Scenario 3 — Minimum fare must be at least the base fare**
- Given the super admin sets minimum fare lower than base fare
- Then a validation error is returned: minimum fare cannot be less than base fare

**Scenario 4 — All rate-card fields are required**
- Given the super admin tries to save with any field empty
- Then a validation error identifies the missing field and save is blocked

**Scenario 5 — Inactive zone (no rate card) blocks trips**
- Given a zone exists but has no rate card configured (Inactive)
- When a rider's pickup falls in that zone
- Then the trip is blocked and the overview shows the zone as Inactive with a warning: "No rate card — trips will be blocked"

**Scenario 6 — Status is derived, not manual**
- Given the super admin is configuring rate cards
- Then there is no manual control to activate or deactivate a zone — a zone is Active whenever it has a valid rate card and Inactive whenever it does not

### Out of Scope
- Manual activation/deactivation of a zone (status is derived from the rate card)
- Global cancellation policy and platform commission (see #1759)
- Time-based rate multipliers (Phase 2)
- Per-vehicle-tier rate cards (Phase 2)
- Scheduled future rate changes

### Dependencies
- #1756 — Super admin creates a service zone (zones must exist first)
- #1760 — Super admin views pricing audit log (records changes)

---

## [Admin] #1759 — Super admin configures global pricing policies (cancellation policy + platform commission) 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to configure the global cancellation policy and the platform commission so that fees, the driver/platform split, and the platform's share are managed consistently across all zones.

### Background

These are the **global** pricing policies under Pricing & Rate Management, applied across all zones: the **cancellation policy** (rider grace period, driver share %, driver cancellation fee, driver cancellation grace period, rider no-show wait time) and the **platform commission** percentage. Changes take effect immediately on save and apply to new trips only — in-progress trips use the values active at driver acceptance. Every change is recorded in the pricing audit log (#1760). The per-zone rate card (including the per-zone rider cancellation fee amount) is configured in #1757.

### Field Validation — Cancellation policy (global)

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Rider grace period | Yes | Integer (minutes) | Whole number ≥ 0 | 0 | — | empty | Enter the rider grace period / أدخل مهلة سماح الراكب | Enter a whole number of minutes / أدخل عدد دقائق صحيح | Cannot be negative / لا يمكن أن تكون القيمة سالبة |
| — | — | — | — | — | — | — | — | — | — |
| Driver cancellation fee | Yes | Decimal (EGP) | Zero or positive, up to 2 decimals | 0 | — | empty | Enter the driver cancellation fee / أدخل رسوم إلغاء السائق | Enter a valid amount / أدخل مبلغًا صحيحًا | Cannot be negative / لا يمكن أن تكون القيمة سالبة |
| Driver cancellation grace period | Yes | Integer (minutes) | Whole number ≥ 0 | 0 | — | empty | Enter the driver cancellation grace period / أدخل مهلة إلغاء السائق | Enter a whole number of minutes / أدخل عدد دقائق صحيح | Cannot be negative / لا يمكن أن تكون القيمة سالبة |
| Rider no-show wait time | Yes | Integer (minutes) | Whole number ≥ 0 | 0 | — | empty | Enter the rider no-show wait time / أدخل مدة انتظار عدم حضور الراكب | Enter a whole number of minutes / أدخل عدد دقائق صحيح | Cannot be negative / لا يمكن أن تكون القيمة سالبة |

### Field Validation — Platform commission (global)

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Commission percentage | Yes | Percentage (%) | Number greater than 0 and at most 50, up to 2 decimals | 0.01 | 50 | empty | Enter the commission percentage / أدخل نسبة العمولة | Enter a valid percentage / أدخل نسبة صحيحة | Commission must be greater than 0% and at most 50% / يجب أن تكون العمولة أكبر من 0% وألا تتجاوز 50% |

### Acceptance Criteria

**Cancellation policy**

**Scenario 1 — Sets the rider grace period**
- Given the super admin enters a rider grace period in minutes (e.g. 3) and saves
- Then all future rider cancellations use this grace period to determine whether the fee applies



**Scenario 2 — Sets the driver cancellation fee**
- Given the super admin enters a fixed driver cancellation fee in EGP (e.g. 20) and saves
- Then a driver who cancels after the driver cancellation grace period is charged this amount, unless the cancellation is a waived rider no-show; setting it to 0 disables the fee

**Scenario 3 — Sets the driver cancellation grace period**
- Given the super admin enters a driver cancellation grace period in minutes (e.g. 2) and saves
- Then a driver who cancels within this window after accepting is not charged, and one who cancels after it is subject to the driver cancellation fee

**Scenario 4 — Sets the rider no-show wait time**
- Given the super admin enters a rider no-show wait time in minutes (e.g. 5) and saves
- Then a driver's cancellation fee is waived only when she cancels a rider no-show after waiting at least this long at the pickup

**Scenario 5 — Policy change applies to new trips only**
- Given a policy change is saved while a trip is in progress
- Then that trip uses the policy active at the time of driver acceptance and new trips use the updated policy

**Scenario 6 — Driver share must be between 1 and 99**
- Given the super admin enters 0 or 100 as the driver share
- Then a validation error is returned: driver share must be between 1% and 99%

**Scenario 7 — Fee and time values must be non-negative**
- Given the super admin enters a negative driver cancellation fee, grace period, or no-show wait time
- Then a validation error is returned and the change is not saved

**Platform commission**

**Scenario 8 — Sets the commission percentage**
- Given the super admin enters a commission percentage (e.g. 20%) and saves
- Then all trips completed after this point use the new rate and the previous rate is preserved in the audit log

**Scenario 9 — Commission is applied to total fare**
- Given a completed trip with total fare 100 EGP and commission 20%
- Then the platform retains 20 EGP, the driver's net earnings are 80 EGP, and both are stored on the trip record

**Scenario 10 — Commission cannot be 0% or above 50%**
- Given the super admin tries to save 0 or a value above 50
- Then a validation error is returned



### Out of Scope
- Per-zone grace periods or per-zone driver cancellation fees
- Different splits per vehicle tier
- Driver appeal/dispute of the cancellation fee
- Per-zone commission rates
- Driver-specific commission tiers
- Commission on cancellation fees

### Dependencies
- #1757 — Super admin configures zone rate card (per-zone rider cancellation fee lives there)
- #1764 — Cancellation fees are charged after grace period (consumes these settings)
- #1760 — Super admin views pricing audit log (records changes)

---

## [Admin] #1830 — Super admin edits and deletes service zones 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to edit a zone's name or boundary and delete zones I no longer need so that the zone map stays accurate as the city's coverage changes.

### Background

This covers editing and deleting existing service zones; creating and listing zones is #1756. A boundary change takes effect immediately for new trips, and a rename cascades to all rate-card screens and audit logs. Because there is no fallback zone, deleting a zone blocks rides in that area until a replacement is drawn — so deletion requires a confirmation and is blocked while any trip is in progress inside the zone. Every change is recorded in the pricing audit log (#1760).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Zone name | Yes | Free text | Letters, digits and spaces; must be unique | 2 chars | 60 chars | — | Enter a zone name / أدخل اسم المنطقة | A zone with this name already exists / يوجد منطقة بهذا الاسم بالفعل | Zone name must be 2–60 characters / يجب أن يكون اسم المنطقة بين 2 و60 حرفًا |
| Zone boundary (polygon) | Yes | Map polygon | A closed polygon of ≥ 3 points drawn on the map; no self-intersections | 3 points | — | — | Draw the zone boundary on the map / ارسم حدود المنطقة على الخريطة | Boundary must not self-intersect / يجب ألا تتقاطع حدود المنطقة | — |

### Acceptance Criteria

**Scenario 1 — Edits a zone boundary**
- Given an existing zone is displayed on the map
- When the super admin adjusts the polygon boundary and saves
- Then the updated boundary takes effect immediately for new trips and the change is recorded in the audit log

**Scenario 2 — Renames a zone**
- Given an existing zone
- When the super admin changes the zone name and saves
- Then the name is updated everywhere it appears, including rate-card screens and audit logs

**Scenario 3 — Rename must remain unique**
- Given another zone already uses a given name
- When the super admin renames a zone to that same name
- Then a validation error is returned: zone name must be unique

**Scenario 4 — Edited boundary must stay valid**
- Given the super admin edits a boundary so it has fewer than 3 points or self-intersects
- Then a validation error is returned and the change is not saved

**Scenario 5 — Deletes a zone**
- Given an existing zone with no trips currently in progress within it
- When the super admin deletes it and confirms
- Then the zone is removed, its rate card is no longer accessible, and a confirmation dialog first warns that rides in that area will be blocked until a new zone is created

**Scenario 6 — Cannot delete a zone with trips in progress**
- Given a zone has one or more trips currently in progress within it
- When the super admin attempts to delete it
- Then deletion is blocked with a message that the zone has active trips and cannot be deleted yet

### Out of Scope
- Creating and listing zones (see #1756)
- Importing zone polygons from a file
- Zone-specific time multipliers (Phase 2)
- Bulk edit or bulk delete of zones
- Merging or splitting existing zones

### Dependencies
- #1756 — Super admin creates and lists service zones (zones must exist first)
- #1757 — Super admin configures zone rate card (a deleted zone's rate card becomes inaccessible)
- #1760 — Super admin views pricing audit log (records changes)

---

## [Admin] #1831 — Super admin views the service-zone list and map 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As a super admin, I want to see all service zones on a map and in a list, each showing whether it is active or inactive, so that I can review coverage and spot zones that are not yet ready to take trips.

### Background

This is the read-only zones overview: a map showing every service zone as a coloured polygon, and a list/grid of all zones with each zone's **Active/Inactive** status. Status is derived automatically from the rate card — a zone with a valid rate card (#1757) is **Active** and accepts trips, while a zone with no rate card is **Inactive** and blocks trips in its area. Status is never set manually. Creating a zone is #1756; editing or deleting a zone is #1830.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Status filter | No | Dropdown (single-select) | Enum: All, Active, Inactive | — | — | All | — | — | — |
| Zone name search | No | Free text | Partial, case-insensitive match on zone name | — | 60 chars | empty | — | — | — |

### Acceptance Criteria

**Scenario 1 — Map overview shows all zones**
- Given the super admin opens the Zones overview
- Then every defined zone is rendered as a coloured polygon on a Cairo/Giza map with its name label
- And Active and Inactive zones are visually distinct (e.g. Active filled, Inactive greyed)

**Scenario 2 — List shows all zones with status**
- Given one or more zones exist
- Then the list shows each zone's name, status (Active/Inactive), who created it, and when

**Scenario 3 — Status is derived from the rate card**
- Given a zone has a valid rate card configured (#1757)
- Then it is shown as Active
- And a zone with no rate card is shown as Inactive
- And the status updates automatically when a rate card is added or removed — it is never toggled manually

**Scenario 4 — Filter by status**
- Given the overview is displayed
- When the super admin filters by Active or Inactive
- Then only zones with that status are shown in both the list and the map

**Scenario 5 — Search by zone name**
- Given many zones exist
- When the super admin types part of a zone name
- Then the list narrows to matching zones

**Scenario 6 — Open a zone for create/edit/delete**
- Given the overview is displayed
- Then the super admin can start creating a new zone (#1756) or open an existing zone to edit or delete it (#1830)

**Scenario 7 — Empty state**
- Given no zones have been created yet
- Then the overview shows an empty state prompting the super admin to create the first zone

### Out of Scope
- Creating zones (see #1756)
- Editing or deleting zones (see #1830)
- Configuring the rate card (see #1757)
- Manually toggling a zone's active/inactive status (status is automatic)

### Dependencies
- #1756 — Super admin creates a service zone
- #1757 — Super admin configures zone rate card (drives Active/Inactive status)
- #1830 — Super admin edits and deletes service zones (row/map actions)

### List / Grid Specification

**Page size:** 50 rows/page (server-side pagination) · **Default sort:** Zone name — A→Z

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Zone name | Yes | Yes | Text search |
| Status | Yes | Yes | Dropdown (All / Active / Inactive) |
| Created by | No | No | — |
| Created at (UTC+2) | Yes | Yes | Date range (from / to) |

---

### Feature 17 — Admin Safety & Incident Review (ADO Feature #1802)

---

## [Admin] #1810 — Super admin reviews the gender-mismatch report queue 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 2

**Description:** As a super admin, I want a queue of all driver-raised gender-mismatch reports so that I can promptly review potential women-only policy violations and open each one for resolution.

### Background

SheDrive is a women-only service. When a driver reports that the rider who showed up is not female, the trip is expired with reason gender_mismatch_report, a report record is created, and the reported rider's account is automatically set to pending_review on the API side (#1687). This screen is the **queue** of all open reports (oldest first — reported rider, reporting driver, trip id, report time, rider status); the super admin opens a report to review the trip snapshot, the reporting driver's statement, and the rider's current account state, then proceeds to resolve it. Resolving a report (suspend or dismiss) is handled by #1811.

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

**Scenario 5 — Export**
- Given the queue is displayed
- Then the super admin can export the current view to CSV/Excel

**Scenario 6 — Proceed to action**
- Given a report is open
- When the super admin chooses to resolve it
- Then she is taken to the action step (#1811)

### Out of Scope
- Resolving a report — suspend or dismiss (see #1811)
- SOS/emergency incident handling (later phase)
- Automated gender detection
- Penalising drivers for false reports (later phase)
- Contacting the rider
- Automated resolution

### Dependencies
- #1687 — Rider account is suspended after gender mismatch report (API auto pending_review)
- #1662 — Admin views rider profile
- #1811 — Super admin actions a gender-mismatch report
- #1816 — Admin activity audit log

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Report time — oldest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Reported rider | Yes | No | — |
| Reported rider phone | No | No | — |
| Reporting driver | No | No | — |
| Trip ID | No | No | — |
| Report time | Yes | Yes | Date range (from / to) |
| Report status | Yes | Yes | Dropdown (Open / Resolved / All) |
| Rider account status | No | No | — |

---

## [Admin] #1811 — Super admin actions a gender-mismatch report 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 2

**Description:** As a super admin, I want to resolve a gender-mismatch report by either suspending the reported rider or dismissing the report so that flagged accounts do not stay in limbo.

### Background

Opened from a report in the queue (#1810), the super admin resolves it one of two ways: **Suspend** the reported rider (applies the same suspension as #1740 via API #1739) or **Dismiss** the report (the rider returns from pending_review to active). Because the gender-mismatch report is itself the recorded reason and the rider is already under review on this screen, an additional suspension note is **optional** free text. The decision is written to the admin activity audit log (#1816) and the report leaves the open queue.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspension reason | No (optional) | Free text (textarea) | Any character; an optional note — the gender-mismatch report is the recorded reason | — | 500 chars | empty | — | — | Too long — must be ≤ 500 characters / يجب ألا يتجاوز السبب 500 حرف |

### Acceptance Criteria

**Scenario 1 — Suspend the reported rider**
- Given the super admin is reviewing an open report
- When she chooses Suspend (optionally adding a free-text note)
- Then the rider's status changes to suspended, her sessions are invalidated, and the report is marked resolved-suspended

**Scenario 2 — Dismiss the report**
- Given the super admin determines the report is unfounded
- When she chooses Dismiss
- Then the rider returns from pending_review to active and the report is marked resolved-dismissed

**Scenario 3 — Suspension note is optional**
- Given the super admin chooses Suspend without entering any note
- Then the suspension proceeds with no required-reason error



**Scenario 4 — A resolved report cannot be actioned again**
- Given a report already resolved
- Then no further action controls are available

### Out of Scope
- Contacting the rider
- Driver-side penalties for false reports (later phase)
- Automated resolution

### Dependencies
- #1810 — Super admin reviews the gender-mismatch report queue
- #1687 — Rider account is suspended after gender mismatch report
- #1740 / #1739 — Account suspension
- #1816 — Admin activity audit log

---

### Feature 18 — Admin Financial Reporting & Reconciliation (ADO Feature #1803)

---

## [Admin] #1832 — Super admin views revenue & commission summary report 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As a super admin, I want a platform revenue & commission summary over a selected period and optional zone, so that I can monitor the platform's financial performance.

### Background

The revenue & commission summary gives the super admin a platform-level financial overview for a selected date range and optional zone. It shows total completed trips, gross fares (EGP), total platform commission (#1759), total cancellation fees collected, and net driver earnings. All figures derive from completed-trip records carrying the commission rate and fare breakdown (#1637). The report is exportable to CSV/Excel.

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
- Tax reporting
- Cross-driver leaderboards and performance analytics
- Payout execution
- Per-driver earnings & settlement (covered by #1833)

### Dependencies
- #1759 — Super admin configures platform commission
- #1637 — Completed trip served with fare breakdown
- #1757 — Zone rate card

---

## [Admin] #1833 — Super admin views per-driver earnings & settlement report 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As a super admin, I want a per-driver earnings & settlement report over a selected period, so that I can answer driver payment queries and track each driver's settlement.

### Background

The per-driver earnings & settlement report lets the super admin review a single driver's financials for a chosen date range. It shows the completed-trips count, gross fares, commission deducted, net earnings, the cash-vs-digital split, the current outstanding cash balance (#1813), and per-trip rows (fare, commission, net). All figures derive from completed-trip records carrying the commission rate and fare breakdown (#1637). The report is exportable to CSV/Excel.

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

**Scenario 2 — Driver is required**
- Given no driver is selected
- Then the report cannot be generated and a “Select a driver” validation message is shown

**Scenario 3 — Cash vs digital breakdown and outstanding balance**
- Given a per-driver report is displayed
- Then earnings are split into cash and digital portions and the current outstanding cash balance (#1813) is shown

**Scenario 4 — Driver with no trips**
- Given the driver completed no trips in the period
- Then an empty-state message is shown



**Scenario 5 — Export**
- Given a per-driver report is displayed
- Then the super admin can export it to CSV/Excel

### Out of Scope
- Charts and trend lines (Phase 2)
- Tax reporting
- Cross-driver leaderboards and performance analytics
- Payout execution
- Platform revenue & commission summary (covered by #1832)

### Dependencies
- #1637 — Completed trip served with fare breakdown
- #1813 — Cash reconciliation
- #1759 — Super admin configures platform commission

### List / Grid Specification (per-trip rows)

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Trip date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Trip date | Yes | No | — |
| Fare (EGP) | Yes | No | — |
| Commission (EGP) | Yes | No | — |
| Net earnings (EGP) | Yes | No | — |

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

### List / Grid Specification

**Page size:** 50 rows/page (server-side pagination) · **Default sort:** Timestamp — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Timestamp (UTC+2) | Yes | Yes | Date range (from / to) |
| Actor | Yes | Yes | Dropdown (All actors / specific admin) |
| Action type | Yes | Yes | Dropdown (All / approve / reject / suspend / reinstate / cancel / reassign / refund / settlement / gender-mismatch resolution / admin-account change) |
| Target entity & id | No | Yes | Free-text search (partial match) |
| Before / after values | No | No | — |

---

