namespace NBC.CRM.Catalog;

using NBC.Setup;

/// <summary>Permissions for the CRM product sales-catalog objects.</summary>
permissionset 50090 "NBC CRM Catalog"
{
    Caption = 'CRM Catalog';
    Assignable = true;

    Permissions =
        tabledata "NBC CRM Product Rel." = RIMD,
        tabledata "NBC CRM Bundle" = RIMD,
        tabledata "NBC CRM Bundle Line" = RIMD,
        table "NBC CRM Product Rel." = X,
        table "NBC CRM Bundle" = X,
        table "NBC CRM Bundle Line" = X,
        codeunit "NBC CRM Catalog Mgt." = X,
        codeunit "NBC CRM Bundle Logic" = X,
        codeunit "NBC CRM Bundle Mgt." = X,
        page "NBC CRM Bundles" = X,
        page "NBC CRM Bundle Card" = X,
        page "NBC CRM Bundle Lines" = X,
        page "NBC CRM Product Relations" = X,
        page "NBC CRM API Bundle" = X,
        page "NBC CRM API Bundle Line" = X,
        page "NBC CRM API Product Rel." = X,
        page "NBC CRM API Item" = X,
        page "NBC CRM API Resource" = X,
        tabledata "NBC Catalog Setup" = RIMD,
        table "NBC Catalog Setup" = X,
        page "NBC Catalog Setup" = X;
}
