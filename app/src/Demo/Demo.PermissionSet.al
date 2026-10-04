namespace NBC.Demo;

using System.IO;

/// <summary>
/// Permissions for the demo-data layer: its own objects (via <see cref="NBC Demo Obj"/>) plus the base-app RapidStart
/// Config. Package tables the package builder writes on demo-data opt-in. Data written by the seeders lands in
/// standard and feature tables the running user already has via their functional permission sets.
/// </summary>
permissionset 65182 "NBC Demo"
{
    Caption = 'CRM Demo Data';
    Assignable = true;

    IncludedPermissionSets = "NBC Demo Obj";

    Permissions =
        tabledata "Config. Package" = RIMD,
        tabledata "Config. Package Table" = RIMD,
        tabledata "Config. Package Field" = RIMD;
}
