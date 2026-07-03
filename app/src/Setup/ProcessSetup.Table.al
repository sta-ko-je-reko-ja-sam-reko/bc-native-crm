namespace NBC.Setup;

/// <summary>Single-record setup for the Business Process Flow feature.</summary>
table 50134 "NBC Process Setup"
{
    Caption = 'Business Process Setup';
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
            ToolTip = 'Specifies whether guided business process flows are enabled. Turning this on shows the related pages and the process bar; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
