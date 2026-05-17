# SheDrive – Business Requirements Document

**Project:** SheDrive
**Version:** 0.2 (Draft)
**Date:** 20/04/2026
**Status:** Draft for Review

---

# 1. Document Control

## 1.1 Document Purpose

This Business Requirements Document (BRD) defines the business context, objectives, scope, stakeholders, and high-level functional expectations for the SheDrive platform — a women-only ride-hailing service designed for the Egyptian market. The document serves as the authoritative reference for stakeholders, decision-makers, and project teams to ensure shared understanding and alignment on business needs prior to High-Level Design (HLD), Low-Level Design (LLD), and implementation.

The BRD establishes:

- A common understanding of the business problem and proposed solution.
- The agreed scope, boundaries, and target users for the MVP.
- The business rules, scenarios, and process flows that the system must support.
- A foundation for downstream technical design, estimation, and delivery planning.
- A reference point for evaluating change requests and scope variations during execution.

This document is non-technical in nature. It does not specify system architecture, technology stack, integration mechanisms, or implementation details. These are addressed in the High-Level Design document.

## 1.2 Intended Audience

This BRD is intended for the following audiences:

- **Business Sponsor & Executive Leadership** — for approval, strategic alignment, and investment decisions.
- **Product & Business Stakeholders** — to validate the business problem, scope, and expected outcomes.
- **Operations & Compliance Teams** — to confirm operational and regulatory expectations are reflected.
- **Project Management** — for planning, scheduling, and stakeholder coordination.
- **Engineering & Solution Architects** — as input for High-Level Design and technical decision-making.
- **Quality Assurance & Acceptance Teams** — as the basis for acceptance criteria and validation activities.
- **External Reviewers** — for legal, financial, or regulatory review where applicable.

## 1.3 Document Conventions

The following conventions are used throughout this document:

- **Shall / Must** — denotes a mandatory business requirement.
- **Should** — denotes a recommended requirement that may be negotiated.
- **May / Could** — denotes an optional or future-phase requirement.
- **MVP** — refers exclusively to the scope defined in 5.1.
- **Out-of-Scope** — refers to items explicitly excluded from MVP delivery (5.2).
- **Section references** use the format X.Y (e.g., 5.1).
- **Actor names** (Rider, Driver, Administrator, etc.) are capitalized when referring to defined system roles.
- All monetary values are expressed in Egyptian Pounds (EGP) unless otherwise stated.
- All times are expressed in local Egyptian time (EET / EEST).

## 1.4 Version History

| Version | Date  | Author        | Description                                                                                  |
|---------|-------|---------------|----------------------------------------------------------------------------------------------|
| 0.1     | 22/04/2026 | Mohamed Talaat – Senior Head of Engineering | Initial BRD.                                                                |
| 0.1     | 22/04/2026 | Abdelrahman Mamdouh | Updated Scope.                                                                |
                                                                          

## 1.5 Authors & Reviewers

**Authors**

- Abdelrahman Mamdouh, Senior Product Owner, ARCorp

**Reviewers**

| Name  | Role  | Organization | Review Scope |
|-------|-------|--------------|--------------|
| [TBD] | [TBD] | [TBD]        | [TBD]        |

## 1.6 Approval & Sign-off

This document requires formal approval before transitioning to High-Level Design. By signing below, approvers confirm that the business requirements, scope, rules, and scenarios described herein are accurate and complete to the best of their knowledge, and that delivery may proceed on this basis.

| Approver Name | Role                    | Date | Signature |
|---------------|-------------------------|------|-----------|
| [TBD]         | Business Sponsor        |      |           |
| [TBD]         | Product Owner           |      |           |
| [TBD]         | Head of Engineering     |      |           |

Subsequent material changes to the approved baseline are managed through a formal change request process and require re-approval by the original approvers or their delegates.

---

# 2. Executive Summary

## 2.1 Background

Urban mobility services have become essential in Egypt's major cities, with ride-hailing platforms serving millions of trips each month. Despite the maturity of this market, existing platforms are designed as general-purpose mobility services and are not specialized for the safety, trust, and cultural needs of women and families.

A meaningful segment of female passengers in Egypt expresses hesitation about using mixed-gender ride-hailing services — particularly during late hours, in unfamiliar areas, or when accompanied by children. These concerns are amplified by:

- Limited gender-specific eligibility controls.
- Inconsistent identity verification standards.
- Absence of dedicated child-friendly ride policies.
- Lack of transparent emergency handling procedures.

In parallel, many qualified Egyptian women are willing to participate in the ride-hailing economy as drivers but face the same gender-related concerns as riders, limiting supply on the driver side.

This combination — under-served female demand and constrained female supply — creates a clear and addressable market gap.

SheDrive is conceived as a women-only ride-hailing platform that addresses this gap directly. Both riders and drivers are women, children under the age of 12 are explicitly permitted under defined safety rules, and the platform supports both Arabic and English from launch.

The initial release is structured as a Minimum Viable Product (MVP) with full ride-cycle capabilities — sufficient to validate market demand, prove operational viability, and inform a phased growth plan. The MVP is targeted at a defined neighborhood-based footprint within **Greater Cairo (Cairo and Giza)** and supports both cash and digital payments to align with local market behavior. The platform launches with **daytime-only operating hours**; expansion to 24/7 operation is planned for a subsequent phase, contingent on safety performance and operational readiness.

## 2.2 Business Problem Statement

Existing ride-hailing platforms in Egypt do not adequately serve the safety, trust, and comfort expectations of women and families. The resulting gaps create both a user experience deficit and an underserved commercial opportunity.

**For female riders:**

- Personal safety concerns when riding alone, particularly outside daylight hours.
- Limited assurance regarding driver identity, eligibility, and conduct.
- No purpose-built support for traveling with young children.
- Lack of clear, immediate emergency mechanisms during trips.

**For female drivers:**

- Reluctance to operate within mixed-gender platforms.
- Concerns about rider conduct and safety incidents.
- Limited platforms that align with cultural and family expectations.

**For the business and the market:**

- Significant unmet demand among female passengers and families.
- Underutilized supply potential of qualified female drivers.
- Absence of standardized safety, identity, and child-ride policies in the local market.
- Limited operational visibility into trips, cancellations, and safety events on existing platforms.

A purpose-built, women-only mobility platform — with strict eligibility, identity assurance, child-ride support, dual payment rails, and operational accountability — addresses these gaps in a focused and commercially viable way.

## 2.3 Proposed Solution Overview

SheDrive is a women-only ride-hailing platform serving female riders and female drivers in Greater Cairo (Cairo and Giza), with explicit support for children under the age of 12 under defined safety and eligibility rules.

The MVP is structured around ten business modules covering the full ride cycle:

1. **Rider App** — registration, booking, tracking, payment, safety, and feedback.
2. **Driver App** — onboarding, availability, ride handling, navigation, earnings, and safety.
3. **Admin & Operations Portal** — back-office for ops, support, finance, and compliance.
4. **Identity & Verification** — KYC, document validation, and background checks.
5. **Payments (Cash + Digital)** — dual payment rails with cash reconciliation.
6. **Trip & Dispatch Engine** — matching, lifecycle, and real-time location.
7. **Pricing & Neighborhood Zones** — polygon-based zone configuration and per-zone fare rules.
8. **Safety & SOS** — emergency response, live trip sharing, and incident management.
9. **Notifications** — SMS, push, in-app, and email communications.
10. **Reporting & Analytics** — operational dashboards and management reporting.

The platform is delivered on three primary surfaces:

- A native **Rider mobile application**.
- A native **Driver mobile application**.
- A web-based **Administration & Operations portal**.

The MVP is positioned as a market-validation release: full enough to support real daily operations, intentionally constrained enough to deliver and learn. Drivers operate their own vehicles (the platform does not provide a fleet), and the platform runs within a daytime-only operating window at launch. More advanced capabilities — including extended ride types, automated payouts, advanced analytics, 24/7 operation, and broader geographic expansion — are deferred to subsequent phases.

## 2.4 Expected Benefits

### 2.4.1 Benefits for Riders

- A dedicated, women-only environment that addresses cultural and safety expectations.
- Clear, enforceable identity and eligibility rules for drivers.
- Purpose-built support for traveling with children under 12.
- Transparent ride status, fare breakdown, and emergency mechanisms.
- Choice of payment method (cash or digital) aligned with local preferences.

