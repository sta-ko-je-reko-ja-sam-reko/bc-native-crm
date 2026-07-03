namespace NBC.Setup;

/// <summary>The toggleable features of the CRM product — one value per feature setup / application area.</summary>
enum 50130 "NBC Feature"
{
    Extensible = true;
    Caption = 'CRM Feature';

    value(0; Ownership) { Caption = 'Ownership and Teams'; }
    value(1; Activities) { Caption = 'Activities and Timeline'; }
    value(2; Party) { Caption = 'Party Enrichment'; }
    value(3; Opportunity) { Caption = 'Opportunity Depth'; }
    value(4; Process) { Caption = 'Business Process Flow'; }
    value(5; RoleCenter) { Caption = 'Role Center'; }
    value(6; Governance) { Caption = 'Governance'; }
    value(7; Catalog) { Caption = 'Product Catalog'; }
    value(8; Pricing) { Caption = 'Pricing Flexibility'; }
    value(9; Linkage) { Caption = 'Transaction Pipeline Linkage'; }
}
