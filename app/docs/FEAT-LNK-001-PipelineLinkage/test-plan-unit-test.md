# FEAT-LNK-001 - Unit Test Plan

DB-free unit tests (codeunit `NBC CRM Linkage Tests`, 50906). Pure logic, no container required.

| # | Test | Arrange | Act | Assert |
|---|---|---|---|---|
| 1 | `ShouldStamp_TrueWhenOpportunitySet` | Sales Header with `NBC CRM Opportunity No.` = 'OPP001' | `Reactions.ShouldStamp` | returns `true` |
| 2 | `ShouldStamp_FalseWhenOpportunityBlank` | Sales Header with blank opportunity | `Reactions.ShouldStamp` | returns `false` |
| 3 | `CopyPipelineLink_CopiesOpportunityToInvoice` | source Sales Header linked to 'OPP042' | `Reactions.CopyPipelineLink` | invoice header carries 'OPP042' |

These assert the pure decision + copy that the posting reaction is built from (the `Enabled` guard and `Modify` are
the DB-bound wrapper, covered by the integration plan).
