namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>List of CRM Teams.</summary>
page 50020 "NBC CDS Teams"
{
    PageType = List;
    ApplicationArea = NBCOwnership;
    UsageCategory = Administration;
    SourceTable = "NBC CDS Team";
    CardPageId = "NBC CDS Team Card";
    Caption = 'CRM Teams';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code") { }
                field(Name; Rec.Name) { }
                field("Team Lead Salesp. Code"; Rec."Team Lead Salesp. Code") { }
                field("Member Count"; Rec."Member Count") { }
            }
        }
    }
}