### 2.4.2 Benefits for Drivers

- A trusted, female-only working environment with reduced exposure to mixed-gender risks.
- Clearly defined onboarding, eligibility, and ride rules.
- Transparent earnings, commission, and cash settlement processes.
- Tools and protocols that prioritize driver safety on equal footing with rider safety.
- A practical participation path for women who would otherwise stay outside the ride-hailing economy.

### 2.4.3 Benefits for Operations & Administration

- Centralized visibility into riders, drivers, active trips, and incidents.
- Standardized handling of cancellations, safety events, and disputes.
- Configurable pricing and cancellation rules at the neighborhood level.
- Reduced operational ambiguity through clearly defined business rules.
- Faster, auditable response to incidents and exceptions.

### 2.4.4 Benefits for Management & Decision-Makers

- Foundational reporting to monitor operational health and safety performance.
- Insight into demand patterns by neighborhood and time of day.
- Clear basis for evaluating MVP success and planning subsequent phases.
- A controlled environment to test business model assumptions before broader investment.

### 2.4.5 Business & Market Benefits

- Differentiated positioning in a crowded ride-hailing market.
- Access to underserved demand and supply segments.
- Brand trust as a structural advantage rather than a marketing claim.
- A controlled, measurable MVP launch with manageable risk.
- A platform foundation that scales to broader geographies and capabilities.

## 2.5 High-Level Out-of-Scope

To preserve focus and a deliverable timeline, the following items are explicitly excluded from the MVP and may be considered in subsequent phases:

- Ride pooling, shared rides, scheduled rides, and recurring rides.
- Intercity, long-distance, hourly, and rental ride models.
- Multiple service tiers (e.g., economy, premium, family-plus).
- In-app rider or driver wallets.
- Automated driver payouts and settlement.
- Promotional codes, discounts, referrals, and loyalty programs.
- Corporate, enterprise, and family / multi-user accounts.
- Subscription pricing models.
- AI-driven safety scoring, behavioral analytics, and predictive modeling.
- In-trip audio or video recording.
- Full Business Intelligence (BI) platform and ad-hoc analytical dashboards.
- Marketing campaign management tools.
- Dispatcher / call-center based booking.
- Multi-country or multi-currency operation.
- 24/7 operation (deferred to a subsequent phase).
- Platform-supplied or platform-leased driver vehicles.

A more detailed in-scope and out-of-scope breakdown is provided in 5.

---

# 3. Glossary & Definitions

## 3.1 Business Terms

| Term                       | Definition                                                                                                              |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------|
| Active Ride                | A ride that has been requested and is in any state prior to completion or cancellation.                                 |
| Booking                    | The act of submitting a ride request through the Rider App.                                                             |
| Cancellation               | Termination of a ride before completion, initiated by either Rider or Driver.                                           |
| Cancellation Fee           | A charge applied to the cancelling party based on configured cancellation rules.                                        |
| Cash Trip                  | A trip where the rider has selected cash as the payment method.                                                         |
| Child-Accompanied Ride     | A ride during which one or more children under 12 travel with the rider.                                                |
| Commission                 | The percentage of trip fare retained by the platform from the driver's earnings.                                        |
| Digital Trip               | A trip where the rider has selected digital (card) as the payment method.                                               |
| Driver Settlement          | The process by which drivers transfer cash owed to the platform from cash trips.                                        |
| Eligibility                | The conditions a user must meet to register and operate as a Rider or Driver.                                           |
| Fare                       | The total amount charged to the rider for a completed trip.                                                             |
| Greater Cairo              | The combined metropolitan area of Cairo and Giza, comprising the MVP launch geography.                                  |
| Identity Verification      | The process of validating a user's identity using national ID and biometric checks.                                     |
| Incident                   | A logged event requiring operational review (SOS trigger, dispute, complaint, etc.).                                    |
| MVP                        | Minimum Viable Product — the initial release scope defined in 5.1.                                                     |
| Neighborhood / Zone        | A defined geographic polygon used for driver eligibility and pricing configuration.                                     |
| Onboarding                 | The end-to-end process from driver registration through approval and activation.                                        |
| Operating Hours            | The defined daily window during which the platform accepts ride requests; daytime-only at MVP launch.                   |
| Ride                       | A single end-to-end transaction from request to completion or cancellation.                                             |
| Ride Request               | A submission by a rider seeking driver assignment.                                                                      |
| SOS                        | An emergency alert triggered by a Rider or Driver during an active trip.                                                |
| Trip                       | A ride that has progressed to or beyond the "Trip Started" lifecycle state.                                             |
| Trusted Contact            | A person nominated by a Rider to receive trip sharing and SOS notifications.                                            |
| Vehicle Eligibility        | The platform-defined criteria a driver-owned vehicle must satisfy to be approved for use on the platform.               |
| Working Zone               | A neighborhood selected by a driver as eligible for receiving ride requests.                                            |

## 3.2 Acronyms & Abbreviations

| Acronym | Definition                                                          |
|---------|---------------------------------------------------------------------|
| API     | Application Programming Interface                                   |
| APNS    | Apple Push Notification Service                                     |
| AR / EN | Arabic / English                                                    |
| BRD     | Business Requirements Document                                      |
| EGP     | Egyptian Pound                                                      |
| ETA     | Estimated Time of Arrival                                           |
| FCM     | Firebase Cloud Messaging                                            |
| GPS     | Global Positioning System                                           |
| HLD     | High-Level Design                                                   |
| ID      | Identification (specifically National ID in this document)          |
| KYC     | Know Your Customer                                                  |
| MVP     | Minimum Viable Product                                              |
| OCR     | Optical Character Recognition                                       |
| OTP     | One-Time Password                                                   |
| PSP     | Payment Service Provider                                            |
| RBAC    | Role-Based Access Control                                           |
| RTL     | Right-to-Left (text direction, applicable to Arabic)                |
| SLA     | Service Level Agreement                                             |
| SMS     | Short Message Service                                               |
| SOS     | Emergency distress signal feature                                   |
| T&Cs    | Terms & Conditions                                                  |
| UI / UX | User Interface / User Experience                                    |
| 2FA     | Two-Factor Authentication                                           |

## 3.3 Actor Definitions

| Actor                            | Definition                                                                                                                    |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Rider                            | A verified female user who requests and consumes rides via the Rider App. May travel alone or with children under 12.         |
| Driver                           | A verified, approved female user who provides rides via the Driver App using her own vehicle. Has completed identity, license, vehicle, and background verification. |
| Administrator                    | An authorized back-office user who manages riders, drivers, rides, and configurations through the Admin Portal.               |
| Operations Supervisor            | A senior operational role responsible for incident handling, escalation oversight, and service quality.                       |
| Customer Support Agent           | A back-office user who handles user inquiries, disputes, and incident follow-ups.                                             |
| Finance User                     | A back-office user responsible for payment reconciliation, settlement tracking, and financial reporting.                      |
| Compliance User                  | A back-office user responsible for verification audits, regulatory adherence, and policy enforcement.                         |
| Management User                  | A stakeholder with read-only access to operational and decision-support reports.                                              |
| Trusted Contact                  | An external individual nominated by a Rider to receive trip-sharing links and SOS notifications.                              |
| Payment Service Provider (PSP)   | An external party that processes digital payment transactions.                                                                |
| Identity Verification Provider   | An external party providing OCR, liveness detection, and face-matching services.                                              |
| Maps & Location Provider         | An external party providing mapping, geocoding, and routing services.                                                         |
| Notification Provider            | An external party delivering SMS, push, and email messages.                                                                   |
| Background Check Provider        | An external party performing criminal record and traffic violation history checks for driver onboarding.                       |

---

# 4. Project Overview

## 4.1 Project Vision

To establish the most trusted mobility platform for women and families in Egypt by combining a women-only ecosystem, rigorous safety standards, and culturally aligned service design — and to use the Greater Cairo MVP as the foundation for a sustainable, multi-city presence over time.

## 4.2 Project Objectives

The MVP is structured to deliver against the following objectives:

