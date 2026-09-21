# SheDrive — Financial Core Design (Screen) Stories

> Source: `docs/superpowers/specs/2026-09-08-financial-core-design.md` §7 (screen inventory).
> These are briefs for a **designer**, not developer stories. Do not create these in
> Azure DevOps from this file — the orchestrator resolves parents and creates the
> work items in the `SheDrive\Design Team` area.

---

## How to read this

Design (screen) stories in ADO use a **different field layout than the regular dev
backlog** (`api-stories.md`, `admin-stories.md`, `mobile-*-stories.md`). Whoever pastes
these into Azure DevOps must follow this exactly — it is the opposite of the dev-story
rule:

- **Everything goes in `System.Description`.** The intro paragraph, the component
  list, every state the designer must draw, the bilingual requirement, and the mockup
  link all live in one field.
- **`Microsoft.VSTS.Common.AcceptanceCriteria` is left EMPTY.** No Gherkin, no
  Field Validation table, no List/Grid Specification section — those are dev-story
  conventions and do not apply here.
- **There is no "As a … I want … so that …" sentence.** A design story describes a
  screen for a designer to draw, not a behaviour for a developer to build.

Each story below has its `Description` content in a fenced block, written as the HTML
that goes straight into the ADO rich-text field (`<p>`, `<h3>`, `<ul>`, `<em>`) —
copy the block's contents verbatim into `System.Description`. Every `Parent` below is a
**verified Feature** in the `SheDrive\Design Team` area path, fetched from ADO on
2026-09-08 — see `docs/backlog/financial-core-ado-parents.md`. Set the area path to
`SheDrive\Design Team` and never create one of these without its parent.

Every story reuses existing SheDrive design-system components — `sd-*` for rider and
driver, `ad-*` for admin — rather than inventing new ones. Where a story needs a
pattern that doesn't exist yet (e.g. a persistent banner distinct from a toast), that
is called out explicitly as a new presentational primitive to design, not a new
one-off screen element.

Two content rules apply across every screen in this set, per the design spec:

1. **Amounts are EGP to 2 decimals, right-aligned, tabular figures.** Credits and
   debits must be distinguishable without relying on colour alone — pair colour with
   a sign (`+` / `−`), an icon, or a label.
2. Where a screen is bilingual, the designer must show **both** the Arabic (RTL) and
   English (LTR) layout — not just describe the string swap.

---

# Rider (`rider/`) — bilingual AR/EN, mobile-first, RTL and LTR both shown

## [Rider] Payment Method & Outstanding Fees

**ADO:** #3974 — created 2026-09-08

**Screen:** `rider/payments.html` (rewrite — currently a coming-soon stub)
**Parent:** #1849 — Rider — Menu & Profile
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This screen is where a rider checks how she pays and whether she owes anything
from a past ride. Cash is the only payment method, so the top of the screen simply
confirms how she pays rather than offering a choice.
Below it, an outstanding fees section lists every fee she currently owes — each tied
to the trip and date it came from — with a plain-language line explaining it will be
added to her next ride rather than charged here and now.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code> (menu, back)</li>
  <li>Payment method block: a single "Cash" row, stated rather than chosen, with a
  short line confirming she pays the driver at the end of the ride</li>
  <li>Outstanding fees section: a card or list per fee showing amount (EGP, 2
  decimals, right-aligned, tabular figures), the originating trip reference and
  date, and the fixed line "this will be added to your next ride"</li>
  <li>Per-fee link to the fee's trip detail (<code>trip-detail.html</code>)</li>
  <li><code>sd-toast-host</code> for load/retry feedback</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — no outstanding fees:</strong> payment methods only, no fees
  section, or a light "You're all settled up" line in its place</li>
  <li><strong>Default — one or more outstanding fees:</strong> fees section populated,
  oldest first</li>
  <li><strong>Loading:</strong> skeleton rows while the fee list loads</li>
  <li><strong>Error:</strong> fee list failed to load, with retry; payment methods
  still render (they are static, not fetched)</li>
</ul>

