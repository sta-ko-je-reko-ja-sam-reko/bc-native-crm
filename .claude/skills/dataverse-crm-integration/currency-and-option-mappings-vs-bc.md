# Dataverse **Transactioncurrency** + CRM **option-set fields** vs BC **Currency / Payment Terms / Shipment Method / Shipping Agent** — platform gap analysis

Platform-to-platform comparison of two smaller **CDS base connector** mappings from
[architecture.md](architecture.md) §2 (default entity mappings): the **Currency ↔ `transactioncurrency`**
table mapping, and the **option mappings** by which BC's Payment Terms / Shipment Method / Shipping Agent code
tables are pushed into **option-set (choice) fields on the CRM Account** — not as standalone coupled entities.
Purpose: decide what, if anything, `native-bc-crm` needs to replicate.

> This compares the **real Dataverse `transactioncurrency` entity** and real Account option-set fields, not the
> `CRM Transactioncurrency` / `CRM Account` proxy tables in BaseApp. The proxies only expose the subset BC's sync
> touches. These two topics are deliberately simpler than the Account/Opportunity entities — treat them as thin.

---

## 0. The framing asymmetry (read this first)

Both topics come down to the same asymmetry: **Dataverse models currency and these reference values as
lightweight, record-level or option-level metadata; BC models them as accounting-anchored master data.**

- **Currency** — Dataverse holds one generic `transactioncurrency` per code and stamps *every* record with a
  currency + exchange rate. BC splits the concept into a rich **Currency** master (table 4) plus a dated
  **Currency Exchange Rate** history (table 330), and applies currency at the *transaction/document* level.
- **Payment Terms / Shipment Method / Shipping Agent** — in BC these are their own code tables, but the
  integration does **not** give them Dataverse tables. Each BC code value is mapped to a value in an
  **option-set field on the CRM Account** via the **option mapping** mechanism.

---

## 1. Currency ↔ `transactioncurrency`

### What each side is

| Concept | Dataverse | BC |
|---|---|---|
| Currency definition | `transactioncurrency` (`isocurrencycode`, `currencysymbol`, `currencyname`, `currencyprecision`) | **Currency** (table 4) |
| Exchange rate | **single** `exchangerate` field **on** `transactioncurrency` | **Currency Exchange Rate** (table 330) — dated history, many rows over time |
| Where currency applies | **per record** — every record carries `transactioncurrencyid` + `exchangerate` | **per transaction/document** — master records are not statically currency-stamped |

### What Dataverse has that BC's Currency master doesn't

- **Record-level currency.** Every Dataverse row (account, opportunity, order line…) carries its own
  `transactioncurrencyid` and a snapshotted `exchangerate`, plus paired `_base` money fields auto-computed into
  the org base currency. Currency is an attribute of *each record*, not just of documents.
- A **single current exchange rate** lives directly on the currency; changing a rate is a manual edit or a
  Power Automate flow — there is **no dated rate-history table** in the base platform.

### What BC has that Dataverse doesn't (the accounting depth)

- **Currency master (table 4)** carries the ERP machinery Dataverse has no concept of:
  - rounding: `Amount Rounding Precision`, `Unit-Amount Rounding Precision`, `Invoice Rounding Precision`,
    `Amount Decimal Places`, application/residual rounding;
  - **G/L accounts** for **Realized / Unrealized Gains** and **Realized / Unrealized Losses**, plus
    application-rounding, residual and conversion-rounding accounts.
- **Currency Exchange Rate (table 330)** is a **dated history**: `Starting Date` + `Currency Code` key, with
  `Exchange Rate Amount` / `Relational Exch. Rate Amount` (and adjustment-amount variants). Multiple rates over
  time are first-class; the **Adjust Exchange Rates** batch revalues open entries against them.

### Net difference

Dataverse = **one live rate per currency, applied per record**, snapshotted onto each row. BC = **far richer on
the accounting side** (dated rate history, rounding rules, gain/loss G/L accounts, revaluation batch) but applies
currency at the **document/transaction** level, not statically on master records. The sync couples the two
Currency definitions by ISO code; it does **not** attempt to reconcile BC's rate history or gain/loss accounting
into Dataverse's single-rate model.

---

## 2. Option mappings — Payment Terms / Shipment Method / Shipping Agent

### The pattern: option mapping, not table mapping

Payment Terms, Shipment Method and Shipping Agent are BC **code/reference tables**, but this integration does
**not** create a Dataverse table or a coupled entity for any of them. Instead:

- each of the three is exposed on the Dataverse **Account** as an **option-set (choice) field**, and
- BC ties its code values to those choice values through the **option mapping** mechanism, persisted in
  **table 5334 "CRM Option Mapping"** (see [architecture.md](architecture.md) §3), using the CDS option enums
  **`CDS Payment Terms Code`**, **`CDS Shipment Method Code`** and **`CDS Shipping Agent Code`**.

So on the CRM Account there is a field like *Payment Terms* / *Shipment Method* / *Shipping Agent* whose allowed
values are an **option set**, and each BC code (`30 DAYS`, `CIF`, `DHL`…) is mapped to one of those option values
rather than to a separate account-like record.

| Aspect | Full **table mapping** (e.g. Currency, Customer) | **Option mapping** (Payment Terms / Shipment Method / Shipping Agent) |
|---|---|---|
| Dataverse target | its own entity/proxy table | an **option-set field on `account`** |
| Coupling store | `CRM Integration Record` (5331) | **`CRM Option Mapping` (5334)** |
| Unit coupled | record ↔ record (by GUID) | BC code value ↔ option-set value (CDS option enum) |
| Listed in §2 as | a table pair | an option-set field on `CRM Account` |

### Maintenance implication

Because the Dataverse side is a fixed set of choice values, **adding a new BC code value is not automatic**:
introducing a new Payment Term / Shipment Method / Shipping Agent requires (re)mapping it — the corresponding
option value must exist on the Dataverse side and the BC value must be mapped to it (via option mapping,
`CreateOptionMapping` / `DefineOptionMapping`; see [architecture.md](architecture.md) §7). Unmapped codes simply
don't flow. This is the standard trade-off of option mapping vs table mapping: cheaper to model, but the value
list must be kept in step on both sides.

---

## § Net notes for a BC-native CRM

- **Currency:** BC already owns the richer currency/accounting model (dated rate history, rounding, gain/loss G/L
  accounts, revaluation). A native CRM does **not** need to rebuild any of this. The only thing Dataverse adds is
  **per-record currency stamping** (`transactioncurrencyid` + snapshotted rate on every row); if a native CRM
  needs that parity, it's a *record-attribute* concern, not a new master table.
- **Payment Terms / Shipment Method / Shipping Agent:** these already exist in BC as code tables. Achieving
  Dataverse-style **choice-field parity** on a CRM party record is an **option-mapping** concern — mapping BC code
  values onto option-set values — **not** a reason to introduce new master/coupled tables.
- Both are small: prefer reusing BC's existing Currency and reference tables, and model any CRM-side choice
  fields through option mapping (5334) rather than duplicating the reference data.
