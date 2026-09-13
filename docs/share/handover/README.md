# SheDrive financial core — handover index

**Built 2026-09-08.** Phase 1 is cash-only, but the whole thing is built so that adding
online payment later is a configuration change, not a rebuild.

---

## Start here

| If you are… | Read |
|---|---|
| **The product owner** | The two visual explainers (below), then this page |
| **A designer** | [`DESIGNER.md`](DESIGNER.md) — 11 screens, states, tone, prototype URLs |
| **A backend engineer** | [`BACKEND.md`](BACKEND.md) — the ledger, the invariants, 10 stories |
| **A mobile engineer** | [`MOBILE.md`](MOBILE.md) — 8 stories, both apps, sequencing |
| **Anyone who needs the truth** | [`../../superpowers/specs/2026-09-08-financial-core-design.md`](../../superpowers/specs/2026-09-08-financial-core-design.md) — the spec every team builds from |

**Visual explainers** (published, shareable):
- [**SheDrive Finance Story Map**](https://claude.ai/code/artifact/add3ef30-5b1e-465a-9391-ef646507b223)
  — all 35 work items: scope, team, origin and live ADO status, grouped by what each one
  makes possible, plus the delivery waves. Source: [`financial-story-map.html`](financial-story-map.html)
- [**SheDrive Money Rulebook**](https://claude.ai/code/artifact/5ff1415a-761d-4951-b349-09773fd8203f)
  — every rule in the order money moves, each one tagged with the story number that owns
  it, plus a table of all 35 stories. Source: [`financial-logic-map.html`](financial-logic-map.html)
- [*SheDrive Ledger Logic*](https://claude.ai/code/artifact/271c0275-b74f-4c82-8774-c638bcf7471c)
  — the design in five diagrams, built to present from
- [*SheDrive Money Chain*](https://claude.ai/code/artifact/47f2f70d-be44-4d25-a6d2-063d39aebf71)
  — the state-of-play review that led to this work

---

## The idea in three sentences

On a cash trip the rider pays the driver the whole fare, so the driver ends up holding
SheDrive's commission — she owes us. When online payment arrives, SheDrive will hold the
fare instead, so we will owe her. **Same account, same screens, same reports — only the
direction of the debt changes**, and that is decided by one field on the trip called
`custody`.

---

## What was built

### Design spec
`docs/superpowers/specs/2026-09-08-financial-core-design.md` — the economic model, both
ledgers and their entry types, the four invariants, the policy surface, the settlement
channels, the screen inventory and the story inventory.

### Backlog — 35 stories
| File | Contents |
|---|---|
| `docs/backlog/api-stories.md` | 8 new API stories + #1764 and #1781 reopened and rewritten |
| `docs/backlog/admin-stories.md` | 4 new admin stories + #1813 reopened, #1832 extended |
| `docs/backlog/mobile-driver-stories.md` | 4 new + #1788 rescoped onto the ledger |
| `docs/backlog/mobile-rider-stories.md` | 4 new rider stories |
| `docs/backlog/design-stories-financial.md` | 11 design briefs, one per screen |
| `docs/backlog/financial-core-ado-parents.md` | Verified Feature parent for every story |

### Working prototype — `shedrive-web/`
Every screen in the spec is built and clickable against mock data, with demo switches for
each state. It is the reference for layout, copy and behaviour.

**Rider** — `payments.html` (rewritten from a stub), fee notice and full-recovery banner on
`home.html`, recovered-fee line on `trip-complete.html` and `trip-detail.html`, plus a new
`scripts/fee-store.js` rider ledger.

**Driver** — `balance.html`, new `settle.html`, the blocked/warning states
on `home.html`, and the itemised `cash-collection.html`. `scripts/finance-store.js` carries
the custody model.

**Admin (`admin-v2/`)** — `balances.html`, `reconciliation.html`,
`rider-balances.html` (new), and the policy block on
`pricing-policies.html`, over an extended `seed.js` / `mock-api.js`.

---

## Two decisions worth knowing about

**1. The cancellation-fee leak is closed.** #1764 used to credit the driver her share of a
rider's late-cancellation fee while explicitly putting "collect it from the rider" out of
scope — so SheDrive funded that share out of its own pocket, every time. The fee now posts
to a **rider ledger** and is recovered as a surcharge on her next ride, collected by the
driver in cash. Spec §3 has the worked example; it balances to the last piastre.

**2. There is deliberately no rider booking block.** The first draft of the spec blocked a
rider once her fees crossed a limit. That deadlocks — a cash rider has no card, so taking a
ride is the *only* way she can ever clear a fee. Blocking her would make the debt permanent
and recover nothing. Instead the **recovery escalates**: below the threshold she pays one
fee per ride, at or above it her whole balance comes off the next ride at once. Abuse is
handled by suspending the rider (#1740) — a human decision.

If either comes back up in review, those are the reasons.

---

## Still open — these need a decision from the business

1. **How does the cash physically come back?** The settlement screen supports office cash,
   bank deposit, mobile wallet and field agent, with a reference number and a generated
   receipt. Nobody has decided which of those SheDrive will actually run, or who staffs it.
   `#1813`'s acceptance criteria can't be finalised until this is settled.

2. **Payout destinations are not collected at onboarding.** `#4003` adds the field and
   makes it required before a payout can be recorded, but driver onboarding does not ask for a
   bank account or wallet number today. That needs adding to the onboarding flow.

3. **#1645 — *Driver sets availability status* — is `Removed` in ADO**, yet `#3996`
   extends the go-online check it owned and #3058's completion flow depends on its
   availability write. No story currently owns that transition. Raise with the API team.

4. **Deliberately deferred, worth re-confirming rather than inheriting:** surge pricing,
   promo codes, referral credits, tips, driver bonuses, VAT/tax reporting, PDF receipts,
   accounting exports beyond CSV, and fee disputes. A promo mechanic in particular is the
   usual answer to a cold-start liquidity problem, and SheDrive is launching into exactly
   that.
