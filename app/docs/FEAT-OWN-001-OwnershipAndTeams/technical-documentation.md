# FEAT-OWN-001 - Ownership & Teams

> **Source/legacy reference:** N/A (greenfield). Reimplements the Dataverse ownership model natively — see
> [systemuser-vs-bc-salesperson.md](../../../.claude/skills/dataverse-crm-integration/systemuser-vs-bc-salesperson.md)
> and the Tier 0 gaps in the skill [README.md](../../../.claude/skills/dataverse-crm-integration/README.md).
> **Affected objects:** Customer, Contact (owner fields); new CRM Team / Team Member; owner service + reactions.
> **Namespaces:** default.

This is **Tier 0, feature 1** — the ownership foundation. Dataverse gives every record an `ownerid` (a `systemuser`
**or** a `team`) plus row-level security by ownership/business-unit. BC has **no record ownership and no dynamic
row-level security**. We reimplement the *ownership data model* natively (owner = a Salesperson **or** a Team) and
the *"my records" scoping* as a convenience filter, and we document honestly what BC can and cannot enforce.

## Design decisions

1. **Owner principal = Salesperson/Purchaser (Code 20), not BC User.** BC's CRM attribution anchor is the
   Salesperson; `User Setup."Salesperson Code"` maps the logged-in user to one. (systemuser ≈ Salesperson + BC User;
   we use the Salesperson slice for assignment.) A record's owner is either a **Salesperson** or a **Team**.
2. **Polymorphic owner** via two fields on every ownable record: `CRM Owner Type` (enum Salesperson|Team) +
   `CRM Owner Code` (Code[20]). Mirrors Dataverse's user-or-team owner.
3. **Team model** = `CRM Team` + `CRM Team Member` (members are Salespersons; one may be Team Lead).
4. **Owner defaulting** — on insert of an ownable record with no owner, default to the current user's Salesperson
   (from `User Setup`). Implemented as an extensible **reaction** (pure-proxy subscriber → interface → logic).
