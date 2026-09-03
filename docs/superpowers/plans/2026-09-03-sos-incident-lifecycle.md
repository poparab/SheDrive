# SOS Incident Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn an SOS tap into a recorded case that an admin can review and act on, and bring the driver's SOS experience level with the rider's.

**Architecture:** Three independent slices. (1) Mobile: cap contacts at 5, give the driver a full alert screen, add delivery status / stop-sharing / false-alarm to both. (2) `admin-v2`: a seeded `SOS_CASES` dataset, three mock-api methods, and two new screens — a review queue and a case detail with suspend/close actions. (3) ADO: 6 new stories, 4 updates, and the matching `docs/backlog/` sync. `admin/` (v1) is untouched.

**Tech Stack:** Vanilla HTML + CSS + ES modules, no build step, no bundler. Light-DOM `ad-*` components in admin-v2, `sd-*` in the mobile apps. Python `py -m http.server` for serving. Bilingual EN/AR in admin-v2 via `scripts/admin-i18n.js`; `data-i18n` + `shared/scripts/i18n.js` in the mobile apps.

---

## Verification model — read this before Task 1

**This repo has no Node, no npm, and no test runner.** Do not try to install one. The
project's real verification harness is:

| Surface | Harness |
|---|---|
| `admin-v2` | `admin-v2/_verify.html` — loads every screen in an iframe, in **both** languages, asserts DOM markers exist, asserts `dir` is correct, and asserts Arabic text actually rendered. This is the test suite. |
| Mobile | Browser preview + `read_console_messages`. Screens accept `?state=` query params for preview states. |

**Red/green in this repo means:** add the screen's row to the `_verify.html` manifest
*first*, load `_verify.html` and watch that row **fail**, then build the screen, then
reload and watch it **pass**. Several tasks below follow exactly that order.

**Serving:**

```bash
cd /d/Claude/SheDrive/shedrive-web && py -m http.server 8000
```

Then `http://localhost:8000/admin-v2/_verify.html`. Use a cache-busting reload
(Ctrl+Shift+R) — `http.server` will happily serve a stale ES module.

---

## File Structure

**Created:**

| File | Responsibility |
|---|---|
| `shedrive-web/driver/emergency.html` | Driver's full-screen SOS alert view |
| `shedrive-web/driver/scripts/emergency.js` | Driver alert-screen controller |
| `shedrive-web/driver/styles/emergency.css` | Driver alert-screen styles |
| `shedrive-web/admin-v2/sos-requests.html` | SOS case queue markup |
| `shedrive-web/admin-v2/scripts/sos-requests.js` | Queue list controller |
| `shedrive-web/admin-v2/styles/sos-requests.css` | Queue styles |
| `shedrive-web/admin-v2/sos-request.html` | SOS case detail markup |
| `shedrive-web/admin-v2/scripts/sos-request.js` | Case detail + actions controller |
| `shedrive-web/admin-v2/styles/sos-request.css` | Case detail styles |

**Modified:**

| File | Change |
|---|---|
| `shedrive-web/shared/scripts/emergency-contacts.js` | 5-contact cap |
| `shedrive-web/shared/i18n/ar.json`, `en.json` | Cap, delivery-status, stop-sharing keys |
| `shedrive-web/rider/emergency.html` + `scripts/emergency.js` | Delivery status, stop sharing |
| `shedrive-web/driver/trip.html` + `scripts/trip.js` | Overlay replaced by navigation to `emergency.html` |
| `shedrive-web/admin-v2/scripts/seed.js` | `SOS_CASES`, `SOS_CASES_BY_ID` |
| `shedrive-web/admin-v2/scripts/mock-api.js` | `listSosCases`, `getSosCase`, `actionSosCase` |
| `shedrive-web/admin-v2/scripts/nav.js` | `sos` nav entry |
| `shedrive-web/admin-v2/i18n/core.js`, `lists.js`, `details.js` | EN + AR strings |
| `shedrive-web/admin-v2/_verify.html` | Two new manifest rows |
| `shedrive-web/admin-v2/screens.html` | Two new designer cards |
| `shedrive-web/admin-v2/DESIGN-PORT.md` | Record the data-layer divergence |
| `docs/backlog/*.md` | ADO sync |

---

## Task 1: Cap emergency contacts at 5

**Files:**
- Modify: `shedrive-web/shared/scripts/emergency-contacts.js`
- Modify: `shedrive-web/shared/i18n/ar.json`, `shedrive-web/shared/i18n/en.json`

- [ ] **Step 1: Add the cap constant and export it**

At the top of `shared/scripts/emergency-contacts.js`, directly under the
`EMERGENCY_CONTACTS_KEY` export:

```js
export const EMERGENCY_CONTACTS_KEY = 'shedrive.emergencyContacts';

/** Each contact is one paid SMS per alert, so the list is capped. (#1787 / #1951) */
export const MAX_EMERGENCY_CONTACTS = 5;
```

- [ ] **Step 2: Add the i18n keys, both languages in the same edit**

In `shared/i18n/en.json`, inside the existing `sos` object:

```json
"atCapacity": "You have saved the maximum of 5 contacts. Remove one to add another.",
"capHint": "Up to 5 contacts."
```

In `shared/i18n/ar.json`, inside the existing `sos` object:

```json
"atCapacity": "لقد حفظتِ الحد الأقصى وهو ٥ جهات اتصال. احذفي واحدة لإضافة أخرى.",
"capHint": "حتى ٥ جهات اتصال."
```

- [ ] **Step 3: Disable the add button at capacity**

In `emergency-contacts.js`, inside `render()`, replace the add-button block:

```js
      <button type="button" class="btn btn--primary btn--full sos-contacts__add" id="sos-add-btn">
        <span aria-hidden="true">${icon('plus')}</span>
        <span>${translate('sos.addContact')}</span>
      </button>
```

with:

```js
      <button type="button" class="btn btn--primary btn--full sos-contacts__add" id="sos-add-btn"
        ${atCapacity ? 'disabled' : ''}>
        <span aria-hidden="true">${icon('plus')}</span>
        <span>${translate('sos.addContact')}</span>
      </button>
      <p class="sos-contacts__cap-hint" role="note">
        ${atCapacity ? translate('sos.atCapacity') : translate('sos.capHint')}
      </p>
```

and add this line at the top of `render()`, immediately after `const hasContacts = ...`:

```js
    const atCapacity = contacts.length >= MAX_EMERGENCY_CONTACTS;
```

- [ ] **Step 4: Reject a save that would exceed the cap**

In `submitForm()`, immediately after `const list = getEmergencyContacts();`, insert:

```js
    // Adding (not editing) a contact when already at capacity is rejected. (#1787 S1)
    const isAdding = !editingId || editingId === 'new';
    if (isAdding && list.length >= MAX_EMERGENCY_CONTACTS) {
      toast(translate('sos.atCapacity'), 'danger');
      return;
    }
```

- [ ] **Step 5: Verify in the browser**

Serve, open `http://localhost:8000/rider/sos.html`, and add contacts until there are 5.
Expected: the add button goes disabled at 5 and the hint reads "You have saved the
maximum of 5 contacts." Switch to Arabic with the header toggle; expected: the same
hint in Arabic, no English left on screen. Repeat at
`http://localhost:8000/driver/sos.html` — it shares the module, so it must behave
identically.

- [ ] **Step 6: Commit**

```bash
git add shedrive-web/shared/scripts/emergency-contacts.js shedrive-web/shared/i18n/ar.json shedrive-web/shared/i18n/en.json
git commit -m "feat(sos): cap emergency contacts at five"
```

---

## Task 2: Delivery status and stop-sharing on the rider alert screen

**Files:**
- Modify: `shedrive-web/rider/emergency.html`
- Modify: `shedrive-web/rider/scripts/emergency.js`
- Modify: `shedrive-web/shared/i18n/ar.json`, `en.json`

- [ ] **Step 1: Add the i18n keys, both languages**

`shared/i18n/en.json`, inside `emergency`:

```json
"deliverySent": "Sending…",
"deliveryDelivered": "Delivered",
"deliveryFailed": "Could not deliver",
"stopSharing": "Stop sharing my location",
"sharingStopped": "Location sharing stopped."
```

`shared/i18n/ar.json`, inside `emergency`:

```json
"deliverySent": "جارٍ الإرسال…",
"deliveryDelivered": "تم التسليم",
"deliveryFailed": "تعذّر التسليم",
"stopSharing": "إيقاف مشاركة موقعي",
"sharingStopped": "تم إيقاف مشاركة الموقع."
```

- [ ] **Step 2: Add the stop-sharing button to the markup**

In `rider/emergency.html`, inside `<div class="emergency-actions">`, **above** the
existing `#return-btn`:

```html
      <button
        type="button"
        class="btn btn--ghost btn--full"
        id="stop-sharing-btn"
        data-i18n="emergency.stopSharing"
      >
        إيقاف مشاركة موقعي
      </button>
```

- [ ] **Step 3: Render a delivery status per contact**

