# FEAT-LNK-001 - Transaction Pipeline Linkage

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** `Sales Header`, `Sales Invoice Header`, `Opportunity` (tableextensions + pageextensions); new setup table/page, sales-status enum, linkage codeunits (mgt + interface + reactions + posting subscriber), two API pages, permission set.
> **Namespaces:** `NBC.CRM.Linkage` (feature), `NBC.Setup` (feature toggle plumbing).

Implements **Tier 4 / item 13** of the `dataverse-crm-integration` backlog — the net gaps from
[`salesorder-vs-bc-sales-order.md`](../../../.claude/skills/dataverse-crm-integration/salesorder-vs-bc-sales-order.md) §5.1–2
and [`invoice-vs-bc-sales-invoice.md`](../../../.claude/skills/dataverse-crm-integration/invoice-vs-bc-sales-invoice.md) §5.1.
BC already owns fulfillment, VAT, posting and the customer ledger — **the only missing piece is the CRM linkage**: the
sell-cycle pointer from a transaction back to its originating opportunity, a sales-facing order status distinct from
BC's release `Status`, and visibility of the resulting orders/invoices from the opportunity. We **enrich the existing
Sales Header / Sales Invoice Header** and never touch the fulfillment or accounting engine.

## Business Process

1. A salesperson works an **Opportunity** (FEAT-OPP-001) with product lines and an estimated revenue.
2. When the deal firms up, they create a **Sales Quote or Order** in BC and set its **CRM Opportunity No.** to the
   originating opportunity — the sell-cycle is now traceable end-to-end inside BC.
3. The order carries a **CRM Sales Status** (Active → Submitted → Fulfilled / Canceled) — a customer-facing sales
   lifecycle separate from BC's Open/Released processing `Status`. **Submit** and **Cancel** actions move the status;
   an optional **Pricing Locked** flag records that prices were frozen (the CRM "lock pricing" transition).
4. The order is **posted** through the standard BC engine (ship/invoice — unchanged). On posting an invoice, the
   feature **stamps the originating CRM Opportunity No. onto the Posted Sales Invoice** so billing stays linked to the
   pipeline. The posted invoice is immutable; the stamp is read-only afterwards.
5. From the **Opportunity Card**, the salesperson sees **how many orders and posted invoices** trace back to this
   opportunity and can drill into either list — closing the loop from pipeline to realised revenue.

## Data Model

### New Tables
| # | Field | Type | Notes |
|---|---|---|---|
| `NBC Linkage Setup` (single-record) | Primary Key | Code[10] | PK of the single setup row. |
| | Enabled | Boolean | Feature toggle — first guard of the posting reaction; drives the `NBCLinkage` application area. |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| Sales Header (36) | NBC CRM Opportunity No. | Code[20] | `TableRelation = Opportunity`. Back-reference to the originating opportunity. |
| Sales Header (36) | NBC CRM Sales Status | Enum `NBC CRM Sales Status` | Active/Submitted/Fulfilled/Canceled — sales lifecycle, not BC's release Status. |
| Sales Header (36) | NBC CRM Pricing Locked | Boolean | Records the CRM "lock pricing" transition. |
| Sales Invoice Header (112) | NBC CRM Opportunity No. | Code[20] | `TableRelation = Opportunity`, `Editable = false`. Stamped at posting from the source order; read-only mirror. |
| Opportunity (5092) | NBC CRM Linked Orders | Integer (FlowField) | Count of Sales Headers (Document Type = Order) linked to this opportunity. |
| Opportunity (5092) | NBC CRM Linked Invoices | Integer (FlowField) | Count of Posted Sales Invoices linked to this opportunity. |

## Objects

