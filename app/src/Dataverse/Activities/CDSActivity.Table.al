namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>
/// A unified CRM activity (task / phone call / appointment / email / note) that can regard any
/// record. Native reimplementation of the Dataverse activity model.
/// </summary>
table 50030 "NBC CDS Activity"
{
    Caption = 'CRM Activity';
    DataClassification = CustomerContent;
    LookupPageId = "NBC CDS Activities";
    DrillDownPageId = "NBC CDS Activities";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the unique entry number of the activity.';
        }
        field(10; "Activity Type"; Enum "NBC CDS Activity Type")
        {
            Caption = 'Activity Type';
            ToolTip = 'Specifies the kind of activity.';
        }
        field(20; Subject; Text[100])
        {
            Caption = 'Subject';
            ToolTip = 'Specifies a short summary of the activity.';
        }
        field(30; Description; Text[2048])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the details of the activity.';
        }
        field(40; "Regarding Table No."; Integer)
        {
            Caption = 'Regarding Table No.';
            ToolTip = 'Specifies the table of the record this activity is about.';
            Editable = false;
        }
        field(41; "Regarding System ID"; Guid)
        {
            Caption = 'Regarding System ID';
            ToolTip = 'Specifies the record this activity is about.';
            Editable = false;
        }
        field(42; "Regarding Description"; Text[100])
        {
            Caption = 'Regarding';
            ToolTip = 'Specifies the record this activity is about.';
            Editable = false;
        }
        field(50; "Owner Type"; Enum "NBC CDS Owner Type")
        {
            Caption = 'Owner Type';
            ToolTip = 'Specifies whether the activity is owned by a salesperson or a team.';
        }
        field(51; "Owner Code"; Code[20])
        {
            Caption = 'Owner';
            TableRelation = if ("Owner Type" = const(Salesperson)) "Salesperson/Purchaser"
                            else if ("Owner Type" = const(Team)) "NBC CDS Team";
            ToolTip = 'Specifies the salesperson or team that owns the activity.';
        }
        field(60; Status; Enum "NBC CDS Activity Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the lifecycle status of the activity.';

            trigger OnValidate()
            begin
                Logic().Validate_Status(Rec);
            end;
        }
        field(61; Priority; Enum "NBC CDS Activity Priority")
        {
            Caption = 'Priority';
            ToolTip = 'Specifies the priority of the activity.';
        }
        field(62; Direction; Enum "NBC CDS Activity Direction")
        {
            Caption = 'Direction';
            ToolTip = 'Specifies whether the activity is incoming or outgoing.';
        }
        field(70; "Activity Date"; DateTime)
        {
            Caption = 'Activity Date';
            ToolTip = 'Specifies when the activity happened or is scheduled; drives timeline ordering.';
        }
        field(71; "Due Date"; Date)
        {
            Caption = 'Due Date';
            ToolTip = 'Specifies the date the activity is due.';
        }
        field(72; "Closed DateTime"; DateTime)
        {
            Caption = 'Closed Date-Time';
            Editable = false;
            ToolTip = 'Specifies when the activity was completed or canceled.';
        }
        field(80; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
            ToolTip = 'Specifies the user who created the activity.';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Regarding; "Regarding Table No.", "Regarding System ID", "Activity Date") { }
        key(ActivityDate; "Activity Date") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Activity Type", Subject, "Activity Date") { }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "NBC CDS IActivity";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "NBC CDS IActivity"
    var
        Default: Codeunit "NBC CDS Activity Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Inject an alternative activity-logic implementation (tests / downstream apps).</summary>
    procedure Define(Implementation: Interface "NBC CDS IActivity")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
