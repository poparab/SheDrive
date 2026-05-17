# 10. Diagrams

This section provides visual representations of the platform's architecture, primary user journeys, key business processes, and operational workflows. Each diagram complements — and does not replace — the textual specifications provided in earlier sections of this document. Where a diagram and the surrounding text appear to differ, the textual specifications and functional requirements (Section 7) take precedence.

The diagrams are organised as follows:

- **10.1 Module Interaction Diagram** — High-level view of the ten platform modules and how they relate across layers.
- **10.2 Use Case Diagram** — Primary actors and their core use cases, grouped by user type.
- **10.3 Rider Journey Flow** — End-to-end Rider experience from registration through trip completion.
- **10.4 Driver Onboarding Flow** — Driver journey from registration through approval and activation.
- **10.5 Trip Lifecycle State Diagram** — Valid trip states and transitions.
- **10.6 Dispatch & Matching Sequence** — Sequence of interactions during ride matching.
- **10.7 Payment Flow (Cash + Digital)** — Side-by-side handling of cash and digital payment rails.
- **10.8 SOS Escalation Flow** — Multi-tier escalation workflow with SLA gates.

All diagrams are maintained as Mermaid source alongside this document. To update any diagram, edit the Mermaid source block, re-render to PNG (e.g., via [mermaid.live](https://mermaid.live) or a local Mermaid CLI), and replace the corresponding image in the Word document.

---

## 10.1 Module Interaction Diagram

This diagram presents the SheDrive platform as three logical layers: User-Facing Surfaces (the apps and portal), Domain Capabilities (the business engines), and Cross-Cutting Capabilities (services that support all modules). User-facing surfaces consume the domain capabilities; domain capabilities emit events and data into the cross-cutting layer; and notifications also flow directly back to the user-facing surfaces.

This view aligns with the module structure defined in Section 6.1 and the interaction narrative in Section 6.3.

**Image:** `10-1-module-interaction.png`

**Mermaid source:**

```mermaid
flowchart TB
    subgraph UF["User-Facing Surfaces"]
        direction LR
        RA["Rider App"] ~~~ DA["Driver App"] ~~~ AP["Admin & Operations Portal"]
    end

    subgraph DC["Domain Capabilities"]
        direction LR
        IV["Identity &<br/>Verification"] ~~~ TD["Trip & Dispatch<br/>Engine"] ~~~ PY["Payments<br/>(Cash + Digital)"] ~~~ PZ["Pricing &<br/>Neighborhood Zones"] ~~~ SS["Safety & SOS"]
    end

    subgraph CC["Cross-Cutting Capabilities"]
        direction LR
        NT["Notifications"] ~~~ RP["Reporting & Analytics"]
    end

    UF ==>|"consume capabilities"| DC
    DC ==>|"emit events & data"| CC
    UF -.->|"deliver alerts"| CC

    classDef surface fill:#DBEAFE,stroke:#1E40AF,stroke-width:2px,color:#1E3A8A
    classDef domain fill:#FEF3C7,stroke:#B45309,stroke-width:2px,color:#78350F
    classDef cross fill:#DCFCE7,stroke:#15803D,stroke-width:2px,color:#14532D

    class RA,DA,AP surface
    class IV,TD,PY,PZ,SS domain
    class NT,RP cross
```

---

## 10.2 Use Case Diagram

This diagram organises the primary use cases of the SheDrive platform around three actor groups: Rider, Driver, and Back-Office users. Each use case is associated with the actor or actors who initiate it. External actors — Trusted Contacts, the Payment Service Provider, and the Identity Verification Provider — are shown with dashed connections to indicate that they participate in but do not initiate the corresponding use cases.

The use cases shown are illustrative of the platform's primary functional surface and are detailed exhaustively in Section 7. Some use cases (e.g., Register & Verify Identity, Trigger SOS) are reachable by both Rider and Driver actors and are shown in both swim-lanes.

**Image:** `10-2-use-cases.png`

**Mermaid source:**

```mermaid
flowchart TB
    subgraph TopRow[" "]
        direction LR
        subgraph RiderLane["Rider"]
            direction TB
            RiderActor(["Rider"])
            UC1(("Register & Verify<br/>Identity"))
            UC2(("Book Ride"))
            UC3(("Track Trip"))
            UC4(("Pay for Trip"))
            UC5(("Rate &<br/>Feedback"))
            UC6r(("Trigger SOS"))
            UC7(("Share Live Trip"))

            RiderActor --- UC1
            RiderActor --- UC2
            RiderActor --- UC3
            RiderActor --- UC4
            RiderActor --- UC5
            RiderActor --- UC6r
            RiderActor --- UC7
        end

        subgraph DriverLane["Driver"]
            direction TB
            DriverActor(["Driver"])
            UC1d(("Register & Verify<br/>Identity"))
            UC8(("Onboard as<br/>Driver"))
            UC9(("Accept / Decline<br/>Request"))
            UC10(("Execute Trip"))
            UC11(("View Earnings"))
            UC12(("Settle Cash"))
            UC6d(("Trigger SOS"))

            DriverActor --- UC1d
            DriverActor --- UC8
            DriverActor --- UC9
            DriverActor --- UC10
            DriverActor --- UC11
            DriverActor --- UC12
            DriverActor --- UC6d
        end
    end

    subgraph BackLane["Back-Office"]
        direction LR
        UC13(("Approve Drivers"))
        UC14(("Monitor Active<br/>Rides"))
        UC15(("Manage SOS<br/>Incidents"))
        UC16(("Configure Zones<br/>& Pricing"))
        UC17(("Reconcile<br/>Payments"))
        UC18(("View Reports"))

        AdminActor(["Administrator"])
        OpsActor(["Ops Supervisor"])
        SupportActor(["Customer Support"])
        FinanceActor(["Finance"])
        ComplianceActor(["Compliance"])
        MgmtActor(["Management"])

        AdminActor --- UC13
        AdminActor --- UC14
        AdminActor --- UC16
        ComplianceActor --- UC13
        OpsActor --- UC14
        OpsActor --- UC15
        SupportActor --- UC15
        FinanceActor --- UC17
        MgmtActor --- UC18
    end

    Trusted(["Trusted Contact"])
    PSP(["PSP"])
    IDV(["Identity Provider"])

    UC7 -.-> Trusted
    UC6r -.-> Trusted
    UC4 -.-> PSP
    UC1 -.-> IDV
    UC1d -.-> IDV

    classDef actor fill:#F3E8FF,stroke:#7C3AED,stroke-width:2px,color:#4C1D95
    classDef ext fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D
    classDef rideruc fill:#DBEAFE,stroke:#1E40AF,stroke-width:1px,color:#1E3A8A
    classDef driveruc fill:#FEF3C7,stroke:#B45309,stroke-width:1px,color:#78350F
    classDef backuc fill:#DCFCE7,stroke:#15803D,stroke-width:1px,color:#14532D

    class RiderActor,DriverActor,AdminActor,OpsActor,SupportActor,FinanceActor,ComplianceActor,MgmtActor actor
    class Trusted,PSP,IDV ext
    class UC1,UC2,UC3,UC4,UC5,UC6r,UC7 rideruc
    class UC1d,UC8,UC9,UC10,UC11,UC12,UC6d driveruc
    class UC13,UC14,UC15,UC16,UC17,UC18 backuc
```

---

## 10.3 Rider Journey Flow

This diagram presents the end-to-end experience of a Rider from initial registration through trip completion. It covers the three logical phases of the Rider experience: account creation and identity verification, booking and matching, and trip execution and settlement. Diamond-shaped nodes mark decision points (identity verification outcome, driver availability, payment method); rectangular nodes represent process steps.

The flow assumes a verified Rider operating within the platform's defined operating hours and within a configured neighborhood zone. Edge cases — payment failure, no driver available after retries, manual review queue — are visualised.

**Image:** `10-3-rider-journey.png`

**Mermaid source:**

```mermaid
flowchart TB
    Start([Start]) --> R1["Register with<br/>mobile + OTP"]
    R1 --> R2["Complete profile<br/>(name, photo, language)"]
    R2 --> R3["Submit National ID<br/>+ live selfie"]
    R3 --> R4{"Identity<br/>verified?"}
    R4 -->|No| R5["Manual review<br/>queue"]
    R5 --> R4
    R4 -->|Yes| R6["Account activated"]

    R6 --> B1["Open map &<br/>set pickup location"]
    B1 --> B2["Set destination"]
    B2 --> B3["Declare child<br/>accompaniment if any"]
    B3 --> B4["View fare estimate"]
    B4 --> B5["Select payment method<br/>(cash or digital)"]
    B5 --> B6["Submit ride request"]

    B6 --> M1["System matches<br/>eligible driver"]
    M1 --> M2{"Driver<br/>found?"}
    M2 -->|No| M3["Retry with backoff"]
    M3 --> M2
    M2 -->|Yes| M4["Driver assigned"]

    M4 --> T1["Track driver to<br/>pickup on map"]
    T1 --> T2["Driver arrives"]
    T2 --> T3["Trip starts"]
    T3 --> T4["Live tracking +<br/>shareable link"]
    T4 --> T5["Trip completes"]

    T5 --> P1{"Payment<br/>method?"}
    P1 -->|Cash| P2["Dual confirmation<br/>by Rider & Driver"]
    P1 -->|Digital| P3["Card capture<br/>via PSP"]
    P2 --> F1["Rate driver +<br/>submit feedback"]
    P3 --> F1
    F1 --> End([Trip closed])

    classDef start fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#14532D
    classDef process fill:#E8F4FD,stroke:#2563EB,stroke-width:1px,color:#1E3A8A
    classDef decision fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F
    classDef terminator fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D

    class Start,End start
    class R1,R2,R3,R5,R6,B1,B2,B3,B4,B5,B6,M1,M3,M4,T1,T2,T3,T4,T5,P2,P3,F1 process
    class R4,M2,P1 decision
```

---

## 10.4 Driver Onboarding Flow

This diagram covers the multi-stage Driver onboarding sequence: mobile registration, identity verification, driving license validation, vehicle document and photo submission, vehicle eligibility check, background check consent and clearance, and final administrative review. Any failed gate routes the Driver to onboarding rejection with a captured reason; only approved Drivers are activated and may select working zones to become matchable.

This flow reflects the requirements in Section 7.2 (Driver App) and Section 7.4 (Identity & Verification), plus the administrative review behaviours defined in Section 7.3.

**Image:** `10-4-driver-onboarding.png`

**Mermaid source:**

```mermaid
flowchart TB
    Start([Start]) --> S1["Register with<br/>mobile + OTP"]
    S1 --> S2["Submit profile<br/>information"]
    S2 --> S3["Submit National ID<br/>+ live selfie"]
    S3 --> S4{"Identity<br/>verified?"}
    S4 -->|No| Reject1["Onboarding<br/>rejected"]
    S4 -->|Yes| S5["Upload driving license<br/>(front + back)"]

    S5 --> S6{"License valid<br/>format & expiry?"}
    S6 -->|No| Reject1
    S6 -->|Yes| S7["Upload vehicle<br/>registration & insurance"]

    S7 --> S8["Upload vehicle<br/>exterior photos"]
    S8 --> S9{"Vehicle meets<br/>eligibility criteria?"}
    S9 -->|No| Reject1
    S9 -->|Yes| S10["Provide background<br/>check consent"]

    S10 --> S11["Background check<br/>submitted to provider"]
    S11 --> S12{"Background<br/>cleared?"}
    S12 -->|No| Reject1
    S12 -->|Yes| S13["Documents submitted<br/>for admin review"]

    S13 --> S14["Admin reviews<br/>full submission"]
    S14 --> S15{"Admin<br/>decision?"}
    S15 -->|Reject| Reject2["Rejected with<br/>captured reason"]
    S15 -->|Approve| S16["Account activated"]
    S16 --> S17["Driver selects<br/>working zones"]
    S17 --> S18["Driver goes online<br/>and is matchable"]
    S18 --> End([Active driver])

    Reject1 --> RejectEnd([Notified with reason])
    Reject2 --> RejectEnd

    classDef start fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#14532D
    classDef process fill:#E8F4FD,stroke:#2563EB,stroke-width:1px,color:#1E3A8A
    classDef decision fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F
    classDef reject fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D

    class Start,End start
    class S1,S2,S3,S5,S7,S8,S10,S11,S13,S14,S16,S17,S18 process
    class S4,S6,S9,S12,S15 decision
    class Reject1,Reject2,RejectEnd reject
```

---

## 10.5 Trip Lifecycle State Diagram

This diagram captures the valid trip states enforced by the Trip & Dispatch Engine (TD-007) and the legal transitions between them. A trip enters the "Requested" state when the Rider submits a ride request, progresses through matching, assignment, arrival, in-progress, and completion, or terminates in one of three cancellation states (cancelled by Rider, cancelled by Driver, or cancelled because no Driver was available).

Cancellation policy and applicable fees vary by zone configuration (Section 7.7) and trip state at the time of cancellation. Real-time location streaming and SOS availability apply during the In-Progress state. Trip completion triggers fare capture (digital) or dual cash confirmation (cash) and the rating flow.

**Image:** `10-5-trip-lifecycle.png`

**Mermaid source:**

```mermaid
stateDiagram-v2
    [*] --> Requested: Rider submits<br/>ride request

    Requested --> Searching: System begins<br/>matching
    Searching --> Assigned: Driver accepts
    Searching --> NoDriver: Timeout /<br/>no eligible driver
    NoDriver --> Searching: Retry with<br/>backoff
    NoDriver --> CancelledNoDriver: Max retries<br/>exceeded

    Requested --> CancelledByRider: Rider cancels<br/>before assignment
    Searching --> CancelledByRider: Rider cancels<br/>before assignment

    Assigned --> DriverArrived: Driver confirms<br/>arrival
    Assigned --> CancelledByRider: Rider cancels<br/>(fee may apply)
    Assigned --> CancelledByDriver: Driver cancels<br/>(reassignment)

    DriverArrived --> InProgress: Driver starts trip
    DriverArrived --> CancelledByRider: Rider cancels<br/>(fee may apply)
    DriverArrived --> CancelledByDriver: Driver cancels

    InProgress --> Completed: Driver completes<br/>at destination

    Completed --> [*]
    CancelledByRider --> [*]
    CancelledByDriver --> [*]
    CancelledNoDriver --> [*]

    note right of InProgress
        Real-time location streamed.
        SOS available to both parties.
    end note

    note right of Completed
        Triggers fare capture
        (digital) or dual confirmation
        (cash) and rating flow.
    end note
```

---

## 10.6 Dispatch & Matching Sequence

This diagram presents the sequence of interactions during ride matching, from the Rider's initial request submission through Driver assignment (or the no-driver-available case). It is intentionally aligned with the requirements in Section 7.6 (Trip & Dispatch Engine), including the broadcast-with-timeout pattern (TD-003), atomic acceptance (TD-004), decline/timeout reassignment (TD-005), and the no-driver-available retry queue (TD-010).

The Pricing & Neighborhood Zones module is consulted at fare-estimate time. The Notifications module is invoked at lifecycle transitions to keep both parties informed.

**Image:** `10-6-dispatch-sequence.png`

**Mermaid source:**

```mermaid
sequenceDiagram
    autonumber
    participant R as Rider
    participant RA as Rider App
    participant TD as Trip & Dispatch Engine
    participant PZ as Pricing & Zones
    participant DA as Driver App
    participant D as Driver
    participant N as Notifications

    R->>RA: Set pickup, destination,<br/>payment method, child decl.
    RA->>PZ: Request fare estimate<br/>for origin zone
    PZ-->>RA: Estimated fare + duration
    RA->>R: Show fare estimate
    R->>RA: Confirm & submit request
    RA->>TD: Submit ride request

    TD->>TD: Filter eligible drivers<br/>(zone, online, rating)
    TD->>TD: Rank by proximity

    loop Until accepted or exhausted
        TD->>DA: Broadcast request<br/>(timer starts)
        DA->>D: Show request popup<br/>with timer
        alt Driver accepts within timeout
            D->>DA: Tap Accept
            DA->>TD: Acceptance (atomic lock)
            TD-->>DA: Lock confirmed
            TD->>RA: Driver assigned
            RA->>R: Show driver info card
            TD->>N: Notify rider & driver
        else Driver declines or timeout
            DA->>TD: Decline / no response
            TD->>TD: Move to next driver
        end
    end

    alt No driver found after retries
        TD->>RA: No driver available
        RA->>R: Notify and offer retry
        TD->>N: Log event
    end
```

---

## 10.7 Payment Flow (Cash + Digital)

This diagram presents the two payment rails side-by-side. The Digital path uses pre-authorisation at trip start and capture at trip completion via the configured PSP, with explicit handling for capture failure (rider notified, future bookings blocked until resolved). The Cash path requires dual confirmation from both Rider and Driver at trip completion; mismatched confirmation routes the trip to the Operations dispute workflow. Both rails culminate in commission calculation and trip settlement.

This flow reflects the requirements in Section 7.5 (Payments). Refund handling and reconciliation views are managed through the Admin & Operations Portal (Section 7.3).

**Image:** `10-7-payment-flow.png`

**Mermaid source:**

```mermaid
flowchart TB
    Start(["Trip in progress"]) --> M{"Payment method<br/>selected at booking"}

    M -->|Digital| D1["Pre-authorise estimated<br/>fare on saved card"]
    D1 --> D2["Trip continues"]
    D2 --> D3["Trip completes —<br/>final fare calculated"]
    D3 --> D4["Capture final amount<br/>via PSP"]
    D4 --> D5{"Capture<br/>successful?"}
    D5 -->|Yes| D6["Receipt generated<br/>& sent to Rider"]
    D5 -->|No| D7["Mark payment failure"]
    D7 --> D8["Notify Rider — block<br/>future bookings until resolved"]
    D8 --> D9["Allow retry or<br/>alternative card"]
    D9 --> D5

    M -->|Cash| C1["No pre-auth required"]
    C1 --> C2["Trip continues"]
    C2 --> C3["Trip completes —<br/>final fare displayed"]
    C3 --> C4["Driver confirms<br/>cash received"]
    C3 --> C5["Rider confirms<br/>cash paid"]
    C4 --> C6{"Both<br/>confirmed?"}
    C5 --> C6
    C6 -->|Yes| C7["Trip closed"]
    C6 -->|No / dispute| C8["Routed to Ops<br/>dispute workflow"]
    C7 --> C9["Update Driver cash<br/>balance ledger"]
    C9 --> C10["Receipt generated"]

    D6 --> Comm["Calculate platform<br/>commission"]
    C10 --> Comm
    Comm --> EndOK(["Trip settled"])
    C8 --> EndDispute(["Dispute resolution"])

    classDef start fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#14532D
    classDef digital fill:#E8F4FD,stroke:#2563EB,stroke-width:1px,color:#1E3A8A
    classDef cash fill:#FEF3C7,stroke:#D97706,stroke-width:1px,color:#78350F
    classDef decision fill:#F3E8FF,stroke:#7C3AED,stroke-width:2px,color:#4C1D95
    classDef ending fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D

    class Start start
    class D1,D2,D3,D4,D6,D7,D8,D9 digital
    class C1,C2,C3,C4,C5,C7,C8,C9,C10 cash
    class M,D5,C6 decision
    class Comm digital
    class EndOK,EndDispute ending
```

---

## 10.8 SOS Escalation Flow

This diagram presents the three-tier SOS escalation workflow operationalised by the Safety & SOS module (Section 7.8). When SOS is triggered by either a Rider or a Driver during an active trip, the system auto-captures contextual data, alerts the Operations queue in real time, and notifies any configured Trusted Contacts with a live trip link. Tier 1 (operator), Tier 2 (supervisor), and Tier 3 (external authority handoff) are gated by SLA windows; failure to respond within an SLA, or unresolved situations, drive automatic escalation to the next tier. All incidents are logged, with a post-incident follow-up workflow supporting outcome capture and review notes.

The SLA durations themselves are platform parameters configured via the System Parameters Management capability described in Section 7.3.1.

**Image:** `10-8-sos-escalation.png`

**Mermaid source:**

```mermaid
flowchart TB
    Start(["SOS Triggered<br/>(Rider or Driver)"]) --> A1["Auto-capture context<br/>(location, trip ID,<br/>rider & driver details)"]
    A1 --> A2["Push real-time alert<br/>to Ops SOS queue"]
    A2 --> A3["Notify Trusted Contacts<br/>with live trip link"]
    A2 --> T1{"Tier 1: Operator<br/>responds within<br/>SLA?"}

    T1 -->|Yes| OP1["Operator contacts<br/>Rider and/or Driver"]
    T1 -->|No - SLA breach| ESC1["Auto-escalate<br/>to Supervisor"]

    OP1 --> R1{"Situation<br/>resolved?"}
    R1 -->|Yes| LOG1["Log incident outcome<br/>and close"]
    R1 -->|No| ESC1

    ESC1 --> T2{"Tier 2: Supervisor<br/>responds within<br/>SLA?"}
    T2 -->|Yes| OP2["Supervisor takes<br/>direct ownership"]
    T2 -->|No - SLA breach| ESC2["Escalate to External<br/>Authority handoff"]

    OP2 --> R2{"Situation<br/>resolved?"}
    R2 -->|Yes| LOG1
    R2 -->|No| ESC2

    ESC2 --> EXT["Tier 3: Hand off to<br/>external authority<br/>using prescribed script"]
    EXT --> LOG2["Log full incident<br/>including handoff"]

    LOG1 --> FU["Post-incident<br/>follow-up workflow"]
    LOG2 --> FU
    FU --> End(["Incident closed<br/>with review notes"])

    classDef start fill:#FEE2E2,stroke:#DC2626,stroke-width:3px,color:#7F1D1D
    classDef tier1 fill:#E8F4FD,stroke:#2563EB,stroke-width:1px,color:#1E3A8A
    classDef tier2 fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F
    classDef tier3 fill:#FCA5A5,stroke:#B91C1C,stroke-width:2px,color:#7F1D1D
    classDef decision fill:#F3E8FF,stroke:#7C3AED,stroke-width:2px,color:#4C1D95
    classDef ending fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#14532D

    class Start start
    class A1,A2,A3,OP1 tier1
    class ESC1,OP2 tier2
    class ESC2,EXT,LOG2 tier3
    class T1,T2,R1,R2 decision
    class LOG1,FU,End ending
```

---

## How to update these diagrams

Each diagram above is rendered from a single Mermaid code block. To update any diagram:

1. Edit the Mermaid source block for the relevant diagram (e.g., to add a node, change a label, adjust a connection).
2. Re-render the diagram to PNG using one of the following:
   - **Online:** paste the code block into [https://mermaid.live](https://mermaid.live) and download the PNG.
   - **Local CLI:** `mmdc -i diagram.mmd -o diagram.png -b white --scale 2`.
   - **VS Code:** install the "Markdown Preview Mermaid Support" extension and export from the preview.
3. Replace the corresponding image in the Word document.
4. Check the descriptive paragraph above the diagram for any text that also needs updating.

Mermaid syntax reference: [https://mermaid.js.org/intro/](https://mermaid.js.org/intro/)
