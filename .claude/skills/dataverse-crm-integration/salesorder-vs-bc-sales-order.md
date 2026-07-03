# Dataverse/D365 Sales **Salesorder** vs BC **Sales Header / Sales Line (Order)** — platform gap analysis

Platform-to-platform comparison of the Dataverse/Dynamics 365 Sales **`salesorder`** entity (+ `salesorderdetail`
lines, table model + model-driven forms + platform features) against BC's **Sales Header / Sales Line** with
`Document Type = Order` (tables 36/37, "Sales Order" page 42). Purpose: decide which order capabilities
`native-bc-crm` should natively replicate — and, unusually, which it can simply lean on BC for.

> This compares the **real Dataverse Salesorder/Salesorderdetail entities**, not the `CRM Salesorder` /
> `CRM Salesorderdetail` proxy tables in BaseApp. The proxies only expose the subset of order fields BC's sync
> cares about. The relevant sync pairs are **Sales Header (Order) ↔ `CRM Salesorder`** and
> **Sales Line ↔ `CRM Salesorderdetail`** — see [architecture.md](architecture.md) §2 (CRM / D365 Sales
> connector). Note there are **two order mappings**: the *standard* one, plus a **bidirectional Sales Order
> mapping** that is registered when bidirectional order integration is enabled (§2 note on the `SALESORDER-ORDER`
> pair).

---

## 0. The framing asymmetry (read this first)

Most entities in this skill are asymmetric because Dataverse is the thin/generic side and BC is the thick,
accounting-anchored side. **The sales order is the opposite.** Here BC is the heavy side and CRM is the light one:

| | Dataverse/D365 Sales `salesorder` | BC Sales Header/Line (Order) |
|---|---|---|
| Role | **Pre-fulfillment sales document** | **Operational fulfillment + posting engine** |
| Born from | won **Opportunity** / accepted **Quote** | created in BC, or flowed in from the CRM order |
| Captures | products, price list, discounts, requested delivery, sales context | everything the CRM order has **plus** reservation, shipment, invoicing, ledger posting |
| Does **not** do | ship, invoice, post to any ledger, reserve inventory, track VAT | — (it does all of it) |
| Ends as | `statecode` Fulfilled/Canceled (a status flag) | **Posted Sales Shipment** + **Posted Sales Invoice** + G/L, VAT, customer & item ledger entries |

In D365 Sales an order is a *record of what the customer agreed to buy* — a sales artifact captured after the deal
is won, carrying pricing and delivery intent but no accounting weight. In BC the Sales Order is the *machine that
actually delivers and books the revenue*. That is exactly why the integration **flows the CRM order into BC for
fulfillment**, then writes status (and the BC order number / fulfillment state) back to CRM. So the "gaps" below
run **both ways**: §1 is what the CRM order adds that BC's order doesn't model; §3 is the (much larger) set of
things BC's order does that the CRM order can't touch.

---

## 1. What the CRM `salesorder` adds that BC's Sales Order lacks

### Pipeline linkage (the core of what CRM order is *for*)
- `opportunityid` — link back to the originating **Opportunity**; the order closes the sell-cycle that the
  opportunity opened. BC's Sales Order has **no** concept of an originating opportunity (BC's Opportunity lives in
  Relationship Management, off the **Contact**, and does not chain to the Sales Order).
- `quoteid` — link to the accepted **Quote** the order was generated from (`salesorder` is normally created via
  *Create Order* from a won quote). BC Sales Quote → Sales Order conversion exists, but there is no cross-system
  quote/opportunity pointer on the BC document.
- `pricelevelid` — the **price list** governing the order and its `activate/lock pricing` state.

### Order lifecycle as CRM status (not a posting gate)
- `statecode` / `statuscode` — a genuine sales lifecycle: **Active / Submitted / Canceled / Fulfilled** with
  configurable status reasons, plus the **"activate/lock pricing"** transition that freezes prices. BC's Sales
  Order has a `Status` (Open/Released/Pending Approval/Pending Prepayment) but it is a *processing/approval* gate,
  not a customer-facing sales state; "fulfilled/canceled" in BC is expressed by posting or deleting the document,
  not by a status field.

