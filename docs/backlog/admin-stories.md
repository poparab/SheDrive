# SheDrive — Admin Portal Stories
> Canonical backlog for all [Admin] stories. Organized by sprint and feature.
> Last updated: 2026-06-03
> Stories with changes from original are marked ✏️

---

## Sprint 1

### Feature 1 — Platform & Integration Foundation

---

## [Admin] #1656 — Admin portal shell and login screen are in place
**Feature:** Feature 1 — Platform & Integration Foundation | **Sprint:** 1

**Description:** As an operations admin, I want a working admin web portal with a login screen and shell layout so that I can securely access SheDrive operations dashboards.

### Background
The admin portal is a web application accessible to SheDrive operations staff. It presents a login screen (email + password) as its unauthenticated entry point. Successful authentication lands the admin on the main dashboard, which sits within a persistent shell consisting of a navigation sidebar or top bar and a content area. The portal is distinct from the rider/driver mobile app and serves as the operations team's command centre for approving drivers, monitoring trips, and managing the platform.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Email | Yes | Valid email address (contains @, valid domain) | — | 254 chars | Standard email characters | أدخل البريد الإلكتروني | بريد إلكتروني غير صحيح | بريد إلكتروني غير صحيح |
| Password | Yes | Any printable characters | 8 chars | — | Any printable characters | أدخل كلمة المرور | — | أدخل كلمة المرور (if under 8 chars) |

### Acceptance Criteria

**Scenario 1 — Admin logs in with valid credentials**
- Given an operations admin navigates to the admin portal login screen
- When she enters a valid registered email and the correct password and submits the form
- Then she is authenticated and redirected to the admin dashboard
- And the shell navigation (sidebar or top bar) is visible

**Scenario 2 — Login fails with wrong credentials**
- Given an admin enters a registered email with an incorrect password
- When she submits the form
- Then she remains on the login screen
- And the error message "البريد الإلكتروني أو كلمة المرور غير صحيحة" is displayed

**Scenario 3 — Login form validates empty fields**
- Given an admin submits the login form with the email field empty
- When the form validates
- Then the error "أدخل البريد الإلكتروني" is displayed inline
- And if the password field is also empty, "أدخل كلمة المرور" is displayed inline

**Scenario 4 — Login form validates email format**
- Given an admin enters a value that does not conform to email format (e.g., missing @)
- When she submits the form
- Then the error "بريد إلكتروني غير صحيح" is displayed inline

**Scenario 5 — Admin portal shell is accessible after login**
- Given an authenticated admin is on any portal page
- When she views the page
- Then the shared navigation shell (links to Dashboard, Driver Management, Trip Monitor, and Settings at minimum) is always visible
- And the active page is indicated in the navigation

**Scenario 6 — Unauthenticated access to protected portal pages is redirected**
- Given a user attempts to navigate directly to a protected admin portal URL without a valid session
- When the portal processes the request
- Then the user is redirected to the login screen

### Out of Scope
- Password reset or forgot-password flow
- Multi-factor authentication for admin login
- Admin user management (creating/deleting admin accounts)
- SOS/emergency features

### Dependencies
- None (foundational portal shell story)

---

### Feature 5 — Driver Onboarding & Admin Approval

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

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Rejection reason | Yes | Free text | 10 chars | 500 chars | Any | يرجى إدخال سبب الرفض | — | الرجاء توضيح سبب الرفض بشكل أكثر تفصيلاً |

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

### Feature 13 — Admin — Rider Management

---

## [Admin] #1661 — Admin views rider list
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a searchable, paginated list of all registered riders so that I can find and review any rider account quickly.

