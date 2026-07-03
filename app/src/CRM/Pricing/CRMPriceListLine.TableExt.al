namespace NBC.CRM.Pricing;

using Microsoft.Pricing.PriceList;

/// <summary>CRM pricing flexibility on the standard Price List Line: method, discount tiers, rounding, qty selling.</summary>
tableextension 50100 "NBC CRM Price List Line" extends "Price List Line"
{
    fields
    {
        field(50100; "NBC CRM Pricing Method"; Enum "NBC CRM Pricing Method")
        {
            Caption = 'CRM Pricing Method';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how the unit price is derived (fixed, percent of list, or markup/margin on cost).';
        }
        field(50101; "NBC CRM Pricing %"; Decimal)
        {
            Caption = 'CRM Pricing %';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the percentage used by the pricing method.';
        }
        field(50102; "NBC CRM Discount List"; Code[20])
        {
            Caption = 'CRM Discount List';
            DataClassification = CustomerContent;
            TableRelation = "NBC CRM Discount List";
            ToolTip = 'Specifies a reusable volume discount list applied to the line.';
        }
        field(50103; "NBC CRM Rounding Policy"; Enum "NBC CRM Rounding Policy")
        {
            Caption = 'CRM Rounding Policy';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how the computed price is rounded.';
        }
        field(50104; "NBC CRM Rounding Precision"; Decimal)
        {
            Caption = 'CRM Rounding Precision';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the precision used when rounding the computed price (for example 0.99 or 5).';
        }
        field(50105; "NBC CRM Qty. Selling"; Enum "NBC CRM Qty. Selling")
        {
            Caption = 'CRM Quantity Selling';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the item may be sold in whole or fractional quantities.';
        }
    }
}
