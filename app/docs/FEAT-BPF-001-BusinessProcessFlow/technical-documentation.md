# FEAT-BPF-001 - Business Process Flow (Guided Stages)

> **Source/legacy reference:** N/A (greenfield). Closes Tier 2 gap #8 from the skill
> [README.md](../../../.claude/skills/dataverse-crm-integration/README.md) (guided process — no BC primitive).
> **Affected objects:** new CRM Process / Stage / State + process-bar control add-in; Opportunity Card hosts it.
> **Namespaces:** default.

**Tier 2, feature 1.** Dataverse's **Business Process Flow** — an ordered, guided stage bar on a record that shows
progress and drives "next stage" — has **no BC equivalent**. We build it natively: a reusable process definition
(stages), a per-record state, and a **JavaScript control add-in** stage bar. Generic across entities; hosted first
on the Opportunity Card.

## Design decisions

1. **Reusable definition, generic state.** `CRM Process` (header, bound to a `Table No.`) + `CRM Process Stage`
   (ordered stages). Per-record progress in `CRM Process State`, keyed by `Table No.` + `Record System ID` — the
   same generic-regarding technique as the activity timeline.
2. **No write on view.** The bar renders from the definition even before a record has started a process
   (current stage = 0). State is created lazily only when the user advances/clicks a stage — so a FactBox render
   never writes during page load.
3. **Control add-in for the visual** (`CRM Process Bar`) — horizontal chevrons, current highlighted, click a stage
   or press *Advance*. AL pushes JSON via `Render()`; the control raises `StageClicked` / `AdvanceClicked`.
4. **Generic host part** — `CRM Process Bar Part` is a CardPart bound to `CRM Process State` with
   `SubPageLink "Table No." = const(<n>), "Record System ID" = field(SystemId)`; it reads the host identity from
   the applied filter range (works even with no state row) and renders.
5. **Seeded default** — an Install codeunit seeds a `Lead to Opportunity` process (Qualify → Develop → Propose →
   Close) for the Opportunity table, idempotently (upgrade-safe).
6. **Extensible** — `CRM Process Mgt.` raises `OnAfterAdvanceStage`; stage logic is service-level, not in triggers.

## Business Process

1. On an Opportunity, the **process bar** shows the stages of the active process.
2. **Advance** moves the record to the next stage (creating its state on first use); the final advance completes it.
3. Clicking a stage jumps the record to that stage.

## Data Model

### New Tables
| # | Table | Field | Type | Notes |
|---|---|---|---|---|
| 50060 | CRM Process | Code | Code[20] | PK |
| | | Name | Text[100] | |
| | | Table No. | Integer | entity the process applies to |
| | | Active | Boolean | one active process per table is used |
| 50061 | CRM Process Stage | Process Code | Code[20] | PK1, TableRelation CRM Process |
| | | Stage No. | Integer | PK2, order |
| | | Name | Text[100] | |
| 50062 | CRM Process State | Table No. | Integer | PK1 |
| | | Record System ID | Guid | PK2 |
| | | Process Code | Code[20] | TableRelation CRM Process |
| | | Current Stage No. | Integer | 0 = not started |
| | | Started/Completed DateTime | DateTime | |

## Objects

| Type | ID | Name |
|---|---|---|
| table | 50060 | CRM Process |
| table | 50061 | CRM Process Stage |
| table | 50062 | CRM Process State |
| codeunit | 50060 | CRM Process Mgt. |
| codeunit | 50061 | CRM Process Install |
| controladdin | — | CRM Process Bar |
| page | 50060 | CRM Processes |
| page | 50061 | CRM Process Card |
| page | 50062 | CRM Process Stages |
| page | 50063 | CRM Process Bar Part |
| pageextension | 50060 | CRM Proc. Opportunity Card |
| permissionset | 50060 | CRM Processes |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Bar data | `CRM Process Mgt.GetProcessJson(TableNo, RecId)` | definition + current stage → JSON |
| Advance | `CRM Process Mgt.AdvanceStage` / `SetStage` (lazy state create) | drive progress |
| Extensibility | `OnAfterAdvanceStage(CRM Process State)` | react to stage change |
| Seed | `CRM Process Install` → `EnsureDefaultOpportunityProcess` | default Lead-to-Opportunity |

## Files

```
app/src/CRM/Process/
├── Process.Table.al  ProcessStage.Table.al  ProcessState.Table.al
├── ProcessMgt.Codeunit.al  ProcessInstall.Codeunit.al
├── Processes.Page.al  ProcessCard.Page.al  ProcessStages.Page.al  ProcessBarPart.Page.al
├── ProcOpportunityCard.PageExt.al  CRMProcesses.PermissionSet.al
└── ProcessBar/
    ├── ProcessBar.ControlAddin.al  processbar.js  processbar.css
test/src/ProcessMgtTests.Codeunit.al
```

## Known Limitations

- Stages are labels + order only (no per-stage required fields/steps like Dataverse). Step-level field gating is a
  later refinement.
- One active process per table (no branching/conditional BPF).
- Not yet compiled against a container (`bccrm28` pending).