5. **Row-level security — honest scope.** BC has no platform mechanism to enforce "only records I/my team own"
   keyed to the current user (security filters are static and can't reference the running user). So:
   - We provide **`ApplyMyRecordsFilter`** — a convenience that filters a list to the current user's owner keys
     (own Salesperson code + the Team codes they belong to). Surfaced as **"Show my CRM records"** actions and a
     view. This is *scoping, not enforcement* (a user can clear the filter).
   - **Hard enforcement**, where required, is left to standard BC **permission-set security filters** (static per
     role) — documented as a deployment option, not built here.
   - See **Known Limitations**.
6. **UI convention** — owner field goes under a **`group(CRM)`** on cards; owner actions under a **`CRM`** promoted
   action category on lists/cards (per the project decision framework).
7. **House pattern** — all trigger/subscriber logic delegates one line to an interface impl; subscribers are pure
   proxies resolving through the `CRM Service Locator` (introduced here as the app-wide service hub).

## Business Process

1. A user opens a Customer/Contact; the **Owner** (Salesperson or Team) shows in the **CRM** group.
2. On create, the record's Owner defaults to the creating user's Salesperson (if mapped) — else left blank.
3. A user reassigns ownership via **Assign Owner** (CRM action) — pick Salesperson or an existing Team.
4. Teams are maintained on the **CRM Teams** list/card; members are Salespersons, one optionally the Team Lead.
5. **Show my CRM records** filters a list to records owned by the user or any team they belong to.

## Data Model

### New Tables
| # | Table | Field | Type | Notes |
|---|---|---|---|---|
| 50020 | CRM Team | Code | Code[20] | PK |
| | | Name | Text[100] | |
| | | Description | Text[250] | |
| | | Team Lead Salesp. Code | Code[20] | TableRelation Salesperson/Purchaser |
| | | Member Count | Integer | FlowField Count(CRM Team Member) |
| 50021 | CRM Team Member | Team Code | Code[20] | PK1, TableRelation CRM Team |
| | | Salesperson Code | Code[20] | PK2, TableRelation Salesperson/Purchaser |
| | | Team Lead | Boolean | |
| | | Salesperson Name | Text[100] | FlowField |

### New Fields on Existing Tables
| Object | Field ID | Field | Type | Notes |
|---|---|---|---|---|
| Customer (18) | 50020 | CRM Owner Type | Enum "CRM Owner Type" | Salesperson (default) / Team |
| Customer (18) | 50021 | CRM Owner Code | Code[20] | conditional TableRelation on Owner Type |
| Contact (5050) | 50020 | CRM Owner Type | Enum "CRM Owner Type" | |
| Contact (5050) | 50021 | CRM Owner Code | Code[20] | |

## Objects

| Type | ID | Name | Folder | Purpose |
|---|---|---|---|---|
| enum | 50020 | CRM Owner Type | Dataverse/Ownership | Salesperson / Team |
| table | 50020 | CRM Team | Dataverse/Ownership | Team master |
| table | 50021 | CRM Team Member | Dataverse/Ownership | Team ↔ Salesperson |
| interface | — | CRM ITeam | Dataverse/Ownership | Team trigger logic |
| interface | — | CRM IOwnerReactions | Dataverse/Ownership | swappable owner-default reactions |
| codeunit | 50020 | CRM Owner Mgt. | Dataverse/Ownership | owner service API (default/assign/scope/membership) |
| codeunit | 50021 | CRM Team Logic | Dataverse/Ownership | default ITeam impl |
| codeunit | 50022 | CRM Owner Reactions | Dataverse/Ownership | default IOwnerReactions impl |
| codeunit | 50023 | CRM Owner Subscribers | Dataverse/Ownership | pure-proxy subscribers (Customer/Contact OnInsert) |
| codeunit | 50000 | CRM Service Locator | Core | SingleInstance app-wide resolver |
| page | 50020 | CRM Teams | Dataverse/Ownership | team list |
| page | 50021 | CRM Team Card | Dataverse/Ownership | team card + members |
| page | 50022 | CRM Team Members | Dataverse/Ownership | members ListPart |
| tableextension | 50020 | CRM Owner Customer | Dataverse/Ownership | owner fields on Customer |
| tableextension | 50021 | CRM Owner Contact | Dataverse/Ownership | owner fields on Contact |
| pageextension | 50020 | CRM Owner Customer Card | Dataverse/Ownership | Owner in CRM group + actions |
| pageextension | 50021 | CRM Owner Customer List | Dataverse/Ownership | Owner column + "Show my CRM records" |
| pageextension | 50022 | CRM Owner Contact Card | Dataverse/Ownership | as Customer Card |
| pageextension | 50023 | CRM Owner Contact List | Dataverse/Ownership | as Customer List |
| permissionset | 50000 | CRM Foundation | Core | all Tier-0 objects |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Owner default | `Customer/Contact` `OnAfterInsertEvent` → `CRM Owner Subscribers` → `CRM Service Locator.OwnerReactions()` | stamp default owner |
| Owner service | `CRM Owner Mgt.` public API | GetCurrentUserOwner / AssignOwner / IsOwnedByCurrentUser / ApplyMyRecordsFilter / IsSalespersonInTeam |
| Extensibility | `CRM IOwnerReactions`, `CRM ITeam` via `Define()` / Service Locator | downstream apps/tests swap behaviour |

## Files

```
app/src/
├── Core/
│   ├── ServiceLocator.Codeunit.al
│   └── CRMFoundation.PermissionSet.al
└── Dataverse/Ownership/
    ├── OwnerType.Enum.al
    ├── ITeam.Interface.al
    ├── IOwnerReactions.Interface.al
    ├── Team.Table.al
    ├── TeamMember.Table.al
    ├── OwnerMgt.Codeunit.al
    ├── TeamLogic.Codeunit.al
    ├── OwnerReactions.Codeunit.al
    ├── OwnerSubscribers.Codeunit.al
    ├── Teams.Page.al
    ├── TeamCard.Page.al
    ├── TeamMembers.Page.al
    ├── OwnerCustomer.TableExt.al
    ├── OwnerContact.TableExt.al
    ├── OwnerCustomerCard.PageExt.al
    ├── OwnerCustomerList.PageExt.al
    ├── OwnerContactCard.PageExt.al
    └── OwnerContactList.PageExt.al
test/src/
└── OwnerMgtTests.Codeunit.al
```

## Known Limitations

- **No enforced row-level security.** `ApplyMyRecordsFilter` is UI scoping only; users can clear it. Dataverse's
  owner/business-unit security has no native BC equivalent. Hard isolation must be configured with standard BC
  **permission-set security filters** (static) at deployment, or revisited if BC adds a per-user filter primitive.
- **`ApplyMyRecordsFilter` filters on `CRM Owner Code`** (own Salesperson code + team codes) without splitting by
  `Owner Type`; a Salesperson code equal to a Team code (unlikely) could over-match. Acceptable for convenience.
- **Business Unit** ownership is out of scope for Tier 0 (BC has no BU concept); owner is Salesperson/Team only.
- **Vendor** owner fields are not included in this feature (Customer + Contact are the primary CRM parties); add
  by replicating the Customer tableextension/pageextension pattern if needed.
- Not yet built/verified against a container (`bccrm28` pending) — needs a compile pass.