In `rider/scripts/emergency.js`, inside `renderNotifiedContacts()`, replace the
`contacts.forEach` body so each row carries a status element. The full replacement
loop:

```js
  contacts.forEach((c) => {
    const li = document.createElement('li');
    li.className = 'emergency-contact-notified';

    const name = document.createElement('span');
    name.className = 'emergency-contact-notified__name';
    name.textContent = c.name;

    const meta = document.createElement('span');
    meta.className = 'emergency-contact-notified__meta';
    meta.textContent = [c.relationship, c.phone].filter(Boolean).join(' · ');

    // Delivery starts as "sending" and settles once the gateway reports back.
    // Until an SMS gateway exists this demonstrates the three states only.
    const status = document.createElement('span');
    status.className = 'emergency-contact-notified__status is-sending';
    status.textContent = translate('emergency.deliverySent');
    status.dataset.contactId = c.id;

    li.append(name, meta, status);
    list.appendChild(li);
  });
```

- [ ] **Step 4: Settle the delivery status after a short delay**

Immediately after the `renderNotifiedContacts();` call in the same file, add:

```js
// Delivery confirmations arrive asynchronously. No gateway is wired yet, so the
// screen settles every contact to "delivered" to show the state exists. (#1780)
function settleDeliveryStatuses() {
  document.querySelectorAll('.emergency-contact-notified__status').forEach((el, i) => {
    setTimeout(() => {
      el.classList.remove('is-sending');
      el.classList.add('is-delivered');
      el.textContent = translate('emergency.deliveryDelivered');
    }, 1200 + i * 400);
  });
}
settleDeliveryStatuses();
```

- [ ] **Step 5: Wire stop-sharing**

At the end of `rider/scripts/emergency.js`:

```js
// Stop sharing revokes the live link immediately. The alert itself stays open —
// her contacts keep the message, they just stop seeing where she is. (#1780)
qs('#stop-sharing-btn')?.addEventListener('click', (e) => {
  const btn = e.currentTarget;
  btn.disabled = true;
  const step2 = document.querySelector('[data-step="2"]');
  if (step2) {
    step2.classList.remove('emergency-step--active');
    step2.classList.add('emergency-step--done');
    const text = step2.querySelector('.emergency-step__text');
    if (text) text.textContent = translate('emergency.sharingStopped');
  }
});
```

- [ ] **Step 6: Style the three delivery states**

Append to `shedrive-web/rider/styles/emergency.css`:

```css
.emergency-contact-notified__status {
  font-size: var(--font-size-xs);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
}
.emergency-contact-notified__status.is-sending   { color: var(--color-text-muted); }
.emergency-contact-notified__status.is-delivered { color: var(--color-success); }
.emergency-contact-notified__status.is-failed    { color: var(--color-danger); }
```

- [ ] **Step 7: Verify in the browser**

Open `http://localhost:8000/rider/sos.html`, save two contacts, then open
`http://localhost:8000/rider/emergency.html`. Expected: both contacts listed, each
showing "Sending…" then flipping to "Delivered" about a second apart. Click
**Stop sharing my location**; expected: the button disables and step 2 of the
timeline changes to "Location sharing stopped." Check the console via
`read_console_messages`; expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add shedrive-web/rider/emergency.html shedrive-web/rider/scripts/emergency.js shedrive-web/rider/styles/emergency.css shedrive-web/shared/i18n/ar.json shedrive-web/shared/i18n/en.json
git commit -m "feat(sos): delivery status and stop-sharing on the rider alert screen"
```

---

## Task 3: Give the driver a full alert screen

The driver currently gets a small inline overlay in `driver/trip.html`. Replace it
with a real screen matching the rider's.

**Files:**
- Create: `shedrive-web/driver/emergency.html`
- Create: `shedrive-web/driver/scripts/emergency.js`
- Create: `shedrive-web/driver/styles/emergency.css`
- Modify: `shedrive-web/driver/trip.html`, `shedrive-web/driver/scripts/trip.js`

- [ ] **Step 1: Create `driver/emergency.html`**

```html
<!doctype html>
<html dir="rtl" lang="ar">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SheDrive Driver — طوارئ</title>
    <script type="module" src="../shared/components/sd-page.js"></script>
  </head>
  <body>
    <sd-page body-class="app-shell emergency-page" screen-styles="styles/driver.css, styles/emergency.css">
      <sd-app-header hide-lang-toggle bar-class="emergency-topbar" inner-class="emergency-topbar__inner">
        <button type="button" class="btn btn--icon btn--ghost" data-slot="start" id="back-btn"
          aria-label="رجوع" data-i18n-aria-label="aria.back">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20" aria-hidden="true">
            <polyline points="15 18 9 12 15 6"></polyline>
          </svg>
        </button>
      </sd-app-header>

      <section class="emergency-hero" role="alert">
        <div class="emergency-hero__pulse" aria-hidden="true"><span class="emergency-hero__dot"></span></div>
        <h1 class="emergency-hero__title" data-i18n="emergency.title">تم إخطار جهات اتصال الطوارئ</h1>
        <p class="emergency-hero__subtitle" data-i18n="emergency.subtitle">
          تتم مشاركة موقعك المباشر معهم الآن. ابقي هادئة.
        </p>
      </section>

      <main class="emergency-content">
        <div class="emergency-call-list">
          <a href="tel:122" class="emergency-call" data-i18n-aria-label="emergency.callPolice" aria-label="اتصال بالشرطة">
            <span class="emergency-call__body">
              <span class="emergency-call__label" data-i18n="emergency.callPolice">الشرطة</span>
              <span class="emergency-call__number" data-i18n="emergency.policeNumber">122</span>
            </span>
          </a>
          <a href="tel:123" class="emergency-call" data-i18n-aria-label="emergency.callAmbulance" aria-label="اتصال بالإسعاف">
            <span class="emergency-call__body">
              <span class="emergency-call__label" data-i18n="emergency.callAmbulance">الإسعاف</span>
              <span class="emergency-call__number" data-i18n="emergency.ambulanceNumber">123</span>
            </span>
          </a>
        </div>

        <section class="emergency-timeline" aria-live="polite">
          <h2 class="emergency-timeline__title" data-i18n="emergency.contactsTitle">جهات الاتصال التي تم إخطارها</h2>
          <div class="emergency-step emergency-step--active" data-step="1">
            <span class="emergency-step__text" data-i18n="emergency.step1">تم إرسال تنبيه الطوارئ إلى جهات اتصالك.</span>
          </div>
          <div class="emergency-step emergency-step--pending" data-step="2">
            <span class="emergency-step__text" data-i18n="emergency.step2">تتم مشاركة موقعك المباشر مع جهات اتصالك.</span>
          </div>
          <ul class="emergency-contacts-notified" id="notified-contacts" role="list"></ul>
          <p class="emergency-no-contacts" id="no-contacts-msg" data-i18n="emergency.noContacts" hidden>
            لم تُضيفي جهات اتصال للطوارئ بعد.
          </p>
        </section>

        <section class="emergency-recap">
          <h2 class="emergency-recap__title" data-i18n="emergency.recapTitleDriver">تفاصيل رحلتك الحالية</h2>
          <div class="emergency-recap__row">
            <span class="emergency-recap__label" data-i18n="emergency.recapRider">الراكبة</span>
            <span class="emergency-recap__value" id="recap-rider">—</span>
          </div>
          <div class="emergency-recap__row">
            <span class="emergency-recap__label" data-i18n="emergency.recapPlate">رقم اللوحة</span>
            <span class="emergency-recap__value" id="recap-plate">—</span>
          </div>
          <div class="emergency-recap__row">
            <span class="emergency-recap__label" data-i18n="emergency.recapLocation">الموقع الحالي</span>
            <span class="emergency-recap__value" id="recap-location">30.0444°N, 31.2357°E</span>
          </div>
        </section>
      </main>

      <div class="emergency-actions">
        <button type="button" class="btn btn--ghost btn--full" id="stop-sharing-btn" data-i18n="emergency.stopSharing">
          إيقاف مشاركة موقعي
        </button>
        <button type="button" class="btn btn--primary btn--full" id="return-btn" data-i18n="emergency.returnToTrip">
          العودة إلى الرحلة
        </button>
        <button type="button" class="btn btn--ghost btn--full btn--sm" id="cancel-btn" data-i18n="emergency.cancelAlert">
          إلغاء التنبيه (إنذار كاذب)
        </button>
      </div>
    </sd-page>
    <script type="module" src="scripts/emergency.js"></script>
  </body>
</html>
```

- [ ] **Step 2: Add the driver-specific i18n keys, both languages**

`shared/i18n/en.json`, inside `emergency`:

```json
"recapTitleDriver": "Your current trip",
"recapRider": "Rider"
```

`shared/i18n/ar.json`, inside `emergency`:

```json
"recapTitleDriver": "تفاصيل رحلتك الحالية",
"recapRider": "الراكبة"
```

- [ ] **Step 3: Create `driver/scripts/emergency.js`**

```js
/**
 * emergency.js — Driver SOS alert screen (Phase 1 SOS)
 * Mirrors the rider screen: who was alerted, delivery status, live-location
 * sharing, public emergency numbers, stand down. (#1951 / #1952)
 */