- Establish a women-only mobility platform with enforceable eligibility and identity rules for both riders and drivers.
- Enable a complete ride cycle from request to payment, supporting both cash and digital methods to align with local market behavior.
- Operationalize safety as a core capability — including identity verification, SOS workflows, and incident management — as first-class features rather than add-ons.
- Support child-accompanied rides under defined safety and eligibility rules, addressing a clear underserved use case.
- Support female driver participation through a trusted onboarding process, transparent earnings, and protective in-trip features.
- Deliver operational visibility and control to ops, support, finance, and compliance teams via a unified back-office portal.
- Validate business assumptions about demand, supply, pricing, and cancellation behavior in a controlled neighborhood-based footprint within Greater Cairo.
- Lay a foundation for phased growth — including 24/7 operation and additional cities — without re-engineering core capabilities.

## 4.3 Stakeholders & Actors

### 4.3.1 Internal Stakeholders

- **Business Sponsor / Executive Leadership** — accountable for funding, strategic alignment, and final approvals.
- **Product Owner** — accountable for scope, priorities, and ongoing requirement decisions.
- **Operations Management** — accountable for daily platform operations, incident handling, and service continuity.
- **Customer Support Team** — handles user inquiries, complaints, and follow-ups on incidents and disputes.
- **Finance & Accounting** — responsible for payment reconciliation, cash settlement oversight, and financial reporting.
- **Compliance & Legal** — responsible for regulatory adherence, data protection, and policy review.
- **Engineering & Delivery Team** — responsible for design, build, test, and deployment of the platform.
- **Marketing & Growth** — responsible for user acquisition, brand positioning, and launch communications.

### 4.3.2 Primary Users

- **Female Riders** — registered female users using the Rider App. May travel alone or accompanied by children under 12. Subject to identity verification before first trip.
- **Female Drivers** — registered, verified, and admin-approved female users providing rides through the Driver App using their own vehicles. Subject to identity, license, vehicle, and background verification.
- **Administrators & Operations Users** — back-office users managing platform activities through the Admin Portal, with role-based permissions.
- **Management Users** — stakeholders with read-only access to operational dashboards and management reports.

### 4.3.3 External Service Providers

- **Payment Service Provider (PSP)** — processes digital card payments, returns transaction status, and supports manual refunds.
- **Identity Verification Provider** — supports automated ID OCR, liveness detection, and face matching.
- **Maps & Location Provider** — provides mapping, geocoding, routing, distance, and ETA calculations.
- **Notification Provider** — delivers SMS messages, push notifications, and emails.
- **Background Check Provider** — supports criminal record and traffic violation history checks for driver onboarding.
- **Regulatory Authorities (Indirect)** — Egyptian governmental and regulatory bodies whose rules govern transportation, data protection, and digital services.

## 4.4 Project Assumptions

The following assumptions form the basis of MVP planning and scope. Any change to these assumptions may require formal scope reassessment.

### 4.4.1 Business & Market

- The platform launches in Egypt as a single-country deployment.
- Initial geographic footprint is constrained to a defined set of neighborhoods within **Greater Cairo (Cairo and Giza)**, not a full city, governorate, or country rollout.
- The business model is per-ride transaction-based with platform commission on each trip; subscription and B2B models are out of scope for MVP.
- Demand exists in the targeted neighborhoods to support meaningful market validation within the MVP horizon.
- The platform launches with **daytime-only operating hours**. Expansion to 24/7 operation is planned for a subsequent phase, contingent on safety performance, operational maturity, and management approval.

### 4.4.2 Users & Identity

- Both Riders and Drivers must be female and at least 18 years old.
- Identity verification is mandatory before a user's first trip and includes national ID submission, live selfie capture, age check, and gender check.
- Drivers additionally require valid driving license verification, vehicle document verification, and background check before activation.
- **Drivers own and operate their own vehicles. The platform does not own, supply, lease, or maintain vehicles for drivers in the MVP. Each vehicle must satisfy platform-defined vehicle eligibility criteria.**
- User-provided identity information is assumed to be accurate and is subject to validation, manual review, and audit.
- Children under 12 may travel only when accompanied by a verified adult Rider, and must be declared at booking.

### 4.4.3 Payments & Financial

- Both cash and digital payment methods are supported from MVP launch.
- A single PSP integration is sufficient for MVP digital payments.
- Driver settlement (transfer of cash owed to platform) is an operational process; in-app automated payouts are out of scope for MVP.
- Pricing is configured centrally per neighborhood and applies prospectively.

### 4.4.4 Language & Localization

- The platform supports Arabic and English from launch.
- Arabic is the default language for end users, with full RTL support in both apps.
- Localization includes UI language, notification templates, and date/number formats.

### 4.4.5 Operations & Reporting

- Daily operations require live operational dashboards, queue management, and incident handling capabilities at MVP.
- Foundational management reporting is in scope; advanced analytics, BI, and predictive modeling are out of scope.
- Customer support operates through defined operational workflows rather than self-service automation.

### 4.4.6 Integrations & Dependencies

- External providers (PSP, identity verification, maps, notifications, background checks) are available and contractually engaged for the MVP timeline.
- External provider interfaces are stable and suitable for integration during the MVP.
- Regulatory requirements relevant to MVP (transportation, data protection, payments) remain stable during delivery.

## 4.5 Project Constraints

### 4.5.1 Scope & Delivery

- MVP scope is bounded by 5.1; any additions require formal change control.
- Implementation details (architecture, technology stack, deployment) are addressed in HLD, not in this document.

### 4.5.2 Market & Geographic

- Initial launch is constrained to Egypt only.
- Initial coverage is limited to a defined set of neighborhoods within **Greater Cairo (Cairo and Giza)**, with expansion to additional governorates or cities deferred to post-MVP phases.

### 4.5.3 User & Eligibility

- Access is restricted to verified female users aged 18 or above.
- Children under 12 may travel only as declared, accompanied passengers.
- Unverified users cannot complete trips.
- **Drivers must own and operate a vehicle that satisfies platform-defined vehicle eligibility criteria; the platform does not provide vehicles in the MVP.**

### 4.5.4 Payment & Financial

- A single PSP is supported in the MVP.
- Wallets, automated payouts, and complex refund automation are out of scope.
- Driver cash settlement is operationally supported but not automated end-to-end.

### 4.5.5 Operational & Reporting

- Operational dashboards are limited to MVP-defined views.
- Advanced analytics and BI are excluded from MVP delivery.

### 4.5.6 Regulatory & Compliance

- Platform operations must comply with applicable Egyptian transportation, data protection, and payment regulations.
- Material regulatory changes during delivery may impact scope or timeline.

### 4.5.7 Time & Resource

- Delivery is constrained by the agreed schedule and the resources committed to the project.
- External provider readiness directly affects integration and launch milestones.

### 4.5.8 Operating Hours

- The platform operates within a defined **daytime-only window at launch** (specific start and end hours to be confirmed by Operations and reflected in 8 Business Rules).
- 24/7 operation is **out of scope for the MVP** and is planned for a subsequent phase.
- New ride requests are not accepted outside the operating window. Behavior of trips spanning the end-of-day cutoff is governed by Business Rules in 8.

## 4.6 Dependencies

### 4.6.1 External Services

- **PSP availability** for digital payment processing, transaction confirmations, and refunds.
- **Identity verification provider** for OCR, liveness, and face matching.
- **Maps & location provider** for mapping, routing, and ETA.
- **Notification provider** for SMS, push, and email delivery.
- **Background check provider** for driver onboarding clearance.

### 4.6.2 Regulatory & Compliance

- Continued alignment with applicable Egyptian transportation, payment, and data protection regulations during delivery.

### 4.6.3 Business & Operational

- Timely approval of business rules — pricing, cancellation, eligibility, vehicle eligibility, operating hours, and safety procedures.
- Availability of operations resources for driver onboarding, incident handling, and customer support during pilot operations.
- Defined cash settlement process between drivers and the platform.

### 4.6.4 Stakeholder & Decision

- Timely approvals from business sponsor and product owner on scope, rules, and reporting.
- Alignment between business, operations, finance, and compliance functions on shared definitions and policies.

### 4.6.5 External Readiness

- App store review and publication readiness for both Rider and Driver apps.
- Executed legal agreements with all external service providers prior to integration milestones.

---

# 5. Business Scope

## 5.1 In-Scope for MVP

The following capabilities, organized by module, are included in the MVP delivery. Detailed feature definitions are provided in 7. The MVP operates within Greater Cairo (Cairo and Giza) and within a daytime-only operating window.

### 5.1.1 Rider App

Registration and identity verification, booking with map-based pickup and destination, fare estimate, child accompaniment declaration, payment method selection (cash/digital), real-time driver tracking, in-app communication, ride cancellation, fare display and payment, rating and feedback, trip history, language switching, live trip sharing, trusted contacts, and SOS.

