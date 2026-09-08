# SOS Incident Lifecycle — Design

**Date:** 2026-09-03
**Status:** Approved for implementation
**Scope:** Rider app, Driver app, `admin-v2` portal, API + Admin + Mobile stories in ADO
**Supersedes:** the control-room SOS design removed in the 2026-06-17 Phase 1.5 deferral

---

## 1. Why this exists

Phase 1 SOS today is: save emergency contacts, tap SOS during a trip, contacts are
alerted with a live location link. Public numbers 122 / 123 are dialled by the user
herself. That is the whole feature.

Three things are missing that this design adds:

1. **An SOS leaves no trace.** No record is kept anywhere, so operations cannot
   count incidents, investigate one afterwards, spot a repeat pattern, or answer a
   regulator or insurer.
2. **The driver has roughly half the rider's feature.** She gets the button but not
   the aftermath.
3. **Nobody can act on an SOS.** There is no queue, no case, and no way to suspend
   an account or close an incident.

---

## 2. The model

An **SOS Case** becomes a first-class object. One tap creates one case.

| Property | Decision |
|---|---|
| **Visibility to the other party** | **Silent.** The other person in the car is never told. If the threat is the other occupant, notifying them escalates the danger. |
| **Effect on the trip** | **None.** The trip runs on and settles and is rated exactly as normal. The case is a parallel record. |
| **Automatic suspension** | **None.** The system never suspends anyone. An admin decides. |
| **Who can raise it** | Rider or driver, **during an active trip only**. |
| **Who closes it** | An admin, always. Cases do not auto-close. |

Rationale for "silent": it is the only choice that is safe in the worst case. The
cost is that in a medical or collision emergency the nearest available help is not
alerted — accepted for this phase, revisit when an operations desk is staffed.

Rationale for "trip runs on": cancelling the ride mid-journey can strand her
somewhere worse than the car. Locking the trip open blocks the driver's next fare
and her settlement for something she may have had no part in.

---

## 3. Mobile — rider and driver become symmetric

Both apps end up with an identical feature set. Today the driver is missing most of
the post-tap experience.

### 3.1 Emergency contacts screen

Exists on both (`rider/sos.html`, `driver/sos.html`, sharing
`shared/scripts/emergency-contacts.js`).

**Changes:**
- **Cap at 5 contacts.** The add button disables at 5 with an explanatory line.
  Each contact is a paid SMS per alert, so the list is a cost driver.
- Existing validation stands: name required, phone required and valid.
  Relationship stays optional.

### 3.2 SOS button and confirmation

Exists on both (`rider/active-trip.html`, `driver/trip.html`). Unchanged — a single
confirm modal between the tap and the alert, guarding against pocket presses.

### 3.3 Alert screen

The rider has a full screen (`rider/emergency.html`). **The driver's small overlay in
`driver/trip.html` is replaced by an equivalent full screen** (`driver/emergency.html`).

Both screens contain:

| Element | Notes |
|---|---|
| Status header | "Your emergency contacts have been notified · your live location is being shared" |
| Notified contacts | One row per contact **with delivery status: sent / delivered / failed** |
| Call buttons | **Police 122 and Ambulance 123 only.** No fire brigade. |
| Trip recap | Rider sees driver name, plate, vehicle, current coordinates. Driver sees rider name, plate, vehicle, current coordinates. |
| Stop sharing | Revokes the live link immediately. New on both. |
| Return to trip | Alert stays active. |
| Cancel — false alarm | Closes the alert, stops sharing, marks the case `false_alarm_by_user`. New on the driver side. |

Delivery status replaces today's unconditional "they have been notified", which
reassures her even when the SMS failed.

### 3.4 The live location link

- Issued once per case, a single-use unguessable URL.
- **Expires at trip end + 60 minutes.** Covers the walk from the car to safety
  without leaking her location indefinitely.
- **Revocable by her at any time** from the alert screen.
- Shows the raiser's live location and trip details; nothing else about her account.

---

## 4. The SOS case record

Captured at the instant of confirmation and **immutable** thereafter:

**Who** — raiser role (`rider` | `driver`) and identity · rider name + phone ·
driver name + phone
**Where** — GPS at trigger + reverse-geocoded address · pickup address ·
destination address · route progress at trigger
**What** — trip id · **trip state at trigger** (`en_route_pickup` | `arrived_pickup` |
`trip_started`) · vehicle make, model, colour, plate
**When** — timestamp (UTC+2)
**Alerting** — contacts alerted, per-contact delivery status, live-link issued and
its expiry

Mutable case fields: `status` (`open` | `closed`) · `outcome` · resolution note ·
closed by · closed at.

The snapshot is frozen because it is the audit record. If the trip continues and the
car moves, the case must still show where she was when she pressed the button.

---

## 5. Admin — `admin-v2` only

Built in `shedrive-web/admin-v2/` only. `admin/` (v1) is **not** changed.

> **Deliberate divergence.** `DESIGN-PORT.md` states the data layer is identical
> across `admin/` and `admin-v2/` and must not be forked. Adding SOS to v2 alone
> breaks that. This is accepted — v2 is the direction of travel — and must be
> recorded in `DESIGN-PORT.md` as an intentional divergence, not left to be
> discovered later as drift.

### 5.1 Navigation

New item in `admin-v2/scripts/nav.js`, in the **Operations** group, **above** Safety
reports:

```
{ key: 'sos', labelKey: 'nav.sos', href: 'sos-requests.html', icon: 'warning-sign.svg' }
```

Carries an **open-case count badge**. Prominent, but a review queue — no sound, no
popup. The portal must not imply a response time the operation cannot currently meet.

### 5.2 `sos-requests.html` — the queue

Standard list-screen controller; copies the shape of `admin-v2/scripts/safety-reports.js`.

- **Columns:** raised at · raised by (Rider/Driver pill + name) · trip · trip state at
  trigger · location · contacts alerted · status
- **Filters:** status (`open` default / `closed` / `all`) · raised by
  (`all` / `rider` / `driver`) · date range
- **Sort:** open cases first, then newest first
- Open rows carry a severity stripe so a safety incident does not read like a trip row
- Honours `?state=empty|loading|error|long`
- CSV export of the current view, matching the other list screens

### 5.3 `sos-request.html` — the case detail

Panels, using `ad-detail-section`:

1. **Incident header** — who raised it, when, trip state at trigger, current status
2. **Location** — static map at the trigger point, coordinates, address
3. **Rider** — name, phone, account status, link to profile
4. **Driver** — name, phone, account status, link to profile
5. **Vehicle** — make, model, colour, plate
6. **Trip** — pickup → destination, progress at trigger, link to `trip-detail.html`
7. **Contacts alerted** — one row per contact with delivery status
8. **Resolution** — once closed: outcome, note, who closed it, when

**Action bar** (open cases only):

| Action | Effect |
|---|---|
| Suspend the rider | Reuses `suspendRider`. Records outcome `rider_suspended`. |
| Suspend the driver | Reuses `suspendDriver`. Records outcome `driver_suspended`. |
| Close — resolved | Genuine emergency, handled, no account action. |
| Close — false alarm | Accidental or test press. Kept distinct from *resolved* so repeat false alarms stay visible in reporting. |

**Both suspensions may be applied to one case.** The action bar lets the admin tick
*suspend the rider*, *suspend the driver*, both, or neither, then choose the closing
outcome — so a single confirmed action can suspend both parties and close the case in
one step. Outcome is recorded as `rider_suspended`, `driver_suspended`,
`both_suspended`, `resolved` or `false_alarm`. Every action requires a reason note,
and applying an outcome closes the case.

A closed case is not reopened. If ops later needs to suspend the other party, they do
it from that person's profile screen, which already supports it.

Because suspension goes through the existing mutations, a suspension raised from a
case appears on the person's profile screen and in the audit log identically to one
raised anywhere else.

### 5.4 Data layer

`admin-v2/scripts/seed.js` gains `SOS_CASES` (derived from existing `TRIPS`, mixing
rider-raised and driver-raised, open and closed) and `SOS_CASES_BY_ID`.

`admin-v2/scripts/mock-api.js` gains three methods, mirroring the safety-report set:

