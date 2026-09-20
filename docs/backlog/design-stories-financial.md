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

**ADO:** #3977 — created 2026-09-08

**Screen:** `driver/balance.html` (finish)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is a driver's financial home base: one signed balance, read as either money
she is owed (available) or money she owes the platform (outstanding), a warning band
when she is approaching the outstanding limit, and a full statement of every credit
and debit that produced that number — trip commissions, trip earnings, cancellation
fees and shares, recovered-fee deductions, settlements and payouts —
each with a plain-language cause. Any payout Finance has sent her appears here with
its reference and date, exactly like a settlement — there is nothing for her to start;
a payout is only ever recorded after Finance has already sent the money.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code></li>
  <li>Large balance figure (EGP, 2 decimals, right-aligned, tabular figures) with an
  explicit "available" or "outstanding" label — never just a bare signed number</li>
  <li>Warning band: a persistent banner (reuse the same new banner primitive as the
  rider fee notice) shown once her outstanding balance crosses the configured warning
  fraction of the limit</li>
  <li>Statement list: one row per ledger entry — date, entry type in plain language
  (e.g. "Trip commission", "Cash fee collected from rider", "Settlement recorded",
  "Payout received"), signed amount, and a link to the related trip/settlement/payout
  where one exists</li>
  <li>Last-settlement summary block (date, amount, receipt number)</li>
  <li><code>sd-button</code> entry point to <code>settle.html</code></li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — available (positive) balance:</strong> balance reads as
  money SheDrive owes her — an explanation, not an action; there is no withdraw entry
  point anywhere on this screen</li>
  <li><strong>Default — outstanding (negative) balance, under warning band:</strong>
  balance reads as money she owes; settle entry point is the primary action</li>
  <li><strong>Warning band:</strong> outstanding balance at or above the configured
  warning fraction of the limit, still short of being blocked — persistent banner
  above the balance</li>
  <li><strong>Zero balance:</strong> a distinct neutral reading, not styled as either
  a credit or a debit</li>
  <li><strong>Empty statement:</strong> a brand-new driver with no ledger entries yet</li>
  <li><strong>Loading:</strong> skeleton balance and statement rows</li>
  <li><strong>Error:</strong> balance/statement failed to load, with retry</li>
</ul>

<h3>Behaviour</h3>
<p><em>Note: credits and debits in the statement must be distinguishable without
relying on colour alone — pair colour with a leading sign and/or a small icon.
Every row must name its cause; a bare amount with no explanation is not acceptable
anywhere on this screen. Every posted row is permanent — Phase 1 has no correction
mechanism, so nothing here can be edited or reversed.</em></p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

> **Removed 2026-09-13:** drivers do not request payouts. Finance transfers the funds and records the transfer afterwards — see #4001 (which absorbed #3993 on 2026-09-17). There is no driver-initiated request in the system.

---

## [Driver] Settle What You Owe

**ADO:** #3979 — created 2026-09-08

**Screen:** `driver/settle.html` (new)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This screen is where a driver who owes the platform money finds out how to clear
it. Settlement itself is recorded by an admin, in person or via a channel like a bank
deposit — this screen does not take a payment, it tells her what she owes, where and
how she can hand it over, and shows her the history of settlements she has already
made, each with its receipt number.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code></li>
  <li>Amount-owed summary card (EGP, 2 decimals, right-aligned, tabular figures)</li>
  <li>Channel list: the configurable settlement channels (office cash, bank deposit,
  mobile wallet, field agent) each with the detail she needs — office address and
  hours for office cash, account/reference details for bank deposit and mobile
  wallet, contact info for a field agent</li>
  <li>Settlement history list: date, channel, amount, receipt number
  (<code>S-nnnnn</code>)</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — owes money:</strong> amount-owed card, channel list, and
  history all shown</li>
  <li><strong>Zero owed:</strong> a neutral, positive-reading state — nothing to
  settle, channel list can be hidden or muted</li>
  <li><strong>Empty history:</strong> a new driver who has never settled before</li>
  <li><strong>Loading / Error:</strong> standard fetch states with retry on error</li>
