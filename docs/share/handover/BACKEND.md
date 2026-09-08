# Handover — Backend / API team

**Subject:** SheDrive financial core, Phase 1 (cash) built to be online-payment ready
**Date:** 2026-09-08

---

## Read these, in this order

1. **`docs/superpowers/specs/2026-09-08-financial-core-design.md`** — the design spec.
   This is the contract. Sections 1, 2, 3, 5 and 6 are yours.
2. **`docs/backlog/api-stories.md`** — your ten stories, `#3991` … `#4004` plus the two
   reopened ones (#1764, #1781).
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
| 2 | Entries are **immutable**. Corrections are new `adjustment` entries. No update, no delete. | It is the audit trail. An edited ledger is not evidence. |
| 3 | Posting is **idempotent**, keyed `{event_type}:{trip_id\|request_id}:{party_id}`. | A retried trip completion must not charge twice. This is the single most likely production bug. |
| 4 | Every entry **names its cause** — trip id, settlement reference, request id, or admin id + reason. | Support has to be able to answer "why do I owe this?" |

Reads expose **both** readings so no client ever interprets a sign:
`outstanding` (what she owes; 0 when the balance is positive) and
`available` (what she can withdraw; 0 when the balance is negative).

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

### 4. Fee recovery on the next ride (`#4000`, `#4002`)
Cash riders have no card, so an unpaid fee rides along on the next trip as a surcharge
the driver collects. Spec §3 has the full worked example with both custody values —
**implement against those numbers; they balance exactly.**

- Below the recovery threshold: oldest fee first, one per ride.
- At or above it: the whole outstanding balance, in one payment (`#4002`).
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

### 6. Payouts (`#3993`, `#4003`)
`pending → approved → paid`, or `pending → rejected`. Requesting **reserves** against the
available balance and posts nothing. Only *mark paid* posts a `withdrawal` entry.
Rejecting or cancelling releases the reservation and posts nothing.
**A payout cannot be approved without a payout destination on file** (`#4003`).

### 7. Reads (`#1781` reopened, `#4004`)
Driver balance + statement; rider outstanding fees + statement. These calculate nothing —
they read the ledger.

---

## Open issue you need to resolve with us

**#1645 — *[API] Driver sets availability status* — is `Removed` in ADO.**
`#3996` extends the go-online check that story owned, and #3058's completion flow also
depends on the availability write. There is currently no story owning that transition.
Please confirm where availability is actually written before starting `#3996`.

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
ledger — entry types, balance derivation, settlement posting, withdrawal state machine and
the day book. It is not production code, but the **shapes and the invariants are the ones
we want**, and the admin screens are already built against them. Read it before designing
your tables; it will save an argument later.
