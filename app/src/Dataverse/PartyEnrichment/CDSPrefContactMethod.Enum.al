namespace NBC.Dataverse.PartyEnrichment;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;

/// <summary>Preferred way to contact a party — mirrors the Dataverse preferredcontactmethodcode.</summary>
enum 50050 "NBC CDS Pref. Contact Method"
{
    Extensible = true;
    Caption = 'CRM Preferred Contact Method';

    value(0; Any) { Caption = 'Any'; }
    value(1; Email) { Caption = 'Email'; }
    value(2; Phone) { Caption = 'Phone'; }
    value(3; Mail) { Caption = 'Mail'; }
}
