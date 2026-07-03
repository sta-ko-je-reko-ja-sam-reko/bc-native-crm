namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Priority of a CRM activity.</summary>
enum 50032 "NBC CDS Activity Priority"
{
    Extensible = true;
    Caption = 'CRM Activity Priority';

    value(0; Normal) { Caption = 'Normal'; }
    value(1; Low) { Caption = 'Low'; }
    value(2; High) { Caption = 'High'; }
}
