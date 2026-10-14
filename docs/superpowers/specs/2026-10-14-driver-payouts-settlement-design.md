# Driver payouts, settlement import and maker-checker — design

**Date:** 2026-10-14 · **Status:** approved by the product owner, building
**Source:** stakeholder meeting 2026-10-13 and follow-ups — `docs/product/stakeholder-feedback-2026-10-13.md`
**Builds on:** `2026-09-08-financial-core-design.md` (ledger, custody, settlement). Where the two
disagree, this document wins. It reverses three 2026-09-17 cuts: payout details are collected,
a rider fee can be waived, and payouts are batched instead of only recorded.

## 1. The rule over everything — maker-checker

Every finance action is a **request**. One admin makes it, a **different** admin approves or
rejects it, and only an approval changes data or writes the ledger.

| Request type | Made from | On approval |
|---|---|---|
| `payout_batch` | Payouts | Batch becomes *Ready to export* |
| `payout_result` | Payout batch | SUCCESS lines post a `payout` entry; FAILED lines go back to *Due* |
| `payout` (manual) | Driver balances | Posts a `payout` entry |
| `settlement` (manual) | Driver balances | Posts a `settlement` entry |
| `settlement_import` | Settlement imports | Posts one `settlement` entry per ready row |
| `fee_waiver` | Rider balances | Posts `fee_waived` (rider) and `fee_credit_reversed` (driver) |
| `payout_method` (admin edit) | Driver profile | Replaces the driver's payout method |
| `rate_card` | Pricing zones | Saves (or removes) the zone's rate card |
| `commission` | Pricing policies | Saves the commission % |

