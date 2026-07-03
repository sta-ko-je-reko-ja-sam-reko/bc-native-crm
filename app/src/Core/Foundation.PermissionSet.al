namespace NBC.Core;

using NBC.Dataverse.Ownership;
using NBC.Dataverse.PartyEnrichment;
using NBC.Setup;

/// <summary>Permissions for the CRM foundation (ownership &amp; teams) objects.</summary>
permissionset 50000 "NBC Foundation"
{
    Caption = 'CRM Foundation';
    Assignable = true;

    Permissions =
        tabledata "NBC CDS Team" = RIMD,
        tabledata "NBC CDS Team Member" = RIMD,
        table "NBC CDS Team" = X,
        table "NBC CDS Team Member" = X,
        codeunit "NBC Service Locator" = X,
        codeunit "NBC Access Policy" = X,
        codeunit "NBC CDS Owner Mgt." = X,
        codeunit "NBC CDS Team Logic" = X,
        codeunit "NBC CDS Owner Reactions" = X,
        codeunit "NBC MCP Setup" = X,
        codeunit "NBC Feature Mgt." = X,
        tabledata "NBC Ownership Setup" = RIMD,
        tabledata "NBC Party Setup" = RIMD,
        table "NBC Ownership Setup" = X,
        table "NBC Party Setup" = X,
        page "NBC Ownership Setup" = X,
        page "NBC Party Setup" = X,
        page "NBC CDS Teams" = X,
        page "NBC CDS Team Card" = X,
        page "NBC CDS Team Members" = X,
        page "NBC CDS API Team" = X,
        page "NBC CDS API Team Member" = X,
        page "NBC CDS API Customer" = X,
        page "NBC CDS API Contact" = X;
}
