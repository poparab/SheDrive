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
from a past ride. Cash is the only active method in Phase 1; online payment is shown
but not selectable, so the door is visibly open for later without promising a date.
Below it, an outstanding fees section lists every fee she currently owes — each tied
to the trip and date it came from — with a plain-language line explaining it will be
added to her next ride rather than charged here and now.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code> (menu, back)</li>
  <li>Payment method list: a selected/active "Cash" row and a visually disabled
  "Online payment — coming soon" row (same row style, muted, no tap target)</li>
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

## [Rider] Outstanding Fee Notice & Full-Recovery State

**ADO:** #3975 — created 2026-09-08

**Screen:** `rider/home.html` (extend)
**Parent:** #1844 — Rider — Home & Booking
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is the home screen's money-awareness layer. Most riders never see it. When one
does carry a fee from a past cancellation, home shows a dismissible banner stating the
amount and that it will be added to her next ride. If her outstanding fees reach the
recovery threshold, that banner is replaced by a firmer, non-dismissible one saying her
<strong>whole</strong> balance will be recovered on this ride — a bigger number, so she
must see it before she confirms.</p>

<p><strong>She is never blocked from booking.</strong> An earlier version of this design
blocked her at the threshold. That deadlocks: a Phase 1 rider pays cash and has no card,
so the only way she can ever clear a fee is by taking a ride. Blocking the booking would
make the debt permanent and lose the customer with nothing recovered. Please do not draw
a blocked artboard for the rider — the only block on a rider is an admin suspending her
account, which is an existing flow and a human decision.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell (map, <code>sd-app-header</code> with menu, drawer)</li>
  <li>A new persistent banner primitive (not <code>sd-toast-host</code> — a toast is
  transient and this must persist until the fee is cleared or the banner is dismissed);
  anchored above or below the map, using existing token-driven card/alert styling, not a
  new colour system. Two weights: dismissible and non-dismissible</li>
  <li>The ordinary "Request a ride" <code>sd-button</code>, unchanged and always present</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default:</strong> no outstanding fee — no banner, ordinary home screen</li>
  <li><strong>Single-fee notice:</strong> below the recovery threshold — dismissible
  banner, the oldest fee's amount, and the "added to your next ride" line</li>
  <li><strong>Full recovery:</strong> at or above the recovery threshold — non-dismissible
  banner stating the full outstanding amount and that this ride clears it completely.
  Booking stays available</li>
  <li><strong>Loading:</strong> fee status not yet resolved — home renders without a
  banner until it is known; it must never flash one weight and then swap to the other</li>
  <li><strong>Error:</strong> fee status failed to load — home degrades to the ordinary
  no-banner state rather than showing a possibly wrong amount, with a quiet retry</li>
</ul>

<h3>Behaviour and tone</h3>
<p><em>Dismissing the notice hides it for the session only — it does not waive or reduce
the fee. Make sure the dismiss control cannot be read as "I've paid this." Both weights
carry the same calm, factual tone: state the amount, say what it clears, link to
<code>payments.html</code> for the detail, and never punish. The full-recovery banner is
the most sensitive copy in the rider app — she is being asked for a noticeably larger
amount than her fare, for something that happened days ago. It has to read as fair.</em></p>

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
fees and shares, recovered-fee deductions, settlements and withdrawals, adjustments —
each with a plain-language cause. It is also where she starts a withdrawal.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code></li>
  <li>Large balance figure (EGP, 2 decimals, right-aligned, tabular figures) with an
  explicit "available" or "outstanding" label — never just a bare signed number</li>
  <li>Warning band: a persistent banner (reuse the same new banner primitive as the
  rider fee notice) shown once her outstanding balance crosses the configured warning
  fraction of the limit</li>
  <li>Statement list: one row per ledger entry — date, entry type in plain language
  (e.g. "Trip commission", "Cash fee collected from rider", "Settlement recorded"),
  signed amount, and a link to the related trip/settlement/withdrawal where one
  exists</li>
  <li>Last-settlement summary block (date, amount, receipt number)</li>
  <li><code>sd-button</code> entry points to <code>withdraw.html</code> and
  <code>settle.html</code></li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — available (positive) balance:</strong> balance reads as
  money owed to her; withdraw entry point is the primary action</li>
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
anywhere on this screen.</em></p>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Driver] Request a Withdrawal

**ADO:** #3978 — created 2026-09-08

**Screen:** `driver/withdraw.html` (finish)
**Parent:** #1840 — Driver — Trip Completion & Earnings
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is where a driver with an available balance asks to be paid out. The form
honours the policy minimum and maximum, and a cooling-off period between requests. A
driver may cancel her own request while it is still pending, and if it was rejected
she sees why. This screen also has to be honest when withdrawals are switched off
platform-wide, or when she is inside a cooling-off window.</p>

