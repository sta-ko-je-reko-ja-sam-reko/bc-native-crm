namespace NBC.Dataverse.PartyEnrichment;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;

/// <summary>Hierarchy, firmographic and consent fields on Customer.</summary>
tableextension 50050 "NBC CDS Enrich Customer" extends Customer
{
    fields
    {
        field(50050; "NBC CDS Parent Customer No."; Code[20])
        {
            Caption = 'CRM Parent Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ToolTip = 'Specifies the parent customer in the account hierarchy.';
        }
        field(50051; "NBC CDS Industry Group Code"; Code[10])
        {
            Caption = 'CRM Industry Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Industry Group";
            ToolTip = 'Specifies the industry of the customer.';
        }
        field(50052; "NBC CDS Annual Revenue"; Decimal)
        {
            Caption = 'CRM Annual Revenue';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the estimated annual revenue of the customer.';
        }
        field(50053; "NBC CDS No. of Employees"; Integer)
        {
            Caption = 'CRM No. of Employees';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of employees at the customer.';
        }
        field(50054; "NBC CDS Contact Method"; Enum "NBC CDS Pref. Contact Method")
        {
            Caption = 'CRM Preferred Contact Method';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the preferred way to contact the customer.';
        }
        field(50055; "NBC CDS Do Not Email"; Boolean)
        {
            Caption = 'CRM Do Not Email';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the customer should not be contacted by email.';
        }
        field(50056; "NBC CDS Do Not Phone"; Boolean)
        {
            Caption = 'CRM Do Not Phone';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the customer should not be contacted by phone.';
        }
        field(50057; "NBC CDS Do Not Bulk Email"; Boolean)
        {
            Caption = 'CRM Do Not Bulk Email';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the customer should be excluded from bulk email.';
        }
    }
}
