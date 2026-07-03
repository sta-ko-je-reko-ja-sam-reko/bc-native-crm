namespace NBC.Setup;

/// <summary>Single-record setup for the Transaction Pipeline Linkage feature.</summary>
table 50139 "NBC Linkage Setup"
{
    Caption = 'Pipeline Linkage Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key of the single setup record.';
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            ToolTip = 'Specifies whether transaction-to-pipeline linkage is enabled. Turning this on shows the CRM opportunity link and sales status on orders and invoices; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
