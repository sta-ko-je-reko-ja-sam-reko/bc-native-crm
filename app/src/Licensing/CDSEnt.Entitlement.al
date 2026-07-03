#if APPSOURCE
namespace NBC.Licensing;

/// <summary>
/// AppSource offer entitlement for the Dataverse (CDS-base) plan — grants the non-assignable CDS license
/// set to holders of that Marketplace offer plan. Compiled only in the AppSource build (APPSOURCE symbol);
/// a PTE extension cannot contain an entitlement (PTE0013). Replace Id with the Partner Center Service ID.
/// </summary>
entitlement "NBC CDS Ent"
{
    Type = PerUserOfferPlan;
    Id = '00000000-0000-0000-0000-000000000000'; // REPLACE-WITH-DATAVERSE-PLAN-SERVICE-ID at onboarding

    ObjectEntitlements = "NBC CDS License";
}
#endif
