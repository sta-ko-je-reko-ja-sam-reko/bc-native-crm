namespace NBC.Dataverse.PartyEnrichment;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;

/// <summary>Consent and preference fields on Contact.</summary>
tableextension 50051 "NBC CDS Enrich Contact" extends Contact
{
    fields
    {
        field(50054; "NBC CDS Contact Method"; Enum "NBC CDS Pref. Contact Method")
        {
            Caption = 'CRM Preferred Contact Method';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the preferred way to contact this contact.';
        }
        field(50055; "NBC CDS Do Not Email"; Boolean)
        {
            Caption = 'CRM Do Not Email';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that this contact should not be contacted by email.';
        }
        field(50056; "NBC CDS Do Not Phone"; Boolean)
        {
            Caption = 'CRM Do Not Phone';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that this contact should not be contacted by phone.';
        }
        field(50057; "NBC CDS Do Not Bulk Email"; Boolean)
        {
            Caption = 'CRM Do Not Bulk Email';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that this contact should be excluded from bulk email.';
        }
    }
}
