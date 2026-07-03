namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;
using NBC.Setup;

/// <summary>Permissions for the CRM business-process-flow objects.</summary>
permissionset 50060 "NBC CRM Processes"
{
    Caption = 'CRM Processes';
    Assignable = true;

    Permissions =
        tabledata "NBC CRM Process" = RIMD,
        tabledata "NBC CRM Process Stage" = RIMD,
        tabledata "NBC CRM Process State" = RIMD,
        table "NBC CRM Process" = X,
        table "NBC CRM Process Stage" = X,
        table "NBC CRM Process State" = X,
        codeunit "NBC CRM Process Mgt." = X,
        codeunit "NBC CRM Process Install" = X,
        page "NBC CRM Processes" = X,
        page "NBC CRM Process Card" = X,
        page "NBC CRM Process Stages" = X,
        page "NBC CRM Process Bar Part" = X,
        page "NBC CRM API Process" = X,
        page "NBC CRM API Process Stage" = X,
        page "NBC CRM API Process State" = X,
        tabledata "NBC Process Setup" = RIMD,
        table "NBC Process Setup" = X,
        page "NBC Process Setup" = X;
}
