namespace NBC.CRM.Linkage;

using NBC.Setup;

/// <summary>Permissions for the transaction ↔ pipeline linkage objects.</summary>
permissionset 50140 "NBC CRM Linkage"
{
    Caption = 'CRM Pipeline Linkage';
    Assignable = true;

    Permissions =
        codeunit "NBC CRM Linkage Mgt." = X,
        codeunit "NBC CRM Linkage Reactions" = X,
        codeunit "NBC CRM Linkage Subscribers" = X,
        page "NBC CRM API Sales Order" = X,
        page "NBC CRM API Sales Invoice" = X,
        tabledata "NBC Linkage Setup" = RIMD,
        table "NBC Linkage Setup" = X,
        page "NBC Linkage Setup" = X;
}