### 5.1.2 Driver App

Registration, identity verification, license and vehicle document submission (driver-owned vehicle), background check consent, onboarding status tracking, online/offline toggle, working zone selection, ride request handling, navigation deep-linking, trip lifecycle management, ride cancellation, cash collection confirmation, digital payment status, earnings dashboard, cash balance tracking, rating, in-app communication, language switching, and SOS.

### 5.1.3 Admin & Operations Portal

2FA login, role-based access, live operational dashboard, driver onboarding queue and document review, rider and driver account management, live ride monitoring, ride detail and history, cancellation and incident management, SOS queue and escalation, neighborhood / zone management, pricing and cancellation rule configuration, commission configuration, cash reconciliation, manual refund processing, dispute management, audit logs, notification template management, and static content management.

### 5.1.4 Identity & Verification

National ID OCR, validity and duplicate checks, liveness detection, face matching, age and gender eligibility checks, driving license validation, vehicle document and eligibility verification, background check integration, and a manual review queue for edge cases.

### 5.1.5 Payments (Cash + Digital)

PSP integration, card tokenization and saved cards, payment authorization and capture, cash recording, driver cash balance ledger, commission calculation, cash settlement workflow, payment failure handling, manual refunds, receipt generation, cancellation fee calculation, and unresolved-failure ride blocking.

### 5.1.6 Trip & Dispatch Engine

Driver-rider matching, zone-aware eligibility filtering, ride broadcasting, acceptance handling, decline / timeout reassignment, ETA calculation, lifecycle state machine, real-time location streaming, geofence detection, no-driver-available retry queue, and operating-hours enforcement on new ride requests.

### 5.1.7 Pricing & Neighborhood Zones

Polygon-based zone definition, per-zone base fare, per-km and per-minute rates, minimum fare, zone-to-zone pricing rules, cancellation fee rules per zone, and pricing rule versioning.

### 5.1.8 Safety & SOS

SOS button (rider and driver), automated data capture on trigger, real-time alert to ops, response SLA tracking, defined escalation workflow, live trip sharing, trusted contacts, incident logging, post-incident follow-up, and women-only and age policy enforcement.

### 5.1.9 Notifications

SMS, push, in-app, and email channels with template management in Arabic and English, delivery tracking and retry, user preferences, and critical-alert priority handling.

### 5.1.10 Reporting & Analytics

Live operational dashboard, daily/weekly ride summaries, driver performance, cancellation analytics, payment reconciliation, safety incident reporting, zone performance, management KPI dashboard, and CSV/Excel export.

## 5.2 Out-of-Scope for MVP

The following are explicitly excluded from MVP delivery. Each item may be considered for subsequent phases subject to formal prioritization.

### 5.2.1 Service & Ride Variations

- Ride pooling or shared rides.
- Scheduled or recurring rides.
- Intercity, hourly, or rental ride models.
- Multiple service tiers (premium, family-plus, etc.).
- 24/7 operation.

### 5.2.2 Payment & Financial Capabilities

- In-app rider or driver wallets.
- Automated driver payouts and end-to-end settlement automation.
- Promotional codes, discounts, referrals, and loyalty programs.
- Multiple PSPs and advanced payment routing.
- Subscription pricing models.

### 5.2.3 Advanced User & Account Features

- Corporate, enterprise, or institutional accounts.
- Family or multi-user account management.
- Guardian dashboards and parental control panels.
- Subscription or membership tiers.

### 5.2.4 Advanced Safety & Intelligence

- AI-driven behavior monitoring and risk scoring.
- Predictive safety analytics.
- In-trip audio or video recording.
- Automated fraud detection beyond basic controls.

### 5.2.5 Analytics & BI

- Full Business Intelligence platform.
- Predictive analytics and demand forecasting.
- Custom or ad-hoc analytical dashboards.
- Cross-platform data warehousing.

### 5.2.6 Operations & Platform Extensions

- Dispatcher / call-center booking.
- Manual ride creation by administrators.
- Marketing campaign management tools.
- White-label or multi-brand support.
- Third-party marketplace integrations beyond core services.
- Platform-supplied or platform-leased driver vehicles.
- Vehicle fleet management.

### 5.2.7 Technical & Implementation

- System architecture, infrastructure design, technology stack selection.
- API design and integration mechanisms (covered in HLD).
- Deployment environments and DevOps processes.
- Performance optimization and scaling strategy.

> **Note:** Any capability not explicitly included in 5.1 is considered out of scope. Changes to scope are subject to formal change control and re-approval.

## 5.3 Target Users

### 5.3.1 Female Riders

- Female individuals aged 18 or above, eligible to use the Rider App.
- May travel alone or accompanied by children under 12 (declared at booking).
- Subject to identity verification before first trip.

### 5.3.2 Female Drivers

- Licensed female individuals aged 18 or above (or higher minimum age if defined by business policy).
- Subject to identity verification, driving license validation, vehicle document verification, and background check.
- **Own and operate their own vehicle, which must satisfy platform-defined vehicle eligibility criteria.**
- Operate under defined availability, safety, and service policies, including the platform's defined operating hours.
- Activated only after administrative approval.

### 5.3.3 Operations & Administration Users

- Authorized back-office staff with permissions assigned via RBAC.
- Includes Administrators, Operations Supervisors, Customer Support, Finance, and Compliance roles.

### 5.3.4 Management & Decision-Making Users

- Internal stakeholders with read-only access to operational and management reports.
- Responsible for performance monitoring and strategic oversight.

### 5.3.5 External Service Actors

- Third-party providers supporting payments, identity verification, mapping, notifications, and background checks.
- Engage with the platform through defined business interfaces and contractual agreements.


# 6. Solution Overview (Module Architecture)

## 6.1 Module Map

The SheDrive platform is structured around ten business modules organised into three logical layers:

**User-Facing Surfaces** — applications that platform users interact with directly:

- Rider App
- Driver App
- Admin & Operations Portal

**Domain Capabilities** — the business and operational engines that power user actions:

- Identity & Verification
- Payments (Cash + Digital)
- Trip & Dispatch Engine
- Pricing & Neighborhood Zones
- Safety & SOS

**Cross-Cutting Capabilities** — services that support all modules:

- Notifications
- Reporting & Analytics

| #   | Module                          | Layer                     | Primary Users                              |
|-----|---------------------------------|---------------------------|--------------------------------------------|
| 1   | Rider App                       | User-Facing Surface       | Female Riders                              |
| 2   | Driver App                      | User-Facing Surface       | Female Drivers                             |
| 3   | Admin & Operations Portal       | User-Facing Surface       | Administrators, Operations, Support, Finance, Compliance |
| 4   | Identity & Verification         | Domain Capability         | Riders, Drivers (during onboarding)        |
| 5   | Payments (Cash + Digital)       | Domain Capability         | Riders, Drivers, Finance                   |
| 6   | Trip & Dispatch Engine          | Domain Capability         | Riders, Drivers (system-driven)            |
| 7   | Pricing & Neighborhood Zones    | Domain Capability         | Administrators (configuration)             |
| 8   | Safety & SOS                    | Domain Capability         | Riders, Drivers, Operations                |
| 9   | Notifications                   | Cross-Cutting Capability  | All users                                   |
| 10  | Reporting & Analytics           | Cross-Cutting Capability  | Operations, Management                     |

## 6.2 Module Summaries

### 6.2.1 Rider App

The Rider App is the primary touchpoint for female riders, providing a complete journey from account registration through identity verification, ride booking, real-time tracking, in-trip communication, payment, feedback, and access to safety features. The app supports child accompaniment declaration, trusted contacts setup, and live trip sharing — all positioned around the platform's safety-first promise.

The Rider App interacts with Identity & Verification during onboarding, with the Trip & Dispatch Engine during the ride lifecycle, with Payments during fare settlement, with Safety & SOS during emergencies, and with Notifications throughout for real-time updates.

### 6.2.2 Driver App

The Driver App enables verified female drivers to manage their availability, accept and execute rides using their own vehicles, navigate to pickups and destinations, confirm cash collection, view earnings, and access safety features. The app guides drivers through a structured onboarding process — identity verification, driving license validation, vehicle document submission, vehicle photo upload, and background check — before activation.

