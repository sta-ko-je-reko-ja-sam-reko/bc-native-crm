namespace NBC.CRM.Pricing;

/// <summary>Quantity tiers subpage for a CRM discount list.</summary>
page 50102 "NBC CRM Discount Tiers"
{
    PageType = ListPart;
    ApplicationArea = NBCPricing;
    SourceTable = "NBC CRM Discount Tier";
    Caption = 'Tiers';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Minimum Quantity"; Rec."Minimum Quantity") { }
                field("Maximum Quantity"; Rec."Maximum Quantity") { }
                field(Value; Rec.Value) { }
            }
        }
    }
}