### Ownership & row-level security
- `ownerid` / `owningbusinessunit` / `owningteam` — every order is **owned** by a user/team, with sharing and
  hierarchy security. BC Sales Orders have **no per-record owner** (BC security is object-level via permission
  sets; the `Salesperson Code` is informational, not a security principal).

### Order products (`salesorderdetail`)
- Line can be **catalog** (`productid` → CRM Product) **or write-in** (`isproductoverridden` / `productdescription`)
  — a free-text line with no product master. BC lines are typed (`Type` = Item/Resource/G/L Account/Fixed
  Asset/Charge/Comment) and generally require a master record.
- Per-line discounts sourced from the price list — `manualdiscountamount`, `volumediscountamount`,
  `tax`, `baseamount`, `extendedamount` — computed in CRM's pricing engine.

### Relationship & activity context on the document
- **Timeline** control — the unified stream of emails, calls, appointments, tasks, notes, posts attached to the
  *order record itself*. BC Sales Orders have no unified activity timeline.
- **Connections** (typed N:N relationships), **Business Process Flow** stages rendered on the order form.
- `transactioncurrencyid` + `exchangerate` **per record** (CRM carries currency on the order as a first-class
  field; BC does too via `Currency Code`, so this one is near-parity — see §3).

### The write-back the integration relies on
- The CRM order receives **fulfillment status and the BC order number** back from BC (handled outside the plain
  table mappings — see architecture.md §2: `CRM Order Status Update Job` and `CRM Archived Sales Orders Job`), so
  the salesperson sees fulfillment progress in D365 without leaving CRM.

---

## 2. Forms — what the Salesorder form has that the BC Sales Order page doesn't

| Dataverse Salesorder main form | BC "Sales Order" page 42 |
|---|---|
| **Timeline control** — unified emails/calls/appointments/tasks/notes/posts on the order | No unified timeline on the document |
| **Business Process Flow bar** — guided stages across lead→opportunity→quote→order | No BPF concept |
| **Sub-grids** for related activities, connections, competitors | Lines are an editable subpage; related data via FactBoxes / Navigate, not activity sub-grids |
| **Order products grid** with in-line price-list lookup, write-in products, recalculate | Sales Lines subpage — typed lines, availability, dimensions, reservations (far richer *operationally*) |
| **Role-based / Quick Create / Quick View** form variants | One AL page (+ role-center variants); no per-role form swapping |
| **Business Rules** — no-code show/hide/require/validate | Logic is AL (`OnValidate`/events); no no-code form rules |
| **Notes + SharePoint document management** on the record | Attachments via Incoming Documents/links; no per-record SharePoint doc grid by default |

---

## 3. Where BC is vastly richer — the fulfillment & accounting engine

This is the large asymmetry in BC's favour. **None of the following exists on the CRM `salesorder`; all are core
to the BC Sales Order.** A CRM order is "what to sell"; the BC order is "actually deliver it and book the money".

### Posting engine (the defining difference)
- **Ship / Invoice / Ship-and-Invoice / Post** — the order generates **Posted Sales Shipment** and **Posted
  Sales Invoice** documents and writes **G/L**, **VAT**, **Customer Ledger** and **Item Ledger** entries. CRM
  order posts to nothing; "Fulfilled" is only a status flag.
- **Partial posting** — ship/invoice quantities partially across many postings; `Qty. to Ship`, `Qty. to
  Invoice`, quantity-shipped/invoiced tracking per line.

### Inventory & availability
- **Reservations** and **order tracking** against supply (purchase/production/transfer).
- **Availability** checks (`Item Availability by …`), planning/requisition impact.
- **Item tracking** — serial / lot / package numbers per line.
- **Assemble-to-Order** (linked assembly), **Drop Shipment** and **Special Orders** (purchase linked to the sales
  line), **Blanket Sales Orders** releasing to orders.

