# native-bc-crm — Project Status, Decisions & Open Items

The git-tracked source of truth for this project's state. It travels with the repo, so a future session on any
machine (with no assistant memory) has the full picture. **Keep it current as work proceeds.**

Last updated: 2026-07-03 · Version `0.4.0.0` · BC 28.2 · container `crm2802`.

## What's built (all compiling green on `crm2802` symbols)

Build targets: **PTE** (default, ships in 50000 range) and **AppSource** (`alc /define:APPSOURCE`, drops
PerTenantExtensionCop, includes the `#if APPSOURCE` entitlements). Both `exit=0`; test app `exit=0`. Tests are
**compiled but not yet run** (no container test runner wired up).

| Tier / area | Features | Status |
|---|---|---|
| Tier 0 | Ownership & Teams · Activities & Timeline | ✅ |
| Tier 1 | Opportunity Depth · Party Enrichment | ✅ |
| Tier 2 | Business Process Flow · Role Center · Governance | ✅ |
| Tier 3 | Product Sales Catalog · Pricing Flexibility | ✅ |
| API | 22 API pages (FEAT-API-001; +2 in Tier 4) | ✅ |
| MCP Server | 17 MCP configurations (7 functional + 10 demo) + per-config GitHub Copilot agent instructions (FEAT-MCP-001) | ✅ |
| Licensing | 3 cumulative AppSource entitlements | ✅ |
| Setup/toggle | Per-feature setup + `Enabled` + ApplicationArea + AccessByPermission gating (FEAT-SETUP-001) | ✅ |
| **Tier 4** | Transaction ↔ pipeline linkage — order Opportunity link + CRM sales status, invoice stamp on post, opportunity→orders/invoices rollup (FEAT-LNK-001) | ✅ |
| Demo data | 10 CRONUS-style seeders (one per feature) + 10 `[ServiceEnabled] ImportDemoData` APIs, each in its own `demo<Feature>` API group + own MCP config; master `SeedAll`; `NBC Demo` permset | ✅ |
| Onboarding | 10 per-feature **Assisted Setup wizards** (enable + **sample-data opt-in** with instructional description → same `Import()`), Guided Experience registration, `NBC Onboarding` permset — the end-user (non-MCP) path to demo data | ✅ |

Each feature has `app/docs/FEAT-*/technical-documentation.md` + `getting-started-english.md`; the master
[`getting-started-english.md`](getting-started-english.md) indexes them. The spec/backlog is the project skill
[`.claude/skills/dataverse-crm-integration/`](../../.claude/skills/dataverse-crm-integration/) (gap analyses + the
Tier 0–4 "what to build" README).

## Object ID map (50000-block)

| Range | Owner |
|---|---|
| 50000 | Core (Service Locator, Foundation permset) |
| 50020–50023 | Ownership |
| 50030–50033 | Activities |
| 50040–50043 | Opportunity |
| 50050–50051 | Party Enrichment (tableext fields 50050–50057 on Customer/Contact) |
| 50060–50063 | Business Process Flow |
| 50070–50072 | Role Center (incl. `NBC CRM Cue` — see gotchas) |
| 50080–50081 | Governance |
| 50090–50099 | Product Catalog |
| 50100–50109 | Pricing Flexibility |
| 50110–50121 | Feature Mgt facade (50120), App Area subscriber (50121), MCP setup cu (50110) |
| 50110–50129 | **API pages** (14 over custom tables + 6 over extended standard tables) |
| 50130–50138 | Feature setup tables + setup pages; `NBC Feature` enum (50130); `NBC App Area Setup` tableext (50130) |
| 50139–50151 | **Tier 4 Linkage** (FEAT-LNK-001): setup table/page 50139 (`NBC Linkage` app-area field 50139, `NBC Feature::Linkage`); sales-status enum + tableexts 50140–50142 (Sales Header/Sales Inv. Header/Opportunity); codeunits 50141–50143 (Mgt/Reactions/Subscribers); pageexts 50143–50145 (Sales Order/Posted Sales Invoice/Opp Card); permset 50140; **API pages 50150–50151** (`NBC CRM API Sales Order`/`Sales Invoice`) |
| 50111–50113 | Licensing permsets (`NBC CRM/CDS/Core License`, `#if APPSOURCE`) |
| 50160–50182 | **Demo data**: dummy `NBC Demo Data` table (50160); 10 seeder codeunits 50161–50170; master `NBC Demo Data Mgt.` (50181); 10 import API pages 50171–50180 (each its own `demo<Feature>` API group); config-package helper `NBC Demo Config Package` (codeunit 50182) + `NBC Demo` permset (50182). MCP demo configs seeded via `NBC MCP Setup.SeedDemoConfigurations()` |
| 50183–50193 | **Onboarding**: `NBC Wizard Step` enum (50183) + `NBC Assisted Setup` registration codeunit (50183); 10 per-feature Assisted Setup wizard pages 50184–50193; `NBC Onboarding` permset (50184). Each wizard enables its feature + offers a sample-data opt-in that calls the same `NBC Demo <Feature>.Import()` |
| 50900–50907 | Test codeunits (own block; +50906 Linkage, +50907 Demo Data idempotency) |

