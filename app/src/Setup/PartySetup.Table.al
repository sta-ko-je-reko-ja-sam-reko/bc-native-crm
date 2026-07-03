namespace NBC.Setup;

/// <summary>Single-record setup for the Party Enrichment feature.</summary>
table 50132 "NBC Party Setup"
{
    Caption = 'Party Enrichment Setup';
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
            ToolTip = 'Specifies whether party enrichment (classification, firmographics and preferences) is enabled. Turning this on shows the related fields and actions; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