<h3>Behaviour</h3>
<p>The tone here matters more than the layout. This is a rider being told, calmly,
that she owes money from something that already happened — usually a late
cancellation on an earlier trip. The copy and layout must read as a plain statement
of fact, not a warning: no red, no alert iconography, no "you owe" framing. State the
amount, name the trip it came from, and say plainly that it will be added to her next
ride. She should be able to trace exactly which trip caused it by following the link.
Never fold the fee silently into anything else on this screen — it is always its own
line, with its own trip reference.</p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Rider] Outstanding Fee Notice

**ADO:** #3975 — created 2026-09-08 · retitled 2026-09-17 (was "Outstanding Fee Notice & Full-Recovery State")

**Screen:** `rider/home.html` (extend)
**Parent:** #1844 — Rider — Home & Booking
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is the home screen's money-awareness layer. Most riders never see it. When one
does carry an outstanding balance from a past cancellation, home shows a dismissible
banner stating the <strong>full</strong> amount and that it will be added to her next
ride. Whatever she owes — one late cancellation or several — is always shown as this
single amount; there is no threshold, no escalation and no second, firmer state.</p>

<p><strong>She is never blocked from booking.</strong> An earlier version of this design
blocked her once her balance passed a threshold. That deadlocks: a rider pays in cash on
the ride, so the only way she can ever clear a fee is by taking a ride. Blocking the
booking would make the debt permanent and lose the customer with nothing recovered.
Please do not draw a blocked artboard for the rider — the only block on a rider is an
admin suspending her account, which is an existing flow and a human decision.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell (map, <code>sd-app-header</code> with menu, drawer)</li>
  <li>A new persistent banner primitive (not <code>sd-toast-host</code> — a toast is
  transient and this must persist until dismissed or the fee is cleared); anchored
  above or below the map, using existing token-driven card/alert styling, not a new
  colour system. One weight only — dismissible</li>
  <li>The ordinary "Request a ride" <code>sd-button</code>, unchanged and always present</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default:</strong> no outstanding balance — no banner, ordinary home screen</li>
  <li><strong>Outstanding-balance notice:</strong> dismissible banner stating the full
  outstanding amount and that it will be added to her next ride. Booking stays available</li>
  <li><strong>Loading:</strong> balance status not yet resolved — home renders without a
  banner until it is known</li>
  <li><strong>Error:</strong> balance status failed to load — home degrades to the
  ordinary no-banner state rather than showing a possibly wrong amount, with a quiet retry</li>
</ul>

<h3>Behaviour and tone</h3>
<p><em>Dismissing the notice hides it for the session only — it does not pay or reduce
the balance; there is no waive anywhere in the system, only paying it on her next
completed trip. Make sure the dismiss control cannot be read as "I've paid this." She
sees the same total again on the fare summary (#3999) before she actually pays, so this
banner is informational, not a gate. The tone is calm and factual: state the amount, say
what it clears, link to <code>payments.html</code> for the detail, and never punish.</em></p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Rider] Fare Summary with a Recovered Fee

**ADO:** #3976 — created 2026-09-08

**Screens:** `rider/trip-complete.html` and `rider/trip-detail.html` (extend)
**Parent:** #1846 — Rider — Trip Completion & Rating
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is the moment the fee actually lands: a rider finishes an unrelated trip and
her fare summary shows an extra line — an outstanding fee, recovered on this ride,
from a cancellation on a different, earlier trip. The same summary shape appears
later on that trip's own history entry, so the charge stays traceable long after the
fact. This is the single most awkward moment in the whole flow — she is paying now
for something that happened then — and the design has to carry that honestly.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell; on <code>trip-complete.html</code> the existing
  <code>sd-rating-stars</code> flow is unaffected by this change</li>
  <li>Fare breakdown list/card: base fare line, a distinct "Outstanding fee
  recovered" line (amount, EGP 2 decimals, right-aligned, tabular figures) with a
  link back to the originating trip, then the total — the total is what she actually
  paid</li>
  <li>Same breakdown block reused on <code>trip-detail.html</code> for historic trips</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — no recovered fee:</strong> ordinary fare summary, no extra
  line, unchanged from today</li>
  <li><strong>Default — recovered fee on this trip:</strong> the extra line appears
  above the total, base fare and fee both itemised</li>
  <li><strong>Historic (trip-detail) — with recovered fee:</strong> identical line
  shown when reviewing a past trip that carried a recovery</li>
  <li><strong>Loading:</strong> fare summary not yet resolved</li>
  <li><strong>Error:</strong> summary failed to load, with retry</li>
