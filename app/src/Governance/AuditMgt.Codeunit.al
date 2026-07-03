namespace NBC.Governance;

using NBC.CRM.Opportunity;
using NBC.CRM.Process;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using System.Diagnostics;

/// <summary>Enables BC Change Log audit tracking for the CRM tables (reuses the native Change Log).</summary>
codeunit 50080 "NBC Audit Mgt."
{
    Access = Public;

    trigger OnRun()
    begin
        EnableCrmAuditLogging();
    end;

    /// <summary>Activate Change Log and register the CRM tables for all-field logging.</summary>
    procedure EnableCrmAuditLogging()
    var
        ChangeLogSetup: Record "Change Log Setup";
        ChangeLogManagement: Codeunit "Change Log Management";
        EnabledMsg: Label 'CRM audit logging is enabled — Change Log now tracks the CRM tables.';
    begin
        if not ChangeLogSetup.FindFirst() then begin
            ChangeLogSetup.Init();
            ChangeLogSetup.Insert();
        end;
        ChangeLogSetup."Change Log Activated" := true;
        ChangeLogSetup.Modify();

        RegisterTable(Database::"NBC CDS Team");
        RegisterTable(Database::"NBC CDS Activity");
        RegisterTable(Database::"NBC CRM Opp. Line");
        RegisterTable(Database::"NBC CRM Process State");

        ChangeLogManagement.InitChangeLog();
        Message(EnabledMsg);
    end;

    local procedure RegisterTable(TableId: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
    begin
        if ChangeLogSetupTable.Get(TableId) then
            exit;
        ChangeLogSetupTable.Init();
        ChangeLogSetupTable."Table No." := TableId;
        ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"All Fields";
        ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"All Fields";
        ChangeLogSetupTable."Log Deletion" := ChangeLogSetupTable."Log Deletion"::"All Fields";
        ChangeLogSetupTable.Insert(true);
    end;
}
