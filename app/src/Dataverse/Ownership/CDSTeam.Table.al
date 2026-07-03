namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>
/// A CRM Team — a group of salespersons that can own records collectively.
/// Native reimplementation of the Dataverse team as a record-owning principal.
/// </summary>
table 50020 "NBC CDS Team"
{
    Caption = 'CRM Team';
    DataClassification = CustomerContent;
    LookupPageId = "NBC CDS Teams";
    DrillDownPageId = "NBC CDS Teams";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Specifies a unique code that identifies the team.';
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the display name of the team.';
        }
        field(30; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the team.';
        }
        field(40; "Team Lead Salesp. Code"; Code[20])
        {
            Caption = 'Team Lead Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
            ToolTip = 'Specifies the salesperson who leads the team.';
        }
        field(50; "Member Count"; Integer)
        {
            Caption = 'Member Count';
            FieldClass = FlowField;
            CalcFormula = count("NBC CDS Team Member" where("Team Code" = field("Code")));
            Editable = false;
            ToolTip = 'Specifies how many salespersons are members of the team.';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name) { }
    }

    trigger OnDelete()
    begin
        Logic().Trigger_OnDeleteTeam(Rec);
    end;

    var
        ILogic: Interface "NBC CDS ITeam";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "NBC CDS ITeam"
    var
        Default: Codeunit "NBC CDS Team Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Inject an alternative team-logic implementation (tests / downstream apps).</summary>
    procedure Define(Implementation: Interface "NBC CDS ITeam")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