</ul>

<h3>Behaviour</h3>
<p><em>Note: the copy and layout on this line have to make the charge feel like an
honest accounting of something she already knows about, not a hidden extra tacked
onto an unrelated ride. Always show which trip the fee came from (date and/or trip
reference), never just an unexplained amount. Never combine it into the base fare
number — it is always its own labelled line, on both the fresh trip-complete summary
and the historic trip-detail view, so the two match exactly.</em></p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

# Driver (`driver/`) — bilingual AR/EN, mobile-first

## [Driver] Balance & Statement

**ADO:** #3977 — created 2026-09-08 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screen:** `driver/balance.html` (finish)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>The driver's one balance — what she owes SheDrive, or what SheDrive owes her — and the statement behind it. Reached from Earnings. </p>
<h3>Sections </h3>
<ul>
<li>Balance card: the amount, a label that says which way it runs (<strong>You owe</strong> / <strong>Your available balance</strong>) and one line explaining it </li>
<li>Limit band: shown when she is near or at the balance limit </li>
<li><strong>Settle now</strong> (only while she owes) and <strong>Settlement history</strong> — both open the settle screen </li>
<li>Last settlement: amount and date </li>
<li>Statement: one row per movement — the cause in plain words, date and route or reference, and the signed amount. Trip rows open the trip. Load more at the end </li>
</ul>
<h3>States </h3>
<ul>
<li><strong>Owes</strong> — Settle now is the main action </li>
<li><strong>In credit</strong> — explanation only; no settle, and no withdraw anywhere </li>
<li><strong>Warning</strong> — amber band with the amount and the limit </li>
<li><strong>Blocked</strong> — red band; she cannot go online until she settles </li>
<li><strong>Zero</strong> — a new driver: neutral message and an empty statement </li>
<li><strong>Error</strong> — message and retry </li>
</ul>
<h3>Rules </h3>
<ul>
<li>Credit and debit rows must differ by sign as well as colour </li>
<li>Every row names its cause, and no row can be edited or reversed </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Owes — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?owed=200">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?owed=200</a> </li>
<li>In credit — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?available=850">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?available=850</a> </li>
<li>Warning — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?warn">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?warn</a> </li>
<li>Blocked — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?blocked">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?blocked</a> </li>
<li>Zero / empty statement — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?zero">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?zero</a> </li>
<li>Error — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?error">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?error</a> </li>
<li>English (LTR): use the AR / EN switch in the screen header </li>
</ul>
```

---

> **Removed 2026-09-13:** drivers do not request payouts. Finance transfers the funds and records the transfer afterwards — see #4001 (which absorbed #3993 on 2026-09-17). There is no driver-initiated request in the system.

---

## [Driver] Settle What You Owe

**ADO:** #3979 — created 2026-09-08 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screen:** `driver/settle.html` (new)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>Where a driver sees what she owes, the ways to hand it over, and her past settlements. She settles in person or by transfer and Finance records it — there is no payment inside the app. </p>
<h3>Sections </h3>
<ul>
<li>Amount owed, with one line on how settling works </li>
<li>Ways to settle: office cash, bank deposit, mobile wallet, field agent — each says whether a reference number is needed </li>
<li>SheDrive office: address and opening hours </li>
<li>Settlement history: amount, date, channel and receipt number </li>
</ul>
<h3>States </h3>
<ul>
<li><strong>Owes</strong> — amount, ways to settle and history </li>
<li><strong>Nothing to settle</strong> — a neutral message; history empty for a new driver </li>
<li><strong>Error</strong> — message and retry </li>
</ul>
<h3>Rules </h3>
<ul>
<li>An instruction-and-history screen, not a checkout — no pay button </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Owes — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?owed=320">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?owed=320</a> </li>
<li>Nothing to settle — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?zero">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?zero</a> </li>
<li>Error — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?error">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?error</a> </li>
<li>Reached from the balance screen — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?owed=320">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/balance.html?owed=320</a> </li>
<li>English (LTR): use the AR / EN switch in the screen header </li>
</ul>
```

---

## [Driver] Go-Online Blocked & Warning Band

