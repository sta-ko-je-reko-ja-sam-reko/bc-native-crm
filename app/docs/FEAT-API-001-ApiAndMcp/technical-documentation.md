# FEAT-API-001 - API Layer & MCP

> **Source/legacy reference:** N/A (greenfield). Implements the standing API-coverage rule in
> [api-pages.md](../../../../bc-dev-templates/bc-customer-project-template/al-object-types/_patterns/api-pages.md)
> and the feature-ready gate — **every new persisted table and every extended standard table gets an API page**,
> *even outside migration projects*, because the BC **MCP server exposes API pages as agent tools**.
> **Affected objects:** new API pages over all custom tables + extended standard tables. **The MCP server that
> publishes these pages as agent tools is now its own feature — [FEAT-MCP-001](../FEAT-MCP-001-MCPServer/technical-documentation.md).**
> **Namespaces:** each API page stays in its feature namespace.

**Cross-cutting retrofit.** Tiers 0–3 shipped every custom entity with **UI pages only** — no programmatic surface.
This feature closes that: a `PageType = API` page for each persisted custom table and each standard table we
extended with affix fields, all under our own `APIPublisher = 'nbc'`, grouped per module so an admin can expose a
whole module as one MCP tool set. Buffer/cue tables are excluded per the rule's exception.

## Design decisions

1. **One API page per persisted custom table** — 14 pages (Team, Team Member, Activity, Opp. Line/Competitor/
   Stakeholder, Process/Stage/State, Bundle/Bundle Line, Product Rel., Discount List/Tier). Bound directly to the
   table, `SystemId` as the key, camelCase fields, `Extensible = false`, `DelayedInsert = true`.