import { auth } from '../../shared/scripts/auth.js';
import { initI18n, setLanguage, translate } from '../../shared/scripts/i18n.js';
import { qs, qsa } from '../../shared/scripts/utils.js';
import { getEmergencyContacts } from '../../shared/scripts/emergency-contacts.js';

auth.requireAuth();
await initI18n();

qsa('[data-lang-btn]').forEach((btn) =>
  btn.addEventListener('click', () => setLanguage(btn.getAttribute('data-lang-btn')))
);

// ── Trip recap ────────────────────────────────────
const trip = JSON.parse(sessionStorage.getItem('shedrive.driverActiveTrip') || '{}');
qs('#recap-rider').textContent = trip.riderName || '—';
qs('#recap-plate').textContent = trip.plate || '—';

if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition(
    (pos) => {
      qs('#recap-location').textContent =
        `${pos.coords.latitude.toFixed(4)}°N, ${pos.coords.longitude.toFixed(4)}°E`;
    },
    () => {}
  );
}

// ── Contacts alerted, with delivery status ────────
function renderNotifiedContacts() {
  const list = qs('#notified-contacts');
  const emptyMsg = qs('#no-contacts-msg');
  const contacts = getEmergencyContacts();

  if (!contacts.length) {
    if (emptyMsg) emptyMsg.hidden = false;
    return;
  }

  contacts.forEach((c) => {
    const li = document.createElement('li');
    li.className = 'emergency-contact-notified';

    const name = document.createElement('span');
    name.className = 'emergency-contact-notified__name';
    name.textContent = c.name;

    const meta = document.createElement('span');
    meta.className = 'emergency-contact-notified__meta';
    meta.textContent = [c.relationship, c.phone].filter(Boolean).join(' · ');

    const status = document.createElement('span');
    status.className = 'emergency-contact-notified__status is-sending';
    status.textContent = translate('emergency.deliverySent');

    li.append(name, meta, status);
    list.appendChild(li);
  });
}
renderNotifiedContacts();

function settleDeliveryStatuses() {
  qsa('.emergency-contact-notified__status').forEach((el, i) => {
    setTimeout(() => {
      el.classList.remove('is-sending');
      el.classList.add('is-delivered');
      el.textContent = translate('emergency.deliveryDelivered');
    }, 1200 + i * 400);
  });
}
settleDeliveryStatuses();

// ── Actions ───────────────────────────────────────
qs('#stop-sharing-btn')?.addEventListener('click', (e) => {
  e.currentTarget.disabled = true;
  const step2 = qs('[data-step="2"]');
  if (step2) {
    step2.classList.remove('emergency-step--active');
    step2.classList.add('emergency-step--done');
    const text = step2.querySelector('.emergency-step__text');
    if (text) text.textContent = translate('emergency.sharingStopped');
  }
});

qs('#return-btn')?.addEventListener('click', () => window.location.assign('./trip.html'));
qs('#back-btn')?.addEventListener('click', () => window.location.assign('./trip.html'));
qs('#cancel-btn')?.addEventListener('click', () => {
  setTimeout(() => window.location.assign('./trip.html'), 800);
});
```

- [ ] **Step 4: Create `driver/styles/emergency.css`**

Reuse the rider's visual language rather than inventing a second one:

```css
/* Driver SOS alert screen — mirrors rider/styles/emergency.css. */
@import url('../../rider/styles/emergency.css');

.emergency-contact-notified__status {
  font-size: var(--font-size-xs);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
}
.emergency-contact-notified__status.is-sending   { color: var(--color-text-muted); }
.emergency-contact-notified__status.is-delivered { color: var(--color-success); }
.emergency-contact-notified__status.is-failed    { color: var(--color-danger); }
```

- [ ] **Step 5: Point the driver's SOS confirm at the new screen**

In `driver/scripts/trip.js`, replace the `#sos-confirm` handler:

```js
qs('#sos-confirm')?.addEventListener('click', () => {
  if (sosBackdrop) { sosBackdrop.hidden = true; sosBackdrop.setAttribute('aria-hidden', 'true'); }
  const overlay = qs('#emergency-overlay');
  if (overlay) { overlay.hidden = false; overlay.removeAttribute('aria-hidden'); }
});
```

with:

```js
qs('#sos-confirm')?.addEventListener('click', () => {
  if (sosBackdrop) { sosBackdrop.hidden = true; sosBackdrop.setAttribute('aria-hidden', 'true'); }
  // The overlay is replaced by a real screen, matching the rider app. (#1951)
  window.location.assign('./emergency.html');
});
```

- [ ] **Step 6: Delete the dead overlay**

In `driver/trip.html`, delete the whole `<div class="emergency-overlay" id="emergency-overlay" …>…</div>`
block (it starts at the line containing `id="emergency-overlay"` and ends at its
closing `</div>`). In `driver/scripts/trip.js`, delete the now-orphaned
`qs('#emergency-return')` handler.

- [ ] **Step 7: Verify in the browser**

Open `http://localhost:8000/driver/sos.html`, save two contacts. Open
`http://localhost:8000/driver/trip.html?state=in-ride`, tap the SOS action, confirm.
Expected: navigation to `driver/emergency.html`, both contacts listed with delivery
status settling to "Delivered", police 122 and ambulance 123 both present, and the
three action buttons. Confirm **no fire brigade number appears anywhere**. Check the
console; expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add shedrive-web/driver/emergency.html shedrive-web/driver/scripts/emergency.js shedrive-web/driver/styles/emergency.css shedrive-web/driver/trip.html shedrive-web/driver/scripts/trip.js shedrive-web/shared/i18n/ar.json shedrive-web/shared/i18n/en.json
git commit -m "feat(sos): give the driver a full SOS alert screen"
```

---

## Task 4: Seed SOS cases in admin-v2

**Files:**
- Modify: `shedrive-web/admin-v2/scripts/seed.js`

- [ ] **Step 1: Append the SOS case dataset**

Add after the `SAFETY_REPORTS` block in `admin-v2/scripts/seed.js`:

```js
// ── SOS cases (#1780/#1952 raise them, admin reviews them) ─────

const SOS_STATEMENTS = [
  'Passenger reported feeling unwell and asked to stop.',
  'Driver reported being followed by another vehicle.',
  'Passenger raised the alarm during a prolonged stop in traffic.',
  'Driver reported an argument escalating inside the vehicle.',
  'Passenger raised the alarm after the route deviated unexpectedly.',
];

const SOS_TRIP_STATES = ['en_route_pickup', 'arrived_pickup', 'trip_started'];

const SOS_SOURCE_TRIPS = TRIPS.filter((t) => t.driverId && t.riderId).slice(0, 11);

export const SOS_CASES = SOS_SOURCE_TRIPS.map((trip, index) => {
  const rider = RIDERS_BY_ID.get(String(trip.riderId)) ?? RIDERS[index];
  const driver = DRIVERS_BY_ID.get(String(trip.driverId)) ?? DRIVERS[index];
  const raisedBy = index % 3 === 0 ? 'driver' : 'rider';
  const closed = index >= 5;
  const outcomes = ['rider_suspended', 'driver_suspended', 'resolved', 'false_alarm', 'both_suspended'];
  const outcome = closed ? outcomes[index % outcomes.length] : null;
  const raisedAt = trip.createdAt + intBetween(3, 25) * MINUTE;

  return {
    id: `SOS-${7200 + index}`,
    tripId: trip.id,
    raisedBy,
    raisedAt,
    tripStateAtTrigger: SOS_TRIP_STATES[index % SOS_TRIP_STATES.length],

    riderId: rider.id,
    riderName: rider.name,
    riderPhone: rider.phone,
    driverId: driver.id,
    driverName: driver.name,
    driverPhone: driver.phone,

    vehicle: driver.vehicle ?? null,
    location: {
      lat: 30.0444 + (index % 7) * 0.004,
      lng: 31.2357 + (index % 5) * 0.004,
      address: trip.pickupAddress ?? 'Cairo',
    },
    pickupAddress: trip.pickupAddress ?? null,
    destinationAddress: trip.destinationAddress ?? null,
    note: SOS_STATEMENTS[index % SOS_STATEMENTS.length],

    // Contacts alerted, with the delivery result the gateway reported.
    contactsAlerted: Array.from({ length: (index % 3) + 1 }, (_, c) => ({
      name: ['Mona Adel', 'Hoda Samir', 'Nour Hassan', 'Yasmin Fouad'][(index + c) % 4],
      phone: `+2010${String(20000000 + index * 137 + c * 11).slice(0, 8)}`,
      relationship: ['Sister', 'Mother', 'Friend', 'Husband'][(index + c) % 4],
      delivery: c === 0 && index % 4 === 3 ? 'failed' : 'delivered',
    })),
    liveLinkExpiresAt: raisedAt + 90 * MINUTE,

    status: closed ? 'closed' : 'open',
    outcome,
    resolutionNote: closed ? 'Reviewed against the trip record and the driver statement.' : null,
    closedAt: closed ? raisedAt + intBetween(1, 20) * HOUR : null,
    closedBy: closed ? ADMINS[1].email : null,
  };
}).sort((a, b) => b.raisedAt - a.raisedAt);

