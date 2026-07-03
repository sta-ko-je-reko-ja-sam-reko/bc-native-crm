namespace NBC.Demo;

using Microsoft.CRM.Team;
using System.Security.User;

/// <summary>
/// Demo seeder for the CRM Role Center (FEAT-RC). The role center owns NO persistent records of
/// its own — every cue on it (activity + sales cues) is computed live and scoped to the CURRENT
/// USER's salesperson via User Setup. So the only meaningful "demo" is to guarantee that link
/// exists, so the cues actually populate the first time the user opens the CRM Salesperson role
/// center. Idempotent: only stamps a salesperson when the field is blank; safe to re-run.
/// </summary>
codeunit 50166 "NBC Demo Role Center"
{
    Access = Public;

    /// <summary>
    /// Ensures the current user is linked to a salesperson in User Setup so the role-center cues
    /// resolve. Creates the User Setup record if missing; leaves an already-populated
    /// "Salespers./Purch. Code" untouched; does nothing if no salesperson exists to assign.
    /// </summary>
    procedure Import()
    var
        UserSetup: Record "User Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CurrentUser: Code[50];
    begin
        CurrentUser := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
        if CurrentUser = '' then
            exit;

        // Need at least one salesperson to link to — otherwise there is nothing to seed.
        SalespersonPurchaser.SetLoadFields(Code);
        if not SalespersonPurchaser.FindFirst() then
            exit;

        if not UserSetup.Get(CurrentUser) then begin
            UserSetup.Init();
            UserSetup."User ID" := CurrentUser;
            UserSetup.Insert(true);
        end;

        // Idempotent: only stamp when currently unmapped; never overwrite an existing link.
        if UserSetup."Salespers./Purch. Code" = '' then begin
            UserSetup.Validate("Salespers./Purch. Code", SalespersonPurchaser."Code");
            UserSetup.Modify(true);
        end;

        CreateConfigPackage();
    end;

    /// <summary>Header-only Config. Package — the Role Center owns no persistable tables/fields (cues are computed).</summary>
    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
    begin
        ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl);
    end;

    var
        PackageCodeTok: Label 'NBC-ROLECENTER', Locked = true;
        PackageNameLbl: Label 'CRM Role Center';
}
