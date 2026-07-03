namespace NBC.Setup;

/// <summary>Single-record setup for the Ownership and Teams feature.</summary>
table 50130 "NBC Ownership Setup"
{
    Caption = 'Ownership Setup';
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
            ToolTip = 'Specifies whether record ownership and teams are enabled. Turning this on shows the related fields, pages and actions; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
