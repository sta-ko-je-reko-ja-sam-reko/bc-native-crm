namespace NBC.Setup;

/// <summary>Single-record setup for the Product Catalog feature.</summary>
table 50137 "NBC Catalog Setup"
{
    Caption = 'Product Catalog Setup';
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
            ToolTip = 'Specifies whether the product sales catalog (lifecycle, bundles, relations) is enabled. Turning this on shows the related fields, pages and actions; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
