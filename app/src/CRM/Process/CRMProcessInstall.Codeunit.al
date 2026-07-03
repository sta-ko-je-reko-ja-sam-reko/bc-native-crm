namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>Seeds default CRM processes on install/upgrade (idempotent).</summary>
codeunit 50061 "NBC CRM Process Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        ProcessMgt: Codeunit "NBC CRM Process Mgt.";
    begin
        ProcessMgt.EnsureDefaultOpportunityProcess();
    end;
}
