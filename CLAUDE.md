# SheDrive — Claude Code Instructions

This file is loaded automatically by Claude Code in every session. Follow all rules below exactly.

---

## Project Overview

**SheDrive** is a women-only ride-hailing service for Cairo/Giza, Egypt.

**Strategic positioning:** Safety-first premium service — not the cheapest, the safest.
Phase 1 pillar: SOS direct line to Ministry of Interior (aspirational). Live in-vehicle cameras and first-aid-trained drivers are deferred to post-Phase 1.
Driver supply includes male drivers (opt-in, never default) to avoid the liquidity failure that killed Fyonka and Pink Taxi.

**Working directory:** `D:\Claude\SheDrive\shedrive-web\`
**To serve locally (Windows):** `py -m http.server 8000` from `shedrive-web\`
Then open `http://localhost:8000/rider/`

---

## Stack Rules

- **Vanilla HTML + CSS + ES modules** — no build step, no bundler, no JS framework runtime.
- **Framework7 Core CSS only** for mobile chrome polish. It is vendored locally at `shared/vendor/framework7-bundle.min.css` and consumed only through `shared/styles/f7-overrides.css`.
- **Mapbox GL JS** loaded from CDN (`v3.6.0`). Token lives in `shared/scripts/config.js` only.
- **No Node.js / npm** on this machine. Python (`py` launcher) only.
- **No TypeScript.** Plain `.js` ES module files only.
- Serve with `py -m http.server 8000` or VS Code Live Server.

---

## File Ownership Convention

Every new screen gets exactly three files — no more:

```
rider/<screen>.html
rider/scripts/<screen>.js
rider/styles/<screen>.css
```

Shared reusables go in `shared/styles/` or `shared/scripts/`.
Never add screen-specific logic to shared files.

Shared UI primitives now also live in `shared/components/`.
Keep screen-specific markup, ids, and behavior in the rider screen files; only extract reusable shells and presentational primitives.

---

## Web Components Rules

- **Light DOM only.** Do not use Shadow DOM for SheDrive components.
- Register shared UI via `shared/components/sd-page.js`; it imports the current component set.
- `sd-page` owns shared CSS injection, Framework7 overrides, optional drawer CSS, optional Mapbox CSS, and the default toast host.
- Rider pages should not manually duplicate shared `<link rel="stylesheet">` tags or manual `#toast-container` markup when they already use `sd-page`.
- Preserve existing ids, `data-i18n*` attributes, and semantic roles when migrating markup into components.
- Reuse existing class names intentionally so screen CSS keeps working after componentization.
- Keep shared components presentational and attribute-driven. Screen-specific state, timers, auth checks, uploads, and storage flows stay in the page scripts.

---

## Design System Rules

- **Every CSS value must use `var(--token-name)`** from `shared/styles/tokens.css`.
- Never hardcode hex colors, pixel sizes, or font names.
- Exception: `rgba()` shadow values and one-off gradient stops that are direct derivations of token colors are acceptable.
- Reuse existing component classes: `.btn`, `.btn--primary`, `.btn--ghost`, `.btn--danger`, `.btn--icon`, `.btn--full`, `.btn--sm`, `.btn--lg`, `.input`, `.field`, `.spinner`, `.toast`, `.toast--success`, `.toast--danger`.
- Do not define new button or input styles — extend existing tokens.

---

## i18n / Bilingual Rules (CRITICAL)

**Every user-visible string must flow through a `data-i18n*` attribute.**

| Attribute | Used for |
|---|---|
| `data-i18n="key"` | Element text content |
| `data-i18n-placeholder="key"` | `<input placeholder>` |
| `data-i18n-aria-label="key"` | `aria-label` attribute |
| `data-i18n-value="key"` | `<input value>` (readonly fields) |

Rules:
1. **Always add Arabic fallback text** directly in the HTML as the element's content. This is shown before i18n loads.
2. **Always add new keys to BOTH** `shared/i18n/ar.json` AND `shared/i18n/en.json` at the same time.
3. **Never mix Arabic and English inside a single text node.** One key per language — not `<span>طوارئ</span> SOS`.
4. **Never use hardcoded `aria-label="..."`** on any element — always pair it with `data-i18n-aria-label`.
5. Key namespaces: `login.*`, `home.*`, `verify.*`, `matching.*`, `trip.*`, `emergency.*`, `complete.*`, `menu.*`, `aria.*`, `nav.*`, `common.*`, `splash.*`.

`shared/scripts/i18n.js` handles all four attribute types in `applyTranslations()`.

---

## Auth & Storage Keys

