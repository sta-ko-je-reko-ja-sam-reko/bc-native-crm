namespace NBC.Demo;

/// <summary>
/// Minimal shared source table for the demo-import API pages. The import pages exist for their [ServiceEnabled]
/// ImportDemoData action (the MCP tool), not for their rows — this dummy table is just a valid SourceTable.
/// </summary>
table 50160 "NBC Demo Data"
{
    Caption = 'Demo Data';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
