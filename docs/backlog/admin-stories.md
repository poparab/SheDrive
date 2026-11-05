# SheDrive — Admin Portal Stories
> Canonical backlog for all [Admin] stories. Organized by sprint and feature.
> Last updated: 2026-11-04 (approval request page, one payout method per batch — #6570)
> Stories with changes from original are marked ✏️ | New stories marked 🆕

> **Role model (2026-10-27):** Five admin roles — **Admin (users & IT)**, **Operations officer**,
> **Operations lead**, **Financial officer**, **Financial lead** — replace Super admin / Admin.
> One story per role, each with its own column of the access matrix: #6480 Admin (users & IT, also the rules every role shares), #6481 Operations officer, #6482 Operations lead, #6483 Financial officer, #6484 Financial lead. Setting a role when adding an account: #6485. Financial-lead-only approvals: #6212. (#6210 and #6211 Removed 2026-10-29.)
> Built stories that still say "Super admin" or "any other admin" are left as they are; these stories carry the change.
> **Portal UI:** English only. **Safety/SOS:** the SOS queue + escalation workflow
> is deferred to a later phase; the women-only gender-mismatch report triage is in scope.

---

## Sprint 1

### Feature 1 — Platform & Integration Foundation (ADO Feature #1611)

---

## [Admin] #1656 — Admin portal shell and login screen are in place ✏️
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As an admin, I want a working admin web portal with a login screen and shell layout so that I can securely access SheDrive operations dashboards.

### Background

The admin portal is a web application accessible to SheDrive operations staff. It presents a login screen (email + password) as its unauthenticated entry point. Successful authentication lands the admin on the main dashboard, which sits within a persistent shell consisting of a navigation sidebar or top bar and a content area. The portal is distinct from the rider/driver mobile app and serves as the operations team's command centre for approving drivers, monitoring trips, and managing the platform. The portal UI is English only. Every admin account can use every portal screen; the two admin roles differ only in suspending, unsuspending and deleting other admin accounts (#1821), and finer-grained roles are a planned future addition. Two-factor authentication (#1806) is required at login, password reset (#1822) is self-service, and admin accounts are managed via #1807.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email | Yes | Email | local@domain.tld; letters, digits, . _ % + - @ | — | 254 chars | — | Enter your email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |
| Password | Yes | Password (masked) | Any printable character | 8 chars | 128 chars | — | Enter your password / أدخل كلمة المرور | — | Password must be at least 8 characters / يجب ألا تقل كلمة المرور عن 8 أحرف |

### Acceptance Criteria

**Scenario 1 — Admin logs in with valid credentials**
- Given an admin navigates to the admin portal login screen
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

**Description:** As an admin, I want my login to require a second authentication factor so that the portal — which controls pricing, payouts, and account suspension — is protected against credential theft.

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

## [Admin] #1807 — Admin adds an admin user account 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As an admin, I want to invite/create a new admin user account by email so that I can grant a colleague access to the operations portal.

### Background

Any admin can add an admin account; the two admin roles differ only in suspending, unsuspending and deleting other admin accounts (#1821), and finer-grained roles are a planned future addition. This story covers creating a new admin by email: on creation the system **generates a temporary password and emails it to the new admin's address**, and the account appears with status Active. The temporary password is single-use and the new admin must change it on her first login (#1822). Viewing the accounts list is #1820; enabling/disabling accounts is #1821.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Email | Yes | Email | local@domain.tld; letters, digits, . _ % + - @; must be unique among admin accounts | — | 254 chars | — | Enter an email address / أدخل البريد الإلكتروني | Invalid email address / بريد إلكتروني غير صحيح · An admin with this email already exists / يوجد مشرف بهذا البريد الإلكتروني بالفعل | Email must be ≤ 254 characters / يجب ألا يتجاوز البريد الإلكتروني 254 حرفًا |

### Acceptance Criteria

**Scenario 1 — Admin creates an admin account**
- Given the admin is on the add-admin form
- When she enters a valid, unique email and confirms
- Then a temporary password is auto-generated and emailed to the new admin's address, and the account appears with status Active

**Scenario 2 — Temporary password is sent only to the new admin**
- Given the account has just been created
- Then the temporary password is delivered only to the new admin's email and is never displayed to the creating admin
- And first login with it forces a password change (#1822)

**Scenario 3 — Duplicate email is rejected**
- Given an account already exists with a given email
- When the admin tries to create another with the same email
- Then a validation error is shown and no account is created

**Scenario 4 — Invalid email format is rejected**
- Given the admin enters a malformed email
- Then a validation error is shown and no account is created

**Scenario 5 — Email over the length limit is rejected**
- Given the admin enters an email longer than 254 characters
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

## [Admin] #1820 — Admin views the admin user accounts list 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As an admin, I want to view a searchable, filterable list of all admin user accounts so that I can see who has portal access and each account's status.

### Background

This screen lists all admin user accounts so admins can see who has portal access. Each row shows email, status, created date, and last login. The list is searchable by email, filterable by status, and paginated. Creating accounts is #1807; enabling/disabling is #1821.

### Acceptance Criteria

**Scenario 1 — Account list shows status and last login**
- Given the admin-users screen is open
- Then each row shows email, status, created date, and last login
- And results are ordered by created date descending

**Scenario 2 — Search by email**
- Given the list is loaded
- When the admin types part of an email
- Then the list filters to accounts whose email contains that text

**Scenario 3 — Filter by status**
- Given the list is loaded
- When the admin selects All, Active, or Disabled
- Then only accounts in that status group are shown

**Scenario 4 — Pagination**
- Given there are more accounts than fit on one page
- When the admin navigates to the next page
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

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Created date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Email | Yes | Yes | Free-text search (partial match) |
| Status | Yes | Yes | Dropdown (All / Active / Disabled) |
| Created date | Yes | No | — |
| Last login | Yes | No | — |

---

## [Admin] #1821 — Super admin suspends and unsuspends admin user accounts ✏️
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 4

**Description:** As a super admin, I want to suspend and unsuspend other admin user accounts so that I can revoke or restore portal access without ever locking the portal out.

### Background

Admin accounts have one of two roles: **Super admin** or **Admin**. Both roles see and use every portal screen in the same way. The only thing a Super admin can do that an Admin cannot is **suspend, unsuspend and delete other admin accounts** — suspend and unsuspend are this story, delete is #4122.

From the admin accounts list (#1820), a Super admin can suspend an Active account — which immediately ends its sessions and blocks its login — or unsuspend a Suspended one. Suspension is reversible; deletion (#4122) is not. The status label is **Suspended** (it replaces the earlier "Disabled" wording). A Super admin cannot suspend her own account.

### Role Permissions

| Action | Super admin | Admin |
|---|---|---|
| Use every other portal screen and action | Yes | Yes |
| View the admin accounts list (#1820) and its summary cards (#4121) | Yes | Yes |
| Add an admin account (#1807) | Yes | Yes |
| Suspend or unsuspend another admin account (this story) | Yes | No |
| Delete another admin account (#4122) | Yes | No |

### Acceptance Criteria

**Scenario 1 — Super admin suspends an admin**
- Given a Super admin is on the admin accounts list and another admin's account is Active
- When she chooses Suspend and confirms
- Then the account's status changes to Suspended
- And its active sessions are ended and that admin can no longer log in

**Scenario 2 — Super admin unsuspends an admin**
- Given another admin's account is Suspended
- When the Super admin chooses Unsuspend and confirms
- Then the account's status changes to Active and that admin can log in again with her existing password

**Scenario 3 — Admin role cannot suspend or unsuspend**
- Given the logged-in account has the Admin role
- When she opens the admin accounts list
- Then no Suspend or Unsuspend action is shown on any row
- And if a suspend or unsuspend request is sent anyway, it is refused and nothing changes

**Scenario 4 — Super admin cannot suspend her own account**
- Given a Super admin is viewing her own row in the list
- Then the Suspend action is not available for that row

**Scenario 5 — A suspended admin tries to log in**
- Given an admin's account is Suspended
- When she enters her correct email and password
- Then login is refused with the message "This account is suspended / هذا الحساب موقوف"

**Scenario 6 — Super admin cancels the confirmation**
- Given the suspend or unsuspend confirmation dialog is open
- When the Super admin cancels
- Then the dialog closes and the account's status is unchanged

**Scenario 7 — The action is recorded**
- Given a Super admin suspends or unsuspends an account
- Then an entry is written to the admin activity audit log (#1816) with the actor, the action, the affected account and the before/after status

### Out of Scope
- Creating accounts (see #1807)
- Viewing the accounts list (see #1820)
- Deleting accounts (see #4122)
- Changing an existing account's role
- Resetting an admin's password (see #1822)
- Granular per-feature permissions beyond the two roles

### Dependencies
- #1656 — Admin portal shell and login
- #1820 — Admin views the admin user accounts list (where the actions live)
- #1816 — Admin activity audit log

---

## [Admin] #4121 — Admin sees summary cards above the admin user accounts list 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 4

**Description:** As an admin, I want a row of summary cards above the admin user accounts list showing total, active and suspended account counts so that I can see who holds portal access at a glance without filtering the grid.

### Background

The admin accounts list (#1820) carries a row of three summary cards above the filter bar and the grid. Each card shows a caption, a whole-number count and an icon. The cards are visible to both roles, Super admin and Admin.

The cards are totals for all admin accounts: they do not react to the search box or the status filter below. Each count agrees with the grid — the number on a card is exactly the number of rows the grid shows when that card's status is selected in the filter. Deleted accounts (#4122) are never counted. The cards are read-only and the counts are read when the screen loads.

### Card Specification

| Card | What it counts | Agrees with |
|---|---|---|
| Total admins | Every admin account that is not deleted, both statuses and both roles | Grid with status filter = All |
| Active | Accounts that can log in | Grid with status filter = Active |
| Suspended | Accounts currently suspended (#1821) | Grid with status filter = Suspended |

### Acceptance Criteria

**Scenario 1 — Admin opens the admin accounts list**
- Given an admin navigates to the Admin users screen
- When the page loads
- Then three summary cards are shown above the filter bar: Total admins, Active, Suspended
- And each card shows its caption and a whole-number count

**Scenario 2 — A card count agrees with the grid**
- Given the summary cards are displayed
- When the admin selects the status filter matching a card
- Then the grid's total number of results equals the number on that card

**Scenario 3 — Cards do not react to the grid's filters**
- Given the summary cards are displayed
- When the admin types a search term or changes the status filter
- Then only the grid narrows and the card counts stay unchanged

**Scenario 4 — Deleted accounts are not counted**
- Given a Super admin has deleted an admin account (#4122)
- When the list next loads
- Then that account is not included in any card

**Scenario 5 — A count is zero or cannot be retrieved**
- Given no account is Suspended, the Suspended card shows 0 and is not hidden
- And if one count cannot be retrieved, that card shows a placeholder instead of a number while the other cards and the grid still load

**Scenario 6 — Cards are read-only**
- Given the summary cards are displayed
- When the admin clicks a card
- Then nothing happens — no navigation and no change to the grid's filters

### Out of Scope
- Clicking a card to filter the grid
- A count by role (Super admin / Admin)
- Trends, percentages or period comparison
- Refreshing the counts on a timer

### Dependencies
- #1820 — Admin views the admin user accounts list (the grid these cards sit above)
- #1821 — Super admin suspends and unsuspends admin user accounts (moves accounts between Active and Suspended)
- #4122 — Super admin deletes an admin user account (removes accounts from every count)

---

## [Admin] #4122 — Super admin deletes an admin user account 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 4

**Description:** As a super admin, I want to delete another admin user account so that a person who should no longer have portal access is removed from the admin list, while the record and its history are kept.

### Background

Admin accounts have one of two roles: **Super admin** or **Admin**. The only thing a Super admin can do that an Admin cannot is suspend, unsuspend (#1821) and **delete** other admin accounts. The role table is in #1821.

A Super admin can delete an Active or Suspended admin account from the admin accounts list (#1820), after confirming. **Deletion is always a soft delete.** The account record is never removed from the database: it is marked Deleted, with the date and the Super admin who deleted it. A deleted account disappears from the list and the summary cards (#4121), its sessions end, and it can no longer log in or reset its password. Everything that admin did before stays in the audit log (#1816) under her email. There is no hard delete in the portal or the backend.

A Super admin cannot delete her own account.

### Acceptance Criteria

**Scenario 1 — Super admin deletes an admin account**
- Given a Super admin is on the admin accounts list and another admin's account is Active or Suspended
- When she chooses Delete and confirms in the dialog
- Then the account is removed from the list and from the summary card counts
- And its active sessions are ended and that admin can no longer log in

**Scenario 2 — Deletion is a soft delete only**
- Given an admin account has been deleted
- Then its record still exists in the database, marked Deleted, with the deletion date and the Super admin who deleted it
- And no account data is erased
- And audit log entries (#1816) made by that admin still show her email

**Scenario 3 — Super admin cancels the confirmation**
- Given the delete confirmation dialog is open
- When the Super admin cancels
- Then the dialog closes and the account is unchanged

**Scenario 4 — Admin role cannot delete**
- Given the logged-in account has the Admin role
- When she opens the admin accounts list
- Then no Delete action is shown on any row
- And if a delete request is sent anyway, it is refused and nothing changes

**Scenario 5 — Super admin cannot delete her own account**
- Given a Super admin is viewing her own row in the list
- Then the Delete action is not available for that row

**Scenario 6 — A deleted admin cannot get back in**
- Given an admin account has been deleted
- When that person tries to log in with the old email and password
- Then login is refused with the standard invalid-credentials message
- And a forgot-password request (#1822) for that email sends nothing, with the same response as for an unknown email

**Scenario 7 — The action is recorded**
- Given a Super admin deletes an account
- Then an entry is written to the admin activity audit log (#1816) with the actor, the action and the affected account

### Out of Scope
- Hard delete or permanent erasure of an admin record (never done)
- Restoring a deleted account from the portal
- Re-using a deleted account's email for a new account
- Suspending or unsuspending accounts (see #1821)

### Dependencies
- #1820 — Admin views the admin user accounts list (where the Delete action lives)
- #1821 — Super admin suspends and unsuspends admin user accounts (defines the two roles)
- #1816 — Admin activity audit log
- #1822 — Admin password reset (must not work for a deleted account)

---

## [Admin] #1822 — Admin password reset and first-login mandatory change 🆕
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As an admin, I want to reset my password via an emailed single-use temporary password and be required to set a new one — the same flow that applies on my first login — so that I can always regain secure access with a credential only I know.

### Background

One secure cycle covers two triggers: (1) a newly created admin's **first login** using the temporary password emailed by #1807, and (2) a **password reset** — either self-service “forgot password” or an admin-initiated reset for another admin. In every case the system emails a single-use temporary password; on the next login the admin is forced to set a new password before she can reach any portal screen, and the temporary password is invalidated once the new one is set. To avoid account enumeration, the forgot-password response does not reveal whether an email is registered.

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

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Submission date — oldest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Driver name | Yes | Yes | Free-text search (partial match) |
| Phone number | Yes | Yes | Free-text search (partial match) |
| Submission date | Yes | Yes | Date range (from / to) |
| View application | No | No | — (row action → #1658) |

---

## [Admin] #4008 — Admin sees outcome summary cards above the driver applications queue 🆕
**Feature:** Feature 5 — Driver Onboarding & Admin Approval | **Sprint:** Phase 1

**Description:** As an operations admin, I want a row of summary cards above the driver applications queue showing total, approved, pending and rejected application counts so that I can size the review workload and the decisions already made at a glance.

### Background

The driver applications queue (#1657) carries a row of four summary cards above the filter bar and the grid. Each card shows a caption, a whole-number count and an icon. The cards answer "how much of each kind is there" before the admin narrows anything down, so they are platform-wide totals: they do not react to the search box, the outcome dropdown or the submission-date range applied to the grid below.

Every outcome count must agree with the grid — the number on a card is exactly the number of rows the grid would show if that card's outcome were selected in the outcome filter. The pending-count badge already shown on the section header (#1657) is unchanged and stays where it is; the card row sits above it. The cards are read-only: a card is not a filter shortcut and clicking one does nothing. Counts are read when the screen loads.

### Card Specification

| Card | What it counts | Agrees with |
|---|---|---|
| Total applications | Every driver application ever submitted, all outcomes | Grid with outcome filter = All |
| Approved | Applications an admin has approved | Grid with outcome filter = Approved |
| Pending | Applications still awaiting review — the live review workload | Grid with outcome filter = Pending, and the header's pending badge |
| Rejected | Applications an admin has rejected, with a reason recorded | Grid with outcome filter = Rejected |

### Acceptance Criteria

**Scenario 1 — Admin opens the driver applications queue**
- Given the admin navigates to the Driver applications screen
- When the page loads
- Then a row of four summary cards is displayed above the filter bar: Total applications, Approved, Pending, Rejected
- And each card shows its caption and a whole-number count

**Scenario 2 — A card count agrees with the grid**
- Given the summary cards are displayed
- When the admin selects the outcome filter matching a card (for example Rejected)
- Then the grid's total number of results equals the number shown on that card

**Scenario 3 — The Pending card and the header badge agree**
- Given applications are awaiting review
- Then the Pending card and the queue's pending badge show the same number
- And both keep showing the pending workload whatever filter is applied to the grid

**Scenario 4 — Cards do not react to the grid's filters**
- Given the summary cards are displayed with their counts
- When the admin types a search term, changes the outcome filter or applies a submission-date range
- Then only the grid below narrows
- And the card counts continue to show the platform-wide totals, unchanged

**Scenario 5 — A count is zero**
- Given no application currently matches one of the cards — for example the queue has been fully cleared
- Then that card shows 0
- And it is not left blank or hidden

**Scenario 6 — One count cannot be retrieved**
- Given the platform cannot return the count for one card
- Then that card shows a placeholder instead of a number, never a stale or guessed value
- And the other three cards still show their counts
- And the grid below still loads normally

**Scenario 7 — Cards are read-only**
- Given the summary cards are displayed
- When the admin clicks a card
- Then nothing happens — no navigation, and no change to the grid's filters

**Scenario 8 — Cards are independent of the grid's state**
- Given the grid is still loading, is empty, or has failed to load
- Then the card row still occupies its place above the filter bar and shows whatever counts it was able to retrieve

### Out of Scope
- Clicking a card to apply the matching filter to the grid
- Trend indicators, percentage change, sparklines or period comparison on a card
- An ageing or SLA figure on a card (for example oldest pending application) — waiting time stays on the row
- Refreshing the counts on a timer — they are read when the screen loads
- Exporting the card values (the grid's CSV export from #1657 is unchanged)

### Dependencies
- #1657 — Admin views pending applications queue (the grid these cards sit above, and the pending badge the Pending card must agree with)
- #1659 / #1660 — Approve and reject a driver application (the decisions that move a count from Pending to Approved or Rejected)

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

**Description:** As an admin, I want to view a searchable, filterable, paginated list of all registered riders so that I can find and review any rider account quickly.

### Background

The rider list is the primary entry point for rider management in the admin portal. It loads automatically when the admin navigates to the Riders section. The table shows all registered riders with key identifiers, including each rider's account status (Active or Suspended). The admin can type a name or phone number into the search box to narrow results in real time, and can filter by account status. Clicking any row opens the rider profile screen (#1662). The default page size is 10 rows.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | Any character (name or phone digits) | — | 100 chars | empty | — | — | Search must be ≤ 100 characters / يجب ألا يتجاوز البحث 100 حرف |
| Status filter | No | Dropdown (single-select) | Enum: All / Active / Suspended | — | — | All | — | — | — |

### Acceptance Criteria

**Scenario 1 — Admin opens the rider list**
- Given the admin is authenticated and navigates to the Riders section
- When the page loads
- Then a table of all registered riders is displayed, 10 per page by default
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

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Registration date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Name | Yes | Yes | Free-text search (partial match) |
| Phone number | Yes | Yes | Free-text search (partial match) |
| Account status | Yes | Yes | Dropdown (All / Active / Suspended) |
| Registration date | Yes | No | — |
| Total trips completed | Yes | No | — |

---

## [Admin] #4010 — Admin sees status summary cards above the rider list 🆕
**Feature:** Feature 13 — Admin — Rider Management | **Sprint:** Phase 1

**Description:** As an operations admin, I want a row of summary cards above the rider list showing total, active, pending-review and suspended rider counts so that I can read the rider base and the review workload at a glance without filtering the grid.

### Background

The rider list (#1661) carries a row of four summary cards above the filter bar and the grid. Each card shows a caption, a whole-number count and an icon. The cards answer "how much of each kind is there" before the admin narrows anything down, so they are platform-wide totals: they do not react to the search box or the account-status dropdown applied to the grid below.

Every status count must agree with the grid — the number on a card is exactly the number of rows the grid would show if that card's account status were selected in the status filter. Pending review matters most operationally: a rider lands there automatically when a driver raises a gender-mismatch report, so the card is the standing signal that triage work is waiting. The cards are read-only: a card is not a filter shortcut and clicking one does nothing. Counts are read when the screen loads.

### Card Specification

| Card | What it counts | Agrees with |
|---|---|---|
| Total riders | Every rider account on the platform, all statuses | Grid with status filter = All |
| Active | Riders whose account is in good standing and able to book | Grid with status filter = Active |
| Pending review | Riders held for review after a gender-mismatch report — the triage workload | Grid with status filter = Pending review |
| Suspended | Riders whose account is currently suspended | Grid with status filter = Suspended |

### Acceptance Criteria

**Scenario 1 — Admin opens the rider list**
- Given the admin navigates to the Riders screen
- When the page loads
- Then a row of four summary cards is displayed above the filter bar: Total riders, Active, Pending review, Suspended
- And each card shows its caption and a whole-number count

**Scenario 2 — A card count agrees with the grid**
- Given the summary cards are displayed
- When the admin selects the account-status filter matching a card (for example Pending review)
- Then the grid's total number of results equals the number shown on that card

**Scenario 3 — Pending review reflects the triage workload**
- Given a driver has raised a gender-mismatch report that put a rider into Pending review
- When the admin next loads the rider list
- Then the Pending review card includes that rider
- And once the case is actioned the rider leaves that count on the next load

**Scenario 4 — Cards do not react to the grid's filters**
- Given the summary cards are displayed with their counts
- When the admin types a search term or changes the account-status filter
- Then only the grid below narrows
- And the card counts continue to show the platform-wide totals, unchanged

**Scenario 5 — A count is zero**
- Given no rider currently matches one of the cards — for example nothing is awaiting review
- Then that card shows 0
- And it is not left blank or hidden

**Scenario 6 — One count cannot be retrieved**
- Given the platform cannot return the count for one card
- Then that card shows a placeholder instead of a number, never a stale or guessed value
- And the other three cards still show their counts
- And the grid below still loads normally

**Scenario 7 — Cards are read-only**
- Given the summary cards are displayed
- When the admin clicks a card
- Then nothing happens — no navigation, and no change to the grid's filters

**Scenario 8 — Cards are independent of the grid's state**
- Given the grid is still loading, is empty, or has failed to load
- Then the card row still occupies its place above the filter bar and shows whatever counts it was able to retrieve

### Out of Scope
- Clicking a card to apply the matching filter to the grid
- Trend indicators, percentage change, sparklines or period comparison on a card
- New-rider or growth figures (for example riders registered this week)
- Refreshing the counts on a timer — they are read when the screen loads
- Exporting the card values

### Dependencies
- #1661 — Admin views rider list (the grid these cards sit above)
- #1662 — Admin views rider profile (defines the Pending review account state)
- #1810 / #1811 — Gender-mismatch report queue and actioning (what puts a rider into, and takes her out of, Pending review)
- #1740 / #1741 — Suspend and reinstate a rider account (the actions that move a rider in and out of the Suspended count)

---

## [Admin] #1662 — Admin views rider profile ✏️
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an admin, I want to view a rider's full profile and their trip history so that I can understand their account activity and take account actions when needed.

### Background

The rider profile screen is opened by clicking any row in the rider list (#1661). It presents the rider's personal information at the top — including an account status badge (Active, Pending Review, or Suspended) — followed by a paginated list of the rider's past trips. A rider enters **Pending Review** automatically when a driver raises a gender-mismatch report (API #1687); such cases are triaged from the gender-mismatch queue (#1810/#1811). From this screen the admin can also **suspend** an active rider or **reinstate** a suspended one (#1740/#1741). Trip history is read-only.

### Acceptance Criteria

**Scenario 1 — Admin opens a rider profile**
- Given the admin has clicked a rider row in the rider list
- When the profile screen loads
- Then the following is shown: full name, phone number, account status badge (Active, Pending Review, or Suspended), registration date, total trips completed, and date of last trip
- And below the profile, a paginated list of the rider's past trips is displayed

**Scenario 2 — Trip history section displays correct columns**
- Given the rider profile is loaded
- Then each trip row shows: trip ID, trip date, pickup area, destination area, start time, end time, fare (EGP), trip status, and the rating the rider gave for that trip
- And the trip status is shown as a coloured status indicator together with its label
- And trips are ordered by trip date, newest first

**Scenario 3 — Trip has not finished, so some values do not exist yet**
- Given a listed trip has not reached a final state (for example it is still Searching)
- When the trip history is displayed
- Then start time, end time, fare and rating are each shown as a dash placeholder rather than an empty cell

**Scenario 4 — Trip was not rated**
- Given a completed trip that the rider did not rate
- Then the rating cell shows a dash placeholder

**Scenario 5 — Rider is suspended or pending review**
- Given the rider's account is Suspended or Pending Review
- When the profile loads
- Then the status badge and the recorded reason are shown
- And for a Pending Review rider a link to the related gender-mismatch report (#1810) is shown

**Scenario 6 — Admin takes an account action**
- Given the admin is viewing a rider profile
- Then a Suspend action (#1740) is available for an active rider, and a Reinstate action (#1741) is available for a suspended rider

**Scenario 7 — Rider has no past trips**
- Given the admin opens the profile of a rider who has never completed a trip
- Then an empty state message is shown in place of the trip table

**Scenario 8 — Admin paginates the trip history**
- Given the rider has more than one page of past trips
- When the admin navigates to the next page
- Then the next page of trips loads within the profile screen

**Scenario 9 — Admin changes how many trips are shown per page**
- Given the trip history is displayed
- When the admin selects a different rows-per-page value (10, 25 or 50)
- Then the trip history reloads at the selected page size and returns to the first page

**Scenario 10 — Admin navigates back to the rider list**
- Given the admin is on the rider profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the rider list

### Out of Scope
- Editing rider details
- Viewing trip details from within the profile (trip row is not clickable in this phase)
- Filtering or searching within the trip history
- Exporting rider data

### Dependencies
- #1740 / #1741 — Rider suspend / reinstate
- #1810 — Gender-mismatch report queue (Pending Review source)

### List / Grid Specification

**Page size:** selectable — 10 (default), 25 or 50 rows/page (trip-history grid within the profile) · **Default sort:** Trip date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Trip ID | Yes | No | — |
| Trip date | Yes | No | — |
| Pickup area | No | No | — |
| Destination area | No | No | — |
| Start time | No | No | — |
| End time | No | No | — |
| Fare (EGP) | Yes | No | — |
| Trip status | No | No | — |
| Rating | Yes | No | — |

---

## [Admin] #1740 — Operations admin suspends a rider account 🆕
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to suspend a rider's account so that a rider who has violated platform policies or is under review is immediately prevented from booking trips.

### Background

Accessible from the rider profile screen (#1662), this action allows the admin to suspend a rider's account. The admin selects a suspension reason from a predefined list; when "Other" is chosen an explanatory note is required. The selected reason (and any note) is recorded. The rider's existing sessions are invalidated and she cannot log in again until reinstated. If the rider has an active trip when the suspension is confirmed, the account is marked **Pending Suspension** and the suspension is applied automatically as soon as that trip ends; otherwise it takes effect immediately.

**Riders under review are excluded.** A rider whose account is **Pending Review** (placed there by a gender-mismatch report, #1687) cannot be suspended from this screen. Her profile offers no Suspend action and links to the open gender-mismatch report instead; the decision to suspend or clear her is taken only against that report (#1811).

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

**Scenario 7 — A rider under review cannot be suspended manually**
- Given the rider's account is in Pending Review after a gender-mismatch report (#1687)
- When the admin views her in the rider list (#1661) or opens her profile (#1662)
- Then no "Suspend Account" action is offered
- And her profile links to the open gender-mismatch report, where she can be suspended or cleared (#1811)

### Out of Scope
- Automatic (rule-based) suspension without an admin decision
- Suspension appeal workflow

### Dependencies
- #1739 — Account suspension status is updated by admin (API — must be live)
- #1811 — Admin actions a gender-mismatch report (the only way to suspend a rider who is under review)

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

**Description:** As an admin, I want to view a searchable, filterable list of all driver accounts grouped by status so that I can monitor the driver pipeline and locate any driver quickly.

### Background

The driver list is the primary entry point for driver management in the admin portal. It shows all driver accounts regardless of onboarding status. A status filter lets the admin narrow results to a single group: Pending, Approved, Rejected, or Suspended. A search box allows free-text lookup by name or phone. The default page size is 10 rows. Clicking any row opens the driver profile (#1666).

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

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Onboarding submission date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Name | Yes | Yes | Free-text search (partial match) |
| Phone number | Yes | Yes | Free-text search (partial match) |
| Status | Yes | Yes | Dropdown (All / Pending / Approved / Rejected / Suspended) |
| Onboarding submission date | Yes | No | — |
| Total trips completed | Yes | No | — |

---

## [Admin] #4009 — Admin sees status summary cards above the driver list 🆕
**Feature:** Feature 14 — Admin — Driver Management | **Sprint:** Phase 1

**Description:** As an operations admin, I want a row of summary cards above the driver list showing total, online, approved and suspended driver counts so that I can read driver supply and account health at a glance without filtering the grid.

### Background

The driver list (#1665) carries a row of four summary cards above the filter bar and the grid. Each card shows a caption, a whole-number count and an icon. The cards answer "how much of each kind is there" before the admin narrows anything down, so they are platform-wide totals: they do not react to the search box or the status dropdown applied to the grid below.

Three of the cards are status counts and must agree with the grid — the number on such a card is exactly the number of rows the grid would show if that card's status were selected in the status filter. The fourth, Online now, is a live presence figure with no matching status filter; it uses the same definition as the dashboard's Online Drivers (#1669). The cards are read-only: a card is not a filter shortcut and clicking one does nothing. Counts are read when the screen loads; the dashboard's 30-second auto-refresh (#1669) does not apply here.

### Card Specification

| Card | What it counts | Agrees with |
|---|---|---|
| Total drivers | Every driver account on the platform, all statuses | Grid with status filter = All |
| Online now | Drivers currently online and available to receive ride requests | No grid filter; same definition as the dashboard's Online Drivers (#1669) |
| Approved | Drivers approved and allowed to drive | Grid with status filter = Approved |
| Suspended | Drivers whose account is currently suspended | Grid with status filter = Suspended |

### Acceptance Criteria

**Scenario 1 — Admin opens the driver list**
- Given the admin navigates to the Drivers screen
- When the page loads
- Then a row of four summary cards is displayed above the filter bar: Total drivers, Online now, Approved, Suspended
- And each card shows its caption and a whole-number count

**Scenario 2 — A status card count agrees with the grid**
- Given the summary cards are displayed
- When the admin selects the status filter matching a card (for example Suspended)
- Then the grid's total number of results equals the number shown on that card

**Scenario 3 — Online now is a presence figure, not a status**
- Given the summary cards are displayed
- Then Online now shows how many drivers are online at that moment, not a count of any account status
- And it uses the same definition as the Online Drivers metric on the dashboard (#1669)

**Scenario 4 — Cards do not react to the grid's filters**
- Given the summary cards are displayed with their counts
- When the admin types a search term or changes the status filter
- Then only the grid below narrows
- And the card counts continue to show the platform-wide totals, unchanged

**Scenario 5 — A count is zero**
- Given no driver currently matches one of the cards — for example no driver is online at that moment
- Then that card shows 0
- And it is not left blank or hidden

**Scenario 6 — One count cannot be retrieved**
- Given the platform cannot return the count for one card
- Then that card shows a placeholder instead of a number, never a stale or guessed value
- And the other three cards still show their counts
- And the grid below still loads normally

**Scenario 7 — Cards are read-only**
- Given the summary cards are displayed
- When the admin clicks a card
- Then nothing happens — no navigation, and no change to the grid's filters

**Scenario 8 — Cards are independent of the grid's state**
- Given the grid is still loading, is empty, or has failed to load
- Then the card row still occupies its place above the filter bar and shows whatever counts it was able to retrieve

### Out of Scope
- Clicking a card to apply the matching filter to the grid
- Trend indicators, percentage change, sparklines or period comparison on a card
- Refreshing the counts on a timer — they are read when the screen loads (the dashboard's 30-second refresh, #1669, is not applied here)
- Exporting the card values (the grid's CSV export from #1665 is unchanged)
- Per-zone or per-city breakdowns of driver supply

### Dependencies
- #1665 — Admin views driver list across all statuses (the grid these cards sit above)
- #1669 — Admin sees live summary dashboard (defines Online Drivers, reused by the Online now card)
- #1742 / #1743 — Suspend and reinstate a driver account (the actions that move a driver in and out of the Suspended count)

---

## [Admin] #1666 — Admin views driver profile ✏️
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an admin, I want to view a driver's full profile including their documents, vehicle details, and trip history so that I can assess their account comprehensively and take account actions when needed.

### Background

The driver profile screen is opened by clicking any row in the driver list (#1665). It presents personal details, vehicle information, uploaded document images (viewable inline), the profile photo, current status badge, aggregate statistics, and — for pending, rejected, or suspended drivers — the decision history. Below the profile, a paginated list of the driver's completed trips is shown. Approve/reject actions remain on the pending queue screens (#1657–#1660); from this screen the admin can **suspend** an approved driver or **reinstate** a suspended one (#1742/#1743).

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

**Description:** As an admin, I want to view a searchable, filterable list of all trips on the platform so that I can monitor trip activity and investigate specific trips.

### Background

The trip list screen shows all trips across all statuses. The admin can filter by trip status, apply a date range, and search by rider or driver name or phone. Columns provide enough information to identify a trip at a glance. Clicking any row opens the trip detail screen (#1671). The default page size is 10 rows ordered by creation date descending.

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

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Creation date — newest first

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

## [Admin] #4007 — Admin sees status summary cards above the trip list 🆕
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** Phase 1

**Description:** As an operations admin, I want a row of summary cards above the trip list showing total, active, completed and expired trip counts so that I can read trip activity at a glance without filtering the grid.

### Background

The trip list (#1670) carries a row of four summary cards above the filter bar and the grid. Each card shows a caption, a whole-number count and an icon. The cards answer "how much of each kind is there" before the admin narrows anything down, so they are platform-wide totals: they do not react to the search box, the status dropdown or the date range applied to the grid below.

Every status count must agree with the grid — the number on a card is exactly the number of rows the grid would show if that card's status were selected in the status filter. The cards are read-only: a card is not a filter shortcut and clicking one does nothing. Counts are read when the screen loads; the dashboard's 30-second auto-refresh (#1669) does not apply here.

### Card Specification

| Card | What it counts | Agrees with |
|---|---|---|
| Total trips | Every trip on the platform, all statuses | Grid with status filter = All |
| Active now | Trips currently in progress (matched through trip started) | Grid with status filter = Active; same definition as the dashboard's Active Trips (#1669) |
| Completed | Trips that ended successfully | Grid with status filter = Completed |
| Expired | Trips that expired without completing, all expiry reasons | Grid with status filter = Expired |

### Acceptance Criteria

**Scenario 1 — Admin opens the trip list**
- Given the admin navigates to the Trips screen
- When the page loads
- Then a row of four summary cards is displayed above the filter bar: Total trips, Active now, Completed, Expired
- And each card shows its caption and a whole-number count

**Scenario 2 — A card count agrees with the grid**
- Given the summary cards are displayed
- When the admin selects the status filter matching a card (for example Completed)
- Then the grid's total number of results equals the number shown on that card

**Scenario 3 — Cards do not react to the grid's filters**
- Given the summary cards are displayed with their counts
- When the admin types a search term, changes the status filter or applies a date range
- Then only the grid below narrows
- And the card counts continue to show the platform-wide totals, unchanged

**Scenario 4 — A count is zero**
- Given no trip currently matches one of the cards
- Then that card shows 0
- And it is not left blank or hidden

**Scenario 5 — One count cannot be retrieved**
- Given the platform cannot return the count for one card
- Then that card shows a placeholder instead of a number, never a stale or guessed value
- And the other three cards still show their counts
- And the grid below still loads normally

**Scenario 6 — Cards are read-only**
- Given the summary cards are displayed
- When the admin clicks a card
- Then nothing happens — no navigation, and no change to the grid's filters

**Scenario 7 — Cards are independent of the grid's state**
- Given the grid is still loading, is empty, or has failed to load
- Then the card row still occupies its place above the filter bar and shows whatever counts it was able to retrieve

### Out of Scope
- Clicking a card to apply the matching filter to the grid
- Trend indicators, percentage change, sparklines or period comparison on a card
- Refreshing the counts on a timer — they are read when the screen loads (the dashboard's 30-second refresh, #1669, is not applied here)
- Exporting the card values (the grid's CSV export from #1670 is unchanged)
- Per-zone or per-city breakdowns

### Dependencies
- #1670 — Admin views trip list (the grid these cards sit above)
- #1669 — Admin sees live summary dashboard (defines Active Trips, reused by the Active now card)

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
- #1808 — Admin cancels an in-progress trip
- #1809 — Admin reassigns a trip to another driver

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
- #3058 — Completed-trip fare is served to rider and driver (fare data source)
- #1639 — Rider submits driver rating (rating data source)
- #1815 — Admin processes a manual refund

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

## [Admin] #1756 — Admin creates a service zone 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As an admin, I want to create a named service zone by drawing its boundary on a map so that the platform can recognise trips originating in that area.

### Background

Zones are the foundation of the pricing system. Every zone has a name and a polygon boundary. The platform uses the rider's pickup coordinates to identify which zone she is in and applies that zone's rate card. There is no fallback zone — if a pickup falls outside all defined zones the trip is blocked. All of Cairo and Giza must be covered by zones before the platform goes live. This story covers **creating** a zone. A newly created zone has no rate card yet, so it starts **Inactive** and does not accept trips until a rate card is configured (#1757). Viewing all zones (list + map) is #1831; editing or deleting a zone is #1830.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Zone name | Yes | Free text | Letters, digits and spaces; must be unique | 2 chars | 60 chars | empty | Enter a zone name / أدخل اسم المنطقة | A zone with this name already exists / يوجد منطقة بهذا الاسم بالفعل | Zone name must be 2–60 characters / يجب أن يكون اسم المنطقة بين 2 و60 حرفًا |
| Zone boundary (polygon) | Yes | Map polygon | A closed polygon of ≥ 3 points drawn on the map; no self-intersections | 3 points | — | empty | Draw the zone boundary on the map / ارسم حدود المنطقة على الخريطة | Boundary must not self-intersect / يجب ألا تتقاطع حدود المنطقة | — |

### Acceptance Criteria

**Scenario 1 — Admin creates a new zone**
- Given the admin is on the create-zone screen
- When she enters a zone name, draws a polygon on the map, and saves
- Then the zone is created and recognised by the platform for trips originating inside that polygon

**Scenario 2 — New zone starts Inactive until a rate card is configured**
- Given a zone has just been created with no rate card yet
- Then it is Inactive and does not accept trips
- And it becomes Active automatically once a valid rate card is saved for it (#1757)

**Scenario 3 — Zone names must be unique**
- Given a zone already exists with a given name
- When the admin tries to save a new zone with the same name
- Then a validation error is returned: zone name must be unique

**Scenario 4 — New boundary must be valid**
- Given the admin draws a boundary with fewer than 3 points or one that self-intersects
- Then a validation error is returned and the zone is not created

### Out of Scope
- Viewing the zone list and map overview (see #1831)
- Editing or deleting zones (see #1830)
- Configuring the zone rate card (see #1757)
- Zone-specific time multipliers (Phase 2)
- Importing zone polygons from a file

### Dependencies
- #1757 — Admin configures zone rate card (activates the zone)
- #1831 — Admin views the service-zone list and map

---

## [Admin] #1757 — Admin configures zone rate card 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As an admin, I want to set and update each service zone's rate card so that fares are computed from the correct per-zone pricing.

### Background

This is the admin's **per-zone rate-card** configuration under Pricing & Rate Management. Each service zone has its own rate card: base fare, per-km rate, per-min rate, minimum fare, and cancellation fee. Saving a zone's first complete, valid rate card makes the zone **Active** — it begins accepting trips; a zone with no rate card is **Inactive** and blocks trips in its area (status is derived automatically from the rate card, never toggled by hand). Changes take effect immediately on save, and are recorded in the pricing audit log (#1760). Minimum fare must be ≥ base fare. The global cancellation policy and platform commission are configured separately in #1759.

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
- When the admin enters all required fields and saves
- Then the rate card is active immediately and the zone status changes to Active and starts accepting new trips

**Scenario 2 — Updates a rate**
- Given a zone has an existing rate card
- When the admin changes one or more values and saves
- Then the new values are active immediately for new trips and the previous values are preserved in the audit log

**Scenario 3 — Minimum fare must be at least the base fare**
- Given the admin sets minimum fare lower than base fare
- Then a validation error is returned: minimum fare cannot be less than base fare

**Scenario 4 — All rate-card fields are required**
- Given the admin tries to save with any field empty
- Then a validation error identifies the missing field and save is blocked

**Scenario 5 — Inactive zone (no rate card) blocks trips**
- Given a zone exists but has no rate card configured (Inactive)
- When a rider's pickup falls in that zone
- Then the trip is blocked and the overview shows the zone as Inactive with a warning: "No rate card — trips will be blocked"

**Scenario 6 — Status is derived, not manual**
- Given the admin is configuring rate cards
- Then there is no manual control to activate or deactivate a zone — a zone is Active whenever it has a valid rate card and Inactive whenever it does not

### Out of Scope
- Manual activation/deactivation of a zone (status is derived from the rate card)
- Global cancellation policy and platform commission (see #1759)
- Time-based rate multipliers (Phase 2)
- Per-vehicle-tier rate cards (Phase 2)
- Scheduled future rate changes

### Dependencies
- #1756 — Admin creates a service zone (zones must exist first)
- #1760 — Admin views pricing audit log (records changes)

---

## [Admin] #1759 — Admin configures global platform policies (cancellation policy + platform commission + dispatch) ✏️
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As an admin, I want to configure the global cancellation policy, the platform commission, and the driver acceptance window so that fees, the driver/platform split, the platform's share, and how long a driver has to answer a trip offer are managed consistently across all zones.

### Background

These are the **global** platform policies, applied across all zones: the **cancellation policy** (rider grace period, driver share %, driver cancellation fee, driver cancellation grace period, rider no-show wait time), the **platform commission** percentage, and the **dispatch** setting (driver acceptance window). Changes take effect immediately on save and apply to new trips only — in-progress trips use the values active at driver acceptance, and an acceptance-window change never shortens or extends a dispatch already in flight. Every change is recorded in the pricing audit log (#1760). The per-zone rate card (including the per-zone rider cancellation fee amount) is configured in #1757.

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

### Field Validation — Dispatch (global)

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Driver acceptance window | Yes | Integer (seconds) | Whole number between 10 and 120 | 10 | 120 | 30 | Enter the driver acceptance window / أدخل مهلة قبول السائق | Enter a whole number of seconds / أدخل عدد ثوانٍ صحيح | Must be between 10 and 120 seconds / يجب أن تكون بين 10 و120 ثانية |

### Acceptance Criteria

**Cancellation policy**

**Scenario 1 — Sets the rider grace period**
- Given the admin enters a rider grace period in minutes (e.g. 3) and saves
- Then all future rider cancellations use this grace period to determine whether the fee applies

**Scenario 2 — Sets the driver cancellation fee**
- Given the admin enters a fixed driver cancellation fee in EGP (e.g. 20) and saves
- Then a driver who cancels after the driver cancellation grace period is charged this amount, unless the cancellation is a waived rider no-show; setting it to 0 disables the fee

**Scenario 3 — Sets the driver cancellation grace period**
- Given the admin enters a driver cancellation grace period in minutes (e.g. 2) and saves
- Then a driver who cancels within this window after accepting is not charged, and one who cancels after it is subject to the driver cancellation fee

**Scenario 4 — Sets the rider no-show wait time**
- Given the admin enters a rider no-show wait time in minutes (e.g. 5) and saves
- Then a driver's cancellation fee is waived only when she cancels a rider no-show after waiting at least this long at the pickup

**Scenario 5 — Policy change applies to new trips only**
- Given a policy change is saved while a trip is in progress
- Then that trip uses the policy active at the time of driver acceptance and new trips use the updated policy

**Scenario 6 — Driver share must be between 1 and 99**
- Given the admin enters 0 or 100 as the driver share
- Then a validation error is returned: driver share must be between 1% and 99%

**Scenario 7 — Fee and time values must be non-negative**
- Given the admin enters a negative driver cancellation fee, grace period, or no-show wait time
- Then a validation error is returned and the change is not saved

**Platform commission**

**Scenario 8 — Sets the commission percentage**
- Given the admin enters a commission percentage (e.g. 20%) and saves
- Then all trips completed after this point use the new rate and the previous rate is preserved in the audit log

**Scenario 9 — Commission is applied to total fare**
- Given a completed trip with total fare 100 EGP and commission 20%
- Then the platform retains 20 EGP, the driver's net earnings are 80 EGP, and both are stored on the trip record

**Scenario 10 — Commission cannot be 0% or above 50%**
- Given the admin tries to save 0 or a value above 50
- Then a validation error is returned

**Dispatch**

**Scenario 11 — Sets the driver acceptance window**
- Given the admin enters a driver acceptance window in seconds (e.g. 30) and saves
- Then every trip offer dispatched after the save gives the driver that many seconds to accept or reject before it is passed to the next driver (#1630)
- And the driver app's countdown reflects the same value (#1582, #1585)

**Scenario 12 — Default acceptance window is 30 seconds**
- Given the platform has been set up and the admin has not yet changed the value
- Then the driver acceptance window is 30 seconds

**Scenario 13 — Acceptance window must be between 10 and 120 seconds**
- Given the admin tries to save a value below 10 or above 120, or a non-whole number
- Then a validation error is returned and the change is not saved

**Scenario 14 — Acceptance window change does not affect a dispatch in flight**
- Given a trip offer is already sitting with a driver under the previous window
- When the admin saves a new acceptance window
- Then the in-flight offer keeps the window it was issued with and only later dispatches use the new value

### Out of Scope
- Per-zone grace periods or per-zone driver cancellation fees
- Different splits per vehicle tier
- Driver appeal/dispute of the cancellation fee
- Per-zone commission rates
- Driver-specific commission tiers
- Commission on cancellation fees
- Per-zone, per-driver, or time-of-day acceptance windows (the window is a single global value)

### Dependencies
- #1757 — Admin configures zone rate card (per-zone rider cancellation fee lives there)
- #1764 — Cancellation fees are charged after grace period (consumes these settings)
- #1760 — Admin views pricing audit log (records changes)
- #1630 — Driver-matching engine (consumes the acceptance window when dispatching)

---

## [Admin] #1830 — Admin edits and deletes service zones 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As an admin, I want to edit a zone's name or boundary and delete zones I no longer need so that the zone map stays accurate as the city's coverage changes.

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
- When the admin adjusts the polygon boundary and saves
- Then the updated boundary takes effect immediately for new trips and the change is recorded in the audit log

**Scenario 2 — Renames a zone**
- Given an existing zone
- When the admin changes the zone name and saves
- Then the name is updated everywhere it appears, including rate-card screens and audit logs

**Scenario 3 — Rename must remain unique**
- Given another zone already uses a given name
- When the admin renames a zone to that same name
- Then a validation error is returned: zone name must be unique

**Scenario 4 — Edited boundary must stay valid**
- Given the admin edits a boundary so it has fewer than 3 points or self-intersects
- Then a validation error is returned and the change is not saved

**Scenario 5 — Deletes a zone**
- Given an existing zone with no trips currently in progress within it
- When the admin deletes it and confirms
- Then the zone is removed, its rate card is no longer accessible, and a confirmation dialog first warns that rides in that area will be blocked until a new zone is created

**Scenario 6 — Cannot delete a zone with trips in progress**
- Given a zone has one or more trips currently in progress within it
- When the admin attempts to delete it
- Then deletion is blocked with a message that the zone has active trips and cannot be deleted yet

### Out of Scope
- Creating and listing zones (see #1756)
- Importing zone polygons from a file
- Zone-specific time multipliers (Phase 2)
- Bulk edit or bulk delete of zones
- Merging or splitting existing zones

### Dependencies
- #1756 — Admin creates and lists service zones (zones must exist first)
- #1757 — Admin configures zone rate card (a deleted zone's rate card becomes inaccessible)
- #1760 — Admin views pricing audit log (records changes)

---

## [Admin] #1831 — Admin views the service-zone list and map 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** 2

**Description:** As an admin, I want to see all service zones on a map and in a list, each showing whether it is active or inactive, so that I can review coverage and spot zones that are not yet ready to take trips.

### Background

This is the read-only zones overview: a map showing every service zone as a coloured polygon, and a list/grid of all zones with each zone's **Active/Inactive** status. Status is derived automatically from the rate card — a zone with a valid rate card (#1757) is **Active** and accepts trips, while a zone with no rate card is **Inactive** and blocks trips in its area. Status is never set manually. Creating a zone is #1756; editing or deleting a zone is #1830.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Status filter | No | Dropdown (single-select) | Enum: All, Active, Inactive | — | — | All | — | — | — |
| Zone name search | No | Free text | Partial, case-insensitive match on zone name | — | 60 chars | empty | — | — | — |

### Acceptance Criteria

**Scenario 1 — Map overview shows all zones**
- Given the admin opens the Zones overview
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
- When the admin filters by Active or Inactive
- Then only zones with that status are shown in both the list and the map

**Scenario 5 — Search by zone name**
- Given many zones exist
- When the admin types part of a zone name
- Then the list narrows to matching zones

**Scenario 6 — Open a zone for create/edit/delete**
- Given the overview is displayed
- Then the admin can start creating a new zone (#1756) or open an existing zone to edit or delete it (#1830)

**Scenario 7 — Empty state**
- Given no zones have been created yet
- Then the overview shows an empty state prompting the admin to create the first zone

### Out of Scope
- Creating zones (see #1756)
- Editing or deleting zones (see #1830)
- Configuring the rate card (see #1757)
- Manually toggling a zone's active/inactive status (status is automatic)

### Dependencies
- #1756 — Admin creates a service zone
- #1757 — Admin configures zone rate card (drives Active/Inactive status)
- #1830 — Admin edits and deletes service zones (row/map actions)

### List / Grid Specification

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Zone name — A→Z

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Zone name | Yes | Yes | Text search |
| Status | Yes | Yes | Dropdown (All / Active / Inactive) |
| Created by | No | No | — |
| Created at (UTC+2) | Yes | Yes | Date range (from / to) |

---

## [Admin] #3994 — Admin configures balance and fee policy 🆕
**Feature:** Feature 16 — Pricing & Rate Management | **Sprint:** Phase 1

**Description:** As an admin, I want to configure the driver outstanding-balance limit and warning band so that the platform's cash exposure to drivers is capped.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`. The Arabic (RTL) counterpart of each page is the same file name with the `_ar` suffix, e.g. `revenue-summary_ar.html`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Global policies | `pricing-policies.html` | Global Policies → "Driver balance" card |

### Background

These are the **global** balance settings on `pricing-policies.html`, applied to every driver. The platform commission percentage, the cancellation grace periods, the driver cancellation fee, and the rider no-show wait are configured on #1759 — not here.

**Driver outstanding-balance limit.** The maximum a driver may owe the platform (a negative ledger balance) before the availability service refuses to put her online (#3996). Setting the limit to **0 disables the block entirely**. The **warning band** is the fraction of that limit at which the driver app starts warning her — at 80% of a 500 EGP limit, from 400 EGP owed (#3988) — and has no visible effect while the limit is 0.

Changes take effect immediately on save and apply to new evaluations only: a driver already online is never knocked offline by a balance-limit change. Every change is recorded in the pricing audit log (#1760). A rider's outstanding fee is always recovered in full on her next completed trip, so there is nothing to configure on that side (#4000).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Driver outstanding-balance limit | Yes | Decimal (EGP) | Zero or positive, up to 2 decimals; 0 disables the go-online block | 0 | 100000 | 500.00 | Enter the outstanding balance limit / أدخل حد الرصيد المستحق | Enter a valid amount / أدخل مبلغًا صحيحًا | Must be between 0 and 100,000 EGP / يجب أن تكون القيمة بين 0 و100,000 جنيه |
| Driver warning band | Yes | Percentage (%) | Whole number between 1 and 99 | 1 | 99 | 80 | Enter the warning band / أدخل نسبة التحذير | Enter a valid percentage / أدخل نسبة صحيحة | Must be between 1% and 99% / يجب أن تكون بين 1% و99% |

### Acceptance Criteria

**Scenario 1 — Sets the driver outstanding-balance limit**
- Given the admin enters an outstanding-balance limit of 500 EGP and saves
- Then a driver who owes 500 EGP or more is refused when she tries to go online (#3996)
- And a driver who owes less is unaffected

**Scenario 2 — Driver limit of zero disables the block**
- Given the outstanding-balance limit is set to 0 and saved
- Then no driver is ever blocked from going online because of her balance
- And no balance warning band is shown in the driver app (#3988)

**Scenario 3 — Driver limit change applies to the next go-online attempt**
- Given the limit is lowered while drivers are online
- Then no online driver is knocked offline
- And the new limit applies from each driver's next go-online request

**Scenario 4 — Sets the driver warning band**
- Given the admin sets the warning band to 80% against a 500 EGP limit and saves
- Then the driver app begins warning her once she owes 400 EGP or more (#3988)

**Scenario 5 — Warning band must be between 1% and 99%**
- Given the admin enters 0 or 100 as the warning band
- Then a validation error is returned and the change is not saved

**Scenario 6 — Negative or non-numeric values are rejected**
- Given the admin enters a negative limit, a negative amount, a warning band outside 1–99, or a non-whole number of days
- Then a validation error is returned and nothing is saved

**Scenario 7 — Changes are audited**
- Given any of these settings is changed
- Then the change is recorded in the pricing audit log (#1760) with actor, field, before and after values, and timestamp (UTC+2)

**Scenario 8 — Save and error states**
- Given the settings are saved successfully, or the save fails
- Then a success confirmation or an error state is shown and the form retains the entered values on failure

### Out of Scope
- Per-driver, per-zone, or tier-based balance limits — every limit here is a single global value
- Automatic suspension of a driver or rider who stays over a limit (Phase 2)
- The cancellation grace periods and the platform commission (#1759)
- Payout minimums, maximums, approval, or scheduling — a payout is recorded after Finance sends it (#4001), never gated or scheduled here
- Any rider fee recovery threshold or escalation setting — a rider's outstanding balance is always recovered in full on her next trip, with nothing to configure (#4000)
- The mechanics of how a rider fee is recovered on her next trip (#4000)

### Dependencies
- #3996 — Driver go-online is blocked while her outstanding balance is over the limit (consumes the driver limit)
- #3988 — Driver is blocked from going online while her balance is over the limit (consumes the warning band)
- #1760 — Admin views pricing audit log (records changes)
- #1759 — Admin configures global platform policies (sibling policy screen; owns commission and cancellation policy)

---

### Feature 17 — Admin Safety & Incident Review (ADO Feature #1802)

---

## [Admin] #1810 — Admin reviews the gender-mismatch report queue ✏️
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 4

**Description:** As an admin, I want a queue of all driver-raised gender-mismatch reports so that I can promptly review potential women-only policy violations and open each one for resolution.

### Background

SheDrive is a women-only service. When a driver reports that the rider who showed up is not female, the trip is expired with reason gender_mismatch_report, a report record is created, and the reported rider's account is automatically set to pending_review on the API side (#1687). This screen is the **queue** of all open reports (oldest first — reported rider, reporting driver, trip id, report time, rider status); the admin opens a report to review the trip snapshot, the reporting driver's statement, and the rider's current account state, then proceeds to resolve it. Resolving a report (suspend or dismiss) is handled by #1811.

**First-trip verification is mandatory.** On every rider's first trip the driver must **always** verify at pickup that the rider is female before the trip can start (#1588). The step cannot be skipped, dismissed or switched off, and there is no exception for any passenger. A gender-mismatch report can only be raised from that step, so every report relates to a rider's first trip; returning riders are not re-checked.

Oldest-first is deliberate and is the opposite of every other admin list: this is a queue to work through, and the longest-waiting case is the most urgent because a rider is held out of service while it sits.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Status filter | No | Dropdown (single-select) | Enum: Open / Resolved / All | — | — | Open | — | — | — |
| Date range — from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date range — to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before from-date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — Queue lists open reports**
- Given one or more open gender-mismatch reports exist
- When the admin opens the queue
- Then reports are listed oldest ( still opened ) first with reported rider, reporting driver, trip id, report time, and rider status

**Scenario 2 — Empty state**
- Given there are no open reports
- Then a clear empty-state message is shown

**Scenario 3 — Open a report**
- Given the admin clicks a report row
- Then the detail shows the trip snapshot, the reporting driver's statement, and the rider's current account state

**Scenario 4 — A report with no statement**
- Given the reporting driver submitted no statement — it is optional on the driver side (#1588)
- When the admin opens that report
- Then the statement block states plainly that no statement was given and that the trip snapshot is the only evidence
- And it is never left blank, so the admin can tell an absent statement from a failure to load one

**Scenario 5 — A resolved report shows how it was decided**
- Given a resolved report is opened or listed
- Then it shows whether it was resolved-suspended or resolved-dismissed, not merely "resolved"
- And the detail shows the resolving admin, the resolution time and any note (#1811)

**Scenario 6 — Filter the queue**
- Given the queue has many entries
- When the admin filters by date range or status (open / resolved / all)
- Then only matching reports are shown

**Scenario 7 — Export**
- Given the queue is displayed
- Then the admin can export the current view to CSV/Excel
- And the export covers every report matching the current filters, not only the visible page

**Scenario 8 — Proceed to action**
- Given a report is open
- When the admin chooses to resolve it
- Then she is taken to the action step (#1811)

**Scenario 9 — The linked trip is unavailable**
- Given the trip record behind a report can no longer be retrieved
- Then the report still opens, with the trip snapshot marked unavailable rather than the screen failing

**Scenario 10 — Report not found**
- Given a report id that does not exist
- Then a not-found message is shown with a link back to the queue

**Scenario 11 — Loading and error states**
- Given the queue is being fetched, then skeleton rows are shown
- Given the fetch fails, then a failure message with a retry action is shown

### Out of Scope
- Resolving a report — suspend or dismiss (see #1811)
- SOS/emergency incident handling — a separate queue (#3945 / #3946)
- Automated gender detection
- Penalising drivers for false reports (later phase)
- Contacting the rider
- Automated resolution

### Dependencies
- #1687 — Rider account is placed under review after a gender mismatch report (creates the records; owns pending_review)
- #1662 — Admin views rider profile
- #1811 — Admin actions a gender-mismatch report
- #1816 — Admin activity audit log

### List / Grid Specification

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Report time — oldest first

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

## [Admin] #1811 — Admin actions a gender-mismatch report ✏️
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 4

**Description:** As an admin, I want to resolve a gender-mismatch report by either suspending the reported rider or dismissing the report so that flagged accounts do not stay in limbo.

### Background

Opened from a report in the queue (#1810), the admin resolves it one of two ways: **Suspend** the reported rider (applies the same suspension as #1740 via API #1739, with the reason "Women-only policy violation (gender mismatch)" from the #1740 reason list and the report id attached as its reference) or **Dismiss** the report (the rider returns from pending_review to active). Because the gender-mismatch report is itself the recorded reason and the rider is already under review on this screen, an additional **resolution note** is **optional** free text on either outcome. The decision is written to the admin activity audit log (#1816) and the report leaves the open queue.

**First-trip verification is mandatory.** On every rider's first trip the driver must **always** verify at pickup that the rider is female before the trip can start (#1588). The step cannot be skipped, dismissed or switched off, and there is no exception for any passenger. A gender-mismatch report can only be raised from that step, so every report relates to a rider's first trip; returning riders are not re-checked.

`pending_review` is the state API #1687 places the rider in when the driver reports. It has exactly two exits and this screen is both of them — nothing else moves an account out of it.

**A dismissal is not a reinstatement.** Reinstatement (#1741) lifts a suspension that was actually applied and records a reason. A dismissal here means the report was not upheld: the rider returns to active with **no suspension record created**, so nothing appears in her history for something she was cleared of.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Resolution note | No (optional) | Free text (textarea) | Any character; optional on both Suspend and Dismiss — the gender-mismatch report is the recorded reason | — | 500 chars | empty | — | — | Too long — must be ≤ 500 characters / يجب ألا تتجاوز الملاحظة 500 حرف |

### Acceptance Criteria

**Scenario 1 — Suspend the reported rider**
- Given the admin is reviewing an open report
- When she chooses Suspend (optionally adding a free-text note)
- Then the rider's status changes from pending_review to suspended, her sessions are invalidated, and the report is marked resolved-suspended
- And the suspension is recorded with the reason "Women-only policy violation (gender mismatch)" — the same value from the #1740 reason list — with the report id attached as its reference, so her profile shows why she was suspended and which report it came from

**Scenario 2 — Dismiss the report**
- Given the admin determines the report is unfounded
- When she chooses Dismiss (optionally adding a free-text note)
- Then the rider returns from pending_review to active and the report is marked resolved-dismissed
- And no suspension record is created and her sessions are untouched
- And she can request trips again immediately

**Scenario 3 — Resolution note is optional**
- Given the admin chooses Suspend or Dismiss without entering any note
- Then the decision proceeds with no required-field error
- And given a note longer than 500 characters, the error "يجب ألا تتجاوز الملاحظة 500 حرف" is shown and nothing is changed

**Scenario 4 — A resolved report cannot be actioned again**
- Given a report already resolved
- Then no further action controls are available
- And the outcome, the note, who resolved it and when are shown in their place

**Scenario 5 — The decision is recorded on the report**
- Given a report is resolved either way
- Then the resolving admin, the resolution timestamp and the note are stored on the report and shown on this screen and in the queue's resolved view (#1810)

**Scenario 6 — The decision reaches the audit log**
- Given a report is resolved
- Then an entry is written to the admin activity audit log (#1816) recording the actor, the action type, the report id, and the before/after account status
- And a suspension raised here appears on the rider profile identically to one raised manually (#1740), so the profile never has to explain two kinds of suspension

**Scenario 7 — A rider under review is only actioned from the report**
- Given a rider's account is in `pending_review`
- When the admin views her in the rider list (#1661) or opens her profile (#1662)
- Then no Suspend or Reinstate action is offered there
- And her profile links to the open gender-mismatch report instead, so the decision is always taken against the report on this screen

**Scenario 8 — The report and the account never disagree**
- Given any part of the resolution fails
- Then neither the report status nor the rider's account status is changed, and the admin is told the decision was not recorded

### Out of Scope
- Contacting the rider
- Reopening a resolved report
- Driver-side penalties for false reports (later phase)
- Automated resolution

### Dependencies
- #1810 — Admin reviews the gender-mismatch report queue
- #1687 — Rider account is placed under review after a gender mismatch report (creates the report and owns `pending_review`)
- #1740 / #1739 — Account suspension (the mechanism reused to uphold a report)
- #1741 — Rider reinstatement (the separate path for lifting an unrelated suspension)
- #1816 — Admin activity audit log

---

## [Admin] #4120 — Admin sees summary cards above the gender-mismatch report queue 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** 4

**Description:** As an admin, I want to see how many gender-mismatch reports there are in total, how many are open and how many are resolved so that I know the size of the review workload at a glance.

### Background

Three read-only cards sit above the gender-mismatch report queue (#1810): **Total reports**, **Open** and **Resolved**. They show counts for all reports and do not change when the admin filters the grid.

Reports only come from the driver's check on a rider's first trip, which the driver must always do (#1588).

### Cards

| Card | Counts |
|---|---|
| Total reports | All reports |
| Open | Reports waiting for a decision |
| Resolved | Reports where the rider was suspended or the report was dismissed (#1811) |

### Acceptance Criteria

**Scenario 1 — Cards are shown**
- Given the admin opens the gender-mismatch report queue
- Then the Total reports, Open and Resolved cards are shown above the filters, each with a count
- And Open plus Resolved equals Total reports

**Scenario 2 — Counts stay the same when filtering**
- Given the cards are shown
- When the admin changes the status filter or the date range
- Then only the grid changes and the card counts stay the same

**Scenario 3 — Counts update after a change**
- Given a new report is raised or an open report is resolved
- When the admin reloads the queue
- Then the card counts reflect the change

**Scenario 4 — Zero or unavailable count**
- Given a card has no matching reports, then it shows 0
- Given a count cannot be loaded, then that card shows "—" and the other cards and the grid still load

**Scenario 5 — Cards are not clickable**
- Given the cards are shown
- When the admin clicks a card
- Then nothing happens

### Out of Scope
- Clicking a card to filter the grid
- Separate counts for suspended and dismissed
- Trends, charts or auto-refresh

### Dependencies
- #1810 — Admin reviews the gender-mismatch report queue
- #1811 — Admin actions a gender-mismatch report

---

## [Admin] #3945 — Admin reviews the SOS request queue 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** Phase 1

**Description:** As an admin, I want a queue of every SOS raised from inside a trip so that I can see which incidents are still unreviewed and open one to decide what to do.

### Background

An SOS is raised from inside an active trip by either occupant. It is a parallel record, not a trip state: the trip runs on, settles and is rated exactly as normal, the other occupant is never told, and the system never suspends anyone automatically. Only an admin closes a case.

This screen is the triage queue. Open cases sort above closed ones in every sort order, because a safety queue is worked top-down and a closed case must never bury an open one. The nav item carries an open-case count badge and sits above Safety reports — a live emergency outranks women-only triage. It is deliberately a review queue and not a real-time alerting surface: no sound, no popup. The portal must not imply a response time the operation cannot currently meet.

Resolving a case (suspend and close) is #3946.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Status filter | No | Dropdown (single-select) | Enum: Open / Closed / All | — | — | Open | — | — | — |
| Raised by filter | No | Dropdown (single-select) | Enum: Anyone / Rider / Driver | — | — | Anyone | — | — | — |
| Date range — from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date range — to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before from-date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — Queue lists open cases first**
- Given one or more SOS cases exist
- When the admin opens the queue
- Then open cases are listed above closed ones regardless of the chosen sort
- And within each group the newest case is listed first

**Scenario 2 — Each row identifies the incident at a glance**
- Given the queue is displayed
- When the admin scans the list
- Then each row shows the time it was raised, who raised it (rider or driver, with their name), trip id, trip state at the moment of the tap, location, how many contacts were alerted, and the case status
- And an open case is visually distinguished so a safety row does not read like an ordinary trip row
- And a closed case shows how it was closed, not merely "closed"

**Scenario 3 — A failed contact alert is visible in the list**
- Given a case where the platform could not deliver to one or more emergency contacts
- When that case appears in the queue
- Then the contacts-alerted cell shows the failed count distinctly, so it can be chased without opening the case

**Scenario 4 — Filter the queue**
- Given the queue has many entries
- When the admin filters by status, by who raised it, or by date range
- Then only matching cases are shown and the count badge reflects the filtered total

**Scenario 5 — Open a case**
- Given the queue is displayed
- When the admin clicks a case row
- Then the case detail opens (#3946)

**Scenario 6 — Open-case count is visible from anywhere**
- Given one or more cases are open
- When the admin is anywhere in the portal
- Then the SOS item in the side navigation carries the open-case count
- And the queue is a review surface only — no sound and no popup alert is raised

**Scenario 7 — Export**
- Given the queue is displayed
- When the admin chooses to export
- Then the current view is exported to CSV

**Scenario 8 — Empty state**
- Given no cases match the current filters
- When the queue is displayed
- Then a clear empty-state message is shown rather than a blank grid

**Scenario 9 — Loading state**
- Given the queue is open
- When the list of cases is still being fetched
- Then skeleton rows are shown in place of the grid

**Scenario 10 — Error state**
- Given the queue is open
- When the list of cases fails to load
- Then a failure message is shown with a retry action

### Out of Scope
- Resolving a case — suspend and close (see #3946)
- Real-time alerting in the portal (sound, popup)
- Live location tracking — the case carries a snapshot at the moment of the tap, not a live feed
- Notifying the other occupant
- Control room or staffed operations desk
- Automatic suspension on any pattern
- Changes to the v1 admin portal

### Dependencies
- #1779 — Emergency & Safety API (the SOS case record)
- #3946 — Admin actions an SOS request
- #1816 — Admin activity audit log
- #1662 — Admin views rider profile

---

## [Admin] #3946 — Admin actions an SOS request 🆕
**Feature:** Feature 17 — Admin Safety & Incident Review | **Sprint:** Phase 1

**Description:** As an admin, I want to suspend either party, both, or neither and then close an SOS case with a recorded reason so that every incident reaches a decision and no case is left open indefinitely.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`. The Arabic (RTL) counterpart of each page is the same file name with the `_ar` suffix, e.g. `revenue-summary_ar.html`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| SOS queue | `sos-requests.html` | SOS requests |
| SOS case detail + resolution | `sos-request-details.html` | SOS Case → Resolution / Suspend & Close / Dismiss |

### Background

Opened from a case in the queue (#3945). The screen carries the whole snapshot taken at the moment of the tap: who raised it, when, the trip state at trigger, the location, both parties, the vehicle, the trip, and every emergency contact the platform tried to reach with the result the gateway reported.

The admin then closes the case, ticking **suspend the rider**, **suspend the driver**, both, or neither — one confirmed action does all of it. A suspension always wins the recorded outcome, and goes through the same mechanism as a manual one, so it appears on that person's profile and in the audit log identically however it was raised. Closing is final: a closed case is never reopened, and a later suspension of the other party is done from that person's profile.

Two facts are stated on the screen because an admin will otherwise assume the opposite: the trip was **not** interrupted, and the case is **silent** — neither occupant was told the other raised it.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Suspend the rider | No | Checkbox | Ticked / not ticked; disabled when she is already suspended | — | — | Not ticked | — | — | — |
| Suspend the driver | No | Checkbox | Ticked / not ticked; disabled when she is already suspended | — | — | Not ticked | — | — | — |
| Resolution note | Yes | Free text (textarea) | Any character | 1 char | 500 chars | empty | Add a resolution note / أضيفي ملاحظة القرار | — | Too long — must be ≤ 500 characters / يجب ألا يتجاوز 500 حرف |

### Acceptance Criteria

**Scenario 1 — The case detail shows the full snapshot**
- Given an SOS case exists in the queue
- When the admin opens it from the queue
- Then the detail shows who raised it and what was reported, the trigger time, the trip state at the moment of the tap, the location as coordinates and an address on a map, the rider, the driver, the vehicle, and the trip reference as a link that opens the trip detail screen
- And every emergency contact the platform tried to reach is listed with the contact name, the relationship, and a delivered or failed result badge for that contact
- And the screen shows the notice that the trip was not interrupted and the SOS is recorded alongside it
- And the screen shows the notice that neither occupant was told the other raised it

**Scenario 2 — A stood-down false alarm still waits for the admin to close it**
- Given the person who raised the SOS stood it down as a false alarm and no admin has closed the case
- When the admin opens the case
- Then the detail shows a stood-down-by-the-reporter marker with the time she stood it down
- And the case status badge still reads Open and the close action controls are available

**Scenario 3 — Close with no suspension**
- Given an open case with neither suspend tick box ticked
- When the admin selects the outcome resolved, or false alarm, enters a resolution note and confirms
- Then the case status badge changes to Closed with that outcome
- And the resolution note, the admin who closed it and the closing time are shown on the case detail
- And the rider profile and the driver profile both still show account status Active

**Scenario 4 — Suspend one party while closing**
- Given an open case with both parties active
- When the admin ticks suspend the rider, enters a resolution note and confirms
- Then the rider profile shows account status Suspended with the resolution note as the suspension reason
- And the case outcome reads rider_suspended, not resolved
- And the driver profile still shows account status Active

**Scenario 5 — Suspend both parties in one action**
- Given an open case with both parties active
- When the admin ticks suspend the rider and suspend the driver, enters a resolution note and confirms
- Then both the rider profile and the driver profile show account status Suspended
- And the case outcome reads both_suspended

**Scenario 6 — The confirmation names the accounts that will be suspended**
- Given an open case and the admin has ticked suspend the driver only
- When the admin clicks the close action
- Then a confirmation dialog is shown naming the driver as the account that will be suspended and stating that the rider account is not affected
- And when no tick box is ticked the same dialog states that no account will be suspended
- And the case is only closed after the admin confirms in that dialog

**Scenario 7 — The resolution note is required**
- Given an open case with the resolution note left empty
- When the admin clicks the close action
- Then the case is not closed and the status badge still reads Open
- And the inline error "Add a resolution note / أضيفي ملاحظة القرار" is shown under the note field

**Scenario 8 — The resolution note is capped at 500 characters**
- Given an open case
- When the admin enters a resolution note longer than 500 characters and clicks the close action
- Then the case is not closed and the status badge still reads Open
- And the inline error "Too long — must be ≤ 500 characters / يجب ألا يتجاوز 500 حرف" is shown under the note field

**Scenario 9 — An already-suspended party cannot be suspended again**
- Given the rider on the case is already suspended for another reason
- When the admin opens the case
- Then the suspend the rider tick box is rendered disabled and cannot be ticked
- And the admin can still enter a note and close the case, and the case status badge changes to Closed

**Scenario 10 — Closing writes to the admin activity audit log**
- Given an open case with suspend the driver ticked
- When the admin enters a note and confirms the close
- Then a new entry appears in the admin activity audit log naming the acting admin, the SOS case id and the outcome driver_suspended
- And the driver profile suspension history shows the suspension with the same actor, reason and timestamp as a manually raised suspension

**Scenario 11 — A closed case cannot be actioned again**
- Given a case that has already been closed
- When the admin opens it
- Then the suspend tick boxes, the note field and the close action are not rendered
- And the outcome, the closing note, the admin who closed it and the closing time are shown instead
- And no reopen control is present on the screen

**Scenario 12 — Case not found**
- Given a case id that does not exist
- When the admin opens the case detail URL for that id
- Then a not-found message is shown in place of the case detail
- And a link labelled back to the SOS queue is shown that returns to the queue screen

### Out of Scope
- Reopening a closed case
- Contacting the rider or driver from this screen
- Live location tracking — the location is a snapshot at the moment of the tap
- Notifying the other occupant
- Automatic suspension on any pattern
- Changes to the v1 admin portal

### Dependencies
- #3945 — Admin reviews the SOS request queue
- #1779 — Emergency & Safety API (the SOS case record)
- #1740 / #1739 — Rider account suspension
- #1742 / #1741 — Driver account suspension
- #1816 — Admin activity audit log

---

### Feature 18 — Admin Financial Reporting & Reconciliation (ADO Feature #1803)

---

> **Removed 2026-09-17:** #1832 — Admin views revenue & commission summary report. The platform-wide revenue & commission summary is dropped from Phase 1. Per-driver earnings, commission and settlement are still reported by #1833.

---

## [Admin] #1833 — Admin views per-driver earnings & settlement report 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** 2

**Description:** As an admin, I want a per-driver earnings & settlement report over a selected period, so that I can answer driver payment queries and track each driver's settlement.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`. The Arabic (RTL) counterpart of each page is the same file name with the `_ar` suffix, e.g. `revenue-summary_ar.html`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Per-driver earnings & settlement report | `reconciliation.html` | Reconciliation → "Per-driver earnings & settlement" |
| Drill-through from "Open driver balance" | `driver-balances.html` | Driver Balances |

### Background

A single driver's financials for a chosen date range: completed-trips count, gross fares, commission deducted, net earnings, the cash-vs-digital split, the current outstanding cash balance (#1813), and per-trip rows (trip date, payment method, fare, commission, net). All figures derive from completed-trip records carrying the commission rate and fare breakdown (#1636). The report is exportable to PDF.

### Summary cards

The report opens with four summary cards above the per-trip breakdown. Every one of them is a period figure driven by the date range, so the row reads as a single consistent answer to "what did this driver earn between these two dates".

The delivered design kit (`SheDrive.AdminPanel_v16-09-2026`) shows a fifth card, *Driver Debt*. **It is out of scope for this story and is removed from the design.** Driver Debt is a live balance as at now — the date range does not move it. Standing it in the same row as four period totals invites the reader to subtract one from the others, which is meaningless. The driver's live balance is already reported twice, correctly: as *Outstanding cash balance* in the Cash vs digital rail on this screen, and as the balance column on Driver balances (#1813).

| # | Card (EN) | Card (AR) | Format | What it shows | What the admin uses it for | Scope |
|---|---|---|---|---|---|---|
| 1 | Completed trips | الرحلات المكتملة | Whole number (no currency, no decimals) | Count of trips the selected driver completed inside the selected period. Cancelled, expired and in-progress trips are excluded. | Establishes the size of the period before any money is read — three trips and three hundred trips warrant very different conversations about the same total. | Period; recomputes with the date range |
| 2 | Gross fares | إجمالي أجور الرحلات | EGP, 2 decimal places | Sum of the fares of those completed trips, taken from the stored fare breakdown (#1636). | The top line the driver herself will quote: what the riders were charged for her work, before the platform takes anything. | Period; recomputes with the date range |
| 3 | Commission deducted | العمولة المخصومة | EGP, 2 decimal places | Sum of the platform commission on those trips, at the commission rate stored on each trip (#1759). | Answers "how much did SheDrive take, and was it the rate I was promised" — the most common driver payment query. | Period; recomputes with the date range |
| 4 | Net earnings | صافي الأرباح | EGP, 2 decimal places | Gross fares minus commission deducted for the same set of trips. | The driver's actual earning for the period, and the figure every settlement conversation starts from. | Period; recomputes with the date range |

### Per-trip breakdown

One row per completed trip in the period, newest first, 20 rows per page.

| Column (EN) | Column (AR) | Format | What it shows |
|---|---|---|---|
| Trip date | تاريخ الرحلة | Date | When the trip completed. |
| Payment method | وسيلة الدفع | Status pill — Cash / نقدًا or Digital / إلكتروني | How the rider paid. This is what decides who is holding the money: on a cash trip the driver already has the fare and owes the commission, on a digital trip the platform has the fare and owes her the net. Without it the admin cannot tell whether a row's net earnings are money the driver already has or money still owed to her, and the Cash vs digital rail's totals cannot be traced back to the individual trips that produced them. |
| Fare (EGP) | الأجرة (جنيه) | EGP, 2 decimal places | The rider's fare for that trip. |
| Commission (EGP) | العمولة (جنيه) | EGP, 2 decimal places | The platform's commission on that trip, at the rate stored on it. |
| Net earnings (EGP) | صافي الأرباح (جنيه) | EGP, 2 decimal places | Fare minus commission for that trip. |

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Driver | Yes | Searchable dropdown — one control, type-ahead on **name or phone number** | Any approved or suspended driver account; each result row shows the driver's name and her phone number. Typed digits match the stored number in any notation (01012345678, +20 101 234 5678, 1012345678) | — | — | empty | Select a driver / اختر سائقًا | No match for that name or phone / لا يوجد تطابق لهذا الاسم أو الرقم | — |
| Date from | No | Date (YYYY-MM-DD) | Valid calendar date | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | — |
| Date to | No | Date (YYYY-MM-DD) | Valid calendar date; must not be before Date from | — | — | empty | — | Invalid date format / صيغة التاريخ غير صحيحة | End date must be after start date / تاريخ النهاية يجب أن يكون بعد تاريخ البداية |

### Acceptance Criteria

**Scenario 1 — Report for a driver and date range**
- Given the admin is on Reconciliation → "Per-driver earnings & settlement"
- When she selects a driver and a date range and clicks Search
- Then the four summary cards and the per-trip breakdown are shown for that driver and period
- And only trips completed by that driver between Date from and Date to inclusive appear in the rows

**Scenario 2 — Driver is required**
- Given no driver has been selected
- When the admin clicks Search
- Then no report is generated
- And the validation message "Select a driver / اختر سائقًا" is shown on the driver field

**Scenario 3 — The four summary cards show the period figures**
- Given a driver with completed trips in the selected period
- When the report is generated
- Then the cards show, in this order: Completed trips, Gross fares, Commission deducted, Net earnings
- And no Driver Debt card, or any other point-in-time balance, appears in the card row
- And Net earnings equals Gross fares minus Commission deducted
- And Gross fares, Commission deducted and Net earnings equal the column sums of the per-trip rows for the same period

**Scenario 4 — Completed trips is a count, not an amount**
- Given the cards are displayed
- When the admin reads the Completed trips card
- Then the value is a whole number with no decimal separator and no EGP suffix, for example 120
- And the other three cards show EGP to 2 decimal places

**Scenario 5 — Every card moves with the date range**
- Given a report is displayed for a driver
- When the admin changes the date range and clicks Search
- Then all four cards — Completed trips, Gross fares, Commission deducted and Net earnings — recompute for the new period
- And no card on the report holds a figure that the date range does not move

**Scenario 6 — The live balance is reported outside the cards**
- Given a report is displayed for a driver who owes an outstanding balance
- When the admin reads the Cash vs digital rail
- Then *Outstanding cash balance* shows the same live figure that the driver balances grid (#1813) shows for that driver
- And it is labelled as a current balance, not as a total for the period
- And a driver who owes nothing shows 0.00 EGP there, with no debt warning raised on the report

**Scenario 7 — Cash vs digital breakdown**
- Given a driver whose period contains both cash-collected and digitally-paid trips
- When the report is generated
- Then earnings are split into a cash portion and a digital portion
- And the two portions add up to the Net earnings card

**Scenario 8 — Driver with no trips in the period**
- Given the selected driver completed no trips in the selected period
- When the admin clicks Search
- Then all four cards show zero and the per-trip breakdown shows its empty state
- And the Cash vs digital rail still shows her live outstanding balance, because that is not a period figure
- And no error is shown

**Scenario 9 — Per-trip rows carry the same figures as the cards**
- Given a report whose period contains more than 10 completed trips
- When the admin pages through the per-trip breakdown
- Then each row shows trip date, payment method, fare, commission and net earnings for that trip
- And the card values stay unchanged across pages, because they are period totals and not page totals

**Scenario 10 — Export**
- Given a per-driver report is displayed
- When the admin exports it
- Then the exported file carries the same four card values and the same per-trip rows as the screen, including each row's payment method, for the same driver and period

**Scenario 11 — Drill-through to the driver balance**
- Given a per-driver report is displayed
- When the admin clicks "Open driver balance"
- Then the driver balances screen (#1813) opens on that same driver

**Scenario 12 — Loading and error states**
- Given the report has been requested
- When the data is still loading, or the request fails
- Then a loading state, or an error state with a retry action, is shown in place of the cards
- And no figure from a previous search is left on screen as if it were the new result

**Scenario 13 — Finding a driver by name or by phone**
- Given the admin is on the Driver & period panel
- When she types part of a driver's name into the driver field
- Then the matching drivers are listed beneath it, each row showing the driver's name and her phone number
- And when she types digits instead, the same list matches on phone number
- And a number typed as 01012345678, as +20 101 234 5678 or as 1012345678 all find the same driver
- And selecting a result puts that driver's name in the field and generates her report
- And when nothing matches, "No match for that name or phone / لا يوجد تطابق لهذا الاسم أو الرقم" is shown in place of the list
- And there is exactly one driver control on the panel — no separate free-text search box beside it

**Scenario 14 — Payment method on every row**
- Given a report whose period contains both cash-collected and digitally-paid trips
- When the admin reads the per-trip breakdown
- Then each row carries a Payment method value of Cash / نقدًا or Digital / إلكتروني
- And the fares of the rows marked Cash sum to the *Collected in cash* figure in the Cash vs digital rail
- And the fares of the rows marked Digital sum to the *Collected digitally* figure

### Out of Scope
- Charts and trend lines (Phase 2)
- Tax reporting
- Cross-driver leaderboards and performance analytics
- Payout execution
- Platform-wide revenue & commission summary — dropped from Phase 1 on 2026-09-17 together with story #1832; this report is per-driver only

### Dependencies
- #1636 — Trip settlement (stores the fare breakdown, commission rate and net earnings these figures derive from)
- #3058 — Completed-trip fare is served to rider and driver
- #1813 — Cash reconciliation
- #1759 — Admin configures platform commission

### List / Grid Specification (per-trip rows)

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Trip date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Trip date | Yes | No | — |
| Fare (EGP) | Yes | No | — |
| Commission (EGP) | Yes | No | — |
| Net earnings (EGP) | Yes | No | — |

---

## [Admin] #1813 — Admin reviews the driver balances grid ♻️
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** Phase 1

**Description:** As an admin, I want one list of every driver's balance so that I can see at a glance who owes the platform, who the platform owes, and whose ledger I need to open.

> **Split 2026-09-17:** the old #1813 covered the grid, the ledger and the settlement action in one story. It was split into three: **#1813** (this one) keeps the balances grid, **#4378** takes the driver ledger and the ledger model, **#4379** takes the record-settlement action.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`. The Arabic (RTL) counterpart of each page is the same file name with the `_ar` suffix, e.g. `driver-balances_ar.html`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Driver balances (list) | `driver-balances.html` | Driver Balances |

### Background

On cash trips the driver collects the full fare and therefore owes the platform its commission. This screen is the operational entry point: it lists drivers by balance so the admin can find the ones who owe, and opens any one of them into her full ledger (#4378), where a settlement is recorded (#4379).

**One signed balance per driver, in EGP.** Negative means she owes the platform (cleared by a settlement) and positive means the platform owes her (reduced by a payout). The grid shows that one signed number in a single **Balance** column — there is no separate outstanding column and available column — and it never computes a balance of its own (#4378). The list covers drivers with a **negative** balance by default, with a filter to show those the platform owes and those settled to zero.

**Settlement entries are exportable as PDF** directly from this screen — driver, amount, channel, reference, receipt number, recording admin, and time — giving Finance its reconciliation input. There is no separate day-book screen.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Driver search | No | Free text | Arabic and Latin letters, digits, spaces; partial match on name or phone | — | 50 chars | empty | — | — | Search term must be 50 characters or fewer / يجب ألا يزيد نص البحث عن 50 حرفًا |
| Balance filter | No | Dropdown (single-select) | Enum: Owing the platform, Owed by the platform, Settled (zero), All | — | — | Owing the platform | — | — | — |

### Acceptance Criteria

**Scenario 1 — List drivers by balance**
- Given drivers have balances
- Then they are listed with driver name, balance, last settlement date, and go-online status
- And the balance is one signed number in EGP shown with its sign — negative when she owes the platform, positive when the platform owes her, and 0.00 when she is settled
- And the default filter shows only drivers owing the platform, most negative first

**Scenario 2 — Search for a driver**
- Given the admin types part of a driver's name or phone number
- Then the list narrows to the matching drivers, within the current filter

**Scenario 3 — Filter by balance direction**
- Given the admin selects Owed by the platform, Settled (zero), or All
- Then the list shows only drivers whose signed balance matches, and the default reverts to Owing the platform on a fresh visit

**Scenario 4 — Sort and paginate**
- Given more than 20 drivers match
- Then the list paginates at 20 rows per page and can be sorted by driver, balance, or last settlement date

**Scenario 5 — Open a driver's ledger**
- Given the admin opens a driver's row
- Then her full ledger is shown (#4378), from which a settlement can be recorded (#4379)

**Scenario 6 — A settlement updates the row**
- Given a settlement is recorded for a driver (#4379)
- Then her balance and last settlement date on this grid reflect it, with no separate refresh step

**Scenario 7 — Settlement entries export to PDF**
- Given the driver balances list is displayed
- Then the admin can export the settlement entries to PDF, with driver, amount, channel, reference, receipt number, recording admin, and time on every row
- And the export respects the search and filter currently applied

**Scenario 8 — A suspended driver still appears**
- Given a driver is suspended (#1742) and has a balance
- Then she still appears in the list with her balance unchanged

**Scenario 9 — Empty, loading and error states**
- Given no drivers match the filter, the list is loading, or the request fails
- Then the corresponding empty, loading, or error state is shown

### Out of Scope
- The driver ledger view, the ledger entry types, and the posting guarantees (#4378)
- Recording a settlement and its form (#4379)
- Recording a payout sent to a driver (#4001)
- Automated payouts, bank transfers, or payment-provider integration
- A standalone settlement day book / reconciliation screen — cut deliberately on 2026-09-13; settlement entries export as PDF from this screen instead

### Dependencies
- #4378 — Admin opens a driver's balance ledger (the row's destination, and the source of every balance shown here)
- #4379 — Admin records a driver settlement (supplies the last settlement date and the PDF rows)
- #3996 — Driver go-online is blocked while her outstanding balance is over the limit (supplies the go-online status column)
- #3994 — Admin configures balance and fee policy (owns the outstanding-balance limit)
- #1833 — Admin views per-driver earnings & settlement report

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Balance — most negative first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Driver | Yes | Yes | Free-text search (partial match) |
| Balance (EGP, signed) | Yes | Yes | Dropdown (enum) |
| Last settlement date | Yes | No | — |
| Go-online status | No | No | — |

Opening a row navigates to the driver's ledger (#4378); the ledger's own grid specification lives there.

---

## [Admin] #4378 — Admin opens a driver's balance ledger 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** Phase 1

**Description:** As an admin, I want to open a driver's full transaction ledger so that I can see every entry that produced her balance before deciding what to reconcile.

> **Split 2026-09-17:** carved out of #1813 together with #4379.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Driver ledger | `driver-balance-details.html` | Ledger — *driver name* |

### Background

The ledger is the record behind the balance. It is opened from the driver balances grid (#1813) and is **read-only** — it shows entries, it never creates or changes them. Recording a settlement (#4379) and recording a payout (#4001) are separate actions on the same screen, each with its own story.

**One signed balance per driver, in EGP.** Negative means she owes the platform (cleared by a settlement) and positive means the platform owes her (reduced by a payout). Her balance is the arithmetic sum of her ledger entries — never stored directly and never computed from trip records. A new driver starts at zero. It is **one number, never a pair** — there is no separate outstanding figure and available figure, here or on the grid (#1813). Its entry types are:

| Entry type | Sign | Posted when | Shown in Source |
|---|---|---|---|
| `trip_commission` | debit (−) | A trip completes with `custody = driver` — she holds the fare, so the platform's commission becomes a debt she owes (#3997) | Trip id |
| `trip_earnings` | credit (+) | A trip completes with `custody = platform` — the platform holds the fare, so her net earnings become a debt it owes (#3997) | Trip id |
| `driver_cancellation_fee` | debit (−) | She cancels late without a qualifying no-show waiver (#1764) | Trip id (the cancelled trip) |
| `rider_cancellation_fee_credit` | credit (+) | A rider cancels late; the whole fee is credited to the driver (#1764) | Trip id (the cancelled trip) |
| `rider_fee_recovery` | debit (−) | She collected a rider's outstanding fee in cash on the platform's behalf (#4000) — the cash stays in her hand, so the recovered amount is a debt she owes back | Trip id (the trip the fee was recovered on) |
| `settlement` | credit (+) | Finance records cash received from the driver (#4379) | Receipt number (`S-nnnnn`) |
| `payout` | debit (−) | Finance sends the driver a payout on its own cycle and it is recorded against her balance afterward (#4001) | Payout reference |

**Entries are immutable and posting is idempotent.** Nothing edits an entry and nothing deletes one — Phase 1 ships with no correction mechanism at all, on either ledger. Every entry carries an idempotency key shaped `{event_type}:{trip_id|request_id}:{party_id}`, its type, its signed EGP amount, a timestamp (UTC+2), and the id of the source record.

### Field Validation

This screen is read-only — it has no editable fields. The settlement form and its validation live in #4379.

### Acceptance Criteria

**Scenario 1 — Open a driver's ledger**
- Given the admin opens a driver's row on the driver balances grid (#1813)
- Then her full transaction ledger is shown newest-first — trip commission, trip earnings, cancellation fees, fee credits, fee recoveries, settlements, and payouts — each with date, type, signed amount, and source reference
- And every row names its cause in **Source** — the trip id for a trip, fee or recovery entry, the receipt number for a settlement, the payout reference for a payout
- And the running balance is shown

**Scenario 2 — New driver starts at zero**
- Given an approved driver with no ledger entries
- Then her balance is 0.00 EGP and her ledger is empty

**Scenario 3 — Balance is the sum of the entries**
- Given a driver with entries of −20.00, −10.00, +15.00 and +300.00
- When her balance is read
- Then it is +285.00 EGP and matches the sum of her entries exactly

**Scenario 4 — A mixed-custody driver nets to one balance**
- Given a driver has one driver-custody trip (`trip_commission` −20.00) and one platform-custody trip (`trip_earnings` +80.00)
- Then her balance is the sum of both entries, +60.00 EGP, with no special handling for the mix of custody values

**Scenario 5 — Entries are immutable**
- Given a posted ledger entry
- When any request attempts to edit or delete it
- Then the request is rejected and the entry stands unchanged, with no correction offered in its place

**Scenario 6 — The same event never posts twice for the same idempotency key**
- Given a trip completion, cancellation, fee recovery, settlement, or payout is submitted or retried more than once for the same idempotency key
- Then exactly one ledger entry is posted per party for that key, and the balance is unaffected by the repeat

**Scenario 7 — Concurrent postings are serialised**
- Given two entries are posted for the same driver at the same moment
- Then both are recorded and the resulting balance reflects both, with no lost update

**Scenario 8 — Amounts are stored to two decimals with no rounding drift**
- Given any posted amount
- Then it is stored to two decimal places in EGP, and the balance never accumulates rounding drift

**Scenario 9 — A suspended driver's balance and ledger are retained**
- Given a driver is suspended (#1742)
- Then her balance and ledger are retained unchanged and remain visible to the admin

**Scenario 10 — The same entries appear in the driver's own app**
- Given entries exist on a driver's ledger
- Then her driver-app statement shows the same entries and the same balance (#1781, #1788), with no figure computed differently on either side

**Scenario 11 — Empty, loading and error states**
- Given the ledger is empty, loading, or the request fails
- Then the corresponding empty, loading, or error state is shown

### Out of Scope
- Recording a settlement — the action that posts a `settlement` credit (#4379)
- Recording a payout sent to a driver (#4001) — the mirror action, on the same screen but a separate story
- The driver balances list, its search, filters and PDF export (#1813)
- Editing, deleting, reversing or adjusting an entry — Phase 1 ships with no correction mechanism
- Driver dispute of a ledger entry (Phase 2)

### Dependencies
- #1813 — Admin reviews the driver balances grid (must be live — the entry point to this ledger)
- #3997 — Trip completion posts the custody-driven ledger entry
- #1764 — Cancellation fees post to both parties' ledgers
- #4000 — Rider outstanding fee recovered in cash by the driver
- #4001 — Admin records a payout sent to a driver
- #1781, #1788 — Driver balance and statement in the driver app

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Date — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Date (UTC+2) | No | No | — |
| Type | No | No | — |
| Amount (EGP, signed) | No | No | — |
| Source | No | No | — |

The ledger sub-grid is not separately sorted or filtered.

---

## [Admin] #4379 — Admin records a driver settlement 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** Phase 1

**Description:** As an admin, I want to record the money a driver hands back so that her outstanding balance is cleared against the channel it came through and she is unblocked once she has settled.

> **Split 2026-09-17:** carved out of #1813 together with #4378.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Record settlement | `driver-balance-details.html` | Ledger — *driver name* → "Record settlement" |

### Background

On cash trips the driver collects the full fare and therefore owes the platform its commission. Recording a settlement credits her balance and is the **only** way an outstanding amount is ever cleared. It is triggered from the driver's ledger (#4378), which is opened from the driver balances grid (#1813). Recording a payout Finance has sent — money going out, the mirror of this action — sits on the same screen but is a separate story (#4001).

**Recording a settlement posts a ledger entry.** It never edits a balance directly. The entry is immutable (#4378), appears in the driver's own statement (#1781, #1788), and is written to the audit log (#1816). **Partial settlements are normal** — she may hand in less than she owes, and the balance reduces by what she paid. A settlement that brings her below the balance limit unblocks her go-online immediately (#3996), with no further admin action.

**Settlement channels.** The admin records which channel the money came back through — Office cash, Bank deposit, Mobile wallet, or Field agent — drawn from a configurable list, not a hard-coded one. A reference is required for every channel except Office cash, where it is optional and, left blank, defaults to the settlement's own receipt number. Every settlement generates a unique **receipt number** (`S-nnnnn`), shown to the admin immediately and visible in the driver's own statement.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Settlement amount | Yes | Decimal (EGP) | Positive number, up to 2 decimals; not more than what she owes | 0.01 | what she owes (the magnitude of her negative balance) | empty | Enter a settlement amount / أدخل مبلغ التسوية | Enter a valid amount / أدخل مبلغًا صحيحًا | Amount must be greater than 0 and not exceed what she owes / يجب أن يكون المبلغ أكبر من 0 وألا يتجاوز الرصيد المستحق |
| Settlement date | Yes | Date (YYYY-MM-DD) | Valid calendar date; not in the future | — | today | today | Enter the settlement date / أدخل تاريخ التسوية | Invalid date format / صيغة التاريخ غير صحيحة | Date cannot be in the future / لا يمكن أن يكون التاريخ في المستقبل |
| Settlement channel | Yes | Dropdown (single-select, admin-configurable list) | Enum: Office cash, Bank deposit, Mobile wallet, Field agent | — | — | Office cash | Select a settlement channel / اختر قناة التسوية | — | — |
| Settlement reference | Required for every channel except Office cash | Free text | Letters, digits, hyphens; for Office cash, left empty it defaults to the generated receipt number | — | 60 chars | empty | Enter a settlement reference / أدخل مرجع التسوية | — | Reference must be 60 characters or fewer / يجب ألا يزيد المرجع عن 60 حرفًا |
| Settlement note | No | Free text | Any characters | — | 500 chars | empty | — | — | Note must be 500 characters or fewer / يجب ألا تزيد الملاحظة عن 500 حرف |

### Acceptance Criteria

**Scenario 1 — Record a full settlement**
- Given a driver's balance is −300.00 EGP (she owes the platform 300)
- When the admin records a 300 EGP settlement through Office cash
- Then a `settlement` entry of +300.00 EGP is posted, a receipt number is generated and shown to the admin, her balance becomes zero, and the last settlement date updates

**Scenario 2 — Record a partial settlement**
- Given a driver's balance is −300.00 EGP (she owes the platform 300)
- When the admin records 120 EGP
- Then her balance becomes −180.00 EGP and the entry appears in her ledger (#4378) with its receipt number

**Scenario 3 — Settlement unblocks a blocked driver**
- Given a driver is blocked from going online at a 500 EGP limit (#3996)
- When a settlement brings her below the limit
- Then her next go-online attempt succeeds with no further admin action

**Scenario 4 — Settlement amount validation**
- Given a settlement amount of zero, negative, or greater than what she owes
- Then it is rejected with a validation error and no entry is posted

**Scenario 5 — Settling a driver who owes nothing is refused**
- Given a driver whose balance is zero or positive
- Then the record-settlement action is unavailable for her

**Scenario 6 — Reference is required for non-cash channels**
- Given the admin selects Bank deposit, Mobile wallet, or Field agent as the channel
- When she leaves the reference empty and tries to save
- Then a validation error is returned and no entry is posted

**Scenario 7 — Office-cash reference defaults to the receipt number**
- Given the admin selects Office cash and leaves the reference empty
- Then the settlement is recorded with its own generated receipt number standing in as the reference

**Scenario 8 — Every settlement generates a receipt number**
- Given any settlement is recorded, on any channel
- Then a unique receipt number in the form `S-nnnnn` is generated, shown to the admin immediately, and visible in the driver's own statement (#1781, #1788)

**Scenario 9 — Every settlement is audited**
- Given a settlement is recorded
- Then it appears in the audit log (#1816) with actor, driver, amount, channel and receipt number, before/after balance, and timestamp (UTC+2)
- And it appears on the driver's earnings & settlement report (#1833)

**Scenario 10 — Driver sees it in her own app**
- Given a settlement is recorded
- Then it appears in the driver's statement with its receipt number and updates her balance (#1781, #1788)

**Scenario 11 — Double submission does not double-post**
- Given the settlement form is submitted twice for the same settlement
- Then exactly one entry is posted (#4378)

**Scenario 12 — A failed save posts nothing**
- Given the settlement request fails
- Then an error is shown, no entry is posted, and the driver's balance is unchanged

### Out of Scope
- Automated payouts, bank transfers, or payment-provider integration — every channel here records an operational fact after the money has already moved
- Adding, renaming, or removing settlement channels from the configurable list (managed outside this screen)
- Recording a payout sent to a driver (#4001) — the mirror action, on the same screen but a separate story
- The driver ledger view itself and its posting guarantees (#4378)
- The driver balances list, its search, filters and PDF export (#1813)
- Driver-facing settlement notifications
- Editing, reversing or adjusting a recorded settlement — Phase 1 ships with no correction mechanism
- Driver dispute of a ledger entry (Phase 2)
- A standalone settlement day book / reconciliation screen — cut deliberately on 2026-09-13; settlement entries export as PDF from the balances screen (#1813) instead

### Dependencies
- #4378 — Admin opens a driver's balance ledger (must be live — owns the ledger this action posts into, and the screen the action sits on)
- #1813 — Admin reviews the driver balances grid (must be live — the entry point)
- #3996 — Driver go-online is blocked while her outstanding balance is over the limit (unblocked by a settlement here)
- #3994 — Admin configures balance and fee policy (owns the outstanding-balance limit)
- #1759 — Admin configures global platform policies (platform commission)
- #1833 — Admin views per-driver earnings & settlement report
- #1816 — Admin views the admin activity audit log
- #1781, #1788 — Driver balance and statement in the driver app

---

> **Removed 2026-09-13:** cut as a report dressed as a screen. Settlement entries are exportable as PDF from the driver balances screen (#1813), which gives Finance the same reconciliation input. Can return as a real reconciliation — banked amount in, variance out — once the cash-collection model is decided.

---

## [Admin] #4005 — Admin reviews rider outstanding fees 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** Phase 1

**Description:** As an admin, I want to see every rider's outstanding fee balance and her full ledger so that I understand her position and, if her abuse is persistent, can escalate to suspension.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`. The Arabic (RTL) counterpart of each page is the same file name with the `_ar` suffix, e.g. `revenue-summary_ar.html`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Rider balances (list) | `rider-balances.html` | Rider Balances |
| Rider ledger | `rider-balance-details.html` | Ledger — *rider name* |

### Background

A rider's ledger is zero almost always. It moves when she cancels after the grace period (a `cancellation_fee` debit) or when that fee is recovered in full as a surcharge on her next completed trip (a `fee_collected` credit, #4000). This screen (`rider-balances.html`) is the admin counterpart to the outstanding balance a rider sees in her own app (#3992): it lists riders with an **outstanding** balance by default — with a filter for settled and all — and opens a full ledger for any one of them.

**One signed balance per rider, in EGP.** Negative means she owes an unpaid fee; a new rider starts at zero. Her balance is the arithmetic sum of her ledger entries — never stored directly and never computed from trip records. Its two entry types are:

| Entry type | Sign | Posted when |
|---|---|---|
| `cancellation_fee` | debit (−) | She cancels after the grace period (#1764) |
| `fee_collected` | credit (+) | The fee is recovered — in Phase 1, as a cash surcharge on her next trip (#4000) |

**Entries are immutable and posting is idempotent.** Nothing edits an entry and nothing deletes one — Phase 1 ships with no correction mechanism at all, on either ledger. Every entry carries an idempotency key shaped `{event_type}:{trip_id|request_id}:{party_id}`, its type, its signed EGP amount, a timestamp (UTC+2), and the id of the source record.

**The screen is read-only on the money, and the one action it offers is escalation.** There is no waive, write-off or correction of a rider's fee — the only way it clears is that she pays it in full on her next completed trip (#4000). A rider whose abuse is persistent is escalated through the existing rider-suspension flow (#1740), reachable from her ledger; that is a decision about her account, never a change to what she owes. There is no automatic booking block, because blocking one would deadlock — she can only ever clear a fee by taking a ride.

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Rider search | No | Free text | Arabic and Latin letters, digits, spaces; partial match on name or phone | — | 50 chars | empty | — | — | Search term must be 50 characters or fewer / يجب ألا يزيد نص البحث عن 50 حرفًا |
| Balance filter | No | Dropdown (single-select) | Enum: Outstanding, Settled (zero), All | — | — | Outstanding | — | — | — |

### Acceptance Criteria

**Scenario 1 — Open Rider Balances**
- Given riders exist with cancellation-fee and fee-collection entries
- When the admin opens the Rider Balances screen from the admin navigation
- Then the grid lists only riders whose balance is below zero, sorted by outstanding amount highest first, 20 rows per page
- And each row shows the rider name, the outstanding amount in EGP, and the date of her oldest unpaid fee
- And the Balance filter is pre-selected to "Outstanding"

**Scenario 2 — Filter to Settled and All**
- Given a rider whose balance is 0.00 EGP and a rider whose balance is −20.00 EGP
- When the admin changes the Balance filter to "Settled (zero)"
- Then the grid shows the 0.00 EGP rider and does not show the −20.00 EGP rider
- And when the admin changes the filter to "All", the grid shows both riders
- And when the admin changes the filter back to "Outstanding", only the −20.00 EGP rider is shown

**Scenario 3 — Open a rider's ledger**
- Given a rider in the grid with at least one cancellation fee and one fee collection
- When the admin expands that rider's row
- Then the ledger sub-grid opens showing her entries newest-first, 20 rows per page, with Date, Type, signed Amount in EGP, and the source trip reference on every row
- And the running balance is displayed on the ledger and equals the sum of the entries shown

**Scenario 4 — No fee-clearing action is offered**
- Given a rider with an outstanding balance of −20.00 EGP
- When the admin opens her ledger and inspects every control on the screen — row actions, toolbar, and detail pane
- Then no waive, write-off, adjustment, or correction control is present
- And the only action offered on the ledger is the suspend-rider link

**Scenario 5 — Escalate persistent abuse to suspension**
- Given a rider with repeated late cancellations and an outstanding balance of −20.00 EGP
- When the admin opens the suspend-rider link from her ledger
- Then the existing rider-suspension screen (#1740) opens for that rider
- And on returning to her ledger, her balance is still −20.00 EGP and her ledger contains the same entries as before

**Scenario 6 — Empty, loading and error states**
- When the admin applies a search term that matches no rider
- Then the grid is replaced by the empty state with its "no riders match" message and no rows
- And when the list request is still in flight, the grid shows the loading skeleton instead of rows
- And when the list request fails, the grid shows the error state with a Retry control, and pressing Retry re-issues the request

**Scenario 7 — Export the current view to PDF**
- Given the admin has entered a search term and selected a Balance filter
- When the admin presses Export to PDF
- Then a PDF file is produced containing exactly the rows matching the current search and filter, in the current sort order, and no other riders

**Scenario 8 — A new rider starts at zero**
- Given a rider who has never been charged a cancellation fee
- When the admin finds her under the "All" filter and opens her ledger
- Then her balance reads 0.00 EGP and her ledger sub-grid shows the empty state with no entries

**Scenario 9 — Balance is the sum of the entries, to two decimals**
- Given a rider with posted entries of −20.00 and −15.00 EGP
- When the admin opens her ledger
- Then the balance reads −35.00 EGP
- And every amount on the ledger and in the grid is shown in EGP to exactly two decimal places
- And after a −0.50 EGP entry is posted, the balance reads −35.50 EGP

**Scenario 10 — Posted entries cannot be edited or deleted**
- Given a posted ledger entry on a rider's ledger
- When a request to edit or delete that entry is submitted
- Then the request is rejected with an error response, and the entry and the balance are unchanged when the ledger is reloaded

**Scenario 11 — A repeated event posts only one entry**
- Given a rider with a balance of −20.00 EGP
- When the same cancellation or fee-recovery event is submitted again with the same idempotency key `{event_type}:{trip_id|request_id}:{party_id}`
- Then her ledger still shows exactly one entry for that key
- And her balance still reads −20.00 EGP

### Out of Scope
- Waiving, writing off, or otherwise adjusting a rider's outstanding fee — the only way it clears is that she pays it in full on her next completed trip (#4000)
- A free-form correction/adjustment action — every posted entry stands, with no correction mechanism in Phase 1
- Automated or bulk actions on rider balances
- Rider dispute workflow (Phase 2)
- Driver balance reconciliation (covered by #1813, #4378, #4379)
- Cancellation-policy configuration (#1759)
- Any rider fee recovery threshold or escalation setting — a rider's balance is always recovered in full on her next trip, with nothing to configure (#3994, #4000)

### Dependencies
- #4000 — Rider outstanding fee is recovered on her next trip (fee entries this screen displays originate here; also the only way a fee clears)
- #1740 — Operations admin suspends a rider account (the only action this screen offers beyond visibility)
- #1764 — Cancellation fees are charged after the grace period (rider and driver) (fee entries originate here)

### List / Grid Specification

**Page size:** 20 rows/page (server-side pagination) · **Default sort:** Outstanding — highest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Rider | Yes | Yes | Free-text search (partial match) |
| Outstanding (EGP) | Yes | Yes | Dropdown (enum) |
| Oldest unpaid fee date | Yes | No | — |

Expanding a row opens the rider's full ledger sub-grid (Date, Type, Amount, Source); the sub-grid is not separately sorted or filtered and paginates at 20 rows.

---

## [Admin] #4001 — Admin records a payout sent to a driver 🆕
**Feature:** Feature 18 — Admin Financial Reporting & Reconciliation | **Sprint:** Phase 1

**Description:** As an admin, I want to record a payout that Finance has already sent to a driver so that her ledger reflects the transfer and her statement shows it with its reference and date.

### Design reference

Delivered design kit: `SheDrive.AdminPanel_v16-09-2026`. The Arabic (RTL) counterpart of each page is the same file name with the `_ar` suffix, e.g. `revenue-summary_ar.html`.

| Screen | Design file | On-screen heading / entry point |
|---|---|---|
| Driver ledger + record payout | `driver-balance-details.html` | Ledger — *driver name* → "Record Payout" |
| Reached from | `driver-balances.html` | Driver Balances |

### Background

Recording a payout happens on the driver's ledger (#4378), in the same place as recording a settlement (#4379) — the same act in the opposite direction: money moved, now write it down. A driver never requests a payout: there is no request, no approval queue, no pending/approved/rejected states, and no reservation against her balance. Finance transfers the money on its own cycle, outside the system, and an admin records it here after the fact.

**Recording posts a ledger entry. It never edits a balance directly.** A `payout` debit is posted for the amount actually sent, reducing her available balance by exactly that amount, and it can never exceed her current available balance. **Posting is idempotent on the payout reference** — the bank or wallet transaction id, or a receipt number — so a retry or a double form submission never posts a second entry; the original is returned unchanged.

**The platform holds no payout destination.** Getting the money to the driver is a manual, off-platform process; nothing is captured from her and nothing is verified here. Every payout is immutable, appears immediately in the driver's own statement (#1781, #1788), and is written to the audit log (#1816).

### Field Validation

| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Payout amount | Yes | Decimal (EGP) | Positive number, up to 2 decimals; not more than the driver's available balance | 0.01 | available balance | empty | Enter a payout amount / أدخل مبلغ الصرف | Enter a valid amount / أدخل مبلغًا صحيحًا | Amount must be greater than 0 and not exceed the available balance / يجب أن يكون المبلغ أكبر من 0 وألا يتجاوز الرصيد المتاح |
| Payout date | Yes | Date (YYYY-MM-DD) | Valid calendar date; not in the future | — | today | today | Enter the payout date / أدخل تاريخ الصرف | Invalid date format / صيغة التاريخ غير صحيحة | Date cannot be in the future / لا يمكن أن يكون التاريخ في المستقبل |
| Payout reference | Yes | Free text | Letters, digits, hyphens | — | 60 chars | empty | Enter a payout reference / أدخل مرجع الصرف | — | Reference must be 60 characters or fewer / يجب ألا يزيد المرجع عن 60 حرفًا |

### Acceptance Criteria

**Scenario 1 — Record a payout**
- Given a driver has an available balance of 500 EGP
- When the admin records a payout of 200 EGP with a reference and date
- Then a `payout` entry of −200.00 EGP is posted (#1813), her available balance becomes 300.00, and the entry appears in her ledger with the reference and date

**Scenario 2 — Amount cannot exceed the available balance**
- Given a driver's available balance is 100 EGP
- When the admin attempts to record a payout of 150 EGP
- Then it is rejected with a validation error and no entry is posted

**Scenario 3 — Recording a payout for a driver who does not have one is refused**
- Given a driver's balance is negative or zero
- Then the record-payout action is unavailable for her

**Scenario 4 — Only approved drivers may receive a recorded payout**
- Given a driver whose account is pending approval, rejected, or suspended
- When a payout is submitted for her
- Then it is rejected

**Scenario 5 — Reference and date are required**
- Given a payout submission missing a reference or a date
- Then a validation error is returned and no entry is posted

**Scenario 6 — Idempotent on the payout reference**
- Given a payout is recorded with reference "PMT-1042"
- When the same reference is submitted again, whether as a retry or a double form submission
- Then no second entry is posted (#1813) and the original entry is returned unchanged

**Scenario 7 — Every payout is audited**
- Given a payout is recorded
- Then it appears in the audit log (#1816) with actor, driver, amount, reference, and timestamp (UTC+2)

**Scenario 8 — Driver sees it in her own app**
- Given a payout is recorded
- Then it appears in the driver's statement with its reference and date and reduces her available balance (#1781, #1788)

**Scenario 9 — Payout appears alongside settlements in the driver's ledger**
- Given the admin opens a driver's ledger on `balances.html` (#1813)
- Then payout and settlement entries appear in the same newest-first list, each with its own type, amount, and reference

### Out of Scope
- A driver requesting, tracking, or cancelling a payout — there is no such action anywhere in the system
- An approval queue, or pending/approved/rejected states — recording is the only step
- Executing the transfer — Finance moves the money outside the system before this screen is used
- Payment-provider or bank integration
- Capturing, storing, or verifying a payout destination of any kind — the platform holds none
- Bulk recording of multiple payouts
- Reversing a recorded payout — Phase 1 ships with no correction mechanism for a mis-recorded entry (#1813)
- Tips, bonuses, incentives, and referral credits

### Dependencies
- #1813 — Admin reconciles driver balances and records settlements (must be live — owns the driver ledger that receives the payout entry; same screen as the settlement side of this action)
- #1816 — Admin views the admin activity audit log

---

### Feature 19 — Admin Audit & Compliance (ADO Feature #1804)

---

## [Admin] #1816 — Admin views the admin activity audit log 🆕
**Feature:** Feature 19 — Admin Audit & Compliance | **Sprint:** 2

**Description:** As an admin, I want a chronological, searchable log of every consequential admin action so that I can hold the team accountable and investigate decisions.

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
- When the admin filters by actor, action type, date range, or target entity
- Then only matching entries are shown

**Scenario 4 — Read-only**
- Given the admin views the log
- Then no entry can be edited or deleted

**Scenario 5 — Pagination**
- Given more than 50 entries exist
- Then results are paginated 10 per page

**Scenario 6 — Export**
- Given a filtered view is displayed
- Then the admin can export it to CSV/Excel

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

**Page size:** 10 rows/page (server-side pagination) · **Default sort:** Timestamp — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Timestamp (UTC+2) | Yes | Yes | Date range (from / to) |
| Actor | Yes | Yes | Dropdown (All actors / specific admin) |
| Action type | Yes | Yes | Dropdown (All / approve / reject / suspend / reinstate / cancel / reassign / refund / settlement / gender-mismatch resolution / admin-account change) |
| Target entity & id | No | Yes | Free-text search (partial match) |
| Before / after values | No | No | — |

---



# Payouts, settlement import and maker-checker (2026-10-14)

> Spec: `docs/superpowers/specs/2026-10-14-driver-payouts-settlement-design.md`. Created in ADO 2026-10-14 with tag "Payouts & settlement".

---

## [Admin] #5617 — Financial lead approves or rejects finance requests (maker-checker) 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval

**Description:** As a Financial lead, I want every finance request in one queue, each on its own page, so that I can check each one and decide it before money or prices move.

### Rules
- **Approvals** lists every finance request. What creates each type and what deciding it does is in that type's approval cycle story (Dependencies).
- Financial officers and Financial leads make requests; only a Financial lead decides, and never her own request (#6484).
- With no other active Financial lead, a lead's own request shows "Waiting for another Financial lead" / "في انتظار رئيس فريق مالي آخر" and stays pending.
- Requests never expire.
- Above the queue, three cards:

| Card | Shows |
|---|---|
| Pending Requests / طلبات قيد الانتظار | How many are pending |
| Longest Waiting / أطول انتظار | Age of the oldest pending one ("5 hours", "2 days") |
| Decided Today / قرارات اليوم | Approved or rejected today |

- **View** on a row, and every link to a request on another screen, opens the **request page** (`approval-request.html?id=APR-nnnn`). Its back button returns to the screen she came from (Approvals by default).
- Every request page has the same frame; each cycle story lists what its type puts in it:

| Block | Shows |
|---|---|
| Title | "{type} —" and the request ID |
| Request details | Subject (links to it), amount, created by and when, the type's own facts, status; once decided: checked by, decided on |
| Before → After | Every changed value, old → new |
| The type's sections | What the checker needs for that type (in its cycle story) |
| What approving does | Short bullets: what Approve does, what Reject leaves |
| Actions | **Approve Request** · **Reject Request**, under the content |

- Approve asks to confirm and says what the approval does. Reject asks for a reason. After either, she stays on the page: a success message shows and the page shows the decision.
- A decided request's page opens with a banner: "Approved by {name} on {date}" or "Rejected by {name} on {date}" with the reason.
- A lead's own request shows Approve and Reject disabled with "You made this request — another Financial lead must decide it." / "أنت من قدّم هذا الطلب — يجب أن يقرر فيه رئيس فريق مالي آخر."
- **Financial officer**: sees only her own requests, read-only (no Approve or Reject), with no Created by filter; her sidebar count is her own pending requests.
- National IDs and account numbers are shown in full.
- The sidebar shows the pending count next to **Approvals**.

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Rejection reason | Yes (reject only) | Free text (textarea) | Any characters | 10 chars | 500 chars | empty | Give a reason for rejecting / اذكر سبب الرفض | — | Reason must be 10–500 characters / يجب أن يكون السبب بين 10 و500 حرف |

### List / Grid Specification
**Status filter:** Pending (default) · Decided · **Page size:** 20 · **Default sort:** Pending — newest made first; Decided — newest decided first

| Filter | Options |
|---|---|
| Created by | Anyone / Other admins — mine to decide / Me — waiting for others |
| Area | All / Payouts & settlements (payout result, manual payout, manual settlement, settlement import, payout settings) / Rider fees (fee waiver) / Pricing (rate card, commission, cancellation policy, balance limit) / Driver details (payout method change) |
| Request type | All / the eleven types |

| Column | Sortable |
|---|---|
| Request ID | No |
| Type | No |
| Subject (driver, rider, zone, batch, file or policy — links to it) | No |
| Amount (EGP) | Yes |
| Created by / at ("You" chip on her own) | Yes |
| Status | No |
| Checked by / at (Decided only) | Yes |
| Actions (View) | No |

### Acceptance Criteria
**Scenario 1 — Approve on the request page**
- Given a pending request made by another admin
- When a Financial lead opens it with View, approves and confirms
- Then the page shows "Approved by …", Approve and Reject are gone, the pending count drops by one, and the change applies as its cycle story says

**Scenario 2 — Reject needs a reason**
- When she rejects with no reason
- Then she sees "Give a reason for rejecting" and nothing is decided
- When she gives one
- Then the page shows "Rejected by …" with the reason, and the subject stays as it was

**Scenario 3 — Back to where she came from**
- Given she opened a request from a payout batch's pending notice
- When she uses the back button after deciding
- Then she is on that batch again

**Scenario 4 — Maker cannot decide her own request**
- Given Hala made a commission change
- When she opens it
- Then Approve and Reject are disabled and the page says another Financial lead must decide it

**Scenario 5 — No other Financial lead**
- Given Hala is the only active Financial lead
- Then her own request shows "Waiting for another Financial lead" and stays pending

**Scenario 6 — Financial officer's queue**
- Given Mona (Financial officer) has two pending requests and Hala has one
- When Mona opens Approvals
- Then she sees her two, without Approve or Reject on their pages, and not Hala's

### Out of Scope
- Approval limits by amount
- Bulk approve
- Delegating approvals while a lead is on leave
- Email when a request is waiting

### Dependencies
- #6483, #6484 — Financial officer and Financial lead
- #1816 — Audit log (every request, approval and rejection is logged)
- Approval cycles — each lists its request page's sections:

| Story | Type |
|---|---|
| #6559 | Payout result |
| #6560 | Settlement import |
| #6561 | Manual settlement |
| #6562 | Manual payout |
| #6563 | Fee waiver |
| #6564 | Payout method change |
| #5623 | Rate card change |
| #6565 | Commission change |
| #6566 | Cancellation policy change |
| #6567 | Balance limit change |
| #6568 | Payout settings change |

### Mockup (ADO comment)
- Approvals as a Financial lead: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approvals.html?as=fin_lead
- As a Financial officer: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approvals.html?as=fin_officer
- Request page (payout result, 338 lines): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0012&as=nour.hassan@shedrive.app
- Own request, another lead must decide: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0021&as=hala.mahmoud@shedrive.app
- Decided request (rejected): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0008
- Request not found: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-9999
- Every type's request page is in its approval cycle story.

---

## [Admin] #6559 — Approval cycle — Payout result 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Payout

**Description:** As a Financial lead, I want to check a batch's result file before it is posted so that a driver is marked paid only when her transfer really went through.

### Rules
- Made when an admin imports a batch's result file (#5619). A batch pays one method, so one request per batch. Subject: the batch. Amount: the successful lines.
- Pending notice: the batch reads Result pending approval with a link to the request page; its back button returns to the batch.

### Request page
| Block | Shows |
|---|---|
| Request details | Batch (links to it), successful amount, created by, **File type** (the payout method), file name, status |
| Before → After | Lines sent to bank: n → 0 · Lines paid: 0 → n · Lines back to Due: 0 → n |
| Result file — tiles | File total (amount, lines) · Successful (amount, lines) · Failed (amount, lines) |
| Result file — list | Search (driver, national ID, account, reference) · Result filter (All / Failed / Success) · Reset · failed lines first · paged 10 / 20 / 50 |
| List columns | Line, Driver name, National ID, Wallet provider or Bank (not for prepaid card), Wallet / Account / Card number, Amount (EGP), Result, Bank reference (success) or Reason (failed) |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- Each SUCCESS line posts a payout entry (−line amount, bank reference); the driver is told she was paid.
- Each FAILED line goes back to Due, flags her Last payout failed with the reason, and she is told.
- The batch is Completed.
- Reject: nothing posts; the batch is Sent to bank again, so a corrected result can be imported.

### Acceptance Criteria
All scenarios use the same example: a mobile wallet batch of 100 lines, 50,000 EGP. Its result file marks 98 lines SUCCESS (49,000 EGP) and 2 FAILED (1,000 EGP).

**Scenario 1 — The checker sees the totals**
- When the checker opens the request
- Then she sees three tiles:
  - File total: 50,000 EGP, 100 lines
  - Successful: 49,000 EGP, 98 lines
  - Failed: 1,000 EGP, 2 lines

**Scenario 2 — Failed lines come first**
- When the checker opens the request
- Then the 2 failed lines are at the top of the list, each with its reason, followed by the successful lines

**Scenario 3 — Finding one driver**
- When the checker types a driver's national ID in the search
- Then the list shows only that driver's line

**Scenario 4 — Approved**
- When the checker approves it
- Then the 98 drivers are paid with their bank reference, the 2 failed lines are Due again with Last payout failed, and the batch is Completed

**Scenario 5 — Rejected**
- When the checker rejects it with a reason
- Then no line is paid and the batch is Sent to bank again, showing the reason

### Dependencies
- #5617 — Approvals and the request page
- #5619 — Bank file and result

### Mockup (ADO comment)
- Request page — mobile wallet batch, 338 lines, 6 failed: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0012&as=nour.hassan@shedrive.app
- Bank account batch, 333 lines: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0013&as=nour.hassan@shedrive.app
- Prepaid card batch, 329 lines (no provider column): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0014&as=nour.hassan@shedrive.app
- Approved result: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0005

---

## [Admin] #6560 — Approval cycle — Settlement import 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Settlement

**Description:** As a Financial lead, I want to check a settlement sheet before it is applied so that no driver's balance changes on a file only one person has read.

### Rules
- Made when an admin sends a checked file (#5620): one request for the whole file. Subject: the file. Amount: the file's total.
- Pending notice: the settlements history (#6492) shows the file as Pending approval with a link to the request page; its back button returns to the history.

### Request page
| Block | Shows |
|---|---|
| Request details | File name, amount, created by, rows, status |
| Before → After | Owed by these drivers: total before → total after |
| File rows — tiles | Amount (rows) · Settled in full · Part paid · Paid more |
| File rows — list | Search (driver, national ID, phone, reference) · Result filter (All / Settled in full / Part paid / Paid more) · Reset · paged 10 / 20 / 50 |
| List columns | Row, Driver, National ID, Phone, Amount (EGP), Balance now → after, Payment (reference, date, channel), Result (Settled in full · Part paid — still owes X · Paid more — X added to her balance) |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- Each row posts a settlement entry with a receipt number (S-nnnnn); a driver's go-online block lifts once she is under the limit.
- The file is Approved and gets its View page (#6492).
- Reject: nothing posts; the file is Rejected with the reason, and its payment references can be imported again in a corrected file.

### Acceptance Criteria
**Scenario 1 — Approved**
- Given a 13-row file awaiting approval
- When the checker approves it
- Then 13 settlement entries post with receipt numbers and the history shows the file Approved with View

**Scenario 2 — Rejected**
- When the checker rejects it with "The Fawry references do not match the Fawry statement"
- Then no balance changes, the history shows Rejected with that reason, and a corrected file with the same references passes step 3

### Dependencies
- #5617 — Approvals and the request page
- #5620 — Settlement import wizard
- #6492 — Settlements history

### Mockup (ADO comment)
- Request page — settlement import, 13 rows: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0018&as=nour.hassan@shedrive.app
- Rejected file: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0025
- Settlements history: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?as=fin_lead

---

## [Admin] #6561 — Approval cycle — Manual settlement 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Settlement

**Description:** As a Financial lead, I want a settlement recorded by hand to wait for my approval so that no single person can change a driver's balance.

### Rules
- Record settlement (#4379) on the driver's ledger creates a request instead of posting. Subject: the driver. Amount: the settlement.
- Pending notice: Record settlement gives way to the notice with a link to the request page; her Driver balances row shows Awaiting approval.
- Only one request can be pending for her settlement; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Driver, amount, created by, payment channel, status |
| Before → After | Balance |
| Settlement details | Driver (links to her ledger), balance now, payment channel, payment date, reference, note, proof of payment |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- The settlement posts with its receipt number as #4379 describes; her go-online block lifts once she is under the limit.
- Reject: her balance stays; Record settlement is offered again.

### Acceptance Criteria
**Scenario 1 — Balance waits**
- Given a driver owes 300.00 EGP
- When a Financial officer records a 300.00 settlement
- Then she is told it was sent for approval, the balance still reads −300.00 and the ledger shows the pending notice

**Scenario 2 — Approved**
- When a Financial lead approves it
- Then the settlement posts with its receipt number and the balance reads 0.00

**Scenario 3 — Rejected**
- When a Financial lead rejects it
- Then the balance stays −300.00 and Record settlement is back

### Dependencies
- #5617 — Approvals and the request page
- #4379 — Admin records a driver settlement

### Mockup (ADO comment)
- Request page — manual settlement: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0011&as=hala.mahmoud@shedrive.app
- Driver balances: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html

---

## [Admin] #6562 — Approval cycle — Manual payout 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Payout

**Description:** As a Financial lead, I want a payout recorded by hand to wait for my approval so that no single person can mark a driver paid.

### Rules
- Record payout (#4001) on the driver's ledger creates a request instead of posting. Subject: the driver. Amount: the payout.
- Pending notice: Record payout gives way to the notice with a link to the request page; her Driver balances row shows Awaiting approval.
- Only one request can be pending for her payout; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Driver, amount, created by, reference, status |
| Before → After | Balance |
| Payout details | Driver (links to her ledger), paid to (method and provider), account / wallet / card number, account holder, reference, payment date, proof of payment |
| Where her earnings stand — tiles | Due · On hold (7 days) · In an open batch |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- The payout posts to her ledger and marks her oldest Due earnings Paid, up to its amount.
- Reject: her balance and earnings stay; Record payout is offered again.

### Acceptance Criteria
**Scenario 1 — Approved**
- Given a driver's balance is 620.00 EGP
- When a Financial officer records a 500.00 payout with reference INSTAPAY-… and a Financial lead approves
- Then her balance reads 120.00 and her oldest Due earnings worth 500.00 read Paid

**Scenario 2 — Rejected**
- When a Financial lead rejects it
- Then her balance stays 620.00 and nothing is marked Paid

### Dependencies
- #5617 — Approvals and the request page
- #4001 — Admin records a payout sent to a driver

### Mockup (ADO comment)
- Request page — manual payout: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0019&as=nour.hassan@shedrive.app
- Driver balances: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html

---

## [Admin] #6563 — Approval cycle — Fee waiver 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Fee waiver

**Description:** As a Financial lead, I want a fee waiver to wait for my approval so that no rider's fee disappears on one person's say.

### Rules
- Waive fee on the rider's ledger (#5621) creates a request. Subject: the rider. Amount: the fee.
- Pending notice: the fee reads "Waiver awaiting approval" with a link to the request page and offers no Waive action.
- Only one request can be pending for the fee; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Rider, fee, created by, trip, status |
| Before → After | Fee owed |
| Fee details | Rider (links to her ledger), trip (links to it), trip date, route, driver, fee to waive, what the rider owes now, reason |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- An unpaid fee is removed from what the rider owes; a paid one becomes a credit on her balance.
- The driver's credit for that fee is reversed, as #5621 describes.
- Reject: the fee stays owed; Waive is offered again.

### Acceptance Criteria
**Scenario 1 — Approved**
- Given a 20.00 EGP fee for trip T-1042 has a waiver awaiting approval
- When a Financial lead approves it
- Then the rider owes 0.00 for it and the driver's 20.00 credit is reversed

**Scenario 2 — Rejected**
- When a Financial lead rejects it
- Then the rider still owes 20.00 and Waive is back on the fee

### Dependencies
- #5617 — Approvals and the request page
- #5621 — Admin waives a rider's cancellation fee

### Mockup (ADO comment)
- Request page — fee waiver: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0010&as=nour.hassan@shedrive.app
- Rider balances: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html

---

## [Admin] #6564 — Approval cycle — Payout method change 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Payout

**Description:** As a Financial lead, I want an admin's change to a driver's payout method to wait for my approval so that no one can redirect a driver's money alone.

### Rules
- An admin's edit on the driver profile (#5624) creates a request. The driver's own change in the app does not. Subject: the driver.
- Pending notice: the profile reads "Change awaiting approval" with a link to the request page, and Edit is disabled.
- Only one request can be pending for her payout method; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Driver, created by, status |
| Before → After | Payout type, provider or bank, account number, account holder — all in full |
| Driver | Driver (links to her profile), when the current method was last updated and by whom, due now, in an open batch |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- Her payout method is replaced and shows it was updated by an admin; her next batch uses the new method.
- A line already in an open batch is paid to the method it was generated with.
- Reject: her current method stays; Edit is offered again.

### Acceptance Criteria
**Scenario 1 — Approved**
- Given her method is a Vodafone Cash wallet and an admin requested a CIB bank account
- When a Financial lead approves it
- Then her next payout goes in a bank-account batch to the CIB account

**Scenario 2 — Rejected**
- When a Financial lead rejects it
- Then her payouts still go to the wallet

### Dependencies
- #5617 — Approvals and the request page
- #5624 — Admin views and edits a driver's payout method

### Mockup (ADO comment)
- Request page — payout method change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0020&as=nour.hassan@shedrive.app
- Driver profile: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069

---

## [Admin] #5623 — Approval cycle — Rate card change 🆕
**Feature:** #1755 Admin — Pricing & Rate Management | **Sprint:** Sprint 6 | **Tag:** Approval

**Description:** As a Financial lead, I want a rate card change to wait for another Financial lead's approval so that prices never change on one person's say.

### Rules
- Saving or removing a zone's rate card (#1757) creates a request. Only a Financial lead makes it. Subject: the zone.
- Pending notice: the zone reads "Rate card change awaiting approval" with the proposed values and a link to the request page; its card is locked.
- Only one request can be pending for the zone; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Zone, created by, status |
| Before → After | Base fare, per-km rate, per-minute rate, minimum fare, cancellation fee; a removal shows Rate card → Removed |
| Where it applies | Zone (links to Pricing & zones), zone status, "To new trips in this zone, from the moment it is approved." |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- New trips in the zone price on the new card; the zone status follows the card. Logged in #1760.
- Reject: the card stays and is unlocked.

### Acceptance Criteria
**Scenario 1 — Price waits**
- Given Zamalek's per-km rate is 6.50 EGP
- When a Financial lead saves 7.00
- Then trips still price at 6.50 and the zone shows the pending change

**Scenario 2 — Approved**
- When another Financial lead approves
- Then new trips in Zamalek price at 7.00

**Scenario 3 — Rejected**
- When another Financial lead rejects it
- Then trips stay at 6.50 and the card can be edited again

### Out of Scope
- Scheduling a price change for a future date

### Dependencies
- #5617 — Approvals and the request page
- #1757 — Zone rate card
- #1760 — Pricing changes are logged

### Mockup (ADO comment)
- Request page — rate card change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0009&as=hala.mahmoud@shedrive.app
- Pricing & zones: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-zones.html

---

## [Admin] #6565 — Approval cycle — Commission change 🆕
**Feature:** #1755 Admin — Pricing & Rate Management | **Sprint:** Sprint 6 | **Tag:** Approval

**Description:** As a Financial lead, I want a commission change to wait for another Financial lead's approval so that SheDrive's share never changes on one person's say.

### Rules
- Saving the commission on Global policies, Pricing tab (#1759, #6486) creates a request. Only a Financial lead makes it. Subject: platform commission.
- Pending notice: "Commission change to {pct} awaiting approval" / "تغيير العمولة إلى {pct} بانتظار الموافقة" with a link to the request page; the field is locked and the current rate stays in force.
- Only one request can be pending for the commission; another is refused: "A change is already awaiting approval".
- Saving the Pricing tab with both commission and cancellation policy changed sends two requests, one per card.

### Request page
| Block | Shows |
|---|---|
| Request details | Platform commission, created by, status |
| Before → After | Commission (%) |
| Where it applies | Setting, Global policies tab (Pricing — links to it), "To trips completed after it is approved." |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- The new commission is saved and applies from then on.
- Reject: the commission stays; the field is unlocked.

### Acceptance Criteria
**Scenario 1 — Rejected**
- Given a commission change from 18% to 20% is pending
- When the checker rejects it with "Stays at 18% until the quarterly review"
- Then commission stays 18% and the reason shows on the decided request

**Scenario 2 — Approved**
- Given Hala requested 18% → 19%
- When Nour approves it
- Then commission is 19%

### Dependencies
- #5617 — Approvals and the request page
- #1759 — Global policies

### Mockup (ADO comment)
- Request page — commission change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0021&as=nour.hassan@shedrive.app
- Rejected commission change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0008
- Global policies, Pricing tab: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=fin_lead&tab=pricing

---

## [Admin] #6566 — Approval cycle — Cancellation policy change 🆕
**Feature:** #1755 Admin — Pricing & Rate Management | **Sprint:** Sprint 6 | **Tag:** Approval

**Description:** As a Financial lead, I want a cancellation policy change to wait for another Financial lead's approval so that what riders and drivers are charged never changes on one person's say.

### Rules
- Saving the Cancellation policy card on Global policies, Pricing tab (#1759, #6486) creates one request for the whole card. Only a Financial lead makes it. Subject: cancellation policy.
- Pending notice: "Cancellation policy change awaiting approval" / "تغيير سياسة الإلغاء بانتظار الموافقة" with a link to the request page; the card is locked.
- Only one request can be pending for the cancellation policy; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Cancellation policy, created by, status |
| Before → After | The changed ones of: rider grace period, cancellation fee, driver cancellation fee, driver grace period, rider no-show wait |
| Where it applies | Setting, Global policies tab (Pricing — links to it), "To trips requested after it is approved." |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- The policy is saved and applies to new trips.
- Reject: the policy stays; the card is unlocked.

### Acceptance Criteria
**Scenario 1 — Fee waits**
- Given the driver cancellation fee is 20 EGP
- When Hala saves 25
- Then drivers are still charged 20 until another Financial lead approves

**Scenario 2 — Approved**
- When Nour approves it
- Then cancellations on new trips charge the driver 25

### Dependencies
- #5617 — Approvals and the request page
- #1759 — Global policies

### Mockup (ADO comment)
- Request page — cancellation policy change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0022&as=hala.mahmoud@shedrive.app
- Global policies, Pricing tab: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=fin_lead&tab=pricing

---

## [Admin] #6567 — Approval cycle — Balance limit change 🆕
**Feature:** #1755 Admin — Pricing & Rate Management | **Sprint:** Sprint 6 | **Tag:** Approval

**Description:** As a Financial lead, I want a driver balance limit change to wait for another Financial lead's approval so that who may go online never changes on one person's say.

### Rules
- Saving the driver balance limit on Global policies, Finance tab (#3994, #6486) creates a request. Only a Financial lead makes it. Subject: driver balance limit.
- Pending notice: "Balance limit change to {limit} awaiting approval" / "تغيير حد الرصيد إلى {limit} بانتظار الموافقة" with a link to the request page; the field is locked.
- Only one request can be pending for the balance limit; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Driver balance limit, created by, status |
| Before → After | Balance limit (EGP) |
| Where it applies | Setting, Global policies tab (Finance — links to it), "At once: drivers under the new limit can go online, drivers over it cannot." |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- The new limit is saved; go-online blocks follow it (#3994).
- Reject: the limit stays; the field is unlocked.

### Acceptance Criteria
**Scenario 1 — Approved**
- Given the limit is 500 EGP and a driver owes 550 EGP
- When a change to 600 EGP is approved
- Then she is under the limit and can go online

**Scenario 2 — Rejected**
- When it is rejected
- Then the limit stays 500 EGP and she stays blocked

### Dependencies
- #5617 — Approvals and the request page
- #3994 — Driver balance limit

### Mockup (ADO comment)
- Request page — balance limit change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0023&as=hala.mahmoud@shedrive.app
- Global policies, Finance tab: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=fin_lead&tab=finance

---

## [Admin] #6568 — Approval cycle — Payout settings change 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Approval, Payout

**Description:** As a Financial lead, I want a payout settings change to wait for another Financial lead's approval so that the minimum payout and the transfer fee never change on one person's say.

### Rules
- Saving the Payouts card on Global policies, Finance tab (#6486) creates a request. Only a Financial lead makes it. Subject: payout settings.
- Pending notice: "Payout settings change awaiting approval" / "تغيير إعدادات المدفوعات بانتظار الموافقة" with a link to the request page; the card is locked.
- Only one request can be pending for the payout settings; another is refused: "A change is already awaiting approval".

### Request page
| Block | Shows |
|---|---|
| Request details | Payout settings, created by, status |
| Before → After | The changed ones of: minimum payout, transfer fee (%), fee minimum, fee maximum, who pays it |
| Where it applies | Setting, Global policies tab (Finance — links to it), "To the next payout batch generated. Batches already generated keep their own settings." |

### What approving does
- **Approve** only asks her to confirm. **Reject** needs a reason, and the reason shows on the request page.
- The settings apply to the next batch generated, whatever its method; a batch generated before keeps its own.
- Reject: the settings stay; the card is unlocked.

### Acceptance Criteria
**Scenario 1 — Approved**
- Given Hala sets the minimum payout to 150.00 EGP and SheDrive as the fee payer
- When Nour approves it
- Then the next batch leaves out drivers due under 150.00 and sends each driver her full amount

**Scenario 2 — Rejected**
- When Nour rejects it
- Then batches keep the 100.00 minimum and the driver pays the fee

### Dependencies
- #5617 — Approvals and the request page
- #6486 — Admin sets the minimum payout and the transfer fee

### Mockup (ADO comment)
- Request page — payout settings change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approval-request.html?id=APR-0024&as=nour.hassan@shedrive.app
- Global policies, Finance tab: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=fin_lead&tab=finance

---

## [Admin] #5618 — Admin generates a payout batch 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payout

**Description:** As an admin, I want to generate a payout batch from the earnings that are due so that Finance pays every driver what she is owed in one run.

### Rules
- A payable earning (trip earnings, rider cancellation-fee credit) is on hold for 7 calendar days, then due.
- Cut-off line: a batch takes earnings up to the end of the day 7 days before it is generated (generated 29 Oct → up to the end of 22 Oct). Later earnings stay on hold. The preview and the batch show it.
- An admin generates a batch by hand on working days. No automatic run.
- One line per driver whose due earnings net above 0 and whose whole balance is positive.
- Line amount = her due net up to the cut-off, not capped by her balance. This leaves her balance.
- A driver due less than the minimum payout isn't in the batch or the preview at all; her earnings stay Due for a later batch.
- Every line carries a transfer fee: a percentage of the line, never below the fee minimum or above the fee maximum, paid by the driver or by SheDrive.
- Minimum, fee and payer come from the payout settings (#6486). A batch keeps the settings it was generated with.
- Earnings in a batch can't be picked up by another batch.
- Statuses: Ready to export → Sent to bank → Result pending approval → Completed (#5619).
- Reference: PB-YYYYMMDD-nn.
- Generate payout batch is on the Payouts page; the page itself — its cards and the list of batches — is #6497.

### Acceptance Criteria
**Scenario 1 — Preview before generating**
- Given three drivers have due earnings and one of them owes SheDrive 40.00 EGP overall
- When the admin chooses Generate payout batch
- Then the preview lists two lines with their amount, transfer fee and the amount sent to her, the totals, and how many files the batch makes per payout method; the third driver isn't listed

**Scenario 2 — The cut-off line**
- Given today is 29 Oct and a driver earned 120.00 EGP on 22 Oct and 80.00 EGP on 23 Oct
- Then the preview reads "Cut-off: earnings up to the end of 22 Oct 2026 (7 days ago)", her line is 120.00 EGP, and the 80.00 EGP stays on hold

**Scenario 3 — Not capped by her balance**
- Given a driver is due 300.00 EGP up to the cut-off and her whole balance is 180.00 EGP
- Then her line is 300.00 EGP

**Scenario 4 — Below the minimum**
- Given the minimum payout is 100.00 EGP and a driver's line would be 60.00 EGP
- Then she isn't in the batch or the preview at all — no count or note — and her earnings stay Due

**Scenario 5 — Transfer fee paid by the driver**
- Given the transfer fee is 1.5% (minimum 3.00 EGP, maximum 20.00 EGP), paid by the driver
- And a driver's line is 250.50 EGP
- Then her line shows 250.50 EGP, fee −3.76 EGP, sent to her 246.74 EGP
- And a 140.00 EGP line pays the 3.00 EGP minimum fee, and a 2,000.00 EGP line the 20.00 EGP maximum

**Scenario 6 — Transfer fee paid by SheDrive**
- Given the same fee, paid by SheDrive
- Then the same driver is sent 250.50 EGP

**Scenario 7 — Generate**
- When the admin confirms
- Then the batch is created as Ready to export, no approval request is made, and the admin lands on the batch

**Scenario 8 — Nothing due**
- Given no driver has a due amount at or above the minimum
- Then the preview says so and Generate is disabled

### Out of Scope
- Excluding a single driver from a batch by hand
- Holiday calendars
- A different fee per payout method

### Dependencies
- #6486 Admin sets the minimum payout and the transfer fee
- #6497 Admin views the payout history
- #5619 Bank files and results
- #5625 Driver payout method
- #4378 — Driver ledger (payable entries)

### Mockup (ADO comment)
- Payouts (generate a batch here): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html


---

## [Admin] #6570 — Financial officer chooses the payout method before generating a batch 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payout

**Description:** As a Financial officer, I want to choose the payout method first and generate a batch for that method only so that each batch has one bank file and one result to follow.

### Rules
- **Generate payout batch** opens on a method choice. The preview and the batch (#5618) then cover the chosen method only.
- Three cards, in this order:

| Card | Shows | When no driver is due |
|---|---|---|
| Mobile wallet / محفظة إلكترونية | Drivers due: n · amount due | "No driver due" / "لا توجد سائقة مستحقة"; the card can't be picked |
| Bank account / حساب بنكي | Drivers due: n · amount due | Same |
| Prepaid card / بطاقة مسبقة الدفع | Drivers due: n · amount due | Same |

- A card also shows "Open batch: {ref}" / "دفعة مفتوحة: {ref}" while a batch of that method is not Completed.
- Drivers due and amounts follow the #5618 rules (cut-off, minimum payout, drivers who owe left out), counted per driver's current payout method.
- The preview's subtitle names the method: "Bank account — drivers in this batch: 2 — total 408.54 EGP".
- The preview table has no Payout type column. Its columns follow that method's bank file:

| Method | Columns |
|---|---|
| Mobile wallet | Driver, Wallet provider, Wallet number, Amount, Transfer fee, Sent to her |
| Bank account | Driver, Bank, Account number, Amount, Transfer fee, Sent to her |
| Prepaid card | Driver, Card number, Amount, Transfer fee, Sent to her |

- **Change method** goes back to the cards; nothing is generated.
- A batch keeps its method for life: one bank file (#5619), one result, one approval (#6559).
- The batch page shows the method under Status.
- The Payouts list (#6497) gets a **Payout method** column and a Payout method filter (All methods / the three methods). Export CSV adds a Payout method column after Batch ref.

### Acceptance Criteria
**Scenario 1 — Choose the method**
- Given 1 wallet driver is due 339.94 EGP, 2 bank drivers 408.54 EGP and 1 card driver 282.67 EGP
- When a Financial officer chooses Generate payout batch
- Then she sees the three cards with those counts and amounts, and no batch preview yet

**Scenario 2 — One method only**
- When she picks Bank account
- Then the preview lists only the 2 bank drivers with Bank and Account number columns, and Generate makes batch PB-… with one bank-account file

**Scenario 3 — Nothing due on a method**
- Given no prepaid-card driver is due
- Then the Prepaid card card reads "No driver due" and can't be picked

**Scenario 4 — Filter the history by method**
- When she filters Payouts by Mobile wallet
- Then only mobile wallet batches are listed, and Export CSV downloads only those

### Out of Scope
- One batch for several methods
- Moving a driver's line to another method's batch

### Dependencies
- #5618 Admin generates a payout batch (built — this story changes its preview)
- #6497 Admin views the payout history (built — this story adds the method column and filter)
- #5619 Bank file and result
- #5625 Driver payout method

### Mockup (ADO comment)
- Payouts — choose Generate payout batch: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html?as=fin_officer
- Payouts filtered by method: pick Payout method in the filter row on the page above
---

## [Admin] #6497 — Admin views the payout history 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payouts & settlement

**Description:** As a Financial officer or lead, I want to see every payout batch and where the money stands so that I know what is due, what is with the bank and what was paid.

### Rules
- **Payouts** (Finance in the sidebar) shows three cards on top, then the list of batches. Generate payout batch sits on the title row (#5618).
- Financial officer and Financial lead only (#6483, #6484). Nothing on this page moves money.

| Card | Shows | Sub-line |
|---|---|---|
| Due now / مستحق الآن | What a batch generated now would pay, by the same rules as #5618 (cut-off, minimum, drivers who owe left out) | Drivers due: n / السائقات المستحقات: n |
| In open batches / في دفعات مفتوحة | Total of the batches Sent to bank or Result pending approval | Sent to bank, awaiting the result / أُرسلت إلى البنك وبانتظار النتيجة |
| Paid this month / مدفوع هذا الشهر | Paid lines of the batches completed this calendar month (Cairo time) | Lines paid: n / البنود المدفوعة: n |

- The batch ref and the View action open the batch (#5619).
- Export CSV downloads the filtered list: Batch ref, Created, Created by, Lines, Total (EGP), Paid lines, Failed lines, Status. File name `shedrive-payout-batches-YYYY-MM-DD.csv`.
- No batches: "No payout batches" / "لا توجد دفعات مدفوعات" — "Generate a batch when drivers have earnings past their 7-day hold." / "أنشئ دفعة عندما تكون لدى السائقات أرباح تجاوزت فترة الانتظار ٧ أيام."

### List / Grid Specification
**Page size:** 20 · **Default sort:** Created — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| Batch ref (links to the batch) | No | No | — |
| Created at / by | Yes | No | — |
| Lines | Yes | No | — |
| Total (EGP) | Yes | No | — |
| Paid / Failed (paid in green, failed in red) | No | No | — |
| Status | No | Yes | Dropdown (All / Ready to export / Sent to bank / Result pending approval / Completed) |
| Actions (View — approved files only) | No | No | — |

### Acceptance Criteria
**Scenario 1 — The cards**
- Given four drivers are due 1,031.15 EGP up to the cut-off, one batch is Sent to bank with 912.40 EGP, and a batch completed this month paid 9 lines totalling 2,140.00 EGP
- When the admin opens Payouts
- Then the cards read Due now 1,031.15 EGP (Drivers due: 4), In open batches 912.40 EGP, Paid this month 2,140.00 EGP (Lines paid: 9)

**Scenario 2 — Filter by status**
- When she picks Sent to bank
- Then only batches Sent to bank are listed, and Export CSV downloads only those

**Scenario 3 — Open a batch**
- When she clicks a batch ref or View
- Then the batch opens with its bank files and results (#5619)

**Scenario 4 — No batches yet**
- Given no batch was ever generated
- Then the list shows "No payout batches" and the cards still show what is due

### Out of Scope
- Charts or trends over time
- Filtering by date or by driver

### Dependencies
- #5618 Admin generates a payout batch
- #5619 Bank files and results
- #6483, #6484 — Financial officer and Financial lead

### Mockup (ADO comment)
- Payouts: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html?as=fin_lead
- No batches: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html?as=fin_lead&state=empty
- Error: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html?as=fin_lead&state=error

---

## [Admin] #5619 — Financial officer exports a payout batch's bank file and imports its result 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payout

**Description:** As a Financial officer, I want to export a batch as its channel's bulk-transfer file and import the result the channel sends back so that a driver is marked paid only when her transfer is confirmed.

### Rules
- A batch pays one payout method (#6570), so it has **one bank file** and **one result file**.
- Exporting a **Ready to export** batch downloads its file and moves the batch to Sent to bank.
- The file can be downloaded again; a copy changes nothing.
- earnings_egp leaves her balance; transfer_fee_egp and fee_paid_by come from the batch's payout settings (#6486); amount_egp is what the channel sends. Account and card numbers are in full.
- The result file is matched on line_ref. An imported result goes to approval (#6559 Approval cycle — Payout result).
- Batch status: Ready to export → Sent to bank → Result pending approval → Completed.
- A line_ref can never be paid twice.

### File templates
The three templates are attached to this story and to #5618: `payout-template-mobile-wallet.csv`, `payout-template-bank-account.csv`, `payout-template-prepaid-card.csv` (header row plus one example line each). Source: `docs/backlog/payout-templates/`. A batch uses the template of its method.

**Mobile wallet** — `<batch ref>-mobile-wallet.csv`

| Column | Content | Example |
|---|---|---|
| batch_ref | Batch reference | PB-20261029-08 |
| line_ref | Line reference, unique | PB-20261029-08-0003 |
| national_id | 14 digits | 28291037053102 |
| driver_name | Full name | Laila Fathy |
| phone | Her mobile number | 01262626151 |
| wallet_provider | Vodafone Cash / Orange Cash / e& money / WE Pay | Vodafone Cash |
| wallet_number | 01 + 9 digits | 01262626151 |
| account_holder | Name on the wallet | Laila Fathy |
| earnings_egp | What leaves her balance | 250.50 |
| transfer_fee_egp | The fee for this transfer: its percentage, held between the fee minimum and maximum | 3.76 |
| fee_paid_by | DRIVER or SHEDRIVE | DRIVER |
| amount_egp | What is sent to her | 246.74 |

**Bank account** — `<batch ref>-bank-account.csv`

| Column | Content | Example |
|---|---|---|
| batch_ref | Batch reference | PB-20261029-08 |
| line_ref | Line reference, unique | PB-20261029-08-0001 |
| national_id | 14 digits | 28897381418151 |
| driver_name | Full name | Nada El-Sayed |
| phone | Her mobile number | 01149222929 |
| bank_name | From the bank list | National Bank of Egypt |
| account_number | 10–20 digits, or IBAN EG + 27 digits | EG248392193762161230469282293 |
| account_holder | Account holder name | Nada El-Sayed |
| earnings_egp | What leaves her balance | 140.00 |
| transfer_fee_egp | The fee for this transfer: its percentage, held between the fee minimum and maximum | 3.00 |
| fee_paid_by | DRIVER or SHEDRIVE | DRIVER |
| amount_egp | What is sent to her | 137.00 |

**Prepaid card** — `<batch ref>-prepaid-card.csv`

| Column | Content | Example |
|---|---|---|
| batch_ref | Batch reference | PB-20261029-08 |
| line_ref | Line reference, unique | PB-20261029-08-0002 |
| national_id | 14 digits | 30094955329783 |
| driver_name | Full name | Jana Adel |
| phone | Her mobile number | 01064090123 |
| card_number | 16 digits | 5078589101662031 |
| card_holder | Name on the card | Jana Adel |
| earnings_egp | What leaves her balance | 195.25 |
| transfer_fee_egp | The fee for this transfer: its percentage, held between the fee minimum and maximum | 3.00 |
| fee_paid_by | DRIVER or SHEDRIVE | DRIVER |
| amount_egp | What is sent to her | 192.25 |

**Result file** — the same columns as the file it answers, plus:

| Column | Content | Example |
|---|---|---|
| status | SUCCESS or FAILED | FAILED |
| bank_reference | The channel's reference for a SUCCESS line | BNK48213377 |
| failure_reason | Why a FAILED line failed | Wallet number not registered |

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Result file | Yes | File (.csv) | Columns `line_ref` and `status` present; every line of the batch exactly once; status `SUCCESS` or `FAILED` | — | — | none | Choose the result file / اختر ملف النتيجة | Missing column: {column} / عمود ناقص: {column} | Line {line} is missing, repeated or not in this batch / البند {line} ناقص أو مكرر أو ليس في هذه الدفعة |

### Acceptance Criteria
**Scenario 1 — Export**
- Given a bank-account batch PB-20261104-11 is Ready to export with 3 lines
- When a Financial officer exports it
- Then `PB-20261104-11-bank-account.csv` downloads with each driver's phone number, and the batch shows Sent to bank with who exported it and when

**Scenario 2 — Import a result with a failure**
- Given a wallet batch's result marks 3 lines SUCCESS and 1 FAILED "Wallet number not registered"
- When a Financial officer imports it
- Then the batch is Result pending approval with a link to its request (#6559), and nothing is paid yet

**Scenario 3 — Result doesn't match the batch**
- Given a result file leaves one line out and repeats another
- Then the import is refused with both lines named, and nothing changes

**Scenario 4 — Rejected result**
- Given the result request is rejected
- Then the batch is Sent to bank again with the reason shown, and a corrected file can be imported

### Out of Scope
- Sending the file to the bank or wallet channel automatically (Finance uploads it on the channel's portal)

### Dependencies
- #6570 Financial officer chooses the payout method before generating a batch
- #5618 Admin generates a payout batch
- #6486 Payout settings
- #6559 Approval cycle — Payout result
- #5627 Driver sees the payout status of her earnings

### Mockup (ADO comment)
- Payouts — open a batch marked Ready to export or Sent to bank: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html?as=fin_officer
- Batch not found: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payout-batch.html?id=unknown

---

## [Admin] #6486 — Financial lead sets the minimum payout and the transfer fee 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payout

**Description:** As a Financial lead, I want to set the minimum payout, the transfer fee as a percentage with a minimum and a maximum, and who pays it so that small payouts wait and the transfer cost lands where we decide.

### Rules
- Global policies has three tabs, one per owner, each with its own Save and Revert:

| Tab | Cards | Who changes it | When a change applies |
|---|---|---|---|
| Pricing | Cancellation policy, platform commission (#1759) | Financial lead | After another Financial lead approves |
| Finance | Driver balance limit (#3994), Payouts | Financial lead | After another Financial lead approves |
| Operations | Operating hours (#6268) | Operations lead | On save |

- Save and Revert act on the open tab only; unsaved edits on another tab stay. A tab a role can't change is read-only, with no Save. The page opens on the first tab the role can change; `?tab=pricing|finance|operations` opens a tab, and a request's link opens the tab its setting is on.
- The Finance tab gets a **Payouts** card:

| Setting | Default |
|---|---|
| Minimum payout (EGP) | 100.00 |
| Transfer fee (% of each payout), same for every payout method | 1.5% |
| Transfer fee — minimum (EGP) | 3.00 |
| Transfer fee — maximum (EGP) | 20.00 |
| Who pays the fee: the driver or SheDrive | The driver |

- Fee on a payout = its percentage of the payout, raised to the minimum when below it and cut to the maximum when above it, to 2 decimals (1.5%: 250.50 → 3.76; 140.00 → 3.00; 2,000.00 → 20.00).
- Driver pays: the fee comes off what she is sent. SheDrive pays: she gets her full amount.
- A change goes through approval (#6568 Approval cycle — Payout settings change), in the Payouts & settlements area filter.
- The card shows a worked example for a 500.00 EGP payout and when it was last changed and by whom.

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Minimum payout | Yes | Number, 2 decimals (EGP) | 0–100,000; more than the fee on it when the driver pays the fee | 0 | 100,000 | 100.00 | Enter the minimum payout / أدخل الحد الأدنى للصرف | Enter a valid amount / أدخلي مبلغًا صحيحًا | Must be between 0 and 100,000 EGP / يجب أن تكون القيمة بين 0 و100,000 جنيه · When the driver pays the fee, the minimum payout must be more than the fee on it / عندما تدفع السائقة الرسوم، يجب أن يكون الحد الأدنى للصرف أكبر من الرسوم عليه |
| Transfer fee (%) | Yes | Number, 2 decimals (%) | 0–100 | 0 | 100 | 1.5 | Enter the transfer fee percentage / أدخل نسبة رسوم التحويل | Enter a valid amount / أدخلي مبلغًا صحيحًا | Must be between 0% and 100% / يجب أن تكون النسبة بين 0% و100% |
| Transfer fee — minimum | Yes | Number, 2 decimals (EGP) | 0–1,000 | 0 | 1,000 | 3.00 | Enter the minimum fee / أدخل الحد الأدنى للرسوم | Enter a valid amount / أدخلي مبلغًا صحيحًا | Must be between 0 and 1,000 EGP / يجب أن تكون القيمة بين 0 و1,000 جنيه |
| Transfer fee — maximum | Yes | Number, 2 decimals (EGP) | 0–1,000; not below the fee minimum | 0 | 1,000 | 20.00 | Enter the maximum fee / أدخل الحد الأقصى للرسوم | Enter a valid amount / أدخلي مبلغًا صحيحًا | Must be between 0 and 1,000 EGP / يجب أن تكون القيمة بين 0 و1,000 جنيه · The maximum fee can’t be below the minimum fee / لا يمكن أن يكون الحد الأقصى للرسوم أقل من الحد الأدنى |
| Transfer fee paid by | Yes | Dropdown | The driver / السائقة · SheDrive / شي درايف | — | — | The driver | — | — | — |

### Acceptance Criteria
**Scenario 1 — SheDrive takes over the fee**
- Given the fee is 1.5% (minimum 3.00, maximum 20.00 EGP), paid by the driver
- When Hala sets SheDrive as the payer and saves
- Then a payout settings change is pending, the card is locked, and batches still take the fee from the driver until another Financial lead approves

**Scenario 2 — Approved**
- When Nour approves it
- Then the next batch sends a driver due 250.50 EGP the full 250.50 EGP, and a batch generated before stays as it was

**Scenario 3 — Minimum not above the fee**
- Given the driver pays the fee and its minimum is 3.00 EGP
- When the minimum payout is set to 3.00 EGP
- Then the minimum payout shows "When the driver pays the fee, the minimum payout must be more than the fee on it" and nothing is sent

**Scenario 4 — Maximum below minimum**
- When the fee minimum is 10.00 EGP and the maximum 8.00 EGP
- Then the maximum shows "The maximum fee can’t be below the minimum fee" and nothing is sent

**Scenario 5 — Not a Financial lead**
- When a Financial officer opens Global policies
- Then the Payouts card is read-only

**Scenario 6 — One tab saves alone**
- Given Hala changed the commission on Pricing and the minimum payout on Finance, and is on Finance
- When she saves
- Then only a payout settings change is sent for approval, and her commission edit stays on Pricing unsaved

**Scenario 7 — Opens on her tab**
- When the Operations lead opens Global policies
- Then the Operations tab is open with Save; Pricing and Finance are read-only

### Out of Scope
- A different fee or minimum per payout method
- A flat fee plus a percentage

### Dependencies
- #5618 Admin generates a payout batch
- #5619 Bank files and results
- #6568 — Approval cycle — Payout settings change

### Mockup (ADO comment)
- Global policies — Finance tab, Payouts card: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=fin_lead&tab=finance
- Review a payout settings change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approvals.html?id=APR-0024

---

## [Admin] #5620 — Financial officer imports Finance's settlement sheet 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Settlement

**Description:** As a Financial officer, I want to import the sheet of drivers who paid SheDrive so that their balances are settled in one go instead of one at a time.

### Rules
- **Import settlement** on the settlements history (#6492) opens a wizard: 1 Download template → 2 Upload sheet → 3 Review result. Back returns one step; no step can be skipped.
- Step 1 offers the CSV template and shows how each of its seven columns is written (Field Validation).
- Step 2 checks only the template and format (Field Validation).
- Step 2 never lists cell errors on screen. **Download the file with errors** returns her sheet with an `errors` column naming every cell to fix on each wrong row (`column: what is wrong`, joined by ` | `). She fixes it and uploads it again; the `errors` column is ignored.
- Problems with the file itself (type, size, columns, row count) belong to no row, so the step 2 alert names them and no errors file is offered.
- Step 3 checks each row against SheDrive's data (Business Rules) and shows Passed or why it failed.
- One failed row rejects the whole file. **Download the file with errors** returns her sheet with an `errors` column holding each failed row's reason (passed rows left blank). She fixes those rows or deletes them, then uploads the file again from step 2; the `errors` column is ignored.
- The sheet lists only payments already made. Rows match drivers by national ID, and the phone number must be the one registered to that driver (Business Rules). The name is for reference only.
- Any amount is applied. Paying more adds the extra to her balance, so SheDrive owes her.
- Each passed row shows her balance now and after, and the outcome: Settled in full, Part paid — still owes X, or Paid more — X added to her balance.
- **Send file for approval** sends the whole file as one request (#6560 Approval cycle — Settlement import). It then appears in the history (#6492).

### Field Validation (step 2 — template and format)
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Settlement sheet | Yes | File (.csv) | A .csv file | — | 5 MB | none | Choose the settlement sheet / اختر ملف التسويات | The file must be a .csv file / يجب أن يكون الملف بصيغة ‎.csv | The file is larger than 5 MB / حجم الملف أكبر من ٥ ميجابايت |
| Template columns | Yes | Header row | Exactly the seven template columns, each once; an `errors` column from an errors file is ignored | 7 | 7 | — | Missing column: {column} / عمود ناقص: {column} | Column not in the template: {column} / عمود غير موجود في النموذج: {column} · Column appears twice: {column} / عمود مكرر: {column} | — |
| Rows | Yes | CSV rows, seven cells each | — | 1 | 1,000 | — | The sheet has no rows / الملف لا يحتوي على صفوف | The row does not have seven cells / الصف لا يحتوي على سبع خلايا | The sheet has {n} rows; a sheet can have up to 1,000 / الملف به {n} صفًا؛ الحد الأقصى ١٬٠٠٠ صف |
| national_id | Yes | Digits only | 14 digits | 14 | 14 | — | Required — the cell is empty / مطلوب — الخلية فارغة | Must be 14 digits / يجب أن يكون ١٤ رقمًا | Must be 14 digits / يجب أن يكون ١٤ رقمًا |
| phone_number | Yes | Digits only | Egyptian mobile: 11 digits starting 010, 011, 012 or 015 (matched against the driver in step 3) | 11 | 11 | — | Required — the cell is empty / مطلوب — الخلية فارغة | Must be an Egyptian mobile number: 11 digits starting 010, 011, 012 or 015 / يجب أن يكون رقم موبايل مصري: ١١ رقمًا يبدأ بـ 010 أو 011 أو 012 أو 015 | Must be an Egyptian mobile number: 11 digits starting 010, 011, 012 or 015 / يجب أن يكون رقم موبايل مصري: ١١ رقمًا يبدأ بـ 010 أو 011 أو 012 أو 015 |
| driver_name | No | Free text | Any characters (reference only) | — | 100 chars | empty | — | — | Must be 100 characters or fewer / يجب ألا يزيد عن ١٠٠ حرف |
| amount_egp | Yes | Decimal (EGP), up to 2 decimals | A plain number, no currency or thousands separator (245.50) | 0.01 | — | — | Required — the cell is empty / مطلوب — الخلية فارغة | Must be a number with up to 2 decimals, no currency or commas / يجب أن يكون رقمًا بحد أقصى خانتين عشريتين، بدون عملة أو فواصل | Must be more than 0 / يجب أن يكون أكبر من صفر |
| payment_date | Yes | Date (YYYY-MM-DD) | A real calendar date | — | — | — | Required — the cell is empty / مطلوب — الخلية فارغة | Must be a real date written YYYY-MM-DD / يجب أن يكون تاريخًا صحيحًا بصيغة YYYY-MM-DD | — |
| payment_channel | Yes | Text, exact spelling | Bank transfer, Fawry, Mobile wallet, Field agent | — | — | — | Required — the cell is empty / مطلوب — الخلية فارغة | Must be Bank transfer, Fawry, Mobile wallet or Field agent / يجب أن يكون Bank transfer أو Fawry أو Mobile wallet أو Field agent | — |
| payment_reference | Yes | Letters, digits, hyphen | — | 1 char | 60 chars | — | Required — the cell is empty / مطلوب — الخلية فارغة | Must be 1–60 letters, digits or hyphens / يجب أن يكون من ١ إلى ٦٠ حرفًا أو رقمًا أو شرطة | Must be 1–60 letters, digits or hyphens / يجب أن يكون من ١ إلى ٦٠ حرفًا أو رقمًا أو شرطة |

### Business Rules (step 3 — any failure rejects the whole file)
| Rule | Row fails when | Row result |
|---|---|---|
| Registered driver | `national_id` matches no driver | No driver with this national ID / لا توجد سائقة بهذا الرقم القومي |
| Phone matches the driver | `phone_number` is not the registered phone of the driver found by `national_id` | Phone number doesn't match this driver / رقم الموبايل لا يطابق هذه السائقة |
| Payment not imported before | `payment_reference` is on an approved import or a file awaiting approval | Already imported / تم استيراده من قبل |
| Reference unique in the file | `payment_reference` appeared on an earlier row of the same file | Payment reference repeated in this file / مرجع السداد مكرر في هذا الملف |
| Payment already made | `payment_date` is after today | Payment date is in the future / تاريخ السداد في المستقبل |

File result when any row fails: *File rejected — {n} rows failed the business check* / *الملف مرفوض — فشل {n} صفوف في فحص قواعد العمل*.

### Acceptance Criteria
**Scenario 1 — Format errors come back in the file**
- Given a file of four rows with `102.08 EGP` as an amount and `1596961055` as a phone on row 1, `29/10/2026` as a date on row 2, a 12-digit national ID on row 3 and `Cash` as the channel on row 4
- When a Financial officer uploads it
- Then step 2 says *The file has errors in 4 rows*, lists no cell errors on screen, Next is unavailable and nothing is checked against drivers
- When she downloads the file with errors
- Then it is her sheet with an `errors` column: row 1 reads `phone_number: Must be an Egyptian mobile number… | amount_egp: Must be a number with up to 2 decimals…`, and rows 2–4 each name their one cell

**Scenario 2 — Re-upload the corrected errors file**
- Given she fixes those cells and leaves the `errors` column in the file
- When she uploads it again
- Then step 2 passes and Next opens step 3

**Scenario 3 — Wrong template**
- Given the file has no `payment_reference` column, or an extra `notes` column
- Then the step 2 alert names the column, no errors file is offered and no row is checked

**Scenario 4 — One business error rejects the whole file**
- Given a well-formed file of eight rows where four pass, one has an unknown national ID, one repeats a reference imported last week, one is dated tomorrow and one has a phone that isn't the driver's
- When the Financial officer reaches step 3
- Then each row shows *Passed* or its reason, the file shows *File rejected — 4 rows failed*, it can't be sent, and nothing is stored
- When she downloads the file with errors
- Then it is her eight-row sheet with an `errors` column: rows 5–8 read *No driver with this national ID*, *Already imported*, *Payment date is in the future* and *Phone number doesn't match this driver*; rows 1–4 are blank

**Scenario 5 — Fix or delete the failed rows and upload again**
- Given she deletes the unknown-driver and already-imported rows, fixes the date and the phone, and leaves the `errors` column in the file
- When she uploads it again
- Then step 2 passes and step 3 accepts the six-row file

**Scenario 6 — Send an accepted file and approve**
- Given a file where one driver pays exactly the 102.08 EGP she owes, one pays 42.00 of 84.22, one pays 50.00 more than she owes and one pays 75.00 while owing nothing
- Then step 3 shows *Settled in full*, *Part paid — still owes 42.22*, *Paid more — 50.00 added*, *Paid more — 75.00 added*
- When the Financial officer sends the file and a Financial lead approves
- Then four settlement entries are posted with receipt numbers

**Scenario 7 — Same driver twice**
- Given two rows for the same driver, 40.00 and 60.00, and she owes 100.00
- Then the first shows *Part paid — still owes 60.00* and the second *Settled in full*

### Out of Scope
- Reading bank statements directly
- Editing a row on screen (Finance corrects the sheet)
- Sending only the rows that passed
- The settlements history and an import's detail (#6492)

### Dependencies
- #6492 — Financial officer views the settlements history (where the wizard opens and the sent file appears)
- #4379 — Admin records a driver settlement (same ledger entry and receipt)
- #3996 — Go-online block lifts on settlement
- #6560 — Approval cycle — Settlement import

### Mockup (ADO comment)
- Step 1: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?step=1&as=fin_officer
- Step 2, file with errors (download it from the alert): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?step=2&sample=format&as=fin_officer
- Step 3, file rejected (download it from the alert): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?step=3&sample=business&as=fin_officer
- Step 3, ready to send: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?step=3&sample=clean&as=fin_officer
- Pending import review: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approvals.html?id=APR-0018

---

## [Admin] #6492 — Financial officer views the settlements history 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Settlement

**Description:** As a Financial officer, I want to see every settlement file sent for approval and what each one settled so that I can follow a file from upload to receipt numbers.

### Rules
- The Settlement imports screen opens on the **settlements history**: every file sent for approval (#5620), newest first. Financial officers and Financial leads open it (#6483, #6484).
- Each file shows its ID, file name, who uploaded it and when, its rows, its amount, its status (*Pending approval*, *Approved*, *Rejected*) and who decided and when. A file is always sent whole (#5620), so its rows are all the rows in the file.
- The history is filtered by **status** (All, Pending approval, Approved, Rejected) and by the **date the file was uploaded** (from / to, both days included). **Reset** clears both. When no file matches, the history shows *No files match*.
- **View** is offered on approved files only. A pending file is read in its approval request (#5617); a rejected file has nothing to view. Another import is a new one, started with **Import settlement**.
- **View** opens the file's own page: file ID, file name, status, uploaded by / at, approved by / at, rows, amount and its approval request; the counts of rows settled in full, part paid and paid more; and every row — row, driver (name in the system, phone, national ID), amount, balance before, balance after, payment reference with date and channel, and what the row does to her balance (as step 3 of #5620 showed it).
- The rows can be searched by driver, national ID, phone, payment reference or receipt, and filtered by result. They are paged 10 / 20 / 50.
- The page says who approved it and when, and each row shows its receipt number (`S-nnnnn`).
- **Download the file** gives the rows as sent, in the template's seven columns.
- The page has its own link (`?id=IMP-nnnn`). An ID that matches no file, or a file that is not approved, shows *Settlement import not found*.
- Nothing in the history or on the page can be edited or deleted.

### List / Grid Specification
**Page size:** 20 · **Default sort:** Uploaded — newest first

| Column | Sortable | Filterable | Filter type |
|---|---|---|---|
| File ID | No | No | — |
| File name | No | No | — |
| Uploaded at / by | Yes | Yes (uploaded date) | Date range (from / to) |
| Rows | No | No | — |
| Amount (EGP) | Yes | No | — |
| Status (Pending approval / Approved / Rejected) | No | Yes | Dropdown — All / Pending approval / Approved / Rejected |
| Decided at / by | Yes | No | — |
| Actions (View — approved files only) | No | No | — |

### Acceptance Criteria
**Scenario 1 — Newest first**
- Given IMP-0003 sent today and awaiting approval, IMP-0002 rejected this week and IMP-0001 approved last week
- When a Financial officer opens Settlement imports
- Then IMP-0003 is first with *Pending approval* and no decision, and the others show their status with who decided and when

**Scenario 3 — Pending and rejected files have no View**
- Given IMP-0003 pending approval and IMP-0002 rejected
- When a Financial officer opens Settlement imports
- Then neither row offers *View*, and IMP-0001 (approved) does

**Scenario 7 — Nothing yet**
- Given no file was ever sent
- Then the history shows *No settlement imports yet*

**Scenario 8 — Filtering by status and date**
- Given IMP-0001 approved, IMP-0002 rejected and IMP-0003 pending approval
- When a Financial officer filters the status to *Approved*
- Then only IMP-0001 shows
- When she clears the status and sets an uploaded date range that holds only the day IMP-0002 was sent
- Then only IMP-0002 shows

**Scenario 9 — No file matches**
- Given a status or date range that no file matches
- Then the history shows *No files match*
- When she selects **Reset**
- Then every file shows again, newest first

### Out of Scope
- Searching the history by text
- Editing, deleting or re-sending a file

### Dependencies
- #5620 — Financial officer imports Finance's settlement sheet (the wizard that sends a file here)
- #5617 Maker-checker approvals
- #6483, #6484 — Financial officer and Financial lead (who opens the screen)

### Mockup (ADO comment, updated 2026-11-04 — history filtered by status and uploaded date; View on approved files only, design #6552)
- Settlements history (Status and Uploaded date filters): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?as=fin_officer
- Approved import with receipts: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-import.html?id=IMP-0001&as=fin_officer
- Import not found (also a pending or rejected file): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-import.html?id=IMP-0002&as=fin_officer
- Empty: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/settlement-imports.html?state=empty&as=fin_officer

---

## [Admin] #5621 — Admin waives a rider's cancellation fee 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Fee waiver

**Description:** As a Financial officer, I want to waive one specific cancellation fee so that a rider isn't charged for a cancellation that wasn't her fault.

### Rules
- A waiver covers one cancellation fee, with a reason. No limit on amount or count.
- Maker-checker: a Financial officer or lead requests it, a Financial lead decides it (#6212).
- The fee is never edited or deleted. Approval adds fee_waived (+fee) on the rider's ledger and fee_credit_reversed (−fee) on the credited driver's. Both point to the original, which stays, marked Waived.
- Already paid: she gets a credit, shown not spent in this phase.
- **Rider balances** gains a Has a credit filter and a Credit column.

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Waiver reason | Yes | Free text (textarea) | Any characters | 10 chars | 500 chars | empty | Give a reason for the waiver / اذكر سبب الإعفاء | — | Reason must be 10–500 characters / يجب أن يكون السبب بين 10 و500 حرف |

### Acceptance Criteria
**Scenario 1 — Waive an unpaid fee**
- Given a rider owes a 20.00 EGP fee for trip T-1042, credited to driver Sara
- When a Financial officer waives it and a Financial lead approves
- Then the rider's ledger still shows the −20.00 fee, now marked Waived, plus a new +20.00 *Fee waived* entry; Sara's ledger keeps her +20.00 credit and gains a −20.00 reversal; the rider owes 0.00

**Scenario 2 — Waive a fee she already paid**
- Given the rider paid that fee on her next trip
- When the waiver is approved
- Then her balance shows a 20.00 EGP credit

**Scenario 3 — Already pending**
- Given a waiver for this fee is awaiting approval
- Then the fee shows "Waiver awaiting approval" and offers no Waive action

### Out of Scope
- Refunding the rider in cash

### Dependencies
- #4005 — Admin reviews rider outstanding fees (the screen this action sits on)
- #5617 Maker-checker approvals
- #5628 Rider sees a credit from a waived fee

### Mockup (ADO comment)
- Rider balances (Waive fee is in the rider ledger): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html

---

## [Admin] #5622 — Driver ledger shows her payout method and where her earnings stand 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payout

**Description:** As a Financial officer, I want a driver's ledger to show her payout method and which earnings are on hold, due, in a batch or sent to the bank so that I can answer her payout questions without opening batches.

> Split 2026-11-04: approving a manual settlement or payout moved to #6561 and #6562.

### Rules
- The driver ledger (#4378) shows her payout method: type, provider or bank, holder and the full number.
- A **Last payout failed** warning shows the reason and links to the batch (#5619).
- Totals above the entries: On hold, Due, In a batch, Sent to bank.
- Each payable earning shows its status: On hold until <date> (7 calendar days, #5618), Due, In a batch, Sent to bank, Paid.

### Acceptance Criteria
**Scenario 1 — Earning statuses**
- Given a trip earning from 3 days ago and one from 10 days ago
- Then the first reads "On hold until <date>" and the second "Due"

**Scenario 2 — Failed payout**
- Given her last payout failed "Account closed"
- Then the ledger shows Last payout failed with that reason and a link to the batch

### Out of Scope
- Changing the payout method from the ledger (#5624)

### Dependencies
- #4378 — Driver ledger
- #5618 — Payout batch
- #5619 — Bank files and results
- #6561 — Approval cycle — Manual settlement
- #6562 — Approval cycle — Manual payout

### Mockup (ADO comment)
- Driver balances: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html

---

## [Admin] #5624 — Financial officer views and edits a driver's payout method 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Payout

**Description:** As a Financial officer, I want to see a driver's payout method and correct it on her behalf so that payouts reach her when she can't fix it herself.

### Rules
- The driver profile and the driver application show the payout method to Finance roles only (#6483, #6484): type, provider or bank, holder name, the full number, and who changed it last (the driver, or the Financial officer or lead by name).
- *Last payout failed* shows with the reason and a link to the batch.
- A Financial officer's or lead's edit uses the same fields and rules as the driver's own form and goes through approval (#6564 Approval cycle — Payout method change). The current method stays until then.

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Payout method | Yes | Single choice | Mobile wallet, Bank account, Prepaid card | — | — | current | Choose a payout method / اختر طريقة استلام الأرباح | — | — |
| Wallet provider | Yes (wallet) | Dropdown | Vodafone Cash, Orange Cash, e& money, WE Pay | — | — | none | Choose the wallet provider / اختر مزوّد المحفظة | — | — |
| Wallet number | Yes (wallet) | Egyptian mobile | `01` + 9 digits | 11 | 11 | empty | Enter the wallet number / أدخل رقم المحفظة | Enter a valid Egyptian mobile number / أدخل رقم موبايل مصري صحيح | — |
| Bank | Yes (bank) | Dropdown | CIB, National Bank of Egypt, Banque Misr, QNB Al Ahli, AAIB, Banque du Caire, HSBC Egypt | — | — | none | Choose the bank / اختر البنك | — | — |
| Account holder / name on card | Yes (bank, card) | Free text | Letters and spaces | 3 | 100 | driver's name | Enter the name / أدخل الاسم | — | Name must be 3–100 characters / يجب أن يكون الاسم بين 3 و100 حرف |
| Account number / IBAN | Yes (bank) | Digits or IBAN | 10–20 digits, or `EG` + 27 digits | 10 | 29 | empty | Enter the account number / أدخل رقم الحساب | Enter a valid account number or IBAN / أدخل رقم حساب أو IBAN صحيح | — |
| Card number | Yes (card) | Digits | 16 digits, any prepaid card | 16 | 16 | empty | Enter the card number / أدخل رقم الكارت | Enter the 16-digit card number / أدخل رقم الكارت المكوّن من 16 رقمًا | — |

### Acceptance Criteria
**Scenario 1 — Correct a failed method**
- Given a driver's last payout failed "Account closed"
- When a Financial officer enters a new bank account and a Financial lead approves
- Then the profile shows the new number, updated by the Financial officer, and her next due earnings go into the next batch

**Scenario 2 — Pending edit**
- Given an edit is awaiting approval
- Then the profile shows "Change awaiting approval" and Edit is disabled

### Out of Scope
- Verifying the account with the bank

### Dependencies
- #1657/#1658 — Driver application review
- #5625 Driver adds a payout method during onboarding
- #6564 — Approval cycle — Payout method change

### Mockup (ADO comment)
- Driver profile — last payout failed: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069
- Driver profile — prepaid card: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1089
- Driver application — payout method: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-application.html?id=1061

---


# No masking of phone numbers or national IDs (2026-10-14)

> Phone numbers and national IDs are shown in full everywhere; payout account and card numbers stay masked. Built stories are left as they are — these new stories carry the change.

---

## [Admin] #5652 — Admin sees a driver's full national ID 🆕
**Feature:** #1614 Admin — Driver Management | **Sprint:** —

**Description:** As an admin, I want to see a driver's full national ID so that I can match her to her documents and to Finance's settlement sheet without asking for it.

### Rules
- The driver profile (#1666), the driver application (#1658) and the payout batch lines (#5619) show the full 14-digit national ID. Nothing is masked.
- Phone numbers are shown in full, as today.
- Payout account, card and wallet numbers are shown in full too.

### Acceptance Criteria
**Scenario 1 — Driver profile**
- Given a driver whose national ID is 29805120104821
- When an admin opens her profile
- Then the national ID reads 29805120104821

**Scenario 2 — Payout batch line**
- When an admin opens a payout batch
- Then every line shows the driver's full national ID next to her name

### Dependencies
- #1666, #1658, #5619

### Mockup (ADO comment)
- Driver profile: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069
- Driver application: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-application.html?id=1061
- Payout batch lines — open a batch from Payouts: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html

---

## [Admin] #5663 — Sidebar groups Finance, Pricing and Reporting 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6

**Description:** As an admin, I want the sidebar grouped by the job I'm doing so that the daily finance screens aren't mixed with pricing settings and reports.

### Rules
- Sidebar order:

| Group | Items |
|---|---|
| Operations | Dashboard · Trips · SOS requests · Safety reports |
| People | Driver applications · Drivers · Riders |
| Finance | Approvals · Driver balances · Payouts · Settlement imports · Rider balances |
| Pricing | Pricing & zones · Global policies |
| Reporting | Reports · Driver earnings |
| Administration | Audit log · Admin users |

- Only headings and order change.
- No shared icons; Payouts / Settlement imports use withdrawal / deposit wallet.

### Acceptance Criteria
**Scenario 1 — Arabic**
- When the portal is in Arabic
- Then the headings read العمليات · المستخدمون · المالية · التسعير · التقارير والمصالحات · الإدارة

### Dependencies
- #5617 — Approvals
- #5618 — Payouts
- #5620 — Settlement imports
- #5668 — Driver earnings (renamed from Reconciliation)

### Mockup (ADO comment)
- Sidebar on any screen: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/payouts.html
- Screen index (same groups): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/screens.html

---

## [Admin] #5668 — Driver earnings statement — who holds the fare and her balance for the period 🆕
**Feature:** #1803 Admin — Financial Reporting & Reconciliation | **Sprint:** Sprint 6 | **Tag:** Settlement

**Description:** As a Financial officer, I want a driver's earnings statement to show who holds each fare and how her balance moved over the period so that I can explain exactly why she owes SheDrive, or is owed, a given amount.

### Rules
- Sidebar: **Driver earnings** (Reporting). Page title: **Driver earnings statement** / أرباح السائقات · كشف أرباح السائقة. Trip figures and table as in #1833.
- Cards for the chosen driver and period:

| Card | Shows |
|---|---|
| Driver holds the fare | Trips, fares, commission she owes |
| SheDrive holds the fare | Trips, fares, net owed to her by payout status: on hold, due, in a batch, sent to bank, paid |
| Balance for the period | Opening, then count and total per movement (trip commission, trip earnings, cancellation fees, rider fee credits and hand-backs, waiver reversals, settlements, payouts), closing |

- Negative balance means she owes SheDrive.
- Trip rows: **Held by** replaces the payment method; SheDrive-held rows add **Payout status**.
- "Outstanding cash balance" is removed. The CSV follows the new columns.

### Acceptance Criteria
**Scenario 1 — Balance ties to the ledger**
- Given a driver whose ledger reads +250.50 EGP today
- When a Financial officer opens her statement with no dates
- Then the balance card closes at +250.50 EGP, built from opening 0.00, trip commission −89.44, trip earnings +475.50 and payouts −135.56

**Scenario 2 — A period starts mid-way**
- Given a start date three weeks ago
- Then the opening balance is her balance on that date, only that period's movements are listed, and the closing balance still matches her ledger

**Scenario 3 — Platform-held trips**
- Given two card trips with a net of 135.56 EGP already paid out
- Then the card shows *SheDrive holds the fare — 2 trips*, *Net SheDrive owes her +135.56*, *Paid 135.56*, and those rows say *SheDrive holds · Paid*

### Out of Scope
- Matching against bank statements or a payment provider's reports

### Dependencies
- #1833 — Admin views per-driver earnings & settlement report (the screen this extends)
- #4378 — Driver ledger
- #5618, #5619 — payout batches (payout status)

### Mockup (ADO comment)
- Driver earnings (choose a driver, e.g. Laila Fathy): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html

---


# Admin roles and access (2026-10-27)

> Approved access matrix: `docs/admin-roles/SheDrive-Admin-Access-Matrix.xlsx`. Created in ADO 2026-10-27 with tag "Admin roles".

---

## [Admin] #6480 — Admin (users & IT) sees only admin accounts and the audit log 🆕
**Feature:** Feature 1 — Platform & Integration Foundation (ADO Feature #1611) | **Sprint:** Sprint 6 | **Tag:** Admin roles

**Description:** As the Admin (users & IT), I want the portal to show me only admin accounts and the whole audit log so that I can run access and security without seeing riders', drivers' or financial data.

### Rules
- One role per admin account: Admin (users & IT), Operations officer, Operations lead, Financial officer, Financial lead. They replace Super admin and Admin (#1821, #4122). Setting a role: #6485.
- A lead has everything their officer has.
- The sidebar shows only the role's pages. Other pages show "You don't have access to this page" / "ليس لديك صلاحية لفتح هذه الصفحة" with a link to the role's start page.
- Read-only pages hide action buttons (not disable). The server refuses an action sent anyway.
- Role changes apply from the next page load.
- Operations and Finance alike see riders' and drivers' phone numbers.
- No role can edit or delete an audit log entry (#1816).

### Access Matrix
**Full** can see and do it · **View** read only · **Request** makes a request another person approves · **Approve** decides other people's requests · **Request + approve** both, never on their own request

| Area | Page / action | Stories | Admin (users & IT) |
|---|---|---|---|
| Account & security | Sign in, own profile, own password and two-factor | #1656, #1806, #1822 | Full |
| Account & security | Admin users: add, set or change a role, suspend, unsuspend, delete, reset password or two-factor | #1820, #4121, #1807, #1821, #4122, #1822, #6485 | Full |
| Account & security | Audit log | #1816 | View (all) |

### Acceptance Criteria
**Scenario 1 — Sign in**
- When the Admin (users & IT) signs in she lands on Admin users
- And a link to driver 1069's profile shows "You don't have access to this page" with a link to Admin users

**Scenario 2 — The whole audit log**
- Given today Sara approved a driver application and Hala approved a settlement
- When the Admin (users & IT) opens the audit log
- Then she sees both

### Out of Scope
- Custom permissions for a single account
- More than one role on one account
- A read-only Support role (added when support staff are hired)
- Approval limits by amount

### Dependencies
- #6485 — Setting and changing a role
- #6481, #6482, #6483, #6484 — the other four roles
- #1816 — Audit log

### Mockup (ADO comment)
- Audit log, every entry: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/audit-log.html?as=admin_it
- No access page (driver profile): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069&as=admin_it

---

## [Admin] #6485 — Admin (users & IT) chooses the role when adding an admin user 🆕
**Feature:** Feature 1 — Platform & Integration Foundation (ADO Feature #1611) | **Sprint:** Sprint 6 | **Tag:** Admin roles

**Description:** As the Admin (users & IT), I want to choose a colleague's role when I add their admin account so that their access matches their job from their first sign-in.

### Rules
- **Add admin user** has a required **Role** field. The role is set once, when the account is added. There is no Change role action.
- The **Admin users** list (#1820) gets a **Role** column, sortable and filterable.
- The list shows Operations and Financial accounts only. Admin (users & IT) accounts, her own included, never show in the list, and the Role filter doesn't offer that role.
- On Admin users she also resets two-factor: this removes the authenticator and recovery codes and ends the account's sessions.
- When a suspension or deletion leaves fewer than two active Financial leads, the confirmation warns:

| Leads left | Warning |
|---|---|
| One | "Only one Financial lead will be left. Their own finance requests can't be approved until another is added." / "سيتبقى رئيس فريق مالي واحد فقط. لا يمكن اعتماد طلباته المالية حتى تتم إضافة آخر." |
| None | "No Financial lead will be left. Finance requests can't be approved until one is added." / "لن يتبقى رئيس فريق مالي. لا يمكن اعتماد أي طلب مالي حتى تتم إضافة واحد." |

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Role | Yes | Dropdown (single-select) | Admin (users & IT) / Operations officer / Operations lead / Financial officer / Financial lead | — | — | none | Choose a role / اختر الصلاحية | — | — |

### Acceptance Criteria
**Scenario 1 — Add with a role**
- When the Admin (users & IT) adds Mona with the role Financial officer and saves
- Then Mona's row shows Financial officer
- And at her first sign-in Mona sees the Financial officer pages
- And the audit log records the account added with that role

**Scenario 2 — No role chosen**
- When the Admin (users & IT) saves a new account without a role
- Then "Choose a role" shows and the account is not added

**Scenario 3 — Admin (users & IT) accounts not listed**
- Given Reem and Dina are both Admin (users & IT)
- When Reem opens Admin users
- Then neither Reem's nor Dina's row shows
- And the Role filter offers only the Operations and Financial roles

**Scenario 4 — Last Financial lead**
- Given Hala and Nour are the only active Financial leads
- When the Admin (users & IT) suspends Nour
- Then the "Only one Financial lead will be left" warning shows, and on confirm Nour is suspended

**Scenario 5 — Lost phone**
- Given Sara has lost her phone and her recovery codes
- When the Admin (users & IT) resets her two-factor
- Then at her next sign-in Sara scans a new QR code

### Out of Scope
- Changing a role after the account is added
- Managing Admin (users & IT) accounts from the Admin users list
- Time-limited roles

### Dependencies
- #6480 — Roles, and what the Admin (users & IT) sees
- #1807, #1820, #1821, #4122 — Admin accounts
- #1822 — Password reset
- #1806 — Two-factor
- #1816 — Audit log

### Mockup (ADO comment)
- Admin users with roles: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/admin-users.html?as=admin_it

---

## [Admin] #6481 — Operations officer reviews applications and safety reports and looks up riders, drivers and trips 🆕
**Feature:** Feature 1 — Platform & Integration Foundation (ADO Feature #1611) | **Sprint:** Sprint 6 | **Tag:** Admin roles

**Description:** As an Operations officer, I want to review driver applications and safety reports and look up riders, drivers and trips so that I can run daily operations without suspending anyone or touching money.

### Rules
- Start page after sign-in: Dashboard.
- On the driver profile and the driver application she sees the full national ID (#5652) and no payout method section. The dashboard shows her the live operations map (#1823–#1826).
- Hidden pages and actions behave as #6480 says.

### Access Matrix
**Full** can see and do it · **View** read only · **Request** makes a request another person approves · **Approve** decides other people's requests · **Request + approve** both, never on their own request

| Area | Page / action | Stories | Operations officer |
|---|---|---|---|
| Account & security | Sign in, own profile, own password and two-factor | #1656, #1806, #1822 | Full |
| Operations | Dashboard | #1669 | View |
| Operations | Driver applications: open, approve or reject | #1657, #4008, #1658, #1659, #1660 | Full |
| Operations | Drivers | #1665, #4009, #1666 | View |
| Operations | Riders | #1661, #4010, #1662 | View |
| Operations | Trips | #1670–#1672, #4007 | View |
| Operations | Safety reports: open, dismiss | #1810, #4120, #1811 | Full |
| Operations | SOS requests and their actions (when it goes live) | #3945, #3946 | Full |
| Pricing & settings | Zones and pricing policies | #1831, #1759 | View |

### Acceptance Criteria
**Scenario 1 — Approve an application**
- Given Sara is an Operations officer
- When she opens driver application 1061 and approves it
- Then the application is Approved (#1659)

**Scenario 2 — An Active driver's profile**
- Given an Active driver with national ID 29805120104821 and payout wallet 01012345678
- When Sara opens her profile
- Then she sees 29805120104821, no payout method section and no Suspend action

**Scenario 3 — A request sent around the screen**
- Given Sara's session sends a suspend request for that driver directly
- Then it is refused and the driver stays Active

**Scenario 4 — A gender-mismatch report**
- When Sara opens an open report
- Then she can Dismiss it, with an optional note, and there is no Suspend action

**Scenario 5 — A finance link**
- When Sara opens a link to Driver balances
- Then she sees "You don't have access to this page" with a link to the Dashboard

### Dependencies
- #6480 — Roles, and how hidden pages and actions behave
- #1657, #1658, #1659, #1660 — Driver applications
- #1810, #1811 — Safety reports
- #5652 — Full national ID

### Mockup (ADO comment)
- Driver application 1061: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-application.html?id=1061&as=ops_officer
- Driver profile — national ID, no payout method, no Suspend: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069&as=ops_officer
- Safety reports: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/safety-reports.html?as=ops_officer
- No access page (Driver balances): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html?as=ops_officer

---

## [Admin] #6482 — Operations lead suspends riders and drivers, acts on safety reports and runs zones and operating hours 🆕
**Feature:** Feature 1 — Platform & Integration Foundation (ADO Feature #1611) | **Sprint:** Sprint 6 | **Tag:** Admin roles

**Description:** As an Operations lead, I want everything an Operations officer has plus suspensions, safety-report actions, live-trip intervention, zones and operating hours so that decisions that remove someone's access or change how the service runs stay with one accountable person.

### Rules
- She has every page, action and piece of data the Operations officer has (#6481).
- Her actions apply at once, with no approval.
- The audit log (#1816) shows her operations entries only: driver applications, rider and driver suspensions, safety reports, zones and operating hours.

### Access Matrix
**Full** can see and do it · **View** read only · **Request** makes a request another person approves · **Approve** decides other people's requests · **Request + approve** both, never on their own request

| Area | Page / action | Stories | Operations lead |
|---|---|---|---|
| Account & security | Sign in, own profile, own password and two-factor | #1656, #1806, #1822 | Full |
| Account & security | Audit log | #1816 | View (operations) |
| Operations | Dashboard | #1669 | View |
| Operations | Driver applications: open, approve or reject | #1657, #4008, #1658, #1659, #1660 | Full |
| Operations | Drivers | #1665, #4009, #1666 | View |
| Operations | Suspend or reinstate a driver | #1742, #1743 | Full |
| Operations | Riders | #1661, #4010, #1662 | View |
| Operations | Suspend or reinstate a rider | #1740, #1741 | Full |
| Operations | Trips | #1670–#1672, #4007 | View |
| Operations | Cancel or reassign a trip still in progress | #1671 | Full |
| Operations | Safety reports: open, dismiss | #1810, #4120, #1811 | Full |
| Operations | Safety report: act against a driver or rider | #1811 | Full |
| Operations | SOS requests and their actions (when it goes live) | #3945, #3946 | Full |
| Pricing & settings | Zones and pricing policies | #1831, #1759 | View |
| Pricing & settings | Create, edit or delete a service zone | #1756, #1830 | Full |
| Pricing & settings | Change the operating hours | #6268 | Full |
| Finance | Driver balances | #1813, #4378 | View |
| Finance | Rider outstanding fees | #4005 | View |
| Finance | Reports and reconciliation | #1833, #5668 | View |

### Acceptance Criteria
**Scenario 1 — Suspend a driver**
- Given an Active driver
- When the Operations lead suspends her (#1742)
- Then she is Suspended

**Scenario 2 — Pricing policies**
- When the Operations lead opens Pricing policies
- Then the operating hours have Edit, and the cancellation policy has none

**Scenario 3 — The audit log by role**
- Given today Sara approved a driver application and Hala approved a settlement
- When the Operations lead opens the audit log
- Then she sees only the application approval

**Scenario 4 — A driver who owes money**
- When she opens Driver balances
- Then she sees a driver owing 350 EGP and no Record settlement action

### Dependencies
- #6480 — Roles, and how hidden pages and actions behave
- #6481 — Operations officer
- #1740–#1743 — Suspensions
- #1811 — Safety report actions
- #1671 — Trip in progress
- #1756, #1830, #6268 — Zones and operating hours
- #1816 — Audit log

### Mockup (ADO comment)
- Driver profile with Suspend: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069&as=ops_lead
- Pricing policies — operating hours editable: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=ops_lead
- Audit log, operations entries: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/audit-log.html?as=ops_lead
- Driver balances, read only: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html?as=ops_lead

---

## [Admin] #6483 — Financial officer reads balances and reports and makes finance requests 🆕
**Feature:** Feature 1 — Platform & Integration Foundation (ADO Feature #1611) | **Sprint:** Sprint 6 | **Tag:** Admin roles

**Description:** As a Financial officer, I want to see balances, fees and reports and make settlement, payout, waiver and payout-method requests so that money moves only after a Financial lead approves it.

### Rules
- Start page after sign-in: Dashboard.
- Each of her requests waits for a Financial lead (#6212). Approvals shows her own requests and their decisions. Generating a payout batch and exporting its bank files need no approval (#5618).
- On the driver profile she sees the payout method section in full (#5624) and no national ID. Payout batch lines and settlement import lines keep the national ID, because the bank file and Finance's sheet identify a driver by it. The dashboard has no live operations map.
- Hidden pages and actions behave as #6480 says.

### Access Matrix
**Full** can see and do it · **View** read only · **Request** makes a request another person approves · **Approve** decides other people's requests · **Request + approve** both, never on their own request

| Area | Page / action | Stories | Financial officer |
|---|---|---|---|
| Account & security | Sign in, own profile, own password and two-factor | #1656, #1806, #1822 | Full |
| Operations | Dashboard | #1669 | View |
| Operations | Drivers | #1665, #4009, #1666 | View |
| Operations | Riders | #1661, #4010, #1662 | View |
| Operations | Trips | #1670–#1672, #4007 | View |
| Pricing & settings | Zones and pricing policies | #1831, #1759 | View |
| Finance | Driver balances | #1813, #4378 | View |
| Finance | Rider outstanding fees | #4005 | View |
| Finance | Record a manual settlement or payout | #4379, #4001, #5622 | Request |
| Finance | Settlement imports: import the settlement sheet | #5620 | Request |
| Finance | Waive a rider's cancellation fee | #5621 | Request |
| Finance | Payouts: the payout history and its cards | #6497 | View |
| Finance | Payouts: choose the payout method, generate a batch and export its bank file | #5618, #6570, #5619 | Full |
| Finance | Payouts: import a batch's result file | #5619 | Request |
| Finance | Change a driver's payout method | #5624 | Request |
| Finance | Approvals | #5617, #6212 | Own requests (view) |
| Finance | Reports and reconciliation | #1833, #5668 | View |

### Acceptance Criteria
**Scenario 1 — A settlement waits for a lead**
- Given a driver owes 350 EGP
- When Mona records a 350 EGP cash settlement
- Then Approvals shows it Pending with no Approve action for her, and the balance stays −350 EGP until a Financial lead approves

**Scenario 2 — A link to an application**
- When Mona opens a link to driver application 1061
- Then she sees "You don't have access to this page" and her sidebar has no Driver applications item

**Scenario 3 — Payout method**
- When Mona changes a driver's wallet to 01098765432
- Then the profile keeps showing the old wallet until a Financial lead approves the change

### Dependencies
- #6480 — Roles, and how hidden pages and actions behave
- #6212 — Only Financial leads approve finance requests
- #5617 — Maker-checker approvals
- #4379, #4001, #5622, #5620, #5621, #5618, #5619, #5624 — Finance requests
- #6497 — Payout history

### Mockup (ADO comment)
- Driver balances: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html?as=fin_officer
- Approvals — own requests only: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approvals.html?as=fin_officer
- Driver profile — payout method, no national ID: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-profile.html?id=1069&as=fin_officer
- No access page (driver application): https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/driver-application.html?id=1061&as=fin_officer

---

## [Admin] #6484 — Financial lead approves finance requests and proposes pricing and balance-limit changes 🆕
**Feature:** Feature 1 — Platform & Integration Foundation (ADO Feature #1611) | **Sprint:** Sprint 6 | **Tag:** Admin roles

**Description:** As a Financial lead, I want everything a Financial officer has plus deciding other people's finance requests and proposing pricing and balance-limit changes so that every money and pricing change is checked by a second person.

### Rules
- She has every page, request and piece of data the Financial officer has (#6483).
- Her own request, including a pricing or balance-limit change she proposes, goes to a different Financial lead (#6212).
- The audit log (#1816) shows her finance entries only: finance requests and their decisions, settlements, payouts, settlement imports, fee waivers, payout methods and pricing.

### Access Matrix
**Full** can see and do it · **View** read only · **Request** makes a request another person approves · **Approve** decides other people's requests · **Request + approve** both, never on their own request

| Area | Page / action | Stories | Financial lead |
|---|---|---|---|
| Account & security | Sign in, own profile, own password and two-factor | #1656, #1806, #1822 | Full |
| Account & security | Audit log | #1816 | View (finance) |
| Operations | Dashboard | #1669 | View |
| Operations | Drivers | #1665, #4009, #1666 | View |
| Operations | Riders | #1661, #4010, #1662 | View |
| Operations | Trips | #1670–#1672, #4007 | View |
| Pricing & settings | Zones and pricing policies | #1831, #1759 | View |
| Pricing & settings | Change the rate card, commission or cancellation policy | #1757, #1759, #5623, #6212 | Request + approve |
| Pricing & settings | Change the driver balance limit | #3994, #6212 | Request + approve |
| Pricing & settings | Change the payout settings (minimum payout, transfer fee) | #6486, #6212 | Request + approve |
| Finance | Driver balances | #1813, #4378 | View |
| Finance | Rider outstanding fees | #4005 | View |
| Finance | Record a manual settlement or payout | #4379, #4001, #5622 | Request + approve |
| Finance | Settlement imports: import the settlement sheet | #5620 | Request + approve |
| Finance | Waive a rider's cancellation fee | #5621 | Request + approve |
| Finance | Payouts: the payout history and its cards | #6497 | View |
| Finance | Payouts: choose the payout method, generate a batch and export its bank file | #5618, #6570, #5619 | Full |
| Finance | Payouts: import a bank file's result | #5619 | Request + approve |
| Finance | Change a driver's payout method | #5624 | Request + approve |
| Finance | Approvals | #5617, #6212 | Approve |
| Finance | Reports and reconciliation | #1833, #5668 | View |

### Acceptance Criteria
**Scenario 1 — Approve an officer's settlement**
- Given Mona recorded a 350 EGP settlement for a driver who owes 350 EGP
- When Hala approves it
- Then the driver's balance goes from −350 EGP to 0

**Scenario 2 — Her own pricing change**
- When Hala proposes commission 15% → 18%
- Then her row in Approvals has no Approve action
- And when Nour approves it, the new commission applies

**Scenario 3 — The audit log by role**
- Given today Sara approved a driver application and Hala approved a settlement
- When Nour opens the audit log
- Then she sees only the settlement approval

### Dependencies
- #6480 — Roles, and how hidden pages and actions behave
- #6483 — Financial officer
- #6212 — Only Financial leads approve finance requests
- #5617 — Maker-checker approvals
- #1757, #1759, #5623, #3994 — Pricing and balance limit
- #1816 — Audit log

### Mockup (ADO comment)
- Approvals — approve or reject: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/approvals.html?as=fin_lead
- Pricing policies — propose a change: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=fin_lead
- Audit log, finance entries: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/audit-log.html?as=fin_lead

---

# Operating hours (2026-10-27)

> Admin side of [Mobile] #1791 / [API] #1785. Design story #6269.

---

## [Admin] #6268 — Operations lead sets the daily operating hours 🆕
**Feature:** #1755 Admin — Pricing & Rate Management | **Sprint:** Sprint 6 | **Tag:** Operating hours

**Description:** As the Operations lead, I want to set the hours when riders can book so that SheDrive only takes ride requests while we are serving.

### Rules
- **Global policies** (#1759) gets an **Operating hours** section on its own **Operations** tab (tabs: #6486): **Opens at** / **Closes at**, Cairo time.
- Operations lead only (#6482); other roles read-only. Saves immediately, no approval.
- Applies to the next ride request and the rider app's open/closed status (#1785), not to trips already requested.
- Status line: "Open now · closes at 23:00" / "مفتوح الآن · يغلق الساعة 23:00", "Closed now · opens today at 07:00" / "مغلق الآن · يفتح اليوم الساعة 07:00", "Closed now · opens tomorrow at 07:00" / "مغلق الآن · يفتح غدًا الساعة 07:00".
- Shows "Last changed <date> by <name>".

### Field Validation
| Field | Required | Type / Format | Accepted values | Min | Max | Default | Error — empty | Error — invalid | Error — range/length |
|---|---|---|---|---|---|---|---|---|---|
| Opens at | Yes | Time (HH:MM, 24-hour, Cairo time) | 00:00–23:59 | 00:00 | 23:59 | 07:00 | Enter the opening time / أدخل وقت الفتح | Enter a valid time / أدخل وقتًا صحيحًا | — |
| Closes at | Yes | Time (HH:MM, 24-hour, Cairo time) | 00:01–23:59, later than Opens at | — | 23:59 | 23:00 | Enter the closing time / أدخل وقت الإغلاق | Enter a valid time / أدخل وقتًا صحيحًا | Closing time must be after opening time / يجب أن يكون وقت الإغلاق بعد وقت الفتح |

### Acceptance Criteria
**Scenario 1 — Closing earlier tonight**
- Given the hours are 07:00–23:00 and it is 22:30
- When the Operations lead changes Closes at to 22:00 and saves
- Then the section reads "Closed now · opens tomorrow at 07:00"
- And a rider who requests a trip at 22:31 is refused (#1785)

**Scenario 2 — Closing before opening**
- Given Opens at is 07:00
- When she enters 06:00 as Closes at and saves
- Then "Closing time must be after opening time" shows under Closes at and nothing is saved

### Out of Scope
- Different hours per zone
- Different hours per weekday
- Holidays and one-off closures
- A window that runs past midnight

### Dependencies
- #1759 — Global policies (the screen)
- #1785 — [API] Booking is open only inside operating hours
- #1791 — [Mobile] Rider cannot book outside operating hours
- #6482 — Operations lead
- #1816 — Audit log

### Mockup (ADO comment)
- Global policies — Operations tab: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?as=ops_lead&tab=operations
- Design story: #6269

---