| Key | Storage | Type | Meaning |
|---|---|---|---|
| `shedrive.session` | localStorage | JSON `{role, phone, loginAt}` | Active auth session |
| `shedrive.lang` | localStorage | string `'ar'\|'en'` | Language preference |
| `shedrive.pendingTrip` | sessionStorage | JSON `{pickup, destination}` | Home → Matching handoff |
| `shedrive.activeTrip` | sessionStorage | JSON `{driver, trip}` | Matching → Active Trip handoff |
| `shedrive.completedRating` | sessionStorage | string `'1'` | Rating submitted flag |
| `shedrive.adminSession` | localStorage | JSON `{email, role, loginAt}` | Admin portal session (separate from `shedrive.session`) |

---

## Admin Panel (`shedrive-web/admin/`)

The admin portal is a **desktop operations tool**, not a mobile app. It deliberately
breaks three rules that apply to the rider and driver apps. These deviations are
sanctioned — do not "fix" them.

| Rule elsewhere | Admin portal | Why |
|---|---|---|
| Every string via `data-i18n` | **English only, no `data-i18n`** | Agreed admin UX rule (`docs/ux/admin-wireframes.md`). Keeps 36 stories of dense operational copy out of the rider locale files. |
| Mobile-first, `@media (min-width: …)` | **Desktop-first**, verified at 1280 px and 1440 px | Operations staff work on desktops; grids need width. |
| `sd-*` components, Framework7 chrome | **`ad-*` components**, no Framework7 | Admin needs side nav, dense data grids and detail panes — the opposite of bottom sheets and drawers. |

Everything else still applies: vanilla HTML/CSS/ES modules, no build step, light DOM
only, three files per screen, and **every CSS value from a token**.

- Admin density tokens live in `admin/styles/admin-tokens.css` (extends `tokens.css`).
- Shared admin layout and primitives live in `admin/styles/admin.css`.
- `ad-shell` is the page wrapper — it injects the CSS stack, renders the
  sidebar/topbar, mounts the toast host, and calls `adminAuth.requireAdmin()`.
