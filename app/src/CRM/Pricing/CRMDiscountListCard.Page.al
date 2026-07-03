namespace NBC.CRM.Pricing;

/// <summary>Card for a CRM discount list and its quantity tiers.</summary>
page 50101 "NBC CRM Discount List Card"
{
    PageType = Card;
    ApplicationArea = NBCPricing;
    UsageCategory = None;
    SourceTable = "NBC CRM Discount List";
    Caption = 'CRM Discount List';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { }
                field(Description; Rec.Description) { }
                field("Discount Type"; Rec."Discount Type") { }
            }
            part(Tiers; "NBC CRM Discount Tiers")
            {
                ApplicationArea = NBCPricing;
                SubPageLink = "Discount List Code" = field("Code");
                UpdatePropagation = Both;
            }
        }
    }
}
