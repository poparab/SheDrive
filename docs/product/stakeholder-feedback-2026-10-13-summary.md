# Stakeholder requests — 2026-10-13 (summary for phasing)

Ten requests from the stakeholder meeting. **Phased 2026-10-13: Now = 5, 6a, 6b, 7, 8, 9;
Phase 2 = 1, 2, 3, 4, 10.** Size is a rough guess (S = days, M = 1–2 sprints, L = 3+ sprints, or
blocked by an external dependency). The full notes and open questions are in
[stakeholder-feedback-2026-10-13.md](stakeholder-feedback-2026-10-13.md).

| # | Request | In one line | Size | Depends on | Reverses an earlier decision? | Now / Phase 2 |
|---|---|---|---|---|---|---|
| 1 | Global price card | A zone with no price card uses the global one, instead of blocking trips | S | — | No | Phase 2 |
| 2 | Destination-zone pricing | The destination zone also affects the price, not only the pickup | M | 1; rule still to be defined | No | Phase 2 |
| 3 | Timed suspension | Suspend a rider or driver for N days; reinstated automatically | S | — | No | Phase 2 |
| 4 | Closed-loop rider wallet | Rider tops up a balance and pays trips from it | L | Payment integration, legal check (CBE) | Yes, wallet was out of scope (2026-09-10) | Phase 2 |
| 5 | Driver payout method | Driver picks mobile wallet, bank account or prepaid card at onboarding | M | — | Yes, payout details were removed (2026-09-17) | Now |
| 6a | Payout export | File for a bulk transfer through the bank portal | M | 5, 9, bank file template | No | Now |
| 6b | Settlement import | Upload Finance's sheet; matched drivers are marked settled | M | Sample sheet from Finance | No | Now |
| 7 | Maker-checker | Every finance action needs a second admin to approve it | M | — (6, 8, 4 use it) | No | Now |
| 8 | Waive one cancellation fee | Admin waives the fee on a specific rider cancellation | S | 7 | Yes, waives were removed (2026-09-17) | Now |
| 9 | 7-day settlement cycle | Daily export of transactions older than 7 days and not settled | M | 6a | No | Now |
| 10 | Scheduled rides | Book a ride up to 7 days ahead | L | — (stories already written, Phase 1.5) | Yes, moved out of Phase 1 | Phase 2 |

## Points to know before deciding

- **Items 5, 6a, 9 and 7 are one package.** The export needs the payout method and the 7-day
  rule, and every step needs maker-checker. Doing only part of the package gives Finance
  nothing they can use.
- **The wallet (4) is the largest item and is blocked from outside the team.** Card top-up
  waits on the payment integration, and legal should confirm the regulatory position first.
  The ledger was designed for platform-held money, so the accounting is ready for it once it
  is unblocked.
- **Scheduled rides (10) are already specified**, so restoring them is mostly build effort,
  not analysis.
- **1, 3 and 8 are small** and touch screens that already exist.
- **Still undefined:** the destination pricing rule (2), which actions count as "finance
  decisions" (7), and whether the 7-day rule (9) applies to payouts, settlements or both.
  These need a stakeholder answer before they can be built, whichever phase they go in.
