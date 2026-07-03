namespace NBC.CRM.Pricing;

/// <summary>List of reusable CRM discount lists.</summary>
page 50100 "NBC CRM Discount Lists"
{
    PageType = List;
    ApplicationArea = NBCPricing;
    UsageCategory = Lists;
    SourceTable = "NBC CRM Discount List";
    CardPageId = "NBC CRM Discount List Card";
    Caption = 'CRM Discount Lists';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code") { }
                field(Description; Rec.Description) { }
                field("Discount Type"; Rec."Discount Type") { }
            }
        }
    }
}
