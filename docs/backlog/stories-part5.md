# SheDrive — User Stories Part 5
## Features 12–15: Trip History, Admin Rider/Driver Management, Admin Operations Dashboard

---

## [Mobile] #1567 — Rider views trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a rider, I want to view a list of my past trips so that I can review where I have travelled and how much I have spent.

### Background
Riders access trip history from the menu or profile section of the app. The list is sorted most recent first and shows a summary row for each past trip. This screen gives riders a quick overview without surfacing every detail — tapping any row opens the full trip detail screen (#1568). If the rider has not yet completed any trips, an empty state message is displayed instead of the list.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Rider opens trip history with past trips**
- Given the rider is authenticated and has at least one completed trip
- When she opens the trip history screen from the menu
- Then a paginated list of her past trips is displayed, most recent first
- And each row shows: trip date, destination name, fare paid (EGP), and status "Completed"

**Scenario 2 — Rider taps a trip row**
- Given the trip history list is visible with at least one row
- When the rider taps any trip row
- Then the app navigates to the trip detail screen (#1568) for that trip

**Scenario 3 — Rider has no past trips**
- Given the rider is authenticated and has never completed a trip
- When she opens the trip history screen
- Then an empty state message is shown indicating no trips are available yet
- And no list rows are rendered

**Scenario 4 — Rider paginates the list**
- Given the rider has more than one page of past trips
- When she scrolls to the bottom of the current page
- Then the next page of trips loads and appends to the list
- And the order remains most recent first

### Out of Scope
- Cancellations and in-progress trips
- Filtering or searching trip history
- Exporting trip history
- SOS-related trip records

### Dependencies
- #1641 — Rider retrieves trip history (must be live)

---

## [Mobile] #1568 — Rider views past trip detail
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a rider, I want to view the full details of a past trip so that I can understand the fare breakdown and confirm where I travelled.

### Background
When a rider taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the complete picture of that trip: timing, addresses, fare breakdown, and who drove her. If she previously submitted a star rating for this trip, that rating is also shown. The screen is read-only — no actions are available.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Rider views detail of a rated trip**
- Given the rider has navigated to the detail screen for a past trip she rated
- When the screen loads
- Then it displays: date and time, pickup address, destination address, total fare (EGP), fare breakdown (base fare + distance charge + time charge), trip duration, distance travelled, driver name, and vehicle information
- And the star rating she submitted is shown

**Scenario 2 — Rider views detail of an unrated trip**
- Given the rider has navigated to the detail screen for a past trip she did not rate
- When the screen loads
- Then all trip details are shown as in Scenario 1
- And the rating section is absent or shows a placeholder indicating no rating was given

**Scenario 3 — Rider navigates back to the list**
- Given the rider is on the trip detail screen
- When she presses the back button
- Then she is returned to the trip history list at the same scroll position

### Out of Scope
- Submitting or editing a rating from this screen
- Disputing a fare
- Contacting the driver
- SOS history

### Dependencies
- #1641 — Rider retrieves trip history (must be live)
- #1637 — Trip rating is stored (must be live)

---

## [Mobile] #1593 — Driver views trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a driver, I want to view a list of my completed trips so that I can track my earnings and activity over time.

### Background
Drivers access trip history from the menu or profile section of the app. The list shows completed trips only, sorted most recent first, with a summary of each trip's destination area and cash fare collected. Tapping a row opens the full trip detail screen (#1594). If the driver has not yet completed any trips, an empty state is displayed.

### Field Validation
N/A

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

## [Mobile] #1594 — Driver views past trip detail
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As a driver, I want to view the full details of a past trip so that I can review the route, duration, and the rating I received.

### Background
When a driver taps a row in her trip history list, she is taken to the trip detail screen. This screen shows the full picture of that trip from the driver's perspective: timing, pickup and destination addresses, cash fare collected, trip duration, distance, and the star rating the rider gave (if submitted). If the rider skipped rating, the screen shows a localised placeholder. The screen is read-only.

### Field Validation
N/A

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

## [API] #1641 — Rider retrieves trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As the rider app, I want to retrieve a paginated list of the authenticated rider's past trips so that the trip history screen can display accurate trip data.

### Background
The rider trip history endpoint is called each time the rider opens the trip history screen or loads a new page of results. It returns trips belonging only to the authenticated rider, ordered by date descending. Each item in the response includes the fields needed to render a summary row. The endpoint supports page-number-based pagination. Unauthenticated requests are rejected before any data is accessed.

### Field Validation
N/A

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
- Then the response contains an empty list
- And pagination metadata reflects zero records

**Scenario 3 — Rider requests a subsequent page**
- Given the rider has trips spanning multiple pages
- When the rider app requests page two
- Then the response contains the correct slice of trips for that page in date descending order

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- When a request is made to the rider trip history endpoint
- Then the request is rejected with an authentication error
- And no trip data is returned

### Out of Scope
- Filtering by date range or status
- Cancelled or in-progress trips in the response
- Driver-facing history

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1655 — Driver retrieves trip history
**Feature:** Trip History — Rider & Driver | **Sprint:** 2

**Description:** As the driver app, I want to retrieve a paginated list of the authenticated driver's completed trips so that the trip history screen can display accurate trip data.

### Background
The driver trip history endpoint is called each time the driver opens the trip history screen or loads a new page. It returns only completed trips belonging to the authenticated driver, ordered by date descending. Each item includes the fields needed to render a summary row on the driver's history screen. The endpoint supports page-number-based pagination. Unauthenticated requests are rejected before any data is accessed.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Driver with completed trips retrieves page one**
- Given the driver is authenticated and has completed trips
- When the driver app requests page one of trip history
- Then the response contains a list of completed trips ordered by date descending
- And each item includes: trip ID, date, destination area, and cash fare collected (EGP)
- And pagination metadata is included

**Scenario 2 — Driver with no completed trips retrieves history**
- Given the driver is authenticated and has no completed trips
- When the driver app requests trip history
- Then the response contains an empty list
- And pagination metadata reflects zero records

**Scenario 3 — Driver requests a subsequent page**
- Given the driver has trips spanning multiple pages
- When the driver app requests page two
- Then the response contains the correct slice of trips for that page

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid session token is provided
- When a request is made to the driver trip history endpoint
- Then the request is rejected with an authentication error
- And no trip data is returned

### Out of Scope
- Filtering by date range
- Earnings totals or aggregates
- Rider-facing history

### Dependencies
- #1619 — Session validation (must be live)

---

## [Admin] #1661 — Admin views rider list
**Feature:** Admin — Rider Management | **Sprint:** 2

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
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a rider's full profile and their trip history so that I can understand their account activity.

### Background
The rider profile screen is opened by clicking any row in the rider list (#1661). It presents the rider's personal information at the top, followed by a paginated list of the rider's past trips below. All information is read-only in these sprints. The admin can paginate through the trip history without leaving the profile screen.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin opens a rider profile**
- Given the admin has clicked a rider row in the rider list
- When the profile screen loads
- Then the following information is shown: full name, phone number, registration date, total trips completed, and date of last trip
- And below the profile, a paginated list of the rider's past trips is displayed

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
- Banning or suspending the rider
- Viewing trip details from within the profile (trip row is not clickable in this sprint)
- Exporting rider data

### Dependencies
- #1664 — Rider profile with trip history is served (must be live)

---

## [API] #1663 — Rider list with search and filters is served
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, searchable list of riders to the admin portal so that operations admins can browse and locate rider accounts.

### Background
The rider list endpoint is called by the admin portal when the Riders section is opened and on every search keystroke or page change. It requires a valid admin session token. The response includes a page of rider records with the fields needed to render the table. Optional search by name or phone narrows results. Default sort is registration date descending.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests the full rider list**
- Given the admin is authenticated and sends no search parameter
- When the rider list endpoint is called
- Then a paginated list of all riders is returned ordered by registration date descending
- And each record includes: rider ID, full name, phone number, registration date, and completed trip count
- And pagination metadata (page, total pages, total count) is included

**Scenario 2 — Admin requests the list with a name search**
- Given the admin sends a search parameter containing a name substring
- When the endpoint is called
- Then only riders whose name contains that substring (case-insensitive) are returned

**Scenario 3 — Admin requests the list with a phone search**
- Given the admin sends a search parameter containing a phone substring
- When the endpoint is called
- Then only riders whose phone number contains that substring are returned

**Scenario 4 — Search returns no matching riders**
- Given the admin sends a search parameter that matches no rider
- When the endpoint is called
- Then an empty list is returned with total count zero

**Scenario 5 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the rider list endpoint
- Then the request is rejected with an authentication error
- And no rider data is returned

**Scenario 6 — Admin requests a subsequent page**
- Given there are more riders than fit on one page
- When the admin requests page two
- Then the correct slice of rider records for that page is returned

### Out of Scope
- Filtering by registration date range
- Sorting by columns other than registration date
- Exporting results

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1664 — Rider profile with trip history is served
**Feature:** Admin — Rider Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single rider's profile and paginated trip history to the admin portal so that operations admins can review full account details.

### Background
The rider profile endpoint is called when the admin clicks a rider row in the list. It returns all profile fields needed for the profile screen header and a paginated subset of the rider's trip history. The endpoint requires a valid admin session token. If the requested rider ID does not exist, a not-found response is returned.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests a valid rider profile**
- Given the admin is authenticated and provides a valid rider ID
- When the rider profile endpoint is called
- Then the response includes: full name, phone number, registration date, total trips completed, and last trip date
- And a paginated list of the rider's past trips is included, each with: trip date, destination address, fare (EGP), and status

**Scenario 2 — Rider has no past trips**
- Given the admin requests the profile of a rider with no completed trips
- When the endpoint is called
- Then the profile fields are returned normally
- And the trip history list is empty with total count zero

**Scenario 3 — Admin requests a non-existent rider ID**
- Given the admin provides a rider ID that does not exist in the system
- When the endpoint is called
- Then a not-found response is returned
- And no data is included in the response body

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the rider profile endpoint
- Then the request is rejected with an authentication error

**Scenario 5 — Admin requests a subsequent page of trip history**
- Given the rider has more trips than fit on one page
- When the admin requests page two of the trip history
- Then the correct page of trip records is returned in date descending order

### Out of Scope
- Editing rider fields via this endpoint
- Trip detail fields beyond the list summary
- Exporting profile data

### Dependencies
- #1619 — Session validation (must be live)
- #1641 — Rider retrieves trip history (must be live)

---

## [Admin] #1665 — Admin views driver list across all statuses
**Feature:** Admin — Driver Management | **Sprint:** 2

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
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As an operations admin, I want to view a driver's full profile including their documents, vehicle details, and trip history so that I can assess their account comprehensively.

### Background
The driver profile screen is opened by clicking any row in the driver list (#1665). It presents personal details, vehicle information, uploaded document images (viewable inline), current status, aggregate statistics, and — for pending or rejected drivers — the decision history. Below the profile information, a paginated list of the driver's completed trips is shown. All content is read-only on this screen in sprint 2; approve/reject actions remain on the pending queue screens (#1657–#1660).

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin opens an approved driver profile**
- Given the admin has clicked an approved driver row
- When the profile screen loads
- Then the following sections are displayed: personal details (name, phone, date of birth, masked national ID), vehicle details (make, model, plate number, colour), document images (viewable inline), vehicle photo, status badge "Approved", total trips completed, and average rider rating

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

## [API] #1667 — Driver list with status filter and search is served
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, filterable list of driver accounts to the admin portal so that operations admins can browse the full driver pipeline by status.

### Background
The driver list endpoint is called when the admin opens the Drivers section and on each filter change, search keystroke, or page change. It requires a valid admin session token. The response includes driver records with the fields needed to render the table. Optional status filter and name/phone search narrow the result set. Default order is submission date descending.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests the full driver list**
- Given the admin is authenticated and sends no filter or search parameter
- When the driver list endpoint is called
- Then a paginated list of all driver accounts is returned ordered by submission date descending
- And each record includes: driver ID, name, phone, status, submission date, and completed trip count
- And pagination metadata is included

**Scenario 2 — Admin filters by status**
- Given the admin sends a status parameter of "pending", "approved", or "rejected"
- When the endpoint is called
- Then only drivers matching that status are returned

**Scenario 3 — Admin searches by name**
- Given the admin sends a search parameter containing a name substring
- When the endpoint is called
- Then only drivers whose name contains that substring (case-insensitive) are returned

**Scenario 4 — Admin searches by phone**
- Given the admin sends a search parameter containing a phone substring
- When the endpoint is called
- Then only drivers whose phone contains that substring are returned

**Scenario 5 — Filter and search return no results**
- Given the admin sends parameters that match no driver
- When the endpoint is called
- Then an empty list is returned with total count zero

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the driver list endpoint
- Then the request is rejected with an authentication error
- And no driver data is returned

**Scenario 7 — Admin requests a subsequent page**
- Given there are more drivers than fit on one page
- When the admin requests page two
- Then the correct slice of driver records is returned

### Out of Scope
- Filtering by registration date range
- Sorting by columns other than submission date
- Exporting results

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1668 — Driver profile with trip history is served
**Feature:** Admin — Driver Management | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single driver's full profile and paginated trip history to the admin portal so that operations admins can review complete driver account details.

### Background
The driver profile endpoint is called when the admin clicks a driver row in the list. It returns personal details, vehicle information, document URLs (so the portal can display images inline), current status, average rating, decision history, and a paginated slice of the driver's completed trip history. The endpoint requires a valid admin session token. A not-found response is returned if the driver ID does not exist.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests a valid driver profile**
- Given the admin is authenticated and provides a valid driver ID
- When the driver profile endpoint is called
- Then the response includes: personal details (name, phone, date of birth, masked national ID), vehicle details, document image URLs, vehicle photo URL, current status, total trips completed, average rider rating, and decision history records
- And a paginated list of completed trips is included, each with: trip date, destination area, fare collected, and rider rating received

**Scenario 2 — Driver has no completed trips**
- Given the admin requests the profile of a driver with no completed trips
- When the endpoint is called
- Then the profile fields are returned normally
- And the trip history list is empty with total count zero

**Scenario 3 — Admin requests a non-existent driver ID**
- Given the admin provides a driver ID that does not exist in the system
- When the endpoint is called
- Then a not-found response is returned
- And no data is included in the response body

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the driver profile endpoint
- Then the request is rejected with an authentication error

**Scenario 5 — Admin requests a subsequent page of trip history**
- Given the driver has more trips than fit on one page
- When the admin requests page two
- Then the correct page of trip records is returned in date descending order

### Out of Scope
- Approve or reject actions via this endpoint
- Editing driver fields
- Exporting profile data

### Dependencies
- #1619 — Session validation (must be live)

---

## [Admin] #1669 — Admin sees live summary dashboard
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see a live summary of key platform metrics on the dashboard so that I can monitor the health of the service at a glance.

### Background
The dashboard is the landing page of the admin portal after login. It presents six live key metrics in summary cards: active trips, online drivers, total trips today, total registered riders, and total approved drivers. The metrics refresh automatically every 30 seconds without requiring a page reload. Each card shows a label, a numeric value, and a last-refreshed timestamp.

### Field Validation
N/A

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

## [Admin] #1670 — Admin views trip list
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a searchable, filterable list of all trips on the platform so that I can monitor trip activity and investigate specific trips.

### Background
The trip list screen shows all trips across all statuses. The admin can filter by trip status, apply a date range, and search by rider or driver name or phone. Columns provide enough information to identify a trip at a glance. Clicking any row opens the trip detail screen (#1671). The default page size is 20 rows ordered by creation date descending.

### Field Validation

| Field | Required | Format | Min | Max | Accepted characters | Error — empty | Error — invalid format | Error — length |
|---|---|---|---|---|---|---|---|---|
| Search | No | Free text | 0 chars | 100 chars | Any | Show all trips (no error) | N/A | Clear input and reset to full list |
| Status filter | No | Enum | N/A | N/A | All, Searching, Active, Completed, Expired | Show all statuses (default = All) | N/A | N/A |
| Date from | No | Date (YYYY-MM-DD) | N/A | N/A | Digits and hyphens | Show no date constraint | Inline error: "Invalid date" | N/A |
| Date to | No | Date (YYYY-MM-DD) | N/A | N/A | Digits and hyphens | Show no date constraint | Inline error: "Invalid date" | N/A — but to-date must not be before from-date; inline error: "End date must be after start date" |

### Acceptance Criteria

**Scenario 1 — Admin opens the trip list**
- Given the admin navigates to the Trips section
- When the page loads
- Then a table of all trips is displayed ordered by creation date descending
- And columns shown are: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, for completed trips), and date

**Scenario 2 — Admin filters by status**
- Given the trip list is loaded
- When the admin selects a status filter (e.g., "Active")
- Then only trips with that status are shown

**Scenario 3 — Admin applies a date range**
- Given the trip list is loaded
- When the admin sets a from-date and a to-date
- Then only trips created within that date range are shown

**Scenario 4 — Admin sets an invalid date range (to before from)**
- Given the admin has set a from-date
- When the admin sets a to-date that is earlier than the from-date
- Then an inline error "End date must be after start date" is displayed
- And the trip list is not filtered until the date range is corrected

**Scenario 5 — Admin searches by rider or driver name**
- Given the trip list is loaded
- When the admin types a partial name into the search box
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
- Then the portal navigates to the trip detail screen (#1671) for that trip

**Scenario 9 — Admin paginates the list**
- Given the filtered list has more than 20 entries
- When the admin navigates to the next page
- Then the next 20 trips are displayed

### Out of Scope
- Cancelling a trip from this screen
- Contacting the rider or driver from this screen
- Exporting the trip list
- Surge pricing adjustments

### Dependencies
- #1674 — Trip list with pagination and filters is served (must be live)

---

## [Admin] #1671 — Admin views trip detail with state history
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to view a trip's full detail and state transition timeline so that I can understand exactly how that trip progressed.

### Background
The trip detail screen is opened by clicking any row in the trip list (#1670). It shows rider and driver information, the pickup and destination addresses, and a chronological timeline of every state the trip passed through with timestamps. The timeline makes it possible to identify where a trip stalled or what sequence of events occurred. The screen is read-only.

### Field Validation
N/A

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
- And a note is shown indicating no driver was matched

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

## [Admin] #1672 — Admin views completed trip with fare and rating
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As an operations admin, I want to see the fare breakdown and rider rating on a completed trip's detail screen so that I can verify charges and understand the rider's experience.

### Background
The completed trip detail screen extends the general trip detail screen (#1671) with two additional sections visible only for completed trips: a fare breakdown table and the rider's rating. The fare breakdown shows how the total charge was composed. The rating section shows stars and any tags the rider selected; if the rider skipped rating, it shows "No rating given". The screen remains read-only.

### Field Validation
N/A

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
- #1637 — Trip rating is stored (must be live)

---

## [API] #1673 — Dashboard summary is served
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve live platform metric counts to the admin portal so that the dashboard can display accurate, up-to-date operational summaries.

### Background
The dashboard summary endpoint is called by the admin portal on initial load and every 30 seconds thereafter. It requires a valid admin session token. It computes and returns five live counts at request time: active trips, online drivers, trips created today, total registered riders, and total approved drivers. No caching is required in these sprints — the data is computed fresh on each call.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin portal requests the dashboard summary**
- Given the admin is authenticated
- When the dashboard summary endpoint is called
- Then the response includes: active_trips (count of trips currently in active status), online_drivers (count of drivers currently available), trips_today (count of trips created since midnight local time), total_riders (count of all registered riders), total_approved_drivers (count of all approved drivers)
- And all counts are integers greater than or equal to zero

**Scenario 2 — All metrics are zero on an idle day**
- Given no trips are active, no drivers are online, and no trips have been created today
- When the endpoint is called
- Then all counts return as zero

**Scenario 3 — Counts reflect the current state**
- Given a trip transitions to active status between two calls to the endpoint
- When the endpoint is called after the transition
- Then the active_trips count is incremented accordingly

**Scenario 4 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the dashboard summary endpoint
- Then the request is rejected with an authentication error
- And no metric data is returned

### Out of Scope
- Historical time-series data
- Per-city or per-zone breakdowns
- Caching or pre-computation
- Alert thresholds

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1674 — Trip list with pagination and filters is served
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a paginated, filterable list of all trips to the admin portal so that operations admins can monitor platform activity and find specific trips.

### Background
The trip list endpoint is called when the admin opens the Trips section and on each filter change, search input, or page change. It requires a valid admin session token. Optional parameters include: status filter, date range (from/to), and search string (matched against rider/driver name and phone). Default order is creation date descending with a page size of 20.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests the full trip list**
- Given the admin is authenticated and sends no filter parameters
- When the trip list endpoint is called
- Then a paginated list of all trips is returned ordered by creation date descending
- And each record includes: trip ID, rider name, driver name, pickup area, destination area, status, fare (EGP, null for non-completed trips), and creation date
- And pagination metadata (page, total pages, total count) is included

**Scenario 2 — Admin filters by status**
- Given the admin sends a status parameter (e.g., "active")
- When the endpoint is called
- Then only trips with that status are returned

**Scenario 3 — Admin filters by date range**
- Given the admin sends a from-date and a to-date
- When the endpoint is called
- Then only trips created within that date range (inclusive) are returned

**Scenario 4 — Admin searches by rider or driver name**
- Given the admin sends a search parameter
- When the endpoint is called
- Then trips where the rider name, driver name, rider phone, or driver phone contains that substring are returned

**Scenario 5 — Filters return no results**
- Given the admin sends parameters that match no trip
- When the endpoint is called
- Then an empty list is returned with total count zero

**Scenario 6 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the trip list endpoint
- Then the request is rejected with an authentication error
- And no trip data is returned

**Scenario 7 — Admin requests a subsequent page**
- Given there are more trips than fit on one page
- When the admin requests page two
- Then the correct slice of trip records is returned maintaining the applied filters and sort order

### Out of Scope
- Sorting by columns other than creation date
- Exporting results
- Cancelling a trip via this endpoint

### Dependencies
- #1619 — Session validation (must be live)

---

## [API] #1675 — Trip detail with state history is served
**Feature:** Admin Operations Dashboard | **Sprint:** 2

**Description:** As the SheDrive platform, I want to serve a single trip's full details and state transition history to the admin portal so that operations admins can investigate the full lifecycle of any trip.

### Background
The trip detail endpoint is called when the admin clicks a trip row in the trip list. It returns all information needed to render the trip detail screen: rider and driver information, addresses, all state transition records with timestamps, and — if the trip is completed — the fare breakdown and rider rating. A not-found response is returned if the trip ID does not exist.

### Field Validation
N/A

### Acceptance Criteria

**Scenario 1 — Admin requests details of an in-progress trip**
- Given the admin is authenticated and provides a valid trip ID for an active trip
- When the trip detail endpoint is called
- Then the response includes: rider info (name, phone), driver info (name, phone, vehicle), pickup address, destination address, and a list of all state transitions with timestamps up to the current state

**Scenario 2 — Admin requests details of a completed trip**
- Given the admin provides a valid trip ID for a completed trip
- When the endpoint is called
- Then all fields from Scenario 1 are returned plus: fare breakdown (base, distance, time, total, cash collected) and rider rating (stars and tags if rated, null if not rated)

**Scenario 3 — Admin requests details of an expired trip**
- Given the admin provides a valid trip ID for an expired trip
- When the endpoint is called
- Then rider info, addresses, and the state transitions up to "Expired" with timestamps are returned
- And driver info is null as no driver was matched

**Scenario 4 — Admin requests a non-existent trip ID**
- Given the admin provides a trip ID that does not exist
- When the endpoint is called
- Then a not-found response is returned
- And no data is included in the response body

**Scenario 5 — Unauthenticated request is rejected**
- Given no valid admin session token is provided
- When a request is made to the trip detail endpoint
- Then the request is rejected with an authentication error

### Out of Scope
- Modifying trip status via this endpoint
- Real-time streaming of state changes
- SOS event records

### Dependencies
- #1619 — Session validation (must be live)
- #1652 — Trip state transitions are recorded (must be live)
