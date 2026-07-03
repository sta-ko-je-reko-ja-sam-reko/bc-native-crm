namespace NBC.Setup;

/// <summary>Single-record setup for the Activities and Timeline feature.</summary>
table 50131 "NBC Activity Setup"
{
    Caption = 'Activity Setup';
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
            ToolTip = 'Specifies whether the activity timeline is enabled. Turning this on shows the related pages and actions; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
