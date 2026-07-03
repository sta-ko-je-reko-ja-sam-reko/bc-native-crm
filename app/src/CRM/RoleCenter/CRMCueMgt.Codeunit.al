namespace NBC.CRM.RoleCenter;

using NBC.Dataverse.Ownership;

/// <summary>Prepares the CRM cue record and scopes its FlowFilters to the current user.</summary>
codeunit 50070 "NBC CRM Cue Mgt."
{
    Access = Public;

    /// <summary>Ensure the singleton cue record exists and set its FlowFilters for the current user.</summary>
    procedure PrepareCue(var Cue: Record "NBC CRM Cue")
    var
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        MySalesperson: Code[20];
    begin
        Cue.Reset();
        if not Cue.FindFirst() then begin
            Cue.Init();
            Cue."Primary Key" := '';
            if Cue.Insert() then;
        end;

        MySalesperson := OwnerMgt.GetCurrentUserSalesperson();
        Cue.SetRange("Owner Code Filter", MySalesperson);
        Cue.SetRange("Salesperson Code Filter", MySalesperson);
        Cue.SetRange("Overdue Before Filter", DMY2Date(1, 1, 1900), CalcDate('<-1D>', Today()));
    end;
}
