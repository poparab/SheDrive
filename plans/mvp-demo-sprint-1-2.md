# SheDrive — Demo MVP: Sprint 1 & Sprint 2

> **Purpose:** Define the minimum production-quality slice across all three surfaces — Rider app, Driver app, and Admin portal — that demonstrates a complete trip cycle at the end of Sprint 2.
> Everything built in these sprints is kept and continued in future sprints.

---

## Demo Scenario

> A driver registers, submits her onboarding documents and car photo, and is approved by an admin.
> A rider registers and books a ride.
> The driver receives a push notification for the request, accepts within 10 seconds, confirms the rider's identity at pickup, and completes the trip.
> The rider pays in cash and rates the driver.
> The admin portal shows drivers, riders, and the full trip lifecycle live.

---

## Scope Decisions

| Area | Decision |
|------|----------|
| Rider identity verification | Removed from tech scope. Driver confirms rider identity manually at pickup on the rider's first trip. |
| Driver resubmission after rejection | Deferred. A rejected driver cannot resubmit in these sprints. |
| Trip cancellation | Deferred. Neither rider nor driver can cancel in these sprints. |
| In-app masked calling | Out of scope for Phase 1. |
| Payment | Cash only. Fare is calculated and displayed. No PSP in these sprints. |
| SOS | Out of scope for these two sprints. |
| Driver acceptance window | 10 seconds. Non-response is treated as rejection and trip is reassigned. |
| Push notifications | In scope. Used for all background state changes. OTP edge cases handled within Register and Login stories. |

---

## Out of Scope for These Two Sprints

- SOS and emergency features
- Trip cancellation by rider or driver
- Driver resubmission after rejected onboarding
- Payment gateway / PSP integration
- In-app masked calling
- Trusted contacts management
- Driver earnings and payout
- Zone restrictions and surge pricing
- Scheduled rides
- Audit log, reports, and exports
- Account suspension and reactivation

---

## Sprint 1 — Everyone Is Live & Ready

**Sprint goal:** Rider and driver can register, log in, and log out. Driver completes onboarding and is approved by admin. Driver is available on the map. Rider can search addresses and see a fare estimate. Platform is wired to SMS, Google Maps, and push notifications.

---

### Feature 1: Platform & Integration Foundation

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [API] | SMS gateway delivers OTP to Egyptian mobile numbers | #1616 | 1 |
| [API] | Google Maps returns route distance and duration | #1617 | 1 |
| [API] | Push notification service delivers to iOS and Android | #1618 | 1 |
| [API] | Auth middleware validates session tokens on all protected endpoints | #1619 | 1 |
| [Admin] | Admin portal shell and login screen are in place | #1656 | 1 |

---

### Feature 2: Rider Authentication

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Rider registers | #1545 | 1 |
| [Mobile] | Rider logs in | #1546 | 1 |
| [Mobile] | Rider logs out | #1547 | 1 |

---

### Feature 3: Driver Authentication

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Driver registers and is directed to onboarding | #1569 | 1 |
| [Mobile] | Driver logs in | #1570 | 1 |
| [Mobile] | Driver logs out | #1571 | 1 |

---

### Feature 4: Authentication API (Shared — Rider & Driver)

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [API] | User requests OTP via SMS | #1620 | 1 |
| [API] | User registers with OTP verification | #1621 | 1 |
| [API] | User logs in with OTP verification | #1622 | 1 |
| [API] | User retrieves own profile | #1623 | 1 |
| [API] | User session is invalidated on logout | #1624 | 1 |
| [API] | User registers device token for push notifications | #1625 | 1 |

---

### Feature 5: Driver Onboarding & Admin Approval

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Driver submits personal details | #1572 | 1 |
| [Mobile] | Driver submits vehicle details | #1573 | 1 |
| [Mobile] | Driver photographs her vehicle | #1574 | 1 |
| [Mobile] | Driver uploads licence and vehicle registration documents | #1575 | 1 |
| [Mobile] | Driver sees pending state until approved | #1576 | 1 |
| [Mobile] | Driver receives push on application decision | #1577 | 1 |
| [API] | Driver submits onboarding application | #1642 | 1 |
| [API] | Driver queries onboarding status | #1643 | 1 |
| [API] | Driver is blocked from going online until approved | #1644 | 1 |
| [Admin] | Admin views pending applications queue | #1657 | 1 |
| [Admin] | Admin views full driver application | #1658 | 1 |
| [Admin] | Admin approves driver application | #1659 | 1 |
| [Admin] | Admin rejects driver application with reason | #1660 | 1 |

