# Dataverse/D365 Sales **Product** (+ Unit Group / Unit) vs BC **Item / Resource** (+ UoM) — platform gap analysis

Platform-to-platform comparison of the Dynamics 365 Sales product-catalog entities — **`product`**,
**`uomschedule`** (unit group), **`uom`** (unit) — against BC's **Item / Resource** masters and their
**Unit of Measure** model. Purpose: decide which product-catalog capabilities `native-bc-crm` should natively
replicate, and (just as important) which BC richness a CRM projection must *not* try to rebuild.

> This compares the **real Dataverse product-catalog entities**, not the `CRM Product` / `CRM Uomschedule` /
> `CRM Uom` proxy tables in BaseApp. The proxies only expose the subset of attributes BC's sync cares about
> (see [architecture.md](architecture.md) §2 — the D365 Sales connector maps Item **and** Resource → `product`,
> Unit of Measure **and** Unit Group → `uomschedule`, Item **and** Resource Unit of Measure → `uom`).

---

## 0. The framing asymmetry (read this first)

**`product` is a lightweight sales-catalog record.** It exists to be put on a quote, order, opportunity, or
price list — a sellable line reference with a price and a unit. **BC splits that same "thing you sell" across
two heavy ERP masters**: an **Item** (a physical/inventory/costing master) and a **Resource** (a capacity/time
master). One CRM `product` is fed from *either* a BC Item *or* a BC Resource — the connector maps both BC tables
onto the single `product` entity (architecture.md §2).

| Concept | Dataverse | BC |
|---|---|---|
| Sellable catalog line (goods) | `product` (producttypecode = Product/Sales Inventory) | **Item** |
| Sellable catalog line (labour/time) | `product` (producttypecode = Services) | **Resource** |
| Sellable bundle | `product` (producttypecode = Bundle) + Bundle Products | BOM / Assembly / Item (approximate, not a catalog concept) |
| Selectable units for a product | `uomschedule` (unit group) + `uom` rows | **Unit of Measure** + **Item/Resource Unit of Measure** |

So most "gaps" below exist because `product` is a **thin, sales-facing, publishable catalog record** while a BC
Item is a **thick, inventory-and-accounting-anchored master**. The two lists barely overlap: what CRM adds is
almost entirely *catalog / selling* metadata; what BC adds is almost entirely *supply-chain / costing* depth.

---

## 1. Data model — what Dataverse `product` adds that BC Item/Resource lacks

### Catalog structure & hierarchy (the biggest CRM-side gap)
- **Product families / hierarchy** — `product` with `producttypecode = Product Family` acts as a parent node;
  child products and sub-families nest under it via `parentproductid`. BC has no product tree; Item Categories
  (§4) are a flat-ish classification, not a sellable hierarchy node.
- **Bundles & kits** — `producttypecode = Bundle` + **Bundle Product** (`productassociation`) rows compose a
  sellable package with per-line required/optional flags and quantities. BC's nearest constructs (Assembly BOM,
  Production BOM, item-tracking kits) are *supply-chain* structures, not catalog bundles priced/sold as one line.
- **Product relationships** — the **Product Relationship** (`productsubstitute` / relationship) model expresses
  **cross-sell, up-sell, accessory, and substitute** links between products, surfaced as suggestions on
  quote/order lines. BC has **Item Substitutions** (functional equivalents only) — see §4 — but nothing for
  cross/up-sell or accessories.

### Dynamic attributes
- **Product properties** — a **Property** / **Property Group** model (`dynamicproperty*`) lets each product
  *family* define typed attributes (option set, number, decimal, boolean) that its children inherit and override.
  BC's analogue is **Item Attributes** (§4), which are close in spirit but not family-scoped/inherited.

