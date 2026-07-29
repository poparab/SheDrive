# Admin Portal — Screen Build & Verification Tracker

Mirrors [driver-screen-tracker.md](driver-screen-tracker.md) for the admin portal
mockups at `shedrive-web/admin/`.

**Verification bar per screen** (no test runner — this is a browser sweep):

1. Console clean — no errors or unresolved-module warnings.
2. All four `?state=` variants render: `empty`, `loading`, `error`, `long`.
3. Grids: sort reorders rows, each filter narrows the set, pagination advances,
   row click opens the right detail URL.
4. Forms: every rule in the story's Field Validation table fires — empty, invalid,
   range/length — with the English message from the table.
5. Mutations produce the state change plus a toast, and the list reflects it on return.
6. Keyboard: Tab reaches every control, focus visible, Esc closes modals and lightboxes.
7. Layout holds at 1280 px and 1440 px; the page body never scrolls horizontally.

Legend: ✅ verified · ⚠️ built, partially verified · ⬜ not built

---

## Foundation wave — landed

| Screen | Stories | Status | Notes |
|---|---|---|---|
| `index.html` — sign in, 2FA, reset | #1656, #1806, #1822 | ✅ | Empty/format/length validation, wrong credentials, invalid code, 3-strike lockout with cool-down, recovery-code path, enrolment step, forced first-login change, reset request — all exercised. |
| `dashboard.html` — KPIs + live map | #1669, #1823–#1826 | ⚠️ | Five KPI cards, 30 s refresh with last-refreshed stamps, and graceful map-unavailable degradation verified. **Map itself unverified** — see environment note below. |
| `audit-log.html` — audit log | #1816 | ✅ | 5 columns per spec, 50/page, newest first, 56 seeded entries over 2 pages. Sort (incl. `aria-sort`), actor/action/target/date filters, pagination, and all four forced states verified. Reference implementation for every other grid. |
| `screens.html` — designer index | — | ✅ | All 18 cards, ADO links, state chips, progress count. |

### Shared foundation (not screens)

| Piece | Status |
|---|---|
| `admin-tokens.css`, `admin.css` | ✅ No hex outside the token file; px limited to hairlines, the visually-hidden clip, and breakpoints — matching existing shared-CSS convention. |
| 12 `ad-*` components | ✅ Exercised through the three built screens. |
| `seed.js` — canonical dataset | ✅ 8 admins, 42 riders, 34 drivers (7 pending), 148 trips, 9 zones (2 without rate cards), 9 safety reports, 56 audit entries. Deterministic shape, live timestamps. |
| `mock-api.js` | ✅ All list/detail/mutation methods, `?state=` handling, business-rule rejections. |
| `request-guard.js` | ✅ Required on every list screen — drops stale responses. |
| Contract doc | ✅ [admin-component-contract.md](../ux/admin-component-contract.md) |

---

## Screen tracks — pending

Each track branches from `master` after the foundation wave. File sets are disjoint,
so merges cannot conflict.

### Track A — `admin/track-a-drivers` · Driver onboarding & management

| Screen | Stories | Status |
|---|---|---|
| `driver-applications.html` | #1657 | ⬜ |
| `driver-application.html` | #1658, #1659, #1660 | ⬜ |
| `drivers.html` | #1665 | ⬜ |
| `driver-profile.html` | #1666, #1742, #1743 | ⬜ |

### Track B — `admin/track-b-riders` · Riders & safety

| Screen | Stories | Status |
|---|---|---|
| `riders.html` | #1661 | ⬜ |
| `rider-profile.html` | #1662, #1740, #1741 | ⬜ |
| `safety-reports.html` | #1810 | ⬜ |
| `safety-report.html` | #1810, #1811 | ⬜ |

### Track C — `admin/track-c-trips` · Trips & admin users

| Screen | Stories | Status |
|---|---|---|
| `trips.html` | #1670 | ⬜ |
| `trip-detail.html` | #1671, #1672 | ⬜ |
| `admin-users.html` | #1820, #1807, #1821 | ⬜ |

### Track D — `admin/track-d-money` · Pricing, reports & reconciliation

| Screen | Stories | Status |
|---|---|---|
| `pricing-zones.html` | #1831, #1756, #1830, #1757 | ⬜ |
| `pricing-policies.html` | #1759 | ⬜ |
| `reports.html` | #1832 | ⬜ |
| `reconciliation.html` | #1833 | ⬜ |

---

## Environment note — map verification

The in-app browser pane runs with the page in a hidden visibility state, so
`requestAnimationFrame` never fires. Mapbox GL JS depends on it for style loading
and its render loop, so **maps cannot complete loading in that pane**. Confirmed
not a code defect: the token and `api.mapbox.com` are reachable (200), the map
object constructs, and the canvas sizes correctly — only the render loop is absent.

Consequence for verification:

- `ad-map-panel.mount()` resolves `null` after an 8 s timeout and the screen shows a
  visible "map unavailable" message instead of hanging. This degradation path is
  verified, and the dashboard's KPI cards are deliberately not blocked on the map.
- **Map behaviour itself — markers, clustering, popovers, layer filter, polygon
  drawing — must be checked once in a real browser window** (Live Server or the
  deployed Pages URL). Applies to `dashboard.html`, `pricing-zones.html` and
  `trip-detail.html`.
