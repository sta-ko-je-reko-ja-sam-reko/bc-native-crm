#if APPSOURCE
namespace NBC.Licensing;

/// <summary>
/// AppSource offer entitlement for the base Core plan — grants the non-assignable Core license set
/// (foundation + governance) to holders of that Marketplace offer plan. The CDS and CRM plans are
/// cumulative supersets of this one. Compiled only in the AppSource build (APPSOURCE symbol); a PTE
/// extension cannot contain an entitlement (PTE0013). Replace Id with the Partner Center Service ID.
/// </summary>
entitlement "NBC Core Ent"
{
    Type = PerUserOfferPlan;
    Id = '00000000-0000-0000-0000-000000000000'; // REPLACE-WITH-CORE-PLAN-SERVICE-ID at onboarding

    ObjectEntitlements = "NBC Core License";
}
#endif
