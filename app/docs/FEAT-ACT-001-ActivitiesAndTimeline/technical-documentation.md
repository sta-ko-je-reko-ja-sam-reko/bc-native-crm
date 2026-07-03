# FEAT-ACT-001 - Activities & Timeline

> **Source/legacy reference:** N/A (greenfield). Reimplements the Dataverse activity model + timeline natively —
> see the account/contact/opportunity gap analyses and Tier 0 in the skill
> [README.md](../../../.claude/skills/dataverse-crm-integration/README.md).
> **Affected objects:** new CRM Activity + enums + timeline control add-in; Customer/Contact cards get a Timeline
> FactBox and CRM activity actions.
> **Namespaces:** default.

**Tier 0, feature 2.** Dataverse makes `task` / `phonecall` / `appointment` / `email` / annotation (note)
first-class **activities** and shows them on every record as a **Timeline** control. BC has an Interaction Log
only on Contact and no unified, record-agnostic timeline. We build a native, generic **CRM Activity** entity that
can regard *any* record, and a **JavaScript control add-in** timeline (a visual BC cannot render natively) shown as
a FactBox on the party cards. Reuses ownership from [FEAT-OWN-001](../FEAT-OWN-001-OwnershipAndTeams/technical-documentation.md).

## Design decisions

1. **One unified activity table** (`CRM Activity`) with an `Activity Type` (Task / Phone Call / Appointment /
   Email / Note) — mirrors Dataverse's activitypointer rather than a table per type.
2. **Polymorphic "Regarding"** — an activity points at any record via `Regarding Table No.` (Integer) +
   `Regarding System ID` (Guid), plus a cached `Regarding Description` for display. No hard table coupling.
3. **Owner-integrated** — activities carry `Owner Type`/`Owner Code` and default the owner on insert via the
   `CRM Owner Mgt.` service from FEAT-OWN-001.
4. **Generic FactBox, no host triggers** — the timeline part is bound to `CRM Activity` and filtered to the host
   record with **`SubPageLink = "Regarding Table No." = const(<tableno>), "Regarding System ID" = field(SystemId)`**.
   This follows the current record automatically (page extensions can't add page triggers), so one part works on
   any card by changing the `const`.
5. **Control add-in for the visual** — a `CRM Timeline` control add-in (JS + CSS) renders the chronological,
   icon-per-type timeline; the host part pushes the filtered activities as JSON via `Render()` and reacts to an
   `ActivityClicked` event to open the activity. (Decision framework: valuable graphics BC can't render → control add-in.)
6. **JSON boundary is testable** — `CRM Activity Mgt.BuildTimelineJson` is a pure record→JSON method (unit-tested
   with temporary records); the control add-in only renders.
7. **UI convention** — activity actions on the party cards live under the **CRM** action group.

## Business Process

1. On a Customer/Contact, the **Timeline** FactBox shows that record's activities newest-first.
2. **New CRM Activity** (CRM action) creates an activity already regarding the current record; it opens for edit.
3. An activity has a type, subject, description, owner, due/activity date, priority and status.
4. **Complete** sets status = Completed and stamps the closed date-time.
5. Clicking a timeline entry opens its Activity Card.

## Data Model

### New Tables
| # | Table | Field | Type | Notes |
|---|---|---|---|---|
| 50030 | CRM Activity | Entry No. | Integer | PK, AutoIncrement |
| | | Activity Type | Enum "CRM Activity Type" | Task/Phone Call/Appointment/Email/Note |
| | | Subject | Text[100] | |
| | | Description | Text[2048] | |
| | | Regarding Table No. | Integer | the regarded record's table |
| | | Regarding System ID | Guid | the regarded record's SystemId |
| | | Regarding Description | Text[100] | cached display |
| | | Owner Type / Owner Code | Enum / Code[20] | reuse FEAT-OWN-001 |
| | | Status | Enum "CRM Activity Status" | Open/Completed/Canceled |
| | | Priority | Enum "CRM Activity Priority" | Low/Normal/High |
| | | Direction | Enum "CRM Activity Direction" | None/Incoming/Outgoing |
| | | Activity Date | DateTime | timeline ordering |
| | | Due Date | Date | |
| | | Closed DateTime | DateTime | set on completion |
| | | Created By | Code[50] | |

### New Fields on Existing Tables
| Object | Field | Notes |
|---|---|---|
| Customer / Contact | — | no new fields; Timeline FactBox + actions only (linked by SystemId) |

## Objects

| Type | ID | Name | Folder |
|---|---|---|---|
| enum | 50030 | CRM Activity Type | Dataverse/Activities |
| enum | 50031 | CRM Activity Status | Dataverse/Activities |
| enum | 50032 | CRM Activity Priority | Dataverse/Activities |
| enum | 50033 | CRM Activity Direction | Dataverse/Activities |
| table | 50030 | CRM Activity | Dataverse/Activities |
| interface | — | CRM IActivity | Dataverse/Activities |
| codeunit | 50030 | CRM Activity Mgt. | Dataverse/Activities |
| codeunit | 50031 | CRM Activity Logic | Dataverse/Activities |
| page | 50030 | CRM Activities | Dataverse/Activities |
| page | 50031 | CRM Activity Card | Dataverse/Activities |
| page | 50032 | CRM Timeline Part | Dataverse/Activities |
| controladdin | — | CRM Timeline | Dataverse/Activities/Timeline |
| pageextension | 50030 | CRM Act. Customer Card | Dataverse/Activities |
| pageextension | 50031 | CRM Act. Contact Card | Dataverse/Activities |
| permissionset | 50030 | CRM Activities | Dataverse/Activities |

## Files

```
app/src/Dataverse/Activities/
├── ActivityType.Enum.al  ActivityStatus.Enum.al  ActivityPriority.Enum.al  ActivityDirection.Enum.al
├── Activity.Table.al  IActivity.Interface.al  ActivityLogic.Codeunit.al  ActivityMgt.Codeunit.al
├── Activities.Page.al  ActivityCard.Page.al  TimelinePart.Page.al
├── ActCustomerCard.PageExt.al  ActContactCard.PageExt.al  CRMActivities.PermissionSet.al
└── Timeline/
    ├── Timeline.ControlAddin.al
    ├── timeline.js
    └── timeline.css
test/src/ActivityMgtTests.Codeunit.al
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Timeline data | `CRM Activity Mgt.BuildTimelineJson(var Activity)` | record set → JSON for the control add-in |
| Control add-in | `CRM Timeline`.`Render(Text)` / events `ControlReady`, `ActivityClicked(Text)` | render + click-through |
| Owner default | `CRM Activity Logic.Trigger_OnInsert` → `CRM Owner Mgt.GetDefaultOwner` | stamp owner |
| Quick create | card action → `CRM Activity Mgt.InitActivityForRecord` | new activity regarding current record |

## Known Limitations

- Email/appointment are modeled as activity *records* only — no Exchange/Outlook sync or ICS (out of scope; BC has
  no native two-way calendar for this). Direction/dates capture the data.
- Timeline is read + click-through; inline compose is via the Activity Card (not in the control add-in).
- Regarding is generic by Table No. + SystemId; only Customer and Contact cards host the FactBox in this feature
  (add other hosts by dropping the same part with a different `const` table no).
- Not yet compiled against a container (`bccrm28` pending).
