namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Opportunity stakeholders subpage.</summary>
page 50042 "NBC CRM Opp. Stakeholders"
{
    PageType = ListPart;
    ApplicationArea = NBCOpportunity;
    SourceTable = "NBC CRM Opp. Stakeholder";
    Caption = 'Stakeholders';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Contact No."; Rec."Contact No.") { }
                field("Contact Name"; Rec."Contact Name") { }
                field(Role; Rec.Role) { }
                field("Role Description"; Rec."Role Description") { }
            }
        }
    }
}
