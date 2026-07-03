namespace NBC.CRM.Pricing;

/// <summary>How a price-list line derives its unit price (the Dataverse pricingmethodcode analog).</summary>
enum 50100 "NBC CRM Pricing Method"
{
    Extensible = true;
    Caption = 'CRM Pricing Method';

    value(0; "Currency Amount") { Caption = 'Currency Amount'; }
    value(1; "Percent of List") { Caption = 'Percent of List'; }
    value(2; "Markup on Cost") { Caption = 'Percent Markup on Cost'; }
    value(3; "Margin on Cost") { Caption = 'Percent Margin on Cost'; }
}
