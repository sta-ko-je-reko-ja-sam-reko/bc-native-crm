namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>A product/resource line on a CRM opportunity; the lines roll up to estimated revenue.</summary>
table 50040 "NBC CRM Opp. Line"
{
    Caption = 'CRM Opportunity Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Opportunity No."; Code[20])
        {
            Caption = 'Opportunity No.';
            NotBlank = true;
            TableRelation = Opportunity;
            ToolTip = 'Specifies the opportunity the line belongs to.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
        }
        field(10; Type; Enum "NBC CRM Opp. Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies whether the line is a comment, an item or a resource.';
        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(Item)) Item
                            else if (Type = const(Resource)) Resource;
            ToolTip = 'Specifies the item or resource on the line.';

            trigger OnValidate()
            begin
                Logic().Validate_No(Rec);
            end;
        }
        field(30; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the line.';
        }
        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies the quantity.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(50; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            ToolTip = 'Specifies the price per unit.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(60; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            Editable = false;
            ToolTip = 'Specifies the line amount (quantity multiplied by unit price).';
        }
    }

    keys
    {
        key(PK; "Opportunity No.", "Line No.") { Clustered = true; }
    }

    var
        ILogic: Interface "NBC CRM IOpportunityLine";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "NBC CRM IOpportunityLine"
    var
        Default: Codeunit "NBC CRM Opp. Line Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Inject an alternative line-logic implementation (tests / downstream apps).</summary>
    procedure Define(Implementation: Interface "NBC CRM IOpportunityLine")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