```js
listSosCases({ status='open', raisedBy='all', from='', to='', page=1, pageSize=20, sort })
getSosCase(id)          // joins trip, rider, driver, vehicle, contacts
actionSosCase(id, { suspendRider, suspendDriver, outcome, note })
```

`admin-v2/scripts/audit-log.js` action types gain `sos_case_closed`.

### 5.5 i18n

English and Arabic strings added **in the same edit**, per `I18N-PORT.md`:
`nav.sos` in `i18n/core.js`, the queue strings in `i18n/lists.js`, the case detail
strings in `i18n/details.js`.

---

## 6. ADO work

All parents verified as Features on 2026-09-03.

### New stories

| Story | Parent |
|---|---|
| `[Mobile]` Rider raises SOS and reaches the emergency screen | `#1773` Emergency & Safety — Rider |
| `[Mobile]` Driver raises SOS and reaches the emergency screen | `#1774` Emergency & Safety — Driver |
| `[API]` SOS incident is recorded with a full trip snapshot | `#1779` Emergency & Safety API |
| `[API]` Live location link is issued, scoped, and expires | `#1779` Emergency & Safety API |
| `[Admin]` Super admin reviews the SOS request queue | `#1802` Admin — Safety & Incident Review |
| `[Admin]` Super admin actions an SOS request | `#1802` Admin — Safety & Incident Review |

### Updates to existing stories

| Story | Change | Note |
|---|---|---|
| `#1787` Rider emergency contacts | Cap at 5 | **3 points — user confirmed the edit on 2026-09-03** |
| `#1951` Driver emergency contacts | Cap at 5 | unpointed |
| `#1780` Rider contacts notified on SOS | Delivery status, link TTL, revocation | unpointed |
| `#1952` Driver contacts notified on SOS | Delivery status, link TTL, revocation | unpointed |

The removed stories `#1723`, `#1725`, `#1726`, `#1727` stay removed. They describe
the control-room design that no longer exists; the new stories replace them.

### Conventions to honour

- Every story gets a Feature parent — no exceptions.
- `[API]` and `[Mobile]` stories: Description carries only *As a / I want / So that*.
  Background, scenarios, out of scope and dependencies go in Acceptance Criteria.
- `[Admin]` stories carry the standard bilingual Field Validation table, including
  *Accepted values*.
- The four role-split files in `docs/backlog/` must be updated in the same pass so
  ADO and the local backlog stay in sync.

---

## 7. Out of scope

- Notifying the other party in the car (deliberate — see §2)
- Control room or staffed operations desk
- Fire brigade as a third emergency number (**dropped at user request, 2026-09-03**)
- Live location tracking for the admin — the case shows a snapshot at trigger, not a
  live feed. Revisit when the ops desk is staffed.
- Real-time alerting in the portal (sound, popup)
- SOS outside an active trip
- Automatic suspension on any pattern
- Changes to `admin/` (v1)

---

## 8. Build order

The work splits into four independent slices that touch disjoint files:

1. **ADO stories** — 6 new, 4 updated, plus the four `docs/backlog/` files.
   Independent of all code.
2. **Mobile — contacts cap** — `shared/scripts/emergency-contacts.js` plus locale keys.
   Smallest slice, touches both apps at once.
3. **Mobile — driver alert screen** — new `driver/emergency.html` + script + styles,
   and the delivery-status / stop-sharing / false-alarm additions to the rider screen.
4. **admin-v2 — SOS queue and case** — nav, seed, mock-api, i18n, then the two
   screens. The data layer lands before either screen.

Slice 1 can run alongside any of the others. Within slice 4 the data layer is a
prerequisite for both screens, so it is not parallelisable end to end.

---

## 9. Known open dependencies

These sit outside this design and still block a production launch:

1. **SMS gateway.** Reaching an Egyptian mobile needs a supplier, a contract, a
   sender ID, a per-message cost and delivery reporting. No story owns it and no
   supplier is chosen. Delivery status in §3.3 depends on the gateway reporting it.
2. **Positioning.** The brief and deck still promise a direct line to the Ministry of
   Interior. The product does not have one and this design does not add one.