### Lifecycle & publishing (no BC equivalent)
- **Draft → Active → Retired lifecycle** via `statecode` / `statuscode`, with an explicit **publish workflow**:
  a product is authored in **Draft**, validated, then **Published** to become Active and sellable; it can later
  be **Retired**. Families and bundles must publish their members. BC Item/Resource have only a `Blocked` gate
  (and `Sales/Purch/Inventory Blocked` on Item) — no draft state, no publish action, no retire lifecycle.
- **Validity dates** — `validfromdate` / `validtodate` bound when a product may be sold. BC has no sell-window
  on the master (only price-line date ranges).

### Pricing linkage on the master
- **Default price list** — `pricelevelid` (Default Price List) sits directly on the product, and a product
  carries a **currency** (`transactioncurrencyid`) and standard cost/list price fields
  (`currentcost`, `standardcost`, `price`). BC keeps price/cost in ledger + price-list lines, not as static
  master fields (Unit Price / Unit Cost exist on Item but drive posting, not a "default price list" pointer).

### Ownership, media & platform record model
- `ownerid` / `owningbusinessunit` / `owningteam` — every product is **owned** (row-level). BC Item/Resource
  have no per-record owner (object-level permissions only).
- **Product images** (`entityimage`) and **product catalog / suggestions** presentation for sellers.
- **Subject** (`subjectid`) tree classification and `productstructure` (whether product is standalone, a family,
  or part of a family).

---

## 2. Units of measure — `uomschedule` / `uom` vs BC Unit of Measure

Both platforms model "how this thing is counted and converted," but the shapes differ.

| Concept | Dataverse | BC |
|---|---|---|
| Named set of related units | **`uomschedule`** ("unit group") — a group whose members convert to a **base unit** | **Unit of Measure** (a global code list, e.g. PCS, BOX, HOUR) |
| A specific unit + its conversion | **`uom`** — belongs to one unit group, has `quantity` (factor **to the group's base unit**) and an `isschedulebaseuom` flag | **Item Unit of Measure** / **Resource Unit of Measure** — links an Item/Resource to a UoM code with a **Qty. per Unit of Measure** factor (to the item's *base* UoM) |
| Which units a product may use | Product points at **one unit group** (`defaultuomscheduleid`) + a **default unit** (`defaultuomid`); units are **per-product-selectable from that group** | Item's **Base Unit of Measure** + rows in Item Unit of Measure define the allowed units per item |

Key modeling differences to respect when mapping:
- **Base-unit ownership.** In Dataverse the base unit lives on the **unit group** (`uomschedule`), and every `uom`
  factor is relative to *that group's* base. In BC the base lives on the **Item/Resource** (Base Unit of Measure),
  and each Item Unit of Measure factor is relative to *that item's* base. So a BC item's UoM set is item-local;
  a Dataverse unit group is shared and *selected* by the product.
- **Reusability.** One `uomschedule` (e.g. "Weight" or "Each/Box/Pallet") is authored once and reused across many
  products. BC re-declares the conversion **per item** (the UoM code is global, but Qty-per is item-specific),
  which is more granular but more redundant.
- **Factor direction.** `uom.quantity` = quantity of the unit **in one base unit** vs BC's **Qty. per Unit of
  Measure** semantics — verify direction on the connector's transformation rules before trusting a round-trip.

BC UoM also carries physical attributes CRM's `uom` lacks: **Weight**, **Cube**, **Length/Width/Height**, and
**Qty. Rounding Precision** per Item Unit of Measure — logistics data with no `uom` counterpart.

---

## 3. Where BC is MUCH richer — the ERP mass behind an Item (do **not** rebuild)

Everything below hangs off a BC **Item** (some off **Resource**) and has essentially **no `product` counterpart**.
A CRM projection should treat these as read-through / out-of-scope, not replicate them.