The Driver App interacts with the Trip & Dispatch Engine for ride lifecycle, with Payments for commission and cash balance tracking, with Safety & SOS during emergencies, and with Notifications for ride and operational alerts.

### 6.2.3 Admin & Operations Portal

The Admin & Operations Portal is the back-office hub for managing the platform's daily operations. It provides differentiated access to Operations, Customer Support, Finance, and Compliance teams via role-based permissions. The portal supports driver onboarding approvals, rider and driver account management, live ride monitoring, cancellation and incident handling, SOS response, pricing and zone configuration, cash reconciliation, refunds, and audit oversight.

The Admin & Operations Portal depends on every other module for the data and operations it surfaces, and is the primary control surface for enforcing platform-wide business rules.

### 6.2.4 Identity & Verification

The Identity & Verification module is the platform's gatekeeper. It validates user identity through national ID OCR, liveness-detected selfie capture, face matching against the ID, age and gender eligibility checks, and — for drivers — driving license and vehicle document verification along with background checks. The module enforces the platform's women-only and age-eligibility rules and routes edge cases to a manual review queue.

The Identity & Verification module serves both the Rider and Driver Apps during onboarding and is governed by the Admin & Operations Portal for review and approval workflows.

### 6.2.5 Payments (Cash + Digital)

The Payments module handles all financial flows on the platform, supporting both cash and digital rails from launch. It integrates with a single Payment Service Provider for digital card transactions, manages card tokenisation and saved cards, authorises and captures fares, and records cash payments through dual rider/driver confirmation. It maintains driver cash ledgers, calculates commission, supports cash settlement workflows, processes manual refunds, and generates receipts.

The Payments module interacts closely with the Trip & Dispatch Engine for fare triggers and with the Admin & Operations Portal for reconciliation and dispute handling.

### 6.2.6 Trip & Dispatch Engine

The Trip & Dispatch Engine is the matching and lifecycle core of the platform. It receives ride requests from the Rider App, filters candidate drivers based on availability, working zone, and rating, broadcasts requests within a defined timeout, handles acceptance with atomic locking, and reassigns on decline or timeout. The engine maintains the trip state machine, streams driver location during active trips, calculates ETAs, and detects pickup and drop-off geofences.

The Trip & Dispatch Engine is central to the platform — every active ride flows through this module — and connects to Pricing for fare logic, to Payments for trigger events, to Notifications for status updates, and to Safety & SOS during emergencies.

### 6.2.7 Pricing & Neighborhood Zones

The Pricing & Neighborhood Zones module enables the platform to configure pricing at the granularity of individual neighborhoods within Greater Cairo. Administrators define zones as map polygons and configure base fare, per-kilometre and per-minute rates, minimum fare, zone-to-zone rules, and cancellation fees per zone. The module supports versioning of pricing rule changes for audit and rollback, and provides hooks for future peak-hour multipliers.

The Pricing & Neighborhood Zones module is consumed by the Trip & Dispatch Engine during fare estimation, by the Driver App for working zone selection, and by Payments during fare calculation.

### 6.2.8 Safety & SOS

The Safety & SOS module operationalises the platform's safety-first positioning as a first-class capability rather than a UI feature. It provides the SOS button surface in both apps, automated data capture on activation, real-time alert delivery to the Operations queue, response SLA tracking, defined escalation paths through to external authorities, live trip sharing with trusted contacts, incident logging, and post-incident follow-up. It also enforces the platform's women-only and age policies.

The Safety & SOS module receives triggers from both apps and integrates tightly with the Admin & Operations Portal for response and tracking.

### 6.2.9 Notifications

The Notifications module delivers all platform communications across SMS, push, in-app, and email channels. It supports template management in Arabic and English, delivery tracking with retry, user-level preferences for non-critical messages, and a critical-alert priority mode that bypasses quiet hours for SOS and safety messages.

Every other module produces notifications via this module, and SMS in particular is foundational from launch for OTP delivery during registration.

### 6.2.10 Reporting & Analytics

The Reporting & Analytics module provides foundational visibility for both daily operations and management decision-making. It includes a live operational dashboard, daily and weekly summaries, driver performance reports, cancellation analytics, payment reconciliation, safety incident reports, zone performance reports, and a management KPI view. It also supports CSV and Excel export.

The Reporting & Analytics module reads from every other module and outputs primarily to Operations and Management users via the Admin Portal.

## 6.3 Module Interaction Overview

At a high level, the modules interact as follows during a typical ride:

1. A Rider initiates registration via the Rider App. The Identity & Verification module validates her identity. The Notifications module delivers OTP and verification-status messages.
2. A Driver completes a similar onboarding flow with additional license, vehicle, and background check steps. The Admin & Operations Portal reviews and approves her account. Notifications keep her informed of progress.
3. The Rider submits a ride request through the Rider App. The Pricing & Neighborhood Zones module supplies the fare estimate based on the originating zone. The Trip & Dispatch Engine matches her with an eligible Driver, who accepts via her app.
4. The trip executes. The Trip & Dispatch Engine streams location to the Rider App and the Admin & Operations Portal. Notifications inform both parties of lifecycle events.
5. If safety is at risk, either party triggers SOS. The Safety & SOS module captures context, alerts Operations, tracks SLA, and supports escalation.
6. On trip completion, the Payments module triggers fare capture via the PSP for digital trips, or records cash payment via dual confirmation. Commission is calculated. The Driver's cash balance ledger updates.
7. All interactions feed into Reporting & Analytics for operational and management visibility.

The Admin & Operations Portal supervises the entire process, providing a unified view across modules and the controls needed to manage rides, drivers, riders, incidents, finances, and configuration.

---

# 7. Functional Requirements (MVP)

## 7.0 Reading Guide

Each functional requirement in this section is expressed as a single "shall" statement. Requirements are grouped by module and tagged with a unique identifier (e.g., `RA-001`) and a development priority from P1 to P4.

### Priority Definitions

| Priority | Meaning                  | Description                                                                                              |
|----------|--------------------------|----------------------------------------------------------------------------------------------------------|
| **P1**   | Foundation               | Foundational capabilities every other feature depends on (auth, identity core, RBAC, core data models, platform-wide policies). Built first. |
| **P2**   | Core Ride Cycle          | Minimum end-to-end ride loop: registration → onboarding → booking → matching → trip lifecycle → basic payment → basic SOS. Built second. |
| **P3**   | Operational Completeness | Everything required to run real operations: full payment flows, cancellations, full admin tools, notifications, basic reporting. Built third. |
| **P4**   | Polish                   | Nice-to-haves and edge cases: advanced reports, optional features, peak pricing, post-incident workflows. Built last. |

### Priority Distribution

| Priority | Count | % of Total |
|----------|-------|------------|
| P1       | 28    | 18%        |
| P2       | 56    | 37%        |
| P3       | 53    | 35%        |
| P4       | 15    | 10%        |
| **Total**| **152** | **100%** |

---

## 7.1 Rider App

