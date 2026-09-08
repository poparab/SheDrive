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
| `#3993` | [API] Driver requests a withdrawal of her available balance | **#1776** Earnings — Driver API | `SheDrive` |
| `#3996` | [API] Driver go-online blocked over the outstanding limit | **#1607** Driver Availability & Location API | `SheDrive` |
| `#3997` | [API] Trip completion posts to the ledger by fare custody | **#1604** Trip Completion & Rating API | `SheDrive` |
| `#4000` | [API] Rider outstanding fee is recovered on her next trip | **#1602** Trip Request & Matching API | `SheDrive` |
| `#4002` | [API] Rider fees above the recovery threshold are recovered in a single payment | **#1602** Trip Request & Matching API | `SheDrive` |
| `#4003` | [API] Driver payout destination captured and required | **#1776** Earnings — Driver API | `SheDrive` |
| `#4004` | [API] Rider retrieves her outstanding fees and statement | **#1775** Payments — Rider API | `SheDrive` |
| **#1764** | [API] Cancellation fees after the grace period — **reopen** | **#1602** (its existing parent) | `SheDrive` |
| **#1781** | [API] Driver retrieves her balance and statement — **reopen** | **#1776** (its existing parent) | `SheDrive` |
| `#3994` | [Admin] Configures balance, fee and withdrawal policy | **#1755** Admin — Pricing & Rate Management | `SheDrive` |
| `#4001` | [Admin] Reviews and processes driver withdrawal requests | **#1803** Admin — Financial Reporting & Reconciliation | `SheDrive` |
| `#4005` | [Admin] Reviews rider outstanding fees and waives them | **#1803** | `SheDrive` |
| `#4006` | [Admin] Views the settlement day book | **#1803** | `SheDrive` |
| **#1813** | [Admin] Reconciles driver balances, records settlements — **reopen** | **#1803** (its existing parent) | `SheDrive` |
| `#3987` | [Mobile] Driver requests a withdrawal | **#1769** Earnings — Driver | `SheDrive\SheDrive Mobile Team` |
| `#3988` | [Mobile] Driver blocked from going online over the limit | **#1540** Driver Home & Availability | `SheDrive\SheDrive Mobile Team` |
| `#3989` | [Mobile] Driver settles what she owes, sees settlement history | **#1769** Earnings — Driver | `SheDrive\SheDrive Mobile Team` |
| `#3990` | [Mobile] Driver collects a recovered rider fee with the fare | **#1543** Trip Completion — Driver | `SheDrive\SheDrive Mobile Team` |
| **#1788** | [Mobile] Driver views her balance and statement — **rescope** | **#1769** (its existing parent) | `SheDrive\SheDrive Mobile Team` |
| `#3992` | [Mobile] Rider views payment method and outstanding fees | **#1768** Payments — Rider | `SheDrive\SheDrive Mobile Team` |
| `#3995` | [Mobile] Rider sees an outstanding fee before requesting | **#1533** Rider Home, Address Search & Fare Estimate | `SheDrive\SheDrive Mobile Team` |
| `#3998` | [Mobile] Rider is told when her full outstanding balance will be added | **#1533** | `SheDrive\SheDrive Mobile Team` |
| `#3999` | [Mobile] Rider sees the recovered fee on her fare summary | **#1536** Trip Completion & Rating | `SheDrive\SheDrive Mobile Team` |

## Design backlog — area path `SheDrive\Design Team`

Design stories use the **design story format**: everything in `System.Description`,
`AcceptanceCriteria` left empty.

| ADO id | Design story | Parent Feature |
|---|---|---|
| **#3974** | [Rider] Payment Method & Outstanding Fees | **#1849** Rider — Menu & Profile |
| **#3975** | [Rider] Outstanding Fee Notice & Full-Recovery State | **#1844** Rider — Home & Booking |
| **#3976** | [Rider] Fare Summary with a Recovered Fee | **#1846** Rider — Trip Completion & Rating |
| **#3977** | [Driver] Balance & Statement | **#1840** Driver — Trip Completion & Earnings |
| **#3978** | [Driver] Request a Withdrawal | **#1840** |
| **#3979** | [Driver] Settle What You Owe | **#1840** |
| **#3980** | [Driver] Go-Online Blocked & Warning Band | **#1838** Driver — Home & Trip Acceptance |
| **#3981** | [Driver] Cash Collection with a Recovered Fee | **#1840** |
| **#3982** | [Admin] Driver Balances & Record Settlement | **#2857** Admin — Pricing, Reporting & Reconciliation |
| **#3983** | [Admin] Driver Withdrawal Requests | **#2857** |
| **#3984** | [Admin] Rider Outstanding Fees | **#2857** |
| **#3985** | [Admin] Settlement Day Book | **#2857** |
| **#3986** | [Admin] Balance, Fee & Withdrawal Policy | **#2857** |

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

## Separate gap, not part of this change set

**#1645** *[API] Driver sets availability status* is `Removed`, but #3058's completion
flow and the go-online gate (`#3996`) both depend on the availability write it owned.
Raise this with the API team — `#3996` extends a story that no longer exists.
