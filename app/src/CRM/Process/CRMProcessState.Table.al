namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>Per-record progress through a CRM process (generic by table no. + record SystemId).</summary>
table 50062 "NBC CRM Process State"
{
    Caption = 'CRM Process State';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the table of the record the state belongs to.';
        }
        field(2; "Record System ID"; Guid)
        {
            Caption = 'Record System ID';
            ToolTip = 'Specifies the record the state belongs to.';
        }
        field(10; "Process Code"; Code[20])
        {
            Caption = 'Process Code';
            TableRelation = "NBC CRM Process";
            ToolTip = 'Specifies the process being followed.';
        }
        field(20; "Current Stage No."; Integer)
        {
            Caption = 'Current Stage No.';
            ToolTip = 'Specifies the current stage (0 = not started).';
        }
        field(30; "Started DateTime"; DateTime)
        {
            Caption = 'Started Date-Time';
            ToolTip = 'Specifies when the process was started.';
        }
        field(40; "Completed DateTime"; DateTime)
        {
            Caption = 'Completed Date-Time';
            ToolTip = 'Specifies when the process was completed.';
        }
    }

    keys
    {
        key(PK; "Table No.", "Record System ID") { Clustered = true; }
    }
}
