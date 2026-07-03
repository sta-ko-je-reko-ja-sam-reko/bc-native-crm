namespace NBC.CRM.Pricing;

/// <summary>A quantity band (min..max) and its value within a reusable discount list.</summary>
table 50101 "NBC CRM Discount Tier"
{
    Caption = 'CRM Discount Tier';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Discount List Code"; Code[20])
        {
            Caption = 'Discount List Code';
            NotBlank = true;
            TableRelation = "NBC CRM Discount List";
            ToolTip = 'Specifies the discount list the tier belongs to.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
        }
        field(10; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            ToolTip = 'Specifies the lowest quantity the tier applies to.';
        }
        field(20; "Maximum Quantity"; Decimal)
        {
            Caption = 'Maximum Quantity';
            ToolTip = 'Specifies the highest quantity the tier applies to (0 means no upper bound).';
        }
        field(30; Value; Decimal)
        {
            Caption = 'Value';
            ToolTip = 'Specifies the discount percentage or amount, per the discount list type.';
        }
    }

    keys
    {
        key(PK; "Discount List Code", "Line No.") { Clustered = true; }
        key(Band; "Discount List Code", "Minimum Quantity") { }
    }
}
