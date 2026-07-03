# Dataverse/D365 Sales **Pricelevel / Productpricelevel** vs BC **Price List / Sales Price** — platform gap analysis

Platform-to-platform comparison of the Dataverse/Dynamics 365 Sales pricing entities — **`pricelevel`**
("price list") and its **`productpricelevel`** line items ("price list item") — against BC's pricing model:
the modern unified **Price List** (Header/Line) plus the legacy **Customer Price Group / Sales Price /
Sales Line Discount** structures. Purpose: decide which pricing capabilities `native-bc-crm` should natively
replicate — and, unlike the Account comparison, where BC's own pricing is already **equal or richer**.

> This compares the **real Dataverse pricing entities**, not the `CRM Pricelevel` / `CRM Productpricelevel`
> proxy tables in BaseApp. The proxies only expose the subset of attributes BC's sync cares about. See the
> §2 default-mappings table in [architecture.md](architecture.md): the **CRM / D365 Sales connector** maps
> **Customer Price Group** *and* **Price List Header** → `CRM Pricelevel`, and **Sales Price** *and*
> **Price List Line** → `CRM Productpricelevel`.

---

## 0. The framing asymmetry (read this first)

**A Dataverse `pricelevel` is a lightweight container: a named, currency-scoped, date-ranged list of
`productpricelevel` rows** that price products/services on Opportunity, Quote, Order and Invoice line items in
D365 Sales. It is a *pricing catalog*, deliberately decoupled from any ledger.

**BC has two overlapping pricing models**, and the connector maps *both* onto the same two CRM entities:

| Concept | Dataverse | BC (modern) | BC (legacy) |
|---|---|---|---|
| Price list container | `pricelevel` | **Price List Header** | **Customer Price Group** |
| Priced line | `productpricelevel` | **Price List Line** | **Sales Price** |
| Quantity/volume break | Discount List (related entity) | Price List Line `Minimum Quantity` | **Sales Line Discount** |

So the interesting story here is the **inverse** of the Account gap analysis: BC's modern Price List is a
**thick, posting-aware, source-typed** structure that in several respects *exceeds* the flat Dataverse price
list. The real gaps Dataverse exposes are narrow and specific — per-line **pricing method** and **discount-list
tiers** (§1) — while much of what BC has (§2) has no Dataverse counterpart at all.

---

## 1. Data model — what Dataverse pricing has that BC lacks

### Per-line **pricing method** (the standout gap)
`productpricelevel.pricingmethodcode` lets each line compute its price rather than store a fixed amount:

| `pricingmethodcode` | Meaning |
|---|---|
| Currency Amount | fixed `amount` (the only mode BC's price lists really use) |
| Percent of List | `percentage` × the product's **list price** |
| Percent Markup — Current Cost | list price = current cost × (1 + %) |
| Percent Margin — Current Cost | list price yields target margin over current cost |
| Percent Markup — Standard Cost | as above, on **standard** cost |
| Percent Margin — Standard Cost | as above, on standard cost |

BC's Price List Line stores a fixed **Unit Price** *or* a **Cost Factor** (price = unit cost × factor — a
partial markup-on-cost analogue), but has **no percent-of-list** and no margin-target methods; percentage
adjustments are expressed as Line Discount %, not as a price-derivation rule.

### Discount lists (volume/quantity tiers as a related entity)
Dataverse attaches an optional **Discount List** (`discounttype` + `discount` rows) to a `productpricelevel`.
Each discount row defines a quantity band (`lowquantity`/`highquantity`) and a `percentage` **or** `amount`,
with the list typed as Percentage or Amount. One discount list is reusable across many price-list items.

### Rounding policy & option (built into every line)
`productpricelevel` carries first-class rounding rules that BC's price list does not model at line level:
- `roundingpolicycode` — None / Up / Down / To Nearest
- `roundingoptioncode` — Ends In / Multiple Of, with `roundingoptionamount` (e.g. always end in `.99`).

### Quantity-selling option
`quantitysellingcode` — None (no control) / Whole / Whole and Fractional — constrains how the quantity may be
sold for that item. BC enforces this via item/UoM rounding precision, not on the price line.

### Per-list currency, ownership & lifecycle
- `pricelevel.transactioncurrencyid` — one currency per list (a `productpricelevel` inherits it).
- `ownerid` / `owningbusinessunit` / `owningteam` — every price list is **owned** and row-securable
  (same ownership model called out for `account`). BC price lists have **no per-record owner**.
- `statecode` / `statuscode` — Active/Inactive lifecycle with status reasons. BC's nearest analogue is the
  Price List **Status** (Draft/Active/Inactive) — see §2; it is comparable but posting-oriented, not CRM state.

---

## 2. Where BC is equal or richer (don't rebuild these)

BC's **modern unified Price List** (introduced to supersede Sales Price / Customer Price Group) already
matches or beats Dataverse on most dimensions:

| Capability | BC Price List | Dataverse `pricelevel` |
|---|---|---|
| **Source typing** — who the list applies to | `Source Type` = All Customers, Customer, Customer Price Group, Customer Disc. Group, Campaign, Contact, Job/Project… + `Source No.` | No built-in audience; a price list is selected on the deal/customer manually or via rules |
| **Defines** price vs discount vs both | `Amount Type` / `Defines` (Price, Discount, Price & Discount) — one structure covers both | Prices and discounts are **separate** entities (`productpricelevel` + discount list) |
| **Line & invoice discount control** | `Allow Line Disc.` / `Allow Invoice Disc.` flags per header and line | Not modeled on the price list |
| **VAT / tax handling** | `Price Includes VAT`, `VAT Bus. Posting Gr. (Price)` on the header | Tax handled outside the price list |
| **Ledger / posting integration** | Prices resolve directly into document lines that post to **G/L**, with full posting-group wiring | Purely a CRM catalog; no ledger tie |
| **Asset breadth per line** | `Asset Type` = Item, Resource, Item/Resource Disc. Group, G/L Account, Service Cost… | Line is a `product` (or write-in), narrower |
| **Date effectivity** | `Starting Date` / `Ending Date` on **header and line** | `begindate` / `enddate` on the header only |
| **Worksheet / bulk maintenance** | Price Worksheet + suggestion/implementation batch jobs | Manual line entry (or Excel/import) |
| **Calculation method** | Pluggable **Price Calculation Method** (e.g. Lowest Price) with a resolution engine | Fixed selection of one active price list |
| **Variant / UoM / min-qty granularity** | Per-line Variant Code, Unit of Measure, `Minimum Quantity`, Work Type | `uomid` and (via discount list) quantity bands |

Net: BC's price list is **posting-anchored and audience-aware**; Dataverse's is a **flexible standalone catalog**.

---

## 3. The modeling mismatch — where quantity/discount pricing lives

The two platforms decompose "cheaper when you buy more" differently:

| | Dataverse | BC |
|---|---|---|
| Where quantity breaks live | A **Discount List** entity (`discounttype` + `discount` rows) attached to the `productpricelevel` | **Sales Line Discount** rows, or multiple **Price List Line** rows each with a `Minimum Quantity` |
| Reusability | One discount list reusable across many price-list items | Discount defined per source/asset combination (not a reusable list object) |
| Price vs discount | Distinct objects (price on `productpricelevel`, discount on discount list) | Optionally unified — one Price List with `Defines = Price & Discount` |

Consequence for sync: a single Dataverse `productpricelevel` with an attached discount list can expand into
**several** BC rows (Price List Lines at different minimum quantities, and/or Sales Line Discount rows). There
is no clean 1:1 field mapping for tiered discounts — this is the main structural friction in the
`Sales Price / Price List Line ↔ CRM Productpricelevel` pair from [architecture.md](architecture.md) §2.

---

## 4. Platform capabilities behind the price list (BC handles differently)

- **Row-level security** — ownership, sharing, teams, business units on the price list (as with all Dataverse
  tables). BC = object-level permission sets only.
- **Currency isolation** — one currency per Dataverse list; BC allows a `Currency Code` per header/line and
  resolves against exchange rates at document time.
- **Default price list on the price-list catalog / product** — Dataverse can flag a system default; BC selects
  the applicable list via Source Type + the Price Calculation engine, not a single global default.
- **Change tracking / audit** — Dataverse per-field audit vs BC Change Log (must be configured).

*(Forms differ in the same ways noted for Account — Timeline, sub-grids, business rules on the Dataverse main
form vs an AL-defined BC page — but that is generic to every entity and not repeated here.)*

---

## 5. Net gaps a BC-native CRM would close vs Pricelevel

Because BC's modern Price List is already strong, the list is short and specific:

1. **Per-line pricing methods** — Percent of List and Percent Markup/Margin on current or standard cost
   (BC covers only fixed price and Cost Factor).
2. **Reusable discount-list tiers** — a shared, quantity-banded discount object attachable to many price
   lines, if that authoring model is desired over per-line `Minimum Quantity` rows.
3. **Line-level rounding rules** — rounding policy + ending-in / multiple-of on the price line itself.
4. **Quantity-selling control** on the price line (whole vs fractional).
5. **Price-list ownership / row-level security**, if CRM-style ownership of catalogs is required.

> Design note: prefer **extending BC's modern Price List** (Header/Line) over resurrecting Sales Price /
> Customer Price Group. Pricing method and rounding fit naturally as new Price List Line fields feeding a
> custom **Price Calculation Method**; reuse `Minimum Quantity` and `Line Discount %` before introducing a
> separate discount-list entity. Everything in §2 already exists — do not rebuild it.
