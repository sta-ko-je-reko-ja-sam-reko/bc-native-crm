namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>An ordered stage of a CRM process.</summary>
table 50061 "NBC CRM Process Stage"
{
    Caption = 'CRM Process Stage';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Process Code"; Code[20])
        {
            Caption = 'Process Code';
            NotBlank = true;
            TableRelation = "NBC CRM Process";
            ToolTip = 'Specifies the process the stage belongs to.';
        }
        field(2; "Stage No."; Integer)
        {
            Caption = 'Stage No.';
            ToolTip = 'Specifies the order of the stage within the process.';
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the display name of the stage.';
        }
    }

    keys
    {
        key(PK; "Process Code", "Stage No.") { Clustered = true; }
    }
}
