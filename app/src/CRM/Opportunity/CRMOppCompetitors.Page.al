namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Opportunity competitors subpage.</summary>
page 50041 "NBC CRM Opp. Competitors"
{
    PageType = ListPart;
    ApplicationArea = NBCOpportunity;
    SourceTable = "NBC CRM Opp. Competitor";
    Caption = 'Competitors';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name) { }
                field("Threat Level"; Rec."Threat Level") { }
                field(Strengths; Rec.Strengths) { }
                field(Weaknesses; Rec.Weaknesses) { }
            }
        }
    }
}
