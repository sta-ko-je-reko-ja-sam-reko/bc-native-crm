namespace NBC.CRM.Catalog;

/// <summary>Kind of seller-facing relationship between two catalog products.</summary>
enum 50091 "NBC CRM Product Rel. Type"
{
    Extensible = true;
    Caption = 'CRM Product Relationship Type';

    value(0; Substitute) { Caption = 'Substitute'; }
    value(1; CrossSell) { Caption = 'Cross-sell'; }
    value(2; UpSell) { Caption = 'Up-sell'; }
    value(3; Accessory) { Caption = 'Accessory'; }
}
