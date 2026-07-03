# FEAT-RC-001 - CRM Role Center

> **Source/legacy reference:** N/A (greenfield). Tier 2 gap #9 (form experience / role-tuned home) from the skill
> [README.md](../../../.claude/skills/dataverse-crm-integration/README.md).
> **Affected objects:** new CRM Role Center + cue table/parts + profile. **Namespaces:** `NBC.CRM.RoleCenter`.

**Tier 2, feature 2.** Dataverse role apps open on a tailored home with cue tiles and navigation. BC's equivalent is
a **Role Center page + Profile**; we add a CRM one with activity/opportunity cues (scoped to the current user's
salesperson) and navigation to the CRM pages.

## Design decisions

1. **Cue tiles via a singleton cue table** (`NBC CRM Cue`) with FlowFilter fields set to the current user's
   salesperson (from `NBC CDS Owner Mgt.`), and FlowFields counting activities/opportunities — the standard BC cue
   pattern (no per-tile code).
2. **Role Center page** with two cue FactBoxes + Sections navigation (Teams, Activities, Opportunities, Processes)
   + a Governance section (from FEAT-GOV-001) + New-activity creation.
3. **Profile** `NBC CRM Salesperson` points at the role center (Enabled).
4. Cues are scoped, not enforced (consistent with FEAT-OWN-001 row-level scoping).

## Data Model

| Table | Field | Type | Notes |
|---|---|---|---|
| NBC CRM Cue (50070) | Primary Key | Code[10] | singleton |
| | Owner Code Filter / Salesperson Code Filter | Code[20] | FlowFilter |
| | Overdue Before Filter | Date | FlowFilter |
| | My Open Activities | Integer | FlowField count(NBC CDS Activity, Owner+Open) |
| | Overdue Activities | Integer | FlowField (Open + Due Date past) |
| | My Opportunities | Integer | FlowField count(Opportunity by Salesperson) |
| | Opportunities In Progress | Integer | FlowField (Status = In Progress) |

## Objects

| Type | ID | Name |
|---|---|---|
| table | 50070 | NBC CRM Cue |
| codeunit | 50070 | NBC CRM Cue Mgt. |
| page | 50070 | NBC CRM Role Center (RoleCenter) |
| page | 50071 | NBC CRM Activity Cues (CardPart) |
| page | 50072 | NBC CRM Sales Cues (CardPart) |
| profile | — | NBC CRM Salesperson |
| permissionset | 50070 | NBC CRM Role Center |

## Known Limitations

- Cue drill-downs open the full list (not pre-filtered to the user); scoping is via the "Show my CRM records" action.
- Single cue record shared per company; filters are per-session (current user).
