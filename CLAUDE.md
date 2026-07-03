# native-bc-crm — Native CRM for Business Central (Greenfield ISV)

A from-scratch Microsoft Dynamics 365 Business Central AL extension that **natively reimplements, inside BC, the
Dynamics 365 / Dataverse CRM capabilities that BC does not have** — with **no dependency on Dataverse, the CRM
connector, or the CRM proxy tables**. This is a **greenfield ISV product** built to **AppSource standards** but
shipped in the **PTE object ID range (50000–99999)**. Not a Navision/NAV port; not a Dataverse integration.

## Purpose (read this first)

BC ships a Dataverse/D365 Sales **integration** (sync engine + proxy tables) — we deliberately **do not** use it.
Instead we take the *feature set* of the Dataverse/D365 Sales platform and build the missing pieces **as native
BC objects**, so a BC customer gets CRM without ever provisioning Dataverse.

**The spec is already written** — the platform-by-platform gap analysis lives in the project skill
[`.claude/skills/dataverse-crm-integration/`](.claude/skills/dataverse-crm-integration/):
- [`README.md`](.claude/skills/dataverse-crm-integration/README.md) — the prioritized **"what to build"** synthesis (Tier 0–4) and the **"what NOT to build"** (BC already owns it) list.
- [`architecture.md`](.claude/skills/dataverse-crm-integration/architecture.md) — how the standard integration works + the entity map (§2). **Reference only** — we don't implement the sync.
- One `*-vs-bc-*.md` per entity (account, contact, systemuser, product, pricelevel, opportunity, salesorder, invoice, currency+options) — the authoritative gap list per feature.

Each gap analysis ends with the net gaps a BC-native CRM must close; those are the backlog.

## The build decision framework (per gap)

For every Dataverse/CRM capability, size the gap vs standard BC and pick the lightest option that fits:

| Gap size | Approach |
|---|---|
| **None** (BC already equal/richer — e.g. Currency, accounting, inventory, posting) | Do nothing. Reuse standard BC. |
| **Minor / additive** | `tableextension` / `pageextension` on the standard BC object. Surface new UI under a dedicated **`CRM`** group (`group(CRM)`) and new page actions under a **`CRM`** action **category** (promoted action category). |
| **Large / structural** (no BC home — e.g. ownership+teams, activity timeline, opportunity depth, party hierarchy) | Build **custom BC entities** (new tables + pages + codeunits). |
| **Graphical, valuable, un-renderable in native AL** (timeline control, BPF stage bar, hierarchy chart, Kanban) | Build a **JavaScript control add-in** (`controladdin`) hosted on a BC page. See the shared `controladdin.md` guide. |

Prefer BC's own models first: home CRM-party behaviour on **Contact + Relationship Management** (Customer/Vendor
as role projections), reuse **Dimensions** for classification and **Price Lists** for pricing before inventing
new objects. Extend, never edit base.

## Source layout

`app/src/` is split by platform layer (mirrors the CDS-vs-Sales split in architecture.md §2), feature-grouped inside:

- [`app/src/Dataverse/`](app/src/Dataverse/) — CDS base layer: account (Customer/Vendor/Contact), contact, systemuser (Salesperson), currency + option sets.
- [`app/src/CRM/`](app/src/CRM/) — D365 Sales layer: product/UoM, price list, opportunity, sales order, invoice.
- Plus the usual cross-cutting folders as needed (`Core`, `Setup`, `PermissionSet`) per the greenfield layout.

## Methodology & shared conventions (from bc-dev-templates)

This project follows the **bc-greenfield-template** methodology and the shared AL conventions/object-type guides in
**bc-customer-project-template**, both in the sibling repo [`../bc-dev-templates/`](../bc-dev-templates/):

- **Feature workflow** — `intake → design → document → implement AL → (optional data import) → test → deliver`, one `app/docs/FEAT-<CRM>-<Title>/` folder per feature. See `../bc-dev-templates/bc-greenfield-template/instructions/02-feature-workflow.md`.
- **AL authoring** — the canonical per-object-type guides + metamodel: `../bc-dev-templates/bc-customer-project-template/al-object-types/`. Read standard objects from `.alpackages` symbols; don't assume field/event names.
- **Ruleset** — `app/ruleset.json` (synced from `bc-customer-project-template/ruleset.json`). Zero-error builds.
- **House patterns already proven on bc-construction-management** (in the shared templates): the **polymorphic table-logic** pattern (no logic in triggers/subscriber bodies — delegate one line to a swappable interface impl), **pure-proxy event-subscriber codeunits** via a Service Locator, ToolTips on **table fields** not page fields, filename = object-name-minus-affix incl. feature prefix, multiple tableextensions per base object allowed. Follow the guides — don't reinvent.
- **Definition of done** — `../bc-dev-templates/bc-greenfield-template/checklists/feature-ready.md`.

### Working a feature
1. `plan-feature {CRM-MARK} {Title}` — scaffold `app/docs/{MARK}-{Suffix}/`, draft `technical-documentation.md` (pick the gap analysis it implements).
2. `implement-bc-object` — write AL per the shared object-type guides into `app/src/Dataverse/…` or `app/src/CRM/…`.
3. Tests (`test/`) + getting-started docs + translations + version bump.
4. Gate: `feature-ready`.

