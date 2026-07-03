namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>
/// CRM ownership service. Resolves the current user's owner identity (via User Setup →
/// Salesperson), stamps default owners, evaluates ownership, and builds the "my records"
/// convenience filter. See FEAT-OWN-001 for the row-level-security scope decision.
/// </summary>
codeunit 50020 "NBC CDS Owner Mgt."
{
    Access = Public;

    /// <summary>The Salesperson code linked to the current user in User Setup, or '' if none.</summary>
    procedure GetCurrentUserSalesperson(): Code[20]
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            exit(UserSetup."Salespers./Purch. Code");
        exit('');
    end;

    /// <summary>Default owner for a new record = the current user's salesperson. FALSE if unmapped.</summary>
    procedure GetDefaultOwner(var OwnerType: Enum "NBC CDS Owner Type"; var OwnerCode: Code[20]): Boolean
    begin
        OwnerType := OwnerType::Salesperson;
        OwnerCode := GetCurrentUserSalesperson();
        exit(OwnerCode <> '');
    end;

    /// <summary>Is the given salesperson a member of the given team?</summary>
    procedure IsSalespersonInTeam(TeamCode: Code[20]; SalespersonCode: Code[20]): Boolean
    var
        TeamMember: Record "NBC CDS Team Member";
    begin
        exit(TeamMember.Get(TeamCode, SalespersonCode));
    end;

    /// <summary>Does the current user own (directly or via a team) a record with this owner?</summary>
    procedure IsOwnedByCurrentUser(OwnerType: Enum "NBC CDS Owner Type"; OwnerCode: Code[20]): Boolean
    var
        MySalesperson: Code[20];
    begin
        MySalesperson := GetCurrentUserSalesperson();
        if MySalesperson = '' then
            exit(false);
        case OwnerType of
            OwnerType::Salesperson:
                exit(OwnerCode = MySalesperson);
            OwnerType::Team:
                exit(IsSalespersonInTeam(OwnerCode, MySalesperson));
        end;
        exit(false);
    end;

    /// <summary>
    /// Filter expression (for "NBC CDS Owner Code") matching records owned by the current user or
    /// any team they belong to — e.g. 'SP01|TEAM-A|TEAM-B'. '' if the user has no owner keys.
    /// </summary>
    procedure GetMyOwnerCodeFilter(): Text
    var
        TeamMember: Record "NBC CDS Team Member";
        MySalesperson: Code[20];
    begin
        MySalesperson := GetCurrentUserSalesperson();
        TeamMember.SetRange("Salesperson Code", MySalesperson);
        exit(BuildOwnerCodeFilter(MySalesperson, TeamMember));
    end;

    /// <summary>
    /// Pure builder (unit-testable, no DB reads of its own): combines a salesperson code with the
    /// team codes in the supplied (optionally filtered/temporary) member set into a '|' filter.
    /// </summary>
    procedure BuildOwnerCodeFilter(SalespersonCode: Code[20]; var TeamMember: Record "NBC CDS Team Member"): Text
    var
        FilterBuilder: TextBuilder;
    begin
        if SalespersonCode <> '' then
            FilterBuilder.Append(SalespersonCode);
        if TeamMember.FindSet() then
            repeat
                if FilterBuilder.Length() > 0 then
                    FilterBuilder.Append('|');
                FilterBuilder.Append(TeamMember."Team Code");
            until TeamMember.Next() = 0;
        exit(FilterBuilder.ToText());
    end;
}