export const SOS_CASES_BY_ID = new Map(SOS_CASES.map((c) => [c.id, c]));
```

- [ ] **Step 2: Verify the dataset loads**

Serve, then in the browser console on any admin-v2 screen:

```js
const m = await import('./scripts/seed.js');
console.log(m.SOS_CASES.length, m.SOS_CASES.filter(c => c.status === 'open').length);
```

Expected: `11 5`.

- [ ] **Step 3: Commit**

```bash
git add shedrive-web/admin-v2/scripts/seed.js
git commit -m "feat(sos): seed SOS cases in the admin-v2 dataset"
```

---

## Task 5: Add the SOS mock-api methods

**Files:**
- Modify: `shedrive-web/admin-v2/scripts/mock-api.js`

- [ ] **Step 1: Extend the seed import**

Find the existing `import { … } from './seed.js';` at the top of `mock-api.js` and add
`SOS_CASES` and `SOS_CASES_BY_ID` to the named imports.

- [ ] **Step 2: Add the three methods**

Insert into the `mockApi` object, immediately after `resolveSafetyReport`:

```js
  // ── SOS cases ──────────────────────────────────

  listSosCases({ status = 'open', raisedBy = 'all', from = '', to = '', page = 1, pageSize = 20, sort } = {}) {
    const filtered = SOS_CASES.filter(
      (c) =>
        (status === 'all' || c.status === status) &&
        (raisedBy === 'all' || c.raisedBy === raisedBy) &&
        inDateRange(c.raisedAt, from, to),
    );
    // Open cases first, then newest first — a safety queue is worked top-down.
    const sorted = sortRows(filtered, sort, { key: 'raisedAt', dir: 'desc' });
    const ordered = [...sorted].sort((a, b) => {
      if (a.status === b.status) return 0;
      return a.status === 'open' ? -1 : 1;
    });
    return respond(paginate(ordered, page, pageSize), { emptyValue: emptyPage(pageSize) });
  },

  getSosCase(id) {
    const sosCase = SOS_CASES_BY_ID.get(String(id)) ?? null;
    if (!sosCase) return respond(null, { emptyValue: null });
    return respond(
      {
        ...sosCase,
        trip: TRIPS_BY_ID.get(sosCase.tripId) ?? null,
        rider: RIDERS_BY_ID.get(String(sosCase.riderId)) ?? null,
        driver: DRIVERS_BY_ID.get(String(sosCase.driverId)) ?? null,
      },
      { emptyValue: null },
    );
  },

  /**
   * Close a case. Either, both or neither party may be suspended in the same
   * action; the outcome recorded reflects what was actually done.
   */
  actionSosCase(id, { suspendRider = false, suspendDriver = false, outcome, note } = {}) {
    const sosCase = SOS_CASES_BY_ID.get(String(id));
    if (!sosCase) return Promise.reject(new MockApiError('SOS case not found.', 404));
    if (sosCase.status === 'closed') {
      return Promise.reject(new MockApiError('This case is already closed.', 409));
    }

    const now = Date.now();
    const rider = RIDERS_BY_ID.get(String(sosCase.riderId));
    const driver = DRIVERS_BY_ID.get(String(sosCase.driverId));

    if (suspendRider && rider) {
      rider.status = 'suspended';
      rider.suspensionReason = note || `Suspended from SOS case ${sosCase.id}`;
      rider.suspendedAt = now;
      rider.suspendedBy = CURRENT_ADMIN.email;
      patch('riders', rider.id, {
        status: rider.status,
        suspensionReason: rider.suspensionReason,
        suspendedAt: rider.suspendedAt,
        suspendedBy: rider.suspendedBy,
      });
    }

    if (suspendDriver && driver) {
      driver.status = 'suspended';
      driver.suspensionReason = note || `Suspended from SOS case ${sosCase.id}`;
      driver.suspendedAt = now;
      driver.suspendedBy = CURRENT_ADMIN.email;
      patch('drivers', driver.id, {
        status: driver.status,
        suspensionReason: driver.suspensionReason,
        suspendedAt: driver.suspendedAt,
        suspendedBy: driver.suspendedBy,
      });
    }

    const resolved =
      suspendRider && suspendDriver
        ? 'both_suspended'
        : suspendRider
          ? 'rider_suspended'
          : suspendDriver
            ? 'driver_suspended'
            : outcome;

    sosCase.status = 'closed';
    sosCase.outcome = resolved;
    sosCase.resolutionNote = note || null;
    sosCase.closedAt = now;
    sosCase.closedBy = CURRENT_ADMIN.email;

    patch('sosCases', id, {
      status: sosCase.status,
      outcome: sosCase.outcome,
      resolutionNote: sosCase.resolutionNote,
      closedAt: sosCase.closedAt,
      closedBy: sosCase.closedBy,
    });

    return respond({
      ok: true,
      outcome: resolved,
      riderStatus: rider?.status ?? null,
      driverStatus: driver?.status ?? null,
    });
  },
```

- [ ] **Step 3: Verify the methods work**

In the browser console on an admin-v2 screen:

```js
const { mockApi } = await import('./scripts/mock-api.js');
const page = await mockApi.listSosCases({ status: 'open' });
console.log(page.total, page.rows[0].id, page.rows[0].raisedBy);
const one = await mockApi.getSosCase(page.rows[0].id);
console.log(one.rider?.name, one.driver?.name, one.contactsAlerted.length);
```

Expected: a non-zero total, an `SOS-72xx` id, a `rider` or `driver` raiser, and both
names plus a contact count resolving.

- [ ] **Step 4: Commit**

```bash
git add shedrive-web/admin-v2/scripts/mock-api.js
git commit -m "feat(sos): add SOS case list, detail and action methods to the admin-v2 mock API"
```

---

## Task 6: Add the SOS strings and nav entry

**Files:**
- Modify: `shedrive-web/admin-v2/i18n/core.js`, `i18n/lists.js`, `i18n/details.js`
- Modify: `shedrive-web/admin-v2/scripts/nav.js`

- [ ] **Step 1: Nav label in `i18n/core.js`**

In the `en` export's `nav` namespace add `sos: 'SOS requests',`. In the `ar` export's
`nav` namespace add `sos: 'طلبات الطوارئ',`.

Also add to the `en` `status` namespace:

```js
  open: 'Open',
  closed: 'Closed',
  rider_suspended: 'Rider suspended',
  driver_suspended: 'Driver suspended',
  both_suspended: 'Both suspended',
  resolved: 'Resolved',
  false_alarm: 'False alarm',
```

and to `ar` `status`:

```js
  open: 'مفتوحة',
  closed: 'مغلقة',
  rider_suspended: 'تم إيقاف الراكبة',
  driver_suspended: 'تم إيقاف السائقة',
  both_suspended: 'تم إيقاف الطرفين',
  resolved: 'تم الحل',
  false_alarm: 'إنذار كاذب',
```

Skip any key that already exists in `core.js` — never restate one.

- [ ] **Step 2: Queue strings in `i18n/lists.js`**

Add a `sos` namespace to both exports.

`en`:

```js
  sos: {
    title: 'SOS requests',
    breadcrumb: 'Operations > SOS requests',
    openCount: 'Open cases',
    totalCount: 'Total cases',
    statusLabel: 'Status',
    raisedByLabel: 'Raised by',
    timeLabel: 'Raised at',
    colRaisedBy: 'Raised by',
    colTrip: 'Trip',
    colTripState: 'Trip state at trigger',
    colLocation: 'Location',
    colContacts: 'Contacts alerted',
    rider: 'Rider',
    driver: 'Driver',
    emptyHeading: 'No SOS requests',
    emptyMessage: 'No cases match the current filters.',
    csvFile: 'sos-requests',
    csvId: 'Case ID',
  },
```

`ar`:

```js
  sos: {
    title: 'طلبات الطوارئ',
    breadcrumb: 'العمليات > طلبات الطوارئ',
    openCount: 'الحالات المفتوحة',
    totalCount: 'إجمالي الحالات',
    statusLabel: 'الحالة',
    raisedByLabel: 'مقدّمة من',
    timeLabel: 'وقت الطلب',
    colRaisedBy: 'مقدّمة من',
    colTrip: 'الرحلة',
    colTripState: 'حالة الرحلة عند الطلب',
    colLocation: 'الموقع',
    colContacts: 'جهات الاتصال المُخطَرة',
    rider: 'الراكبة',
    driver: 'السائقة',
    emptyHeading: 'لا توجد طلبات طوارئ',
    emptyMessage: 'لا توجد حالات مطابقة للفلاتر الحالية.',
    csvFile: 'طلبات-الطوارئ',
    csvId: 'رقم الحالة',
  },