The Rider App provides female riders with the complete journey from registration through trip completion, including safety and payment features.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| RA-001  | Registration with mobile OTP              | The system shall allow Riders to register using an Egyptian mobile number, verified via a one-time SMS password.                                                                  | P1       |
| RA-002  | Login, logout & session management        | The system shall provide Riders with secure login, logout, and persistent session management with defined session expiry.                                                         | P1       |
| RA-003  | Profile management                        | The system shall allow Riders to view and edit their name, profile photo, email, and language preference.                                                                          | P1       |
| RA-004  | Emergency contacts management             | The system shall allow Riders to add, edit, and remove up to three trusted contacts, used for live trip sharing and SOS notifications.                                            | P3       |
| RA-005  | Identity verification (ID + live selfie)  | The system shall require Riders to complete identity verification (national ID front and back plus live selfie) before completing their first trip.                               | P1       |
| RA-006  | Map-based home screen                     | The system shall present Riders with a map-based home screen showing current location, recent destinations, and a primary call-to-action to request a ride.                       | P1       |
| RA-007  | Pickup location selection                 | The system shall allow Riders to set the pickup location via GPS auto-detection, manual map pin placement, or selection from saved places.                                        | P2       |
| RA-008  | Destination selection                     | The system shall allow Riders to set the destination by searching by name or address, placing a manual map pin, or selecting from saved places.                                   | P2       |
| RA-009  | Fare estimate before booking              | The system shall display an estimated fare and trip duration to the Rider before request submission, calculated using configured zone-based pricing rules.                        | P2       |
| RA-010  | Child accompaniment declaration           | The system shall require Riders to declare child accompaniment (count and approximate ages) for any ride involving children under 12 prior to ride request submission.            | P2       |
| RA-011  | Payment method selection                  | The system shall allow Riders to select between cash and digital (saved or new card) as the payment method for each ride.                                                          | P2       |
| RA-012  | Submit ride request                       | The system shall allow Riders to submit a ride request after confirming pickup, destination, payment method, and child accompaniment information.                                  | P2       |
| RA-013  | Driver matching status & wait screen      | The system shall display a "searching for driver" status to Riders during driver matching, with the option to cancel before driver assignment.                                    | P2       |
| RA-014  | Driver info card                          | The system shall display the assigned Driver's photo, name, vehicle make/model/colour, plate number, and average rating to the Rider upon assignment.                              | P2       |
| RA-015  | Real-time driver tracking on map          | The system shall provide Riders with real-time map tracking of the assigned Driver, with continuously updated estimated time of arrival.                                          | P2       |
| RA-016  | Trip status timeline                      | The system shall present Riders with a visual timeline showing trip progress through the states: assigned, driver arrived, trip started, and trip completed.                       | P2       |
| RA-017  | In-app text chat with driver              | The system shall provide Riders with limited in-app text messaging to the assigned Driver during the active ride, with messaging disabled after trip completion.                   | P3       |
| RA-018  | Call driver via masked number             | The system shall allow Riders to place voice calls to the assigned Driver via a masked-number proxy that protects both parties' personal phone numbers.                            | P3       |
| RA-019  | Live trip sharing with trusted contacts   | The system shall allow Riders to share a live trip status link with trusted contacts via SMS, displaying real-time location, ETA, and Driver information.                          | P3       |
| RA-020  | SOS button (in-trip)                      | The system shall provide Riders with an SOS button accessible during an active trip that triggers the safety alert workflow.                                                       | P2       |
| RA-021  | Cancel ride with reason                   | The system shall allow Riders to cancel a ride before trip completion, requiring selection of a reason from a predefined list, and shall display any applicable cancellation fee before confirmation. | P3       |
| RA-022  | Trip completion & fare breakdown          | The system shall display the final fare with itemised breakdown (base, distance, time, fees) to the Rider upon trip completion.                                                    | P2       |
| RA-023  | Cash payment confirmation flow            | The system shall require both Rider and Driver confirmation of cash payment for cash trips, closing the trip only upon dual confirmation.                                          | P2       |
| RA-024  | Digital payment processing flow           | The system shall capture authorised digital payment from the Rider's selected card upon trip completion and display the payment outcome to the Rider.                              | P2       |
| RA-025  | Rate driver + feedback                    | The system shall allow Riders to rate the Driver on a 1-to-5 scale and submit categorical tags and free-text feedback after trip completion.                                       | P3       |
| RA-026  | Trip history & receipts                   | The system shall provide Riders with a chronological list of past trips, including date, route, fare, payment method, and access to trip receipts.                                | P3       |
| RA-027  | Saved places                              | The system shall allow Riders to save home, work, and custom locations for quick selection during booking.                                                                         | P4       |
| RA-028  | Language switcher (AR/EN, RTL)            | The system shall allow Riders to switch the application language between Arabic (with full right-to-left support) and English, with the selection persisting across sessions.     | P1       |
| RA-029  | Help & support contact                    | The system shall provide Riders with access to in-app FAQs, a contact form, and direct contact channels to customer support.                                                       | P4       |

## 7.2 Driver App

The Driver App enables verified female drivers to onboard, manage availability, execute trips using their own vehicles, and access safety features.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| DA-001  | Registration with mobile OTP              | The system shall allow Drivers to register using an Egyptian mobile number, verified via a one-time SMS password.                                                                  | P1       |
| DA-002  | Login & session management                | The system shall provide Drivers with secure login, logout, and persistent session management with defined session expiry.                                                         | P1       |
| DA-003  | Profile management                        | The system shall allow Drivers to view and edit their name, profile photo, contact information, and language preference.                                                            | P1       |
| DA-004  | Identity verification (ID + live selfie)  | The system shall require Drivers to complete identity verification (national ID front and back plus live selfie) as part of onboarding.                                            | P1       |
| DA-005  | Driving license upload & validation       | The system shall require Drivers to upload front and back images of a valid Egyptian driving license, and shall validate format, expiry, and category as part of onboarding.       | P1       |
| DA-006  | Vehicle documents upload                  | The system shall require Drivers to upload current vehicle registration and valid insurance documents as part of onboarding.                                                       | P1       |
| DA-007  | Vehicle photo upload                      | The system shall require Drivers to upload exterior photographs of their vehicle so that Riders can visually identify the assigned vehicle.                                        | P2       |
| DA-008  | Background check consent flow             | The system shall require Drivers to acknowledge and consent to a background check before document review proceeds.                                                                | P2       |
| DA-009  | Onboarding status tracking                | The system shall display the current onboarding status to Drivers across each stage (documents submitted, under review, approved, or rejected).                                    | P2       |
| DA-010  | Online / offline toggle                   | The system shall provide Drivers with a single-tap toggle to switch between online (available) and offline (unavailable) status.                                                  | P2       |
| DA-011  | Working zone selection                    | The system shall allow Drivers to select one or more configured neighborhoods as their working zones for ride request eligibility.                                                | P2       |
| DA-012  | Incoming request popup with timer         | The system shall present incoming ride requests to available Drivers as a popup containing rider, route, and fare information, automatically dismissing after a defined timeout.   | P2       |
| DA-013  | Accept / decline ride request             | The system shall allow Drivers to accept or decline incoming ride requests within the timeout window, triggering reassignment upon decline or timeout.                            | P2       |
| DA-014  | Pickup navigation                         | The system shall provide Drivers with a deep link to a default mapping application for turn-by-turn navigation to the Rider's pickup location.                                    | P2       |
| DA-015  | Arrived at pickup confirmation            | The system shall allow Drivers to confirm arrival at the pickup location, triggering rider notification and starting the pickup wait window.                                       | P2       |
| DA-016  | Start trip                                | The system shall allow Drivers to start the trip after pickup, transitioning the trip lifecycle to "in progress" and initiating real-time location streaming.                      | P2       |
| DA-017  | In-trip navigation                        | The system shall provide Drivers with a deep link to a default mapping application for navigation to the destination during an active trip.                                       | P2       |
| DA-018  | Complete trip                             | The system shall allow Drivers to complete the trip upon reaching the destination, triggering fare calculation and payment processing.                                            | P2       |
| DA-019  | Cancel ride with reason                   | The system shall allow Drivers to cancel an assigned ride before trip completion, requiring a reason from a predefined list, with repeated cancellations flagged for review.      | P3       |
| DA-020  | Cash collection confirmation              | The system shall allow Drivers to confirm cash payment receipt for cash trips, matched against the Rider's confirmation to close the trip.                                         | P2       |
| DA-021  | Digital payment status visibility         | The system shall display the digital payment outcome to the Driver after trip completion.                                                                                          | P2       |
| DA-022  | Trip history list                         | The system shall provide Drivers with a chronological list of completed trips, including route, fare, and rider rating.                                                            | P3       |
| DA-023  | Earnings dashboard                        | The system shall provide Drivers with a daily, weekly, and per-trip earnings dashboard, including platform commission breakdown.                                                  | P3       |
| DA-024  | Cash owed to platform balance             | The system shall display a live balance of platform commission owed by the Driver from cash trips, with settlement reminders.                                                     | P3       |
| DA-025  | Rate rider + feedback                     | The system shall allow Drivers to rate the Rider on a 1-to-5 scale and submit categorical tags after trip completion.                                                              | P3       |
| DA-026  | SOS button (in-trip)                      | The system shall provide Drivers with an SOS button accessible during an active trip that triggers the safety alert workflow.                                                      | P2       |
| DA-027  | In-app chat with rider                    | The system shall provide Drivers with limited in-app text messaging to the assigned Rider during the active ride, with messaging disabled after trip completion.                   | P3       |
| DA-028  | Call rider via masked number              | The system shall allow Drivers to place voice calls to the assigned Rider via a masked-number proxy.                                                                               | P3       |
| DA-029  | Help & support contact                    | The system shall provide Drivers with access to in-app FAQs, a support form, and direct contact channels to customer support.                                                      | P4       |
| DA-030  | Language switcher (AR/EN)                 | The system shall allow Drivers to switch the application language between Arabic and English, with the selection persisting across sessions.                                       | P1       |