## Key decisions

- **Naming:** one prefix `NBC` + layer tag — `NBC CDS <name>` (Dataverse base), `NBC CRM <name>` (D365 Sales),
  plain `NBC <name>` (Core). Filenames strip the `NBC ` affix, keep the rest, remove spaces
  (`NBC CRM Bundle` → `CRMBundle.Table.al`); test files keep their own convention.
- **API layer:** publisher `nbc`, `v1.0`, per-module `APIGroup`. Extended standard tables get a **new** API page
  (API pages can't be extended) = **a FULL clone of Microsoft's matching APIV2 page + the affix fields** (Customer/
  Contact/Opportunity/Item cloned from GitHub `microsoft/ALAppExtensions/.../APIV2/app/src/pages` — they're NOT in
  `.alpackages`; MS sub-parts dropped as they bind to unavailable APIV2-app pages). Resource + Price List Line have
  no MS APIV2 page → authored comprehensively. (An earlier pass shipped minimal identity+affix pages — useless to
  MCP; corrected.) Cue/buffer/setup tables get no API page.
  **API coverage audit (verified):** all 14 custom business tables + all 6 extended standard tables have API
  pages; `NBC CRM Cue` excluded (cue holder); **the 9 feature `Setup` tables are deliberately excluded** — feature
  enablement is admin-UI/assisted-setup only because toggling has a session-restart side effect a plain `PATCH`
  would bypass (see FEAT-API-001 §5b). Re-run the API-coverage check whenever a feature adds a persisted table.
- **Entitlements (AppSource):** **3 cumulative plans — Core ⊂ CDS ⊂ CRM.** Non-assignable license permsets nest
  via `IncludedPermissionSets` (`NBC CRM License` ⊇ `NBC CDS License` ⊇ `NBC Core License`); entitlements
  `NBC Core/CDS/CRM Ent` (`Type = PerUserOfferPlan`, `Id` = placeholder → set to the Partner Center Service ID at
  onboarding). All wrapped in `#if APPSOURCE` (PTE range can't hold an entitlement — PTE0013). An "advanced
  Dataverse" plan later slots between CDS and CRM.
- **Feature setup/toggle (per-feature granularity):** 9 single-record setups, each with a dedicated
  `ApplicationArea` toggled from `Enabled`; surfaced controls gated by `AccessByPermission = tabledata
  "NBC <Feature> Setup" = R`; API write-guards via `CheckEnabled`. **Features default disabled** — enable per
  feature after publish.
- **Enablement UI is `ApplicationArea = All`; operational UI is the dedicated area — never the reverse.** Because
  features ship **disabled** (their area off), the **Setup pages** (and any future **assisted-setup wizard**) must be
  `All` at object level, or a fresh install hides the very switch needed to turn a feature on — a bootstrap deadlock
  (all 9 setup pages are `All`, carrying only the `Enabled` field). The dedicated area's sole purpose is to gate a
  feature's **operational** surface (its own pages + controls injected onto standard pages) on/off with `Enabled`.
  On the **Role Center**, each cue part / nav action / processing action now carries the area of the feature it
  exposes (`NBCOwnership`/`NBCActivities`/`NBCOpportunity`/`NBCProcess`/`NBCGovernance`; the two cue parts stay
  `NBCRoleCenter`, matching the cue pages) — a disabled feature drops cleanly off the home page, as BaseApp Role
  Centers do. Corrected from an earlier pass that put `All` on all 9 Role Center controls. See bc-dev-templates
  `feature-setup-and-toggle.md` §4a + greenfield `feature-ready.md`.
- **House patterns:** polymorphic table-logic (interface + `<X> Logic`, one-line trigger delegation), pure-proxy
  subscribers via `NBC Service Locator`, ToolTips on table fields, two JS control add-ins (Timeline, Process Bar).
- **Tier 4 (FEAT-LNK-001) — linkage only, no fulfillment/accounting rebuild.** Enriches `Sales Header` (Opportunity
  link + `NBC CRM Sales Status` + pricing-locked), `Sales Invoice Header` (read-only Opportunity link, stamped at
  posting by a pure-proxy subscriber on `Sales-Post.OnAfterSalesInvHeaderInsert` → `Service Locator.LinkageReactions()`
  → interface impl, `Enabled`-guarded), and `Opportunity` (linked order/invoice count FlowFields + drill-downs). BC's
  posting/VAT/ledger are untouched. `Fulfilled` is a **manual** sales status (a fully posted order is deleted, so
  there is nothing to auto-flip) — see FEAT-LNK-001 Known Limitations.
- **Tier 4 API pages (per the "full MS APIV2 clones" choice):** the two new API pages (`NBC CRM API Sales
  Order`/`Sales Invoice`, 50150–50151, `APIGroup='pipeline'`) mirror Microsoft's APIV2 sales order/invoice **field
  surface** but **source the base table directly** (`Sales Header`/`Sales Invoice Header`) — the same house practice
  as the Customer/Item clones — because MS's APIV2 pages bind a `Sales Order Entity Buffer` aggregate that is not a
  symbol dependency here. Document totals + MS sub-parts are omitted (documented). Order API is writable with
  `CheckEnabled` write-guards; the posted-invoice API is read-only (immutable document).
- **Demo data (CRONUS-style) — one seeder + one import API per feature, each in its own API group / MCP config.**
  Ten idempotent `NBC Demo <Feature>` codeunits (fixed keys + `Get`-guard; `Validate` through logic; defensive
  `Get`-guards on standard CRONUS master data so they no-op on a non-CRONUS company) cover every field/enum/relation
  of each feature; a master `NBC Demo Data Mgt.SeedAll()` runs them in dependency order (ownership/party/catalog/
  pricing → opportunity → process/activities/governance/rolecenter → linkage). Each feature also ships a thin
  `NBC API Demo <Feature>` page whose **`[ServiceEnabled] ImportDemoData`** action is the MCP tool, deliberately in a
  **dedicated per-feature API group** (`demo<Feature>`, never a functional group) so each importer binds to its
  **own MCP configuration** (`SeedDemoConfigurations()`) and can be attached to a **different GitHub Copilot agent**.
  All share a dummy `NBC Demo Data` source table; all in the `NBC Demo` permset (in the CRM license). Pattern +
  skill added to bc-dev-templates (`demo-data-and-import-apis.md`, `generate-demo-data`, feature-ready gate item).
- **RapidStart Config. Package per feature, built only on demo-data opt-in.** Each seeder's `Import()` also builds a
  standard **Config. Package** (via shared helper `NBC Demo Config Package`, codeunit 50182, over base
  `Config. Package Management` 8611) — so a feature's package is created **only when the user imports that feature's
  demo data** (Assisted Setup opt-in or MCP `importDemoData`), never eager. 10 packages (`NBC-<FEATURE>`): own tables
  (all fields) + extended standard tables **narrowed to PK + affix fields** (FlowFields skipped); **the feature
  `Setup` table is never added** (setup is prepopulated via Assisted Setup / manual / MCP). Role Center + Governance
  own no tables → header-only packages. Idempotent on the package code. `NBC Demo` permset grants the three
  `Config. Package*` tabledata + the helper. See bc-dev-templates `demo-data-and-import-apis.md` §6.
- **MCP agent instructions — one markdown file per MCP configuration (`app/docs/FEAT-MCP-001-MCPServer/agent-instructions/`).**
  BC 28.2's `MCP Config` facade exposes only `Name` + `Description[250]` — **there is no agent-instructions
  API/field** (verified by extracting the System Application symbols; the config card has Name/Active/Default/
  Description/dynamic-tool-mode only). So per-agent instructions can't live in BC; they're shipped as **17
  version-controlled `.md` files** (7 functional + 10 demo configs), each pasted manually into the GitHub Copilot
  agent wired to that configuration. Keep each file in sync with its config's tools (add/remove tool → update file;
  add config → add file). Pattern: bc-dev-templates `mcp-configuration-instructions.md` + feature-ready gate item.
- **Subscribers to MS/base publishers must not break the tenant for unentitled users.** `NBC CDS Owner Subscribers`
  + `NBC App Area Subscriber` are entitled **`Unlicensed`** (permset `NBC Base Subscribers` + `#if APPSOURCE`
  entitlement `NBC Base Ent`) so the subscription never errors for any user; each forwards only after checking the
  user's **effective** permission — via MS `Effective Permissions Mgt.PopulatePermissionBuffer` → temporary
  `Permission Buffer` **by object id** (never by instantiating our own, possibly unlicensed, object; and not the
  deprecated `Permission` table). `Feature Mgt.IsEnabled`
  guards each setup read the same way. See bc-dev-templates `event-subscribers.md`.
- **The effective-permission check is now a swappable interface** — `NBC IAccessPolicy` + default impl
  `NBC Access Policy` (50001), both granted via the Unlicensed `NBC Base Subscribers` set and resolved through
  `NBC Service Locator.AccessPolicy()` (`HasEffectiveExecute` / `HasEffectiveRead`, cached per session). This
  consolidated the check that was **duplicated** in the owner subscriber + `Feature Mgt.` into one place, and let the
  owner subscriber return to a **pure proxy** (no globals/helpers — the guard is now a one-line delegation). A
  customer/downstream app can inject a different policy via `ImplementAccessPolicy`. Both the Service Locator and the
  access policy are in the Unlicensed set precisely so every user can resolve the check **without instantiating a
  licensed object**. (The *tolerance* guard is never swapped to error unentitled users — errors belong in the
  **reaction**, which only runs for entitled users.)

## AL gotchas hit here (generalizable ones belong in bc-dev-templates)

- **`ApplicationArea` / `AccessByPermission` are NOT valid on a layout `group` control (AL0124)** — set them on
  each `field` / `action` / `part`, not the group.
- **JS→AL control add-in** calls `Microsoft.Dynamics.NAV.InvokeExtensibilityMethod` (NOT `InvokeMethod`) — alc
  doesn't compile JS, so a wrong name builds fine but is a silent runtime no-op.
- **Custom `Application Area Setup` boolean fields need `DataClassification` (SystemMetadata)** — else AS0016.
- **Card pages reached only via `CardPageId` need `UsageCategory = None`** (else AW0006).
- **Context-restricted action images** — e.g. `Team` invalid on a Role Center section action; `CalculateSalesPrice`
  invalid on a Price List Lines action (AL0482). Verify the image is valid for the control type.
- **AppSourceCop** needs a complete `app.json` manifest (brief/description/URLs/logo — AS0051/AS0052) and the affix
  on pageext control/action/group identifiers (AS0011).
- **Test object IDs** must not overlap app IDs across the dependency graph (AL0264) — hence the 50900 block.
- `User Setup` salesperson field is **`Salespers./Purch. Code`** (not "Salesperson Code").
- Checking permission by instantiating your **own** object (`MyTable.ReadPermission()`) can itself error for an
  unlicensed user — check **effective** permission by object id through MS `Effective Permissions Mgt.` instead.
- MS `Permission` table (2000000004) is **ObsoletePending** (AL0432 → use `Expanded Permission`). We check
  effective permission via `Effective Permissions Mgt.PopulatePermissionBuffer` → `Record "Permission Buffer"`
  (which reads `Expanded Permission` + entitlements internally) — so our code never touches the deprecated table.
  `Permission Buffer` returns one row per source; filter `Execute/Read Permission <> ::" "` and test `not IsEmpty`.
- Entitlement `Type` set: PerUserOfferPlan / PerUserServicePlan / Unlicensed / Role / Group / Application /
  ApplicationScope. We use **PerUserOfferPlan** for the 3 paid plans and **Unlicensed** for the base-subscriber set.

## Open gate items (run `feature-ready.md` before calling anything done)

- ⬜ **Integration tests + actually running the suite** — only DB-free unit tests exist (50900–50906) and none have
  executed; wire up the `crm2802` test runner and add integration tests for DB-bound behavior (estimated-revenue
  roll-up, bundle component total, change-log audit, **Tier 4: invoice stamped with the opportunity on posting +
  opportunity order/invoice count roll-up**).
- ⬜ **Telemetry on key transactions** (AppSource discipline).
- ⬜ **Build not yet run for 0.4.0.0 (Tier 4 + demo data + onboarding wizards)** — all objects were authored to the
  house patterns but `alc` was not available in the authoring session; compile both targets (PTE +
  `/define:APPSOURCE`) on `crm2802` and resolve any diagnostics before calling these gate-complete. **Highest-risk
  spot to check first:** `NBC Assisted Setup` (50183) — the `Guided Experience.InsertAssistedSetup(...)` overload +
  `"Assisted Setup Group"` enum value are version-sensitive; if the signature differs in 28.2, adjust that one call.
  Second: the wizard pages bind display `field(...)` sources directly to `Label` variables — if the compiler rejects
  that, swap each to a `Text` global assigned from the label.
- Note: base `CRM.g.xlf` is generated (TranslationFile on) — **regenerate it for the Tier 4 captions/labels** on the
  next build; no 2nd-language xlf (English-only, OK).

## Root-cause note for future sessions

Three whole classes of work (API pages, getting-started docs, feature setup/toggle+gating) slipped across
Tiers 0–3 because the `feature-ready.md` checklist was **not run as a gate** — "compiles + tech doc + unit test"
was mistaken for done, and the existing repo's (incomplete) precedent was treated as the standard. **Run the gate
per feature.** Generalizable AL/BC lessons propagate to `../bc-dev-templates/`; product-specific status/decisions
stay here.
