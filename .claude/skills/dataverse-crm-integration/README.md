# Dataverse / CRM integration knowledge base — index & "what to build" synthesis

This folder is the `dataverse-crm-integration` skill for **native-bc-crm**. It documents how standard BC
integrates with Microsoft Dataverse / Dynamics 365 Sales, and — for product design — how each Dataverse entity
compares to its BC counterpart so we know **which CRM capabilities a BC-native CRM must build vs reuse**.

Grounded in **Base Application 28.2** (platform 28.0), AL source read from `.alpackages`.

## Documents

| Doc | What it covers |
|---|---|
| [SKILL.md](SKILL.md) | Skill entry point: when to use, the "add a table to the standard sync" recipe, API cheat-sheet |
| [architecture.md](architecture.md) | The sync engine: flow, all objects + IDs, coupling model, connection setup, **default entity mappings (§2)**, extension events |
| [account-vs-bc-master-data.md](account-vs-bc-master-data.md) | `account` vs Customer / Vendor / Contact (company) |
| [contact-vs-bc-contact.md](contact-vs-bc-contact.md) | `contact` vs BC Contact (person) + Relationship Management |
| [systemuser-vs-bc-salesperson.md](systemuser-vs-bc-salesperson.md) | `systemuser` vs Salesperson/Purchaser (+ BC User) |
| [product-vs-bc-item-resource.md](product-vs-bc-item-resource.md) | `product` / `uom` / `uomschedule` vs Item / Resource / Unit of Measure |
| [pricelevel-vs-bc-price-list.md](pricelevel-vs-bc-price-list.md) | `pricelevel` / `productpricelevel` vs Price List / Customer Price Group / Sales Price |
| [opportunity-vs-bc-opportunity.md](opportunity-vs-bc-opportunity.md) | `opportunity` vs BC Opportunity (RM) |
| [salesorder-vs-bc-sales-order.md](salesorder-vs-bc-sales-order.md) | `salesorder` / `salesorderdetail` vs Sales Header / Line (Order) |
| [invoice-vs-bc-sales-invoice.md](invoice-vs-bc-sales-invoice.md) | `invoice` / `invoicedetail` vs Posted Sales Invoice |
| [currency-and-option-mappings-vs-bc.md](currency-and-option-mappings-vs-bc.md) | `transactioncurrency` + Payment Terms / Shipment Method / Shipping Agent option mappings |

---

## What to build — prioritized synthesis of the net gaps

Rolled up from the §5 "net gaps" of every entity doc. Ordered so each tier unlocks the next. **Bold = no BC
primitive exists; it must be built from scratch.** Everything else has a BC starting point to extend.

### Tier 0 — Foundation (build first; everything CRM-like depends on it)
1. **Record ownership + team model** — an owner (user/team) on CRM party & document records, with a team concept.
   No BC primitive. *Appears in nearly every doc (account, contact, systemuser, opportunity, salesorder, invoice).*
2. **Row-level security / sharing** on those owned records — BC security is object-level only. Design alongside #1.
3. **Activity model + unified timeline** — a first-class activity entity set (task / phone call / appointment /
   email / note) surfaced as one chronological timeline on a party or document. BC has Interaction Log **only on
   Contact** — extend that pattern rather than starting cold.

### Tier 1 — Core CRM data depth
4. **Opportunity depth** (biggest single-entity gap): opportunity **product line items**, stakeholders /
   competitors / sales team, **won/lost reasons + close activity**, and pipeline **forecasting/rollups**.
   BC Opportunity (RM) gives stages/estimated value to build on; the rest is new.
5. **Party / account hierarchy** (parent-subsidiary) with rollups. No BC equivalent for Customer.
6. **Classification / firmographics** (industry, rating, size, territory, revenue…) — prefer **BC Dimensions +
   Item/Contact Attributes** before adding option fields.
7. **Consent & contact preferences** (do-not-phone/email/…, preferred rep/method). Minimal in BC today.

### Tier 2 — Experience & governance
8. **Guided process (Business-Process-Flow style)** staged UI on party/opportunity/order. No BC primitive.
9. **Form experience**: editable related sub-grids on the card, quick-create, and role-tuned pages/Role Centers.
10. **Governance**: per-field audit (extend **Change Log**), duplicate detection, saved/personal views.

### Tier 3 — Sales catalog & pricing (only if selling-motion features are in scope)
11. **Product sales-catalog features**: product **families/properties**, **bundles/kits**, cross-/up-sell
    **relationships**, and a draft→active→retired **lifecycle**. Build on BC Item Categories/Attributes.
12. **Pricing flexibility**: per-line pricing **methods** (percent-of-list, markup/margin on cost) and reusable
    **discount-list tiers**. BC's unified Price Lists are the base to extend.

### Tier 4 — Pipeline linkage & polish
13. **Transaction ↔ pipeline linkage**: order/invoice back-references to originating opportunity/quote, plus
    sales-side statuses on orders. Fulfillment/accounting already exist in BC — only the CRM linkage is missing.

---

## What NOT to build — BC already owns it (extend/reuse, don't reinvent)

- **Accounting & posting** — G/L, VAT/tax, customer/item ledgers, aging, application, credit memos, e-invoicing.
  The **Posted Sales Invoice is BC's system of record**; the CRM `invoice` is a one-way read-mostly mirror.
- **Inventory & operations** — costing, variants, item tracking, BOM/assembly/production, planning, warehouse.
- **Order fulfillment** — shipping, invoicing, reservations, prepayments, drop-ship/ATO, approvals, posted trail.
- **Currency accounting** — dated exchange-rate history, rounding, realized/unrealized gain-loss, adjust-rates.
- **Existing RM assets on Contact** — Interaction Log, Segments, Mailing Groups, Profile Questionnaires,
  Business Relations, basic Opportunities/Sales Cycles, Tasks. **Home CRM-party behavior on Contact/RM**, with
  Customer/Vendor as role projections — don't duplicate onto Customer.
- **Classification axis** — reuse **Dimensions** before inventing new category fields.

## Guiding principle

Extend, never edit base (tableextension / pageextension / event subscribers). Build the CRM layer **on BC
Relationship Management + Contact**, reuse Dimensions and Price Lists, and reserve net-new objects for the true
gaps in Tier 0–1 (ownership/security, activity timeline, opportunity depth, hierarchy). Keep every object affixed
`CRM` in the 50000–99999 range (`app/AppSourceCop.json`).
