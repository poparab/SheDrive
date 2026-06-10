# #1735 — [API] Driver retrieves earnings summary

**Area:** SheDrive (Web / Main)
**Type:** User Story
**State:** New

## User Story

As the driver app, I want to retrieve the authenticated driver's earnings summary so that the earnings dashboard can display accurate income figures.

## Background

This endpoint returns aggregated earnings data for the authenticated driver, broken into three time windows: today (from midnight local time), this week (from Monday midnight), and this month (from the 1st of the month). Each window returns `total_earnings_egp` and `trip_count`. The response also includes a paginated list of recent completed trips with `date`, `pickup_area`, `destination_area`, and `fare_egp`. Only completed trips are counted. Cancelled trips are excluded.

## Acceptance Criteria

**Scenario 1 — Earnings returned for driver with completed trips**
- Given an authenticated driver with at least one completed trip sends a GET request
- When the endpoint is called
- Then the response includes `today`, `this_week`, and `this_month` summaries
- And each summary includes `total_earnings_egp` and `trip_count`
- And a paginated list of recent trips is included

**Scenario 2 — Zero earnings returned for driver with no trips**
- Given an authenticated driver with no completed trips sends a GET request
- Then the response returns `0` for all earnings and trip counts
- And the recent trips list is empty

**Scenario 3 — Cancelled trips are excluded from earnings**
- Given a driver has trips in `cancelled` state
- When the earnings endpoint is called
- Then cancelled trips do not appear in earnings totals or the recent trips list

**Scenario 4 — Unauthenticated request is rejected**
- Given a request arrives without a valid auth token
- Then the platform rejects it via #1619

## Out of Scope
- Custom date range filtering
- Earnings export
- Tip amounts

## Dependencies
- #1619 — Authentication service (must be live)
