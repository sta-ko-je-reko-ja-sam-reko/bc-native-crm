namespace NBC.CRM.Pricing;

/// <summary>Whether a discount tier expresses a percentage or a fixed amount.</summary>
enum 50102 "NBC CRM Discount Type"
{
    Extensible = true;
    Caption = 'CRM Discount Type';

    value(0; Percentage) { Caption = 'Percentage'; }
    value(1; Amount) { Caption = 'Amount'; }
}