<h3>Components</h3>
<ul>
  <li><code>sd-page</code> shell with <code>sd-app-header</code></li>
  <li>Amount <code>sd-*</code> field/input with inline min/max hints, current
  available balance shown for reference</li>
  <li>Submit <code>sd-button</code></li>
  <li>Pending-request card: requested amount, requested date, status, a cancel
  action</li>
  <li>Rejection banner: reason surfaced in plain language, with a way back into a
  fresh request</li>
  <li>Cooling-off notice: days remaining until she can request again</li>
</ul>

<h3>States</h3>
<ul>
  <li><strong>Default — eligible to request:</strong> form shown, min/max enforced
  inline</li>
  <li><strong>Pending request:</strong> form replaced by the pending-request card
  with a cancel action; no second request possible while one is open</li>
  <li><strong>Rejected:</strong> most recent request's rejection reason shown, then
  the form re-opens for a new request</li>
  <li><strong>Cooling-off blocked:</strong> she has an approved/paid request too
  recently — form is replaced by a countdown-style notice, no way to submit early</li>
  <li><strong>Withdrawals disabled:</strong> the platform master switch is off — the
  whole entry point reads as unavailable, not broken, with a short explanation</li>
  <li><strong>Zero available balance:</strong> nothing to withdraw — informational
  state, not an error</li>
  <li><strong>Loading / Error:</strong> standard fetch states with retry on error</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

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

## [Admin] Driver Balances & Record Settlement

**ADO:** #3982 — created 2026-09-08

**Screen:** `admin-v2/balances.html` (finish)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is where operations staff see every driver's balance in one place, drill into
a driver's full ledger, and record a settlement when she hands cash back or post a
manual adjustment with a reason. Recording a settlement here is what unblocks her
go-online state if it clears her below the outstanding limit — no separate step.</p>

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
  date, signed amount, cause, related trip/settlement/withdrawal link)</li>
  <li><code>ad-form-modal</code> "Record settlement" — channel select (configurable
  list), reference field (required except for office cash, where it defaults to the
  generated receipt number), amount, generated receipt number shown on success</li>
  <li><code>ad-form-modal</code> "Post adjustment" — signed amount and a required
  reason</li>
</ul>

<h3>States</h3>
<ul>
  <li>Standard list states per the portal convention: <code>?state=empty</code>,
  <code>?state=loading</code>, <code>?state=error</code>, <code>?state=long</code></li>
  <li>Default populated list, with blocked/over-limit drivers visually distinguished
  in the status column</li>
  <li>Ledger drawer/detail open, populated and empty (a driver with no ledger
  activity yet)</li>
  <li>Record-settlement modal: default, validation errors (missing reference on a
  channel that requires one), success with receipt number and a confirmation toast</li>
  <li>Post-adjustment modal: default, validation error (missing reason), success</li>
  <li>Zero-balance driver in the list and in the ledger drawer</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Admin] Driver Withdrawal Requests

**ADO:** #3983 — created 2026-09-08

**Screen:** `admin-v2/withdrawals.html` (finish)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is the queue operations staff work to pay drivers out: approve a pending
request, mark an approved one paid (the only step that actually posts a ledger
entry), or reject one with a reason. A request cannot be approved until the driver
has a payout destination on file, and that gap has to be obvious from the row, not
just from a blocked button.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton</li>
  <li><code>ad-filter-bar</code>: status filter (pending / approved / paid /
  rejected), search by driver</li>
  <li><code>ad-data-table</code> columns: driver, requested amount (EGP,
  right-aligned, tabular figures), requested date, payout destination summary or a
  "missing" flag, <code>ad-status-pill</code> for request status</li>
  <li>Detail view: <code>ad-detail-section</code> with the request, the driver's
  payout destination (or its absence), and action buttons</li>
  <li><code>ad-form-modal</code> "Reject request" — required reason</li>
  <li>Confirm-style action for "Mark paid" (the ledger-posting step)</li>
</ul>

<h3>States</h3>
<ul>
  <li>Standard list states: <code>?state=empty</code>, <code>?state=loading</code>,
  <code>?state=error</code>, <code>?state=long</code></li>
  <li>Pending request, with and without a payout destination on file</li>
  <li><strong>Blocked without a payout destination:</strong> approve is disabled with
  an inline explanation and a link to the driver's profile to add one</li>
  <li>Approved, awaiting payment</li>
  <li>Paid — read-only, shows the ledger entry reference</li>
  <li>Rejected — reason shown</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Admin] Rider Outstanding Fees

**ADO:** #3984 — created 2026-09-08

