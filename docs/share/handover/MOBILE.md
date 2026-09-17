# Handover — Mobile team (Rider & Driver apps)

**Subject:** SheDrive financial core — 7 mobile stories
**Date:** 2026-09-08

---

## Read these, in this order

1. **`docs/backlog/mobile-driver-stories.md`** — `#3988`, `#3989`, `#3990` plus the
   rescoped `#1788`.
2. **`docs/backlog/mobile-rider-stories.md`** — `#3992`, `#3995`, `#3999`.
3. **`docs/superpowers/specs/2026-09-08-financial-core-design.md`** §3 and §7 — the
   behaviour, with worked numbers.
4. The **working HTML prototype** in `shedrive-web/` — every screen below is built and
   clickable with demo data. It is the reference for layout, states and copy.

---

## What the apps have to understand

The driver carries a **signed balance**. Negative means she owes SheDrive; positive means
SheDrive owes her. **The app never interprets the sign** — the API returns `outstanding`
and `available` separately, and you render whichever is non-zero. Do not compute either
one client-side.

The rider carries an **outstanding fee balance**, normally zero, that gets recovered as a
surcharge on her next ride.

**Neither app should ever calculate money.** Fares, commissions, fees, balances, limits and
recovery amounts all arrive from the API. The app's job is to display them and to explain
them.

---

## Driver app — 4 stories

| Story | Screen | Prototype |
|---|---|---|
| `#1788` **(rescoped)** | Balance & statement | `driver/balance.html` |
| `#3989` | Settle what she owes + history | `driver/settle.html` |
| `#3988` | Go-online blocked + warning band | `driver/home.html?blocked` / `?warn` |
| `#3990` | Cash collection with a recovered fee | `driver/cash-collection.html?riderfee=20` |

**`#1788` is a rescope, not a new build.** It was a read-only "cash owed" view; it is now
the full ledger statement — signed balance, credits and debits, each entry's cause, the
warning band and any payout Finance has sent her. It carries **no story points in ADO**, so it
needs estimating from scratch against the new scope — do not carry over any earlier guess.

**`#3988` is the one that stops her earning.** Always show the amount owed, the limit, and
a direct link to *Settle*. When a settlement clears her, she must be released
**immediately** — no app restart, no re-login. The warning band starts at a configured
fraction of the limit (default 80%), not a hardcoded number. A limit of 0 means the gate
is off entirely and neither state ever appears.

> **There is no driver-initiated payout request.** An earlier story (`#3987`) had her
> request a withdrawal; it was removed 2026-09-13. Finance transfers the money on its own
> cycle and an admin records the transfer afterward (`#4001`) — she never requests
> anything, there is nothing to reserve and nothing for the app to build here.

**`#3990`** — she collects fare + recovered fee, **itemised**, with a short reason on the
fee line. She must never have to explain an unexplained number to a passenger. Her own
commission and net earnings are calculated on the fare only, never on the recovered fee.

---

## Rider app — 3 stories

| Story | Screen | Prototype |
|---|---|---|
| `#3992` | Payment method + outstanding fees | `rider/payments.html` |
| `#3995` | Fee notice before requesting | `rider/home.html?fees=1` |
| `#3999` | Recovered fee on the fare summary | `rider/trip-complete.html?fee=20` |

**Cash is the only payment method in Phase 1.** Show "Online payment" as present but
plainly unavailable — `aria-disabled`, not merely greyed. Do not build a selection flow
for it.

**The fee must never be folded silently into the fare.** It is its own line, before she
confirms (`#3995`) and again on the summary (`#3999`). The total is what she actually
pays.

**`#3995` is the only fee notice — one dismissible banner, always the full amount.** There
is no threshold and no separate full-recovery state (the earlier `#3998` was folded into
`#3995` on 2026-09-17). Whatever she owes, the banner states the full amount and that all
of it will be added to this ride, and she can dismiss it. Tone: factual and fair, never
punitive.

> **There is no rider booking block.** An earlier version of the design blocked her once
> she owed enough; it was removed because it deadlocks — a cash rider can only clear a fee
> by taking a ride. Do not add one. Abuse is handled by an admin suspending the rider
> (#1740).

---

## Cross-cutting requirements

- **Every user-visible string** goes through `data-i18n` / `data-i18n-placeholder` /
  `data-i18n-aria-label` / `data-i18n-value` with **Arabic fallback text inline**. Never a
  bare `aria-label`. Never Arabic and English mixed in one text node.
- Namespaces: `payments.*`, `fees.*`, `driver.balance.*`, `driver.settle.*`,
  `driver.txn.*`, `driver.blocked.*`. Keys are already drafted in
  `shared/i18n/ar.json` and `en.json` — reuse them so the copy matches the prototype.
- **RTL is the default.** Arabic first, English second.
- Amounts: EGP, 2 decimals, tabular figures, explicit sign on ledger entries. Credits and
  debits distinguishable **without colour alone**.
- Loading states must never flash a wrong state and correct themselves. If the balance or
  fee status is unknown, render neutral and resolve quietly. **Never fail closed** — a
  network error must not present as a block.

---

## Sequencing

Nothing on this list can be finished before the backend ships `#3991` (the ledger),
`#3997` (custody posting) and `#1781` / `#4004` (the balance reads). The screens can be
built against the prototype's shapes in the meantime — they are the shapes the API stories
specify.

`#3988` additionally needs `#3996` (the go-online gate) and `#3990` needs `#4000`
(fee recovery).
