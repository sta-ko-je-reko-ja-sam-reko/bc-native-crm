---
name: dataverse-crm-integration
description: How standard Business Central integrates with Microsoft Dataverse and Dynamics 365 Sales (the CDS/CRM sync engine), how to extend it from an AL extension, and how each synced Dataverse entity compares to its BC counterpart. Use when building anything that couples BC records to Dataverse/D365 Sales, adds a table or field to the standard sync, writes a custom integration table mapping, reacts to sync events, debugs coupling / Integration Synch. Job errors, OR when scoping which Dataverse/D365 Sales capabilities (Account, Contact, Opportunity, Product, Price List, Sales Order, Invoice, etc.) a BC-native CRM should replicate. Grounded in BaseApp 28.2 (platform 28.0).
---

# Dataverse / CRM integration in Business Central

Standard BC ships a generic **table-to-table synchronization engine** plus two connectors built on it:

- **CDS (Common Data Service / Dataverse)** — the base connector. Object range **7200+** and part of **5330–5399**. Enabled via **CDS Connection Setup**.
- **Dynamics 365 Sales (CRM)** — layered on top of CDS, adds Sales-specific entities/mappings (Account, Contact, Opportunity, Product, Sales Order, Invoice…). Object range **5330–5399**. Enabled via **CRM Connection Setup**.

> "CRM" in the codebase = the Dataverse/D365 Sales **integration**. It is *not* BC's native Relationship Management module (contacts/segments/opportunities live under `src/CRM/…` in BaseApp and are unrelated to this sync engine).

**Read [architecture.md](architecture.md) first** — it is the full, version-accurate map: engine flow, every object + ID, coupling model, connection setup, and the extension points. This SKILL is the quick index + the "add a table to the sync" recipe.

For **design/scoping** — deciding which Dataverse/D365 Sales capabilities a BC-native CRM should replicate — see the **entity gap analyses** below. Each compares the *real* Dataverse entity (data model + model-driven forms + platform features) against its BC counterpart, and ends with the net gaps a BC-native CRM would need to close. One doc per sync pair from [architecture.md](architecture.md) §2:

| Dataverse / D365 Sales entity | BC counterpart | Doc |
|---|---|---|
| `account` | Customer / Vendor / Contact (company) | [account-vs-bc-master-data.md](account-vs-bc-master-data.md) |
| `contact` | Contact (person) + RM | [contact-vs-bc-contact.md](contact-vs-bc-contact.md) |
| `systemuser` | Salesperson/Purchaser (+ BC User) | [systemuser-vs-bc-salesperson.md](systemuser-vs-bc-salesperson.md) |
| `product` (+ `uom`/`uomschedule`) | Item / Resource / Unit of Measure | [product-vs-bc-item-resource.md](product-vs-bc-item-resource.md) |
| `pricelevel` / `productpricelevel` | Price List / Customer Price Group / Sales Price | [pricelevel-vs-bc-price-list.md](pricelevel-vs-bc-price-list.md) |
| `opportunity` | Opportunity (RM) | [opportunity-vs-bc-opportunity.md](opportunity-vs-bc-opportunity.md) |
| `salesorder` / `salesorderdetail` | Sales Header / Line (Order) | [salesorder-vs-bc-sales-order.md](salesorder-vs-bc-sales-order.md) |
| `invoice` / `invoicedetail` | Posted Sales Invoice Header / Line | [invoice-vs-bc-sales-invoice.md](invoice-vs-bc-sales-invoice.md) |
| `transactioncurrency` + option sets | Currency / Payment Terms / Shipment Method / Shipping Agent | [currency-and-option-mappings-vs-bc.md](currency-and-option-mappings-vs-bc.md) |

## When to use this skill

- Coupling a BC table to a Dataverse table / D365 Sales entity (uni- or bidirectional).
- Adding a new **Integration Table Mapping** + **Integration Field Mapping** from your extension.
- Transforming field values during sync, or injecting custom logic per record.
- Reading/writing couplings programmatically, forcing a sync, or reviewing sync errors.
- Debugging: broken couplings, skipped records, Integration Synch. Job failures.

