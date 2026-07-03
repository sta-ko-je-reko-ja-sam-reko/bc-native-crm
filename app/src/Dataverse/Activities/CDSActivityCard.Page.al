namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Card for a single CRM activity.</summary>
page 50031 "NBC CDS Activity Card"
{
    PageType = Card;
    ApplicationArea = NBCActivities;
    UsageCategory = None;
    SourceTable = "NBC CDS Activity";
    Caption = 'CRM Activity';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Activity Type"; Rec."Activity Type") { }
                field(Subject; Rec.Subject) { }
                field(Status; Rec.Status) { }
                field(Priority; Rec.Priority) { }
                field(Direction; Rec.Direction) { }
                field("Activity Date"; Rec."Activity Date") { }
                field("Due Date"; Rec."Due Date") { }
            }
            group(Regarding)
            {
                Caption = 'Regarding';
                field("Regarding Description"; Rec."Regarding Description") { }
            }
            group(Ownership)
            {
                Caption = 'CRM';
                field("Owner Type"; Rec."Owner Type") { }
                field("Owner Code"; Rec."Owner Code") { }
            }
            group(Details)
            {
                Caption = 'Details';
                field(Description; Rec.Description) { MultiLine = true; }
            }
            group(Audit)
            {
                Caption = 'Audit';
                field("Created By"; Rec."Created By") { }
                field("Closed DateTime"; Rec."Closed DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Complete)
            {
                ApplicationArea = NBCActivities;
                Caption = 'Complete';
                Image = Completed;
                ToolTip = 'Marks the activity as completed.';

                trigger OnAction()
                var
                    ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
                begin
                    ActivityMgt.CompleteActivity(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