## 7.3 Admin & Operations Portal

The Admin & Operations Portal supports the Operations, Customer Support, Finance, and Compliance teams in running daily platform operations.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| AP-001  | Admin authentication with 2FA             | The system shall require Administrators to authenticate using credentials and a second factor (TOTP or SMS), with enforced session timeout.                                       | P1       |
| AP-002  | Role-based access control                 | The system shall enforce role-based access control across portal features and data, supporting roles including Administrator, Operations Supervisor, Customer Support, Finance, and Compliance. | P1       |
| AP-003  | Live operational dashboard                | The system shall provide Administrators with a live dashboard displaying key operational indicators, including active rides, online drivers, open SOS events, and payment failures. | P3       |
| AP-004  | Driver onboarding queue                   | The system shall present Administrators with a queue of Drivers awaiting review, with filtering by status, working zone, and submission date.                                     | P2       |
| AP-005  | Driver document review                    | The system shall allow Administrators to inspect submitted Driver identity, license, and vehicle documents and to approve or reject onboarding with a captured reason.            | P2       |
| AP-006  | Driver account management                 | The system shall allow Administrators to activate, suspend, or deactivate Driver accounts, with each action recorded in the audit trail.                                          | P2       |
| AP-007  | Rider account management                  | The system shall allow Administrators to search, view, suspend, or block Rider accounts, including viewing trip history.                                                          | P3       |
| AP-008  | Live ride monitoring map                  | The system shall provide Administrators with a real-time map of all active rides, with filtering by zone, status, or driver.                                                      | P3       |
| AP-009  | Active rides list with filters            | The system shall provide Administrators with a tabular view of active rides, with filters for zone, status, payment method, and child accompaniment.                              | P3       |
| AP-010  | Ride detail view                          | The system shall provide Administrators with a complete trip-detail view, including event timeline, location trail, payment, and communication log.                               | P3       |
| AP-011  | Cancellation review queue                 | The system shall provide Administrators with a list of recent cancellations and their reasons, and shall flag accounts exhibiting abnormal cancellation patterns.                  | P3       |
| AP-012  | Incident management workflow              | The system shall allow Administrators to log incidents linked to specific rides or users, assign owners, track resolution, and close incidents with notes.                        | P3       |
| AP-013  | SOS alerts queue with response actions    | The system shall provide Administrators with a live queue of active SOS alerts, with one-click response actions including calling Rider, calling Driver, and triggering escalation. | P2       |
| AP-014  | SOS escalation workflow                   | The system shall enforce a defined escalation path for SOS incidents (Operations → Supervisor → External Authority) with time-based triggers.                                      | P3       |
| AP-015  | Neighborhood / zone management            | The system shall allow Administrators to define neighborhood polygons on a map and to activate, deactivate, or edit zone boundaries.                                              | P1       |
| AP-016  | Pricing configuration per zone            | The system shall allow Administrators to configure base fare, per-kilometre and per-minute rates, minimum fare, and zone-pair pricing rules per zone.                             | P2       |
| AP-017  | Cancellation rule configuration           | The system shall allow Administrators to configure cancellation time windows and applicable fees, globally or per zone.                                                            | P3       |
| AP-018  | Commission rate configuration             | The system shall allow Administrators to configure platform commission percentages globally or per zone, with effective-date scheduling.                                          | P2       |
| AP-019  | Cash reconciliation dashboard             | The system shall provide Administrators with an aggregate view of cash owed by Drivers versus cash settled, including identification of overdue settlements.                       | P3       |
| AP-020  | Driver cash balance tracking              | The system shall provide a per-Driver ledger of cash trips, commission accrued, and settlement history.                                                                            | P3       |
| AP-021  | Manual refund processing                  | The system shall allow Administrators to issue manual refunds for digital trips, with reason captured for audit.                                                                   | P4       |
| AP-022  | Dispute management workflow               | The system shall allow Administrators to log payment-related disputes, track status through resolution, and attach supporting evidence.                                            | P4       |
| AP-023  | Audit logs viewer                         | The system shall provide a searchable log of all administrative actions, including approvals, suspensions, configuration changes, and refunds.                                    | P3       |
| AP-024  | Notification template management          | The system shall allow authorised Administrators to edit SMS, push, email, and in-app notification templates per language without code deployment.                                | P4       |
| AP-025  | Static content management                 | The system shall allow Administrators to manage Terms & Conditions, privacy policy, and FAQ content shown in the apps without code deployment.                                    | P3       |

## 7.4 Identity & Verification

The Identity & Verification module is the platform's gatekeeper for both Riders and Drivers.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| IV-001  | National ID OCR & data extraction              | The system shall extract name, ID number, date of birth, and gender from submitted national ID images via Optical Character Recognition.                                          | P1       |
| IV-002  | National ID validity & duplicate checks        | The system shall validate the national ID number format, check expiry, and detect duplicate registrations across user accounts.                                                   | P1       |
| IV-003  | Liveness detection during selfie capture       | The system shall apply anti-spoofing checks during selfie capture, including motion or vendor-defined liveness validations.                                                       | P1       |
| IV-004  | Face matching (ID vs live selfie)              | The system shall compare the photo on the submitted national ID with the live selfie and produce a confidence score evaluated against a defined threshold.                        | P1       |
| IV-005  | Age eligibility check                          | The system shall calculate the user's age from the national ID date of birth and reject registrations of users below 18 years of age.                                              | P1       |
| IV-006  | Gender verification                            | The system shall extract gender from the national ID and reject registrations from non-female users to enforce the platform's women-only policy.                                  | P1       |
| IV-007  | Driving license validation                     | The system shall validate Drivers' submitted driving license images for format, expiry, and category.                                                                              | P2       |
| IV-008  | Vehicle document verification                  | The system shall verify that submitted vehicle registration documents match the Driver and that the insurance document is currently valid.                                         | P2       |
| IV-009  | Background check integration                   | The system shall submit Driver data to the configured background check provider and capture the resulting clearance for Driver onboarding.                                        | P3       |
| IV-010  | Manual review queue                            | The system shall route verification edge cases (low OCR confidence, low face-match score) to a queue for human review.                                                            | P3       |

## 7.5 Payments (Cash + Digital)

The Payments module handles all financial flows for both cash and digital rails.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| PY-001  | PSP integration                           | The system shall integrate with the configured Payment Service Provider for processing card payments, tokenisation, and refunds.                                                  | P1       |
| PY-002  | Card tokenization & saved cards           | The system shall securely tokenise Rider card details via the PSP and allow Riders to save cards for use in future trips.                                                          | P1       |
| PY-003  | Payment authorization on trip start       | The system shall pre-authorise the estimated fare amount on the Rider's payment method when the trip starts.                                                                      | P2       |
| PY-004  | Payment capture on trip completion        | The system shall capture the final fare amount after trip completion, supporting partial-capture scenarios.                                                                        | P2       |
| PY-005  | Cash payment recording                    | The system shall record cash trip payments based on dual confirmation from the Rider and Driver.                                                                                   | P2       |
| PY-006  | Driver cash balance ledger                | The system shall maintain a per-Driver ledger of cash trips, commission accrued, and amounts owed to the platform.                                                                | P3       |
| PY-007  | Commission calculation & deduction        | The system shall calculate platform commission for each completed trip and apply it to Driver earnings or cash balance.                                                            | P2       |
| PY-008  | Cash settlement workflow                  | The system shall support a defined workflow for Drivers to settle outstanding cash owed to the platform, including settlement events and confirmation.                            | P3       |
| PY-009  | Payment failure handling & retry          | The system shall detect payment failures, notify the Rider, and allow retry using the same or an alternative payment method.                                                       | P3       |
| PY-010  | Manual refund processing                  | The system shall provide back-office capability to issue manual refunds for digital trips, with audit trail and PSP reconciliation.                                                | P4       |
| PY-011  | Digital + cash receipt generation         | The system shall generate trip receipts for both cash and digital trips, viewable in-app and exportable.                                                                           | P3       |
| PY-012  | Cancellation fee calculation              | The system shall calculate cancellation fees based on configured zone-level rules and timing, and shall charge them via the active payment method.                                | P3       |
| PY-013  | Block new rides on unresolved failure     | The system shall prevent Riders from booking new rides while a previous payment failure remains unresolved.                                                                        | P3       |