</ul>

<h3>Behaviour</h3>
<p><em>Note: there is no in-app "pay now" button on this screen — settlement is a
real-world action an admin records afterward. Design it as an instruction-and-history
screen, not a checkout flow.</em></p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Driver] Go-Online Blocked & Warning Band

**ADO:** #3980 — created 2026-09-08

**Screen:** `driver/home.html` (extend)
**Parent:** #1838 — Driver — Home & Trip Acceptance
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is the highest-stakes screen in the whole financial core: it is the one that
can stop a driver from earning. When her outstanding balance reaches the platform
limit, going online is blocked outright until she settles. Before that point, a
warning band gives her advance notice while she can still work. Both states have to
be immediately legible and immediately actionable — a driver seeing this screen
should never be left wondering how much she owes, what the limit is, or what to do
about it.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code> and the go-online
  toggle/control</li>
  <li>Blocked panel replacing the go-online control entirely: amount owed, the
  configured limit, and a direct <code>sd-button</code> link to
  <code>settle.html</code> — all three always shown together, never the amount alone</li>
  <li>Warning band (the same persistent banner primitive used on
  <code>balance.html</code>): shown below the go-online control once she crosses the
  warning fraction of the limit, while she can still go online</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Normal:</strong> outstanding balance under the warning band — ordinary
  go-online control, no banner</li>
  <li><strong>Warning band:</strong> outstanding balance at or above the warning
  fraction of the limit but still under it — go-online still works, banner states the
  amount and the limit</li>
  <li><strong>Blocked:</strong> outstanding balance at or over the limit — go-online
  control is replaced by the blocked panel; amount, limit, and the route to
  <code>settle.html</code> are always present together</li>
  <li><strong>Limit disabled:</strong> the platform's outstanding-limit policy is set
  to 0 (gate off) — no warning band, no block, ever, regardless of balance</li>
  <li><strong>Loading:</strong> balance/limit status not yet resolved — go-online
  control does not flash blocked and then clear</li>
  <li><strong>Error:</strong> status failed to load — degrade to the normal
  (unblocked) state rather than guessing, with a way to retry</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Driver] Cash Collection with a Recovered Fee

**ADO:** #3981 — created 2026-09-08

**Screen:** `driver/cash-collection.html` (extend)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>When the rider on this trip is carrying a recovered outstanding fee, the driver's
cash-collection screen has to tell her to collect more than the fare — fare plus fee
equals the total she should ask for. This is the driver-side mirror of the rider's
fare-summary story, so the numbers and the plain-language description of the fee must
match exactly what the rider sees on her own screen.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell</li>
  <li>Itemised collection card: fare line, "Recovered fee" line (amount, EGP 2
  decimals, right-aligned, tabular figures), then the total to collect, clearly the
  largest/most prominent number on the screen</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — no recovered fee:</strong> ordinary single-line fare
  collection, unchanged from today</li>
  <li><strong>Default — recovered fee on this trip:</strong> itemised fare + fee =
  total</li>
  <li><strong>Loading / Error:</strong> standard fetch states with retry on error</li>
</ul>

<h3>Behaviour</h3>
<p><em>Note: keep the itemisation and the amount identical to what
<code>trip-complete.html</code> shows the rider — a mismatch here is what makes a fee
recovery feel like the driver charging extra on her own initiative.</em></p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
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

**ADO:** #4381 — created 2026-09-17 · updated 2026-09-17 (freed column carries the #3982 proof thumbnail)

**Screens:** `driver-balances.html`, `driver-balance-details.html` (revision to the delivered kit)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>Two small corrections to the delivered Driver Balances design (<code>driver-balances.html</code>
and <code>driver-balance-details.html</code>, EN and AR). Everything else on both screens stays
exactly as delivered — this is a column change only, not a redesign.</p>

