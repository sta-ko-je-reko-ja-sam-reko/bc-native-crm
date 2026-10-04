namespace NBC.Governance;

using NBC.Setup;

/// <summary>
/// The governance feature's own objects only. Non-assignable building block: the assignable
/// <see cref="NBC Governance"/> set adds the base-app Change Log tables on top, and the entitlement-bound license
/// sets include this one, because an entitlement ignores permissions on objects of other modules (AL0684).
/// </summary>
permissionset 65081 "NBC Governance Obj"
{
    Caption = 'CRM Governance Objects';
    Assignable = false;

    Permissions =
        codeunit "NBC Audit Mgt." = X,
        codeunit "NBC Duplicate Mgt." = X,
        tabledata "NBC Governance Setup" = RIMD,
        table "NBC Governance Setup" = X,
        page "NBC Governance Setup" = X;
}
