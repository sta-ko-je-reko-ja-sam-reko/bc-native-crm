namespace NBC.CRM.Pricing;

using Microsoft.Pricing.PriceList;
using NBC.Setup;

/// <summary>CRM pricing-method fields + a Recalculate CRM price action on the Price List Lines part, gated by the Pricing feature.</summary>
pageextension 50100 "NBC CRM Price List Lines" extends "Price List Lines"
{
    layout
    {
        addlast(Control1)
        {
            field("NBC CRM Pricing Method"; Rec."NBC CRM Pricing Method") { ApplicationArea = NBCPricing; AccessByPermission = tabledata "NBC Pricing Setup" = R; }
            field("NBC CRM Pricing %"; Rec."NBC CRM Pricing %") { ApplicationArea = NBCPricing; AccessByPermission = tabledata "NBC Pricing Setup" = R; }
            field("NBC CRM Discount List"; Rec."NBC CRM Discount List") { ApplicationArea = NBCPricing; AccessByPermission = tabledata "NBC Pricing Setup" = R; }
            field("NBC CRM Rounding Policy"; Rec."NBC CRM Rounding Policy") { ApplicationArea = NBCPricing; AccessByPermission = tabledata "NBC Pricing Setup" = R; }
            field("NBC CRM Rounding Precision"; Rec."NBC CRM Rounding Precision") { ApplicationArea = NBCPricing; AccessByPermission = tabledata "NBC Pricing Setup" = R; }
            field("NBC CRM Qty. Selling"; Rec."NBC CRM Qty. Selling") { ApplicationArea = NBCPricing; AccessByPermission = tabledata "NBC Pricing Setup" = R; }
        }
    }

    actions
    {
        addlast(Processing)
        {
            group(NBCPricingActions)
            {
                Caption = 'CRM';
                action(NBCRecalcPrice)
                {
                    ApplicationArea = NBCPricing;
                    AccessByPermission = tabledata "NBC Pricing Setup" = R;
                    Caption = 'Recalculate CRM price';
                    Image = Calculate;
                    ToolTip = 'Derives the unit price from the CRM pricing method and applies the rounding rule.';

                    trigger OnAction()
                    var
                        PriceLineMgt: Codeunit "NBC CRM Price Line Mgt.";
                    begin
                        PriceLineMgt.RecalculatePrice(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
}
