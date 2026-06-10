# #1736 — [Mobile] Driver views earnings dashboard

**Area:** SheDrive\SheDrive Mobile Team
**Type:** User Story
**State:** New

## User Story

As a driver, I want to view a summary of my earnings so that I can track my income and performance over time.

## Background

The earnings dashboard is accessible from the driver home screen menu or profile screen. It shows earnings summary cards for today, this week, and this month. Each card shows total earnings in EGP and number of trips completed. Below the summary cards, a list of recent trips shows each trip's date, route summary, and fare. Data is fetched from #1735 on screen load. Pull-to-refresh updates all figures.

## Acceptance Criteria

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

## Out of Scope
- Earnings breakdown by individual day within a week
- Export or download of earnings report
- Tip amounts

## Dependencies
- #1735 — Driver retrieves earnings summary (API — must be live)