```

- [ ] **Step 3: Case-detail strings in `i18n/details.js`**

`en`:

```js
  sosCase: {
    title: 'SOS case',
    breadcrumb: 'Operations > SOS requests > Case',
    notFound: 'This SOS case does not exist.',
    incidentTitle: 'Incident',
    locationTitle: 'Location at trigger',
    riderTitle: 'Rider',
    driverTitle: 'Driver',
    vehicleTitle: 'Vehicle',
    tripTitle: 'Trip',
    contactsTitle: 'Contacts alerted',
    resolutionTitle: 'Resolution',
    raisedBy: 'Raised by',
    raisedAt: 'Raised at',
    tripState: 'Trip state at trigger',
    coordinates: 'Coordinates',
    address: 'Address',
    pickup: 'Pickup',
    destination: 'Destination',
    plate: 'Plate',
    viewTrip: 'View trip',
    viewProfile: 'View profile',
    linkExpires: 'Live link expires',
    delivered: 'Delivered',
    failed: 'Could not deliver',
    outcome: 'Outcome',
    closedAt: 'Closed at',
    closedBy: 'Closed by',
    actionTitle: 'Close this case',
    actionHint: 'Suspending either party closes the case. Every action is recorded in the audit log.',
    closedHint: 'This case is closed. No further action is available.',
    suspendRider: 'Suspend the rider',
    suspendDriver: 'Suspend the driver',
    closeResolved: 'Close — resolved',
    closeFalseAlarm: 'Close — false alarm',
    confirmTitle: 'Close SOS case',
    confirmDescription: 'Confirm what you are recording against this case. Suspensions take effect immediately.',
    noteLabel: 'Resolution note',
    noteHint: 'Explain what was found and why this outcome was chosen.',
    noteEmptyError: 'Add a resolution note',
    closedToast: 'SOS case closed.',
  },
```

`ar`:

```js
  sosCase: {
    title: 'حالة طوارئ',
    breadcrumb: 'العمليات > طلبات الطوارئ > الحالة',
    notFound: 'حالة الطوارئ هذه غير موجودة.',
    incidentTitle: 'البلاغ',
    locationTitle: 'الموقع عند الطلب',
    riderTitle: 'الراكبة',
    driverTitle: 'السائقة',
    vehicleTitle: 'المركبة',
    tripTitle: 'الرحلة',
    contactsTitle: 'جهات الاتصال المُخطَرة',
    resolutionTitle: 'القرار',
    raisedBy: 'مقدّمة من',
    raisedAt: 'وقت الطلب',
    tripState: 'حالة الرحلة عند الطلب',
    coordinates: 'الإحداثيات',
    address: 'العنوان',
    pickup: 'نقطة الانطلاق',
    destination: 'الوجهة',
    plate: 'رقم اللوحة',
    viewTrip: 'عرض الرحلة',
    viewProfile: 'عرض الملف',
    linkExpires: 'انتهاء الرابط المباشر',
    delivered: 'تم التسليم',
    failed: 'تعذّر التسليم',
    outcome: 'النتيجة',
    closedAt: 'وقت الإغلاق',
    closedBy: 'أُغلقت بواسطة',
    actionTitle: 'إغلاق هذه الحالة',
    actionHint: 'إيقاف أي من الطرفين يُغلق الحالة. تُسجَّل كل الإجراءات في سجل التدقيق.',
    closedHint: 'هذه الحالة مغلقة. لا توجد إجراءات إضافية.',
    suspendRider: 'إيقاف الراكبة',
    suspendDriver: 'إيقاف السائقة',
    closeResolved: 'إغلاق — تم الحل',
    closeFalseAlarm: 'إغلاق — إنذار كاذب',
    confirmTitle: 'إغلاق حالة الطوارئ',
    confirmDescription: 'أكّدي ما سيُسجَّل على هذه الحالة. يسري الإيقاف فورًا.',
    noteLabel: 'ملاحظة القرار',
    noteHint: 'اشرحي ما تم التوصل إليه وسبب اختيار هذه النتيجة.',
    noteEmptyError: 'أضيفي ملاحظة القرار',
    closedToast: 'تم إغلاق حالة الطوارئ.',
  },
```

- [ ] **Step 4: Add the nav entry**

In `admin-v2/scripts/nav.js`, in the **Operations** group, insert **above** the
`safety` entry:

```js
      { key: 'sos', labelKey: 'nav.sos', href: 'sos-requests.html', icon: 'warning-sign.svg' },
```

- [ ] **Step 5: Verify**

Reload any admin-v2 screen. Expected: **SOS requests** appears in the sidebar above
Safety reports, with the warning-sign icon. Switch to Arabic (`?lang=ar`); expected:
the label reads **طلبات الطوارئ**. The link 404s for now — that is correct, the screen
is Task 7.

- [ ] **Step 6: Commit**

```bash
git add shedrive-web/admin-v2/i18n/core.js shedrive-web/admin-v2/i18n/lists.js shedrive-web/admin-v2/i18n/details.js shedrive-web/admin-v2/scripts/nav.js
git commit -m "feat(sos): add SOS strings and the admin-v2 nav entry"
```

---

## Task 7: Build the SOS request queue

**Files:**
- Modify first: `shedrive-web/admin-v2/_verify.html`
- Create: `shedrive-web/admin-v2/sos-requests.html`
- Create: `shedrive-web/admin-v2/scripts/sos-requests.js`
- Create: `shedrive-web/admin-v2/styles/sos-requests.css`

- [ ] **Step 1: Add the failing verify rows**

In `admin-v2/_verify.html`, in the `PAGES` array, immediately after the
`safety-reports.html` row:

```js
        ['sos-requests.html', { rows: 'tbody tr', kpi: '#sos-stats ad-stat-card' }],
        ['sos-requests.html?state=empty', { state: '.result-message' }],
```

- [ ] **Step 2: Run the harness and watch it fail**

Serve, open `http://localhost:8000/admin-v2/_verify.html`.
Expected: the two `sos-requests.html` rows report **FAIL** in both `en` and `ar` — the
file does not exist yet. Every other row must still pass. If anything else broke, fix
that before continuing.

- [ ] **Step 3: Create `sos-requests.html`**

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SheDrive Admin — SOS requests</title>
    <meta name="robots" content="noindex" />
    <script type="module" src="components/ad-shell.js"></script>
  </head>
  <body>
    <ad-shell
      active="sos"
      page-title-key="sos.title"
      breadcrumb-keys="nav.operations|# > sos.title"
      screen-styles="styles/sos-requests.css"
    >
      <div id="sos-stats" class="ad-stat-row"></div>
      <ad-filter-bar id="sos-filters"></ad-filter-bar>
      <ad-data-table id="sos-table"></ad-data-table>
    </ad-shell>
    <script type="module" src="scripts/sos-requests.js"></script>
  </body>
</html>
```

- [ ] **Step 4: Create `scripts/sos-requests.js`**

```js
/**
 * sos-requests.js — SheDrive admin SOS case queue.
 * Open cases first, then newest first. Status defaults to Open.
 */

import { adminAuth } from './admin-auth.js';
import { mockApi } from './mock-api.js';
import { createRequestGuard } from './request-guard.js';
import { statusLabel } from '../components/ad-status-pill.js';
import { downloadCsv, formatDateTime, toDateInputValue } from './format.js';
import { qs } from '../../shared/scripts/utils.js';
import { t } from './admin-i18n.js';
import { mountStatRow, fillStatRow } from './list-metrics.js';

if (!adminAuth.requireAdmin()) {
  throw new Error('Redirecting to sign-in');
}

const filters = qs('#sos-filters');
const table = qs('#sos-table');

const query = {
  status: 'open',
  raisedBy: 'all',
  from: '',
  to: '',
  page: 1,
  pageSize: 20,
  sort: { key: 'raisedAt', dir: 'desc' },
};

let lastRows = [];

const stats = mountStatRow(qs('#sos-stats'), [
  { key: 'open', label: t('sos.openCount') },
  { key: 'total', label: t('sos.totalCount') },
]);

filters.fields = [
  {
    type: 'select',
    key: 'status',
    label: t('sos.statusLabel'),
    value: 'open',
    options: [
      { value: 'open', label: t('status.open') },
      { value: 'closed', label: t('status.closed') },
      { value: 'all', label: t('common.all') },
    ],
  },
  {
    type: 'select',
    key: 'raisedBy',
    label: t('sos.raisedByLabel'),
    value: 'all',
    options: [
      { value: 'all', label: t('common.all') },
      { value: 'rider', label: t('sos.rider') },
      { value: 'driver', label: t('sos.driver') },
    ],
  },
  { type: 'daterange', key: 'date', label: t('sos.timeLabel'), fromKey: 'from', toKey: 'to' },
];

