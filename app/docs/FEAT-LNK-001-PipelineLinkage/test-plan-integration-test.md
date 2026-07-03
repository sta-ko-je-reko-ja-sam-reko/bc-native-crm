# FEAT-LNK-001 - Integration Test Plan

DB-bound tests to add once the `crm2802` test runner is wired up (tracked as an open gate item in PROJECT-STATUS).
Each arranges real records, acts through the standard posting/UI path, and relies on the test runner's rollback.

| # | Scenario | Arrange | Act | Assert |
|---|---|---|---|---|
| 1 | Invoice stamped on posting | Enable Linkage; create a Sales Order with `NBC CRM Opportunity No.` = an opportunity; add a postable line | Post (ship + invoice) via `Sales-Post` | the resulting **Posted Sales Invoice** has the same `NBC CRM Opportunity No.` |
| 2 | No stamp when disabled | Linkage **disabled**; order linked to an opportunity | Post | posted invoice's `NBC CRM Opportunity No.` is blank |
| 3 | No stamp when order unlinked | Enable Linkage; order with **blank** opportunity | Post | posted invoice's opportunity is blank |
| 4 | Order roll-up count | Enable Linkage; create 2 orders linked to the same opportunity | `CalcFields("NBC CRM Linked Orders")` | count = 2 |
| 5 | Invoice roll-up count | post 1 linked invoice for an opportunity | `CalcFields("NBC CRM Linked Invoices")` | count = 1 |
| 6 | Status transition guarded | Linkage disabled | `NBC CRM Linkage Mgt.SubmitOrder` | errors with the "feature not enabled" message |
| 7 | API write-guard | Linkage disabled | POST to `salesOrdersCrm` | `CheckEnabled` rejects the write |

Reaction substitution: tests may inject a fake `NBC CRM ILinkageReactions` via
`Service Locator.ImplementLinkageReactions(...)` to assert the subscriber delegates exactly once per posted invoice.
