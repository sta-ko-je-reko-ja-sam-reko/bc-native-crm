namespace NBC.Demo;

using System.IO;

/// <summary>
/// Permissions for the demo-data layer: the shared dummy table, every feature demo seeder, the master runner, the
/// per-feature import API pages, and the RapidStart Config. Package builder (which each seeder uses on demo-data
/// opt-in). Included in the top CRM license. Data written by the seeders lands in standard and feature tables the
/// running user already has via their functional permission sets.
/// </summary>
permissionset 50182 "NBC Demo"
{
    Caption = 'CRM Demo Data';
    Assignable = true;

    Permissions =
        tabledata "NBC Demo Data" = RIMD,
        table "NBC Demo Data" = X,
        tabledata "Config. Package" = RIMD,
        tabledata "Config. Package Table" = RIMD,
        tabledata "Config. Package Field" = RIMD,
        codeunit "NBC Demo Config Package" = X,
        codeunit "NBC Demo Data Mgt." = X,
        codeunit "NBC Demo Ownership" = X,
        codeunit "NBC Demo Activities" = X,
        codeunit "NBC Demo Party" = X,
        codeunit "NBC Demo Opportunity" = X,
        codeunit "NBC Demo Process" = X,
        codeunit "NBC Demo Role Center" = X,
        codeunit "NBC Demo Governance" = X,
        codeunit "NBC Demo Catalog" = X,
        codeunit "NBC Demo Pricing" = X,
        codeunit "NBC Demo Linkage" = X,
        page "NBC API Demo Ownership" = X,
        page "NBC API Demo Activities" = X,
        page "NBC API Demo Party" = X,
        page "NBC API Demo Opportunity" = X,
        page "NBC API Demo Process" = X,
        page "NBC API Demo Role Center" = X,
        page "NBC API Demo Governance" = X,
        page "NBC API Demo Catalog" = X,
        page "NBC API Demo Pricing" = X,
        page "NBC API Demo Linkage" = X;
}
