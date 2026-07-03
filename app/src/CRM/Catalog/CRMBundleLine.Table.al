namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

/// <summary>A component (item/resource) of a CRM bundle, with a required/optional flag.</summary>
table 50092 "NBC CRM Bundle Line"
{
    Caption = 'CRM Bundle Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Bundle No."; Code[20])
        {
            Caption = 'Bundle No.';
            NotBlank = true;
            TableRelation = "NBC CRM Bundle";
            ToolTip = 'Specifies the bundle the component belongs to.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
        }
        field(10; "Component Type"; Enum "NBC CRM Catalog Item Type")
        {
            Caption = 'Component Type';
            ToolTip = 'Specifies whether the component is an item or a resource.';
        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Component Type" = const(Item)) Item
                            else if ("Component Type" = const(Resource)) Resource;
            ToolTip = 'Specifies the item or resource component.';

            trigger OnValidate()
            begin
                Logic().Validate_No(Rec);
            end;
        }
        field(30; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the component.';
        }
        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies how many of the component are in the bundle.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(50; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
            ToolTip = 'Specifies the price per unit of the component.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(60; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            Editable = false;
            AutoFormatType = 2;
            ToolTip = 'Specifies the component amount (quantity multiplied by unit price).';
        }
        field(70; Required; Boolean)
        {
            Caption = 'Required';
            ToolTip = 'Specifies whether the component is mandatory in the bundle.';
        }
    }

    keys
    {
        key(PK; "Bundle No.", "Line No.") { Clustered = true; }
    }

    var
        ILogic: Interface "NBC CRM IBundle";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "NBC CRM IBundle"
    var
        Default: Codeunit "NBC CRM Bundle Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Inject an alternative bundle-line logic implementation (tests / downstream apps).</summary>
    procedure Define(Implementation: Interface "NBC CRM IBundle")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