### Background
The rider list is the primary entry point for rider management in the admin portal. It loads automatically when the admin navigates to the Riders section. The table shows all registered riders with key identifiers. The admin can type a name or phone number into the search box to narrow results in real time. Clicking any row opens the rider profile screen (#1662). The default page size is 20 rows.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | 0 chars | 100 chars | Any | Show all riders (no error) | N/A | Clear input and reset to full list |

### Acceptance Criteria

**Scenario 1 — Admin opens the rider list**
- Given the admin is authenticated and navigates to the Riders section
- When the page loads
- Then a table of all registered riders is displayed, 20 per page by default
- And columns shown are: name, phone number, registration date, total trips completed
- And results are ordered by registration date descending

**Scenario 2 — Admin searches by rider name**
- Given the rider list is loaded
- When the admin types a partial name into the search box
- Then the list filters to show only riders whose name contains the search text
- And the result count updates accordingly

**Scenario 3 — Admin searches by phone number**
- Given the rider list is loaded
- When the admin types a partial phone number into the search box
- Then the list filters to show only riders whose phone number contains that substring

**Scenario 4 — Search returns no results**
- Given the admin has entered a search term that matches no rider
- When the results are rendered
- Then an empty state message is displayed indicating no riders match the search
- And no table rows are shown

**Scenario 5 — Admin clicks a rider row**
- Given the rider list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the rider profile screen (#1662) for that rider

**Scenario 6 — Admin paginates the list**
- Given the rider list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 riders are displayed in the same column order

### Out of Scope
- Editing rider account details
- Banning or suspending a rider account
- Exporting the rider list
- Audit logs

### Dependencies
- #1663 — Rider list with search and filters is served (must be live)

---

## [Admin] #1662 — Admin views rider profile
**Feature:** Feature 13 — Admin Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a rider's full profile and their trip history so that I can understand their account activity.

### Background
The rider profile screen is opened by clicking any row in the rider list (#1661). It presents the rider's personal information at the top, followed by a paginated list of the rider's past trips below. All information is read-only in these sprints. If a rider's account is in "pending_review" status (suspended via #1687), a status badge is shown and an alert appears for the admin to review the report. The admin can paginate through the trip history without leaving the profile screen.

### Acceptance Criteria

**Scenario 1 — Admin opens a rider profile**
- Given the admin has clicked a rider row in the rider list
- When the profile screen loads
- Then the following information is shown: full name, phone number, registration date, total trips completed, and date of last trip
- And below the profile, a paginated list of the rider's past trips is displayed
- And the account status badge is shown (Active or Pending Review)

**Scenario 2 — Trip history section displays correct columns**
- Given the rider profile is loaded
- When the admin views the trip history table
- Then each row shows: trip date, destination address, fare (EGP), and trip status

**Scenario 3 — Rider has no past trips**
- Given the admin opens the profile of a rider who has never completed a trip
- When the trip history section renders
- Then an empty state message is shown in place of the trip table

**Scenario 4 — Admin paginates the trip history**
- Given the rider has more than one page of past trips
- When the admin navigates to the next page of the trip history
- Then the next page of trips loads within the profile screen

**Scenario 5 — Admin navigates back to the rider list**
- Given the admin is on the rider profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the rider list

### Out of Scope
- Editing rider details
- Banning or suspending the rider from this screen
- Viewing trip details from within the profile (trip row is not clickable in this sprint)
- Exporting rider data

### Dependencies
- #1664 — Rider profile with trip history is served (must be live)

---

### Feature 14 — Admin — Driver Management

---

## [Admin] #1665 — Admin views driver list across all statuses
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a searchable, filterable list of all driver accounts grouped by status so that I can monitor the driver pipeline and locate any driver quickly.

### Background
The driver list is the primary entry point for driver management in the admin portal. It shows all driver accounts regardless of onboarding status. Status filter tabs or a dropdown allow the admin to narrow results to a single status group (Pending, Approved, or Rejected). A search box allows free-text lookup by name or phone. The default page size is 20 rows. Clicking any row opens the driver profile (#1666).

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | 0 chars | 100 chars | Any | Show all drivers (no error) | N/A | Clear input and reset to full list |
| Status filter | No | Enum | N/A | N/A | All, Pending, Approved, Rejected | Show all statuses (default = All) | N/A | N/A |

### Acceptance Criteria

**Scenario 1 — Admin opens the driver list**
- Given the admin is authenticated and navigates to the Drivers section
- When the page loads
- Then a table of all driver accounts is displayed with default filter "All"
- And columns shown are: name, phone number, status, onboarding submission date, total trips completed (for approved drivers)
- And the list is ordered by submission date descending

**Scenario 2 — Admin filters by status "Pending"**
- Given the driver list is loaded
- When the admin selects the "Pending" status filter
- Then only drivers with pending status are shown in the table

**Scenario 3 — Admin filters by status "Approved"**
- Given the driver list is loaded
- When the admin selects the "Approved" status filter
- Then only approved drivers are shown

**Scenario 4 — Admin filters by status "Rejected"**
- Given the driver list is loaded
- When the admin selects the "Rejected" status filter
- Then only rejected drivers are shown

**Scenario 5 — Admin searches by driver name**
- Given the driver list is loaded
- When the admin types a partial name into the search box
- Then the list filters to drivers whose name contains that text

**Scenario 6 — Admin searches by phone number**
- Given the driver list is loaded
- When the admin types a partial phone number
- Then the list filters to drivers whose phone contains that substring

**Scenario 7 — Search and filter produce no results**
- Given the admin has applied a search or filter with no matching drivers
- Then an empty state message is displayed

**Scenario 8 — Admin clicks a driver row**
- Given the driver list is visible with at least one row
- When the admin clicks any row
- Then the portal navigates to the driver profile screen (#1666) for that driver

**Scenario 9 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 drivers are displayed

### Out of Scope
- Approving or rejecting a driver from this screen
- Suspending or banning a driver
- Exporting the driver list
- Audit logs

### Dependencies
- #1667 — Driver list with status filter and search is served (must be live)

---

## [Admin] #1666 — Admin views driver profile
**Feature:** Feature 14 — Admin Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a driver's full profile including their documents, vehicle details, and trip history so that I can assess their account comprehensively.

### Background
The driver profile screen is opened by clicking any row in the driver list (#1665). It presents personal details, vehicle information, uploaded document images (viewable inline), the profile photo (#1686), current status, aggregate statistics, and — for pending or rejected drivers — the decision history. Below the profile information, a paginated list of the driver's completed trips is shown. All content is read-only on this screen; approve/reject actions remain on the pending queue screens (#1657–#1660).

### Acceptance Criteria

**Scenario 1 — Admin opens an approved driver profile**
- Given the admin has clicked an approved driver row
- When the profile screen loads
- Then the following sections are displayed: personal details (name, phone, date of birth, masked national ID), vehicle details (make, model, plate number, colour), document images (viewable inline), vehicle photo, profile photo, status badge "Approved", total trips completed, and average rider rating

**Scenario 2 — Admin opens a pending driver profile**
- Given the admin has clicked a pending driver row
- When the profile screen loads
- Then all sections from Scenario 1 are shown with status badge "Pending"
- And a decision history section shows the timeline of status changes with timestamps

**Scenario 3 — Admin opens a rejected driver profile**
- Given the admin has clicked a rejected driver row
- When the profile screen loads
- Then all sections from Scenario 1 are shown with status badge "Rejected"
- And the decision history section shows when and why the application was rejected

**Scenario 4 — Admin views the driver's trip history**
- Given the driver profile is loaded for an approved driver with completed trips
- When the admin scrolls to the trip history section
- Then a paginated list of completed trips is shown with: trip date, destination area, fare collected, and rider rating received

**Scenario 5 — Driver has no completed trips**
- Given the admin opens the profile of a driver with no completed trips
- When the trip history section renders
- Then an empty state message is shown

**Scenario 6 — Admin navigates back to the driver list**
- Given the admin is on the driver profile screen
- When she clicks the back button or breadcrumb
- Then she is returned to the driver list at the same filter state

### Out of Scope
- Approving or rejecting a driver from this screen
- Editing driver details
- Suspending or banning a driver
- Exporting profile data

### Dependencies
- #1668 — Driver profile with trip history is served (must be live)

---

### Feature 15 — Admin Operations Dashboard

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

**Description:** As an operations admin, I want to view a searchable, filterable list of all trips on the platform so that I can monitor trip activity and investigate specific trips.

### Background
The trip list screen shows all trips across all statuses. The admin can filter by trip status, apply a date range, and search by rider or driver name or phone. Default page size is 20 rows ordered by creation date descending.

**Status filter → state machine mapping:**
| UI Filter | Underlying trip states |
|---|---|
| Searching | `searching` |
| Active | `matched`, `accepted`, `en_route_pickup`, `arrived_pickup`, `trip_started` |
| Completed | `trip_ended` |
| Expired | `expired` (all sub-reasons: no_driver, system_timeout, gender_mismatch_report) |

### Field Validation

| Field | Required | Format | Error — invalid format |
|---|---|---|---|
| Search | No | Free text (0–100 chars) | — |
| Status filter | No | All, Searching, Active, Completed, Expired | — |
| Date from | No | YYYY-MM-DD | Inline: "Invalid date" |
| Date to | No | YYYY-MM-DD; must not be before from-date | Inline: "End date must be after start date" |

### Acceptance Criteria

**Scenario 1 — Admin opens the trip list**
- Given the admin navigates to the Trips section
- When the page loads
- Then a table of all trips is displayed ordered by creation date descending
- And columns shown are: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, for completed trips), and date

**Scenario 2 — Admin filters by status**
- Given the trip list is loaded
- When the admin selects a status filter (e.g., "Active")
- Then only trips whose underlying state(s) match that filter bucket are shown (see mapping above)

**Scenario 3 — Admin applies a date range**
- Given the admin sets a from-date and a to-date
- Then only trips created within that date range are shown

**Scenario 4 — Admin sets an invalid date range (to before from)**
- Given the admin sets a to-date earlier than the from-date
- Then an inline error "End date must be after start date" is displayed
- And the filter is not applied

**Scenario 5 — Admin searches by rider or driver name**
- Given the admin types a partial name
- Then the list filters to trips where the rider or driver name contains that text

**Scenario 6 — Admin searches by phone**
- Given the admin types a partial phone number
- Then the list filters to trips where the rider or driver phone contains that substring

**Scenario 7 — Filters produce no results**
- Given filters match no trip
- Then an empty state message is displayed

**Scenario 8 — Admin clicks a trip row**
- Given the trip list has at least one row
- When the admin clicks any row
- Then the portal navigates to the trip detail screen (#1671)

**Scenario 9 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- Then the next page shows the next 20 trips

### Out of Scope
- Cancelling a trip from this screen
- Contacting rider or driver from this screen
- Exporting the trip list

### Dependencies
- #1674 — Trip list with pagination and filters is served (must be live)

---

## [Admin] #1671 — Admin views trip detail with state history
**Feature:** Feature 15 — Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a trip's full detail and state transition timeline so that I can understand exactly how that trip progressed.

### Background
The trip detail screen is opened by clicking any row in the trip list (#1670). It shows rider and driver information, the pickup and destination addresses, and a chronological timeline of every state the trip passed through with timestamps. The timeline is sourced from the `trip_state_history` table (written by #1652 Scenario 6). The screen is read-only.

### Acceptance Criteria

**Scenario 1 — Admin opens a trip that is in progress**
- Given the admin has clicked an active trip row
- When the detail screen loads
- Then rider information (name, phone) and driver information (name, phone, vehicle) are shown
- And pickup and destination addresses are displayed
- And the state timeline shows all transitions up to the current state with timestamps (e.g., Created → Searching → Matched → En route pickup → Arrived → Trip started)

**Scenario 2 — Admin opens a completed trip**
- Given the admin has clicked a completed trip row
- When the detail screen loads
- Then all information from Scenario 1 is shown
- And the timeline includes the "Trip ended" transition with its timestamp
- And the completed trip's additional fare and rating details are shown as per #1672

**Scenario 3 — Admin opens a trip that expired (no driver found)**
- Given the admin has clicked an expired trip row
- When the detail screen loads
- Then the timeline shows the transitions up to "Expired" with its timestamp
- And a note is shown indicating the reason for expiry (no driver matched, system timeout, or gender mismatch report)

**Scenario 4 — Admin navigates back to the trip list**
- Given the admin is on the trip detail screen
- When she clicks the back button or breadcrumb
- Then she is returned to the trip list at the same filter state

### Out of Scope
- Manually changing a trip's status
- Contacting rider or driver from this screen
- Refund processing
- SOS event logs

### Dependencies
- #1675 — Trip detail with state history is served (must be live)

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

**Scenario 4 — Screen remains read-only**
- Given the admin is viewing any completed trip detail
- When she views the fare and rating sections
- Then no edit controls or action buttons are available in these sections

### Out of Scope
- Adjusting or refunding a fare
- Editing or removing a rating
- Contacting rider or driver

### Dependencies
- #1675 — Trip detail with state history is served (must be live)
- #1637 — Completed trip is served with fare breakdown (fare data source)
- #1639 — Rider submits driver rating (rating data source)
