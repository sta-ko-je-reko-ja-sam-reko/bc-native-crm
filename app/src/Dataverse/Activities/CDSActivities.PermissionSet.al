namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;
using NBC.Setup;

/// <summary>Permissions for the CRM activities &amp; timeline objects.</summary>
permissionset 50030 "NBC CDS Activities"
{
    Caption = 'CRM Activities';
    Assignable = true;

    Permissions =
        tabledata "NBC CDS Activity" = RIMD,
        table "NBC CDS Activity" = X,
        codeunit "NBC CDS Activity Mgt." = X,
        codeunit "NBC CDS Activity Logic" = X,
        page "NBC CDS Activities" = X,
        page "NBC CDS Activity Card" = X,
        page "NBC CDS Timeline Part" = X,
        page "NBC CDS API Activity" = X,
        tabledata "NBC Activity Setup" = RIMD,
        table "NBC Activity Setup" = X,
        page "NBC Activity Setup" = X;
}
