namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using NBC.Setup;
using System.Security.User;

/// <summary>Owner column + "my CRM records" scoping on the Customer List, gated by the Ownership feature.</summary>
pageextension 50021 "NBC CDS Owner Customer List" extends "Customer List"
{
    layout
    {
        addafter("No.")
        {
            field("NBC CDS Owner Type"; Rec."NBC CDS Owner Type") { ApplicationArea = NBCOwnership; AccessByPermission = tabledata "NBC Ownership Setup" = R; Visible = false; }
            field("NBC CDS Owner Code"; Rec."NBC CDS Owner Code") { ApplicationArea = NBCOwnership; AccessByPermission = tabledata "NBC Ownership Setup" = R; }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCActions)
            {
                Caption = 'CRM';
                action(NBCShowMine)
                {
                    ApplicationArea = NBCOwnership;
                    AccessByPermission = tabledata "NBC Ownership Setup" = R;
                    Caption = 'Show my CRM records';
                    Image = FilterLines;
                    ToolTip = 'Filters the list to records owned by you or a team you belong to.';

                    trigger OnAction()
                    var
                        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
                        OwnerFilter: Text;
                    begin
                        OwnerFilter := OwnerMgt.GetMyOwnerCodeFilter();
                        if OwnerFilter = '' then
                            Error(NoOwnerKeysErr);
                        Rec.SetFilter("NBC CDS Owner Code", OwnerFilter);
                        CurrPage.Update(false);
                    end;
                }
                action(NBCShowAll)
                {
                    ApplicationArea = NBCOwnership;
                    AccessByPermission = tabledata "NBC Ownership Setup" = R;
                    Caption = 'Show all CRM records';
                    Image = ClearFilter;
                    ToolTip = 'Removes the CRM ownership filter.';

                    trigger OnAction()
                    begin
                        Rec.SetRange("NBC CDS Owner Code");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        NoOwnerKeysErr: Label 'Your user is not linked to a salesperson, so there are no CRM records to show.';
}
