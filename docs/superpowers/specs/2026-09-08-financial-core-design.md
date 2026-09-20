# SheDrive Financial Core — design spec

Authored 2026-09-08. This is the **single source of truth** for the financial build:
the economic model, the ledger, the policy surface, the screen inventory and the
story inventory. Every agent working on this change set builds from this file.

Supersedes the placeholder scheme in `docs/backlog/driver-finance-ado-changeset.md`
(that file's `#TBD-A…G` map is folded into §9 here).

---

## 1. The one idea

**Custody decides the ledger entry. The payment method only decides custody.**

Every completed trip produces the same three numbers, whatever the payment method:

```
fare F  =  commission C  +  net earnings N
```

What differs is **who physically received F**:

| Custody | Phase | Ledger entry on the driver | Meaning |
|---|---|---|---|
| `driver` | Phase 1 (cash) | `trip_commission` **−C** | She holds F, so she owes the platform its commission |
| `platform` | Later (card/wallet) | `trip_earnings` **+N** | The platform holds F, so it owes her the net |

Both land on the same economic position: the driver is entitled to **N**. A driver
who takes some cash trips and some online trips has **one** balance that nets the two
off automatically — a cash debt is cancelled by online earnings with no special case
anywhere.

> **This is the property the business asked for.** Adding a payment provider later
> means writing `custody = 'platform'` on the trip. Nothing downstream changes: not the
> ledger, not the balance, not the go-online gate, not settlement, not payouts, not
> the reports. No screen is rebuilt and no story is rewritten.

**Build rule for every story and every screen in this change set:** never branch on
`paymentMethod`. Branch on `custody` — and only ever in the one place that posts trip
entries to the ledger.

---

## 2. Two ledgers, same rules

Money is owed in both directions, so both parties get an account.

### 2.1 Driver ledger

One signed balance per driver, in EGP.

- **negative** → she owes SheDrive (*outstanding*), cleared only by a settlement
- **positive** → SheDrive owes her (*available*), cleared by a payout Finance sends her

| Entry type | Sign | Posted when |
|---|---|---|
| `trip_commission` | − | A trip completes with `custody = driver` |
| `trip_earnings` | + | A trip completes with `custody = platform` |
| `driver_cancellation_fee` | − | She cancels late without a qualifying no-show waiver |
| `rider_cancellation_fee_credit` | + | A rider cancels late; the **whole** fee is credited to the driver |
| `rider_fee_recovery` | − | She collected a rider's outstanding fee in cash on the platform's behalf |
| `settlement` | + | An admin records that she handed cash back |
| `payout` | − | Finance records a transfer it has already sent her |

### 2.2 Rider ledger

One signed balance per rider, in EGP. Zero for almost every rider, almost always.

| Entry type | Sign | Posted when |
|---|---|---|
| `cancellation_fee` | − | She cancels after the grace period |
| `fee_collected` | + | The fee is recovered — as a cash surcharge, or later a card charge |

### 2.3 Invariants — enforce these everywhere

1. **The balance is the sum of the entries.** Nothing ever writes a balance directly.
2. **Entries are immutable.** Nothing edits an entry and nothing deletes one — ever.
   Phase 1 ships with **no correction mechanism at all**: see the open item in §10.
3. **Posting is idempotent.** A retried trip completion, cancellation or payout posts
   at most one entry per party. Every entry carries an idempotency key
   (`{event_type}:{trip_id|request_id}:{party_id}`).
4. **Every entry names its cause** — a trip id, a settlement receipt, a payout reference,
   or an admin user id plus a reason.
5. **Amounts are EGP to 2 decimals**, VAT-inclusive, never rounded twice.

---

## 3. How a rider fee is actually collected (the leak, closed)

Phase 1 riders have no card. The fee is recovered as a **surcharge on her next trip**,
collected by the driver in cash and passed through the driver ledger.

**The whole fee goes to the driver.** A rider's cancellation fee is compensation for the
driver's wasted time and fuel — the platform takes none of it and there is no split to
configure. (A *driver's* own late-cancellation fee is different: that one is charged to
her and is the platform's.)

Worked example — fee 20.00, next trip fare 100.00, commission 20.00:

| Step | Rider ledger | Driver ledger | Driver holds |
|---|---|---|---|
| Rider cancels late | −20.00 `cancellation_fee` | +20.00 `rider_cancellation_fee_credit` | — |
| Next trip completes, custody `driver` | +20.00 `fee_collected` | −20.00 `trip_commission`<br>−20.00 `rider_fee_recovery` | 120.00 cash |
| **Position** | **0.00** | **−20.00** | She is entitled to 100.00 (80 net + the 20 fee) and holds 120.00 → she owes 20.00 ✓ |

Same fee under `custody = platform`:

| Step | Rider ledger | Driver ledger | Driver holds |
|---|---|---|---|
| Rider cancels late | −20.00 `cancellation_fee` | +20.00 `rider_cancellation_fee_credit` | — |
| Next trip completes, custody `platform` | +20.00 `fee_collected` | +80.00 `trip_earnings` | 0.00 |
| **Position** | **0.00** | **+100.00** | Entitled to 100.00, platform owes her 100.00 ✓ |

**The driver is entitled to 100.00 on both paths, and what she owes is exactly the
commission.** The rider paid 120.00; the driver keeps 100.00, the platform keeps its
20.00 commission and nothing else. No screen, story or report differs between the paths.

Rules:
- The surcharge is shown to the rider **before** she confirms the ride, and again on
  the fare summary as its own line — never folded silently into the fare.
- Commission is never taken from a recovered fee — the whole fee is the driver's.
- **The surcharge is her entire outstanding balance, every time.** Whatever she owes is
  added to her next completed trip in one payment — there is no drip, no oldest-fee-first
  ordering and no threshold. She always leaves that ride owing nothing.

> **There is deliberately NO automatic booking block on the rider.** An earlier draft of
> this spec refused a booking once she owed enough, which deadlocks: the only way to clear
> a fee is to take a ride, so a blocked rider could never clear it and the debt would be
> permanent. Recovering on the *next ride* instead is self-clearing — she books, she pays
> all of it, she is square. Persistent abuse is handled by the existing rider-suspension
> flow (#1740), triggered by an admin from `rider-balances.html` — a human decision, not
> an automatic trap.

---

## 4. Policy surface — one admin screen, no code deploys

All of this lives on `pricing-policies.html` (extends #1759 and adds §9's `#3994`).

| Setting | Default | Effect |
|---|---|---|
| Platform commission % | 20% | Split at trip completion |
| Rider grace period | 2 min | Free cancellation window from driver acceptance |
| Driver cancellation fee | 20.00 EGP | Charged to a driver who cancels late |
| Driver cancellation grace period | 2 min | From her acceptance |
| Rider no-show wait | 5 min | Waives the driver fee if she waited this long |
| **Driver outstanding limit** | **500.00 EGP** | Blocks go-online at this amount. **0 disables the gate.** |
| Driver warning band | 80% | Warns her in-app from this fraction of the limit |

Every change is written to the audit log (#1816) with who, when, old value, new value.
Values in force are **snapshotted at driver acceptance** — a mid-trip policy change never
alters a trip already under way.

---

## 5. Settlement — how the cash comes back

Recording a settlement **posts a ledger entry**; it never edits a balance.

- **Channels** (configurable list, not hard-coded): `office_cash`, `bank_deposit`,
  `mobile_wallet`, `field_agent`.
- **Reference is required** for every channel except `office_cash`, where it is optional
  and defaults to the generated receipt number.
- Every settlement generates a **receipt number** (`S-nnnnn`) shown to the admin and
  visible in the driver's own statement.
- A settlement that clears a driver below the outstanding limit **unblocks her go-online
  immediately**, with no further admin action.
- Settlement entries are **exportable as CSV** from `balances.html` so Finance can check
  them line by line against the bank statement. There is no separate day-book screen — it
  was cut as a report dressed as a screen, and can come back as a real reconciliation
  (banked amount in, variance out) once the cash-collection model is decided.

**Payouts are the mirror, and they work the same way — after the fact.** When a driver's
balance is positive, SheDrive owes her; Finance transfers the money on its own cycle and
then **records the transfer**, which posts a `payout` debit against her balance. Recording
a payout happens in the same place as recording a settlement (`balances.html`) because it
is the same act in the opposite direction: money moved, now write it down.

> **A driver never requests a payout.** There is no request, no approval queue, no
> reservation against her balance, no minimum or maximum, and no cooling-off period —
> nothing to approve, because the money has already moved before anything is recorded.
> Her `available` figure is what SheDrive owes her, not a button. She sees the payout in
> her statement, with its reference and date, the same way she sees a settlement.

**The system holds no payout destination.** Where the money goes and how it is sent is a
manual process outside the platform — paper, for now. Nothing is captured from the driver,
nothing is verified, and recording a payout is not gated on any of it. The admin records
the amount, the date and a reference for what Finance already did; that record is the
entire scope.

---

## 6. Data the system does not hold today and must

| Field | Lives on | Why |
|---|---|---|
| `custody` (`driver` \| `platform`) | Trip | Drives the ledger entry; always `driver` in Phase 1 |
| `riderBalance` / rider ledger | Rider | Closes the cancellation-fee leak |
| `settlementReceiptNo` | Ledger entry | Ties a ledger line to a physical receipt |
| `idempotencyKey` | Ledger entry | Stops a retry double-charging |

---

## 7. Screen inventory

Follow `CLAUDE.md` exactly: three files per screen, every value from a token, every
rider/driver string through `data-i18n*` with an Arabic fallback in the HTML.
Admin-v2 is bilingual via `admin-i18n.js` `t()`; admin v1 is **not** in scope for this
change set.

### 7.1 Rider (`rider/`) — bilingual, mobile-first

| Screen | State | What it must do |
|---|---|---|
| `payments.html` | **rewrite** — it is a coming-soon stub | Cash as the active method; an "Online payment — coming soon" row that is visibly not selectable; **outstanding fees** section with each fee, its trip and date, and the line "this will be added to your next ride"; link to fee detail |
| `home.html` | **extend** | A dismissible banner when anything is outstanding, stating the **full** amount owed and that all of it will be added to this ride. One state, no threshold. She is never blocked from booking |
| `trip-complete.html` | **extend** | The fare summary gains an explicit **outstanding fee** line above the total when one was recovered; the total is what she actually pays |
| `trip-detail.html` | **extend** | Historic trips show the same recovered-fee line |

### 7.2 Driver (`driver/`) — bilingual, mobile-first

| Screen | State | What it must do |
|---|---|---|
| `balance.html` | **finish** | Signed balance, outstanding/available reading, warning band, full statement with credits and debits, entry causes, last settlement, and any payout Finance has sent her. **No withdrawal request — there is nothing for her to initiate** |
| `settle.html` | **new** | What she owes, the channels she may use, the office address/hours, and her settlement history with receipt numbers |
| `home.html` | **extend** | The **blocked** state when over the limit: the amount owed, the limit, and a direct link to `settle.html`; the **warning** band below it |
| `cash-collection.html` | **extend** | When the rider carries a recovered fee, show fare + fee = total to collect, itemised |

### 7.3 Admin (`admin-v2/`) — desktop-first, `ad-*` components, bilingual

| Screen | State | What it must do |
|---|---|---|
| `balances.html` | **finish** | Driver balances list, ledger drawer, record a settlement (cash in), record a payout (money out, after Finance has sent it), CSV export of settlement entries |
| `rider-balances.html` | **new** | Riders with outstanding fees and the rider ledger drawer — **read-only**, with no waive and no adjustment. The only action is the link into the existing rider-suspension flow (#1740) for persistent abuse, which is the only block on a rider and a human decision |
| `pricing-policies.html` | **extend** | The driver-balance and rider-fee policy blocks from §4 |
| `reconciliation.html` | **finish** | Per-driver earnings & settlement; drop the disabled stub |
| `reports.html` | **extend** | Revenue summary gains **collected vs. owed**: commission earned, commission settled, outstanding |
| `driver-profile.html` | **extend** | Balance summary with a link to `balances.html` |

Every list screen honours `?state=empty|loading|error|long`. Data comes from
`admin-v2/scripts/mock-api.js` over `seed.js` — extend, never fork.

---

## 8. i18n

New namespaces. Add every key to **both** `shared/i18n/ar.json` and `en.json` in the
same edit; Arabic fallback text goes in the HTML.

- `payments.*` — rider payment methods and outstanding fees
- `fees.*` — rider-facing fee copy shared across home, trip-complete, trip-detail
- `driver.balance.*`, `driver.settle.*`, `driver.txn.*`
- `driver.blocked.*` — the go-online block and warning band

Admin-v2 keys go in `admin-v2/i18n/` (`lists.js`, `details.js`, `config.js`, `core.js`).

---

## 9. Story inventory

This set was authored against `FIN-nn` placeholders. **They have all been created in ADO
and the ids below are real** — see `docs/backlog/financial-core-ado-parents.md` for the
full map and the verified parent of each.
Every story must be parented to a Feature — never create one without a parent.

### 9.1 API — `docs/backlog/api-stories.md`

| Ref | Title | Parent |
|---|---|---|
| `#3996` | [API] Driver go-online is blocked while her outstanding balance is over the limit | #1607 |
| `#3997` | [API] Trip completion posts to the ledger according to fare custody | #1604 |
| `#4000` | [API] Rider outstanding fee is recovered on her next trip | #1602 |
| **#1764** | [API] Cancellation fees are charged after the grace period (rider and driver) | #1602 — **reopen** |
| **#1781** | [API] Driver retrieves her balance and statement | #1776 — **reopen** |
| `#4004` | [API] Rider retrieves her outstanding balance | #1775 |

### 9.2 Admin — `docs/backlog/admin-stories.md`

| Ref | Title | Parent |
|---|---|---|
| `#3994` | [Admin] Super admin configures balance and fee policy | #1755 |
| `#4001` | [Admin] Super admin records a payout sent to a driver — screen **and** ledger posting | #1803 |
| `#4005` | [Admin] Super admin reviews rider outstanding fees — owns the **rider ledger** | #1803 |
| **#1813** | [Admin] Super admin reconciles driver balances and records settlements — owns the **driver ledger** and the posting rules | #1803 — **reopen** |
| **#1832 / #1833** | Dependency repoint only — **confirm story points before touching** | #1803 |

### 9.3 Mobile driver — `docs/backlog/mobile-driver-stories.md`

| Ref | Title | Parent |
|---|---|---|
| `#3988` | [Mobile] Driver is blocked from going online while her balance is over the limit | #1540 |
| `#3989` | [Mobile] Driver settles what she owes and sees her settlement history | #1769 |
| `#3990` | [Mobile] Driver collects a recovered rider fee alongside the fare | #1543 |
| **#1788** | [Mobile] Driver views her balance and statement — **rescope onto the ledger** | #1769 |

### 9.4 Mobile rider — `docs/backlog/mobile-rider-stories.md`

| Ref | Title | Parent |
|---|---|---|
| `#3992` | [Mobile] Rider views her payment method | #1768 |
| `#3995` | [Mobile] Rider sees an outstanding fee before she requests a ride | #1533 |
| `#3998` | [Mobile] Rider is told when her full outstanding balance will be added to her next ride | #1533 |
| `#3999` | [Mobile] Rider sees the recovered fee on her fare summary | #1536 |

### 9.5 Design — `SheDrive\Design Team` area

One story per screen in §7, in the **design story format**: everything (intro,
components, light states, mockup link) in `System.Description`; `AcceptanceCriteria`
left empty. Parents come from the Design Team Epic→Feature map.

### 9.6 Field format — non-negotiable

- **User stories:** `System.Description` holds **only** `As a … I want … so that …`.
  Background, Field Validation, Acceptance Criteria, Out of Scope, Dependencies and
  List/Grid Specification all go in `Microsoft.VSTS.Common.AcceptanceCriteria`.
- **Design stories:** everything in `System.Description`; `AcceptanceCriteria` empty.
- Every `[Admin]` story carries the standard 10-column bilingual Field Validation table
  including an "Accepted values" column.
- Every list screen carries a `### List / Grid Specification` section at 20 rows/page.

---

## 10. Out of scope — state it in every story

Surge and dynamic pricing · promo codes and discounts · referral credits · tips · driver
bonuses and incentives · payment-provider integration · VAT and tax reporting · receipts
and invoices as PDFs · accounting exports beyond CSV · rider or driver dispute of a fee
(Phase 2) · automated dunning.

**Cut deliberately, on 2026-09-13, to keep Phase 1 simple:** the settlement day book
(`settlements.html`), driver-initiated payout requests, and the **post-adjustment** action
on both balance screens.

**Changed on 2026-09-17:** a rider's cancellation fee now goes **entirely to the driver**.
There is no split with the platform and no share percentage to configure — the setting is
removed from the policy screen and the driver-ledger entry type is renamed
`rider_cancellation_fee_share` → `rider_cancellation_fee_credit`, because nothing is
shared any more. A *driver's* own late-cancellation fee is unaffected: it is still charged
to her and is still the platform's.

**Folded on 2026-09-17:** `#3991` [API] Party balance ledger, into `#1813` (driver ledger)
and `#4005` (rider ledger). The ledger is still exactly the design in §2 — only the story
packaging changed. `#3991` failed INVEST: **none of its sixteen scenarios could be tested
without another story**, and nine of them were duplicates of acceptance criteria already
written in `#3997`, `#1764`, `#4000`, `#1813` and `#4001`. Each ledger now ships with the
screen that proves it, and the mechanics — entry shape, balance-is-the-sum, immutability,
idempotency, concurrency, two-decimal precision — live with the party whose ledger they
govern. Every other story references those two rather than restating them.

> The two `custody = platform` scenarios are **unit-test scope, not acceptance criteria**.
> No Phase 1 flow produces that value, so no tester can reach them through the product;
> writing them as acceptance criteria only guarantees a blocked test.

**Folded on 2026-09-17:** `#3993` [API] Finance records a payout, into `#4001`. The two
described the same act from opposite sides, and the house rule is that an admin screen's
backend lives inside its own `[Admin]` story — `[API]` stories exist for mobile screens.
`#4001` now owns the screen *and* the ledger posting: idempotent on the payout reference,
refused above her available balance.

**Also cut on 2026-09-17:** the admin **waive** action on rider fees, and the `fee_waived`
ledger entry with it. A rider's fee is cleared one way only — she pays it, on her next
completed trip. Nobody writes it off. `rider-balances.html` is a read-only review screen
whose single action is escalating to suspension (#1740).

**Also cut on 2026-09-17:** the **rider fee recovery threshold** and the escalation it
controlled (`#4002`). A rider now clears her whole outstanding balance on her next
completed trip, always — one rule with no exception and nothing to configure. Handling a
rider who accumulates several cancellations before her next ride is deliberately deferred.

**Cut on 2026-09-17:** the stored **payout destination** (`#4003`). No bank or wallet
detail is collected from a driver, held by the platform, or checked before a payout is
recorded. Getting the money to her is a manual, off-platform process; the only thing the
system does is write down that it happened.

> ### Decided 2026-09-17 — design for a reversal, do not build one yet
>
> The ledger is append-only and adjustments have been removed, so nothing in Phase 1 can
> fix a settlement recorded for the wrong driver, an amount keyed as 300 instead of 30, or
> a payout written down twice. The entry is permanent and the driver sees it in her
> statement. **Since the waive was cut on 17 September this is now true of both ledgers:**
> a cancellation fee charged to a rider in error can no longer be written off either. She
> pays it on her next trip, or an admin suspends her; there is no third option.
>
> **The product owner has accepted this for now** and will brief the team to account for
> it in the design. Nothing is built in Phase 1.
>
> What accounting for it means when the ledger is built (#1813): leave room for a
> **reverse-this-entry action** later — one button on an existing entry, a required reason,
> posting the exact opposite amount and linking the two rows. Concretely, give an entry
> somewhere to point at another entry, and make sure the idempotency key cannot block a
> deliberate equal-and-opposite posting. Adding the action later is cheap if the shape
> allows it, and a migration on live financial data if it does not.

**In scope but easy to miss:** the `custody` field and its ledger branch. It ships in
Phase 1 with only one value in use. That is the whole point — it is what makes online
payment a configuration change rather than a rebuild.
