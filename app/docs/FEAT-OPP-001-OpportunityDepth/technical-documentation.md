# FEAT-OPP-001 - Opportunity Depth

> **Source/legacy reference:** N/A (greenfield). Closes the gaps in
> [opportunity-vs-bc-opportunity.md](../../../.claude/skills/dataverse-crm-integration/opportunity-vs-bc-opportunity.md)
> (Tier 1 in the skill [README.md](../../../.claude/skills/dataverse-crm-integration/README.md)).
> **Affected objects:** Opportunity (extend); new Opportunity Line / Competitor / Stakeholder; Opportunity Card.
> **Namespaces:** default.

**Tier 1, feature 1.** BC already has a native **Opportunity** (Relationship Management) with sales-cycle stages,
estimated value, chances-of-success and won/lost status + close reasons — so we **do not rebuild it**. We add the
Dataverse-Sales depth BC lacks: **product line items** (with value roll-up), **competitors**, **stakeholders/sales
team**, an **owner + rating**, and the **activity Timeline** (reusing FEAT-ACT-001). This is the decision framework
in action: minor/additive → `tableextension`; large new structures → custom entities.

## Design decisions

1. **Extend, don't replace, the standard Opportunity** (table `Opportunity` 5092). Add `CRM Owner Type/Code`,
   `CRM Rating` (Hot/Warm/Cold), and `CRM Estimated Revenue` — a FlowField summing the opportunity lines.
2. **Opportunity lines** = new `CRM Opportunity Line` (child of Opportunity by `No.`) — Item/Resource/Comment
   lines with quantity × unit price → line amount; the sum is the estimated revenue. Standard BC keeps its own
   estimated value on Opportunity Entries; ours is the line-driven number surfaced on the card.
3. **Competitors** = `CRM Opportunity Competitor` (name, threat level, strengths/weaknesses).
4. **Stakeholders / sales team** = `CRM Opportunity Stakeholder` (a Contact + role: decision maker / influencer /
   champion / blocker / end user).
5. **Won/Lost close activity** — closing an opportunity logs a `CRM Activity` regarding it (reuses FEAT-ACT-001),
   mirroring Dataverse's opportunityclose. Implemented in `CRM Opportunity Mgt.`.
6. **Timeline** — the FEAT-ACT-001 Timeline FactBox is placed on the Opportunity Card (`const(5092)`).
7. **Polymorphic logic** for the line (amount calc, item/resource lookup) per the house pattern.
8. **UI** — lines/competitors/stakeholders as parts on the card; owner + rating in a **CRM** group; CRM actions.

## Business Process

1. On an Opportunity, add **lines** (items/resources) — the **CRM Estimated Revenue** rolls up from them.
2. Record **competitors** and **stakeholders** (contacts with a role).
3. Set the **owner** and **rating**; the **Timeline** shows related activities.
4. On **Won/Lost**, the standard status/close is set and a close **activity** is logged automatically.

## Data Model

### New Tables
| # | Table | Field | Type | Notes |
|---|---|---|---|---|
| 50040 | CRM Opportunity Line | Opportunity No. | Code[20] | PK1, TableRelation Opportunity |
| | | Line No. | Integer | PK2 |
| | | Type | Enum "CRM Opp. Line Type" | Comment/Item/Resource |
| | | No. | Code[20] | TableRelation by Type |
| | | Description | Text[100] | |
| | | Quantity | Decimal | |
| | | Unit Price | Decimal | |
| | | Line Amount | Decimal | Quantity × Unit Price |
| 50041 | CRM Opportunity Competitor | Opportunity No., Line No. | Code[20], Integer | PK |
| | | Name | Text[100] | |
| | | Threat Level | Enum "CRM Threat Level" | Low/Medium/High |
| | | Strengths / Weaknesses | Text[250] | |
| 50042 | CRM Opportunity Stakeholder | Opportunity No., Contact No. | Code[20], Code[20] | PK; Contact TableRelation |
| | | Role | Enum "CRM Stakeholder Role" | Decision Maker/Influencer/Champion/Blocker/End User |
| | | Role Description | Text[100] | |

### New Fields on Existing Tables
| Object | Field ID | Field | Type |
|---|---|---|---|
| Opportunity (5092) | 50040 | CRM Owner Type | Enum "CRM Owner Type" |
| Opportunity (5092) | 50041 | CRM Owner Code | Code[20] |
| Opportunity (5092) | 50042 | CRM Rating | Enum "CRM Opportunity Rating" |
| Opportunity (5092) | 50043 | CRM Estimated Revenue | Decimal (FlowField sum of lines) |

## Objects

| Type | ID | Name |
|---|---|---|
| enum | 50040 | CRM Opportunity Rating |
| enum | 50041 | CRM Opp. Line Type |
| enum | 50042 | CRM Stakeholder Role |
| enum | 50043 | CRM Threat Level |
| table | 50040 | CRM Opportunity Line |
| table | 50041 | CRM Opportunity Competitor |
| table | 50042 | CRM Opportunity Stakeholder |
| interface | — | CRM IOpportunityLine |
| codeunit | 50040 | CRM Opportunity Line Logic |
| codeunit | 50041 | CRM Opportunity Mgt. |
| page | 50040 | CRM Opportunity Lines |
| page | 50041 | CRM Opp. Competitors |
| page | 50042 | CRM Opp. Stakeholders |
| tableextension | 50040 | CRM Opportunity |
| pageextension | 50040 | CRM Opportunity Card |
| permissionset | 50040 | CRM Opportunities |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Value roll-up | `CRM Estimated Revenue` FlowField = Sum(line amount) | card figure |
| Line calc | `CRM Opportunity Line Logic` | amount + item/resource lookup |
| Close → activity | `CRM Opportunity Mgt.CloseAsWon/Lost` → `CRM Activity Mgt.InitActivityForRecord` | log close activity (reuses FEAT-ACT-001) |
| Timeline | `CRM Timeline Part` FactBox, `const(5092)` | activities on the opportunity |

## Files

```
app/src/CRM/Opportunity/
├── OpportunityRating.Enum.al  OppLineType.Enum.al  StakeholderRole.Enum.al  ThreatLevel.Enum.al
├── OpportunityLine.Table.al  OpportunityCompetitor.Table.al  OpportunityStakeholder.Table.al
├── IOpportunityLine.Interface.al  OpportunityLineLogic.Codeunit.al  OpportunityMgt.Codeunit.al
├── OpportunityLines.Page.al  OppCompetitors.Page.al  OppStakeholders.Page.al
├── Opportunity.TableExt.al  OpportunityCard.PageExt.al  CRMOpportunities.PermissionSet.al
test/src/OpportunityLineTests.Codeunit.al
```

## Known Limitations

- **Forecasting / predictive scoring** (Sales Insights) is not built — no BC ML primitive; the line roll-up +
  chances-of-success give a manual weighted pipeline instead.
- Estimated revenue is line-driven and separate from BC's Opportunity Entry estimated value (kept intact).
- Competitor is free-text (no competitor master) for Tier 1.
- Not yet compiled against a container (`bccrm28` pending).
