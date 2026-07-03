namespace NBC.CRM.Catalog;

/// <summary>Component lines subpage for a CRM bundle.</summary>
page 50092 "NBC CRM Bundle Lines"
{
    PageType = ListPart;
    ApplicationArea = NBCCatalog;
    SourceTable = "NBC CRM Bundle Line";
    Caption = 'Components';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Component Type"; Rec."Component Type") { }
                field("No."; Rec."No.") { }
                field(Description; Rec.Description) { }
                field(Quantity; Rec.Quantity) { }
                field("Unit Price"; Rec."Unit Price") { }
                field("Line Amount"; Rec."Line Amount") { }
                field(Required; Rec.Required) { }
            }
        }
    }
}
