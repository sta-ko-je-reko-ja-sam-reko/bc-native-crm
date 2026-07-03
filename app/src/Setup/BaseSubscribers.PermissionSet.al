namespace NBC.Setup;

using NBC.Core;
using NBC.Dataverse.Ownership;

/// <summary>
/// Execute permission for the always-on codeunits that MUST run for EVERY user in the tenant — the base-app
/// subscriber proxies, the feature facade they call, the Service Locator that resolves them, and the default
/// access policy that performs the effective-permission check. Granted to all users by the Unlicensed
/// <see cref="NBC Base Ent"/> entitlement (AppSource) or assigned to all users by the admin (PTE). These
/// codeunits only ever check permission by object id via Microsoft objects and never touch a licensed product
/// object or expose product data, so granting them broadly is safe.
/// </summary>
permissionset 50121 "NBC Base Subscribers"
{
    Caption = 'CRM Base Subscribers';
    Assignable = true;

    Permissions =
        codeunit "NBC CDS Owner Subscribers" = X,
        codeunit "NBC App Area Subscriber" = X,
        codeunit "NBC Feature Mgt." = X,
        codeunit "NBC Service Locator" = X,
        codeunit "NBC Access Policy" = X,
        // Object permission (X) only — NOT tabledata — so Feature Mgt. can reference the setup Record types for
        // EVERY user (Unlicensed) while data access stays gated: IsEnabled reads only after an effective-permission
        // check, and AccessByPermission on the surfaced controls keys off tabledata, which is granted only by the
        // module (offer-plan) sets. So no unentitled user can read/see feature data through this broad object grant.
        table "NBC Ownership Setup" = X,
        table "NBC Activity Setup" = X,
        table "NBC Party Setup" = X,
        table "NBC Opportunity Setup" = X,
        table "NBC Process Setup" = X,
        table "NBC Role Center Setup" = X,
        table "NBC Governance Setup" = X,
        table "NBC Catalog Setup" = X,
        table "NBC Pricing Setup" = X;
}
