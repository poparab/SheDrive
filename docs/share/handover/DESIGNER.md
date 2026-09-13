# Handover — Design team

**Subject:** SheDrive financial core — 11 screens to draw
**Date:** 2026-09-08

---

## Read these, in this order

1. **`docs/backlog/design-stories-financial.md`** — your 11 briefs. Each one lists the
   components, every state to draw, and the bilingual requirement.
2. **`docs/superpowers/specs/2026-09-08-financial-core-design.md`** §3, §5 and §7 — the
   behaviour behind the screens, with worked numbers.
3. The **working prototype** — every one of these screens exists as a clickable HTML
   mockup with real demo data. Serve `shedrive-web/` and open the URLs in the table below.
   Draw *from* these, not from scratch; they already use the design system correctly.

---

## Story format — this differs from a normal user story

For design stories **everything goes in `System.Description`** — intro, components,
states, mockup link — and **`AcceptanceCriteria` is left empty.** There is no
"As a … I want … so that …" sentence. Each brief in the file is written as the HTML that
goes straight into the ADO field; copy the fenced block's contents verbatim.

Every parent Feature is already resolved and verified — see
`docs/backlog/financial-core-ado-parents.md`. Area path is `SheDrive\Design Team`.

---

## The 11 screens

| Screen | Parent | Prototype to draw from |
|---|---|---|
| **[Rider] Payment Method & Outstanding Fees** | #1849 | `rider/payments.html` |
| **[Rider] Outstanding Fee Notice & Full-Recovery State** | #1844 | `rider/home.html?fees=1` and `?full` |
| **[Rider] Fare Summary with a Recovered Fee** | #1846 | `rider/trip-complete.html?fee=20` |
| **[Driver] Balance & Statement** | #1840 | `driver/balance.html`, `?owed=430`, `?available=200`, `?zero` |
| **[Driver] Settle What You Owe** | #1840 | `driver/settle.html` |
| **[Driver] Go-Online Blocked & Warning Band** | #1838 | `driver/home.html?blocked` and `?warn` |
| **[Driver] Cash Collection with a Recovered Fee** | #1840 | `driver/cash-collection.html?riderfee=20` |
| **[Admin] Driver Balances & Record Settlement** | #2857 | `admin-v2/balances.html` |
| **[Admin] Record a Payout** | #2857 | `admin-v2/balances.html` |
| **[Admin] Rider Outstanding Fees** | #2857 | `admin-v2/rider-balances.html` |
| **[Admin] Balance & Fee Policy** | #2857 | `admin-v2/pricing-policies.html` |

Every admin list screen also honours `?state=empty|loading|error|long`.

---

## Ground rules

**Rider and driver apps** — mobile-first, bilingual **Arabic (RTL, default) and English
(LTR)**. Draw both directions; the RTL version is the primary one. Reuse the existing
`sd-*` components and the tokens in `shared/styles/tokens.css`. Do not introduce a new
colour, radius or button style.

**Admin portal** — desktop-first at **1280 px and 1440 px**, bilingual English (LTR,
default) and Arabic (RTL). Reuse the `ad-*` components. No Framework7, no bottom sheets.

**Money is typography.** Amounts are EGP to 2 decimals, right-aligned, tabular figures so
columns line up. **Credits and debits must be distinguishable without relying on colour
alone** — use an explicit sign, and a label, not just green and red.

---

## The two screens that carry the most risk

### 1. `[Driver] Go-Online Blocked & Warning Band`
This is the highest-stakes screen in the set: it stops a driver earning. It must always
show **three** things — the amount she owes, the limit she hit, and the route to clearing
it (a direct link to *Settle*). The warning band that precedes it is what stops the block
being a surprise. Tone: credit control, not punishment. She has done nothing wrong; she is
simply carrying our cash.

### 2. `[Rider] Outstanding Fee Notice & Full-Recovery State`
The awkward one. A rider is being asked, on today's ride, for a cancellation fee from days
ago — and above the threshold, for **all** of them at once. The amount on her fare will be
noticeably higher than the fare she was quoted.

The copy and layout have to make that feel **fair, not punitive**: state the amount plainly
before she confirms, say what it clears, and never bury it in the fare. Two weights of the
same banner — dismissible below the threshold, non-dismissible above it.

> Please do **not** draw a "rider blocked from booking" state. An earlier version of the
> design had one and it was removed: a cash rider can only clear a fee by taking a ride, so
> blocking her booking would trap her permanently. The only block on a rider is an admin
> suspending her account, which is an existing screen.

---

## States you must not skip

Empty, loading and error on every list. Plus, per screen: the warning band, the blocked
panel, the zero balance, the missing-payout-destination state, and the full-recovery
banner. They are enumerated per story in the briefs — the prototype demonstrates each one
via the query strings above.

Loading states must never **flash** the wrong state and then correct themselves — if the
fee or balance status is not yet known, render the neutral state and resolve quietly.

---

## What we still owe you

The `Mockup: <to be added>` line in each brief is a placeholder. Once you have Figma
frames, paste the link there and we will sync it into ADO.
