# Standard BC ↔ Dataverse / Dynamics 365 Sales integration — architecture reference

> Source of truth: Microsoft **Base Application 28.2.50931.52066** (platform 28.0), AL source read from
> `.alpackages`. Folders: `src/Integration/SynchEngine/`, `src/Integration/Dataverse/`, `src/Integration/D365Sales/`.
> Object IDs below are from that build and are stable across recent versions, but re-verify against the symbols
> you compile against before relying on an exact number.

---

## 1. The big picture

BC has **one generic synchronization engine** (`src/Integration/SynchEngine/`) that copies records between any
two AL tables according to declarative **mappings**. Two connectors configure that engine for Microsoft's cloud:

```
                        ┌─────────────────────────────────────────────┐
                        │        Generic Synch Engine (5335–5361)      │
                        │  Integration Table/Field Mapping + Invokers  │
                        └───────────────▲───────────────▲─────────────┘
                                        │ configures    │ configures
                   ┌────────────────────┴───┐     ┌─────┴───────────────────┐
                   │ CDS connector (Dataverse)│    │ CRM connector (D365 Sales)│
                   │  7200-range + CDS Setup  │    │  5330-range + CRM Setup   │
                   │  Defaults (cu 7204)      │    │  Defaults (cu 5334)       │
                   └──────────────────────────┘    └───────────────────────────┘
                              │  base entities            │  Sales entities layered on top
                              ▼                           ▼
                    Account/Contact/Currency/     Product/Price/Opportunity/
                    Salesperson/Payment Terms…    Sales Order/Invoice/Unit…
```

- **CDS = Dataverse base.** Turning on **CDS Connection Setup** gives you the foundational couplings
  (Company, Business Unit, Salesperson↔systemuser, Currency, Payment Terms, Shipment Method, Shipping Agent,
  Customer/Vendor↔account, Contact↔contact).
- **CRM = Dynamics 365 Sales.** Turning on **CRM Connection Setup** builds on CDS and adds the Sales entities
  (Item/Resource↔product, Price List↔pricelevel, Opportunity, Sales Quote/Order, posted Invoice, UoM…).
- `Codeunit 5330 "CRM Integration Management".IsCDSIntegrationEnabled()` / `IsCRMIntegrationEnabled()` /
  `IsIntegrationEnabled()` tell you which is active.

---

## 2. Default entity mappings (out of the box, BaseApp 28.2)

Exactly which table pairs each connector creates on *Use Default Synchronization Setup* — read from the
`InsertIntegrationTableMapping(...)` calls in `CDS Setup Defaults` (cu 7204) and `CRM Setup Defaults` (cu 5334).

**Rule of thumb:** master/reference data (people, customers, vendors, contacts, currency) = **CDS**;
the sales transaction chain (products, prices, UoM, opportunities, orders, invoices) = **CRM / D365 Sales**.

### BC ↔ Dataverse — **CDS base connector** (enabled by *CDS Connection Setup*)

| BC table | Dataverse entity (proxy table) | Notes |
|---|---|---|
| Salesperson/Purchaser | `CRM Systemuser` (`systemuser`) | Dataverse → BC |
| Customer | `CRM Account` (`account`) | bidirectional |
| Vendor | `CRM Account` (`account`) | bidirectional |
| Contact | `CRM Contact` (`contact`) | bidirectional |
| Currency | `CRM Transactioncurrency` (`transactioncurrency`) | |
| Payment Terms | option-set field on `CRM Account` | **option mapping** (via `CRM Option Mapping` 5334), not a coupled entity |
| Shipment Method | option-set field on `CRM Account` | option mapping |
| Shipping Agent | option-set field on `CRM Account` | option mapping |

Plus **structural / configuration couplings** the connector maintains (not data-record sync): **CDS Company**,
**Business Unit** (`CDS Coupled Business Unit` 7201), and **Team** ownership model.

### BC ↔ CRM — **Dynamics 365 Sales connector** (enabled by *CRM Connection Setup*, layered on CDS)

| BC table | Dataverse/CRM entity (proxy table) | Notes |
|---|---|---|
| Item | `CRM Product` (`product`) | |
| Resource | `CRM Product` (`product`) | |
| Unit of Measure | `CRM Uomschedule` | |
| Unit Group | `CRM Uomschedule` | |
| Item Unit of Measure | `CRM Uom` | |
| Resource Unit of Measure | `CRM Uom` | |
| Customer Price Group | `CRM Pricelevel` | |
| Sales Price | `CRM Productpricelevel` | |
| Price List Header | `CRM Pricelevel` | |
| Price List Line | `CRM Productpricelevel` | |
| Opportunity | `CRM Opportunity` | |
| Sales Header (Order) | `CRM Salesorder` | two mappings: standard **and** a bidirectional Sales Order mapping when bidirectional order integration is on |
| Sales Line | `CRM Salesorderdetail` | |
| Sales Invoice Header | `CRM Invoice` | posted invoice → CRM |
| Sales Invoice Line | `CRM Invoicedetail` | |

