# Stakeholder feedback — 2026-10-13

Comments from the stakeholder meeting, recorded as given. For each comment the record shows
what the backlog says today, what would change, and the questions to answer before anyone
writes or edits stories.

> **Status: phased 2026-10-13.** **Now: 5, 6, 7, 8, 9** (driver payouts and settlement).
> **Phase 2: 1, 2, 3, 4, 10** (global price card, destination pricing, timed suspension,
> rider wallet, scheduled rides). ADO and the four backlog files in `docs/backlog/` have not
> been changed yet.
> The short version for that decision is
> [stakeholder-feedback-2026-10-13-summary.md](stakeholder-feedback-2026-10-13-summary.md).

**Four of the ten comments undo an earlier decision (4, 5, 8 and 10).** Those decisions were made on purpose, so
each one is marked **⚠ Reverses** below with the date and the reason it was made.

---

## 1. Global price card as fallback for zones

**Requested:** a global price card. A zone with an empty price card inherits the global one.

**Today:** each zone has its own rate card (#1757): base fare, per-km, per-min, minimum fare
and cancellation fee. A zone without a rate card is **Inactive** and blocks trips (#1757
Scenario 5). Zone status comes from the rate card and is never set by hand. The global
settings (#1759) cover cancellation policy, commission and dispatch, but not fares.

**What changes**
- New global rate card with the same fields as the zone card (#1757 or #1759).
- A zone with no card of its own prices trips from the global card, so it no longer blocks
  them. That breaks the rule "status comes from the rate card" in #1757 Scenarios 5 and 6.
  Zone status needs a new definition.
- The fare engine (#1628) resolves the card in order: zone card first, then global.
- Global card changes are recorded in the pricing audit log (#1760).

**Open questions**
- Is inheritance **per card** (zone is empty, so use the whole global card) or **per field**
  (zone sets only the per-km rate and takes the other fields from global)?
- With a global card, can a zone still be Inactive? If so, what makes it Inactive: switched
  off by hand, or no drivers?
- Does the fare screen show which card priced a trip (zone or global), for support and audit?

---

## 2. Zone pricing considers the destination, not only the pickup

**Requested:** the pickup zone alone currently decides the price. A trip whose destination is
in a priced zone should also be priced by that zone.

**Today:** the fare engine (#1628) uses the pickup zone's rate card. The destination zone has
no effect on price.

**What changes**
- The fare engine needs a rule for trips where the pickup and destination zones differ.
- The fare estimate (#1552) and the final fare (#1636) must use the same rule.

**Open questions (the rule is not defined yet)**
- When the pickup and destination zones differ, which card prices the trip?
  - a) the destination zone's card,
  - b) the higher of the two cards,
  - c) a zone-to-zone price matrix (a fixed card for each pair), or
  - d) a destination surcharge on top of the pickup zone's card (for example the airport).
- Can a trip **end** in an Inactive zone, or outside every zone?
- If a stop is added mid-trip and the destination moves into another zone, is the fare repriced?

---

## 3. Suspension for a set period

**Requested:** suspend a driver or rider for a set period, for example 7 days.

**Today:** rider suspension (#1740) and driver suspension (#1742) last until an admin manually
reinstates the account (#1741, #1743). There is no end date.

**What changes**
- The suspend dialog gets a duration: a fixed period or **until reinstated**.
- The account is reinstated automatically when the period ends, with an audit entry and a
  notification to the rider or driver.
- An admin can still reinstate early (#1741, #1743), or extend the suspension.
- **Pending Suspension** (a suspension requested during an active trip, #1740) starts the
  clock when the trip ends, not when the admin clicks.
- **Do not change the driver suspension logic that is already built** (see
  `project_account_deletion` memory). The duration is an addition on top of it.

**Open questions**
- Preset durations (1 / 3 / 7 / 30 days) or any number of days?
- Is "until reinstated" still allowed?
- Does the rider or driver see the end date in the app?
- How does a suspension end date interact with account deletion's 30-day window?

---

## 4. Closed-loop rider wallet

**Requested:** a rider can top up a wallet and pay for trips from the balance.

**Today:** there is no wallet. The rider ledger holds only cancellation fees, and she clears
them on her next trip. Card payment is in scope but waiting on the payment integration
(#1732, #1734, tag *Awaiting payment integration*).

**⚠ Reverses:** on 2026-09-10 the product owner ruled that stories must not mention wallets or
online payment. The financial core was built for this: a wallet-paid trip is
`custody = platform`, so the driver's net is a credit (SheDrive owes her). That branch was
designed but no Phase 1 flow uses it. A wallet makes it real.

**What changes**
- Rider: wallet balance, top-up, a wallet payment option at booking, wallet history.
- Rider ledger: new entry types for top-up, trip payment, refund and fee paid from wallet.
- Driver ledger: wallet trips post `trip_earnings` (+net) instead of `trip_commission`
  (−commission). Under the custody rule this already works without new code paths.
- Admin: view a rider's wallet balance and history; refunds and adjustments (maker-checker,
  see 7).

**Open questions**
- **Top-up channel:** card (needs the pending payment integration), Fawry or another cash
  network, or cash handed to the driver? Each one is a separate integration.
- Can a rider ever withdraw the balance or get it refunded (account deletion, dispute)? A
  "closed loop" usually means no.
- Is the outstanding cancellation fee taken from the wallet automatically?
- If the wallet is short at trip end: does she pay the rest in cash, or is booking blocked
  when the balance is low? (A booking block hit a deadlock before — see the financial-core
  spec.)
- **Regulation:** check with legal whether a stored-value rider wallet needs Central Bank of
  Egypt approval or a licensed partner. Do this before committing to a date.

---

## 5. Driver payout method collected at onboarding

**Requested:** drivers are paid by one of three methods: **mobile wallet, bank account, or
prepaid card**. The driver picks one during onboarding.

**Today:** nothing is collected. Payouts are a manual, offline process and the system only
records that a payout happened (#4001).

**⚠ Reverses:** on 2026-09-17 the payout destination story (#4003) was removed. The decision
was that no payout details are collected, stored or verified.

**What changes**
- New onboarding step: choose a payout method and enter its details.
  - Mobile wallet: provider and wallet number.
  - Bank account: bank, account holder name, account number / IBAN.
  - Prepaid card: issuer and card number (confirm which card product, e.g. Meeza).
- Driver profile: view the payout method, and change it after onboarding.
- Admin: payout details shown on the driver application (#1572 family) and the driver
  profile.
- Onboarding stories and the design (#1696) change.

**Open questions**
- Is the payout method **mandatory to finish onboarding**, or required only before the first
  payout?
- Must the account holder's name match the driver's national ID name? Who checks it?
- When a driver changes her payout method, does an admin approve it (maker-checker)? A changed
  payout destination is a common fraud path.
- Prepaid card: which issuer, and is the full card number or only a reference stored?

---

## 6. Import and export for payouts and settlements

**Requested**
- **a. Payout export:** a file Finance uploads to the bank portal for a bulk transfer.
- **b. Settlement import:** when drivers pay SheDrive, Finance imports the settlement sheet and
  those drivers are marked settled in the system.

**Today:** payouts (#4001) and settlements (#4379) are recorded one driver at a time on the
driver ledger. Settlement entries can be exported as CSV, but only for checking.

**What changes**
- **Payout export:** generate a batch of drivers due a payout, in the bank's bulk-transfer
  format, grouped by payout method (5). Mark the batch *exported*, then *confirmed paid*.
  Each line posts a `payout` entry only when confirmed, not when exported.
- **Settlement import:** upload a sheet, match each row to a driver, preview it (matched,
  unmatched, duplicate, amount mismatch), then post `settlement` entries for the rows that
  are approved. The import must be idempotent on the transfer reference, so importing the
  same sheet twice posts nothing new.
- Both go through maker-checker (7).

**Open questions**
- **Which bank?** We need the bank portal's bulk-transfer template (columns, file type,
  limits). Mobile wallets and prepaid cards may each need their own file.
- What is in the settlement sheet, and where does it come from (bank statement, Fawry, a
  sheet Finance fills in)? We need a sample.
- How is a row matched to a driver: phone, driver ID, or a reference the driver quotes when
  paying?
- What happens to a partial payment, an overpayment, or a row that matches no driver?

---

## 7. Maker-checker on every finance decision

**Requested:** every finance decision needs a maker and a checker.

**Today:** one admin records a settlement or payout and it posts immediately. Admin roles
differ only in suspending and deleting other admins (#1821); all admins can use every screen.

**What changes**
- A finance action creates a **pending request**. A second admin approves or rejects it. The
  ledger entry posts only on approval.
- The checker must be a different person from the maker.
- New approvals queue in the admin portal, with an audit trail of who made it, who checked
  it, and when.
- This probably needs a new permission (for example *Finance checker*). Today there are only
  two roles and they differ only in admin-account management.

**Open questions**
- **Which actions count as "finance decisions"?** Suggested list for confirmation: record
  settlement, settlement import, record payout, payout export batch, fee waiver (8), wallet
  refund or adjustment (4), driver payout-method change (5). Are **pricing changes** (1, #1759)
  included?
- Who can be a checker: any other admin, or only a named finance role?
- Does a pending request expire? Can the maker cancel it?

---

## 8. Waive the fee on one rider cancellation

**Requested:** an admin can waive the cancellation fee on one specific rider cancellation.

**Today:** there is no waive. A rider's fee is cleared only by paying it (the
`fee_waived` entry type was removed), and `rider-balances.html` is read-only.

**⚠ Reverses:** on 2026-09-17 waives were removed from both ledgers ("No waive, anywhere").
The automatic driver no-show waiver inside #1764 was kept and is not affected.

**What changes**
- Rider balance / trip detail: a **Waive fee** action on one cancellation, with a reason.
- A `fee_waived` entry on the rider ledger that points to the original fee entry.
- **Decide the driver side:** when the fee is waived, does the driver still keep her share of
  that fee (SheDrive absorbs it), or is her share reversed too?
- Goes through maker-checker (7).
- This also gives the ledger the first correction path. The financial-core memory notes it
  was designed for but not built.

**Open questions**
- Can a fee be waived after the rider has already paid it? If yes, that is a refund, so where
  does the money go (wallet credit, if 4 is built)?
- Is there a limit (amount, or how many per rider)?

---

## 9. Settlement cycle: daily, transactions older than 7 days

**Requested:** settlement runs daily. The daily export includes every transaction that is
**older than 7 days and not yet settled**.

**Today:** there is no cycle. Finance records settlements and payouts whenever they happen.

**What changes**
- Each transaction gets a **maturity date** (transaction date + 7 days).
- A daily batch picks every matured, unsettled transaction and builds the export (6a).
- A driver's statement shows what is matured and what is still in the 7-day hold.

**Open questions (the wording is ambiguous)**
- Does the 7-day rule apply to the **payout export** (money SheDrive sends drivers), the
  **settlement list** (money drivers owe SheDrive), or both? From the wording it reads as the
  payout export.
- Is it **per transaction** or **per driver net**? If a driver both owes cash commission and
  is owed wallet earnings, do we net them before exporting?
- Is it 7 calendar days or 7 business days?
- Does the 7-day hold change the go-online gate (outstanding balance ≥ 500 EGP blocks going
  online), which uses the full balance today?

---

## 10. Scheduled rides

**Requested:** scheduled rides.

**⚠ Reverses:** scheduled rides were moved out of Phase 1 to Phase 1.5.

**Today:** fully specified. See
[phase-1.5-stories.md](../backlog/phase-1.5-stories.md), *Cluster C — Scheduled Rides*:
#1770 (Mobile) and #1777 (API), both set to Removed in ADO. The product values are already
final: book at least 30 minutes ahead, at most 7 days ahead, and matching starts 15 minutes
before pickup.

**What changes**
- Restore the Cluster C stories in ADO and move them back into the four backlog files.
- Add the admin side: scheduled rides list and cancel (not in Cluster C).
- Driver side: decide whether a driver sees upcoming scheduled jobs, or only receives them
  through normal matching 15 minutes before pickup (the current spec).

**Open questions**
- Is a cancellation fee charged when a rider cancels a scheduled ride? How close to pickup?
- What happens if no driver is found by pickup time?

---

## How the items depend on each other

| Item | Needs first |
|---|---|
| 2 Destination pricing | 1 (shares the card-resolution change in the fare engine) |
| 4 Wallet | Payment integration for card top-up (#1732 / #1734), legal check |
| 6a Payout export | 5 (payout method), 9 (which transactions are due) |
| 6b Settlement import | A sample sheet from Finance |
| 8 Waive fee | 7 if a waiver counts as a finance decision |
| 9 7-day cycle | 6a (it feeds the export) |
| 7 Maker-checker | Nothing, but 6, 8 and the wallet adjustments all use it, so build it before them |
| 3 Timed suspension, 10 Scheduled rides | Independent |

---

## Stakeholder answers (2026-10-13, follow-up)

| Item | Question | Answer |
|---|---|---|
| 1 Global price card | Whole card or per field? | **Per field.** A zone can set some fields and take the rest from the global card. |
| 1 Global price card | Can a zone still be Inactive? | **Yes, by hand.** An admin can switch a zone off. Zone status no longer comes from whether it has a rate card. |
| 1 Global price card | Which fields does the global card hold? | **All the per-zone fields**, including the cancellation fee. |
| 1 Global price card | Show which card priced the trip? | **No.** |
| 2 Destination pricing | Destination changed mid-trip? | **Not possible.** The destination cannot be changed mid-trip, so no repricing. |
| 2 Destination pricing | Price change while a trip is in progress? | **Keep the current behaviour:** values active when the driver accepted. |
| 9 7-day cycle | Payouts, settlements or both? | **Payouts only.** Settlements have no 7-day hold. |
| 9 7-day cycle | Per transaction or per driver net? | **Per transaction for maturity** (each transaction becomes due 7 days after it happens). **The exported file shows one net amount per driver.** |
| 9 7-day cycle | Calendar or business days? | **Calendar days.** |

**What follows from the answers**
- The go-online block (owed balance ≥ 500 EGP) is not affected by the 7-day hold. The hold
  applies only to payouts, and the block is about money the driver owes.

---

## Open questions (remaining)

### 2. Destination pricing
- When the pickup and destination zones differ, which price applies: destination zone's
  price, the higher of the two, a fixed price per zone pair, or pickup price plus a
  destination surcharge?
- Can a trip end in an Inactive zone, or outside every zone?

### 3. Timed suspension
- Preset durations (1 / 3 / 7 / 30 days) or any number of days?
- Is "until reinstated" (no end date) still an option?
- Does the rider or driver see the end date in the app?
- Can an admin extend or shorten a running suspension?

### 4. Rider wallet
- Top-up channel: card, Fawry or another cash network, or cash to the driver?
- Can the balance ever be refunded (account deletion, dispute)?
- Balance short at trip end: pay the rest in cash?
- Is an outstanding cancellation fee taken from the wallet automatically?
- Minimum and maximum top-up, maximum balance, expiry?
- Legal confirmation on Central Bank licensing.

### 5. Driver payout method
- Required to finish onboarding, or only before the first payout?
- Must the account name match the national ID name? Who checks?
- Does a later change of payout method need admin approval?
- Prepaid card: which issuer, and is the full card number stored?
- What happens when a payout fails (wrong number, closed account)?

### 6. Payout export and settlement import
- Which bank, and its bulk-transfer file template? Separate files for mobile wallets and
  prepaid cards?
- A sample settlement sheet, and where it comes from.
- How a settlement row is matched to a driver (phone, driver ID, payment reference).
- Partial payments, overpayments, unmatched rows.
- Who pays transfer fees?
- Minimum payout amount (below it, carry over to the next cycle)?

### 7. Maker-checker
- Confirm the list of finance actions (settlement, settlement import, payout, payout export,
  fee waiver, wallet refund/adjustment, payout method change). Do price changes count?
- Who can approve: any other admin, or a finance role only?
- Do pending requests expire? Can the maker cancel?

### 8. Fee waiver
- Does the driver keep her share of a waived fee?
- Can a fee be waived after it was paid (a refund)? Where does the money go?
- Any limit on amount or count per rider?

### 9. 7-day cycle
- If a driver's matured net is negative (she owes more than she is owed), is she left out of
  the payout file, and does her matured earnings amount reduce what she owes?

### 10. Scheduled rides
- Price locked at booking, or recalculated at dispatch? If recalculated, a cap?
- A scheduling fee or premium?
- Which price card applies if prices change between booking and pickup?
- Free-cancellation window, and the fee after it.
- No driver found by pickup time: cancel with no fee, or keep matching?
- Paid from the wallet: is the amount held at booking?
- Do drivers see and accept scheduled jobs in advance, or only through normal matching?
- Are scheduled rides cancelled when the rider is suspended or deletes her account?

### Added after phasing (items 5–9)
- **Scope check:** in Phase 1 fares are cash, so SheDrive owes drivers only their share of
  cancellation and recovered fees. Will card payment launch with this release? If not,
  payouts will be small and rare.
- **5:** how do drivers who are already approved add a payout method?
- **6:** are drivers marked paid on export, or only after Finance confirms the bank transfer?
- **8:** with no wallet in Phase 1, how is a rider refunded if a paid fee is waived?
- **9:** is the daily export generated automatically or by an admin, and at what time?
- **7:** wallet refund/adjustment is out of the finance-action list (wallet is Phase 2).

---

## Answers for items 5–9 (2026-10-14)

| Item | Question | Answer |
|---|---|---|
| 5 | Required at onboarding? | **Yes, required to finish onboarding.** |
| 5 | Name must match national ID? | **No.** The method only has to be valid. |
| 5 | Can she change it later? | **Yes.** |
| 5 | Prepaid card | **Any prepaid card. The card number is stored.** |
| 5 | Failed payout | Finance returns a **result file** for each cycle showing which payouts succeeded and which failed. |
| 6 | Bank template | **We define one** (columns, file type). |
| 6 | One file per method? | **One file**, with a payout-type column. |
| 6 | When is a driver marked paid? | **A middle status after export.** Paid only when Finance returns the file with that line marked successful. |
| 6 | Settlement sheet | **We design the template** and give it to Finance as a proposal. |
| 6 | Matching key | **Driver national ID.** |
| 6 | Partial / overpayment | **Not allowed.** |
| 6 | Transfer fees | **Ignored.** The export carries the exact amount to be paid. |
| 6 | Minimum payout | **None.** |
| 7 | Actions covered | **Every action on the list:** record settlement, settlement import, record payout, payout export, fee waiver, payout method change. |
| 7 | Price changes? | **Yes.** Rate card and commission changes count. |
| 7 | Who approves? | **Any other admin** for now. More roles later. |
| 7 | Expiry / cancel | **Never expires. The checker can reject it.** |
| 8 | Driver's share | **Removed too.** |
| 8 | Fee already paid | **Credited to the rider's balance.** |
| 8 | Limit | **None.** |
| 9 | Negative driver | **No payout.** She must settle. |
| 9 | Who generates the export | **An admin**, by hand (no file on weekends and holidays). |

### Design decisions (2026-10-14)
- **Payout method change by the driver:** no admin approval; takes effect immediately. An
  admin editing it on her behalf still goes through maker-checker.
- **Rider credit** (from waiving a fee she already paid): shown on her balance, **not spent**
  in this phase.
- **Manual record payout stays** (through maker-checker), alongside the payout batches.
- Still to confirm: payout amount = smaller of her due net and her whole balance; settlement
  import amount must equal exactly what she owes on the import day.
