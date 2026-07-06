# Driver App — Screen Tracker (design-story status)

Use this to update the **design user stories** in ADO (`SheDrive\Design Team`, under Epic **Driver App #1834**).

**Status legend**
- 🟢 **No comments** — the design matches the user stories; nothing to change.
- 💬 **Has comments** — discrepancies the designer must address (detail in [driver-app-design-discrepancies.md](driver-app-design-discrepancies.md)).
- ⬜ **Doesn't exist in the driver app** — no page for this screen in the mockup (`shedrive-web/driver/`) yet.

**Board status** column = the design story's current ADO board state (`New` = not yet designed in Figma · `Design Review` = delivered, in review).

Links open the work item in ADO.

| Screen | Design story | Board status | In mockup | Status & comments |
|---|---|---|---|---|
| Splash | [#1527](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1527) | Design Review | ⬜ none | ⬜ **Doesn't exist** — clean design, but no splash page in the mockup |
| Login | [#1435](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1435) | Design Review | `index.html` | 💬 add new-driver **register** path + post-OTP routing (new/pending/rejected/approved) |
| OTP | [#1437](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1437) | Design Review | `index.html` | 🟢 **No comments** |
| Onboarding wizard | [#1696](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1696) | New | `onboarding.html` | 💬 redesign to the **6-step** flow: Personal (typed NID + consent) → **National ID photos** → Vehicle details (**Make/Model dropdowns + Other**) → Documents (licence + registration, **not insurance**; also **licence number + licence expiry + registration expiry**) → **Vehicle photo (after docs)** → Selfie. **Driver min age = 18.** |
| Application Decision | [#1697](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1697) | New | `decision.html` | 🟢 **No comments** (approved + rejected both present) |
| Home | [#1438](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1438) | Design Review | `home.html` | 💬 remove the **offline "Nearby Requests" browse list** (dispatch is push, one at a time); `$`→**EGP**; "Performance"/"Daily Goal" are un-storied extras |
| Incoming Request | [#1698](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1698) | New | `request.html` | 💬 countdown should be **10s**; `$`→EGP |
| Active Trip (3 states) | [#1699](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1699) | New | `trip.html` | 💬 remove **Call/Chat** + **Safety Tools** (out of scope); add **"Open in external app"** button (first-trip female-verify gate is in scope) |
| Arrived at Destination | [#1748](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1748) | Design Review | `trip.html` (partial) | 💬 Safety Tools out of scope; currently folded into in-ride, not a distinct screen |
| Next Ride Opportunity | [#1794](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1794) | Design Review | ⬜ none | ⬜ **Doesn't exist** — and **no user story** (queued rides contradict the dispatch model → keep-or-cut decision) |
| Cancel Trip (reason + fee) | [#1850](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1850) | New | `trip.html` | 🟢 **No comments** (built to story) |
| Trip Completed | [#1751](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1751) | Design Review | `cash-collection.html` | 💬 show **net earnings** (not gross "Total Fare"); remove the rating stars; `$`→EGP |
| Cash Fare Collection | [#1700](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1700) | New | `cash-collection.html` | 🟢 **No comments** (net earnings, hidden commission) |
| Rating Passenger | [#1753](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1753) | Design Review | ⬜ none | ⬜ **Doesn't exist** — and **no user story** (driver-rates-passenger → keep-or-cut decision) |
| Earnings Breakdown | [#1701](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1701) | New | `earnings.html` | 🟢 **No comments** (acceptance-rate metric is a minor extra) |
| Cash Balance Owed | [#1851](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1851) | New | `balance.html` | 🟢 **No comments** (built to story) |
| Trip History | [#1702](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1702) | Design Review | `history.html` | 💬 show **net earnings** per trip; remove the Today/Week/Month tabs (belong to Earnings) |
| Past Trip Detail | [#1703](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1703) | New | `trip-detail.html` | 💬 show **net earnings**; remove the gross fare breakdown |
| Main Menu | [#1827](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1827) | Design Review | `profile.html` | 💬 trim out-of-scope items (Safety Center, Help/Support, Notifications); ensure **Balance** + **Profile** entries |

---

## Grouped for status updates

### 🟢 No comments — ready (6)
- [#1437 OTP](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1437)
- [#1697 Application Decision](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1697)
- [#1850 Cancel Trip (reason + fee)](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1850)
- [#1700 Cash Fare Collection](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1700)
- [#1701 Earnings Breakdown](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1701)
- [#1851 Cash Balance Owed](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1851)

### 💬 Has comments — needs revision (10)
- [#1435 Login](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1435)
- [#1696 Onboarding wizard](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1696)
- [#1438 Home](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1438)
- [#1698 Incoming Request](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1698)
- [#1699 Active Trip (3 states)](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1699)
- [#1748 Arrived at Destination](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1748)
- [#1751 Trip Completed](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1751)
- [#1702 Trip History](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1702)
- [#1703 Past Trip Detail](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1703)
- [#1827 Main Menu](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1827)

### ⬜ Doesn't exist in the driver app — no mockup page (3)
- [#1527 Splash](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1527)
- [#1794 Next Ride Opportunity](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1794) — also no user story
- [#1753 Rating Passenger](https://dev.azure.com/AR-corp/SheDrive/_backlogs/backlog/SheDrive%20Team/Epics?workitem=1753) — also no user story

---

## Notes
- **Closed duplicates** (already removed, ignore): #1704 New Request, #1706 Accept Request, #1709 Ride In Progress.
- **No dedicated design story yet** (covered inside others): the **first-trip female-verification gate** (part of Active Trip #1699), the **Application Rejected** variant (part of #1697), and the **National ID capture** screen (new dev story [#1854] — its design is part of Onboarding #1696).
- **"In mockup"** = the live page exists at `shedrive-web/driver/`; it does **not** mean the Figma design is done. The `New` board items have a built mockup + a written spec but the designer hasn't delivered the Figma screen yet.
