namespace NBC.CRM.RoleCenter;

using NBC.Setup;

/// <summary>Permissions for the CRM Role Center objects.</summary>
permissionset 50070 "NBC CRM Role Center"
{
    Caption = 'CRM Role Center';
    Assignable = true;

    Permissions =
        tabledata "NBC CRM Cue" = RIMD,
        table "NBC CRM Cue" = X,
        codeunit "NBC CRM Cue Mgt." = X,
        page "NBC CRM Role Center" = X,
        page "NBC CRM Activity Cues" = X,
        page "NBC CRM Sales Cues" = X,
        tabledata "NBC Role Center Setup" = RIMD,
        table "NBC Role Center Setup" = X,
        page "NBC Role Center Setup" = X;
}