<h3>1. Combine "Outstanding" and "Available" into one balance column</h3>
<p>On the driver balances grid, the two columns <strong>Outstanding (EGP)</strong> and
<strong>Available (EGP)</strong> are replaced by a single <strong>Balance (EGP)</strong> column.
A driver only ever has one balance; showing it as two columns means one of them is always empty
and forces the reader to compare two cells to answer one question.</p>
<ul>
  <li>One signed figure per row: negative means she owes the platform, positive means the
  platform owes her</li>
  <li>Right-aligned, 2 decimals, tabular figures</li>
  <li>The direction must be readable without relying on colour alone — pair colour with the
  leading sign and/or a short label</li>
  <li>Zero reads as neutral — neither owed nor available</li>
  <li>The existing balance-status filter and the go-online column are unchanged</li>
</ul>

<h3>2. Remove the "Note" column from the ledger grid</h3>
<p>On the driver balance details screen, drop the last column, <strong>Note</strong>. The entry
type already names the cause of every row, so the note column added a mostly-empty column with
no new information.</p>
<p>The freed column is not left blank: it carries the <strong>Proof</strong> thumbnail added in
#3982 — the receipt photo or transfer slip attached when the settlement or payout was recorded,
opening full-size on click. The ledger grid therefore becomes: <strong>Date · Type · Amount (EGP)
· Source · Proof</strong>. An entry with nothing attached shows an em dash.</p>

<h3>Scope</h3>
<ul>
  <li>Applies to both language versions of both screens (EN and AR/RTL)</li>
  <li>No new states, modals or actions — existing empty, loading, error and long-text states
  keep working with the revised columns</li>
</ul>

<h3>Preview</h3>
<p>Current live screen: https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/balances.html</p>
<p>Revised mockup: &lt;to be added&gt;</p>
```

---

> **Removed 2026-09-14 — [Admin] Record a Payout (#3983):** merged into #3982. Recording a payout is a modal on the same driver balances screen, so it is designed as part of that screen rather than as its own brief. Its components, states and preview links now live in the #3982 brief above.

---

## [Admin] Per-driver Earnings — Drop the Driver Debt Card, Searchable Driver Picker, Payment Method Column

**ADO:** #4387 — created 2026-09-17

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
<p>Three corrections to the delivered Per-driver earnings &amp; settlement design
(<code>reconciliation.html</code> and <code>reconciliation_ar.html</code>). Everything else on
the screen stays exactly as delivered — this is a filter, card-row and grid-column change, not
a redesign.</p>

<h3>1. Remove the "Driver Debt" card — four cards, not five</h3>
<p>The card row drops <strong>Driver Debt / مديونية السائقة</strong> and keeps four cards:
<strong>Completed trips · Gross fares · Commission deducted · Net earnings</strong>.</p>
<p>The four survivors are all <em>period</em> figures … (full copy in ADO #4387, including the
bordered table giving each card's format, what it shows and what the admin uses it for)</p>

<h3>2. One searchable driver picker — name <em>or</em> phone</h3>
<ul>
  <li>Typing letters matches the <strong>name</strong>; typing digits matches the
  <strong>phone number</strong></li>
  <li>Every result row shows <strong>name and phone together</strong></li>
  <li>01012345678, +20&nbsp;101&nbsp;234&nbsp;5678 and 1012345678 all find the same driver</li>
  <li>No match → "No match for that name or phone / لا يوجد تطابق لهذا الاسم أو الرقم"</li>
  <li>Keyboard: ↑ / ↓ move, Enter picks, Esc closes; the phone keeps LTR inside the RTL layout</li>
</ul>

<h3>3. Add a Payment method column to the per-trip breakdown</h3>
<p>The grid becomes <strong>Trip date · Payment method · Fare (EGP) · Commission (EGP) ·
Net earnings (EGP)</strong>, with Payment method as a Cash / نقدًا or Digital / إلكتروني
status pill in second position. The CSV export carries the same column.</p>

<h3>Preview</h3>
<p>Live screen (all three implemented):
https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html</p>
<p>Arabic (RTL):
https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/reconciliation.html?lang=ar</p>
<p>Searchable picker in a dialog:
https://shedrive-web.abdelrahman-arcorp.workers.dev/admin-v2/trip-detail.html?id=TRP-24001
→ "Reassign to another driver"</p>
<p>Revised mockup: &lt;to be added&gt;</p>
```

