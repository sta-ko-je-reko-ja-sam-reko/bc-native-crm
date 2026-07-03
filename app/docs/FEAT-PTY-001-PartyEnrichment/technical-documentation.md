# FEAT-PTY-001 - Party Enrichment (Hierarchy, Classification, Consent)

> **Source/legacy reference:** N/A (greenfield). Closes Tier 1 gaps #5–#7 from the skill
> [README.md](../../../.claude/skills/dataverse-crm-integration/README.md) and
> [account-vs-bc-master-data.md](../../../.claude/skills/dataverse-crm-integration/account-vs-bc-master-data.md).
> **Affected objects:** Customer, Contact (additive fields + UI). No new tables.
> **Namespaces:** default.

**Tier 1, feature 2** — bundles three *additive* account/contact capabilities Dataverse has and BC lacks. Per the
decision framework these are **minor/additive → `tableextension` + `pageextension`** under a **CRM** group, not new
entities:

- **Hierarchy** — `CRM Parent Customer No.` (self-relation) gives parent/subsidiary on Customer. (Contact already
  has native Company/Person hierarchy, so nothing added there.)
- **Classification / firmographics** — Industry (reuses the standard **Industry Group** table), Annual Revenue,
  No. of Employees. (Dimensions remain the analytical axis; these are descriptive attributes like Dataverse's.)
- **Consent / preferences** — Do-Not-Email / Do-Not-Phone / Do-Not-Bulk-Email flags + Preferred Contact Method,
  on both Customer and Contact.

## Design decisions

1. **No new tables** — everything is additive fields; base Customer/Contact tabledata permissions already cover
   them, so no new permission set.
2. **Reuse standard `Industry Group`** rather than a new industry enum (BC already has it, and Contacts use it).
3. **Consent flags are data only** — they *record* preference; enforcing them (e.g. suppressing a send) is a
   downstream concern for whichever feature sends email/SMS, which then checks these flags.
4. **UI** — a CRM **Classification** group and a CRM **Preferences** group on the cards; a **Subsidiaries** action
   on the Customer card lists child customers.
5. Data-only feature: no business logic, so no automated test (nothing to assert) — noted per the segment rule.

## Data Model

### New Fields on Existing Tables
| Object | Field ID | Field | Type | Notes |
|---|---|---|---|---|
| Customer | 50050 | CRM Parent Customer No. | Code[20] | TableRelation Customer (self) |
| Customer | 50051 | CRM Industry Group Code | Code[10] | TableRelation "Industry Group" |
| Customer | 50052 | CRM Annual Revenue | Decimal | firmographic |
| Customer | 50053 | CRM No. of Employees | Integer | firmographic |
| Customer | 50054 | CRM Preferred Contact Method | Enum "CRM Pref. Contact Method" | |
| Customer | 50055 | CRM Do Not Email | Boolean | consent |
| Customer | 50056 | CRM Do Not Phone | Boolean | consent |
| Customer | 50057 | CRM Do Not Bulk Email | Boolean | consent |
| Contact | 50054 | CRM Preferred Contact Method | Enum "CRM Pref. Contact Method" | |
| Contact | 50055 | CRM Do Not Email | Boolean | consent |
| Contact | 50056 | CRM Do Not Phone | Boolean | consent |
| Contact | 50057 | CRM Do Not Bulk Email | Boolean | consent |

## Objects

| Type | ID | Name |
|---|---|---|
| enum | 50050 | CRM Pref. Contact Method |
| tableextension | 50050 | CRM Enrich Customer |
| tableextension | 50051 | CRM Enrich Contact |
| pageextension | 50050 | CRM Enrich Customer Card |
| pageextension | 50051 | CRM Enrich Contact Card |

## Files

```
app/src/Dataverse/PartyEnrichment/
├── PrefContactMethod.Enum.al
├── EnrichCustomer.TableExt.al  EnrichContact.TableExt.al
└── EnrichCustomerCard.PageExt.al  EnrichContactCard.PageExt.al
```

## Known Limitations

- Consent flags are recorded but not yet enforced by any sender (no email/SMS feature exists yet).
- Hierarchy is a single parent link (no BU/territory model — out of scope; Dimensions cover territory analytics).
- Not yet compiled against a container (`bccrm28` pending).
