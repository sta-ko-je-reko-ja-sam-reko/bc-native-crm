# Dataverse/D365 Sales **Invoice** vs BC **Posted Sales Invoice** — platform gap analysis

Platform-to-platform comparison of the Dataverse/Dynamics 365 Sales **`invoice`** entity (+ `invoicedetail`
lines, model-driven forms, platform features) against BC's **Sales Invoice Header / Line** — the **posted**
sales invoice (tables **112** / **113**, "Posted Sales Invoice" page). Purpose: decide which invoice
capabilities `native-bc-crm` should natively replicate, and in which direction.

> This compares the **real Dataverse Invoice entity**, not the `CRM Invoice` / `CRM Invoicedetail` proxy tables
> in BaseApp. The proxy only exposes the subset the sync pushes across (see [architecture.md](architecture.md) §2,
> mappings **Sales Invoice Header ↔ CRM Invoice** and **Sales Invoice Line ↔ CRM Invoicedetail**, on the
> **CRM / D365 Sales** connector).

---

## 0. The framing asymmetry (read this first)

Unlike Account (§0 of the master-data doc), **the asymmetry here runs the other way** — and it is about
**purpose and direction**, not missing CRM richness.

- **BC is the system of record.** A BC Posted Sales Invoice is an **accounting document**: posting it writes
  G/L entries, VAT entries, and Customer Ledger Entries; the header/line rows (112/113) are **immutable** by
  design. It is "the real thing."
- **The CRM `invoice` is a lightweight billing/reference document** inside the Sales app. It exists so a
  salesperson can *see* what has been billed against their account, opportunity, and order — it carries **no
  accounting substance** (no ledger, no VAT engine, no reconciliation).
- **Direction is one-way for the integration.** The standard mapping is `ToIntegrationTable` — BC posts, then
  pushes the posted invoice **BC → CRM**. In CRM the record is effectively a **read-mostly mirror**.

| Concept | Dataverse | BC |
|---|---|---|
| Billing/reference document (sales visibility) | `invoice` + `invoicedetail` | — (CRM-only view of the below) |
| Posted accounting document (system of record) | — | **Sales Invoice Header / Line** (112/113) |
| Native origin of the CRM record | generated from an `salesorder`/`opportunity`, **or** received from BC | posting a Sales Order / Sales Invoice |

So the "gaps" below are **small on the CRM side** and are almost entirely **sales-side visibility** features
(ownership, timeline, links to opportunity/order) — not accounting capability, which BC already owns outright.

---

## 1. Data model — what the CRM Invoice has that a BC Posted Sales Invoice lacks

### Sales-context links (the real reason to mirror at all)
- `salesorderid` — link back to the **originating CRM order**; `opportunityid` (via the order) ties billing to
  the **pipeline**. BC's posted invoice links to the *source document no.* and the customer, but has no notion
  of a CRM opportunity/pipeline.
- `customerid` (polymorphic `account` **or** `contact`) + `billto`/`shipto` party. BC always bills a **Customer**.
- `pricelevelid` (price list) carried on the header, consistent with the CRM quote→order→invoice chain.

### Record lifecycle & ownership
- `ownerid` / `owningbusinessunit` / `owningteam` — the invoice is **owned** by a user/team (row-level security).
  BC's posted invoice has **no per-record owner** (object-level permission sets only); the closest field is
  Salesperson Code.
- `statecode` / `statuscode` — **Active / Paid / Canceled / Closed** (Billed, Partially Shipped, etc.). A real
  document lifecycle. BC's posted invoice is simply *posted and immutable*; "paid" status lives in the
  **Customer Ledger Entry** (Open/Closed, Remaining Amount), not on 112.
- A simple **"record payment" / mark-paid** action that flips the state. This is a status flag, **not** a
  payment application (contrast §3).

### Platform data affordances
- `transactioncurrencyid` + `exchangerate` **per record** (mirrors the Account currency point).
- **Notes + attachments / SharePoint document management** on the record.

### Lines — `invoicedetail`
- `productid` **or** `isproductoverridden` + `productdescription` (write-in line), `uomid`, `quantity`,
  `priceperunit`, `manualdiscountamount`, `tax`, `extendedamount`. A **flat priced line** — enough to show what
  was billed, with no posting semantics behind it.

