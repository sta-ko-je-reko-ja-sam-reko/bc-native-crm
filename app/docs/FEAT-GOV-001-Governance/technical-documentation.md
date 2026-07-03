# FEAT-GOV-001 - Governance (Audit & Duplicate Detection)

> **Source/legacy reference:** N/A (greenfield). Tier 2 gap #10 from the skill
> [README.md](../../../.claude/skills/dataverse-crm-integration/README.md).
> **Affected objects:** new audit + duplicate management codeunits. **Namespaces:** `NBC.Governance`.

**Tier 2, feature 3.** Dataverse gives per-field audit and duplicate-detection rules. Per the "what NOT to build"
guidance we **reuse BC's native mechanisms**: audit = the standard **Change Log** (we just register the CRM tables
and activate it); contact de-duplication already exists in BC RM, so we add only a lightweight **customer**
duplicate finder (BC has none for customers).

## Design decisions

1. **Audit via Change Log** — `NBC Audit Mgt.` activates `Change Log Setup` and registers the key CRM tables
   (`NBC CDS Team`, `NBC CDS Activity`, `NBC CRM Opp. Line`, `NBC CRM Process State`) in `Change Log Setup (Table)`
   with All-Fields logging, then calls `Change Log Management.InitChangeLog`. No custom audit store — changes show
   in the standard Change Log Entries. Run on demand (admin action on the Role Center).
2. **Duplicate detection** — `NBC Duplicate Mgt.` finds Customers (and Contacts) sharing the same name, marks them
   and opens the standard list filtered to the marked set. Contacts also have BC's native dedup; this is a simple
   name-based helper.

## Objects

| Type | ID | Name |
|---|---|---|
| codeunit | 50080 | NBC Audit Mgt. |
| codeunit | 50081 | NBC Duplicate Mgt. |
| permissionset | 50080 | NBC Governance |

Surfaced via the Role Center **Governance** actions (FEAT-RC-001): *Enable CRM audit logging*, *Find duplicate customers*.

## Known Limitations

- Audit is opt-in (admin runs it) and uses BC's Change Log retention/UI as-is.
- Duplicate detection is exact-name only (no fuzzy matching); it reads all customers/contacts on demand.