filters.actions = [
  {
    label: t('common.exportCsv'),
    variant: 'ghost',
    onClick: () => {
      if (!lastRows.length) return;
      downloadCsv(
        `${t('sos.csvFile')}-${toDateInputValue(Date.now())}.csv`,
        [
          t('sos.csvId'),
          t('sos.colRaisedBy'),
          t('sos.colTrip'),
          t('sos.colTripState'),
          t('sos.timeLabel'),
          t('sos.colContacts'),
          t('sos.statusLabel'),
        ],
        lastRows.map((row) => [
          row.id,
          row.raisedBy === 'rider' ? row.riderName : row.driverName,
          row.tripId,
          row.tripStateAtTrigger,
          formatDateTime(row.raisedAt),
          String(row.contactsAlerted.length),
          statusLabel(row.status),
        ]),
      );
    },
  },
];

filters.addEventListener('change', (event) => {
  Object.assign(query, event.detail);
  query.page = 1;
  load();
});

table.pageSize = query.pageSize;
table.sort = query.sort;
table.rowHref = (row) => `sos-request.html?id=${row.id}`;
table.emptyState = {
  icon: '⚠',
  heading: t('sos.emptyHeading'),
  message: t('sos.emptyMessage'),
};

table.columns = [
  {
    key: 'raisedAt',
    label: t('sos.timeLabel'),
    sortable: true,
    className: 'ad-table__nowrap',
    render: (row) => formatDateTime(row.raisedAt),
  },
  {
    key: 'raisedBy',
    label: t('sos.colRaisedBy'),
    render: (row) => {
      const wrap = document.createElement('span');
      wrap.className = 'sos-raiser';

      const pill = document.createElement('span');
      pill.className = `sos-raiser__pill sos-raiser__pill--${row.raisedBy}`;
      pill.textContent = row.raisedBy === 'rider' ? t('sos.rider') : t('sos.driver');

      const name = document.createElement('span');
      name.textContent = row.raisedBy === 'rider' ? row.riderName : row.driverName;

      wrap.append(pill, name);
      return wrap;
    },
  },
  {
    key: 'tripId',
    label: t('sos.colTrip'),
    className: 'ad-table__id',
    render: (row) => {
      const id = document.createElement('span');
      id.className = 'ad-ltr';
      id.textContent = row.tripId;
      return id;
    },
  },
  {
    key: 'tripStateAtTrigger',
    label: t('sos.colTripState'),
    render: (row) => statusLabel(row.tripStateAtTrigger),
  },
  {
    key: 'location',
    label: t('sos.colLocation'),
    render: (row) => row.location?.address ?? '',
  },
  {
    key: 'contactsAlerted',
    label: t('sos.colContacts'),
    numeric: true,
    render: (row) => String(row.contactsAlerted.length),
  },
  {
    key: 'status',
    label: t('sos.statusLabel'),
    sortable: true,
    render: (row) => {
      const pill = document.createElement('ad-status-pill');
      pill.status = row.status === 'closed' && row.outcome ? row.outcome : row.status;
      return pill;
    },
  },
];

table.addEventListener('sortchange', (e) => {
  query.sort = e.detail;
  table.sort = e.detail;
  load();
});
table.addEventListener('pagechange', (e) => {
  query.page = e.detail.page;
  load();
});

const guard = createRequestGuard();

async function load() {
  const isCurrent = guard();
  table.setLoading();
  try {
    const result = await mockApi.listSosCases(query);
    if (!isCurrent()) return;
    lastRows = result.rows;
    table.setData(result);

    const openPage = await mockApi.listSosCases({ status: 'open', pageSize: 1 });
    const allPage = await mockApi.listSosCases({ status: 'all', pageSize: 1 });
    if (!isCurrent()) return;
    fillStatRow(stats, { open: String(openPage.total), total: String(allPage.total) });
  } catch (error) {
    if (!isCurrent()) return;
    table.setError(error.message, load);
  }
}

load();
```

- [ ] **Step 5: Create `styles/sos-requests.css`**

```css
/* SOS request queue — an open safety case must not read like a trip row. */

.sos-raiser {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
}

.sos-raiser__pill {
  font-size: var(--font-size-xs);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
  white-space: nowrap;
}

.sos-raiser__pill--rider {
  background: var(--color-primary-500);
  color: var(--color-surface);
}

.sos-raiser__pill--driver {
  background: var(--color-accent-500);
  color: var(--color-surface);
}
```

- [ ] **Step 6: Run the harness and watch it pass**

Reload `http://localhost:8000/admin-v2/_verify.html` with Ctrl+Shift+R.
Expected: both `sos-requests.html` rows now **PASS** in `en` and `ar`, and every other
row still passes.

- [ ] **Step 7: Verify the screen by eye**

Open `http://localhost:8000/admin-v2/sos-requests.html`. Expected: two stat cards
(open count, total), three filters, a grid with open cases at the top, Rider/Driver
pills, and status pills. Set the status filter to Closed; expected: the outcome pills
render (Rider suspended / Resolved / False alarm). Open `?lang=ar`; expected: RTL
layout, Arabic headers, no English left in the content region.

- [ ] **Step 8: Commit**

```bash
git add shedrive-web/admin-v2/sos-requests.html shedrive-web/admin-v2/scripts/sos-requests.js shedrive-web/admin-v2/styles/sos-requests.css shedrive-web/admin-v2/_verify.html
git commit -m "feat(sos): add the admin-v2 SOS request queue"
```

---

## Task 8: Build the SOS case detail with actions

**Files:**
- Modify first: `shedrive-web/admin-v2/_verify.html`
- Create: `shedrive-web/admin-v2/sos-request.html`
- Create: `shedrive-web/admin-v2/scripts/sos-request.js`
- Create: `shedrive-web/admin-v2/styles/sos-request.css`

- [ ] **Step 1: Add the failing verify row**

In `_verify.html`, in the `DETAIL` array, after the `safety-reports.html` row:

```js
        ['sos-requests.html', 'sos-request.html', { cards: '.standard-card-theme2, .ad-section' }],
```

- [ ] **Step 2: Run the harness and watch it fail**

Reload `_verify.html`. Expected: the `sos-request.html` detail row **FAILS** in both
languages. Everything else still passes.

- [ ] **Step 3: Create `sos-request.html`**

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SheDrive Admin — SOS case</title>
    <meta name="robots" content="noindex" />
    <script type="module" src="components/ad-shell.js"></script>
  </head>
  <body>
    <ad-shell
      active="sos"
      page-title-key="sosCase.title"
      breadcrumb-keys="nav.operations|# > sos.title|sos-requests.html > sosCase.title"
      screen-styles="styles/sos-request.css"
    >
      <p class="result-message" id="not-found" hidden data-i18n="sosCase.notFound">
        This SOS case does not exist.
      </p>

      <div id="case-body" hidden>
        <ad-detail-section id="incident-section" section-title="Incident"></ad-detail-section>
        <ad-detail-section id="location-section" section-title="Location at trigger"></ad-detail-section>

        <div class="sos-columns">
          <ad-detail-section id="rider-section" section-title="Rider"></ad-detail-section>
          <ad-detail-section id="driver-section" section-title="Driver"></ad-detail-section>
        </div>

        <ad-detail-section id="vehicle-section" section-title="Vehicle"></ad-detail-section>
        <ad-detail-section id="trip-section" section-title="Trip"></ad-detail-section>
        <ad-detail-section id="contacts-section" section-title="Contacts alerted"></ad-detail-section>
        <ad-detail-section id="resolution-section" section-title="Resolution" hidden></ad-detail-section>

        <ad-detail-section id="action-section" section-title="Close this case">
          <div class="sos-actions" id="sos-actions">
            <label class="sos-actions__check">
              <input type="checkbox" id="suspend-rider" />
              <span data-i18n="sosCase.suspendRider">Suspend the rider</span>
            </label>
            <label class="sos-actions__check">
              <input type="checkbox" id="suspend-driver" />
              <span data-i18n="sosCase.suspendDriver">Suspend the driver</span>
            </label>
            <div class="sos-actions__buttons">
              <button type="button" class="btn btn--danger" id="close-resolved" data-i18n="sosCase.closeResolved">
                Close — resolved
              </button>
              <button type="button" class="btn btn--ghost" id="close-false-alarm" data-i18n="sosCase.closeFalseAlarm">
                Close — false alarm
              </button>
            </div>
            <p class="sos-actions__hint" id="action-hint" data-i18n="sosCase.actionHint">
              Suspending either party closes the case.
            </p>
          </div>
        </ad-detail-section>
      </div>

      <ad-form-modal id="close-modal"></ad-form-modal>
    </ad-shell>
    <script type="module" src="scripts/sos-request.js"></script>
  </body>
</html>
```

- [ ] **Step 4: Create `scripts/sos-request.js`**

```js
/**
 * sos-request.js — SheDrive admin SOS case detail.
 * Shows the immutable snapshot taken at the tap, and closes the case with an
 * outcome. Either, both or neither party may be suspended in the same action.
 */

