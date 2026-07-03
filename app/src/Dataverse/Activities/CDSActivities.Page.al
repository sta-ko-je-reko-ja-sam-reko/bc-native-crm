namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>List of CRM activities.</summary>
page 50030 "NBC CDS Activities"
{
    PageType = List;
    ApplicationArea = NBCActivities;
    UsageCategory = Tasks;
    SourceTable = "NBC CDS Activity";
    CardPageId = "NBC CDS Activity Card";
    Caption = 'CRM Activities';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Activity Type"; Rec."Activity Type") { }
                field(Subject; Rec.Subject) { }
                field("Regarding Description"; Rec."Regarding Description") { }
                field("Activity Date"; Rec."Activity Date") { }
                field("Owner Code"; Rec."Owner Code") { }
                field(Priority; Rec.Priority) { }
                field(Status; Rec.Status) { }
            }
        }
    }
}
