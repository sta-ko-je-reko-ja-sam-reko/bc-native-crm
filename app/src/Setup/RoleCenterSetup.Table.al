namespace NBC.Setup;

/// <summary>Single-record setup for the Role Center feature.</summary>
table 50135 "NBC Role Center Setup"
{
    Caption = 'Role Center Setup';
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
            ToolTip = 'Specifies whether the CRM role center and its cues are enabled. Turning this on shows the related pages; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
