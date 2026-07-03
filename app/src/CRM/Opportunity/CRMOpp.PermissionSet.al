namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using NBC.Setup;

/// <summary>Permissions for the CRM opportunity-depth objects.</summary>
permissionset 50040 "NBC CRM Opp."
{
    Caption = 'CRM Opportunities';
    Assignable = true;

    Permissions =
        tabledata "NBC CRM Opp. Line" = RIMD,
        tabledata "NBC CRM Opp. Competitor" = RIMD,
        tabledata "NBC CRM Opp. Stakeholder" = RIMD,
        table "NBC CRM Opp. Line" = X,
        table "NBC CRM Opp. Competitor" = X,
        table "NBC CRM Opp. Stakeholder" = X,
        codeunit "NBC CRM Opp. Line Logic" = X,
        codeunit "NBC CRM Opportunity Mgt." = X,
        page "NBC CRM Opp. Lines" = X,
        page "NBC CRM Opp. Competitors" = X,
        page "NBC CRM Opp. Stakeholders" = X,
        page "NBC CRM API Opportunity" = X,
        page "NBC CRM API Opp. Line" = X,
        page "NBC CRM API Opp. Competitor" = X,
        page "NBC CRM API Opp. Stakeholder" = X,
        tabledata "NBC Opportunity Setup" = RIMD,
        table "NBC Opportunity Setup" = X,
        page "NBC Opportunity Setup" = X;
}
