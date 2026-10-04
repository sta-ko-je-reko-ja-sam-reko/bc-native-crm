namespace NBC.Test;

using NBC.Dataverse.Ownership;

/// <summary>Spy for the team logic seam: proves the team tables delegate their triggers to the injected logic.</summary>
codeunit 69094 "NBC Spy Team Logic" implements "NBC CDS ITeam"
{
    SingleInstance = true;

    var
        DeleteCalls: Integer;
        InsertMemberCalls: Integer;
        TeamLeadCalls: Integer;

    /// <summary>Clears the call counters.</summary>
    procedure Reset()
    begin
        DeleteCalls := 0;
        InsertMemberCalls := 0;
        TeamLeadCalls := 0;
    end;

    /// <summary>Calls of Trigger_OnDeleteTeam since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure DeleteCallCount(): Integer
    begin
        exit(DeleteCalls);
    end;

    /// <summary>Calls of Trigger_OnInsertMember since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure InsertMemberCallCount(): Integer
    begin
        exit(InsertMemberCalls);
    end;

    /// <summary>Calls of Validate_TeamLead since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure TeamLeadCallCount(): Integer
    begin
        exit(TeamLeadCalls);
    end;

    procedure Trigger_OnDeleteTeam(var Team: Record "NBC CDS Team")
    begin
        DeleteCalls += 1;
    end;

    procedure Trigger_OnInsertMember(var TeamMember: Record "NBC CDS Team Member")
    begin
        InsertMemberCalls += 1;
    end;

    procedure Validate_TeamLead(var TeamMember: Record "NBC CDS Team Member"; xTeamMember: Record "NBC CDS Team Member")
    begin
        TeamLeadCalls += 1;
    end;
}
