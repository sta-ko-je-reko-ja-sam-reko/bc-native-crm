namespace NBC.CRM.Catalog;

/// <summary>Whether a catalog reference points at a BC Item (goods) or Resource (time).</summary>
enum 50092 "NBC CRM Catalog Item Type"
{
    Extensible = true;
    Caption = 'CRM Catalog Item Type';

    value(0; Item) { Caption = 'Item'; }
    value(1; Resource) { Caption = 'Resource'; }
}
