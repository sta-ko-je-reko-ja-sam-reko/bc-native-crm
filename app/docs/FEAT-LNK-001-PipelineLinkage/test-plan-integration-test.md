# FEAT-LNK-001 - Integration Test Plan

DB-bound tests, automated in codeunit `NBC CRM Linkage Integration` (69016); run with `tools\test.ps1`.
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

## Automation

| # | Procedure | Status |
|---|---|---|
| 1 | `NBC CRM Linkage Integration.PostedInvoiceIsStampedWithOpportunity` | compiled, not yet run |
| 2 | `NBC CRM Linkage Integration.NoStampWhileLinkageDisabled` | compiled, not yet run |
| 3 | `NBC CRM Linkage Integration.NoStampForUnlinkedOrder` | compiled, not yet run |
| 4 | `NBC CRM Linkage Integration.OpportunityRollsUpLinkedOrdersAndInvoices` (+ `LinkedOrdersCountOnlyOrders`) | compiled, not yet run |
| 5 | `NBC CRM Linkage Integration.OpportunityRollsUpLinkedOrdersAndInvoices` | compiled, not yet run |
| 6 | `NBC CRM Linkage Integration.StatusChangeOnRealOrderBlockedWhileDisabled` (+ unit `StatusChangeBlockedWhileLinkageDisabled`) | compiled, not yet run |
| 7 | manual — API pages need an HTTP/OData client; the guard itself (`NBC Feature Mgt.CheckEnabled`) is covered by `NBC Feature Setup Tests` | manual |

Reaction substitution: `NBC CRM Linkage Integration.PostingSubscriberDelegatesOncePerInvoice`.
