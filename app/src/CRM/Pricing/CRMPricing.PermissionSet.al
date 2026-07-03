namespace NBC.CRM.Pricing;

using NBC.Setup;

/// <summary>Permissions for the CRM pricing-flexibility objects.</summary>
permissionset 50100 "NBC CRM Pricing"
{
    Caption = 'CRM Pricing';
    Assignable = true;

    Permissions =
        tabledata "NBC CRM Discount List" = RIMD,
        tabledata "NBC CRM Discount Tier" = RIMD,
        table "NBC CRM Discount List" = X,
        table "NBC CRM Discount Tier" = X,
        codeunit "NBC CRM Pricing Calc" = X,
        codeunit "NBC CRM Discount Mgt." = X,
        codeunit "NBC CRM Price Line Mgt." = X,
        page "NBC CRM Discount Lists" = X,
        page "NBC CRM Discount List Card" = X,
        page "NBC CRM Discount Tiers" = X,
        page "NBC CRM API Discount List" = X,
        page "NBC CRM API Discount Tier" = X,
        page "NBC CRM API Price Line" = X,
        tabledata "NBC Pricing Setup" = RIMD,
        table "NBC Pricing Setup" = X,
        page "NBC Pricing Setup" = X;
}