---

## 2. Forms — what the CRM Invoice form has that the BC posted page doesn't

| Dataverse Invoice main form | BC Posted Sales Invoice page |
|---|---|
| **Timeline control** — unified stream of emails, calls, appointments, tasks, notes against the invoice | No unified timeline on the posted document |
| **Sub-grids** for line items, related activities, connections | Lines shown as a read-only subpage; related data via FactBoxes |
| **Business Process Flow bar** tying invoice back through order → opportunity | No BPF concept |
| **Role-based forms** + Quick View / Card variants | One AL-defined page |
| **Business Rules** (no-code client-side logic) | Logic is AL; page is read-mostly by design |
| **Connections** (typed N:N relationships to any record) | No equivalent |

> Note: because the BC document is **immutable/posted**, most "editable form" richness is intentionally *absent
> on the BC side* — it belongs to the pre-posting **Sales Invoice** (document, table 36/37), not the posted one.

---

## 3. Where BC is vastly richer — it is the actual accounting document

The CRM invoice has **none** of the substance below. This is the whole point of BC being the system of record.

- **General Ledger** — posting generates balanced G/L Entries (revenue, receivables, rounding). CRM: none.
- **VAT / tax engine** — VAT Entries, VAT posting setup, reverse charge, EU/OSS handling, multiple VAT rates
  per document. CRM `tax` is a single rolled-up number.
- **Customer Ledger & aging** — the invoice becomes an open **Customer Ledger Entry** with Open/Closed status,
  Remaining Amount, Due Date, aging buckets. CRM `statuscode = Paid` is a flag with no ledger behind it.
- **Payment application & reconciliation** — apply payments/credit memos to the entry, part-payments, payment
  discounts, currency-gain/loss on settlement, bank reconciliation. CRM has only "mark paid."
- **Dimensions** — full analytical dimension set posted with every entry. CRM has no dimension model.
- **Corrective documents** — **Credit Memos** and **Cancel/Correct posted invoice** with proper reversing
  entries and document links. CRM "Canceled" is just a state.
- **Document sending** — Report layouts (Word/RDLC), email, **PEPPOL / e-invoice / EDI**, Document Sending
  Profiles. CRM has no built-in outbound invoice delivery.
- **Immutability & audit** — 112/113 are non-editable; posting is auditable and permanent. CRM invoice is a
  freely editable business record.
- **Numbering & no-series**, deferred revenue, job/project links, item ledger/cost, incoming reversibility —
  all BC-only.

---

## 4. Where BC already has an equivalent (don't rebuild these)

- **The entire accounting spine** — G/L, VAT, ledger, aging, application, credit memos, document sending — is
  native to BC and has **no meaningful CRM counterpart**. Do not attempt to replicate any of it into a
  CRM-style entity; consume it as-is.
- **Salesperson Code** on the posted invoice already ties the document to a rep (the ledger-anchored analogue
  of `ownerid`).
- **Source-document linkage** (posted invoice → source order/quote → customer) already exists via the posting
  chain; it just isn't expressed as CRM opportunity/pipeline links.

---

## 5. Net gaps a BC-native CRM would close vs Invoice

Because BC already **is** the invoice, the gaps are **sales-side visibility only** — small, and none of them
accounting:

1. **Link the (posted) invoice to Opportunity / Order** so billing is visible along the pipeline.
2. **Record ownership + row-level security** (owner/team) on the sales-visible projection, beyond Salesperson Code.
3. **Unified activity timeline** against the invoice (emails, calls, notes).
4. **Lifecycle status for sales eyes** (Active/Paid/Canceled) surfaced from the Customer Ledger Entry's
   Open/Closed + Remaining Amount — **read-derived, not a new source of truth**.
5. **Connections** (typed relationships) if the product needs invoice↔record webs.

> Design note: keep BC as the system of record and treat any CRM-style invoice as a **downstream, read-mostly
> projection** (mapping direction `ToIntegrationTable`, per architecture.md §2). Derive "Paid" from the Customer
> Ledger Entry rather than storing a competing status; never let the sales-visibility layer originate accounting
> data.