- The maker can't approve her own request. Any other admin can (finer roles later).
- A request never expires. The checker can reject it, with a reason (10–500 chars).
- **One pending request per subject** (a zone, a driver's settlement, a fee, a batch). A second
  one is refused until the first is decided.
- Every request, approval and rejection is in the audit log.
- Not a request: a driver changing **her own** payout method (§2). Cancellation policy and
  balance-limit settings still save immediately.

## 2. Driver payout method

- One method per driver: **mobile wallet** (provider + wallet number), **bank account**
  (bank + account holder name + account number or IBAN), **prepaid card** (card number + name
  on card). Any prepaid card is accepted.
- **Required to submit onboarding** (new last step). Only the format is validated; the name is
  not checked against the national ID.
- She can change it any time from her profile. **No approval; it applies immediately.** A batch
  uses the method she has when the batch is generated.
- An admin can edit it on her behalf from the driver profile — that is a `payout_method` request.
- The card and account numbers are masked on every screen (`•••• 4821`) and appear in full only
  in the export file. They must be encrypted at rest.

| Field | Rule |
|---|---|
| Wallet provider | Vodafone Cash, Orange Cash, e& money, WE Pay |
| Wallet number | Egyptian mobile, `01` + 9 digits |
| Bank | From the bank list |
| Account holder name | 3–100 chars |
| Account number / IBAN | 10–20 digits, or IBAN `EG` + 27 digits |
| Card number | 16 digits |
| Name on card | 3–100 chars |

## 3. Payout cycle (money out)

**Payable entries** are the ledger entries that add to what SheDrive owes her:
`trip_earnings` and `rider_cancellation_fee_credit`. Each one carries
`dueAt = at + 7 calendar days` and a payout status:

`On hold` (before `dueAt`) → `Due` → `In batch` → `Sent to bank` → `Paid`.
A FAILED line puts its entries back to `Due`.

**Generating a batch** (an admin, by hand, on working days — no automatic run):

- Several batches can be open at once; an earning already in a batch is never picked up by another.
- One line per driver, when **all** hold: her due net is above 0; her whole balance is positive
  (a driver who owes gets no payout — she settles); she has a payout method.
- **Line amount = the smaller of her due net and her whole balance.**
- No minimum amount. Transfer fees are ignored — the file carries the exact amount.
- Drivers left out are listed with the reason (owes SheDrive, no payout method).

**Batch statuses:** `Pending approval` → `Ready to export` → `Sent to bank` →
`Result pending approval` → `Completed`. A rejected batch is `Rejected` and its entries go
back to `Due`.

**Export file** (CSV, one row per line, all methods in one file):
`batch_ref, line_ref, national_id, driver_name, payout_type, provider_or_bank,
account_number, account_holder, amount_egp`. `payout_type` is `MOBILE_WALLET`,
`BANK_ACCOUNT` or `PREPAID_CARD`. Exporting sets the batch to *Sent to bank*; the file can be
downloaded again afterwards.

**Result file** (from Finance): the same rows plus `status` (`SUCCESS`/`FAILED`),
`bank_reference`, `failure_reason`. Matched on `line_ref`. Refused when a line is missing,
repeated or unknown, or a status is not one of the two values. Importing the same result twice
changes nothing (the `payout` entry is keyed on `line_ref`).

On approval: SUCCESS → `payout` entry (−amount, ref = bank reference), entries *Paid*, the
driver is notified. FAILED → entries back to *Due*, the driver's profile shows
*Last payout failed* with the reason, the driver is notified to check her payout method.

**Manual payout stays** for one-off cases (`payout` request, amount ≤ her balance). On approval
it marks her oldest due entries *Paid* up to the amount.

## 4. Settlement (money in)

**Settlement sheet** — we propose the template to Finance (CSV):
`national_id, driver_name, amount_egp, payment_date, payment_channel, payment_reference`.

The sheet lists **only payments that already went through** (changed 2026-10-14). Every row is
applied as paid:

- **Any amount.** Less than she owes settles part of it; more than she owes adds the extra to
  her balance, so SheDrive then owes her that amount.
- Each row shows her balance now, her balance after, and the outcome: *Settled in full*,
  *Part paid — still owes X*, or *Paid more — X added to her balance*. Two rows for the same
  driver apply one after the other.
- A row can't be applied only when its **national ID matches no driver**, or its
  **payment reference was already imported** (the same payment never posts twice). Those rows
  are not stored; Finance fixes them and sends them again.

The admin sends the rows that can be applied as one `settlement_import` request. On approval
each row posts a `settlement` entry with a receipt number (`S-nnnnn`), and her go-online block
lifts once she is under the limit.

The manual settlement on the driver ledger keeps its current rules and goes through approval.

## 5. Fee waiver

- An admin waives **one** rider cancellation fee, with a reason. No limit on amount or count.
- On approval: the rider ledger posts `fee_waived` (+fee) and the credited driver's ledger posts
  `fee_credit_reversed` (−fee). Both point to the original entry (`reversesEntryId`) — the
  ledger's first correction path. **Nothing is edited or deleted**: the original fee and credit
  stay in both ledgers with their amounts; the new entries cancel them.
- If the rider had already paid the fee, the waiver leaves her with a **credit** (positive
  balance). The credit is shown, not spent, in this phase.
- A waived fee shows *Waived*; a fee with a pending waiver can't be waived again.

## 6. Ledger additions

| Ledger | Entry type | Sign | Cause |
|---|---|---|---|
| Rider | `fee_waived` | + | Approved fee waiver |
| Driver | `fee_credit_reversed` | − | Approved fee waiver |
| Driver | `payout` (existing) | − | Now also posted by a SUCCESS result line, keyed `line_ref` |

## 7. Screens

New (three files each):

| App | Page | Purpose |
|---|---|---|
| Admin | `admin-v2/approvals.html` | Pending / Decided requests, before→after, approve or reject |
| Admin | `admin-v2/payouts.html` | Batches list, generate a batch (preview lines + skipped drivers) |
| Admin | `admin-v2/payout-batch.html` | Batch lines, export file, import result, per-line status |
| Admin | `admin-v2/settlement-imports.html` | Template, upload, per-row check, import history |
| Driver | `driver/payout-method.html` | View and change her payout method |

Edited: admin-v2 `balances`, `rider-balances`, `driver-profile`, `driver-application`,
`pricing-zones`, `pricing-policies`, `audit-log`, side nav (Approvals with pending count,
Payouts, Settlement imports); driver `onboarding` (step 7), `my-profile`, `balance`, `settle`,
notifications; rider `payments`.

`admin/` (v1) is not changed — same precedent as the financial core (admin-v2 `DESIGN-PORT.md`).

**Demo only:** the mockup has one signed-in admin, so the Approvals screen offers
*Act as another admin* to show the checker side. A real deployment has no such switch.
