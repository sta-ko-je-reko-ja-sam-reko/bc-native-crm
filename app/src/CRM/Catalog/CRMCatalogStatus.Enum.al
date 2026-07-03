namespace NBC.CRM.Catalog;

/// <summary>Selling lifecycle of a catalog record (the Dataverse product statecode analog).</summary>
enum 50090 "NBC CRM Catalog Status"
{
    Extensible = true;
    Caption = 'CRM Catalog Status';

    value(0; Draft) { Caption = 'Draft'; }
    value(1; Active) { Caption = 'Active'; }
    value(2; Retired) { Caption = 'Retired'; }
}
