# Native CRM for Business Central

A complete CRM built natively inside Business Central — ownership and teams, a unified activity timeline, deeper
opportunities, richer customer and contact detail, a guided sales process, a salesperson home page, governance,
a product sales catalog, flexible pricing, and connections for other apps and AI assistants. No separate CRM
system to provision — it all lives in Business Central.

## Start here

Adopt the app in this order for the smoothest onboarding:

1. **Assign roles and set the home page** — switch salespeople to the **CRM Manager** home page. See
   [Role Center](FEAT-RC-001-RoleCenter/getting-started-english.md).
2. **Set up ownership** — create teams and give records an owner. See
   [Ownership and Teams](FEAT-OWN-001-OwnershipAndTeams/getting-started-english.md).
3. **Turn on governance** — enable audit logging once, up front. See
   [Governance](FEAT-GOV-001-Governance/getting-started-english.md).
4. Then adopt the functional areas below as you need them.

## What's inside

### Everyday selling
- [Ownership and Teams](FEAT-OWN-001-OwnershipAndTeams/getting-started-english.md) — who owns each record, and
  focusing on your own.
- [Activities and Timeline](FEAT-ACT-001-ActivitiesAndTimeline/getting-started-english.md) — log every
  interaction and read it on one timeline.
- [Opportunity Depth](FEAT-OPP-001-OpportunityDepth/getting-started-english.md) — products, competitors,
  stakeholders, rating and estimated value on a deal.
- [Business Process Flow](FEAT-BPF-001-BusinessProcessFlow/getting-started-english.md) — a guided, staged
  progress bar on the opportunity.
- [Transaction Pipeline Linkage](FEAT-LNK-001-PipelineLinkage/getting-started-english.md) — link orders and posted
  invoices back to their opportunity, with a sales status and order/invoice roll-up on the deal.

### Customer & contact detail
- [Party Enrichment](FEAT-PTY-001-PartyEnrichment/getting-started-english.md) — classification, firmographics,
  hierarchy and contact preferences.

### Products & pricing
- [Product Sales Catalog](FEAT-CAT-001-ProductCatalog/getting-started-english.md) — selling lifecycle, bundles
  and related-product suggestions.
- [Pricing Flexibility](FEAT-PRC-001-PricingFlexibility/getting-started-english.md) — pricing methods, rounding
  and reusable discount tiers.

### Home & governance
- [Role Center](FEAT-RC-001-RoleCenter/getting-started-english.md) — the salesperson home page and its tiles.
- [Governance](FEAT-GOV-001-Governance/getting-started-english.md) — audit logging and duplicate detection.

### Connect & automate
- [Connect and Automate](FEAT-API-001-ApiAndMcp/getting-started-english.md) — make the CRM data available to other
  apps and Power Platform.
- [MCP Server for AI agents](FEAT-MCP-001-MCPServer/getting-started-english.md) — connect a GitHub Copilot agent to
  the CRM, per area, with ready-made agent instructions.

## Load sample data (optional)

Want a filled-in sample company to explore, like the standard demo company? You can load ready-made CRM sample
records — teams and owners, activities, opportunities with lines and stakeholders, catalog bundles, price tiers,
duplicate customers, and orders linked to opportunities.

- **While setting up a feature (recommended):** open **Assisted Setup** and run the setup guide for the feature. Each
  guide has an **Import sample data** step with a full description of exactly what it will add — tick it to load that
  feature's samples as you turn the feature on.
- **All at once:** an administrator runs **Seed all** — it fills every area in the right order. Running it again does
  nothing extra (it never creates duplicates).
- **For AI assistants:** each area also has its own connector, so you can let a specific assistant load just that
  area's samples.
- Sample data builds on the standard demo company's customers and items; on an empty company it simply loads what it
  can. It's safe to run more than once.
- **A Configuration Package is created too.** Whenever you import a feature's sample data, a standard RapidStart
  **Configuration Package** for that area (named `NBC-<area>`) is created — so an administrator can review it, apply
  it, or **export it to reuse the setup in another company**. It's created only when you import that feature's sample
  data, and it never includes the feature's *setup* record — that stays under your control in the setup guide.

