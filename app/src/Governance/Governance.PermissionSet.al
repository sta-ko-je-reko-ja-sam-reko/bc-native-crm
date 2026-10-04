namespace NBC.Governance;

using System.Diagnostics;

/// <summary>
/// Permissions for the CRM governance (audit &amp; duplicate) feature: its own objects (via
/// <see cref="NBC Governance Obj"/>) plus the base-app Change Log setup tables that enabling audit logging writes.
/// </summary>
permissionset 65080 "NBC Governance"
{
    Caption = 'CRM Governance';
    Assignable = true;

    IncludedPermissionSets = "NBC Governance Obj";

    Permissions =
        tabledata "Change Log Setup" = RIM,
        tabledata "Change Log Setup (Table)" = RIM;
}
