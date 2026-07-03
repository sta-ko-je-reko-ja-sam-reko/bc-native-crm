# FEAT-MCP-001 - MCP Server

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** `NBC MCP Setup` (codeunit 50110) — no new AL objects beyond it; it wires the existing API
> pages (FEAT-API-001) and demo importers (demo-data layer) into Business Central MCP configurations.
> **Namespaces:** `NBC.Core` (the MCP seed codeunit). The exposed tools are the API pages in their feature namespaces.

Exposes the CRM to **AI agents (GitHub Copilot and other MCP clients)** through Business Central's built-in **MCP
server**. BC's MCP server publishes **API pages as agent tools**, organised into **MCP configurations**; an agent
connects to one configuration and sees only that configuration's tools. This feature builds those configurations and
ships the per-configuration **agent instructions**. It reuses — does not add — the API surface from
[FEAT-API-001](../FEAT-API-001-ApiAndMcp/technical-documentation.md) and the demo importers from the demo-data layer.

## Business Process

1. An admin **enables the MCP server** in Business Central (Feature Management / MCP setup) and, once, runs the CRM
   MCP seed to create the configurations (`NBC MCP Setup.SeedModuleConfigurations` + `SeedDemoConfigurations`).
2. Each **MCP configuration** exposes a scoped tool set — a functional module (e.g. *catalog*) or a single feature's
   **demo-data importer**.
3. In **GitHub Copilot**, the admin creates an agent, connects it to one BC MCP configuration, and **pastes that
   configuration's agent-instructions file** ([`agent-instructions/`](agent-instructions/)) into the agent's
   instructions — so the agent knows its domain, tools and constraints.
4. The agent now operates that slice of the CRM (read/write its entities, or seed its sample data) within the
   guardrails the instructions define.

## Design decisions

1. **Public facade only.** `NBC MCP Setup` builds configurations through the public `codeunit 8350 "MCP Config"`
   (`CreateConfiguration` / `CreateAPITool` / `AllowRead|Create|Modify` / `ActivateConfiguration`) — it **never
   writes the MCP tables directly**.
2. **One functional configuration per module (7).** `SeedModuleConfigurations` creates a config per module group
   (ownership, activities, opportunity, process, catalog, pricing, party), each exposing that module's API pages as
   read/write tools. Grouping matches the per-module permission sets, so an agent's reach mirrors a licensed user's.
3. **One demo-import configuration per feature (10).** `SeedDemoConfigurations` creates a config per feature, each
   exposing **only** that feature's `importDemoData` action (its own `demo<Feature>` API group) — so each importer
   can be attached to a **different** agent, kept separate from the functional configs. See the demo-data layer.
4. **Not auto-run.** The seed is invoked by an admin (assisted-setup candidate), never on install — creating/
   activating MCP configurations is an administrative act.
5. **Agent instructions are markdown files, one per configuration — BC has no instructions API.** Verified against
   the 28.2 System Application symbols: `MCP Config` exposes only `Name` + `Description[250]`; there is **no field or
   method** that carries agent instructions to the connected client (the config card shows Name/Active/Default/
   Description/dynamic-tool-mode only). So the instructions live as **17 version-controlled `.md` files** under
   [`agent-instructions/`](agent-instructions/) (7 functional + 10 demo), pasted manually into each Copilot agent.
   The config `Description[250]` is used only as a short pointer to the file. **Sync rule:** add/update a
   configuration or its tools → add/update its agent-instructions file.

## Configurations

**Functional (`SeedModuleConfigurations`)** — read/write tools over the FEAT-API-001 pages:

| Configuration | Tools (API pages) |
|---|---|
| NBC CRM Ownership | Team, Team Member |
| NBC CRM Activities | Activity |
| NBC CRM Opportunity | Opportunity, Opp. Line, Opp. Competitor, Opp. Stakeholder |
| NBC CRM Process | Process, Process Stage, Process State |
| NBC CRM Catalog | Bundle, Bundle Line, Product Rel., Item, Resource |
| NBC CRM Pricing | Discount List, Discount Tier, Price Line |
| NBC CRM Party | Customer, Contact |

**Demo importers (`SeedDemoConfigurations`)** — one `importDemoData` tool each, in its own `demo<Feature>` group:
NBC Demo Ownership · Activities · Party · Opportunity · Process · Role Center · Governance · Catalog · Pricing ·
Linkage.

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| codeunit | 50110 | NBC MCP Setup | Builds the functional + demo MCP configurations via the `MCP Config` facade. |

## Files

```
app/src/Core/MCPSetup.Codeunit.al
app/docs/FEAT-MCP-001-MCPServer/
├── technical-documentation.md
├── getting-started-english.md
└── agent-instructions/                 ← 17 agent-instruction files + README (one per configuration)
```

## Integration Points

| Point | Detail |
|---|---|
| BC MCP server | publishes each configuration's API-page tools (+ `[ServiceEnabled]` demo actions) to MCP clients |
| GitHub Copilot | an agent binds to one configuration; its instructions come from the matching `agent-instructions/` file |
| MCP seed | `NBC MCP Setup.SeedModuleConfigurations` / `SeedDemoConfigurations` (admin-invoked, via `MCP Config` facade) |

## Dependencies

| Dependency | Usage |
|---|---|
| FEAT-API-001 (API layer) | the API pages that become the functional MCP tools |
| Demo-data layer | the `importDemoData` actions that become the demo MCP tools |
| BC System Application `MCP Config` (8350) | the public facade used to build configurations |

## Known Limitations

- **Agent instructions are manual.** BC 28.2 has no per-configuration instructions field, so instructions are md
  files pasted into each Copilot agent by hand (see design decision 5). If a future BC version adds an instructions
  API, move the text there and set it in `NBC MCP Setup`.
- **The Tier-4 Linkage API pages (`NBC CRM API Sales Order`/`Sales Invoice`, 50150–50151) are not yet in a functional
  MCP configuration** — `SeedModuleConfigurations` predates them. Follow-up: add a `linkage`/`pipeline` functional
  config exposing them + its `agent-instructions/NBC-CRM-Linkage.md` file.
- **The seed is not auto-run** — an admin invokes it (intended behind an Assisted Setup).
