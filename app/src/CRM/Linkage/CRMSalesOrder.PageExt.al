namespace NBC.CRM.Linkage;

using Microsoft.Sales.Document;
using NBC.Setup;

/// <summary>
/// Surfaces the pipeline link, CRM sales status and lifecycle actions on the Sales Order, gated by the Linkage
/// feature. BC's own Status, posting and fulfillment are untouched.
/// </summary>
pageextension 50143 "NBC CRM Sales Order" extends "Sales Order"
{
    layout
    {
        addlast(content)
        {
            group(NBCPipeline)
            {
                Caption = 'CRM';
                field("NBC CRM Opportunity No."; Rec."NBC CRM Opportunity No.")
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                }
                field("NBC CRM Sales Status"; Rec."NBC CRM Sales Status")
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                }
                field("NBC CRM Pricing Locked"; Rec."NBC CRM Pricing Locked")
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCLinkageActions)
            {
                Caption = 'CRM';
                action(NBCSubmit)
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Caption = 'Submit (CRM)';
                    Image = ReleaseDoc;
                    ToolTip = 'Sets the CRM sales status of this order to Submitted.';

                    trigger OnAction()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.SubmitOrder(Rec);
                    end;
                }
                action(NBCMarkFulfilled)
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Caption = 'Mark fulfilled (CRM)';
                    Image = Completed;
                    ToolTip = 'Sets the CRM sales status of this order to Fulfilled.';

                    trigger OnAction()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.MarkOrderFulfilled(Rec);
                    end;
                }
                action(NBCCancelCrm)
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Caption = 'Cancel (CRM)';
                    Image = Cancel;
                    ToolTip = 'Sets the CRM sales status of this order to Canceled.';

                    trigger OnAction()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.CancelOrder(Rec);
                    end;
                }
                action(NBCLockPricing)
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Caption = 'Lock pricing (CRM)';
                    Image = Lock;
                    ToolTip = 'Freezes the CRM prices on this order.';

                    trigger OnAction()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.LockPricing(Rec);
                    end;
                }
            }
        }
    }
}