**Document flows that are not table mappings:** **CRM Quote → Sales Quote** is a one-way pull handled by codeunit
`CRM Quote to Sales Quote` (quotes originate in Sales); archived-order and order-status write-back run as
scheduled jobs (`CRM Archived Sales Orders Job`, `CRM Order Status Update Job`), not as `Integration Table Mapping` rows.

---

## 3. The synchronization data model

### Integration Table Mapping — table **5335** (one row per synced table pair)
Key fields (verified):

| Field | Meaning |
|---|---|
| `Name` (1) | mapping code, e.g. `CUSTOMER`, `CONTACT`, `SALESORDER-ORDER` |
| `Table ID` (2) | the **BC** table |
| `Integration Table ID` (3) | the **Dataverse/CRM proxy** table |
| `Synch. Codeunit ID` (4) | codeunit that performs the synch — default `5340 "CRM Integration Table Synch."` |
| `Integration Table UID Fld. No.` (5) | the proxy table's primary GUID field (e.g. `CRM Account.AccountId`) |
| `Int. Tbl. Modified On Fld. No.` (6) | proxy `ModifiedOn` field — drives change detection |
| `Table Config Template Code` (8) / `Int. Tbl. Config Template Code` (9) | templates applied to newly-created records on each side |
| `Direction` (10) | `Bidirectional` / `ToIntegrationTable` / `FromIntegrationTable` |
| `Table Filter` (14, BLOB) / `Integration Table Filter` (15, BLOB) | which rows are in scope (set via `SetTableFilter`/`SetIntegrationTableFilter`) |
| `Synch. Only Coupled Records` (16) | if true, only already-coupled rows sync (no mass creation) |
| `Parent Name` (17) | for child/line mappings (e.g. sales order lines) |
| `Deletion-Conflict Resolution` (25) / `Update-Conflict Resolution` (26) | enums 5337 / 5338 |
| `Uncouple Codeunit ID` (27) | default `5337 "CDS Int. Table Uncouple"` |
| `Coupling Codeunit ID` (28) | default `5360 "CDS Int. Table Couple"` |
| `Dependency Filter` (30) | pipe-separated mapping names that must sync first, e.g. `SALESPEOPLE|CURRENCY|PAYMENT TERMS` |
| `Create New in Case of No Match` (31) | auto-create the counterpart when uncoupled |
| `Type` (32) | enum 5339 `Integration Table Mapping Type` |
| `Multi Company Synch. Enabled` (34) | Dataverse multi-company support |

