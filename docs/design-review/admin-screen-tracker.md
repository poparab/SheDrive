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

## All 18 screens — landed

Built in a single pass rather than the four planned tracks: the user needed the full
set for designer review, and with the foundation frozen the remaining screens were
formulaic. The track structure stayed useful as the build order.

| Screen | Stories | Status | Notes |
|---|---|---|---|
| `index.html` — sign in, 2FA, reset | #1656, #1806, #1822 | ✅ | Empty/format/length validation, wrong credentials, invalid code, 3-strike lockout, recovery-code path, enrolment, forced first-login change. |
| `dashboard.html` — KPIs + live map | #1669, #1823–#1826 | ⚠️ | KPI cards, 30 s refresh, graceful map-unavailable degradation verified. **Map itself unverified** — see the environment note. |
| `driver-applications.html` | #1657 | ✅ | 4 columns per spec, 7 pending, oldest-first, row → detail. |
| `driver-application.html` | #1658, #1659, #1660 | ✅ | All four documents + photos inline with lightbox. Reject validation (required reason, ≤500-char note) and approve both exercised; approval persists across navigation and the queue drops to 6. |
| `drivers.html` | #1665 | ✅ | 5 columns, 34 drivers, status filter incl. Pending suspension. |
| `driver-profile.html` | #1666, #1742, #1743 | ✅ | Documents, decision-history timeline, trip history 10/page. Suspend/reinstate wired; mid-trip suspension yields Pending suspension. |
| `riders.html` | #1661 | ✅ | 5 columns, 42 riders. |
| `rider-profile.html` | #1662, #1740, #1741 | ✅ | Three account states; Pending review links to the originating report. Trip history 10/page. |
| `trips.html` | #1670 | ✅ | 8 columns; status filter maps onto the state machine — counts reconcile 4 + 6 + 111 + 27 = 148. |
| `trip-detail.html` | #1671, #1672 | ⚠️ | All three shapes verified: completed (8-step timeline, fare breakdown arithmetic checks out, rating + tags, route section), expired (expiry reason in summary and timeline, estimate shown, fare/rating/route hidden), active (estimate + intervention panel). #1808/#1809 render disabled. **Route map unverified** — environment. |
| `safety-reports.html` | #1810 | ✅ | 7 columns, oldest-first, defaults to Open, CSV export. |
| `safety-report.html` | #1810, #1811 | ✅ | Full workflow: Pending review → suspend → Suspended with note propagating to the rider; resolved report exposes no further actions. |
| `pricing-zones.html` | #1831, #1756, #1830, #1757 | ⚠️ | List, rate-card modal (min-fare ≥ base-fare rule), rename/delete verified. **Polygon drawing unverified** — needs the map. |
| `pricing-policies.html` | #1759 | ✅ | Both forms; commission >0 and ≤50 enforced, negative and fractional minutes rejected, updatedAt/updatedBy refresh on save, worked commission example. |
| `reports.html` | #1832 | ✅ | Five totals; reconciliation proof exact (3,165.89 + 14,422.67 = 17,588.56); idle period zeroes with a note; CSV export. |
| `reconciliation.html` | #1833 | ✅ | Driver required before generating; totals reconcile (114.77 + 522.83 = 637.60); cash/digital split; #1813 settlement is a visible stub. |
| `audit-log.html` | #1816 | ✅ | 5 columns, 50/page, 56 entries. Sort with `aria-sort`, all four filters, pagination, all four forced states. |
| `screens.html` — designer index | — | ✅ | 18 cards, ADO links, state chips. |

### Whole-portal checks

- **Internal screens are open by design** so a deep link from the screen index or an
  ADO design story always lands on its screen. Verified: all 17 authenticated screens
  open cold with the session cleared before each one, no redirect, shell rendered. ✅
- The production guard is still demonstrable via `?auth=strict` — verified it redirects
  to sign-in and provisions no session (#1656 Scenario 6). The sign-in screen also stays
  reachable with a session present, since it is itself a design screen. ✅
- Console clean on every one of the 18 screens (swept in isolated iframes). ✅
- No hex colours outside `admin-tokens.css`; none in JS outside the documented
  Mapbox token resolver; no `data-i18n` anywhere in `admin/`. ✅
- Layout holds at 1280 px and 1440 px; the page body never scrolls horizontally,
  including at `?state=long` with 98-character values. ✅
- Mutations persist for the browser session, so a decision on one screen is visible
  on the next; "Reset demo data" in the sidebar clears them. ✅

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
  drawing — must be checked once in a real browser window.** Easiest place is the
  live deployment:
  https://shedrive-web.abdelrahman-arcorp.workers.dev/admin/dashboard
  Applies to `dashboard.html`, `pricing-zones.html` and `trip-detail.html`.

## Deployment

Cloudflare **Worker** (static assets) at
https://shedrive-web.abdelrahman-arcorp.workers.dev, auto-deploying on push to
`main` — not Cloudflare Pages, despite `wrangler.toml` still carrying a
`pages_build_output_dir` key. The Worker strips `.html` and 307-redirects to
extensionless paths; query strings survive, so `?state=` review links work.

Note for the track plan: because a Worker publishes one branch, the **per-branch
preview URLs originally assumed for track review do not exist**. Review each track
on the local server, or merge to `main` and review the single live URL.
