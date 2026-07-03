#if APPSOURCE
namespace NBC.Licensing;

/// <summary>
/// AppSource offer entitlement — grants the non-assignable CRM license permission set to holders of the
/// Marketplace offer plan. Compiled only in the AppSource build (APPSOURCE symbol); a PTE extension cannot
/// contain an entitlement (PTE0013). Replace Id with the Partner Center Service ID at AppSource onboarding.
/// </summary>
entitlement "NBC CRM Ent"
{
    Type = PerUserOfferPlan;
    Id = '00000000-0000-0000-0000-000000000000'; // REPLACE-WITH-APPSOURCE-SERVICE-ID at onboarding

    ObjectEntitlements = "NBC CRM License";
}
#endif
