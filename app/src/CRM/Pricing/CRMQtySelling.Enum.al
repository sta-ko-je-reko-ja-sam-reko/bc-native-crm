namespace NBC.CRM.Pricing;

/// <summary>Quantity-selling constraint on a price line (the Dataverse quantitysellingcode analog).</summary>
enum 50103 "NBC CRM Qty. Selling"
{
    Extensible = true;
    Caption = 'CRM Quantity Selling';

    value(0; "None") { Caption = 'None'; }
    value(1; Whole) { Caption = 'Whole'; }
    value(2; "Whole and Fractional") { Caption = 'Whole and Fractional'; }
}
