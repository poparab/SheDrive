# Admin Portal — Component & Mock API Contract

> Frozen by the foundation wave. Screen tracks build **against this document**, not
> against each other's code. If a track needs a change to anything described here,
> it stops and the change lands on `admin/foundation` first — never inside a track.

**Location:** `shedrive-web/admin/`
**Stack:** vanilla HTML + CSS + ES modules, light-DOM web components, no build step.
**Conventions:** desktop-first, English-only (no `data-i18n`), `ad-` component prefix,
every CSS value from a token.

---

## 1. File ownership

Each screen owns exactly three files and nothing else:

```
admin/<screen>.html
admin/scripts/<screen>.js
admin/styles/<screen>.css
```

**Never edited by a screen track** (frozen in the foundation wave):

| File | Why it is frozen |
|---|---|
| `admin/scripts/nav.js` | Complete 11-area nav manifest |
| `admin/scripts/seed.js` | The single shared dataset — read-only |
| `admin/scripts/mock-api.js` | All list/detail/mutation methods already exist |
| `admin/scripts/format.js`, `request-guard.js`, `admin-auth.js` | Shared helpers |
| `admin/components/*` | Shared components |
| `admin/styles/admin.css`, `admin-tokens.css` | Shared layout + tokens |
| `admin/screens.html`, `admin/scripts/screens.js` | Designer index, all 18 cards present |

Because these are off-limits, track branches touch disjoint files and merge
without conflict by construction.

---

## 2. Page skeleton

Every authenticated screen looks like this. `ad-shell` injects the CSS stack,
guards the session, renders the sidebar and topbar, and mounts the toast host —
so the `<head>` stays to one module import.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SheDrive Admin — Drivers</title>
    <meta name="robots" content="noindex" />
    <script type="module" src="components/ad-shell.js"></script>
  </head>
  <body>
    <ad-shell
      active="drivers"
      page-title="Drivers"
      breadcrumb="People > Drivers"
      screen-styles="styles/drivers.css"
    >
      <!-- screen content -->
    </ad-shell>
    <script type="module" src="scripts/drivers.js"></script>
  </body>
</html>
```

**Map screens** additionally load the Mapbox pair statically, so the CSS is parsed
before `mapbox-gl.js` runs (this avoids a console warning; `ad-styles` dedupes by
href, so the `mapbox` attribute stays safe to use as well):

```html
<link rel="stylesheet" href="https://api.mapbox.com/mapbox-gl-js/v3.6.0/mapbox-gl.css" />
<script src="https://api.mapbox.com/mapbox-gl-js/v3.6.0/mapbox-gl.js"></script>
```

### `ad-shell` attributes

| Attribute | Meaning |
|---|---|
| `active` | nav key from `nav.js` — highlights the sidebar item |
| `page-title` | topbar heading; also sets `document.title` |
| `breadcrumb` | `"Label\|href > Label\|href > Current"`; last segment is current |
| `screen-styles` | comma-separated screen stylesheet hrefs |
| `mapbox` | also inject the Mapbox stylesheet |
| `content-class` | extra classes on the content region |
| `no-auth` | skip the session guard (login screen only) |

Children of `<ad-shell>` are moved into the content region unchanged — ids, ARIA
attributes and markup all survive.

### Nav keys

`dashboard`, `trips`, `safety`, `driver-applications`, `drivers`, `riders`,
`pricing-zones`, `pricing-policies`, `reports`, `reconciliation`, `audit-log`,
`admin-users`.

---

## 3. Standard list-screen controller

`admin/scripts/audit-log.js` is the reference implementation. Copy its shape.

```js
import { adminAuth } from './admin-auth.js';
import { mockApi } from './mock-api.js';
import { createRequestGuard } from './request-guard.js';
import { qs } from '../../shared/scripts/utils.js';

if (!adminAuth.requireAdmin()) throw new Error('Redirecting to sign-in');

const filters = qs('#drivers-filters');
const table = qs('#drivers-table');

// One object holds the whole query so filters, sort and paging compose.
const query = { search: '', status: 'all', page: 1, pageSize: 20, sort: { key: 'submittedAt', dir: 'desc' } };

filters.fields = [ /* see §4 */ ];
filters.addEventListener('change', (event) => {
  Object.assign(query, event.detail);
  query.page = 1;                       // a filter change always resets paging
  load();
});