---

### Feature 6: Driver Home & Availability

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Driver sees home screen with map | #1578 | 1 |
| [Mobile] | Driver toggles online and offline | #1579 | 1 |
| [Mobile] | Driver location updates while online | #1580 | 1 |
| [API] | Driver sets availability status | #1645 | 1 |
| [API] | Driver updates GPS location | #1646 | 1 |

---

### Feature 7: Rider Home, Address Search & Fare Estimate

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Rider sees home screen with map | #1548 | 1 |
| [Mobile] | Rider searches address with autocomplete | #1549 | 1 |
| [Mobile] | Rider sets pickup point | #1550 | 1 |
| [Mobile] | Rider sets destination | #1551 | 1 |
| [Mobile] | Rider sees fare estimate before requesting | #1552 | 1 |
| [API] | Address autocomplete returns suggestions | #1626 | 1 |
| [API] | Fare estimate uses Google Maps route data | #1627 | 1 |
| [API] | Fare applies base, per-km, and per-minute rates | #1628 | 1 |

---

## Sprint 2 — The Full Trip Cycle

**Sprint goal:** Rider books, driver accepts within 10 seconds, trip runs end to end, rider pays cash and rates the driver. Rider and driver can see their trip history and detail. Admin portal provides full visibility into riders, drivers across all statuses, and trips.

---

### Feature 8: Trip Request & Matching

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Rider submits trip request | #1553 | 2 |
| [Mobile] | Rider sees matching screen | #1554 | 2 |
| [Mobile] | Rider sees confirmed driver card | #1555 | 2 |
| [Mobile] | Rider receives push on match confirmation | #1556 | 2 |
| [Mobile] | Rider sees no-driver error and returns home | #1557 | 2 |
| [API] | Rider creates trip request | #1629 | 2 |
| [API] | System matches request to nearest available driver | #1630 | 2 |
| [API] | Rider polls for match status | #1631 | 2 |
| [API] | Trip expires and rider is notified via push | #1632 | 2 |

---

### Feature 9: Driver Trip Acceptance

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Driver receives push for incoming trip request | #1581 | 2 |
| [Mobile] | Driver sees trip request details | #1582 | 2 |
| [Mobile] | Driver accepts trip | #1583 | 2 |
| [Mobile] | Driver rejects trip and returns to available | #1584 | 2 |
| [Mobile] | Driver acceptance screen expires after 10 seconds | #1585 | 2 |
| [API] | System pushes trip request to matched driver | #1647 | 2 |
| [API] | Driver retrieves pending trip request | #1648 | 2 |
| [API] | Driver accepts trip | #1649 | 2 |
| [API] | Driver rejects trip | #1650 | 2 |
| [API] | Trip is reassigned on rejection or timeout | #1651 | 2 |

---

### Feature 10: Active Trip

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Driver navigates to pickup | #1586 | 2 |
| [Mobile] | Driver confirms arrival at pickup | #1587 | 2 |
| [Mobile] | Driver confirms rider identity on first trip | #1588 | 2 |
| [Mobile] | Driver confirms rider has boarded | #1589 | 2 |
| [Mobile] | Driver navigates to destination | #1590 | 2 |
| [Mobile] | Driver ends trip at destination | #1591 | 2 |
| [Mobile] | Rider sees driver live location while waiting | #1558 | 2 |
| [Mobile] | Rider sees driver-arrived state | #1559 | 2 |
| [Mobile] | Rider receives push when driver arrives | #1560 | 2 |
| [Mobile] | Rider sees driver live location during trip | #1561 | 2 |
| [Mobile] | Rider sees driver details during trip | #1562 | 2 |
| [API] | Driver advances trip state machine | #1652 | 2 |
| [API] | Driver streams GPS from acceptance to completion | #1653 | 2 |
| [API] | Rider retrieves live trip state and driver location | #1633 | 2 |
| [API] | System pushes driver-arrived to rider | #1634 | 2 |
| [API] | Trip detail includes first-trip flag | #1635 | 2 |

---

