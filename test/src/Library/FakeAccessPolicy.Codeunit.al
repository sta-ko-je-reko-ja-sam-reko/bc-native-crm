namespace NBC.Test;

using NBC.Core;

/// <summary>
/// Test double for the swappable access policy: grants or denies every effective-permission check, so feature
/// tests do not depend on the test user's real permission sets or entitlements. SingleInstance so its setting
/// survives being handed to the Service Locator.
/// </summary>
codeunit 69091 "NBC Fake Access Policy" implements "NBC IAccessPolicy"
{
    SingleInstance = true;

    var
        Deny: Boolean;

    /// <summary>Grant (true) or deny (false) every check from now on.</summary>
    /// <param name="Grant">Whether checks pass.</param>
    procedure SetGrant(Grant: Boolean)
    begin
        Deny := not Grant;
    end;

    procedure HasEffectiveExecute(CodeunitId: Integer): Boolean
    begin
        exit(not Deny);
    end;

    procedure HasEffectiveRead(TableId: Integer): Boolean
    begin
        exit(not Deny);
    end;
}
