namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>Default implementation of CRM ITeam — team/member trigger and validation logic.</summary>
codeunit 50021 "NBC CDS Team Logic" implements "NBC CDS ITeam"
{
    Access = Public;

    procedure Trigger_OnDeleteTeam(var Team: Record "NBC CDS Team")
    var
        TeamMember: Record "NBC CDS Team Member";
    begin
        TeamMember.SetRange("Team Code", Team."Code");
        TeamMember.DeleteAll(false);
    end;

    procedure Trigger_OnInsertMember(var TeamMember: Record "NBC CDS Team Member")
    begin
        // Reserved for future member-insert defaults; kept as an explicit delegation target.
    end;

    procedure Validate_TeamLead(var TeamMember: Record "NBC CDS Team Member"; xTeamMember: Record "NBC CDS Team Member")
    var
        OtherMember: Record "NBC CDS Team Member";
        Team: Record "NBC CDS Team";
    begin
        if not TeamMember."Team Lead" then
            exit;

        // Only one lead per team — clear the flag on any other member.
        OtherMember.SetRange("Team Code", TeamMember."Team Code");
        OtherMember.SetFilter("Salesperson Code", '<>%1', TeamMember."Salesperson Code");
        OtherMember.SetRange("Team Lead", true);
        if not OtherMember.IsEmpty() then
            OtherMember.ModifyAll("Team Lead", false);

        // Reflect the lead on the team header.
        if Team.Get(TeamMember."Team Code") then begin
            Team."Team Lead Salesp. Code" := TeamMember."Salesperson Code";
            Team.Modify(true);
        end;
    end;
}