## Project-specific values

| What | Value |
|---|---|
| Affix / prefix | **`NBC`** (one registered prefix on every object + every new field on a standard table). Descriptive **layer tag** in the name: `NBC CDS <name>` = Dataverse-base layer, `NBC CRM <name>` = D365-Sales layer, plain `NBC <name>` = Core/cross-cutting. |
| Object ID range | `50000–99999` (PTE) |
| API layer | `PageType = API` publisher **`nbc`**, version `v1.0`, per-module `APIGroup` (ownership/activities/opportunity/process/catalog/pricing/party). One API page per persisted custom table + a **new** API page per extended standard table (API pages can't be `pageextension`-ed). |
| BC version target | `28.2.0.0` (platform `28.0.0.0`, runtime `17.0`) — dev container **`crm2802`** (Sandbox 28.2; web `http://crm2802/BC/?tenant=default`) |
| Primary language | English (international) — single language, so getting-started docs are `getting-started-english.md` only (no `-<lang>`) |
| Publisher | `YourCompany` — **placeholder; set in `app/app.json`, `test/app.json`, `AppSourceCop.json` before an AppSource build** |
| Version | bump `app.json` + `test/app.json` (+ its dependency) together before any customer-facing build |
| CI/CD | **AL-Go for GitHub** (PTE template v9.0) — `.github/` + `.AL-Go/settings.json` (appFolders=[app], testFolders=[test], country=w1) |

> Symbols are downloaded locally from the `crm2802` container into `app/.alpackages` (BC 28.2). Build with the
> extension's `alc.exe` + the four analyzers (CodeCop, AppSourceCop, UICop, PerTenantExtensionCop) against
> `app/ruleset.json`. **Two build targets:** the default **PTE** build ships in the 50000 range; the **AppSource**
> build adds `/define:APPSOURCE` (and drops PerTenantExtensionCop) to include the `#if APPSOURCE` entitlements —
> a PTE extension cannot contain an `entitlement` (PTE0013).

## Project status, decisions & open items

**See [`app/docs/PROJECT-STATUS.md`](app/docs/PROJECT-STATUS.md)** — the git-tracked living log of what's built (tiers,
API layer, entitlements, feature setup/toggle), the key decisions (naming, ID map, 3-tier cumulative entitlements,
per-feature setups), the AL gotchas hit here, and the **open gate items** (integration tests + running the suite,
telemetry). Update it as work proceeds — it is the source of truth that travels with the repo (do not rely on any
assistant's machine-local memory).

## Hard rules

- **No Dataverse.** No CRM connector, no `CRM *`/`CDS *` proxy tables, no Integration Table Mapping, no coupling. We reimplement the *behaviour*, natively.
- **Extend, never edit base** — tableextension/pageextension/enumextension + event subscribers (pure-proxy codeunits).
- **Use BC's models** — Dimensions, Price Lists, Dimension Set, standard posting routines; build CRM on Contact/RM.
- **Mandatory affix `NBC`** on every new object and every new field on a standard table (+ layer tag `CDS`/`CRM` in the name). **Object IDs** inside 50000–99999. **Zero CodeCop errors** on build.
- **ISV/AppSource discipline** — upgrade-safe (ObsoleteState/data-upgrade, never break shipped data), each sellable module gets its own permission set(s) (**≤20-char** names) + entitlement, telemetry on key transactions, Feature Management (setup table + `Enabled` toggle + per-feature `ApplicationArea`) on every feature.
- **Test + document each segment as you build it** — no batching to the end.
- **Run the `feature-ready` checklist as a GATE before calling any feature done** — `../bc-dev-templates/bc-greenfield-template/checklists/feature-ready.md`. This is a hard rule because ignoring it *already* let three whole classes of work slip across Tiers 0–3 (API pages, getting-started docs, feature setup/toggle+gating) — "compiles green + tech doc + unit test" is **not** done. Do not treat the existing repo's precedent as the definition of done; the checklist is.
- **Every feature ships its setup + toggle + gating** — a single-record `NBC <Feature> Setup` (`Enabled`), a dedicated `ApplicationArea` (registered on `Application Area Setup`, toggled from `Enabled` via the experience-tier subscriber), `AccessByPermission = tabledata "NBC <Feature> Setup" = R` on every control surfaced onto a standard page, `Enabled` as the first guard in subscriber logic, and `CheckEnabled` in the write triggers of the feature's own API pages (ApplicationArea does not reach the API/MCP path). Features default **Enabled = false** — after publish an admin enables each feature's setup (session restarts). See `../bc-dev-templates/bc-customer-project-template/al-object-types/_patterns/feature-setup-and-toggle.md`.

## Feedback loop into bc-dev-templates

`bc-dev-templates` was distilled from building **bc-construction-management**. native-bc-crm is now the active
implementation vehicle: **whenever we hit a generalizable AL/BC lesson or find something the templates missed
(vs what construction did), fix it in `../bc-dev-templates/` too** — the base guide first, then reinforce in the
scenario skills/agents/checklists. Keep the templates customer-generic (`<AFFIX>`, `5####`); product/domain
specifics (CRM feature design, entity decisions) stay in this repo. See the standing directive in memory
(`propagate-lessons-to-templates`).