table.pageSize = query.pageSize;
table.sort = query.sort;
table.columns = [ /* see §5 */ ];
table.emptyState = { icon: '⛟', heading: '…', message: '…' };
table.rowHref = (row) => `driver-profile.html?id=${row.id}`;

table.addEventListener('sortchange', (e) => { query.sort = e.detail; table.sort = e.detail; load(); });
table.addEventListener('pagechange', (e) => { query.page = e.detail.page; load(); });

// REQUIRED on every list screen: the guard drops a stale response that would
// otherwise overwrite newer rows (filter bars debounce, the API adds latency).
const guard = createRequestGuard();

async function load() {
  const isCurrent = guard();
  table.setLoading();
  try {
    const result = await mockApi.listDrivers(query);
    if (!isCurrent()) return;
    table.setData(result);
  } catch (error) {
    if (!isCurrent()) return;
    table.setError(error.message, load);
  }
}

load();
```

Detail screens read their id with `new URLSearchParams(location.search).get('id')`
and must render a not-found state when the record is missing (#1658 Scenario 3).

---

## 4. `ad-filter-bar`

```js
bar.fields = [
  { type: 'search', key: 'search', label: 'Search', placeholder: 'Name or phone', grow: true },
  { type: 'select', key: 'status', label: 'Status', value: 'all',
    options: [{ value: 'all', label: 'All' }, { value: 'active', label: 'Active' }] },
  { type: 'daterange', key: 'date', label: 'Submission date', fromKey: 'from', toKey: 'to' },
];
bar.actions = [{ label: 'Export CSV', variant: 'ghost', onClick: () => exportCsv() }];
bar.value;                  // { search, status, from, to } — pass straight to mock-api
bar.setValue(key, value);   // set without firing change
bar.reset();
```

- Emits one bubbling `change` whose `detail` is the whole value object.
- `search` inputs are debounced 300 ms; selects and dates fire immediately.
- `daterange` validates end-after-start itself and suppresses `change` while invalid.
- An action with `stub: 'reason'` renders disabled with that reason as its tooltip —
  use this for anything awaiting an unwritten story.

---

## 5. `ad-data-table`

```js
table.columns = [
  { key: 'name', label: 'Name', sortable: true, render: (row) => row.name },
  { key: 'status', label: 'Status', sortable: true,
    render: (row) => { const p = document.createElement('ad-status-pill'); p.status = row.status; return p; } },
  { key: 'fare', label: 'Fare (EGP)', sortable: true, numeric: true,
    render: (row) => formatEgp(row.fare.total) },
];
table.pageSize = 20;
table.sort = { key: 'createdAt', dir: 'desc' };
table.rowHref = (row) => `trip-detail.html?id=${row.id}`;
table.emptyState = { icon: '☐', heading: '…', message: '…' };

