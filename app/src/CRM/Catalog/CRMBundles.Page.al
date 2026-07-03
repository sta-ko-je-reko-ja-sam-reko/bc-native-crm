namespace NBC.CRM.Catalog;

/// <summary>List of CRM bundles.</summary>
page 50090 "NBC CRM Bundles"
{
    PageType = List;
    ApplicationArea = NBCCatalog;
    UsageCategory = Lists;
    SourceTable = "NBC CRM Bundle";
    CardPageId = "NBC CRM Bundle Card";
    Caption = 'CRM Bundles';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.") { }
                field(Description; Rec.Description) { }
                field("Catalog Status"; Rec."Catalog Status") { }
                field("Unit Price"; Rec."Unit Price") { }
                field("Component Total"; Rec."Component Total") { }
            }
        }
    }
}
