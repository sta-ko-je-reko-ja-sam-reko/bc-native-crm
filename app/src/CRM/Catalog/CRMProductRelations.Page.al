namespace NBC.CRM.Catalog;

/// <summary>List of seller-facing product relationships (cross-sell / up-sell / accessory / substitute).</summary>
page 50093 "NBC CRM Product Relations"
{
    PageType = List;
    ApplicationArea = NBCCatalog;
    UsageCategory = Lists;
    SourceTable = "NBC CRM Product Rel.";
    Caption = 'CRM Product Relations';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("From Type"; Rec."From Type") { }
                field("From No."; Rec."From No.") { }
                field("Relationship Type"; Rec."Relationship Type") { }
                field("To Type"; Rec."To Type") { }
                field("To No."; Rec."To No.") { }
                field(Description; Rec.Description) { }
                field(Rank; Rec.Rank) { }
            }
        }
    }
}
