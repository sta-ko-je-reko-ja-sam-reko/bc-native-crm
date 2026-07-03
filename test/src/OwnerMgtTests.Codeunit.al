namespace NBC.Test;

using NBC.Dataverse.Ownership;

/// <summary>
/// Unit tests for CRM Owner Mgt. — focuses on the pure, DB-free owner-code filter builder.
/// (Owner-defaulting and membership behaviour that touch User Setup / physical data belong in the
/// integration test plan.)
/// </summary>
codeunit 50900 "NBC CDS Owner Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure BuildOwnerCodeFilter_CombinesSalespersonAndTeams()
    var
        TempTeamMember: Record "NBC CDS Team Member" temporary;
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        Result: Text;
    begin
        // [GIVEN] a salesperson that belongs to two teams
        AddTempMembership(TempTeamMember, 'TEAM-A', 'SP01');
        AddTempMembership(TempTeamMember, 'TEAM-B', 'SP01');

        // [WHEN] building the owner-code filter for that salesperson
        Result := OwnerMgt.BuildOwnerCodeFilter('SP01', TempTeamMember);

        // [THEN] it is the salesperson code OR-ed with each team code
        if Result <> 'SP01|TEAM-A|TEAM-B' then
            Error('Expected ''SP01|TEAM-A|TEAM-B'' but got ''%1''.', Result);
    end;

    [Test]
    procedure BuildOwnerCodeFilter_NoTeams_ReturnsSalespersonOnly()
    var
        TempTeamMember: Record "NBC CDS Team Member" temporary;
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        Result: Text;
    begin
        // [GIVEN] a salesperson in no teams  [WHEN] building the filter
        Result := OwnerMgt.BuildOwnerCodeFilter('SP01', TempTeamMember);

        // [THEN] only the salesperson code is returned
        if Result <> 'SP01' then
            Error('Expected ''SP01'' but got ''%1''.', Result);
    end;

    [Test]
    procedure BuildOwnerCodeFilter_NoSalesperson_ReturnsTeamsOnly()
    var
        TempTeamMember: Record "NBC CDS Team Member" temporary;
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        Result: Text;
    begin
        // [GIVEN] one team membership  [WHEN] building the filter with no current salesperson
        AddTempMembership(TempTeamMember, 'TEAM-A', 'SPX');
        Result := OwnerMgt.BuildOwnerCodeFilter('', TempTeamMember);

        // [THEN] only the team code is returned (no leading separator)
        if Result <> 'TEAM-A' then
            Error('Expected ''TEAM-A'' but got ''%1''.', Result);
    end;

    local procedure AddTempMembership(var TempTeamMember: Record "NBC CDS Team Member" temporary; TeamCode: Code[20]; SalespersonCode: Code[20])
    begin
        TempTeamMember.Init();
        TempTeamMember."Team Code" := TeamCode;
        TempTeamMember."Salesperson Code" := SalespersonCode;
        TempTeamMember.Insert();
    end;
}
