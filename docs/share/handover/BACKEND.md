# Handover — Backend / API team

**Subject:** SheDrive financial core, Phase 1 (cash) built to be online-payment ready
**Date:** 2026-09-08

---

## Read these, in this order

1. **`docs/superpowers/specs/2026-09-08-financial-core-design.md`** — the design spec.
   This is the contract. Sections 1, 2, 3, 5 and 6 are yours.
2. **`docs/backlog/api-stories.md`** — your seven stories: `#3991`, `#3996`, `#3997`,
   `#4000` and `#4004`, plus the two reopened ones (#1764, #1781).
3. **`docs/backlog/financial-core-ado-parents.md`** — which Feature each story hangs off,
   all verified.

---

## The one thing to get right

**Custody decides the ledger entry. The payment method only decides custody.**

```
trip completes:   fare F  =  commission C  +  net earnings N

custody = 'driver'    →  post  −C   trip_commission     (she holds F; she owes us C)
custody = 'platform'  →  post  +N   trip_earnings       (we hold F; we owe her N)
```

Phase 1 always writes `custody = 'driver'`. Ship the branch anyway.

**Never branch on `paymentMethod` anywhere in the financial code.** Branch on `custody`,
in exactly one place — the function that posts trip entries. When a payment provider is
added later, that one field starts taking a second value and nothing else changes: not
the ledger, not the balances, not the go-online gate, not settlement, not payouts, not
the reports.

A driver with a mix of cash and online trips ends up with **one** balance that nets the
two off. There is no second data model and no reconciliation between them.

---

## What you are building

### 1. The ledger (`#3991`) — build this first, everything depends on it

Two parties, same rules. Entry types are in spec §2.1 (driver) and §2.2 (rider).

**Four invariants. Please treat these as non-negotiable, because every screen, report and
audit trail we build on top assumes them:**

| # | Invariant | Why it matters |
|---|---|---|
| 1 | The balance is the **sum of the entries**. Nothing writes a balance. | The driver's app, the admin ledger view and the revenue report cannot disagree — they read the same sum. |
| 2 | Entries are **immutable**. No update, no delete, and — as of 13 Sep — no adjustment entry either. | It is the audit trail. An edited ledger is not evidence. **See the warning below: this currently leaves no way to correct a mistake.** |
| 3 | Posting is **idempotent**, keyed `{event_type}:{trip_id\|request_id}:{party_id}`. | A retried trip completion must not charge twice. This is the single most likely production bug. |
| 4 | Every entry **names its cause** — trip id, settlement reference, request id, or admin id + reason. | Support has to be able to answer "why do I owe this?" |

Reads expose **both** readings so no client ever interprets a sign:
`outstanding` (what she owes; 0 when the balance is positive) and
`available` (what SheDrive owes her; 0 when the balance is negative).

### 2. Trip completion posts by custody (`#3997`)
The keystone. Scenarios cover both custody values and a mixed-mode driver.

### 3. Cancellation fees, both directions (`#1764` — reopened)
Rider late cancellation → fee to the **rider ledger**, her configured share to the
**driver ledger**. Driver late cancellation → fee debited from her ledger, waived only on
a qualifying no-show. Values are **snapshotted at driver acceptance** — a policy change
mid-trip never alters a trip already running.

> `#1764` previously declared "collecting the fee from the rider" out of scope. It is now
> in scope, via `#4000`. That was the cash leak, and closing it is the point of this
> change set.

### 4. Fee recovery on the next ride (`#4000`)
Cash riders have no card, so an unpaid fee rides along on the next trip as a surcharge
the driver collects. Spec §3 has the full worked example with both custody values —
**implement against those numbers; they balance exactly.**

- She clears her **entire** outstanding balance on her next completed trip, always — no
  threshold, no drip, and no oldest-fee-first ordering. She always leaves that ride owing
  nothing.
- The surcharge posts `fee_collected` on the rider and `rider_fee_recovery` on the driver
  (she collected our money, so she owes it to us).
- **Commission is never taken from a recovered fee.** We already hold our share.

> **There is deliberately no rider booking block.** An earlier draft had one; it
> deadlocks, because taking a ride is the only way a cash rider can clear a fee. Abuse is
> handled by suspending the rider (#1740). Please do not reintroduce a fee-based block.

### 5. The go-online gate (`#3996`)
Refuse to put a driver online when `outstanding >= limit`. Return the amount owed and the
limit so the app can explain it. **Limit of 0 disables the gate.** A settlement that drops
her below the limit must release her **immediately** — no batch, no approval step.

### 6. Payouts (`#4001`)
**A driver never requests a payout.** Finance transfers the money on its own cycle and
then records the transfer, which posts a `payout` debit. There is no request, no approval
queue, no reservation against her balance, no minimum or maximum, and no cooling-off
period — there is nothing to approve, because the money moved before anything was
recorded. Recording is idempotent on the payout reference, and an amount above her
available balance is refused — nothing else gates it.
**The system holds no payout destination.** No bank or wallet detail is collected from a
driver, held by the platform, or checked before a payout is recorded — getting the money
to her is a manual, off-platform process outside the platform. `#3993` [API] Finance
records a payout was folded into `#4001` [Admin] on 2026-09-17: the house rule is that an
admin screen's backend lives inside its own `[Admin]` story, so `#4001` now owns both the
screen and the ledger posting.

### 7. Reads (`#1781` reopened, `#4004`)
Driver balance + statement; rider outstanding fees + statement. These calculate nothing —
they read the ledger.

---

## Design for a reversal. Do not build one yet.

**Nothing in Phase 1 can correct a mis-recorded entry.** The ledger is append-only, the
post-adjustment action was cut, and with the waive cut too this is now true of **both**
ledgers. A settlement recorded against the wrong driver, an amount keyed as 300 instead of
30, or a cancellation fee charged to the wrong rider is permanent, and she sees it in her
statement. The product owner has accepted that and will brief the team to account for it
in the design.

**What that asks of you when you build `#3991`:** leave room for a **reverse-this-entry**
action later — one button on an existing entry, a required reason, posting the exact
opposite amount and linking the two rows. In practice that means giving an entry somewhere
to point at another entry, and making sure the idempotency key cannot block a deliberate
equal-and-opposite posting. Adding the action later is cheap if the shape allows it, and a
migration on live financial data if it does not.

---

## Where the availability write lives — answered

`#3996` does **not** extend a missing story. The availability endpoint and its approval
gate are owned by **`#1644` — [API] Driver onboarding decision — go-online and offline**,
which is `Closed` (Sprint 1, 1 point). Its description is explicit: *"the availability
endpoint to reject any attempt by a non-approved driver to set her status to online"*, and
its test suite covers pending, rejected, suspended, no-application and approved drivers,
plus availability being left unchanged after a failed attempt.

`#1645` *[API] Driver sets availability status* was `Removed` because it duplicated
`#1644`, not because the capability was dropped. So `#3996` adds **one more condition** —
the outstanding-balance check — to a gate that already exists and already ships. Estimate
it as an extension, not a new endpoint.

---

## Explicitly out of scope for Phase 1

Payment-provider integration · surge and dynamic pricing · promo codes and discounts ·
referral credits · tips · driver bonuses · VAT and tax reporting · PDF receipts and
invoices · accounting exports beyond CSV · rider or driver dispute of a fee · automated
dunning.

**In scope but easy to skip:** the `custody` field and its branch. It ships with one value
in use. That is the whole point.

---

## A working reference implementation exists

`shedrive-web/admin-v2/scripts/seed.js` and `mock-api.js` contain a complete mock of this
ledger — entry types, balance derivation, settlement posting and payout recording. It is not production code, but the **shapes and the invariants are the ones
we want**, and the admin screens are already built against them. Read it before designing
your tables; it will save an argument later.
