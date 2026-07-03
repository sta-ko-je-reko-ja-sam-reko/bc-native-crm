namespace NBC.Governance;

using NBC.Setup;
using System.Diagnostics;

/// <summary>Permissions for the CRM governance (audit &amp; duplicate) objects.</summary>
permissionset 50080 "NBC Governance"
{
    Caption = 'CRM Governance';
    Assignable = true;

    Permissions =
        tabledata "Change Log Setup" = RIM,
        tabledata "Change Log Setup (Table)" = RIM,
        codeunit "NBC Audit Mgt." = X,
        codeunit "NBC Duplicate Mgt." = X,
        tabledata "NBC Governance Setup" = RIMD,
        table "NBC Governance Setup" = X,
        page "NBC Governance Setup" = X;
}
