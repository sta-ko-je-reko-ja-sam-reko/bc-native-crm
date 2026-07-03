namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;
using NBC.Setup;

/// <summary>Adds the CRM activity Timeline FactBox and activity actions to the Customer Card, gated by the Activities feature.</summary>
pageextension 50030 "NBC CDS Act. Customer Card" extends "Customer Card"
{
    layout
    {
        addfirst(factboxes)
        {
            part(NBCTimeline; "NBC CDS Timeline Part")
            {
                ApplicationArea = NBCActivities;
                AccessByPermission = tabledata "NBC Activity Setup" = R;
                Caption = 'Timeline';
                // 18 = Database::Customer
                SubPageLink = "Regarding Table No." = const(18), "Regarding System ID" = field(SystemId);
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCActivityActions)
            {
                Caption = 'CRM';
                action(NBCNewActivity)
                {
                    ApplicationArea = NBCActivities;
                    AccessByPermission = tabledata "NBC Activity Setup" = R;
                    Caption = 'New CRM activity';
                    Image = Add;
                    ToolTip = 'Creates a CRM activity regarding this customer.';

                    trigger OnAction()
                    var
                        Activity: Record "NBC CDS Activity";
                        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
                    begin
                        ActivityMgt.InitActivityForRecord(Activity, Database::Customer, Rec.SystemId, Rec.Name);
                        Activity.Insert(true);
                        Page.Run(Page::"NBC CDS Activity Card", Activity);
                    end;
                }
                action(NBCShowActivities)
                {
                    ApplicationArea = NBCActivities;
                    AccessByPermission = tabledata "NBC Activity Setup" = R;
                    Caption = 'CRM activities';
                    Image = List;
                    ToolTip = 'Shows all CRM activities regarding this customer.';

                    trigger OnAction()
                    var
                        Activity: Record "NBC CDS Activity";
                    begin
                        Activity.SetRange("Regarding Table No.", Database::Customer);
                        Activity.SetRange("Regarding System ID", Rec.SystemId);
                        Page.Run(Page::"NBC CDS Activities", Activity);
                    end;
                }
            }
        }
    }
}