import { adminAuth } from './admin-auth.js';
import { mockApi } from './mock-api.js';
import { statusLabel } from '../components/ad-status-pill.js';
import { formatDateTime, formatPhone } from './format.js';
import { qs } from '../../shared/scripts/utils.js';
import { t } from './admin-i18n.js';

if (!adminAuth.requireAdmin()) {
  throw new Error('Redirecting to sign-in');
}

const id = new URLSearchParams(location.search).get('id');
const notFound = qs('#not-found');
const body = qs('#case-body');
const modal = qs('#close-modal');
const shell = document.querySelector('ad-shell');

function link(label, href) {
  const a = document.createElement('a');
  a.href = href;
  a.textContent = label;
  a.className = 'ad-link';
  return a;
}

function ltr(text) {
  const span = document.createElement('span');
  span.className = 'ad-ltr';
  span.textContent = text;
  return span;
}

let current = null;

async function load() {
  const record = await mockApi.getSosCase(id);
  if (!record) {
    notFound.hidden = false;
    body.hidden = true;
    return;
  }
  current = record;
  body.hidden = false;
  notFound.hidden = true;
  render(record);
}

function render(c) {
  qs('#incident-section').items = [
    {
      label: t('sosCase.raisedBy'),
      value: c.raisedBy === 'rider' ? `${t('sos.rider')} — ${c.riderName}` : `${t('sos.driver')} — ${c.driverName}`,
    },
    { label: t('sosCase.raisedAt'), value: formatDateTime(c.raisedAt) },
    { label: t('sosCase.tripState'), value: statusLabel(c.tripStateAtTrigger) },
    { label: t('sos.statusLabel'), value: statusLabel(c.status === 'closed' && c.outcome ? c.outcome : c.status) },
    { label: t('sosCase.linkExpires'), value: formatDateTime(c.liveLinkExpiresAt) },
    { label: '', value: c.note, wide: true, muted: true },
  ];

  qs('#location-section').items = [
    { label: t('sosCase.coordinates'), value: ltr(`${c.location.lat.toFixed(4)}, ${c.location.lng.toFixed(4)}`) },
    { label: t('sosCase.address'), value: c.location.address, wide: true },
  ];

  qs('#rider-section').items = [
    { label: t('sosCase.riderTitle'), value: c.riderName },
    { label: t('common.phone'), value: ltr(formatPhone(c.riderPhone)) },
    { label: t('sos.statusLabel'), value: statusLabel(c.rider?.status ?? 'active') },
    { label: '', value: link(t('sosCase.viewProfile'), `rider-profile.html?id=${c.riderId}`) },
  ];

  qs('#driver-section').items = [
    { label: t('sosCase.driverTitle'), value: c.driverName },
    { label: t('common.phone'), value: ltr(formatPhone(c.driverPhone)) },
    { label: t('sos.statusLabel'), value: statusLabel(c.driver?.status ?? 'active') },
    { label: '', value: link(t('sosCase.viewProfile'), `driver-profile.html?id=${c.driverId}`) },
  ];

  const v = c.vehicle ?? {};
  qs('#vehicle-section').items = [
    { label: t('sosCase.vehicleTitle'), value: [v.make, v.model, v.colour].filter(Boolean).join(' · ') || '—' },
    { label: t('sosCase.plate'), value: v.plate ? ltr(v.plate) : '—' },
  ];

  qs('#trip-section').items = [
    { label: t('sosCase.pickup'), value: c.pickupAddress ?? '—', wide: true },
    { label: t('sosCase.destination'), value: c.destinationAddress ?? '—', wide: true },
    { label: '', value: link(t('sosCase.viewTrip'), `trip-detail.html?id=${c.tripId}`) },
  ];

  qs('#contacts-section').items = c.contactsAlerted.map((contact) => ({
    label: `${contact.name} · ${contact.relationship}`,
    value: `${formatPhone(contact.phone)} — ${contact.delivery === 'delivered' ? t('sosCase.delivered') : t('sosCase.failed')}`,
    muted: contact.delivery !== 'delivered',
  }));

  const closed = c.status === 'closed';
  const resolution = qs('#resolution-section');
  resolution.hidden = !closed;
  if (closed) {
    resolution.items = [
      { label: t('sosCase.outcome'), value: statusLabel(c.outcome) },
      { label: t('sosCase.closedAt'), value: formatDateTime(c.closedAt) },
      { label: t('sosCase.closedBy'), value: c.closedBy },
      { label: '', value: c.resolutionNote, wide: true, muted: true },
    ];
  }

  // A closed case exposes no action controls.
  qs('#action-section').hidden = closed;
}

function closeCase(outcome) {
  const suspendRider = qs('#suspend-rider').checked;
  const suspendDriver = qs('#suspend-driver').checked;

  modal.open({
    title: t('sosCase.confirmTitle'),
    description: t('sosCase.confirmDescription'),
    confirmLabel: t('sosCase.confirmTitle'),
    danger: suspendRider || suspendDriver,
    fields: [
      {
        key: 'note',
        type: 'textarea',
        label: t('sosCase.noteLabel'),
        hint: t('sosCase.noteHint'),
        required: true,
        maxLength: 500,
        emptyError: t('sosCase.noteEmptyError'),
      },
    ],
    onConfirm: async (values) => {
      await mockApi.actionSosCase(id, {
        suspendRider,
        suspendDriver,
        outcome,
        note: values.note,
      });
      shell?.showToast(t('sosCase.closedToast'), 'success');
      await load();
    },
  });
}

qs('#close-resolved').addEventListener('click', () => closeCase('resolved'));
qs('#close-false-alarm').addEventListener('click', () => closeCase('false_alarm'));

load();
```

- [ ] **Step 5: Create `styles/sos-request.css`**

```css
/* SOS case detail. */

.sos-columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

@media (max-width: 1100px) {
  .sos-columns { grid-template-columns: 1fr; }
}

