namespace NBC.CRM.Linkage;

using Microsoft.CRM.Opportunity;
using NBC.Setup;

/// <summary>
/// Closes the pipeline loop on the Opportunity Card: counts of the resulting orders and posted invoices, with
/// drill-down actions. Gated by the Linkage feature. A second pageextension on the card (the Opportunity feature
/// owns the first).
/// </summary>
pageextension 50145 "NBC CRM Link Opp. Card" extends "Opportunity Card"
{
    layout
    {
        addlast(content)
        {
            group(NBCLinkage)
            {
                Caption = 'CRM Transactions';
                field("NBC CRM Linked Orders"; Rec."NBC CRM Linked Orders")
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;

                    trigger OnDrillDown()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.ShowLinkedOrders(Rec);
                    end;
                }
                field("NBC CRM Linked Invoices"; Rec."NBC CRM Linked Invoices")
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;

                    trigger OnDrillDown()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.ShowLinkedInvoices(Rec);
                    end;
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
                Caption = 'CRM Transactions';
                action(NBCShowOrders)
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Caption = 'Linked orders';
                    Image = OrderList;
                    ToolTip = 'Shows the sales orders that trace back to this opportunity.';

                    trigger OnAction()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.ShowLinkedOrders(Rec);
                    end;
                }
                action(NBCShowInvoices)
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Caption = 'Linked invoices';
                    Image = Invoice;
                    ToolTip = 'Shows the posted sales invoices that trace back to this opportunity.';

                    trigger OnAction()
                    var
                        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
                    begin
                        LinkageMgt.ShowLinkedInvoices(Rec);
                    end;
                }
            }
        }
    }
}