### Feature 11: Trip Completion & Cash Payment

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Rider receives push on trip completion | #1563 | 2 |
| [Mobile] | Rider sees trip summary with cash fare | #1564 | 2 |
| [Mobile] | Rider rates driver | #1565 | 2 |
| [Mobile] | Rider skips rating | #1566 | 2 |
| [Mobile] | Driver sees cash fare to collect and returns to available | #1592 | 2 |
| [API] | Final fare is calculated from actual route and duration | #1636 | 2 |
| [API] | Completed trip is served with fare breakdown | #1637 | 2 |
| [API] | System pushes trip completion to rider | #1638 | 2 |
| [API] | Rider submits driver rating | #1639 | 2 |
| [API] | Driver aggregate rating is updated | #1654 | 2 |
| [API] | Trip closes without rating on skip | #1640 | 2 |

---

### Feature 12: Trip History — Rider & Driver

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Mobile] | Rider views trip history | #1567 | 2 |
| [Mobile] | Rider views past trip detail | #1568 | 2 |
| [Mobile] | Driver views trip history | #1593 | 2 |
| [Mobile] | Driver views past trip detail | #1594 | 2 |
| [API] | Rider retrieves trip history | #1641 | 2 |
| [API] | Driver retrieves trip history | #1655 | 2 |

---

### Feature 13: Admin — Rider Management

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Admin] | Admin views rider list | #1661 | 2 |
| [Admin] | Admin views rider profile | #1662 | 2 |
| [API] | Rider list with search and filters is served | #1663 | 2 |
| [API] | Rider profile with trip history is served | #1664 | 2 |

---

### Feature 14: Admin — Driver Management

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Admin] | Admin views driver list across all statuses | #1665 | 2 |
| [Admin] | Admin views driver profile | #1666 | 2 |
| [API] | Driver list with status filter and search is served | #1667 | 2 |
| [API] | Driver profile with trip history is served | #1668 | 2 |

---

### Feature 15: Admin Operations Dashboard

| Track | Story Title | ADO # | Priority |
|-------|-------------|-------|----------|
| [Admin] | Admin sees live summary dashboard | #1669 | 2 |
| [Admin] | Admin views trip list | #1670 | 2 |
| [Admin] | Admin views trip detail with state history | #1671 | 2 |
| [Admin] | Admin views completed trip with fare and rating | #1672 | 2 |
| [API] | Dashboard summary is served | #1673 | 2 |
| [API] | Trip list with pagination and filters is served | #1674 | 2 |
| [API] | Trip detail with state history is served | #1675 | 2 |

---

## Story Count Summary

| Sprint | Feature | Mobile | API | Admin | Total |
|--------|---------|--------|-----|-------|-------|
| 1 | Platform & Integration Foundation | — | 4 | 1 | 5 |
| 1 | Rider Authentication | 3 | — | — | 3 |
| 1 | Driver Authentication | 3 | — | — | 3 |
| 1 | Authentication API (shared) | — | 6 | — | 6 |
| 1 | Driver Onboarding & Admin Approval | 6 | 3 | 4 | 13 |
| 1 | Driver Home & Availability | 3 | 2 | — | 5 |
| 1 | Rider Home, Address Search & Fare Estimate | 5 | 3 | — | 8 |
| | **Sprint 1 Total** | **20** | **18** | **5** | **43** |
| 2 | Trip Request & Matching | 5 | 4 | — | 9 |
| 2 | Driver Trip Acceptance | 5 | 5 | — | 10 |
| 2 | Active Trip | 11 | 5 | — | 16 |
| 2 | Trip Completion & Cash Payment | 5 | 6 | — | 11 |
| 2 | Trip History — Rider & Driver | 4 | 2 | — | 6 |
| 2 | Admin — Rider Management | — | 2 | 2 | 4 |
| 2 | Admin — Driver Management | — | 2 | 2 | 4 |
| 2 | Admin Operations Dashboard | — | 3 | 4 | 7 |
| | **Sprint 2 Total** | **30** | **29** | **8** | **67** |
| | **Grand Total** | **50** | **47** | **13** | **110** |

---

## Team Split

| Team | Sprint 1 | Sprint 2 | Total |
|------|----------|----------|-------|
| Mobile (Rider + Driver apps) | 20 | 30 | 50 |
| Web / Main (API + Admin portal) | 23 | 37 | 60 |

Sprint 2 is heavier than Sprint 1, particularly on Mobile, because the entire trip lifecycle lands in a single sprint. Teams should plan Sprint 2 capacity accordingly.

---

## Recommended Next Step

Run each feature through the **SheDrive Story Writer** agent to produce full acceptance criteria, validation tables, and Azure DevOps work items ready for sprint planning. Story titles above are scope markers — each needs a full INVEST check and acceptance criteria before it is Definition of Ready.