- **Internal admin screens are deliberately open.** `requireAdmin()` provisions a
  demo session instead of redirecting, so any screen can be deep-linked from the
  screen index or an ADO design story. `?auth=strict` on any screen URL restores the
  production guard (#1656 Scenario 6) so that criterion stays demonstrable. Do not
  "fix" this by reinstating an unconditional redirect.
- Screens read data from `admin/scripts/mock-api.js` (a fake backend over
  `admin/scripts/seed.js`). Mirrors `shared/scripts/api.js` signatures so the real
  backend swaps in later.
- **Before building any admin screen, read
  `docs/ux/admin-component-contract.md`** — it is the frozen API for every shared
  component, the mock API, and the standard list-screen controller. Files listed as
  frozen there must not be edited by a screen.

Designer entry point: `<site>/admin/screens.html`. Every list screen honours
`?state=empty|loading|error|long`.

---

## Admin Panel v2 (`shedrive-web/admin-v2/`)

`admin-v2/` is the same portal rebuilt on the delivered design kit
`SheDrive.AdminPanel_v18-08-2026` (Bootstrap 5 + Tajawal + Font Awesome + the kit's
compiled `styles.css`, vendored under `admin-v2/vendor/`). It is a **separate copy** —
`admin/` is untouched and still works.

- Read `shedrive-web/admin-v2/DESIGN-PORT.md` before touching it. It is the port spec:
  the CSS stack, the kit's markup vocabulary, the ground rules, and the deviations.
- The data layer (`mock-api.js`, `seed.js`, `mutations.js`, `format.js`,
  `request-guard.js`, `admin-auth.js`) is identical to `admin/` — do not fork it.
- Component public APIs are identical to `admin/`; only what they *render* changed.
- Covers all 18 original screens plus seven the kit added: `2fa`, `2fa-setup`, `otp`,
  `recovery-code`, `password-forgot`, `password-new`, `admin-profile`.
- Smoke test: serve, then open `admin-v2/_verify.html` (checks every screen in both
  languages). Use the `shedrive-nocache` launch config when verifying — the plain
  `http.server` lets the browser cache a stale module.
- **admin-v2 is bilingual**, unlike `admin/`: English (LTR, default) and Arabic (RTL).
  Read `shedrive-web/admin-v2/I18N-PORT.md` before adding a string. Locales are ES
  modules under `admin-v2/i18n/`, `t()` is synchronous, and switching language reloads
  the page. The English-only rule above still applies to `admin/`, not to `admin-v2/`.
- Desktop-first and the `ad-*` component convention still apply.

---

## Reusable Utilities — Import These First

```js
// Auth (shared/scripts/auth.js)
import { auth } from '../../shared/scripts/auth.js';
auth.requireAuth();       // redirects to ./index.html if no session
auth.login(role, phone);  // creates session
auth.logout();            // removes session
auth.getSession();        // returns session object or null

// i18n (shared/scripts/i18n.js)
import {
  initI18n,
  setLanguage,
  translate,
  t,
  applyTranslations,
  I18N_EVENT,
  isI18nReady,
} from '../../shared/scripts/i18n.js';
await initI18n();         // load saved language, apply to DOM — call once at top
setLanguage('ar'|'en');   // switch language + update DOM
translate('key');         // return translated string
translate('key', { var: 'value' }); // with interpolation
applyTranslations();      // re-apply translations after mounting light-DOM content
isI18nReady();            // true once locale data is loaded
I18N_EVENT;               // 'shedrive:i18n:updated'

// Map (shared/scripts/map.js)
import { MapService } from '../../shared/scripts/map.js';
MapService.init('map');               // init map in #map element
MapService.addMarker(lngLat, opts);   // add marker
MapService.flyTo(lngLat, zoom);       // animate camera
MapService.getUserLocation();         // Promise<[lng, lat]>
MapService.setUserLocation(lngLat);   // place/move user dot

// Storage (shared/scripts/storage.js)
import { storage } from '../../shared/scripts/storage.js';
storage.get(key);    // safe JSON parse from localStorage
storage.set(key, v); // safe JSON stringify to localStorage

// DOM utils (shared/scripts/utils.js)
import { qs, qsa } from '../../shared/scripts/utils.js';
qs('#id');      // document.querySelector
qsa('.class');  // document.querySelectorAll (returns array)

// Drawer (shared/scripts/drawer.js)
import { Drawer } from '../../shared/scripts/drawer.js';
Drawer.mount();  // inject drawer HTML into body (idempotent)
Drawer.open();   // open
Drawer.close();  // close

// Note: if the page shell uses <sd-page drawer>, do not call Drawer.mount() again.
```

---

## Shared Components

Import shared UI once per page in the HTML head:

```html
<script type="module" src="../shared/components/sd-page.js"></script>
```

Component APIs:

- `sd-page`
  - Required wrapper for rider screens using the new shell.
  - Attributes: `body-class`, `screen-styles`, `drawer`, `mapbox`, `f7-theme`, `no-fonts`.
  - Responsibilities: inject shared CSS, Framework7 overrides, optional drawer/mapbox CSS, `body` classes, and `#toast-container` via `sd-toast-host`.
- `sd-app-header`
  - Shared top bar with built-in language toggle.
  - Attributes: `menu`, `profile`, `profile-avatar`, `hide-lang-toggle`, `bar-class`, `inner-class`, `actions-class`, `title-class`, `menu-button-id`, `profile-button-id`, `menu-class`.
  - Child nodes with `data-slot="start"` render before the title; `data-slot="end"` render after the language toggle.
- `sd-button`
  - Wrapper around the existing `.btn` system.
  - Attributes: `variant`, `size`, `full`, `icon`, `type`, `disabled`, plus ARIA and `data-i18n*` attributes.
- `sd-bottom-sheet`
  - Framework7-styled bottom sheet wrapper for rider flows.
  - Attributes: `height`; methods: `open()` and `close()`.
- `sd-driver-card`
  - Shared driver summary card.
  - Variants: `detailed`, `preview`, `compact`.
  - Attribute-driven ids/fallbacks: `name-id`, `rating-id`, `vehicle-id`, `eta-id`, `prompt-key`, `prompt-fallback`, `avatar`.
- `sd-rating-stars`
  - Shared five-star rating control.
  - Attribute: `value`.
  - Emits bubbling `change` with `event.detail.value`.
- `sd-toast-host`
  - Auto-mounted by `sd-page` unless a page already contains one.
  - Exposes `showToast(message, type, duration)`.

---

## Standard Page Script Pattern

Every rider page now uses a shell-first HTML pattern plus a small page controller:

```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SheDrive — Example</title>
  <script type="module" src="../shared/components/sd-page.js"></script>
  <script src="https://api.mapbox.com/mapbox-gl-js/v3.6.0/mapbox-gl.js"></script>
  <!-- Include the Mapbox script only on screens that render a map. -->
</head>

<body>
  <sd-page
    body-class="app-shell home-page"
    screen-styles="/rider/styles/rider.css, /rider/styles/home.css"
    drawer
    mapbox
  >
    <sd-app-header menu>
      <a href="." class="home-topbar__logo" aria-label="SheDrive home">
        <img src="../shared/assets/logos/shedrive-logo.svg" alt="SheDrive" height="32" />
      </a>
    </sd-app-header>

    <!-- screen content -->
  </sd-page>

  <script type="module" src="scripts/home.js"></script>
</body>
```

The matching page script pattern is:

```js
import { auth } from '../../shared/scripts/auth.js';
import { initI18n, setLanguage } from '../../shared/scripts/i18n.js';
import { qs, qsa } from '../../shared/scripts/utils.js';

auth.requireAuth(); // remove for login page
await initI18n();

qsa('[data-lang-btn]').forEach(btn =>
  btn.addEventListener('click', () => setLanguage(btn.getAttribute('data-lang-btn')))
);

// ... page logic ...
// If the shell already uses <sd-page drawer>, do not mount the drawer here.

function showToast(msg, type = 'info') {
  const t = document.createElement('div');
  t.className = `toast toast--${type}`;
  t.textContent = msg;
  qs('#toast-container').appendChild(t);
  setTimeout(() => t.remove(), 4000);
}
```

---

## Full Rider Navigation Map

```
index.html (Splash overlay → Login)
   │
   └──► home.html (Book a Ride)
                                      │
                                 menu ├──► [Drawer] ──► Logout ──► index.html
                                      │
                                      └──► matching.html (Finding Driver)
                                                   │  Cancel → home.html
                                                   │
                                                   └──► active-trip.html (Live Trip)
                                                              │         │
                                                     SOS ────┘         │ ETA→0 / demo btn
                                                              │         │
                                                    emergency.html    trip-complete.html
                                                              │         │
                                                   Return to trip    Submit/Skip
                                                              │         │
                                                    active-trip.html  home.html
```

---

## Screen Index

| File | Description |
|---|---|
| `rider/index.html` | Splash overlay + phone OTP login |
| `rider/home.html` | Map + pickup/destination + request ride |
| `rider/matching.html` | Searching for driver (3.5s auto-advance) |
| `rider/active-trip.html` | Live trip: map + driver card + SOS + demo-end |
| `rider/emergency.html` | Full-screen SOS dashboard + mock call buttons |
| `rider/trip-complete.html` | Rating (stars + tags + tip) + trip summary |

---

## Backlog Teams & Story Types

The SheDrive backlog is split across two teams in Azure DevOps (project: SheDrive):

| Team       | ADO Area Path   | Owns                                      |
|------------|-----------------|-------------------------------------------|
| Web / Main | SheDrive\Web    | Admin Panel stories + API stories         |
| Mobile     | SheDrive\Mobile | Mobile (Rider & Driver) stories           |

Stories are classified by type and prefixed in the title:

| Prefix     | Track                                            | Team       |
|------------|--------------------------------------------------|------------|
| `[Admin]`  | Admin portal screens, workflows, config          | Web / Main |
| `[Mobile]` | Rider and Driver app screens and flows           | Mobile     |
| `[API]`    | Backend API contracts consumed by the Mobile app | Web / Main |

When a Mobile feature needs a backend counterpart, write two stories with matching
business outcomes: one `[Mobile]` story in the Mobile backlog, one `[API]` story in
the Web / Main backlog. Keep both strictly business-focused — no code, schema, or
infrastructure detail.

**HARD RULE: Never create a story in ADO without setting a Feature as its parent.**
Every `wit_create_work_item` call must include `System.Parent` pointing to the correct
Feature work item ID. If the correct Feature ID is not already known, query ADO to find
it before creating the story. A story with no parent is not acceptable.

---

## CSS Link Order in Every Rider Page

Pages using `sd-page` should not hand-author the shared CSS link stack anymore.
Use `screen-styles` on the `sd-page` element and let the component inject styles in this order:

1. `shared/styles/tokens.css`
2. `shared/styles/reset.css`
3. `shared/styles/base.css`
4. `shared/styles/components.css`
5. `shared/styles/utilities.css`
6. `shared/styles/f7-overrides.css`
7. `shared/styles/web-components.css`
8. `shared/styles/rtl.css`
9. `shared/styles/drawer.css` when the page has the `drawer` attribute
10. Any comma-separated screen styles from `screen-styles`
11. Mapbox CSS when the page has the `mapbox` attribute

HTML head pattern:

```html
<script type="module" src="../shared/components/sd-page.js"></script>
<script src="https://api.mapbox.com/mapbox-gl-js/v3.6.0/mapbox-gl.js"></script>
```

Use the Mapbox script only on screens that render a map.

---

## Recommended `.claude/settings.local.json`

Put this at `D:\Claude\SheDrive\.claude\settings.local.json` to reduce permission prompts:

```json
{
  "permissions": {
    "allow": [
      "Bash(py -m http.server *)",
      "Bash(curl http://localhost:*)",
      "Bash(ls *)",
      "Bash(dir *)"
    ]
  }
}
```
