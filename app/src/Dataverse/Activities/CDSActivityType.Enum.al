namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Kind of CRM activity — mirrors the Dataverse activity entities.</summary>
enum 50030 "NBC CDS Activity Type"
{
    Extensible = true;
    Caption = 'CRM Activity Type';

    value(0; Task) { Caption = 'Task'; }
    value(1; "Phone Call") { Caption = 'Phone Call'; }
    value(2; Appointment) { Caption = 'Appointment'; }
    value(3; Email) { Caption = 'Email'; }
    value(4; Note) { Caption = 'Note'; }
}