table.setLoading();        // skeleton rows
table.setData(page);       // { rows, total, page, pageSize, totalPages }
table.setError(msg, retry);
```

Column keys: `key`, `label`, `sortable`, `numeric` (right-aligns, tabular figures),
`className`, `headerClass`, `render(row)`.

`render` may return a **string** (inserted as text, never HTML) or a **Node** (use
this for pills and links). Returning `null`/`''` renders an em dash.

Events: `sortchange {key, dir}`, `pagechange {page}`, `rowclick {row}` — all bubble.
Row activation works by click and by Enter/Space; clicks on a nested `<a>` or
`<button>` are not hijacked.

Page sizes are set per story: 20 for most grids, 10 for trip-history grids inside a
profile, 50 for the audit log and the zone list.

---

## 6. Other components

| Component | API |
|---|---|
| `ad-status-pill` | `pill.status = 'pending_review'`. Covers every account, onboarding, trip, report, zone and payment status. `statusLabel(status)` is exported for CSV and headings. |
| `ad-stat-card` | `card.value = '12'; card.meta = 'Updated 09:42'`; `label` attribute. |
| `ad-detail-section` | `section-title` attribute; `section.items = [{ label, value, muted, wide }]` where `value` is a string or Node. `section.body` and `section.actions` are append targets. |
| `ad-timeline` | `timeline.items = [{ label, meta, note, tone }]`, tone `default\|muted\|success\|danger`. |
| `ad-doc-viewer` | `viewer.docs = [{ label, src, meta, ref }]`. Thumbnails + lightbox, Esc closes. |
| `ad-tabs` | `tabs.tabs = [{ key, label }]`, `tabs.active`, emits `tabchange {key}`. |
| `ad-empty-state` | `icon`, `heading`, `message` attributes; slotted children become actions. |
| `ad-form-modal` | See §7. |
| `ad-map-panel` | See §8. |

Also reusable from `shared/`: `sd-confirm-dialog`, `sd-toast-host`, and the
`.btn`, `.field`, `.input`, `.card`, `.badge`, `.chip`, `.divider`, `.avatar`,
`.spinner`, `.modal`, `.toast` classes from `components.css`.

Toasts: `document.querySelector('ad-shell').showToast(message, type)` where type is
`info | success | warning | danger`.

---

## 7. `ad-form-modal`

Takes a story's **Field Validation table** almost verbatim. This is where the
distinct empty / invalid / range-length messages belong.

```js
modal.open({
  title: 'Reject application',
  description: 'The driver is notified with the reason you select.',
  confirmLabel: 'Reject application',
  danger: true,
  fields: [
    { key: 'reason', type: 'select', label: 'Rejection reason', required: true,
      options: REASON_LISTS.rejection.map((r) => ({ value: r, label: r })),
      emptyError: 'Select a rejection reason' },
    { key: 'note', type: 'textarea', label: 'Note', maxLength: 500,
      requiredWhen: (values) => values.reason === 'Other',
      emptyError: 'Add an explanatory note',
      lengthError: 'Too long — must be ≤ 500 characters' },
  ],
  onConfirm: async (values) => {
    await mockApi.rejectApplication(id, values.reason);
    shell.showToast('Application rejected.', 'success');
  },
});
```

Field spec: `type` (`text|email|password|number|textarea|select|date|readonly`),
`required`, `requiredWhen(values)`, `emptyError`, `pattern`, `invalidError`,
`min`, `max`, `step`, `rangeError`, `maxLength`, `minLength`, `lengthError`,
`hint`, `placeholder`, `options`, `value`, `validate(value, values) → string|null`.

`onConfirm` may throw — the modal stays open and shows the thrown message. It
closes on success. Field errors clear as soon as the admin edits the field.

---

## 8. `ad-map-panel`

```js
const map = await panel.mount({ center, zoom, tall: true });   // null if unavailable
panel.setMarkers([{ id, kind, position: [lng, lat], popover: { title, rows: [[k, v]], link: { href, label } } }]);
panel.setPolygons([{ id, name, status, polygon }]);
panel.setRoute([[lng, lat], …]);
panel.fitTo(coordinates);
panel.setEmpty(true, 'message');
panel.addLegend([{ kind: 'idle', label: 'Driver — idle' }]);
panel.startDraw(onChange); panel.undoDrawPoint(); panel.cancelDraw();
const { polygon, error } = panel.finishDraw();   // validates ≥3 points, no self-intersection
panel.loadDrawPolygon(existingRing);             // edit an existing boundary
```

Marker kinds: `driver-idle`, `driver-on-trip`, `ride-request`. Clustering is
native Mapbox, so it works without extra wiring. `setMarkers` never moves the
camera — that is what keeps the viewport stable across refresh (#1823 Scenario 5).

Emits `markerclick {marker}`. Children with `data-slot="toolbar"` render in the
toolbar row.

**`mount()` can resolve `null`** — no WebGL, no token, or tiles that never arrive.
**A screen must never block its other content on the map.** Load your data first,
then mount, and handle `null` with a visible message. The dashboard does this.

---

## 9. Mock API

Every method returns a Promise and adds ~380 ms of latency so loading states are
real. Signatures mirror `shared/scripts/api.js`, so swapping in the real backend
is a file replacement rather than a rewrite.

List methods take `{ search, status, from, to, page, pageSize, sort }` (subset per
screen) and resolve `{ rows, total, page, pageSize, totalPages }`.

| Area | Methods |
|---|---|
| Auth | `mockAuth.login`, `verifySecondFactor`, `requestPasswordReset`, `changePassword`, `recoveryCodes` |
| Dashboard | `getDashboardMetrics`, `getLiveMapData({layer})` |
| Applications | `listApplications`, `getApplication`, `approveApplication`, `rejectApplication(id, reason)` |
| Drivers | `listDrivers`, `listSettleableDrivers`, `getDriver`, `suspendDriver(id, reason, note)`, `reinstateDriver`, `listDriverTrips(id, {page})` |
| Riders | `listRiders`, `getRider`, `suspendRider(id, reason, note)`, `reinstateRider`, `listRiderTrips(id, {page})` |
| Trips | `listTrips`, `getTrip` |
| Safety | `listSafetyReports`, `getSafetyReport`, `resolveSafetyReport(id, 'suspended'\|'dismissed', note)` |
| Pricing | `listZones`, `getZone`, `createZone`, `updateZone`, `deleteZone`, `saveRateCard`, `removeRateCard`, `getPolicies`, `savePolicies` |
| Reports | `getRevenueSummary({from,to,zoneId})`, `getDriverSettlement({driverId,from,to,page})` |
| Audit | `listAuditEntries` |
| Admin users | `listAdmins`, `createAdmin`, `setAdminStatus` |

Mutations update in-memory state, so a list revisited after an action reflects the
change. A full page reload resets everything to the seed.

Rejections are `MockApiError` with a `status`. Business rules already enforced
server-side: duplicate zone name (409), minimum fare below base fare (422),
duplicate admin email (409), disabling your own account (422), re-resolving a
closed report (409).

`listZones` additionally returns `allMatching` — every matching zone, not just the
current page — because the map needs them all while the grid paginates.

### Derived behaviour already handled

- Zone `status` is derived from the rate card and is never settable by hand (#1757 Scenario 6).
- Suspending a driver who is mid-trip yields `pending_suspension`, not `suspended` (#1742).
- Resolving a gender-mismatch report also moves the rider to `suspended` or `active` (#1811).
- Approving or rejecting an application keeps the pending queue in step.

---

## 10. Forced states

Every screen must honour `?state=` so the designer can inspect states without
duplicated files. `mock-api` implements it centrally — a screen gets it for free
by using the standard controller, but check all four before marking a screen done.

| Value | Behaviour |
|---|---|
| `?state=empty` | resources resolve with zero rows / zeroed totals |
| `?state=loading` | resources never resolve — skeletons stay up |
| `?state=error` | resources reject with a 503 |
| `?state=long` | name, address, email and reason fields are stretched to test overflow |

Screens may add their own params where useful (`?status=suspended`,
`?trip=expired`) — document them in the screen tracker.

---

## 11. Formatters

From `admin/scripts/format.js` — use these rather than ad-hoc formatting, so
dates and money read identically across screens. Egypt is UTC+2 with no DST, so
timestamps render at a fixed +02:00 offset rather than the viewer's zone.

`formatDate`, `formatDateTime`, `formatTime`, `toDateInputValue`, `formatEgp`,
`formatCount`, `formatPercent`, `formatPhone`, `maskNid`, `formatElapsed`,
`formatDistance`, `formatDuration`, `humanize`, `toCsv`, `downloadCsv`.

---

## 12. Styling rules

- Every value references a token from `shared/styles/tokens.css` or
  `admin/styles/admin-tokens.css`. New density values belong in `admin-tokens.css`.
- Accepted raw values, matching existing repo convention: `1px` hairline borders,
  `-1px`/`1px` in the visually-hidden clip pattern, media-query breakpoints, and
  `rgba()` derived from a token's `-rgb` triple.
- Mapbox paint properties cannot read CSS custom properties, so `ad-map-panel`
  resolves tokens to concrete values at layer-creation time. Do not hardcode
  colours anywhere else in JS.
- Reuse `admin.css` classes before adding to a screen stylesheet: `.ad-section`,
  `.ad-split`, `.ad-detail-grid`, `.ad-stats`, `.ad-row`, `.ad-stack`, `.ad-stub`,
  `.ad-panel`, `.ad-muted`, `.ad-num`, `.ad-nowrap`, `.ad-visually-hidden`.
- Wide content scrolls inside its own container. The page body must never scroll
  horizontally — verify with `?state=long`.

---

## 13. Unwritten stories — stub, never invent

Three referenced stories do not exist. Where a screen needs them, render a
**visibly disabled** control with `.ad-stub` or `ad-filter-bar`'s `stub` option
explaining what is missing. Do not design the missing behaviour.

| Missing | Needed by |
|---|---|
| #1808 cancel an in-progress trip | `trip-detail.html` |
| #1809 reassign a trip to another driver | `trip-detail.html` |
| #1813 cash reconciliation / record settlement | `reconciliation.html` |
