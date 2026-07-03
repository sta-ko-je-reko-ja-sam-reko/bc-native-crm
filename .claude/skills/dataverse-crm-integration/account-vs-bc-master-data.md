# Dataverse/D365 Sales **Account** vs BC **Customer / Vendor / Contact** — platform gap analysis

Platform-to-platform comparison of the Dataverse/Dynamics 365 Sales **`account`** entity (table model +
model-driven forms + platform features) against BC's **Customer / Vendor / Contact** tables and pages.
Purpose: decide which Account capabilities `native-bc-crm` should natively replicate.

> This compares the **real Dataverse Account entity**, not the `CRM Account` proxy table in BaseApp. The proxy
> only exposes the subset of account attributes BC's sync cares about (see [architecture.md](architecture.md) §2).

---

## 0. The framing asymmetry (read this first)

**Account is one generic "party/organization" entity.** A single `account` (company) + `contact` (person)
covers customer, prospect, competitor, partner, vendor, influencer — differentiated only by classification
fields and relationships. **BC splits that same concept across three role-specific tables**, each bound to the
ERP posting model:

| Concept | Dataverse | BC |
|---|---|---|
| Organization you sell to | `account` (customertypecode = Customer) | **Customer** |
| Organization you buy from | `account` (relationship/role) | **Vendor** |
| Person | `contact` | **Contact** (Type = Person) |
| Company as a CRM party | `account` | **Contact** (Type = Company) |

So most "gaps" below exist because Account is a **thin, generic, extensible CRM record** while BC master data is
a **thick, accounting-anchored** record. Several CRM features already exist in BC but hang off **Contact**
(Relationship Management), not Customer — see §4.

---

## 1. Data model — attributes/capabilities Account has that BC master data lacks

### Record lifecycle & ownership (the biggest structural gap)
- `ownerid` / `owningbusinessunit` / `owningteam` / `owninguser` — every Account is **owned** by a user or team.
  BC Customer/Vendor/Contact have **no per-record owner** (BC security is object-level via permission sets, not row-level).
- `statecode` / `statuscode` — a real Active/Inactive lifecycle with configurable status reasons.
  BC has only a `Blocked` option, and it's an ERP-posting gate, not a lifecycle.

### Hierarchy & relationships
- `parentaccountid` → native **account hierarchy** (parent/subsidiary) with built-in hierarchy visualization. BC has none.
- `primarycontactid`, `originatingleadid`, managing-partner links.
- **N:N Connections with connection roles** — arbitrary typed relationships between any records.
  Closest BC equivalent: Contact Business Relation (much narrower).

### Classification / firmographics (mostly absent in BC)
- `industrycode`, `businesstypecode`, `customertypecode`, `accountcategorycode`, `accountratingcode`,
  `customersizecode`, `ownershipcode`, `territorycode`.
- `revenue`, `numberofemployees`, `sic`, `tickersymbol`, `stockexchange`, `marketcap`.

### Sales / relationship intelligence & rollups
- Rollup fields: `opendeals`, `openrevenue` (aggregated from related Opportunities), `lastusedincampaign`,
  relationship health/analytics from Sales Insights. BC's Customer statistics are **ledger-derived balances**,
  not CRM pipeline rollups.

### Consent / preferences
- `donotphone / donotemail / donotfax / donotpostalmail / donotbulkemail`, `preferredcontactmethodcode`,
  `preferredsystemuserid` (preferred rep), preferred appointment day/time. BC has almost none of this.

### Communication & multi-address
- `telephone1/2/3`, `emailaddress1/2/3`, `websiteurl`, plus **two rich composite addresses**
  (`address1_*`, `address2_*`) each with lat/long, phone, freight terms, shipping method, address type — and
  related **Customer Address** rows. BC has one primary address + a separate Ship-to Address table (Customer only).

### Record-level currency
- `transactioncurrencyid` + `exchangerate` **per record**. In BC, currency lives on transactions, not statically
  per master record.

---

## 2. Forms — what the Account form has that BC pages don't

| Dataverse Account main form | BC Customer/Vendor/Contact card |
|---|---|
| **Timeline control** — unified stream of emails, calls, appointments, tasks, notes, posts | No unified timeline; Interaction Log exists **only for Contacts** (RM), not on Customer/Vendor |
| **Business Process Flow bar** — guided, staged process rendered on the form | No BPF concept |
| **Sub-grids** for related Contacts, Opportunities, Cases, Quotes, Orders, Invoices, Activities | Related data via ribbon "Navigate"/related lists and **FactBoxes** — read-mostly, not editable sub-grids |
| **Role-based forms** + **Quick Create / Quick View / Card** variants | One AL-defined page (+ role-center variant); no per-role form swapping |
| **Embedded charts & dashboards** on forms/views | Charts limited and separate from the card |
| **Business Rules** — no-code client-side show/hide/require/validate | Logic is AL (events/OnValidate); no no-code form rules |
| **Notes + attachments / SharePoint document management** on the record | Attachments via Incoming Documents/links; no per-record SharePoint doc grid by default |

---

## 3. Platform capabilities behind the Account (BC handles differently or not at all)

- **Row-level security** — ownership, sharing, teams, business units, **field-level security profiles**,
  hierarchy security. BC = object-level permission sets only.
- **Per-field audit history** out of the box. BC = Change Log (must be configured, coarser).
- **Duplicate detection rules** at create/update. BC dedup is minimal.
- **Saved views** (system + personal), per-user personalization, Advanced Find.
- **Activities as first-class entities** (email/appointment/phone call/task) with server-side Exchange sync and
  tracked emails. BC has no native activity/calendar model on master data.
- **Marketing lists / campaign membership**, **Connections**, **Sales Insights** (predictive scoring,
  relationship analytics), **Power Automate flows**, **virtual/elastic tables**, **alternate keys**.

---

## 4. Where BC already has an equivalent (don't rebuild these)

- **Opportunities, Tasks, Segments, Interaction Log, Campaigns, Contact hierarchy** already exist in BC's
  **Relationship Management** module — on the **Contact**, not the Customer.
- **Dimensions** give BC a flexible classification axis Account lacks.
- **Ledger-based statistics/aging** are richer than Account rollups for financial history.

---

## 5. Net gaps a BC-native CRM would need to close vs Account

1. **Record ownership + row-level security** (owner/team, sharing).
2. **Unified activity timeline** on the customer/party record.
3. **Business process flows** (guided stages).
4. **Account/party hierarchy** (parent-subsidiary).
5. **Rich classification / firmographics** (industry, rating, size, territory, revenue…).
6. **Consent & contact preferences** (do-not-contact flags, preferred rep/method).
7. **Editable related sub-grids** on the card (contacts, opportunities, activities).

> Design note: in BC the natural home for CRM-party behavior is the **Contact** (RM) table, with Customer/Vendor
> as role projections. Prefer extending RM + Contact over duplicating this onto Customer, and reuse Dimensions
> for classification before adding new option fields.