### Warehouse & delivery
- **Warehouse pick / shipment**, bins, locations; **multiple Ship-to Addresses**; **Shipment Method**,
  **Shipping Agent** + services, package tracking.
- **Requested/Promised/Planned Delivery Date** with shipping-time and lead-time calculation (CRM has only
  `requestdeliveryby`, a single date field, no calculation).

### Tax, pricing & finance
- Full **VAT / sales-tax engine** (VAT Bus./Prod. Posting Groups, VAT calculation, EU/reverse-charge, tax
  jurisdictions) — CRM carries only flat `tax` amounts.
- **Currency & exchange-rate** handling wired into posting and revaluation (CRM stores rate but never posts FX).
- **Prepayments** (prepayment invoices, % per line, prepayment ledger).
- **Item Charges** (freight/insurance allocation onto item cost) — no CRM equivalent.
- **Line/invoice discounts** driven by BC **Price/Discount** setup, plus **payment terms / payment discounts**.

### Governance & audit trail
- **Document Approval Workflow** (native workflow engine) gating release.
- **Dimensions** (Shortcut + full dimension sets) on header and every line — BC's flexible analytical
  classification; CRM order has none.
- **Posted-document trail** — the immutable Posted Shipment/Invoice chain, `Sell-to` vs `Bill-to` vs `Ship-to`
  party split, and full financial history. CRM order has no posted counterpart.

---

## 4. Where BC already covers it (don't rebuild) & how the sync bridges the two

- **The whole fulfillment/accounting stack in §3 already lives in BC.** For a BC-native CRM there is nothing to
  build here — the order flows into BC and BC does the work.
- **The bridge** is the standard sync: `Sales Header (Order) ↔ CRM Salesorder` + `Sales Line ↔ CRM
  Salesorderdetail` (architecture.md §2). By default the order is pulled **from CRM into BC** for fulfillment;
  enabling **bidirectional order integration** registers the second, bidirectional `SALESORDER-ORDER` mapping so
  edits flow both ways, and status/order-number write-back keeps CRM informed.
- **Sell-cycle context** (Opportunity, Quote, Price List) already exists in BC's Relationship Management and
  Price/Sales-Quote machinery — but it hangs off the **Contact** and the Sales Quote, and is **not linked to the
  Sales Order**. That missing linkage is the real §5 gap, not the pipeline features themselves.

---

## 5. Net gaps a BC-native CRM would close vs Salesorder

Framed honestly: because BC already owns fulfillment and posting (§3), a BC-native CRM does **not** need to
reimplement any of that. The gaps to close are all on the **CRM/sales side** of the order document:

1. **Pipeline linkage on the order** — a first-class pointer from the order back to the originating
   **Opportunity** and accepted **Quote** (and the governing price list), so the sell-cycle is traceable end to
   end inside BC.
2. **Sales-side order statuses** — an Active/Submitted/Canceled/Fulfilled lifecycle (with "lock pricing")
   distinct from BC's release/approval `Status`.
3. **Record ownership + row-level security** on the order (owner/team, sharing) beyond the informational
   `Salesperson Code`.
4. **Unified activity timeline** on the order document (emails/calls/tasks/notes) — reuse RM Interaction Log,
   surfaced on the order.
5. *(Lighter)* **write-in order lines** and CRM-style line discount context, if parity with the CRM order form is
   wanted.

> Design note: unlike the Account/Customer case, here the heavy lifting is *already in BC*. Prefer to **enrich the
> existing Sales Header/Line** with sell-cycle links (Opportunity/Quote), a sales-status field, ownership, and an
> RM-backed timeline — rather than porting any of BC's fulfillment engine into a CRM shape. Wire pipeline context
> onto the document; leave shipping, VAT, and posting exactly where they already work.
