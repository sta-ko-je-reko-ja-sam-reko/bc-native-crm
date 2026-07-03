namespace NBC.CRM.RoleCenter;

using Microsoft.CRM.Opportunity;
using NBC.Dataverse.Activities;

/// <summary>Singleton cue table for the CRM Role Center; FlowFields scoped by FlowFilters.</summary>
table 50070 "NBC CRM Cue"
{
    Caption = 'CRM Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key of the singleton cue record.';
        }
        field(10; "Owner Code Filter"; Code[20])
        {
            Caption = 'Owner Code Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies the owner (salesperson/team) the activity cues are filtered to.';
        }
        field(11; "Salesperson Code Filter"; Code[20])
        {
            Caption = 'Salesperson Code Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies the salesperson the opportunity cues are filtered to.';
        }
        field(12; "Overdue Before Filter"; Date)
        {
            Caption = 'Overdue Before Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies the date range used to detect overdue activities.';
        }
        field(20; "My Open Activities"; Integer)
        {
            Caption = 'My Open Activities';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("NBC CDS Activity" where("Owner Code" = field("Owner Code Filter"), Status = const(Open)));
            ToolTip = 'Specifies the number of open activities you own.';
        }
        field(21; "Overdue Activities"; Integer)
        {
            Caption = 'Overdue Activities';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("NBC CDS Activity" where("Owner Code" = field("Owner Code Filter"), Status = const(Open), "Due Date" = field("Overdue Before Filter")));
            ToolTip = 'Specifies the number of your open activities that are overdue.';
        }
        field(22; "My Opportunities"; Integer)
        {
            Caption = 'My Opportunities';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count(Opportunity where("Salesperson Code" = field("Salesperson Code Filter")));
            ToolTip = 'Specifies the number of opportunities assigned to you.';
        }
        field(23; "Opportunities In Progress"; Integer)
        {
            Caption = 'Opportunities In Progress';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count(Opportunity where("Salesperson Code" = field("Salesperson Code Filter"), Status = const("In Progress")));
            ToolTip = 'Specifies the number of your opportunities that are in progress.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