| Domain | What BC has | `product` equivalent |
|---|---|---|
| **Inventory** | On-hand by location/bin, Item Ledger Entries, availability, reservations | none (`product` is not stock-aware) |
| **Costing** | Costing Method (FIFO/LIFO/Std/Average/Specific), Unit Cost, Standard Cost, cost adjustment, Value Entries | flat `currentcost`/`standardcost` fields only |
| **Variants** | **Item Variants** (colour/size/style) with their own inventory & tracking | none (would be separate products) |
| **Item tracking** | **Serial / Lot / Package** numbers, tracking codes, expiration/warranty | none |
| **BOM / production** | **Assembly BOM**, **Production BOM**, routings, components | Bundle exists but is a *catalog* construct, not manufacturable |
| **Replenishment / planning** | Reordering policy, safety stock, lead time, MRP/planning parameters, vendor | none |
| **Item dimensions** | Physical dims + **units of measure per purpose** (sales/purchase/base/put-away) | single default unit |
| **Item charges** | Freight/insurance allocation to inventory value | none |
| **Warehouse** | Bins, zones, put-away/pick, warehouse UoM | none |
| **Substitutions** | **Item Substitutions** (functional equivalents, conditional) | overlaps only the *substitute* relationship type |
| **References & barcodes** | **Item References** (customer/vendor item no., barcode/GTIN, bar code) | none native |
| **Categorization** | **Item Categories** (hierarchical) + **Item Attributes** (typed, filterable) | see §4 — real overlap here |
| **Financial posting** | General/VAT/Inventory Posting Groups, Tax Group | Tax fields only, no posting groups |
| **Analytical dimensions** | **Dimensions** (flexible accounting axes) as default dimension values | none |
| **Resource-specific** | Capacity, unit cost/price by work type, resource calendar, capacity ledger | `product` has no capacity/calendar model |

**Rule:** these are ERP concerns. `native-bc-crm` should surface a coupled item's *sellable* facets and leave
inventory, costing, tracking, planning, and posting in BC.

---

## 4. Where BC already has an equivalent (don't rebuild these)

- **Item Categories + Item Attributes** substantially overlap Dataverse **product families + properties**:
  categories give a hierarchical grouping and attributes give typed, filterable, per-category attribute values.
  Prefer mapping product families → Item Categories and product properties → Item Attributes over inventing a
  parallel model. (Gaps remain: BC attributes aren't *inherited/overridable* down a family tree, and categories
  aren't *sellable nodes* the way a product family is.)
- **Item Substitutions** already cover the *substitute* leg of product relationships (functional equivalents,
  optionally condition-driven). Only cross-sell / up-sell / accessory legs are genuinely missing.
- **Assembly / Production BOM** already compose items — but as manufacturable structures, not priced-as-one
  catalog bundles. Don't map a bundle to a BOM blindly.
- **Resource** already gives BC a first-class time/capacity master that `product` (Services type) only
  approximates.
- **Dimensions** give BC a flexible classification axis `product` lacks entirely.

---

## 5. Net gaps a BC-native CRM would close vs `product`

The genuine, non-duplicative gaps are all **sales-catalog** features — none of the ERP depth in §3:

1. **Product bundles / kits** — a priced-as-one sellable package (distinct from BOM/assembly).
2. **Product families + inherited properties** — a sellable hierarchy with family-scoped, overridable typed
   attributes (beyond flat Item Categories + Item Attributes).
3. **Cross-sell / up-sell / accessory relationships** — seller-facing suggestions (BC has only substitutes).
4. **Draft → Active → Retired lifecycle with a publish workflow** — authoring/validation/publish/retire on the
   catalog record (BC has only `Blocked`).
5. **Default price list pointer + validity dates** on the sellable record.
6. **Product images and catalog/suggestion presentation** for sellers.

> Design note: in BC the natural home for a sellable catalog is the **Item** (goods) and **Resource** (time),
> with **Item Categories + Item Attributes** already covering most of families/properties and **Item
> Substitutions** covering substitutes. Prefer extending those before adding parallel tables — reuse the UoM
> model in §2 rather than a second unit system, and keep inventory/costing/tracking/planning (§3) firmly in BC.
