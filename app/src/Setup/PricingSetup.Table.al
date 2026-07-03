namespace NBC.Setup;

/// <summary>Single-record setup for the Pricing Flexibility feature.</summary>
table 50138 "NBC Pricing Setup"
{
    Caption = 'Pricing Setup';
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
            ToolTip = 'Specifies whether pricing flexibility (pricing methods, discount tiers, rounding) is enabled. Turning this on shows the related fields and actions; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
