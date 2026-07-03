namespace NBC.CRM.Catalog;

/// <summary>
/// A priced-as-one sellable package (the Dataverse bundle analog). Deliberately NOT a BOM/Assembly —
/// those are manufacturable supply-chain structures, not catalog packages sold as a single line.
/// </summary>
table 50091 "NBC CRM Bundle"
{
    Caption = 'CRM Bundle';
    DataClassification = CustomerContent;
    LookupPageId = "NBC CRM Bundles";
    DrillDownPageId = "NBC CRM Bundles";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            ToolTip = 'Specifies the unique identifier of the bundle.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the bundle.';
        }
        field(20; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
            ToolTip = 'Specifies the price the bundle is sold for as a single line.';
        }
        field(30; "Catalog Status"; Enum "NBC CRM Catalog Status")
        {
            Caption = 'Catalog Status';
            ToolTip = 'Specifies the selling lifecycle state of the bundle.';
        }
        field(40; "Component Total"; Decimal)
        {
            Caption = 'Component Total';
            FieldClass = FlowField;
            CalcFormula = sum("NBC CRM Bundle Line"."Line Amount" where("Bundle No." = field("No.")));
            Editable = false;
            AutoFormatType = 2;
            ToolTip = 'Specifies the total of the component lines (for comparison with the bundle price).';
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Unit Price") { }
    }
}