2. **Extended standard tables get a NEW API page = FULL Microsoft APIV2 page + affix fields (never a
   `pageextension`)** — API pages cannot be extended, and a minimal "identity + affix" page is useless to MCP/
   Copilot (an agent must see the *whole* entity — a contact's name/email/phone, an item's price/cost, etc.). So
   each page is a **faithful clone of Microsoft's matching APIV2 page** (fields, triggers, calculated-field logic)
   with the NBC affix fields appended. 6 pages: Customer, Contact, Opportunity, Item (cloned from `APIV2 -
   Customers/Contacts/Opportunities/Items`), Resource and Price List Line (**no MS APIV2 page exists** → authored
   from scratch with all meaningful standard fields + affix). **The MS APIV2 pages are NOT in `.alpackages`** (the
   APIV2 app isn't a symbol dependency) — pulled from GitHub `microsoft/ALAppExtensions/.../APIV2/app/src/pages`.
   MS **sub-parts** (picture, default dimensions, financial details, posting groups, variants, document
   attachments, …) are dropped from the clones — they bind to other APIV2-app pages not available here.
3. **`Header + line` = separate top-level pages** — Bundle vs Bundle Line, Discount List vs Discount Tier, Process
   vs Stage vs State are each their own top-level API page (ListPart/CardPart can't be MCP tools).
4. **Per-module `apiGroup`, one `APIPublisher`** — `nbc` publisher, `v1.0`, groups `ownership` / `activities` /
   `opportunity` / `process` / `catalog` / `pricing` / `party`. Grouping matches the per-module permission sets and
   lets MCP scope tools by module. Customer/Contact carry both ownership **and** enrichment fields → grouped as
   `party`.
5. **Cue table excluded** — `NBC CRM Cue` is a role-center cue holder (no integration reads it); per the buffer/cue
   exception it gets no API page. (It is a persisted singleton today rather than `TableType = Temporary` — noted as
   a separate role-center cleanup, not part of this feature.)
5b. **The 9 feature Setup tables are deliberately excluded from the API** (added later in FEAT-SETUP-001).
   They hold single-record *administrative* config (an `Enabled` flag), and enabling/disabling a feature has a
   **session-affecting side effect** — the setup page's `OnQueryClosePage` calls `ApplyExperienceChange`
   (recompute application areas → session restart). A naive API `PATCH` to `Enabled` would flip the flag **without**
   that recompute/restart, so the change wouldn't take effect correctly and would mislead the caller. Feature
   enablement is therefore an **admin-UI / assisted-setup-only** operation, not routine integration data. If
   programmatic toggling is ever required, add a small feature-management API page with `[ServiceEnabled]` bound
   actions that set `Enabled` **and** call `ApplyExperienceChange` — never a plain writable field.
6. **MCP exposure is a separate feature.** Building the MCP configurations that publish these API pages as agent
   tools — the per-module functional configs, the per-feature demo importers, and their agent instructions — lives in
   **[FEAT-MCP-001](../FEAT-MCP-001-MCPServer/technical-documentation.md)**. This feature is the **API surface only**;
   the API-coverage rule is what makes those tools possible.

## API surface

| APIGroup | Entity set | Source table | Page |
|---|---|---|---|
| ownership | teams | NBC CDS Team | 50110 |
| ownership | teamMembers | NBC CDS Team Member | 50111 |
| activities | activities | NBC CDS Activity | 50112 |
| opportunity | opportunityLines | NBC CRM Opp. Line | 50113 |
| opportunity | opportunityCompetitors | NBC CRM Opp. Competitor | 50114 |
| opportunity | opportunityStakeholders | NBC CRM Opp. Stakeholder | 50115 |
| process | processes | NBC CRM Process | 50116 |
| process | processStages | NBC CRM Process Stage | 50117 |
| process | processStates | NBC CRM Process State | 50118 |
| catalog | bundles | NBC CRM Bundle | 50119 |
| catalog | bundleLines | NBC CRM Bundle Line | 50120 |
| catalog | productRelations | NBC CRM Product Rel. | 50121 |
| pricing | discountLists | NBC CRM Discount List | 50122 |
| pricing | discountTiers | NBC CRM Discount Tier | 50123 |
| party | customersCrm | Customer (extended) | 50124 |
| party | contactsCrm | Contact (extended) | 50125 |
| opportunity | opportunities | Opportunity (extended) | 50126 |
| catalog | itemsCrm | Item (extended) | 50127 |
| catalog | resourcesCrm | Resource (extended) | 50128 |
| pricing | priceListLinesCrm | Price List Line (extended) | 50129 |

OData shape: `/api/nbc/{apiGroup}/v1.0/companies({id})/{entitySet}`.

## Objects

| Type | ID | Name |
|---|---|---|
| page (API) | 50110–50129 | 20 API pages (see table above) |

> The MCP seed codeunit (`NBC MCP Setup`, 50110) is documented under [FEAT-MCP-001](../FEAT-MCP-001-MCPServer/technical-documentation.md).

Permission-set wiring: each API page is added (`page … = X`) to its module permission set — API Team/Team Member
+ Customer/Contact CRM → `NBC Foundation`; Activity → `NBC CDS Activities`; Opp. * + Opportunity → `NBC CRM Opp.`;
Process * → `NBC CRM Processes`; Bundle/Product/Item/Resource → `NBC CRM Catalog`; Discount */Price Line →
`NBC CRM Pricing`.

## Integration Points

| Point | Detail |
|---|---|
| OData / Power Platform | all 20 entity sets under publisher `nbc`, per-module groups |
| MCP tools | exposed by **[FEAT-MCP-001](../FEAT-MCP-001-MCPServer/technical-documentation.md)** — this feature only provides the API pages |
| Correlation | every page exposes `systemId` (`Editable = false`) as the key |

## Known Limitations

- Extended-table API pages are **full MS APIV2 clones + affix fields** (corrected — the first pass shipped a
  minimal "identity + affix" surface, which was useless to MCP; see design decision 2). The MS **sub-parts** are
  omitted (they need APIV2-app pages not in our symbols); if a sub-entity (picture, default dimensions, aged AR,
  variants, document attachments) is required over the API, add our own part page. Resource / Price List Line have
  no MS APIV2 page, so their field set is authored (comprehensive, but not an MS-defined contract).
- No `[ServiceEnabled]` bound actions yet (e.g. Publish/Retire, Recalculate price, Advance stage) — the write
  verbs are reachable as field PATCHes; bound actions are a follow-up.
- MCP configuration/seeding and agent instructions are covered in [FEAT-MCP-001](../FEAT-MCP-001-MCPServer/technical-documentation.md).
