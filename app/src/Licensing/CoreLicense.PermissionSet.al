#if APPSOURCE
namespace NBC.Licensing;

using NBC.Core;
using NBC.Governance;

/// <summary>
/// Non-assignable Core license set — the shared base both offer plans include: foundation (ownership,
/// teams, party APIs, MCP setup) and governance (audit, duplicate detection). Referenced by both the
/// CDS and CRM license sets. Compiled only in the AppSource build (APPSOURCE); the PTE build excludes it.
/// </summary>
permissionset 50113 "NBC Core License"
{
    Caption = 'CRM Core License';
    Assignable = false;

    IncludedPermissionSets =
        "NBC Foundation",
        "NBC Governance";
}
#endif