| Type | ID | Name | Namespace | Purpose |
|---|---|---|---|---|
| table | 50139 | NBC Linkage Setup | NBC.Setup | Single-record feature setup + `Enabled`. |
| page | 50139 | NBC Linkage Setup | NBC.Setup | Administration card for the toggle (`ApplicationArea = All`). |
| enum | 50140 | NBC CRM Sales Status | NBC.CRM.Linkage | Active/Submitted/Fulfilled/Canceled. |
| enum (edit) | 50130 | NBC Feature | NBC.Setup | New `value(9; Linkage)` appended to our own feature enum. |
| tableextension | 50130 (field 50139) | NBC App Area Setup | NBC.Setup | Adds the `NBC Linkage` application-area boolean. |
| tableextension | 50140 | NBC CRM Sales Header | NBC.CRM.Linkage | Opportunity link + sales status + pricing-locked on Sales Header. |
| tableextension | 50141 | NBC CRM Sales Inv. Header | NBC.CRM.Linkage | Opportunity link on the posted invoice. |
| tableextension | 50142 | NBC CRM Link Opportunity | NBC.CRM.Linkage | Linked-orders / linked-invoices FlowField counts. |
| interface | — | NBC CRM ILinkageReactions | NBC.CRM.Linkage | Swappable posting-reaction contract. |
| codeunit | 50141 | NBC CRM Linkage Mgt. | NBC.CRM.Linkage | Public services: set opportunity, submit/cancel, show orders/invoices. |
| codeunit | 50142 | NBC CRM Linkage Reactions | NBC.CRM.Linkage | Default `ILinkageReactions` impl — Enabled-guarded invoice stamping. |
| codeunit | 50143 | NBC CRM Linkage Subscribers | NBC.CRM.Linkage | Pure-proxy subscriber on `Sales-Post` → one-line delegate via Service Locator. |
| pageextension | 50143 | NBC CRM Sales Order | NBC.CRM.Linkage | Surfaces the link/status/actions on Sales Order (gated). |
| pageextension | 50144 | NBC CRM Posted Sales Invoice | NBC.CRM.Linkage | Surfaces the read-only opportunity link on the posted invoice (gated). |
| pageextension | 50145 | NBC CRM Link Opp. Card | NBC.CRM.Linkage | Linked-orders/invoices cues + drill-down actions on Opportunity Card (gated). |
| page | 50150 | NBC CRM API Sales Order | NBC.CRM.Linkage | Writable API clone of MS APIV2 sales order + affix fields (`CheckEnabled` guards). |
| page | 50151 | NBC CRM API Sales Invoice | NBC.CRM.Linkage | Read-only API clone of MS APIV2 sales invoice + affix field. |
| permissionset | 50140 | NBC CRM Linkage | NBC.CRM.Linkage | Module permission set; included in `NBC CRM License`. |

## Files

```
app/src/
├── Setup/
│   ├── Feature.Enum.al                 (+ value 9 Linkage)
│   ├── AppAreaSetup.TableExt.al         (+ field 50139 "NBC Linkage")
│   ├── AppAreaSubscriber.Codeunit.al    (+ Linkage area line)
│   ├── FeatureMgt.Codeunit.al           (+ Linkage case)
│   ├── LinkageSetup.Table.al
│   └── LinkageSetup.Page.al
├── Core/
│   └── ServiceLocator.Codeunit.al       (+ LinkageReactions accessor)
└── CRM/Linkage/
    ├── CRMSalesStatus.Enum.al
    ├── CRMSalesHeader.TableExt.al
    ├── CRMSalesInvHeader.TableExt.al
    ├── CRMLinkOpportunity.TableExt.al
    ├── CRMILinkageReactions.Interface.al
    ├── CRMLinkageReactions.Codeunit.al
    ├── CRMLinkageSubscribers.Codeunit.al
    ├── CRMLinkageMgt.Codeunit.al
    ├── CRMSalesOrder.PageExt.al
    ├── CRMPostedSalesInvoice.PageExt.al
    ├── CRMLinkOppCard.PageExt.al
    ├── CRMAPISalesOrder.Page.al
    ├── CRMAPISalesInvoice.Page.al
    └── CRMLinkage.PermissionSet.al
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Posting → invoice stamp | `Sales-Post`.`OnAfterSalesInvHeaderInsert(var SalesInvHeader; SalesHeader)` | Subscriber copies `NBC CRM Opportunity No.` from the source order onto the posted invoice; guarded by `Enabled`. |
| Feature toggle | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `NBC Linkage` area set from the setup `Enabled` flag. |
| API/MCP write path | `NBC Feature Mgt.`.`CheckEnabled(Feature::Linkage)` | Order API write triggers gate on the toggle (ApplicationArea doesn't reach the API). |
| Polymorphism | `NBC Service Locator`.`LinkageReactions()` + interface `NBC CRM ILinkageReactions` | Subscriber body is one line; reaction is swappable for tests/downstream. |

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| FEAT-OPP-001 (Opportunity) | this app | The linkage target (`Opportunity` table + card). |
| FEAT-SETUP-001 (feature toggle) | this app | Setup/`Enabled`/application-area/`Feature Mgt.` plumbing. |
| Base Application (Sales, Sales-Post) | Microsoft | Sales Header/Invoice tables, the posting event, standard fulfillment/accounting (reused untouched). |

## Known Limitations

- **`Fulfilled` is a manual sales status**, not auto-derived from posting: a fully posted order is deleted by BC, so
  there is no record to flip. The status is moved by the Submit/Cancel/Fulfilled actions; deriving it from the posted
  trail is a possible later enhancement.
- **Quote linkage** reuses the same `NBC CRM Opportunity No.` on the Sales Header (a Quote is the same table); no
  separate quote-pointer field is added — BC already chains Quote → Order via `Quote No.`.
- **Invoiced-amount rollup** is expressed as a *count* of linked posted invoices, not a summed amount, to avoid
  depending on posted-invoice FlowField totals; amount roll-up can be added if required.
- The CRM sales status does **not** gate BC posting — it is sales-facing only; BC's release/approval `Status` remains
  the operational gate.