---

## [Admin] Rider Outstanding Fees

**ADO:** #3984 — created 2026-09-08

**Screen:** `admin-v2/rider-balances.html` (new)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>The rider-side counterpart to the driver balances screen: every rider currently
carrying an outstanding cancellation balance, and her ledger of fee and payment
entries. Most riders never appear here — this is exception handling, not a routine
list. The screen is <strong>read-only</strong>: there is no waive and no write-off
anywhere in the system. The only way a rider's balance clears is that she pays it, in
full, on her next completed trip. The one action available is escalating a
persistently abusive rider to the existing suspension flow.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton</li>
  <li><code>ad-filter-bar</code>: search by name/phone, status filter (outstanding /
  settled)</li>
  <li><code>ad-data-table</code> columns: rider name, phone, outstanding amount
  (EGP, right-aligned, tabular figures), oldest unpaid fee date,
  <code>ad-status-pill</code> for status</li>
  <li>Ledger view: <code>ad-detail-section</code> plus entries (cancellation fee,
  fee collected) with cause and related trip link</li>
  <li>Link into the existing rider-suspension flow (#1740), for persistent abuse —
  the only action this screen offers beyond visibility</li>
</ul>

<h3>States</h3>
<ul>
  <li>Standard list states: <code>?state=empty</code>, <code>?state=loading</code>,
  <code>?state=error</code>, <code>?state=long</code></li>
  <li>Default populated list; empty state here reads as a genuinely good sign (no
  riders currently owe anything) rather than a neutral "nothing found"</li>
  <li>Ledger drawer/detail open, populated and empty</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Admin] Settlement Day Book

> **Removed 2026-09-13:** cut as a report dressed as a screen. Settlement entries are exportable as CSV from the driver balances screen (#1813), which gives Finance the same reconciliation input. Can return as a real reconciliation — banked amount in, variance out — once the cash-collection model is decided.

---

## [Admin] Balance & Fee Policy

**ADO:** #3986 — created 2026-09-08 · retitled 2026-09-13

**Screen:** `admin-v2/pricing-policies.html` (extend)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This adds the balance policy block to the existing pricing and
policies screen — the single place a super admin changes commission, grace periods,
cancellation fees, and the driver outstanding limit and warning band, with no code
deploy required. A rider's outstanding balance is always recovered in full on her
next completed trip — there is nothing to configure on that side. A payout to a
driver is recorded, never configured here — there is no request, approval, minimum,
maximum, or cooling-off for it anywhere in the system. Every change here writes an
audit-log entry with who, when, old value and new value, and values already
snapshotted onto a trip at driver acceptance are never affected retroactively.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton, added as a new section alongside the
  existing pricing-policy form on this screen</li>
  <li>Form fields, grouped logically (trip economics / cancellation fees / driver
  balance): platform commission %, rider grace period,
  driver cancellation fee, driver cancellation grace period, rider no-show wait,
  driver outstanding limit, driver warning band %</li>
  <li>Inline helper text on the driver outstanding-limit field explicitly stating what
  a value of 0 does: it disables the go-online gate entirely</li>
  <li>Save action with a confirmation toast and an updated "last changed by / when"
  line per field or per section</li>
  <li>Link to the audit log (<code>audit-log.html</code>) for this screen's history</li>
</ul>

<h3>States</h3>
<ul>
  <li>Default — current policy values loaded</li>
  <li>Loading / Error — standard fetch states, with retry on error and no partial
  save on a failed submit</li>
  <li>Validation errors — e.g. negative values, out-of-range percentages</li>
  <li>Saved confirmation — toast plus the refreshed "last changed" metadata</li>
  <li>Zero-value / gate-disabled state on the driver outstanding-limit field, with the
  helper text visibly explaining what that means</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```