.sos-actions {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.sos-actions__check {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  cursor: pointer;
}

.sos-actions__buttons {
  display: flex;
  gap: var(--space-3);
  flex-wrap: wrap;
}

.sos-actions__hint {
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}
```

- [ ] **Step 6: Run the harness and watch it pass**

Reload `_verify.html` with Ctrl+Shift+R. Expected: the `sos-request.html` detail row
**PASSES** in both languages, and every other row still passes.

- [ ] **Step 7: Verify the action flow by hand**

Open `sos-requests.html`, click an **open** case. Expected: every section renders, the
action section is visible. Tick **both** suspend boxes, click **Close — resolved**,
enter a note, confirm. Expected: a success toast, the action section disappears, a
Resolution section appears with outcome **Both suspended**. Open the rider's and the
driver's profile screens; expected: both now show Suspended. Return to the case;
expected: no action controls, and re-running the action is impossible.

Then open a case that is already closed; expected: no action section at all.

- [ ] **Step 8: Commit**

```bash
git add shedrive-web/admin-v2/sos-request.html shedrive-web/admin-v2/scripts/sos-request.js shedrive-web/admin-v2/styles/sos-request.css shedrive-web/admin-v2/_verify.html
git commit -m "feat(sos): add the admin-v2 SOS case detail with suspend and close actions"
```

---

## Task 9: Wire the SOS screens into the designer index and the audit log

**Files:**
- Modify: `shedrive-web/admin-v2/screens.html`
- Modify: `shedrive-web/admin-v2/scripts/audit-log.js`
- Modify: `shedrive-web/admin-v2/DESIGN-PORT.md`

- [ ] **Step 1: Add the two screen cards**

In `admin-v2/screens.html`, find the card for `safety-reports.html` and add two cards
immediately before it, matching the existing card markup exactly (copy the
safety-reports card and change the href, title and description). Titles:
**SOS requests** (`sos-requests.html`) and **SOS case** (`sos-request.html`).

- [ ] **Step 2: Add the audit action type**

In `admin-v2/scripts/audit-log.js`, find the action-type filter options array and add:

```js
  { value: 'sos_case_closed', label: t('audit.sosCaseClosed') },
```

Add `sosCaseClosed: 'SOS case closed'` to the `audit` namespace in `i18n/lists.js`
(`en`) and `sosCaseClosed: 'إغلاق حالة طوارئ'` (`ar`).

- [ ] **Step 3: Record the data-layer divergence**

Append to `admin-v2/DESIGN-PORT.md`:

```markdown
## Intentional divergence from `admin/` — SOS cases (2026-09-03)

`DESIGN-PORT.md` previously stated the data layer is identical to `admin/` and must
not be forked. That no longer holds. The SOS incident lifecycle
(`docs/superpowers/specs/2026-09-03-sos-incident-lifecycle-design.md`) was built in
`admin-v2` only, at the user's direction. `admin-v2` is therefore ahead of `admin/` by:

- `scripts/seed.js` — `SOS_CASES`, `SOS_CASES_BY_ID`
- `scripts/mock-api.js` — `listSosCases`, `getSosCase`, `actionSosCase`
- `scripts/nav.js` — the `sos` entry
- `sos-requests.html`, `sos-request.html` and their scripts and styles

`admin/` (v1) has none of these and is not being back-filled. Treat `admin-v2` as the
source of truth for anything SOS.
```

- [ ] **Step 4: Verify**

Reload `_verify.html`; expected: all rows pass, including `screens.html`. Open
`screens.html`; expected: the two new cards appear and both links resolve.

- [ ] **Step 5: Commit**

```bash
git add shedrive-web/admin-v2/screens.html shedrive-web/admin-v2/scripts/audit-log.js shedrive-web/admin-v2/i18n/lists.js shedrive-web/admin-v2/DESIGN-PORT.md
git commit -m "docs(sos): index the SOS screens and record the admin-v2 divergence"
```

---

## Task 10: Create the six new ADO stories

**Files:** Azure DevOps project `SheDrive` (no local files in this task)

Parents verified 2026-09-03: `#1773` Emergency & Safety — Rider, `#1774` Emergency &
Safety — Driver, `#1779` Emergency & Safety API, `#1802` Admin — Safety & Incident
Review. All four are Features.

**Conventions that must hold for every story created here:**
- `[Mobile]` / `[API]`: Description holds **only** the As a / I want / So that lines.
  Background, Acceptance Criteria, Out of Scope and Dependencies all go in the
  `Microsoft.VSTS.Common.AcceptanceCriteria` field.
- `[Admin]`: same split, plus the standard bilingual Field Validation table in
  Acceptance Criteria including an **Accepted values** column.
- Area path: `SheDrive\SheDrive Mobile Team` for `[Mobile]`, `SheDrive` for `[API]`
  and `[Admin]`.
- `System.Parent` set as a create field does **not** link. Create the story, then link
  it — or use `wit_add_child_work_items`.

- [ ] **Step 1: Create the two `[Mobile]` stories**

`[Mobile] Rider raises SOS and reaches the emergency screen` → parent `#1773`.
Acceptance criteria must cover: SOS button visible for the whole active trip; a single
confirmation modal; the alert screen states contacts were notified and location is
shared; per-contact delivery status (sent / delivered / failed); police 122 and
ambulance 123 tap-to-call; trip recap showing driver, plate, vehicle and coordinates;
stop-sharing revokes the live link; return-to-trip leaves the alert active;
false-alarm stand-down; and that the driver is **not** notified.

`[Mobile] Driver raises SOS and reaches the emergency screen` → parent `#1774`. Same
criteria, with the recap showing rider name, plate and coordinates, and an explicit
criterion that the rider is **not** notified.

- [ ] **Step 2: Create the two `[API]` stories**

`[API] SOS incident is recorded with a full trip snapshot` → parent `#1779`.
Criteria: a case is created on confirmation; the snapshot captures raiser role and
identity, both parties' names and phones, trip id, trip state at trigger, vehicle,
GPS plus address, pickup, destination, timestamp, contacts alerted and their delivery
results; the snapshot is immutable after creation; the trip is unaffected and still
settles and is rated normally; no account is suspended automatically; the case is
retrievable by admin; unauthenticated requests are rejected.

`[API] Live location link is issued, scoped, and expires` → parent `#1779`.
Criteria: one single-use unguessable link per case; it resolves only to the raiser's
live location and trip details; it expires at trip end + 60 minutes; the raiser can
revoke it early; a revoked or expired link stops resolving; the link exposes nothing
else about her account.

- [ ] **Step 3: Create the two `[Admin]` stories**

`[Admin] Super admin reviews the SOS request queue` → parent `#1802`.
Criteria: 20 rows per page; open cases first then newest first; status filter
defaulting to Open; raised-by filter; date range; CSV export of the current view;
open-case count badge on the nav; empty, loading and error states.

`[Admin] Super admin actions an SOS request` → parent `#1802`.
Criteria: the case shows the full snapshot; the admin may tick suspend-rider,
suspend-driver, both or neither and then close as resolved or false alarm; a
resolution note is required; outcome is recorded as `rider_suspended`,
`driver_suspended`, `both_suspended`, `resolved` or `false_alarm`; closing writes an
audit entry; a closed case exposes no action controls and cannot be reopened.

- [ ] **Step 4: Verify every story is parented**

Query the six new ids and confirm each has the expected `System.Parent` and that the
parent is a Feature. A story with no parent is not acceptable.

- [ ] **Step 5: Commit** — nothing to commit; ADO only. Record the six new ids for Task 12.

---

## Task 11: Update the four existing ADO stories

**Files:** Azure DevOps project `SheDrive`

- [ ] **Step 1: Re-check story points before editing**

Fetch `#1787`, `#1951`, `#1780`, `#1952` and confirm their current point values.
`#1787` carries 3 points; **the user gave explicit approval to edit it on 2026-09-03**.
If any of the other three has become non-zero since this plan was written, stop and
ask before editing that one.

- [ ] **Step 2: Update `#1787` and `#1951`**

Add to the acceptance criteria of both: a maximum of 5 contacts; the add control is
disabled at capacity with an explanatory message; a save that would exceed the cap is
rejected.

- [ ] **Step 3: Update `#1780` and `#1952`**

Add to the acceptance criteria of both: per-contact delivery status is returned and
surfaced; the live link expires at trip end + 60 minutes; the raiser can revoke it
early; a revoked or expired link stops resolving.

- [ ] **Step 4: Verify** — re-fetch all four and confirm the criteria changed and the points are unchanged.

---

## Task 12: Sync the local backlog files

**Files:**
- Modify: `docs/backlog/mobile-rider-stories.md`, `mobile-driver-stories.md`, `api-stories.md`, `admin-stories.md`
- Modify: `docs/backlog/phase-1.5-stories.md`

The four role-split files mirror the active ADO backlog and must match it.

- [ ] **Step 1: Add the six new story sections**

Add each new story to its file under `### Feature 21 — Emergency & Safety`, using the
existing section format in that file: `## [Type] #ID — Title 🆕`, a `**Feature:**`
line, `**Description:**`, `### Background`, `### Acceptance Criteria`,
`### Out of Scope`, `### Dependencies`. Use the real ids from Task 10.

- [ ] **Step 2: Update the four amended stories**

Edit the existing `#1787`, `#1951`, `#1780`, `#1952` sections to match the ADO changes
from Task 11.

- [ ] **Step 3: Correct the stale Phase 1.5 record**

In `docs/backlog/phase-1.5-stories.md`, the SOS cluster is out of date — `#1780` and
`#1787` are active, not deferred, and `#1692` is Closed. Add a dated note at the top of
Cluster A:

```markdown
> **Updated 2026-09-03.** The SOS cluster was rescoped and returned to Phase 1.
> `#1780` and `#1787` are active (`New`), joined by `#1951` and `#1952`, and extended
> by the SOS incident lifecycle (six new stories — see the four role-split backlog
> files). `#1692` is Closed. Only `#1723`, `#1725`, `#1726` and `#1727` remain
> `Removed`: they describe the control-room and Ministry of Interior design that no
> longer exists. See
> `docs/superpowers/specs/2026-09-03-sos-incident-lifecycle-design.md`.
```

Also correct the line in **Decisions captured** that lists `#1781`, `#1812` and `#1813`
as "kept in Phase 1" — all three are `Removed` in ADO. Note their live replacements
(`#1832`, `#1833`) and that no active story replaces `#1781` or `#1813`.

- [ ] **Step 4: Verify** — for each of the six new ids, `grep` the backlog files and confirm exactly one section exists.

- [ ] **Step 5: Commit**

```bash
git add docs/backlog/
git commit -m "docs(backlog): sync SOS incident lifecycle stories with ADO"
```

---

## Self-review notes

**Spec coverage.** §3.1 cap → Task 1. §3.3 delivery status, stop sharing, false alarm →
Tasks 2 and 3. §3.3 driver full screen → Task 3. §3.3 "122 and 123 only" → verified
explicitly in Task 3 Step 7. §4 snapshot → Task 4 seed shape and Task 10 API story.
§5.1 nav → Task 6. §5.2 queue → Task 7. §5.3 case and both-suspensions → Task 8. §5.4
data layer → Tasks 4 and 5. §5.5 i18n → Task 6. §6 ADO → Tasks 10 and 11, backlog sync
Task 12. §5 divergence note → Task 9.

**Not covered by code, by design.** §9 open dependencies (SMS gateway, positioning)
are business decisions with no implementation. §7 out-of-scope items are deliberately
absent.

**Type consistency.** `SOS_CASES` / `SOS_CASES_BY_ID` (Task 4) are the exact names
imported in Task 5. `listSosCases` / `getSosCase` / `actionSosCase` are used with those
names in Tasks 7 and 8. Field names `raisedBy`, `raisedAt`, `tripStateAtTrigger`,
`contactsAlerted`, `liveLinkExpiresAt`, `outcome` are identical across Tasks 4, 5, 7
and 8. Outcome values `rider_suspended` / `driver_suspended` / `both_suspended` /
`resolved` / `false_alarm` match between the seed, `actionSosCase`, the status-pill
labels in Task 6 and the ADO criteria in Task 10.