**ADO:** #3980 — created 2026-09-08 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screen:** `driver/home.html` (extend)
**Parent:** #1838 — Driver — Home & Trip Acceptance
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>How the driver home screen warns her as her balance nears the limit, and stops her going online once she reaches it. </p>
<h3>Sections </h3>
<ul>
<li>Top bar: online toggle and language switch; today's earnings and working zones </li>
<li>Balance band under the top bar: the amount owed, the limit and a <strong>Settle now</strong> button — always together </li>
<li>Blocked sheet: opens when a blocked driver taps the online toggle — why she is blocked, then Settle now, View balance and Close </li>
</ul>
<h3>States </h3>
<ul>
<li><strong>Normal</strong> — no band </li>
<li><strong>Warning</strong> — amber band; she can still go online </li>
<li><strong>Blocked</strong> — red band; tapping the online toggle opens the blocked sheet </li>
</ul>
<h3>Rules </h3>
<ul>
<li>Only going online is refused — a driver already online is never taken offline </li>
<li>If the admin sets the limit to 0, no band and no block ever appear </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Normal — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html?zero">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html?zero</a> </li>
<li>Warning — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html?warn">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html?warn</a> </li>
<li>Blocked (tap the online toggle for the sheet) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html?blocked">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/home.html?blocked</a> </li>
<li>Settle screen the band opens — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?blocked">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/settle.html?blocked</a> </li>
<li>English (LTR): use the AR / EN switch in the screen header </li>
</ul>
```

---

## [Driver] Cash Collection with a Recovered Fee

**ADO:** #3981 — created 2026-09-08 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screen:** `driver/cash-collection.html` (extend)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>When the rider owes a fee from an earlier trip she cancelled late, it is collected with this fare. The cash screen lists it as its own line so the driver can explain the higher total. </p>
<h3>Sections </h3>
<ul>
<li>Total to collect — the largest number on the screen </li>
<li>Breakdown, only when a fee is recovered: Fare, <strong>Outstanding fee from a previous trip</strong>, Total, and a one-line reason </li>
<li>Net earnings for this trip — on the fare only, never the fee </li>
<li>Route </li>
</ul>
<h3>States </h3>
<ul>
<li><strong>No recovered fee</strong> — the total only </li>
<li><strong>Recovered fee</strong> — fare + fee = total </li>
</ul>
<h3>Rules </h3>
<ul>
<li>The wording and the amounts match the rider's fare summary for the same trip exactly (fare 65 + fee 25 = 90 on both) </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>No recovered fee — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/cash-collection.html">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/cash-collection.html</a> </li>
<li>Recovered fee — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/cash-collection.html?riderfee=25">https://shedrive-web.abdelrahman-arcorp.workers.dev/driver/cash-collection.html?riderfee=25</a> </li>
<li>Rider side of the same trip — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/rider/trip-complete.html?fee=25">https://shedrive-web.abdelrahman-arcorp.workers.dev/rider/trip-complete.html?fee=25</a> </li>
<li>English (LTR): use the AR / EN switch in the screen header </li>
</ul>
```

---

# Admin (`admin-v2/`) — bilingual EN default / AR RTL, desktop-first at 1280px and 1440px, `ad-*` components

## [Admin] Driver Balances — Record Settlement & Payout

**ADO:** #3982 — created 2026-09-08 · updated 2026-09-13 · #3983 Record a Payout merged in 2026-09-14 · updated 2026-09-17 (receipt image, no office-cash channel, overpayment allowed)

**Screen:** `admin-v2/balances.html` (finish)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is where operations staff see every driver's balance in one place, drill into
a driver's full ledger, and record money moving in either direction — a
<strong>settlement</strong> when she hands cash back, and a <strong>payout</strong> when
Finance has transferred money to her. Recording a settlement here is what unblocks her
go-online state if it clears her below the outstanding limit — no separate step.
Recording a payout is the mirror of that, in the opposite direction: Finance transfers
money on its own cycle, outside the system, and this is where the transfer is written
down afterward. There is no request, no queue, and no approve/reject — recording is the
only step. Settlement entries export to CSV directly from this screen, which is
Finance's reconciliation input now that the separate day-book screen has been cut.</p>