### Integration Field Mapping — table **5336** (child rows of a mapping)
- `Integration Table Mapping Name`, `Field No.` (BC), `Integration Table Field No.` (Dataverse)
- `Direction` (field 6, Option): `Bidirectional` / `ToIntegrationTable` / `FromIntegrationTable`
- `Constant Value` (push a fixed value), `Transformation Rule` (value conversion), `Validate Field` /
  `Validate Integration Table Field` (run the target field's `OnValidate` on transfer).

### Coupling — table **5331 "CRM Integration Record"**
The persistent BC↔Dataverse link: `CRM ID` (Dataverse GUID) ↔ `Integration ID` / BC `SystemId` + `Table ID`,
plus `Last Synch. Modified On` / `Last Synch. CRM Modified On` (used to decide who changed since last sync) and
skip/broken flags. Option/enum couplings live in **5334 "CRM Option Mapping"**. Coupling is the definition of
"this record is synced"; without it, the engine won't touch a record.

### Job logging
- **5338 "Integration Synch. Job"** — one per synch run per mapping (counts: inserted/modified/deleted/failed/skipped).
- **5339 "Integration Synch. Job Errors"** — per-record failures. Surfaced on **Integration Synch. Error List** (page 5339).

---

## 4. Runtime flow (what happens on "Synchronize")

```
Job Queue Entry ──▶ Integration Synch. Job Runner (cu 5339)     [scheduled path]
      or  UpdateOneNow / EnqueueSyncJob (cu 5330)               [on-demand path]
                     │
                     ▼
   CRM Integration Table Synch. (cu 5340)  ── the mapping's "Synch. Codeunit ID"
                     │  reads Integration Table Mapping (5335) + filters
                     ▼
   Integration Table Synch. (cu 5335)  ── loops the in-scope rows, direction-aware,
                     │                     compares Modified-On vs coupling timestamps
                     ▼
   Integration Record Synch. (cu 5336)  ── per record pair, applies Field Mappings (5336)
                     │
                     ▼
   Integration Rec. Synch. Invoke (cu 5345)  ── transfers fields, inserts/modifies the
                     │                            target, applies config templates, writes
                     │                            back the coupling + timestamps
                     ├── Integration Rec. Couple Invoke (5361)  / CDS Int. Table Couple (5360)
                     ├── Int. Rec. Uncouple Invoke (5357)      / CDS Int. Table Uncouple (5337)
                     └── Integration Rec. Delete Invoke (5347)
```

Change detection = compare each side's *Modified-On* against the timestamps stored on the coupling row.
Conflicts (both sides changed, or one side deleted) resolve per the mapping's conflict-resolution enums and can
be intercepted via events (§6).

---

## 5. Object catalog (BaseApp 28.2)

### Generic engine — `src/Integration/SynchEngine/`
| ID | Type | Name | Role |
|----|------|------|------|
| 5335 | table | Integration Table Mapping | mapping definition |
| 5336 | table | Integration Field Mapping | field-level mapping |
| 5337 | table | Temp Integration Field Mapping | temp buffer |
| 5338 | table | Integration Synch. Job | run log |
| 5339 | table | Integration Synch. Job Errors | error log |
| 5335 | codeunit | Integration Table Synch. | row-loop orchestrator |
| 5336 | codeunit | Integration Record Synch. | per-record field apply |
| 5338 | codeunit | Integration Record Management | coupling/record helpers |
| 5339 | codeunit | Integration Synch. Job Runner | job-queue entry point |
| 5345 | codeunit | **Integration Rec. Synch. Invoke** | transfer/insert/modify + **most events** |
| 5347 | codeunit | Integration Rec. Delete Invoke | delete propagation |
| 5357 | codeunit | Int. Rec. Uncouple Invoke | uncouple one record |
| 5361 | codeunit | Int. Rec. Couple Invoke | couple one record |
| 5339 | enum | Integration Table Mapping Type | mapping type |
| 5337 / 5338 | enum | Deletion / Update Conflict Resolution | conflict policy |
| 5335 / 5361 / 5338 | page | Integration Table Mapping List / Field Mapping List / Synch. Job List | admin UI |

### CRM connector (Dynamics 365 Sales) — `src/Integration/Dataverse/` + `src/Integration/D365Sales/`
| ID | Type | Name | Role |
|----|------|------|------|
| 5330 | table | CRM Connection Setup | D365 Sales connection |
| 5331 | table | **CRM Integration Record** | the coupling table |
| 5334 | table | CRM Option Mapping | option/enum couplings |
| 5330 | codeunit | **CRM Integration Management** | main API (enable, sync, create, urls) |
| 5331 | codeunit | **CRM Coupling Management** | coupling API |
| 5334 | codeunit | **CRM Setup Defaults** | D365 Sales default mappings + events |
| 5340 | codeunit | CRM Integration Table Synch. | default per-mapping synch codeunit |
| 5341 | codeunit | CRM Int. Table. Subscriber | per-table special logic (Sales) |
| 5342 | codeunit | CRM Synch. Helper | helpers |
| 5332 | codeunit | Lookup CRM Tables | table/entity lookup |
| 5333 | codeunit | CRM Integration Telemetry | telemetry |
| — | page | CRM Connection Setup / Wizard | connection UI |
| 5336 | page | CRM Coupling Record | manual couple dialog |
| 5328 | page | CRM Coupling Fields | match-based coupling field picker |

### CDS connector (Dataverse base) — `src/Integration/Dataverse/`
| ID | Type | Name | Role |
|----|------|------|------|
| 7200 | table | CDS Connection Setup | Dataverse connection |
| 7201 | table | CDS Coupled Business Unit | business-unit coupling |
| 7202 | table | CDS Environment | environment info |
| 7200 | codeunit | CDS Integration Mgt. | connection/solution mgt |
| 7201 | codeunit | CDS Integration Impl. | implementation |
| 7204 | codeunit | **CDS Setup Defaults** | base default mappings + events |
| 7205 | codeunit | CDS Int. Table. Subscriber | per-table special logic (base) |
| 5337 | codeunit | CDS Int. Table Uncouple | default uncouple codeunit |
| 5360 | codeunit | CDS Int. Table Couple | default couple codeunit |
| 7206 | codeunit | CDS Setup Certificate Auth | S2S/cert auth |
| 7200 / 7201 | page | CDS Connection Setup / Wizard | connection UI |
| 7208 | page | CDS Full Synch. Review | initial full-sync review |

*(There is also a `src/Integration/Graph/` set — Microsoft Graph / API buffers — separate from Dataverse sync.)*

---

## 6. Extension points (events) — extend, never modify

### Register / alter default mappings
On `Codeunit "CDS Setup Defaults"` (base Dataverse):
`OnAfterResetConfiguration`, `OnAfterAddExtraIntegrationFieldMappings`, and per-entity
`OnBefore/AfterReset<Entity>Mapping` (Customer/Vendor Account, Contact, Salesperson, Currency, Payment Terms,
Shipment/Shipping…), `OnCreateJobQueueEntryOnBeforeJobQueueEnqueue`.

On `Codeunit "CRM Setup Defaults"` (D365 Sales): `OnAfterResetConfiguration`, **`OnAddEntityTableMapping`**,
**`OnGetCDSTableNo`**, `OnBeforeInsertIntegrationTableMapping`, `OnBeforeInsertIntegrationFieldMapping`,
`OnBeforeGetDefaultDirection`, `OnBeforeAddEntityTableMapping`, and many per-entity
`OnBeforeReset…Mapping` / `OnReset…MappingOnAfterInsertFieldsMapping` (Item/Resource Product, Sales Invoice
header/line, Sales Order + bidirectional Sales Order, Price List header/line, UoM, Opportunity…).

### Per-record synch logic — `Codeunit "Integration Rec. Synch. Invoke"` (5345)
`OnBeforeTransferRecordFields` / `OnAfterTransferRecordFields`, `OnBeforeInsertRecord` / `OnAfterInsertRecord`,
`OnBeforeModifyRecord` / `OnAfterModifyRecord`, `OnErrorWhenModifyingRecord`,
`OnBeforeApplyRecordTemplate` / `OnAfterApplyRecordTemplate` / `OnBeforeDetermineConfigTemplateCode`,
`OnFindUncoupledDestinationRecord`, `OnUpdateConflictDetected`, `OnDeletionConflictDetected`
(+ `…SetSynchAction` / `…SetRecordStateAndSynchAction`), `OnWasModifiedAfterLastSynch`,
`OnBeforeIgnoreUnchangedRecordHandled`.

### Connection / enablement — `Codeunit "CRM Integration Management"` (5330)
`OnIsCDSIntegrationEnabled`, `OnInitCDSConnection`, `OnGetCDSIntegrationUserId`, `OnGetCDSServerAddress`,
`OnTestCDSConnection`, `OnCloseCDSConnection`, `OnAfterCRMIntegrationEnabled`,
`OnBeforeGetIntegrationTableMapping`, `OnBeforeHandleCustomIntegrationTableMapping`, `OnIsCRMTable`,
`OnAfterAddExtraFieldMappings`, `OnBeforeOpenRecordCardPage`, `OnBeforeOpenCoupledNavRecordPage`.

### Per-table subscribers
`CRM Int. Table. Subscriber` (5341) and `CDS Int. Table. Subscriber` (7205) hold the special-case logic for
standard entities and expose their own events (e.g. `OnFindNewValueForCoupledRecordPK`,
`OnBeforeFindParentCRMAccountForContact`). Model your own per-table subscriber codeunit on these.

---

## 7. Public API surface (most-used)

**`Codeunit 5330 "CRM Integration Management"`**
- State: `IsCRMIntegrationEnabled()`, `IsCDSIntegrationEnabled()`, `IsIntegrationEnabled()`, `IsCRMSolutionInstalled()`
- Sync now: `UpdateOneNow(RecordID)`, `UpdateMultipleNow(RecVariant [,IsOption])`, `UpdateSkippedNow(...)`,
  `EnqueueSyncJob(Mapping, RecordID, CRMID, Direction)`, `EnqueueFullSyncJob(Name): Guid`
- Create counterparts: `CreateNewRecordsInCRM(RecVariant)`, `CreateNewRecordsFromCRM(RecVariant)`,
  `CreateNewRecordsFromSelectedCRMRecords(RecVariant)`
- Couplings: `RemoveCoupling(...)` (many overloads), `MatchBasedCoupling(TableID)`, `RepairBrokenCouplings()`,
  `CreateOptionMapping(...)`, `GetMappedCRMOptionId(...)`
- Mapping/URL: `GetIntegrationTableMapping(var Mapping, RecId | TableID)`, `IsCRMTable(TableID)`,
  `ShowCRMEntityFromRecordID(RecordID)`, `GetCRMEntityUrlFromRecordID(RecordID): Text`

**`Codeunit 5331 "CRM Coupling Management"`**
- `IsRecordCoupledToCRM(RecordID): Boolean`, `IsRecordCoupledToNAV(CRMID, NAVTableID): Boolean`
- `DefineCoupling(RecordID, var CRMID, var CreateNew, var Synchronize, var Direction)` — opens the couple dialog
- `DefineOptionMapping(...)`, `RemoveCoupling(...)`, `RemoveCouplingWithTracking(...)`

**`Codeunit 5334 "CRM Setup Defaults"` helpers to mirror in your own reset code**
- `InsertIntegrationTableMapping(var Mapping; Name; TableNo; IntegrationTableNo; UIDFieldNo; ModifiedFieldNo; TableConfigTemplateCode; IntTblConfigTemplateCode; SynchOnlyCoupledRecords)`
- `InsertIntegrationFieldMapping(MappingName; TableFieldNo; IntegrationTableFieldNo; SynchDirection; ConstValue; ValidateField; ValidateIntegrationTableField)`

---

## 8. Concrete example — the standard Customer ↔ CRM Account mapping

From `CDS Setup Defaults.ResetCustomerAccountMapping` (abridged, verbatim structure):

```al
InsertIntegrationTableMapping(
  IntegrationTableMapping, IntegrationTableMappingName,
  DATABASE::Customer, DATABASE::"CRM Account",
  CRMAccount.FieldNo(AccountId), CRMAccount.FieldNo(ModifiedOn),
  ResetBCAccountConfigTemplate(Database::Customer),
  ResetCDSAccountConfigTemplate(Database::Customer), true);

Customer.SetRange(Blocked, Customer.Blocked::" ");
IntegrationTableMapping.SetTableFilter(
  GetTableFilterFromView(DATABASE::Customer, Customer.TableCaption(), Customer.GetView()));

CRMAccount.SetRange(StateCode, CRMAccount.StateCode::Active);
CRMAccount.SetRange(CustomerTypeCode, CRMAccount.CustomerTypeCode::Customer);
IntegrationTableMapping.SetIntegrationTableFilter(
  GetTableFilterFromView(DATABASE::"CRM Account", CRMAccount.TableCaption(), CRMAccount.GetView()));

IntegrationTableMapping."Dependency Filter" :=
  'SALESPEOPLE|CURRENCY|PAYMENT TERMS|SHIPMENT METHOD|SHIPPING AGENT';
IntegrationTableMapping.Modify();

InsertIntegrationFieldMapping(IntegrationTableMappingName,
  Customer.FieldNo(Name), CRMAccount.FieldNo(Name),
  IntegrationFieldMapping.Direction::Bidirectional, '', true, false);
// … one InsertIntegrationFieldMapping per field pair …
```

Takeaways for your own tables:
- Filter **both** sides (`SetTableFilter` / `SetIntegrationTableFilter`) to keep scope tight.
- Use `Dependency Filter` so lookups (currency, salesperson, payment terms) are coupled before the parent syncs.
- Config templates define how brand-new records are created on each side.
- Field mappings are explicit and per-field; there is no implicit "map everything".

---

## 9. Admin / operations surfaces (for testing & support)

- **CDS Connection Setup** (page 7200) / **CRM Connection Setup** — enable, "Use Default Synchronization Setup"
  (fires the reset events), "Test Connection".
- **Integration Table Mapping List** (5335) — see/enable/disable each mapping; drill to field mappings (5361).
- **Integration Synch. Job List** (5338) — run history & counts; **Integration Synch. Error List** (5339) — failures.
- **CDS Full Synch. Review** (7208) — orders and runs the initial full sync respecting dependencies.
- On records: **Couple / Set Up Coupling**, **Synchronize**, **Delete Coupling**, **Show Online** actions
  (backed by `CRM Coupling Management` + `CRM Integration Management`).

---

## 10. Notes for building `native-bc-crm`

- If this product **rides on** standard Dataverse/D365 Sales sync, add your mappings through the reset events
  (§6) and reuse the standard coupling table (5331) — don't reinvent coupling.
- If this product syncs to **custom Dataverse entities**, generate proxy integration tables (correct
  `ExternalName`/`TableType`) and register mappings the same way; the engine (§4) is entity-agnostic.
- Keep every new object affixed `CRM` in the 50000–99999 range (see `app/AppSourceCop.json`) — the BaseApp
  objects above are Microsoft's; you only ever *subscribe* to them and *insert* mapping rows.
- Re-verify object IDs against the symbols you compile against; this reference is pinned to BaseApp 28.2.
```
