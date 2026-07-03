# bc-native-crm

**Native CRM for Microsoft Dynamics 365 Business Central.** Record ownership & teams, a unified activity timeline,
opportunity management, a guided sales process, product catalog and flexible pricing — reimplemented as **native AL
objects inside Business Central**, with **no Dataverse, CRM connector, or proxy tables**. Built to AppSource
standards.

---

## Why

Business Central ships an integration to Microsoft Dataverse / Dynamics 365 Sales (a sync engine + proxy tables).
This project deliberately **does not** use it. Instead it takes the *feature set* of D365 Sales / Dataverse and
rebuilds the pieces BC lacks **as first-class BC objects** — so a BC customer gets CRM **without ever provisioning
Dataverse**. Extend, never edit base; build on BC's own Relationship Management, Contact, Dimensions and Price Lists.

## What's inside

| Area | Feature | What it adds |
|---|---|---|
| Foundation | **Ownership & Teams** | An owner (salesperson or team) on CRM party & document records, with a team model. |
| Foundation | **Activities & Timeline** | A first-class activity set (task / call / appointment / email / note) on one chronological timeline. |
| Core depth | **Opportunity Depth** | Product line items, competitors, stakeholders, rating, and rolled-up estimated revenue. |
| Core depth | **Party Enrichment** | Industry, firmographics, parent–subsidiary hierarchy, and contact preferences on Customer/Contact. |
| Experience | **Business Process Flow** | A guided, staged progress bar on the opportunity. |
| Experience | **Role Center** | A salesperson home page with CRM cues and shortcuts. |
| Experience | **Governance** | Per-field audit (Change Log) and duplicate detection. |
| Catalog | **Product Catalog** | Bundles/kits, cross-/up-sell relations, and a draft→active→retired lifecycle. |
| Catalog | **Pricing Flexibility** | Per-line pricing methods and reusable discount tiers. |
| Pipeline | **Transaction Pipeline Linkage** | Order/invoice back-references to the originating opportunity + a sales-side order status. |

Plus the platform layers:

- **API layer** — a `PageType = API` page for every custom table and every extended standard table (publisher `nbc`, per-module API groups), so the whole CRM is reachable over OData / Power Platform.
- **MCP Server** — exposes those API pages as **agent tools** for GitHub Copilot and other MCP clients, organised into per-module and per-feature **MCP configurations**, each with ready-to-paste **agent instructions**.
- **Demo data** — one idempotent CRONUS-style seeder per feature, reachable from an Assisted Setup opt-in *or* an agent, that also builds a per-feature **RapidStart Configuration Package**.
- **Onboarding** — a per-feature Assisted Setup wizard that enables the feature and optionally loads its sample data.

## AI-ready

The MCP server turns the CRM into a set of tools an AI agent can use. Each **MCP configuration** is scoped to one
area (or one demo importer) and paired with an agent-instructions file in
[`app/docs/FEAT-MCP-001-MCPServer/agent-instructions/`](app/docs/FEAT-MCP-001-MCPServer/agent-instructions/) — copy a
file into the GitHub Copilot agent you connect to that configuration, and it knows its domain, tools and limits.

## Architecture & conventions

- **Pure AL extension** — extend base via `tableextension` / `pageextension` / `enumextension` + event subscribers; never edit base.
- **Affix `NBC`** on every object and every added field; object IDs in the **PTE range 50000–99999**.
- **House patterns** — polymorphic table-logic (swappable interface impls behind a Service Locator), pure-proxy event subscribers, a swappable effective-permission access policy, ToolTips on table fields, JS control add-ins for the timeline and process bar.
- **Feature Management** — every feature ships a single-record setup + `Enabled` toggle + a dedicated `ApplicationArea`, so it can be turned on/off per tenant.
- **AppSource discipline** — three cumulative entitlements (Core ⊂ CDS ⊂ CRM), upgrade-safe objects, per-module permission sets. Two build targets: **PTE** (default) and **AppSource** (`alc /define:APPSOURCE`).

## Target platform

Business Central **28.2** (platform 28.0, runtime 17.0). CI via **AL-Go for GitHub** (`.github/` + `.AL-Go/`).

## Repository layout

```
app/                 the extension (src grouped by platform layer: Dataverse, CRM, Core, Setup, Demo, Onboarding, …)
  src/               AL objects
  docs/              per-feature technical + getting-started docs, PROJECT-STATUS.md
test/                the automated test app
.github/ .AL-Go/     AL-Go for GitHub CI/CD
CLAUDE.md            project instructions & conventions (start here to contribute)
```

Deeper docs: [`app/docs/PROJECT-STATUS.md`](app/docs/PROJECT-STATUS.md) (living state, decisions, ID map) and each
[`app/docs/FEAT-*/`](app/docs/) feature folder.

## Getting started

1. Open the workspace in VS Code with the AL extension; symbols download from the BC 28.2 dev container into `app/.alpackages`.
2. Build with the AL compiler + the four analyzers (CodeCop, AppSourceCop, UICop, PerTenantExtensionCop) against `app/ruleset.json` — zero-error builds.
3. Publish to a Business Central 28.2 sandbox.
4. **Enable features** — each feature defaults **off**; an admin turns it on via its Assisted Setup guide or setup page (the session restarts to apply).
5. **Load sample data** (optional) — tick "Import sample data" in a feature's setup guide, or run the demo importers.

## Status

All tiers (0–4) plus the API layer, MCP server, demo data and onboarding are implemented. See
[`app/docs/PROJECT-STATUS.md`](app/docs/PROJECT-STATUS.md) for the current build state and open items.

## License & publisher

Set your publisher and license before an AppSource build (`app/app.json`, `test/app.json`, `AppSourceCop.json`).