<p><strong>Updated 2026-09-17 — three changes, detailed in the rules below:</strong> the
office-cash channel is removed, a driver may settle more than she owes, and both modals
accept a photo of the receipt or transfer confirmation.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton</li>
  <li><code>ad-filter-bar</code>: search by name/phone, balance-status filter
  (outstanding / available / warning / blocked)</li>
  <li><code>ad-data-table</code> columns: driver name, balance (EGP, right-aligned,
  tabular figures), <code>ad-status-pill</code> for balance status, last settlement
  date; row opens the driver's ledger</li>
  <li>Ledger view: <code>ad-detail-section</code> for the driver summary plus an
  <code>ad-data-table</code> or <code>ad-timeline</code> of ledger entries (type,
  date, signed amount, cause, related trip/settlement/payout link, and the attached
  receipt image where one was uploaded)</li>
  <li><code>ad-form-modal</code> "Record settlement" — channel select (configurable
  list), reference field, amount, <strong>image upload</strong>, generated receipt
  number shown on success</li>
  <li><code>ad-form-modal</code> "Record payout", launched from the driver's ledger —
  read-only driver summary (name, current available balance), amount (EGP, capped at
  the available balance), date (defaults to today), reference (the bank/wallet
  transaction id or receipt), <strong>image upload</strong>; success shows a
  confirmation toast and the new balance</li>
  <li>CSV export action on the settlement entries — driver, amount, channel,
  reference, receipt number, recording admin, and time — scoped to the active
  filters</li>
</ul>

<h3>Rules</h3>
<ul>
  <li><strong>Receipt image (new).</strong> Both the record-settlement and the
  record-payout modal accept one image as proof — a photo of the signed receipt, the
  bank slip, or the wallet transfer confirmation. It is optional: recording is never
  blocked by a missing image, because the money has already moved and the record must
  not be delayed. Accepted formats JPG and PNG, up to 5&nbsp;MB, one image per record.
  Once uploaded it is permanent, like the entry itself; it can be viewed full-size from
  the ledger entry but never replaced or removed.</li>
  <li><strong>No office-cash channel (changed).</strong> "Cash at office" is removed
  from the settlement channel list. SheDrive has no cash office, so it was never a real
  channel. The reference field is therefore required on every remaining channel — there
  is no longer a channel where it defaults to the generated receipt number.</li>
  <li><strong>A driver may pay more than she owes (changed).</strong> The settlement
  amount is no longer capped at her outstanding balance. If she hands back more than she
  owes, the surplus is not rejected — it simply carries forward as an available balance,
  which Finance later pays out like any other available balance. The confirmation states
  the resulting balance in plain language so the admin sees the crossover: she owed X,
  she paid Y, SheDrive now owes her Y − X.</li>
</ul>

<h3>States</h3>
<ul>
  <li>Standard list states per the portal convention: <code>?state=empty</code>,
  <code>?state=loading</code>, <code>?state=error</code>, <code>?state=long</code></li>
  <li>Default populated list, with blocked/over-limit drivers visually distinguished
  in the status column</li>
  <li>Ledger drawer/detail open, populated and empty (a driver with no ledger
  activity yet)</li>
  <li>Record-settlement modal: default, validation errors (missing reference, missing
  channel, missing or invalid amount), success with receipt number and a confirmation
  toast</li>
  <li>Record-settlement overpayment: the entered amount is larger than what she owes —
  accepted, with the confirmation naming the surplus that becomes her available balance,
  and her row in the list flipping from outstanding to available immediately</li>
  <li>Image upload: nothing attached (the default), an image selected and previewed
  before confirming, upload in progress, rejected file (wrong format or over 5&nbsp;MB)
  with a clear message, and the attached image viewed full-size from the ledger entry
  afterwards</li>
  <li>Record-payout modal: default (a positive available balance), validation errors
  (amount above the available balance, or the reference/date missing), success with a
  confirmation toast, the new <code>payout</code> entry in the ledger and the
  available balance updated immediately</li>
  <li>Zero or negative available balance: the record-payout action is not offered for
  this driver</li>
  <li>Zero-balance driver in the list and in the ledger drawer</li>
</ul>

<h3>Preview Links</h3>
<ul>
  <li>Default / Empty / Loading / Error / Long text / Arabic (RTL):
  <code>admin-v2/balances.html</code> with <code>?state=empty|loading|error|long</code>
  or <code>?lang=ar</code></li>
  <li>Record payout: set the balance filter to "Owed by the platform", open Reem
  Nabil's ledger, then Record payout</li>
