namespace NBC.Core;

using System.Security.AccessControl;

/// <summary>
/// Default access policy: the current user's EFFECTIVE permission on an object, checked BY OBJECT ID through
/// Microsoft's <c>Effective Permissions Mgt.</c> (which reads Expanded Permission + Access Control + entitlements
/// internally) — so it never instantiates our own, possibly-unlicensed, object and never touches the deprecated
/// Permission table. Lives in the Unlicensed base entitlement so it runs for every user; <c>SingleInstance</c> with
/// per-session caching because effective permissions are constant within a session.
/// </summary>
codeunit 50001 "NBC Access Policy" implements "NBC IAccessPolicy"
{
    Access = Public;
    SingleInstance = true;

    var
        ExecuteCache: Dictionary of [Integer, Boolean];
        ReadCache: Dictionary of [Integer, Boolean];

    procedure HasEffectiveExecute(CodeunitId: Integer): Boolean
    var
        HasIt: Boolean;
    begin
        if ExecuteCache.ContainsKey(CodeunitId) then
            exit(ExecuteCache.Get(CodeunitId));
        HasIt := HasEffective(CodeunitId, false);
        ExecuteCache.Set(CodeunitId, HasIt);
        exit(HasIt);
    end;

    procedure HasEffectiveRead(TableId: Integer): Boolean
    var
        HasIt: Boolean;
    begin
        if ReadCache.ContainsKey(TableId) then
            exit(ReadCache.Get(TableId));
        HasIt := HasEffective(TableId, true);
        ReadCache.Set(TableId, HasIt);
        exit(HasIt);
    end;

    local procedure HasEffective(ObjectId: Integer; CheckRead: Boolean): Boolean
    var
        TempPermissionBuffer: Record "Permission Buffer" temporary;
        ExpandedPermission: Record "Expanded Permission";
        EffectivePermissionsMgt: Codeunit "Effective Permissions Mgt.";
        ObjectType: Integer;
    begin
        if CheckRead then
            ObjectType := ExpandedPermission."Object Type"::"Table Data"
        else
            ObjectType := ExpandedPermission."Object Type"::Codeunit;

        EffectivePermissionsMgt.PopulatePermissionBuffer(
            TempPermissionBuffer, UserSecurityId(), CopyStr(CompanyName(), 1, 50), ObjectType, ObjectId);

        if CheckRead then
            TempPermissionBuffer.SetFilter("Read Permission", '<>%1', TempPermissionBuffer."Read Permission"::" ")
        else
            TempPermissionBuffer.SetFilter("Execute Permission", '<>%1', TempPermissionBuffer."Execute Permission"::" ");
        exit(not TempPermissionBuffer.IsEmpty());
    end;
}
