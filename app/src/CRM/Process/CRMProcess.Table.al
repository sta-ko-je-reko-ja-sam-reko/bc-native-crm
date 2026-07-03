namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>A business-process-flow definition bound to an entity (native BPF reimplementation).</summary>
table 50060 "NBC CRM Process"
{
    Caption = 'CRM Process';
    DataClassification = CustomerContent;
    LookupPageId = "NBC CRM Processes";
    DrillDownPageId = "NBC CRM Processes";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Specifies a unique code for the process.';
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the display name of the process.';
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the table (entity) the process applies to.';
        }
        field(30; Active; Boolean)
        {
            Caption = 'Active';
            ToolTip = 'Specifies whether this is the active process for its table.';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
        key(TableActive; "Table No.", Active) { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name) { }
    }
}