**Screen:** `admin-v2/rider-balances.html` (new)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>The rider-side counterpart to the driver balances screen: every rider currently
carrying an outstanding cancellation fee, her ledger of fee and payment entries, and
the ability for operations staff to waive a fee with a reason or post a manual
adjustment. Most riders never appear here — this is exception handling, not a
routine list.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton</li>
  <li><code>ad-filter-bar</code>: search by name/phone, status filter (outstanding /
  waived / settled)</li>
  <li><code>ad-data-table</code> columns: rider name, phone, outstanding amount
  (EGP, right-aligned, tabular figures), oldest unpaid fee date,
  <code>ad-status-pill</code> for status; a rider over the booking limit is visually
  distinguished</li>
  <li>Ledger view: <code>ad-detail-section</code> plus entries (cancellation fee,
  fee collected, fee waived, adjustment) with cause and related trip link</li>
  <li><code>ad-form-modal</code> "Waive fee" — required reason</li>
  <li><code>ad-form-modal</code> "Post adjustment" — signed amount and required
  reason</li>
</ul>

<h3>States</h3>
<ul>
  <li>Standard list states: <code>?state=empty</code>, <code>?state=loading</code>,
  <code>?state=error</code>, <code>?state=long</code></li>
  <li>Default populated list; empty state here reads as a genuinely good sign (no
  riders currently owe anything) rather than a neutral "nothing found"</li>
  <li>Rider over the booking limit, both in the list and in the ledger drawer</li>
  <li>Waive-fee modal: default, validation error (missing reason), success with
  confirmation toast</li>
  <li>Post-adjustment modal: default, validation error, success</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Admin] Settlement Day Book

**ADO:** #3985 — created 2026-09-08

**Screen:** `admin-v2/settlements.html` (new)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This is the reconciliation artefact Finance checks against the bank: every
settlement recorded, totalled by channel and by the admin who recorded it, filterable
by date, exportable to CSV. Every row here was created from the "Record settlement"
action on the driver balances screen — this page never posts anything itself, it only
reports.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton</li>
  <li><code>ad-filter-bar</code>: date range, channel filter, recording-admin filter</li>
  <li>Totals row: an <code>ad-stat-card</code> per channel plus a grand total for the
  selected range, all EGP right-aligned tabular figures</li>
  <li><code>ad-data-table</code> columns: date/time, driver, channel, amount,
  reference, receipt number (<code>S-nnnnn</code>), recording admin</li>
  <li>CSV export action, scoped to the active filters, not just the visible page</li>
</ul>

<h3>States</h3>
<ul>
  <li>Standard list states: <code>?state=empty</code>, <code>?state=loading</code>,
  <code>?state=error</code>, <code>?state=long</code></li>
  <li>Default — a day with settlements, totals and list populated</li>
  <li>Empty — a date range with no settlements, totals read as zero rather than
  disappearing</li>
  <li>Filtered by date range, by channel, and by recording admin, individually and
  combined</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```

---

## [Admin] Balance, Fee & Withdrawal Policy

**ADO:** #3986 — created 2026-09-08

**Screen:** `admin-v2/pricing-policies.html` (extend)
**Parent:** #2857 — Admin — Pricing, Reporting & Reconciliation
**AcceptanceCriteria:** *(leave empty — design story format)*

```html
<p>This adds the balance, fee and withdrawal policy block to the existing pricing and
policies screen — the single place a super admin changes commission, grace periods,
cancellation fees, the driver outstanding limit and warning band, the rider fee
recovery threshold, and the withdrawal rules, with no code deploy required. Every
change here writes an audit-log entry with who, when, old value and new value, and
values already snapshotted onto a trip at driver acceptance are never affected
retroactively.</p>

<h3>Components</h3>
<ul>
  <li><code>ad-shell</code> page skeleton, added as a new section alongside the
  existing pricing-policy form on this screen</li>
  <li>Form fields, grouped logically (trip economics / cancellation fees / driver
  balance & withdrawals / rider fees): platform commission %, rider grace period,
  driver cancellation fee, driver cancellation grace period, rider no-show wait,
  driver share of a rider fee, driver outstanding limit, driver warning band %,
  rider fee recovery threshold, withdrawals-enabled toggle, minimum withdrawal,
  maximum withdrawal, cooling-off period</li>
  <li>Inline helper text on the two threshold fields explicitly stating what a value of
  0 does: for the driver outstanding limit it disables the go-online gate entirely; for
  the rider fee recovery threshold it keeps recovery at one fee per ride however much she
  owes. Make clear that the rider field is <strong>not</strong> a booking block — it only
  changes how fast a fee is recovered</li>
  <li>Save action with a confirmation toast and an updated "last changed by / when"
  line per field or per section</li>
  <li>Link to the audit log (<code>audit-log.html</code>) for this screen's history</li>
</ul>

<h3>States</h3>
<ul>
  <li>Default — current policy values loaded</li>
  <li>Loading / Error — standard fetch states, with retry on error and no partial
  save on a failed submit</li>
  <li>Validation errors — e.g. minimum withdrawal greater than maximum, negative
  values, out-of-range percentages</li>
  <li>Saved confirmation — toast plus the refreshed "last changed" metadata</li>
  <li>Zero-value / gate-disabled state on the outstanding-limit fields, with the
  helper text visibly explaining what that means</li>
</ul>

<h3>Preview</h3>
<p>Mockup: &lt;to be added&gt;</p>
```