## 7.6 Trip & Dispatch Engine

The Trip & Dispatch Engine governs matching, lifecycle, and real-time location.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| TD-001  | Driver-rider matching algorithm                | The system shall match each ride request to the most suitable eligible Driver based on proximity, working zone, and driver rating.                                                | P2       |
| TD-002  | Zone-aware driver eligibility filtering        | The system shall include only Drivers whose configured working zones encompass the pickup location in matching candidate sets.                                                     | P2       |
| TD-003  | Ride request broadcasting                      | The system shall broadcast ride requests to candidate Drivers, sequentially or in parallel, within a defined timeout window.                                                       | P2       |
| TD-004  | Driver acceptance handling                     | The system shall process Driver acceptance with an atomic lock to prevent multiple Drivers from being assigned to the same ride.                                                  | P2       |
| TD-005  | Decline / timeout reassignment logic           | The system shall re-broadcast a ride request to the next eligible Driver upon decline or response timeout.                                                                         | P2       |
| TD-006  | ETA calculation                                | The system shall calculate the Estimated Time of Arrival using the configured maps service and recalculate it as the Driver's location updates.                                   | P2       |
| TD-007  | Trip lifecycle state machine                   | The system shall enforce valid state transitions across the trip lifecycle: requested, assigned, arrived, started, completed, and cancelled.                                       | P1       |
| TD-008  | Real-time location streaming                   | The system shall stream the Driver's location during an active trip to the Rider App and the Operations portal.                                                                    | P2       |
| TD-009  | Geofence detection (pickup & drop-off)         | The system shall detect Driver entry into pickup and drop-off zones and trigger relevant lifecycle events.                                                                          | P2       |
| TD-010  | No-driver-available retry queue                | The system shall queue ride requests for re-broadcast with exponential backoff when no eligible Driver is available, notifying the Rider after a defined number of attempts.       | P3       |

## 7.7 Pricing & Neighborhood Zones

The Pricing & Neighborhood Zones module enables polygon-based zone configuration and per-zone fare rules.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| PZ-001  | Polygon-based neighborhood definition          | The system shall allow Administrators to define neighborhood boundaries as map polygons, persisted as geo-fences.                                                                 | P1       |
| PZ-002  | Per-zone base fare configuration               | The system shall allow Administrators to set a base fare per zone, applied to trips originating in that zone.                                                                     | P2       |
| PZ-003  | Per-km & per-minute rate configuration         | The system shall allow Administrators to set distance-based and duration-based rates per zone.                                                                                     | P2       |
| PZ-004  | Minimum fare per zone                          | The system shall allow Administrators to define a minimum fare per zone to ensure short trips remain commercially viable.                                                          | P2       |
| PZ-005  | Zone-to-zone pricing rules                     | The system shall support specific pricing rules for trips between defined zone pairs.                                                                                              | P3       |
| PZ-006  | Cancellation fee rules per zone                | The system shall allow Administrators to configure cancellation timing windows and fee amounts per zone.                                                                           | P3       |
| PZ-007  | Pricing rule versioning & history              | The system shall maintain a history of pricing rule changes with effective dates for audit and rollback purposes.                                                                  | P4       |
| PZ-008  | Peak-hour multiplier                           | The system shall optionally apply a configured multiplier to base pricing during defined peak hours per zone.                                                                      | P4       |

## 7.8 Safety & SOS

The Safety & SOS module operationalises the platform's safety-first positioning.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| SS-001  | SOS button (rider + driver)               | The system shall provide a single-tap SOS button visible during active trips in both the Rider and Driver applications.                                                            | P2       |
| SS-002  | Auto-data capture on SOS trigger          | The system shall, upon SOS activation, automatically capture the user's location, trip identifier, and the relevant Rider and Driver details.                                     | P2       |
| SS-003  | Real-time SOS alert to ops queue          | The system shall deliver SOS alerts in real time to the Operations SOS queue with full context and audible/visual notification on the operator side.                              | P2       |
| SS-004  | Ops response SLA tracking                 | The system shall measure the elapsed time from SOS activation to first operator action and alert when defined SLA thresholds are breached.                                        | P3       |
| SS-005  | Escalation workflow                       | The system shall enforce a defined SOS escalation path from initial responder, through supervisor, to external authority handoff, with prescribed scripts.                         | P3       |
| SS-006  | Live trip sharing (rider)                 | The system shall provide a shareable live link to a Rider's trip status, automatically delivered to Trusted Contacts on trip start or SOS activation.                              | P3       |
| SS-007  | Trusted contacts management               | The system shall allow Riders to maintain a list of up to three Trusted Contacts to be notified during live trip sharing or SOS activation.                                       | P3       |
| SS-008  | Incident logging & status tracking        | The system shall create an incident record for each SOS event and shall track its status through to resolution.                                                                    | P3       |
| SS-009  | Post-incident follow-up workflow          | The system shall support an operations-led post-incident follow-up process, including outcome capture and review notes.                                                            | P4       |
| SS-010  | Women-only & age policy enforcement       | The system shall enforce that all Riders and Drivers are female and at least 18 years of age across all platform interactions.                                                     | P1       |

## 7.9 Notifications

The Notifications module delivers all platform communications across channels.

| ID      | Feature                                       | Requirement                                                                                                                                                                       | Priority |
|---------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| NT-001  | SMS gateway integration                        | The system shall integrate with the configured SMS gateway for delivery of one-time passwords and critical alerts.                                                                | P1       |
| NT-002  | Push notification service (FCM / APNS)         | The system shall integrate with Firebase Cloud Messaging (Android) and Apple Push Notification Service (iOS) for push delivery, with managed device-token storage.                | P2       |
| NT-003  | In-app notification center                     | The system shall provide a persistent in-app inbox of recent notifications in the Rider, Driver, and Administrator applications.                                                  | P3       |
| NT-004  | Email notifications (admin / finance)          | The system shall support email delivery for administrative and finance notifications, including reconciliation summaries.                                                          | P3       |
| NT-005  | Notification template management (AR + EN)     | The system shall provide editable notification templates per channel and language, supporting variable substitution.                                                              | P4       |
| NT-006  | Delivery tracking & retry                      | The system shall track delivery status per notification and shall retry failed deliveries with backoff.                                                                            | P3       |
| NT-007  | Notification preferences per user              | The system shall allow users to set their preferences for non-critical notification channels; critical notifications shall always be delivered.                                    | P4       |
| NT-008  | Critical alert priority                        | The system shall ensure that SOS and other safety-related alerts bypass quiet hours and Do Not Disturb settings on user devices.                                                   | P3       |

## 7.10 Reporting & Analytics

The Reporting & Analytics module provides operational and management visibility.

| ID      | Feature                                  | Requirement                                                                                                                                                                       | Priority |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| RP-001  | Live operational dashboard                | The system shall provide a live operational dashboard showing active rides, online drivers, payment success rate, open SOS events, and cancellation rate.                         | P3       |
| RP-002  | Daily / weekly ride summary               | The system shall produce daily and weekly summary reports of trips, gross merchandise value, completion rate, and average fare, grouped by day, week, and zone.                   | P3       |
| RP-003  | Driver performance report                 | The system shall produce per-Driver performance reports including trips completed, earnings, cancellation rate, average rating, and hours online.                                 | P3       |
| RP-004  | Cancellation analytics report             | The system shall produce reports on cancellation reasons, timing patterns, and correlation with zones, Drivers, and Riders.                                                       | P3       |
| RP-005  | Payment reconciliation report             | The system shall produce a payment reconciliation report covering cash and digital splits, success and failure rates, and outstanding cash balances.                              | P3       |
| RP-006  | Safety incident report                    | The system shall produce safety incident reports including SOS counts, response times, escalation outcomes, and accounts with repeat incidents.                                    | P3       |
| RP-007  | Zone performance report                   | The system shall produce per-zone performance reports including trips, gross merchandise value, supply versus demand balance, and cancellation rate.                              | P4       |
| RP-008  | Management KPI dashboard                  | The system shall provide an executive-level KPI dashboard covering gross merchandise value, active users, retention, safety, and financial health.                                | P4       |
| RP-009  | CSV / Excel export                        | The system shall support exporting filtered data from any report to CSV or Microsoft Excel formats.                                                                                | P4       |


