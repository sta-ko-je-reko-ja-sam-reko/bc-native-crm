# app/src/Dataverse — CDS / Dataverse base layer

Native BC reimplementation of the **Dataverse (Common Data Service) base master-data** capabilities that BC
lacks — built natively in AL, **with no dependency on Dataverse, the CRM connector, or CRM proxy tables**.

Scope = the CDS-base entities (see [architecture.md §2](../../../.claude/skills/dataverse-crm-integration/architecture.md)):
`account` (Customer/Vendor/Contact-company), `contact` (person), `systemuser` (Salesperson), `transactioncurrency`
(Currency), and the Payment Terms / Shipment Method / Shipping Agent option sets.

**Spec** = the gap analyses in [.claude/skills/dataverse-crm-integration/](../../../.claude/skills/dataverse-crm-integration/):
`account-vs-bc-master-data.md`, `contact-vs-bc-contact.md`, `systemuser-vs-bc-salesperson.md`,
`currency-and-option-mappings-vs-bc.md`, plus the prioritized `README.md`.

Apply the decision framework in the project [CLAUDE.md](../../../CLAUDE.md) (no-diff → nothing; minor → tableext/pageext
under a **CRM** group / action category; large → custom entity; un-renderable-but-useful graphics → JS control add-in).
Affix `CRM`, IDs 50000–99999. Group features in subfolders here (`app/src/Dataverse/<Feature>/`).
