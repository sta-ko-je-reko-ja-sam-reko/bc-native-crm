namespace NBC.CRM.Pricing;

/// <summary>A reusable, quantity-banded discount list attachable to many price-list lines.</summary>
table 50100 "NBC CRM Discount List"
{
    Caption = 'CRM Discount List';
    DataClassification = CustomerContent;
    LookupPageId = "NBC CRM Discount Lists";
    DrillDownPageId = "NBC CRM Discount Lists";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Specifies the unique identifier of the discount list.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the discount list.';
        }
        field(20; "Discount Type"; Enum "NBC CRM Discount Type")
        {
            Caption = 'Discount Type';
            ToolTip = 'Specifies whether the tiers express a percentage or a fixed amount.';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Discount Type") { }
    }
}
