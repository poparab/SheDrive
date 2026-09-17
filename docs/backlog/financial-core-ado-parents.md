# Financial core — ADO work items, created and parent-verified

**All 37 stories exist in ADO as of 2026-09-08.** The `FIN-nn` placeholders that this
change set was authored against have been replaced with the real ids below, everywhere —
in the backlog files, the design spec, the handover packets, the prototype comments, and
inside the ADO work items' own Dependencies sections.

Every parent was fetched from ADO and confirmed to be a **Feature** before use, and every
link was verified after creation by re-fetching the child. Twenty-four dev stories were
created new, three previously-`Removed` stories were reopened and rewritten (#1764, #1781,
#1813), one was rescoped (#1788), and thirteen design stories were created in the
`SheDrive\Design Team` area.

> For anyone adding to this set later: `System.Parent` as a *create* field does **not**
> link. Create the work item first, then link with `wit_work_items_link` (type `parent`)
> or `wit_add_child_work_items`, then re-fetch to confirm the link stuck.

## Dev backlog

| ADO id | Story | Parent Feature | Area path |
|---|---|---|---|
| `#3991` | [API] Party balance ledger records every balance movement | **#1776** Earnings — Driver API | `SheDrive` |
| `#3993` | ~~[API] Finance records a payout sent to a driver~~ — **Removed 2026-09-17**, folded into #4001, see below | **#1776** Earnings — Driver API | `SheDrive` |
| `#3996` | [API] Driver go-online blocked over the outstanding limit | **#1607** Driver Availability & Location API | `SheDrive` |
| `#3997` | [API] Trip completion posts to the ledger by fare custody | **#1604** Trip Completion & Rating API | `SheDrive` |
| `#4000` | [API] Rider outstanding fee is recovered on her next trip *(rewritten 2026-09-17: recovers her entire balance, always — no drip, no threshold)* | **#1602** Trip Request & Matching API | `SheDrive` |
| `#4002` | ~~[API] Rider fees above the recovery threshold are recovered in a single payment~~ — **Removed 2026-09-17**, see below | **#1602** Trip Request & Matching API | `SheDrive` |
| `#4003` | ~~[API] Driver payout destination captured and required~~ — **Removed 2026-09-17**, see below | **#1776** Earnings — Driver API | `SheDrive` |
| `#4004` | [API] Rider retrieves her outstanding fees and statement | **#1775** Payments — Rider API | `SheDrive` |
| **#1764** | [API] Cancellation fees after the grace period — **reopen** | **#1602** (its existing parent) | `SheDrive` |
| **#1781** | [API] Driver retrieves her balance and statement — **reopen** | **#1776** (its existing parent) | `SheDrive` |
| `#3994` | [Admin] Configures balance and fee policy *(retitled 2026-09-13, was "Configures balance, fee and withdrawal policy"; rider fee recovery threshold removed 2026-09-17)* | **#1755** Admin — Pricing & Rate Management | `SheDrive` |
| `#4001` | [Admin] Records a payout sent to a driver *(retitled 2026-09-13, was "Reviews and processes driver withdrawal requests"; absorbed #3993 2026-09-17 — now owns the ledger posting, idempotency and over-balance refusal)* | **#1803** Admin — Financial Reporting & Reconciliation | `SheDrive` |
| `#4005` | [Admin] Reviews rider outstanding fees *(retitled 2026-09-17, was "...and waives them" — the waive action is gone; read-only, with an escalation link to rider suspension)* | **#1803** | `SheDrive` |
| `#4006` | ~~[Admin] Views the settlement day book~~ — **Removed 2026-09-13**, see below | **#1803** | `SheDrive` |
| **#1813** | [Admin] Reconciles driver balances, records settlements — **reopen** | **#1803** (its existing parent) | `SheDrive` |
| `#3987` | ~~[Mobile] Driver requests a withdrawal~~ — **Removed 2026-09-13**, see below | **#1769** Earnings — Driver | `SheDrive\SheDrive Mobile Team` |
| `#3988` | [Mobile] Driver blocked from going online over the limit | **#1540** Driver Home & Availability | `SheDrive\SheDrive Mobile Team` |
| `#3989` | [Mobile] Driver settles what she owes, sees settlement history | **#1769** Earnings — Driver | `SheDrive\SheDrive Mobile Team` |
| `#3990` | [Mobile] Driver collects a recovered rider fee with the fare | **#1543** Trip Completion — Driver | `SheDrive\SheDrive Mobile Team` |
| **#1788** | [Mobile] Driver views her balance and statement — **rescope** | **#1769** (its existing parent) | `SheDrive\SheDrive Mobile Team` |
| `#3992` | [Mobile] Rider views payment method and outstanding fees | **#1768** Payments — Rider | `SheDrive\SheDrive Mobile Team` |
| `#3995` | [Mobile] Rider sees an outstanding fee before requesting *(rewritten 2026-09-17: the single notice, dismissible, stating the full amount — absorbed #3998)* | **#1533** Rider Home, Address Search & Fare Estimate | `SheDrive\SheDrive Mobile Team` |
| `#3998` | ~~[Mobile] Rider is told when her full outstanding balance will be added~~ — **Removed 2026-09-17**, folded into #3995, see below | **#1533** | `SheDrive\SheDrive Mobile Team` |
| `#3999` | [Mobile] Rider sees the recovered fee on her fare summary | **#1536** Trip Completion & Rating | `SheDrive\SheDrive Mobile Team` |

## Design backlog — area path `SheDrive\Design Team`

Design stories use the **design story format**: everything in `System.Description`,
`AcceptanceCriteria` left empty.

| ADO id | Design story | Parent Feature |
|---|---|---|
| **#3974** | [Rider] Payment Method & Outstanding Fees | **#1849** Rider — Menu & Profile |
| **#3975** | [Rider] Outstanding Fee Notice *(retitled 2026-09-17, was "...& Full-Recovery State" — the full-recovery split is gone, one notice covers everything)* | **#1844** Rider — Home & Booking |
| **#3976** | [Rider] Fare Summary with a Recovered Fee | **#1846** Rider — Trip Completion & Rating |
| **#3977** | [Driver] Balance & Statement | **#1840** Driver — Trip Completion & Earnings |
| **#3978** | ~~[Driver] Request a Withdrawal~~ — **Removed 2026-09-13**, see below | **#1840** |
| **#3979** | [Driver] Settle What You Owe | **#1840** |
| **#3980** | [Driver] Go-Online Blocked & Warning Band | **#1838** Driver — Home & Trip Acceptance |
| **#3981** | [Driver] Cash Collection with a Recovered Fee | **#1840** |
| **#3982** | [Admin] Driver Balances — Record Settlement & Payout *(retitled 2026-09-14, absorbed #3983)* | **#2857** Admin — Pricing, Reporting & Reconciliation |
| **#3983** | ~~[Admin] Record a Payout~~ — **Removed 2026-09-14**, merged into #3982, see below | **#2857** |
| **#3984** | [Admin] Rider Outstanding Fees *(waive flow, modal and states removed 2026-09-17 — screen is read-only)* | **#2857** |
| **#3985** | ~~[Admin] Settlement Day Book~~ — **Removed 2026-09-13**, see below | **#2857** |
| **#3986** | [Admin] Balance & Fee Policy *(retitled 2026-09-13, was "Balance, Fee & Withdrawal Policy")* | **#2857** |

## Pointed stories — confirmed by the product owner on 2026-09-08

| Id | Points | Change | Status |
|---|---|---|---|
| **#1832** | 3 | Commission earned vs. settled vs. outstanding, plus a dependency repoint | **Approved** — apply, leave StoryPoints untouched |
| **#1833** | 8 | Dependency repoint only | **Approved** — apply, leave StoryPoints untouched |

The product owner confirmed both edits explicitly and asked that the `StoryPoints`
field be left as-is. Re-estimation is theirs to do later if the added scope warrants it.

## Do not reopen — verified superseded

| Id | Superseded by |
|---|---|
| #1637 | #3058 |
| #1812 | #1832 + #1833 |
| #1814 | #1833 |
| #1765 | #1636 |
| #1730 / #1732 / #1733 / #1734 / #1782 / #1784 / #1789 / #1793 | Payment-provider work, deliberately post-Phase 1 |

## Removed 2026-09-13 — drivers do not request payouts

The product owner decided drivers never request a payout: Finance transfers the funds
on its own cycle and records the transfer afterward (#4001, which absorbed #3993 on
2026-09-17) — the mirror of recording a settlement (#1813), in the opposite direction.
There is no request, no approval queue, no reservation, no minimum/maximum, and no
cooling-off anywhere in the system.

| Id | Was | Status |
|---|---|---|
| `#3987` | [Mobile] Driver requests a withdrawal of her available balance | **Removed** — see #4001 |
| `#3978` | [Driver] Request a Withdrawal (design) | **Removed** — see #4001 |

## Removed 2026-09-13 — settlement day book cut

Cut as a report dressed as a screen. Settlement entries are exportable as CSV directly
from the driver balances screen (#1813), which gives Finance the same reconciliation
input the day book used to provide. Can return as a real reconciliation — banked
amount in, variance out — once the cash-collection model is decided.

| Id | Was | Status |
|---|---|---|
| `#4006` | [Admin] Super admin views the settlement day book | **Removed** — see #1813 |
| `#3985` | [Admin] Settlement Day Book (design) | **Removed** — see #1813 |

## Removed 2026-09-13 — the post-adjustment action, everywhere

The product owner cut the free-form correction/adjustment action from both ledgers.
The `adjustment` entry type is gone from the driver and rider ledger tables (#3991);
the "Post adjustment" action is gone from #1813 and #4005 and their design briefs
(#3982, #3984). At the time, `fee_waived` and the rider-side waive action were kept —
waiving a debt someone should not pay was treated as a different thing from correcting
a keying error.

**That waive action was itself cut on 2026-09-17** — see the section below. So as of
that date, neither ledger has any correction path at all: not for a keying error, and
not for a fee that should not have been charged. Invariant 2 (entries are immutable)
now states plainly that Phase 1 ships with no correction mechanism at all, on either
ledger; see the open item in the design spec §10 for the proposed reverse-this-entry
follow-up.

No work item was removed for this cut — it is a scope reduction inside stories that
still exist, not a separate story of its own.

## Removed 2026-09-14 — Record a Payout brief merged into Driver Balances

Recording a payout is a modal on the driver balances screen, the same screen as
recording a settlement, so it is designed as part of that screen. The payout form, its
states and its preview links moved into #3982, which was retitled to cover both actions.
The dev story for the action (#4001) is unchanged.

| Id | Was | Status |
|---|---|---|
| `#3983` | [Admin] Record a Payout (design) | **Removed** — merged into #3982 |

## Removed 2026-09-17 — the platform holds no payout destination

The product owner decided the platform does not capture, store, or verify a payout
destination for a driver at all. Getting the money to her is a manual, off-platform
process. Recording a payout (#4001) is not gated on any destination — the admin
records the amount, the date and a reference, and that is the entire scope.

| Id | Was | Status |
|---|---|---|
| `#4003` | [API] Driver payout destination is captured and required before a payout can be recorded | **Removed** — see #4001 |

## Removed 2026-09-17 — there is no rider fee recovery threshold

The product owner decided a rider clears her **entire** outstanding balance on her
next completed trip, always — no recovery threshold, no escalation, no oldest-fee-first
drip, and nothing to configure. Handling a rider who racks up several cancellations
before her next ride is deliberately deferred to later. #4000 was rewritten to this
behaviour; #4002 (the escalation on top of a gentler drip) had nothing left to add.
On the mobile side, #3998 (the escalated, non-dismissible notice) collapsed into #3995
(now the single, dismissible notice stating the full amount). #3994 lost its rider
fee recovery threshold field and scenarios; #4005 and #4004 lost their threshold
references.

| Id | Was | Status |
|---|---|---|
| `#4002` | [API] Rider fees above the recovery threshold are recovered in a single payment | **Removed** — see #4000 |
| `#3998` | [Mobile] Rider is told when her full outstanding balance will be added to her next ride | **Removed** — folded into #3995 |

## Removed 2026-09-17 — there is no waive, anywhere

The product owner decided the only way a rider's fee is cleared is that she pays it,
on her next completed trip — nobody writes it off. The `fee_waived` entry type is gone
from the rider ledger (#3991), which now carries only `cancellation_fee` and
`fee_collected`. #4005 was retitled and cut down to a read-only list, ledger drawer,
and an escalation link into rider suspension (#1740) — no waive action, no Field
Validation rows for it, no scenarios for it. Its design brief (#3984, confirmed still
`Active` in ADO, not superseded by any other session's edit) had its waive modal and
states removed the same way. #4004 no longer describes a fee being waived. This does
**not** touch the driver no-show waiver (#1764, #1720, #1759) — that is an automatic
rule at cancellation time, not an admin write-off, and it stays exactly as it was.

No work item was removed for this cut — it is a scope reduction inside stories that
still exist, not a separate story of its own.

## Removed 2026-09-17 — #3993 folded into #4001

The product owner resolved the open question about #3993 and #4001 describing the
same act from two sides: the house rule is that an `[API]` story exists only for a
mobile screen, and an admin screen's backend lives inside its own `[Admin]` story.
#4001 absorbed #3993's scenarios — the idempotency-on-reference rule and the
refusal when the amount exceeds the available balance both survive, renumbered with
no gaps — and now points its Dependencies straight at #3991.

| Id | Was | Status |
|---|---|---|
| `#3993` | [API] Finance records a payout sent to a driver | **Removed** — folded into #4001 |

## Story count after the cuts

39 work items minus `#3987`, `#3978`, `#4006`, `#3985`, `#3983`, `#4003`, `#4002`,
`#3998`, `#3993` = **30 remaining**, of which **10 are design briefs**.

This count is internal to this file's own tally of the 39 items in the two tables
above (dev backlog, design backlog) plus the two pointed-story repoints. The task
briefs that drove the 2026-09-17 changes instead tracked a base of 35 items (the
story-inventory count in the design spec §9, which does not include #1764, #1781,
#1813 or the pointed-story repoints as new items since they already existed) and
so reported running tallies of 34, 32 and 31. Both countings are internally
consistent; they simply start from different baselines.

## Where the availability write lives — resolved 2026-09-17

The availability endpoint and its approval gate belong to **#1644** *[API] Driver
onboarding decision — go-online and offline*, `Closed` in Sprint 1 at 1 point. **#1645**
was `Removed` as a duplicate of #1644, not because the capability was dropped. `#3996`
therefore adds one more condition — the outstanding-balance check — to a gate that already
exists, and #3058's completion flow has its availability write too.