</ul>
```

---

## [Admin] Driver Balances — One Balance Column, Drop the Note Column

**ADO:** #4381 — created 2026-09-17 · updated 2026-09-17 (freed column carries the #3982 proof thumbnail) · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screens:** `driver-balances.html`, `driver-balance-details.html` (revision to the delivered kit)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>Two column changes to the delivered Driver Balances design (driver-balances.html and driver-balance-details.html, English and Arabic). Everything else stays as delivered. </p>
<h3>Changes </h3>
<ul>
<li><strong>One Balance column</strong> — Outstanding and Available become a single Balance (EGP) column: one signed figure, negative when she owes, positive when she is owed, zero neutral. Sign plus colour, never colour alone. A driver only ever has one balance, so two columns always left one empty </li>
<li><strong>No Note column in the ledger</strong> — the entry type already names the cause. The freed slot carries the Proof thumbnail from #3982 (receipt or transfer slip, full size on click; — when there is none). Ledger columns: Date · Type · Amount (EGP) · Source · Proof </li>
</ul>
<h3>Rules </h3>
<ul>
<li>Both screens, both languages; existing empty, loading, error and long-text states keep working </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Driver Balances (open any driver's ledger for the second change) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html</a> </li>
<li>Arabic (RTL) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html?lang=ar">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html?lang=ar</a> </li>
</ul>
```

---

