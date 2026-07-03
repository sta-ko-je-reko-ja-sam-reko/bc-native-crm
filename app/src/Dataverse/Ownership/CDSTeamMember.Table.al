namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>Membership of a Salesperson/Purchaser in a CRM Team.</summary>
table 50021 "NBC CDS Team Member"
{
    Caption = 'CRM Team Member';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Team Code"; Code[20])
        {
            Caption = 'Team Code';
            NotBlank = true;
            TableRelation = "NBC CDS Team";
            ToolTip = 'Specifies the team the salesperson belongs to.';
        }
        field(20; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser";
            ToolTip = 'Specifies the salesperson who is a member of the team.';
        }
        field(30; "Team Lead"; Boolean)
        {
            Caption = 'Team Lead';
            ToolTip = 'Specifies whether this member leads the team.';

            trigger OnValidate()
            begin
                Logic().Validate_TeamLead(Rec, xRec);
            end;
        }
        field(40; "Salesperson Name"; Text[100])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Salesperson/Purchaser".Name where(Code = field("Salesperson Code")));
            Editable = false;
            ToolTip = 'Specifies the name of the salesperson.';
        }
    }

    keys
    {
        key(PK; "Team Code", "Salesperson Code") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsertMember(Rec);
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
