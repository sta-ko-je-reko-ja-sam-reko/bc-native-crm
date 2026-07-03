namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Lifecycle status of a CRM activity.</summary>
enum 50031 "NBC CDS Activity Status"
{
    Extensible = true;
    Caption = 'CRM Activity Status';

    value(0; Open) { Caption = 'Open'; }
    value(1; Completed) { Caption = 'Completed'; }
    value(2; Canceled) { Caption = 'Canceled'; }
}
