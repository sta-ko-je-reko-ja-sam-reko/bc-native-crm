namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>Members of a CRM Team (ListPart on the Team Card).</summary>
page 50022 "NBC CDS Team Members"
{
    PageType = ListPart;
    ApplicationArea = NBCOwnership;
    SourceTable = "NBC CDS Team Member";
    Caption = 'CRM Team Members';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field("Salesperson Name"; Rec."Salesperson Name") { }
                field("Team Lead"; Rec."Team Lead") { }
            }
        }
    }
}
