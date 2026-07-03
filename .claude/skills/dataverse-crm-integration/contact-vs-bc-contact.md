# Dataverse/D365 Sales **Contact** vs BC **Contact** (table 5050) — platform gap analysis

Platform-to-platform comparison of the Dataverse/Dynamics 365 Sales **`contact`** entity (table model +
model-driven forms + platform features) against BC's **Contact** table 5050, the **Contact Card** page 5050, and
its **Relationship Management (RM)** context (Contact Business Relation → Customer/Vendor/Bank). Purpose: decide
which Contact capabilities `native-bc-crm` should natively replicate. This is the **Contact ↔ CRM Contact** sync
pair from [architecture.md](../architecture.md) §2 (the CDS base connector's default-mappings table).

> This compares the **real Dataverse Contact entity**, not the `CRM Contact` proxy table in BaseApp. The proxy
> only exposes the subset of contact attributes BC's sync cares about (see [architecture.md](../architecture.md) §2).

---

## 0. The framing asymmetry (read this first)

**Contact is where BC and CRM are closest.** In Dataverse, `contact` is a **person party**: it can stand alone or
hang off a parent `account` via `parentcustomerid`. In BC, **Contact (table 5050) is the home of BC's own CRM
(Relationship Management)** and is deliberately richer than the Customer/Vendor tables — it already carries
interactions, opportunities, segments, and business relations.

| Concept | Dataverse | BC |
|---|---|---|
| A person | `contact` | **Contact**, Type = Person |
| A company as a CRM party | `account` | **Contact**, Type = Company |
| Person's employer link | `parentcustomerid` (→ account/contact) | **Company No.** on the person Contact (Company↔Person link) |
| Party promoted to a customer/vendor | qualify/convert flow | **Contact Business Relation** → Customer / Vendor / Bank |

Because BC already invested in RM on Contact, the gap list here is **shorter and more balanced** than the Account
doc: the deltas are mostly **platform plumbing** (ownership, timeline UX, consent, no-code forms), not missing CRM
concepts. Read §4 as carefully as §1–§3 — much of what CRM does, BC's Contact already does.

---

## 1. Data model — attributes/capabilities `contact` has that BC Contact lacks

### Record lifecycle & ownership (the biggest structural gap)
- `ownerid` / `owningbusinessunit` / `owningteam` / `owninguser` — every Contact is **owned** by a user or team.
  BC Contact has **no per-record owner** (BC security is object-level via permission sets, not row-level). BC's
  Salesperson Code is an attribution field, not an ownership/security boundary.
- `statecode` / `statuscode` — a real Active/Inactive lifecycle with configurable status reasons. BC Contact has no
  equivalent lifecycle; the closest is a coarse exclude/blocked behaviour, not staged status.

### Parent-account link & rollups
- `parentcustomerid` links the person to a parent `account` (or contact), driving **parent-account rollups**
  (open deals, aggregated activity, address inheritance from the parent). BC has the Company↔Person link
  (Company No. / Contact Type) but **no CRM pipeline rollups** onto the company contact — company-level totals in
  BC are ledger-derived, not opportunity-pipeline rollups.
- `originatingleadid`, `preferredsystemuserid` (preferred rep), manager/assistant links.

### Consent / contact preferences (largely absent in BC)
- `donotphone / donotemail / donotfax / donotpostalmail / donotbulkemail`, `preferredcontactmethodcode`, and
  marketing/consent flags. BC Contact has no first-class do-not-contact matrix or preferred-method field.

### Personal / demographic attributes
- `firstname / lastname / fullname` as structured name parts (BC Contact stores a single Name plus optional
  Name 2 / salutation), plus `jobtitle`, `birthdate`, `gender`, `familystatuscode`, `spousesname`,
  `anniversary`, personal profile fields. BC captures Job Title and Salutation but not the personal demographics.

### Communication & multi-address
- `telephone1/2/3`, `mobilephone`, `emailaddress1/2/3`, `websiteurl`, plus **rich composite addresses**
  (`address1_*`, `address2_*`, `address3_*`) each with lat/long, phone, address type. BC Contact has one primary
  address plus alternate-address support, but not the multi-slot composite-address model with geo-coordinates.

### Record-level currency
- `transactioncurrencyid` + `exchangerate` **per record**. In BC, currency lives on transactions and on the linked
  Customer/Vendor, not statically on the Contact.

---

## 2. Forms — what the `contact` form has that the BC Contact Card (page 5050) doesn't

| Dataverse Contact main form | BC Contact Card (page 5050) |
|---|---|
| **Timeline control** — unified stream of emails, calls, appointments, tasks, notes, posts on the contact | Interaction Log Entries exist (RM) but render as a **list/FactBox**, not a unified editable timeline of mixed activity types |
| **Business Process Flow bar** — guided, staged process rendered on the form | No BPF concept |
| **Sub-grids** for related Opportunities, Cases, Activities, Connections — editable inline | Related data via RM actions and **FactBoxes** (interactions, opportunities, to-dos) — read-mostly, not editable sub-grids |
| **Role-based forms** + **Quick Create / Quick View / Card** variants | One AL-defined Contact Card (+ Contact List); no per-role form swapping or quick-create pop-ups |
| **Business Rules** — no-code client-side show/hide/require/validate | Logic is AL (events / OnValidate); no no-code form rules |
| **Embedded charts & dashboards** on the form/views | Charts are separate from the card |
| **Notes + attachments / SharePoint document management** on the record | Links/attachments via Record Links and Incoming Documents; no per-record SharePoint doc grid by default |

---

## 3. Platform capabilities behind `contact` (BC handles differently or not at all)

- **Row-level security** — ownership, sharing, teams, business units, **field-level security profiles**, hierarchy
  security. BC = object-level permission sets only.
- **Sales Insights relationship analytics** — relationship health, who-knows-whom, engagement/predictive scoring on
  the contact. BC has no predictive relationship analytics.
- **Per-field audit history** out of the box. BC = Change Log (must be configured, coarser).
- **Duplicate detection rules** at create/update, platform-wide and fuzzy. BC has a **Contact Duplicates** check
  (Duplicate Search %/String setup) — narrower, but see §4: it does exist.
- **Saved views** (system + personal), per-user personalization, Advanced Find.
- **Activities as first-class entities** (email/appointment/phone call/task) with server-side Exchange sync and
  tracked emails. BC has Interactions and To-dos but no native mailbox/calendar-synced activity model.
- **Portal / marketing / customer-journey membership** (Power Pages, Customer Insights – Journeys), **Connections**
  with connection roles, **Power Automate flows**, **alternate keys**, virtual/elastic tables.

---

## 4. Where BC Contact already has an equivalent (don't rebuild these)

BC's Contact is the strongest overlap point with CRM — most of these already ship in Relationship Management:

- **Interaction Log Entries** — logged emails, phone calls, letters, meetings against the contact (with Interaction
  Templates and the create-interaction wizard). This is BC's activity history.
- **Opportunities** — full opportunity/sales-cycle pipeline hung off the Contact.
- **To-dos / Tasks** — scheduled and recurring tasks, team to-dos, linked to contacts and salespeople.
- **Segments** — CRM segmentation with criteria, reuse, and follow-up interactions.
- **Mailing Groups** — grouping for bulk correspondence/interactions.
- **Profile Questionnaires** — structured profiling/classification of contacts (answer points, auto-classification).
- **Job Responsibilities** and **Industry Groups** — role and industry classification of the contact.
- **Business Relations** — arbitrary typed relationships between contacts (BC's closest analogue to CRM Connections).
- **Contact Business Relation** — links a Contact to **Customer / Vendor / Bank Account** (the qualify/convert path).
- **Company ↔ Person link** — the person contact's Company No. gives BC its parent-org relationship.
- **Duplicate contact check** — Duplicate Search String / % setup flags likely duplicates at creation.
- **Dimensions** — a flexible classification axis on the contact that Dataverse `contact` lacks.
- **Salesperson/Team, Campaigns, and RM setup** — attribution and campaign membership already exist in RM.

---

## 5. Net gaps a BC-native CRM would close vs `contact`

1. **Record ownership + row-level security** (owner/team, sharing) on the contact.
2. **Active/Inactive lifecycle** (`statecode`/`statuscode` with status reasons) beyond a coarse exclude flag.
3. **Unified activity timeline UX** on the Contact Card (mixed emails/calls/tasks/notes in one editable stream).
4. **Consent & contact preferences** (do-not-contact matrix, preferred method/rep).
5. **Business process flows** (guided stages) on the contact.
6. **Parent-account pipeline rollups** onto the company contact.
7. **Personal demographics + multi-slot geo-addresses** where the CRM person profile is richer.

> Design note: BC already owns the CRM-party concept on **Contact** (RM). Prefer **extending RM + Contact 5050**
> (interactions, opportunities, segments, business relations) over importing CRM primitives wholesale; add
> ownership/lifecycle/consent as the genuinely missing platform layers, and reuse Dimensions and Profile
> Questionnaires for classification before adding new option fields.