> **Removed 2026-09-14 — [Admin] Record a Payout (#3983):** merged into #3982. Recording a payout is a modal on the same driver balances screen, so it is designed as part of that screen rather than as its own brief. Its components, states and preview links now live in the #3982 brief above.

---

## [Admin] Per-driver Earnings — Drop the Driver Debt Card, Searchable Driver Picker, Payment Method Column

**ADO:** #4387 — created 2026-09-17 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screens:** `reconciliation.html`, `reconciliation_ar.html` (revision to the delivered kit `SheDrive.AdminPanel_v16-09-2026`)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**Dev counterpart:** #1833 — [Admin] Admin views per-driver earnings & settlement report
**AcceptanceCriteria:** *(leave empty — design story format)*

Three corrections, gathered into one story:

| # | Change | Why |
|---|---|---|
| 1 | Drop the **Driver Debt** card — four cards, not five | The other four are period figures that move with the date range; Driver Debt is a live balance that does not. Standing them in one row invites a meaningless subtraction. Her live balance is already reported as *Outstanding cash balance* in the Cash vs digital rail and as the balance column on Driver Balances (#1813). |
| 2 | One **searchable driver picker**, matched on name *or* phone | The kit ships two controls for one job — a free-text "Search by driver name …" box beside a name-only "Select Driver …" dropdown. An admin answering a payment query has the driver's number in front of her, not her spelling. Applies **everywhere a person is picked**, including the *Reassign to another driver* dialog on Trip detail. |
| 3 | Add a **Payment method** column to the per-trip grid | It decides who is holding the money: on a cash trip the driver has the fare and owes the commission, on a digital trip the platform has the fare and owes her the net. Without it a row's net earnings cannot be read as "money she has" or "money she is owed", and the Cash vs digital rail cannot be traced back to individual trips. |

```html
<p>Three changes to the delivered Per-driver earnings &amp; settlement design (reconciliation.html, English and Arabic). Everything else stays as delivered. Dev counterpart: #1833. </p>
<h3>Changes </h3>
<ul>
<li><strong>Four cards, not five</strong> — drop Driver Debt. The other four — Completed trips, Gross fares, Commission deducted, Net earnings — all change with the date range; Driver Debt is a live balance that does not, so it misleads in that row. Her balance is already on this screen and on Driver Balances. Lay the four out as four equal columns </li>
<li><strong>One searchable driver picker</strong> — replaces the name search box and the driver dropdown. Letters match the name, digits match the phone (in any format); each result shows name and phone; arrow keys, Enter and Esc work; the phone stays LTR in Arabic. The same picker is used everywhere one driver or rider is chosen, including Reassign on Trip detail </li>
<li><strong>Payment method column</strong> — the grid becomes Trip date · Payment method · Fare · Commission · Net earnings. A Cash / Digital pill, second, because it decides who holds the money on each row. The CSV export includes it </li>
</ul>
<h3>Rules </h3>
<ul>
<li>English and Arabic, at 1280 and 1440 px; existing empty, loading and error states keep working </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Per-driver earnings — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html</a> </li>
<li>Arabic (RTL) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html?lang=ar">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html?lang=ar</a> </li>
<li>Picker in a dialog (Reassign to another driver) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/trip-detail.html?id=TRP-24001">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/trip-detail.html?id=TRP-24001</a> </li>
</ul>
```

---

## [Admin] Rider Outstanding Fees

**ADO:** #3984 — created 2026-09-08 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screen:** `admin-v2/rider-balances.html` (new)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>Riders who currently owe a late-cancellation fee, and the ledger behind each balance. Read-only: a fee is never waived — it clears only when she pays it in full on her next completed trip. </p>
<h3>Sections </h3>
<ul>
<li>Search by name or phone, and a balance filter: Outstanding, Settled, All </li>
<li>Grid: name, phone, outstanding amount (EGP), oldest unpaid fee date, and a Ledger action </li>
<li>Ledger: every fee and every recovery, with date, type, amount and trip </li>
<li>Suspend-rider link for persistent abuse — the only action on this screen </li>
</ul>
<h3>States </h3>
<ul>
<li><strong>Default</strong> — riders who owe </li>
<li><strong>Empty</strong> — no rider owes anything; reads as good news, not “nothing found” </li>
<li><strong>Loading</strong>, <strong>Error</strong>, <strong>Long names</strong> </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Default — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html</a> </li>
<li>Empty — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=empty">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=empty</a> </li>
<li>Loading — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=loading">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=loading</a> </li>
<li>Error — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=error">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=error</a> </li>
<li>Long names — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=long">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?state=long</a> </li>
<li>Arabic (RTL) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?lang=ar">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/rider-balances.html?lang=ar</a> </li>
</ul>
```

---

## [Admin] Settlement Day Book

> **Removed 2026-09-13:** cut as a report dressed as a screen. Settlement entries are exportable as CSV from the driver balances screen (#1813), which gives Finance the same reconciliation input. Can return as a real reconciliation — banked amount in, variance out — once the cash-collection model is decided.

---

## [Admin] Balance & Fee Policy

**ADO:** #3986 — created 2026-09-08 · retitled 2026-09-13 · rewritten 2026-09-21 (shorter, one format across all design stories)

**Screen:** `admin-v2/pricing-policies.html` (extend)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>The balance and fee section of Global Policies — where a super admin sets commission, grace periods, cancellation fees and the driver balance limit, with no code release. </p>
<h3>Sections </h3>
<ul>
<li>Trip economics: platform commission % </li>
<li>Cancellation: rider grace period, driver cancellation fee, driver grace period, rider no-show wait </li>
<li>Driver balance: outstanding limit and warning band %. Under the limit, a line saying 0 turns the go-online block off </li>
<li>One <strong>Save</strong> for the whole form, then a confirmation and the “last changed by / when” line </li>
<li>Link to the audit log </li>
</ul>
<h3>States </h3>
<ul>
<li><strong>Default</strong>, <strong>Loading</strong>, <strong>Error</strong> (a failed save changes nothing) </li>
<li><strong>Validation errors</strong> — e.g. a negative value or a percentage over 100 </li>
<li><strong>Saved</strong> — confirmation and refreshed “last changed” </li>
<li><strong>Limit set to 0</strong> — the helper line explains the block is off </li>
</ul>
<h3>Rules </h3>
<ul>
<li>Every change is written to the audit log: who, when, old value, new value </li>
<li>A change never touches a trip already accepted — it keeps the values it was accepted with </li>
<li>Nothing to set for riders: an outstanding fee is always recovered in full on her next trip </li>
</ul>
<h3>Preview Links </h3>
<ul>
<li>Default — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html</a> </li>
<li>Loading — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?state=loading">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?state=loading</a> </li>
<li>Error — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?state=error">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?state=error</a> </li>
<li>Arabic (RTL) — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?lang=ar">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/pricing-policies.html?lang=ar</a> </li>
<li>Audit log — <a href="https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/audit-log.html">https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/audit-log.html</a> </li>
</ul>
```
