namespace NBC.CRM.Catalog;

/// <summary>Card for a CRM bundle and its component lines.</summary>
page 50091 "NBC CRM Bundle Card"
{
    PageType = Card;
    ApplicationArea = NBCCatalog;
    UsageCategory = None;
    SourceTable = "NBC CRM Bundle";
    Caption = 'CRM Bundle';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { }
                field(Description; Rec.Description) { }
                field("Catalog Status"; Rec."Catalog Status") { }
                field("Unit Price"; Rec."Unit Price") { }
                field("Component Total"; Rec."Component Total") { }
            }
            part(Lines; "NBC CRM Bundle Lines")
            {
                ApplicationArea = NBCCatalog;
                SubPageLink = "Bundle No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
}
