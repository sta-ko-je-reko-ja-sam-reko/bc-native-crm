namespace NBC.Setup;

using System.Environment.Configuration;

/// <summary>
/// Sets each CRM feature's application area from its setup Enabled flag whenever the experience tier is
/// recomputed (including after a setup toggle). A disabled feature's area stays off, hiding its pages.
/// </summary>
codeunit 50121 "NBC App Area Subscriber"
{
    Access = Internal;

    // This hooks a standard MS publisher that fires for EVERY session. This codeunit AND the Feature Mgt. it calls
    // are granted Unlicensed (permset "NBC Base Subscribers" -> entitlement "NBC Base Ent"), so every user can run
    // them and the subscription never errors. Safety is NOT from the skip flags (under Unlicensed nobody is
    // "missing" the object, so they never skip) — it's from Feature Mgt.IsEnabled, which guards each setup read by
    // the user's EFFECTIVE permission, returning false (area off) for a user without that plan/tier.
    // SkipOnMissingLicense/Permission = true is the PTE-build safety net: PTE has no entitlements, so if an admin
    // hasn't assigned "NBC Base Subscribers" to a user, the subscriber is skipped gracefully instead of erroring at
    // sign-in. See bc-dev-templates event-subscribers.md "License & permission".
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", OnGetEssentialExperienceAppAreas, '', true, true)]
    local procedure SetAppAreasOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        FeatureMgt: Codeunit "NBC Feature Mgt.";
    begin
        TempApplicationAreaSetup."NBC Ownership" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Ownership);
        TempApplicationAreaSetup."NBC Activities" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Activities);
        TempApplicationAreaSetup."NBC Party" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Party);
        TempApplicationAreaSetup."NBC Opportunity" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Opportunity);
        TempApplicationAreaSetup."NBC Process" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Process);
        TempApplicationAreaSetup."NBC Role Center" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::RoleCenter);
        TempApplicationAreaSetup."NBC Governance" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Governance);
        TempApplicationAreaSetup."NBC Catalog" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Catalog);
        TempApplicationAreaSetup."NBC Pricing" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Pricing);
        TempApplicationAreaSetup."NBC Linkage" := FeatureMgt.IsEnabled(Enum::"NBC Feature"::Linkage);
    end;
}
