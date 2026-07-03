namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using NBC.Setup;
using System.Security.User;

/// <summary>Surfaces CRM ownership on the Contact Card (CRM group + CRM actions), gated by the Ownership feature.</summary>
pageextension 50022 "NBC CDS Owner Contact Card" extends "Contact Card"
{
    layout
    {
        addlast(content)
        {
            group(NBCInfo)
            {
                Caption = 'CRM';
                field("NBC CDS Owner Type"; Rec."NBC CDS Owner Type") { ApplicationArea = NBCOwnership; AccessByPermission = tabledata "NBC Ownership Setup" = R; }
                field("NBC CDS Owner Code"; Rec."NBC CDS Owner Code") { ApplicationArea = NBCOwnership; AccessByPermission = tabledata "NBC Ownership Setup" = R; }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCActions)
            {
                Caption = 'CRM';
                action(NBCAssignToMe)
                {
                    ApplicationArea = NBCOwnership;
                    AccessByPermission = tabledata "NBC Ownership Setup" = R;
                    Caption = 'Assign to me';
                    Image = User;
                    ToolTip = 'Assigns CRM ownership of this record to your salesperson.';

                    trigger OnAction()
                    var
                        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
                        MySalesperson: Code[20];
                    begin
                        MySalesperson := OwnerMgt.GetCurrentUserSalesperson();
                        if MySalesperson = '' then
                            Error(NoSalespersonErr);
                        Rec."NBC CDS Owner Type" := Rec."NBC CDS Owner Type"::Salesperson;
                        Rec."NBC CDS Owner Code" := MySalesperson;
                        Rec.Modify(true);
                    end;
                }
            }
        }
    }

    var
        NoSalespersonErr: Label 'Your user is not linked to a salesperson in User Setup.';
}
