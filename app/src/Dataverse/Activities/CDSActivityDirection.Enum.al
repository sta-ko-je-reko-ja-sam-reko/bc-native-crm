namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Direction of a CRM activity (for phone calls / emails).</summary>
enum 50033 "NBC CDS Activity Direction"
{
    Extensible = true;
    Caption = 'CRM Activity Direction';

    value(0; " ") { Caption = ' '; }
    value(1; Incoming) { Caption = 'Incoming'; }
    value(2; Outgoing) { Caption = 'Outgoing'; }
}