## The 4 concepts you must hold

1. **Integration Table Mapping** (table 5335) — one row per synced table pair. Holds `Table ID` ↔ `Integration Table ID`, the UID + Modified-On field numbers, `Direction`, table/integration filters, and the codeunits that do the work (`Synch. Codeunit ID`, `Uncouple/Coupling Codeunit ID`).
2. **Integration Field Mapping** (table 5336) — child rows: `Field No.` ↔ `Integration Table Field No.`, per-field `Direction`, optional constant value / transformation rule / validate flags.
3. **Coupling** — the persistent link between a BC record and a Dataverse row, stored in **CRM Integration Record** (table 5331; options in **CRM Option Mapping** 5334). Coupling is what makes a record "synced"; it also carries the last-synch timestamps used for change detection.
4. **The engine** — `CRM Integration Table Synch.` (5340, the per-mapping synch codeunit) → `Integration Table Synch.` (5335) → `Integration Record Synch.` (5336) → `Integration Rec. Synch. Invoke` (5345, the per-record transfer/insert/modify with all the extension events). Scheduled runs go through Job Queue → `Integration Synch. Job Runner` (5339).

## Recipe — add your own table to the standard sync

Prerequisites: a Dataverse-side table to sync against. Either a **real proxy table** already in BaseApp (e.g. `CRM Account`), or a **generated integration/proxy table** for a custom Dataverse entity (an AL `table` with `TableType = CRM`/external, `ExternalName`, and each field's `ExternalName` set — generate with the *Get tables from Dataverse* / integration-table tooling rather than hand-writing GUID field types).

1. **Register the mapping.** Subscribe to the reset event so your mapping is (re)created whenever the admin resets the integration:
   - Base Dataverse scope → `Codeunit "CDS Setup Defaults" :: OnAfterResetConfiguration`
   - D365 Sales scope → `Codeunit "CRM Setup Defaults" :: OnAfterResetConfiguration` (also `OnAddEntityTableMapping` / `OnGetCDSTableNo` for entity discovery)

2. **Insert the Integration Table Mapping** (mirror `InsertIntegrationTableMapping` in the setup codeunits):
   ```al
   [EventSubscriber(ObjectType::Codeunit, Codeunit::"CDS Setup Defaults", 'OnAfterResetConfiguration', '', false, false)]
   local procedure AddMyMapping(CDSConnectionSetup: Record "CDS Connection Setup")
   var
       IntegrationTableMapping: Record "Integration Table Mapping";
       MyBCTable: Record "CRM <YourBCTable>";      // BC side
       MyCRMTable: Record "CRM <YourDataverseProxy>"; // Dataverse proxy
   begin
       if IntegrationTableMapping.Get('MYMAPPING') then
           IntegrationTableMapping.Delete(true);

       IntegrationTableMapping.Init();
       IntegrationTableMapping.Name := 'MYMAPPING';
       IntegrationTableMapping."Table ID" := Database::"<YourBCTable>";
       IntegrationTableMapping."Integration Table ID" := Database::"CRM <YourDataverseProxy>";
       IntegrationTableMapping."Integration Table UID Fld. No." := MyCRMTable.FieldNo(<PrimaryIdField>);
       IntegrationTableMapping."Int. Tbl. Modified On Fld. No." := MyCRMTable.FieldNo(ModifiedOn);
       IntegrationTableMapping."Synch. Codeunit ID" := Codeunit::"CRM Integration Table Synch.";
       IntegrationTableMapping."Uncouple Codeunit ID" := Codeunit::"CDS Int. Table Uncouple";
       IntegrationTableMapping."Coupling Codeunit ID" := Codeunit::"CDS Int. Table Couple";
       IntegrationTableMapping.Direction := IntegrationTableMapping.Direction::Bidirectional; // or To/FromIntegrationTable
       IntegrationTableMapping."Synch. Only Coupled Records" := true;
       IntegrationTableMapping.Insert(true);
   end;
   ```
   Set `Table Filter` / `Integration Table Filter` via `SetTableFilter` / `SetIntegrationTableFilter` (see the `ResetCustomerAccountMapping` pattern in [architecture.md](architecture.md)). Use `Dependency Filter` to force other mappings (e.g. `CURRENCY|SALESPEOPLE`) to sync first.

3. **Insert Integration Field Mappings** — one per field pair:
   ```al
   InsertFieldMapping('MYMAPPING', MyBCTable.FieldNo(Name), MyCRMTable.FieldNo(Name),
                      IntegrationFieldMapping.Direction::Bidirectional, '', true, false);
   ```
   where the helper does `IntegrationFieldMapping.Init(); .."Integration Table Mapping Name" := …; ."Field No." := …; ."Integration Table Field No." := …; .Direction := …; .Insert()`. Set `Transformation Rule` for value conversions, `Constant Value` for fixed values, and the two `Validate…` flags to run field `OnValidate`.

4. **Per-record custom logic (optional).** Subscribe to `Codeunit "Integration Rec. Synch. Invoke"` events: `OnBeforeTransferRecordFields` / `OnAfterTransferRecordFields` (adjust mapped values), `OnBeforeInsertRecord` / `OnAfterInsertRecord`, `OnBeforeModifyRecord` / `OnAfterModifyRecord`, and the conflict events `OnUpdateConflictDetected` / `OnDeletionConflictDetected`.

5. **Coupling UI (optional).** On the BC card/list, add the standard "Coupling" actions using `Codeunit "CRM Coupling Management"` (`DefineCoupling`, `RemoveCoupling`, `IsRecordCoupledToCRM`) and `Codeunit "CRM Integration Management"` (`UpdateOneNow`, `ShowCRMEntityFromRecordID`). Copy the action group from the standard Customer Card pageextension pattern.

6. **Reset & test.** Run *Dataverse/CRM Connection Setup → Use Default Synchronization Setup* (or reset) so your `OnAfterResetConfiguration` fires, then couple a record and *Synchronize*. Watch **Integration Synch. Job List** (page 5338) and **Integration Synch. Error List** (5339).

## Programmatic API cheat-sheet (`CRM Integration Management`, cu 5330)

- Enabled? `IsCDSIntegrationEnabled()`, `IsCRMIntegrationEnabled()`, `IsIntegrationEnabled()`
- Force sync: `UpdateOneNow(RecordId)`, `UpdateMultipleNow(RecVariant)`, `EnqueueSyncJob(...)`, `EnqueueFullSyncJob(Name)`
- Create in Dataverse / from Dataverse: `CreateNewRecordsInCRM(RecVariant)`, `CreateNewRecordsFromCRM(RecVariant)`
- Coupling: `CRM Coupling Management`.`IsRecordCoupledToCRM`, `DefineCoupling`, `RemoveCoupling`; bulk `MatchBasedCoupling(TableID)`; repair `RepairBrokenCouplings()`
- Get the mapping for a record: `GetIntegrationTableMapping(IntegrationTableMapping, RecId)`
- Open the Dataverse record: `ShowCRMEntityFromRecordID(RecordId)` / `GetCRMEntityUrlFromRecordID(...)`

## Don't

- **Don't hand-write GUID-field proxy tables** for Dataverse entities — generate them so `ExternalName`/`TableType` are correct.
- **Don't put mapping creation anywhere but the reset events** — mappings must survive an admin "reset to default", and duplicate mappings on a name will error.
- **Don't sync uncoupled records blindly** — keep `Synch. Only Coupled Records = true` unless you truly want mass creation.
- **Don't edit BaseApp** — everything here is reachable via events + inserting your own mapping rows (extend, never modify).
