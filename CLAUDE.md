# SheDrive — Claude Code Instructions

This file is loaded automatically by Claude Code in every session. Follow all rules below exactly.

---

## Project Overview

**SheDrive** is a women-only ride-hailing service for Cairo/Giza, Egypt.

**Strategic positioning:** Safety-first premium service — not the cheapest, the safest.
Three pillars: live in-vehicle cameras · SOS direct line to Ministry of Interior (aspirational) · first-aid-trained drivers.
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
