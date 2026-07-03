#if APPSOURCE
namespace NBC.Licensing;

using NBC.Dataverse.Activities;

/// <summary>
/// Non-assignable license set for the mid Dataverse (CDS-base) offer plan. Cumulative: includes the Core
/// plan and adds the activity timeline; the CRM plan in turn includes this one. Advanced Dataverse
/// features added later slot in here (or get their own plan). Granted by the <see cref="NBC CDS Ent"/>
/// entitlement. Compiled only in the AppSource build (APPSOURCE).
/// </summary>
permissionset 50112 "NBC CDS License"
{
    Caption = 'CRM Dataverse License';
    Assignable = false;

    IncludedPermissionSets =
        "NBC Core License",
        "NBC CDS Activities";
}
#endif
