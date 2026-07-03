# FEAT-CAT-001 - Product Sales Catalog

> **Source/legacy reference:** N/A (greenfield). Closes the gaps in
> [product-vs-bc-item-resource.md](../../../.claude/skills/dataverse-crm-integration/product-vs-bc-item-resource.md)
> (Tier 3, feature 11 in the skill [README.md](../../../.claude/skills/dataverse-crm-integration/README.md)).
> **Affected objects:** Item (extend), Resource (extend), Item Card (extend); new Bundle / Bundle Line /
> Product Rel.
> **Namespaces:** `NBC.CRM.Catalog`.

**Tier 3, feature 11.** BC's **Item** (goods) and **Resource** (time) are the natural home for a sellable catalog,
and **Item Categories + Item Attributes** already cover most of Dataverse's *product families + properties* — so we
**reuse those and do not rebuild them**. What BC has no primitive for, and what this feature adds, are the four
genuine sales-catalog gaps from §5 of the gap analysis: a **draft → active → retired lifecycle** (BC has only
`Blocked`), **sell-window validity dates + a default price-list pointer** on the sellable record, priced-as-one
**bundles/kits** (distinct from Assembly/Production BOM), and seller-facing **cross-sell / up-sell / accessory
relationships** (BC has only functional *substitutes*).

## Design decisions

1. **Lifecycle + validity as an extension, not a new master** — a `tableextension` on both **Item** (27) and
   **Resource** (156) adds `NBC CRM Catalog Status` (Draft/Active/Retired), `NBC CRM Valid From`/`Valid To`, and
   `NBC CRM Default Price List`. Extend, never replace: BC's `Blocked`/`Sales Blocked` stay authoritative for
   posting; the catalog status is the *selling* gate layered on top.
2. **Sellability is pure, testable logic** — `NBC CRM Catalog Mgt.IsSellable(Status, ValidFrom, ValidTo, OnDate)`
   is a side-effect-free function (Active **and** inside the sell window). Publish/Retire/Reactivate wrap the
   status transitions.
3. **Bundles are a catalog construct, NOT a BOM** — new `NBC CRM Bundle` (header, own sell price) + `NBC CRM Bundle
   Line` (item/resource components, qty, required/optional). We deliberately do **not** map to Assembly/Production
   BOM — those are manufacturable supply-chain structures, not priced-as-one catalog packages. The header carries a
   FlowField `Component Total` (roll-up of the lines) alongside the bundle's own `Unit Price`.
4. **Polymorphic bundle-line logic** per the house pattern — interface `NBC CRM IBundle` + `NBC CRM Bundle Logic`
   (item/resource lookup + `Line Amount = Quantity × Unit Price`), one-line trigger delegation via a `Logic()`
   resolver + `Define()`.
5. **Product relationships as one generic table** — `NBC CRM Product Rel.` links a (Type, No.) source to a
   (Type, No.) target with a `Relationship Type` (Substitute / Cross-sell / Up-sell / Accessory) and a `Rank`.
   BC's **Item Substitution** already covers the substitute leg; we include Substitute for completeness but the net
   new value is cross/up-sell/accessory suggestions.
6. **Reuse for families/properties** — product families → **Item Categories**, product properties → **Item
   Attributes**. No parallel model is built; the (minor) gaps (inheritance/overridable down a tree, sellable
   nodes) are noted as limitations.
7. **UI** — a **CRM** group on the Item Card surfaces the catalog fields + a **Related Products** action; Bundles
   get their own list/card/lines pages.

## Business Process

1. Author an Item/Resource, set **CRM Catalog Status = Draft**, optionally a **sell window** and a **default price
   list**.
2. **Publish** → Active (sellable); later **Retire** when withdrawn. `IsSellable` gates selling logic on status +
   date.
3. Build a **Bundle**: add component lines (items/resources, required/optional), set the bundle's own price; the
   **Component Total** rolls up.
4. Define **Related Products** (cross-sell/up-sell/accessory/substitute) surfaced to sellers.

## Data Model

