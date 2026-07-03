namespace NBC.CRM.Pricing;

/// <summary>Rounding direction applied to a computed price (the Dataverse roundingpolicycode analog).</summary>
enum 50101 "NBC CRM Rounding Policy"
{
    Extensible = true;
    Caption = 'CRM Rounding Policy';

    value(0; "None") { Caption = 'None'; }
    value(1; Up) { Caption = 'Up'; }
    value(2; Down) { Caption = 'Down'; }
    value(3; Nearest) { Caption = 'To Nearest'; }
}
