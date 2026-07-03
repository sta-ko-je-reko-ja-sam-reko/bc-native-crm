# app/src/CRM — Dynamics 365 Sales (CRM) layer

Native BC reimplementation of the **Dynamics 365 Sales (CRM app)** capabilities that BC lacks — built natively in
AL, **with no dependency on Dataverse, the CRM connector, or CRM proxy tables**.

Scope = the D365 Sales entities (see [architecture.md §2](../../../.claude/skills/dataverse-crm-integration/architecture.md)):
`product` / `uom` / `uomschedule` (Item/Resource/UoM), `pricelevel` / `productpricelevel` (Price List),
`opportunity`, `salesorder` / `salesorderdetail` (Sales Order), `invoice` / `invoicedetail` (Sales Invoice).

**Spec** = the gap analyses in [.claude/skills/dataverse-crm-integration/](../../../.claude/skills/dataverse-crm-integration/):
`product-vs-bc-item-resource.md`, `pricelevel-vs-bc-price-list.md`, `opportunity-vs-bc-opportunity.md`,
`salesorder-vs-bc-sales-order.md`, `invoice-vs-bc-sales-invoice.md`, plus the prioritized `README.md`.

Apply the decision framework in the project [CLAUDE.md](../../../CLAUDE.md) (no-diff → nothing; minor → tableext/pageext
under a **CRM** group / action category; large → custom entity; un-renderable-but-useful graphics → JS control add-in).
Affix `CRM`, IDs 50000–99999. Group features in subfolders here (`app/src/CRM/<Feature>/`).