### New Tables
| # | Table | Field | Type | Notes |
|---|---|---|---|---|
| 50091 | NBC CRM Bundle | No. | Code[20] | PK |
| | | Description | Text[100] | |
| | | Unit Price | Decimal | bundle sold-as-one price |
| | | Catalog Status | Enum "NBC CRM Catalog Status" | Draft/Active/Retired |
| | | Component Total | Decimal | FlowField sum of lines |
| 50092 | NBC CRM Bundle Line | Bundle No. | Code[20] | PK1, TableRelation Bundle |
| | | Line No. | Integer | PK2 |
| | | Component Type | Enum "NBC CRM Catalog Item Type" | Item/Resource |
| | | No. | Code[20] | TableRelation by type |
| | | Description | Text[100] | |
| | | Quantity | Decimal | |
| | | Unit Price | Decimal | |
| | | Line Amount | Decimal | Quantity × Unit Price |
| | | Required | Boolean | required vs optional component |
| 50090 | NBC CRM Product Rel. | From Type | Enum "NBC CRM Catalog Item Type" | PK1 |
| | | From No. | Code[20] | PK2 |
| | | Relationship Type | Enum "NBC CRM Product Rel. Type" | PK3 |
| | | To Type | Enum "NBC CRM Catalog Item Type" | PK4 |
| | | To No. | Code[20] | PK5 |
| | | Description | Text[100] | |
| | | Rank | Integer | suggestion ordering |

### New Fields on Existing Tables
| Object | Field ID | Field | Type |
|---|---|---|---|
| Item (27) | 50090 | NBC CRM Catalog Status | Enum "NBC CRM Catalog Status" |
| Item (27) | 50091 | NBC CRM Valid From | Date |
| Item (27) | 50092 | NBC CRM Valid To | Date |
| Item (27) | 50093 | NBC CRM Default Price List | Code[20] |
| Resource (156) | 50090..50093 | (same four fields) | |

## Objects

| Type | ID | Name |
|---|---|---|
| enum | 50090 | NBC CRM Catalog Status |
| enum | 50091 | NBC CRM Product Rel. Type |
| enum | 50092 | NBC CRM Catalog Item Type |
| table | 50090 | NBC CRM Product Rel. |
| table | 50091 | NBC CRM Bundle |
| table | 50092 | NBC CRM Bundle Line |
| interface | — | NBC CRM IBundle |
| codeunit | 50090 | NBC CRM Catalog Mgt. |
| codeunit | 50091 | NBC CRM Bundle Logic |
| codeunit | 50092 | NBC CRM Bundle Mgt. |
| tableextension | 50090 | NBC CRM Catalog Item |
| tableextension | 50091 | NBC CRM Catalog Resource |
| page | 50090 | NBC CRM Bundles |
| page | 50091 | NBC CRM Bundle Card |
| page | 50092 | NBC CRM Bundle Lines |
| page | 50093 | NBC CRM Product Relations |
| pageextension | 50090 | NBC CRM Catalog Item Card |
| permissionset | 50090 | NBC CRM Catalog |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Sellability gate | `NBC CRM Catalog Mgt.IsSellable(Status, From, To, OnDate)` | pure predicate for selling logic |
| Lifecycle | `Publish` / `Retire` / `Reactivate` | status transitions on Item/Resource |
| Bundle roll-up | `Component Total` FlowField + `NBC CRM Bundle Logic.Validate_Amounts` | bundle pricing |
| Suggestions | `NBC CRM Bundle Mgt.GetRelatedProducts` | seller cross/up-sell list |

## Files

```
app/src/CRM/Catalog/
├── CatalogStatus.Enum.al  ProductRelType.Enum.al  CatalogItemType.Enum.al
├── ProductRel.Table.al  Bundle.Table.al  BundleLine.Table.al
├── IBundle.Interface.al  CatalogMgt.Codeunit.al  BundleLogic.Codeunit.al  BundleMgt.Codeunit.al
├── CatalogItem.TableExt.al  CatalogResource.TableExt.al
├── Bundles.Page.al  BundleCard.Page.al  BundleLines.Page.al  ProductRelations.Page.al
├── CatalogItemCard.PageExt.al  Catalog.PermissionSet.al
test/src/CatalogTests.Codeunit.al
```

## Known Limitations

- **Families/properties reuse Item Categories + Item Attributes** — BC attributes are not *inherited/overridable*
  down a family tree, and categories are not *sellable nodes* the way a Dataverse product family is. Accepted.
- **Product images / catalog presentation** (§5 gap 6) not built — low value vs effort; deferred.
- Bundles are priced-as-one and are **not** exploded into Sales Order lines here (that linkage is Tier 4).
- Relationship targets are free (Item/Resource) — no publish-state cross-validation between related records.
