#if APPSOURCE
namespace NBC.Licensing;

using NBC.CRM.Catalog;
using NBC.CRM.Linkage;
using NBC.CRM.Opportunity;
using NBC.CRM.Pricing;
using NBC.CRM.Process;
using NBC.CRM.RoleCenter;
using NBC.Demo;
using NBC.Onboarding;

/// <summary>
/// Non-assignable license set for the top D365-Sales (CRM) offer plan. Cumulative: includes the whole
/// CDS plan (which includes Core) and adds opportunity depth, guided process, salesperson role center,
/// product catalog and pricing flexibility. Granted by the <see cref="NBC CRM Ent"/> entitlement.
/// Compiled only in the AppSource build (APPSOURCE).
/// </summary>
permissionset 50111 "NBC CRM License"
{
    Caption = 'CRM Sales License';
    Assignable = false;

    IncludedPermissionSets =
        "NBC CDS License",
        "NBC CRM Opp.",
        "NBC CRM Processes",
        "NBC CRM Role Center",
        "NBC CRM Catalog",
        "NBC CRM Pricing",
        "NBC CRM Linkage",
        "NBC Demo",
        "NBC Onboarding";
}
#endif
