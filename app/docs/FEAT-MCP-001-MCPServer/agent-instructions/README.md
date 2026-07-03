# MCP agent instructions

One file per **MCP configuration** the app creates (see [`NBC MCP Setup`](../../../src/Core/MCPSetup.Codeunit.al)).
Each file is the ready-to-paste **agent instructions**: when you connect a GitHub Copilot agent to a BC MCP
configuration, copy the matching file's contents into that agent's instructions.

Business Central (28.2) has no field for agent instructions on an MCP configuration — only a `Description` — so these
live here, version-controlled, and are pasted manually. **One configuration ↔ one agent ↔ one file.**
Keep each file in sync with its configuration's tools: add/remove/rename a tool → update its file; add a config →
add a file. See `bc-dev-templates/.../_patterns/mcp-configuration-instructions.md`.

## Functional configurations (`SeedModuleConfigurations`)
| Configuration | File | Tools |
|---|---|---|
| NBC CRM Ownership | [NBC-CRM-Ownership.md](NBC-CRM-Ownership.md) | Teams, Team Members |
| NBC CRM Activities | [NBC-CRM-Activities.md](NBC-CRM-Activities.md) | Activities |
| NBC CRM Opportunity | [NBC-CRM-Opportunity.md](NBC-CRM-Opportunity.md) | Opportunities, Lines, Competitors, Stakeholders |
| NBC CRM Process | [NBC-CRM-Process.md](NBC-CRM-Process.md) | Processes, Stages, States |
| NBC CRM Catalog | [NBC-CRM-Catalog.md](NBC-CRM-Catalog.md) | Bundles, Bundle Lines, Product Relations, Item/Resource CRM |
| NBC CRM Pricing | [NBC-CRM-Pricing.md](NBC-CRM-Pricing.md) | Discount Lists, Discount Tiers, Price Line CRM |
| NBC CRM Party | [NBC-CRM-Party.md](NBC-CRM-Party.md) | Customers CRM, Contacts CRM |

## Demo-import configurations (`SeedDemoConfigurations`)
Each exposes a single `importDemoData` action (its own `demo<Feature>` API group).
| Configuration | File |
|---|---|
| NBC Demo Ownership | [NBC-Demo-Ownership.md](NBC-Demo-Ownership.md) |
| NBC Demo Activities | [NBC-Demo-Activities.md](NBC-Demo-Activities.md) |
| NBC Demo Party | [NBC-Demo-Party.md](NBC-Demo-Party.md) |
| NBC Demo Opportunity | [NBC-Demo-Opportunity.md](NBC-Demo-Opportunity.md) |
| NBC Demo Process | [NBC-Demo-Process.md](NBC-Demo-Process.md) |
| NBC Demo Role Center | [NBC-Demo-RoleCenter.md](NBC-Demo-RoleCenter.md) |
| NBC Demo Governance | [NBC-Demo-Governance.md](NBC-Demo-Governance.md) |
| NBC Demo Catalog | [NBC-Demo-Catalog.md](NBC-Demo-Catalog.md) |
| NBC Demo Pricing | [NBC-Demo-Pricing.md](NBC-Demo-Pricing.md) |
| NBC Demo Linkage | [NBC-Demo-Linkage.md](NBC-Demo-Linkage.md) |
