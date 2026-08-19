# Admin Wireframes

## Purpose

Tracks the SheDrive admin portal screen set, its mapping to `[Admin]` backlog stories,
and the open questions the mockups surfaced.

Mockups are **coded, not drawn** — they live at `shedrive-web/admin/` and are built on
the production front-end stack (vanilla HTML/CSS/ES modules) so they double as the
scaffold the dev team extends when the API lands.

- **Designer entry point:** https://shedrive-web.abdelrahman-arcorp.workers.dev/admin/screens
  — sign in with `ops.lead@shedrive.app` / `shedrive2026`, then 2FA code `123456`
- **Component + mock API contract:** [admin-component-contract.md](admin-component-contract.md)
- **Build status per screen:** [../design-review/admin-screen-tracker.md](../design-review/admin-screen-tracker.md)
- **Local preview:** see [preview-workflow.md](preview-workflow.md), then `/admin/`

## UX Rules

- desktop-first (verified at 1280 px and 1440 px)
- English-only for MVP — no `data-i18n` plumbing in the admin portal
- operational density over marketing polish
- every grid has explicit columns and filters, taken from each story's
  **List / Grid Specification**
- every form's validation comes from the story's **Field Validation** table
- single admin role this phase: **super admin**, full privileges on every screen

## Screen Set — 11 nav areas, 18 screens

List and detail are separate URLs so the designer can deep-link any screen and the
"back to list at the same filter state" criteria in #1662/#1666/#1671 hold.

| # | Nav area | Screen file | Stories |
|---|---|---|---|
| — | *(unauthenticated)* | `index.html` | #1656, #1806, #1822 |
| 1 | Dashboard | `dashboard.html` | #1669, #1823, #1824, #1825, #1826 |
| 2 | Driver applications | `driver-applications.html` | #1657 |
| | | `driver-application.html` | #1658, #1659, #1660 |
| 3 | Drivers | `drivers.html` | #1665 |
| | | `driver-profile.html` | #1666, #1742, #1743 |
| 4 | Riders | `riders.html` | #1661 |
| | | `rider-profile.html` | #1662, #1740, #1741 |
| 5 | Trips | `trips.html` | #1670 |
| | | `trip-detail.html` | #1671, #1672 |
| 6 | Safety reports | `safety-reports.html` | #1810 |
| | | `safety-report.html` | #1810, #1811 |
| 7 | Pricing & zones | `pricing-zones.html` | #1831, #1756, #1830, #1757 |
| | | `pricing-policies.html` | #1759 |
| 8 | Reports | `reports.html` | #1832 |
| 9 | Reconciliation | `reconciliation.html` | #1833 |
| 10 | Audit log | `audit-log.html` | #1816 |
| 11 | Admin users | `admin-users.html` | #1820, #1807, #1821 |
| — | *(designer index)* | `screens.html` | — |

### Changes from the original MVP screen list

The first draft of this file listed 11 screens. Three corrections came out of reading
the 36 written stories:

1. **"SOS queue" is removed.** The backlog defers the SOS queue and escalation
   workflow to a later phase. What is in scope is the **gender-mismatch report
   queue** (#1810/#1811) — women-only policy enforcement, not emergency response.
2. **"Admin users" is added.** It was missing, but #1807, #1820 and #1821 require it.
3. **"Live rides" is folded into the Dashboard.** #1669 and #1823 both place the live
   operations map on the dashboard, so it is not a separate screen. The Trips area
   covers trip monitoring and investigation.

## Forced states

Every list screen accepts `?state=empty`, `?state=loading`, `?state=error` and
`?state=long` so all states are reviewable without duplicated files. `?state=long`
stretches names and addresses — including long Arabic-transliterated names in an
English grid — to test overflow.

## Open questions

| # | Question | Status |
|---|---|---|
| 1 | **Map provider.** #1823–#1826, #1756 and #1831 specify the Google Maps JavaScript API and its marker-clustering library. The mockups use Mapbox GL JS because it is already wired into the repo via `MapService`. Either the stories or the implementation must change before dev. | Open — needs a BA decision |
| 2 | **#1813 cash reconciliation is unwritten.** Listed as in-scope Phase 1 in `phase-1.5-stories.md` and referenced by #1833 and #1816, but no `[Admin]` story exists. `reconciliation.html` renders "Record settlement" as a visible stub rather than inventing the behaviour. | Open — story needed |
| 3 | **#1808 cancel trip / #1809 reassign trip are unwritten, but now built.** #1671 Scenario 5 requires both on trip detail. Both flows are implemented in the mockup as a **proposal** and the screen says so in a standing notice. Decisions taken, all needing BA sign-off: cancelling yields a distinct `cancelled` status rather than an `expired` one (#1671 S2 already treats "in progress, cancelled, or expired" as three cases); reassigning keeps the trip live and returns it to `accepted`; only approved drivers who are online and not already on a trip can take over; both actions require a reason from a predefined list, with a note mandatory on "Other"; both are written to the audit log per #1816. **Consequence: #1670's status filter needs a fifth option, `Cancelled`** — added in the mockup, not yet in the story. | Stories still needed — mockup is the proposal |
| 3b | **#1657 is now all applications, not a pending-only queue.** The story specifies "pending applications queue". The mockup lists every application — pending, approved and rejected — with an **Application outcome** column (rejections show their reason inline) and an outcome filter. The badge still counts only what is awaiting review, so the queue's workload stays visible under any filter, and `getApplication` now opens a decided application read-only rather than 404ing. #1657's Grid Specification needs a fifth column and a filter row to match. | Open — story needs updating |
| 3c | **Driver reinstatement now records a reason.** #1743 does not ask for one, but reinstating is as consequential as suspending (#1742 requires a reason there), and an unexplained status flip leaves no audit trail. The mockup requires a reason from a list, makes a note mandatory on "Other", shows the recorded reason on the profile, and writes a `reinstate` entry to the audit log — which #1816 already lists as an auditable action. #1743 needs the reason added. Rider reinstatement (#1741) is deliberately left alone for now. | Open — story needs updating |
| 3d | **CSV export added to the trips, drivers and applications grids.** #1670, #1665 and #1657 do not mention export, though #1810, #1832 and #1833 do. Export respects the active filters and exports the full filtered set, not just the visible page. Worth deciding whether export is a portal-wide convention on every grid. | Open — confirm the convention |
| 4 | **Bilingual error strings in an English-only portal.** Every Field Validation table carries Arabic error text alongside English, yet the portal is English-only. The mockups show the English half. | Open — tables likely need cleanup |
| 5 | **Dashboard has no charts by design.** #1669 explicitly excludes trend charts, per-zone breakdowns, thresholds and metric export. If the designer expects graphs, that is a scope change, not a mockup omission. | Confirm with product |
| 6 | **Refund entry point.** #1815 (manual refund) sits in `phase-1.5-stories.md`, and #1672 Scenario 5 names it as the only money action on a completed trip. Not built; needs a decision on whether it lands in Phase 1. | Open |
