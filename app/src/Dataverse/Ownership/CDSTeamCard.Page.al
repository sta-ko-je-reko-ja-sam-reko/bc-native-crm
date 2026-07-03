namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>Card for a CRM Team, with its members.</summary>
page 50021 "NBC CDS Team Card"
{
    PageType = Card;
    ApplicationArea = NBCOwnership;
    UsageCategory = None;
    SourceTable = "NBC CDS Team";
    Caption = 'CRM Team';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { }
                field(Name; Rec.Name) { }
                field(Description; Rec.Description) { }
                field("Team Lead Salesp. Code"; Rec."Team Lead Salesp. Code") { }
            }
            part(Members; "NBC CDS Team Members")
            {
                ApplicationArea = NBCOwnership;
                Caption = 'Members';
                SubPageLink = "Team Code" = field("Code");
                UpdatePropagation = Both;
            }
        }
    }
}
