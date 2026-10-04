namespace NBC.Demo;

/// <summary>
/// The demo-data layer's own objects only (dummy table, seeders, master runner, import API pages). Non-assignable
/// building block: the assignable <see cref="NBC Demo"/> set adds the base-app RapidStart tables on top, and the
/// entitlement-bound CRM license includes this one, because an entitlement ignores permissions on objects of other
/// modules (AL0684).
/// </summary>
permissionset 65185 "NBC Demo Obj"
{
    Caption = 'CRM Demo Data Objects';
    Assignable = false;

    Permissions =
        tabledata "NBC Demo Data" = RIMD,
        table "NBC Demo Data" = X,
        codeunit "NBC Demo Config Package" = X,
        codeunit "NBC Demo Data Mgt." = X,
        codeunit "NBC Demo Ownership" = X,
        codeunit "NBC Demo Activities" = X,
        codeunit "NBC Demo Party" = X,
        codeunit "NBC Demo Opportunity" = X,
        codeunit "NBC Demo Process" = X,
        codeunit "NBC Demo Role Center" = X,
        codeunit "NBC Demo Governance" = X,
        codeunit "NBC Demo Catalog" = X,
        codeunit "NBC Demo Pricing" = X,
        codeunit "NBC Demo Linkage" = X,
        page "NBC API Demo Ownership" = X,
        page "NBC API Demo Activities" = X,
        page "NBC API Demo Party" = X,
        page "NBC API Demo Opportunity" = X,
        page "NBC API Demo Process" = X,
        page "NBC API Demo Role Center" = X,
        page "NBC API Demo Governance" = X,
        page "NBC API Demo Catalog" = X,
        page "NBC API Demo Pricing" = X,
        page "NBC API Demo Linkage" = X;
}
